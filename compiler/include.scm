;; ***** BEGIN LICENSE BLOCK *****
;; Roadsend PHP Compiler
;; Copyright (C) 2007 Roadsend, Inc.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
;; ***** END LICENSE BLOCK *****

; include machinery
(module include
   (load (php-macros "../php-macros.scm"))
   (library profiler php-runtime)
   (include "../runtime/php-runtime.sch")
   (import (ast "ast.scm")
           (driver "driver.scm"))
   (export
    (lib_include_exists file)
    (do-include-paths)
    (find-include-file-in-lib file cwd)
    (find-include-files ast)
    (php-include file)
    (php-require file)
    (include_once file)
    (require_once file)
    (restore_include_path)
    (include-name filename)))

; save once at init
; integrate temp-includes
(define (do-include-paths)
   ; once *after* read-config and commandline has setup original include path
   (when (null? *orig-include-paths*)
      (for-each (lambda (v)
		   (set! *orig-include-paths* (cons v *orig-include-paths*)))
		*include-paths*))
   ; integrate temp includes for this view
   (when (pair? *temp-include-paths*)
      (for-each (lambda (v)
		   (set! *include-paths* (cons v *include-paths*)))
		*temp-include-paths*))
   (set-ini-entry "include_path" (string-join *include-paths* (string (path-separator)))))

; restore every page load
(define (restore-include-paths)
   (set! *include-paths* '())
   (set! *temp-include-paths* '())
   (set! *all-files-ever-included* (make-hashtable))
   (for-each (lambda (v)
		(set! *include-paths* (cons v *include-paths*)))
	     *orig-include-paths*))   

; run after every page view
(add-end-page-reset-func restore-include-paths)

; this is also a userland function
(defbuiltin (restore_include_path)
   (restore-include-paths))


(defalias include php-include)
(defbuiltin (php-include file)
   (do-include (mkstr file) #f #f))

(defbuiltin (include_once file)
   (do-include (mkstr file) #f #t))

(defalias require php-require)
(defbuiltin (php-require file)
   (do-include (mkstr file) #t #f))

(defbuiltin (require_once file)
   (do-include (mkstr file) #t #t))

; user access to find out if include file is available from a currently loaded library
; this is a raven extension
(defbuiltin (lib_include_exists file)
   (if (find-include-file-in-lib (mkstr file) (or *library-cwd* *PHP-FILE*))
       #t
       #f))


(define (include-name filename)
   (string->symbol
    ;(string-downcase
    (mkstr "+include+:" filename)))


; (define (include-name-from-root filename)
;    (let* ((root (util-realpath (pwd)))
; 	  ;; assumes filename always has realpath on it
; 	  (file-from-root (substring filename (+ (string-length root) 1) (string-length filename))))
;       (include-name (maybe-strip-lead-slash file-from-root))))


;;;# Include Files

;;; ``Files for including are first looked in include_path relative to the
;;; current working directory and then in include_path relative to the
;;; directory of current script. E.g. if your include_path is ., current
;;; working directory is /www/, you included include/a.php and there is
;;; include "b.php" in that file, b.php is first looked in /www/ and then
;;; in /www/include/. If filename begins with ../, it is looked only in
;;; include_path relative to the current working directory.''

;;; I. search for file in include_path relative to cwd
;;; II. when file doesn't start with ../
;;;     search for file in include_path relative to directory of the current script)


;;; we prefer libraries for security reasons or something, so the full
;;; algorithm is:

;;; if the file starts with ../, check only relative to cwd, not in
;;; include path (this is the way php behaves, even if it's not the
;;; way it's documented.)

;;; I. in library, 
;;;   a. search for file in include_path relative to cwd 
;;;   b. search for file in include_path relative to directory of current script

;;; II. on disk
;;;   a. search for file in include_path relative to cwd
;;;   b. search for file in include_path relative to directory of current script


;; *library-cwd* is a dynamic variable to track the notion of cwd
;; inside of a library.  We bind it to *PHP-FILE* when we first enter
;; include(), and don't unbind it until we're done.  That simulates a
;; chdir to the directory of the script that was invoked.  We can't
;; actually chdir because the script is potentially not in a
;; directory, i.e. it might be in a library.
(define *library-cwd* #f)

(define (do-include file require? once?)
   (fluid-let ((*include-paths*
                (append (unix-path->list  (if (getenv "PCC_INCLUDE")
                                              (getenv "PCC_INCLUDE")
                                              ""))
                        *include-paths*))
               (*library-cwd* (or *library-cwd* *PHP-FILE*)))
      ;; I. look in library
      (let ((lib-inc-name (find-include-file-in-lib file *library-cwd*)))
	 (if lib-inc-name
	     ;
	     ; found in lib
	     ;
	     (begin
		(debug-trace 2 "Include file " lib-inc-name " found in lib.")
		(if (not (and once? (hashtable-get *all-files-ever-included* lib-inc-name)))
		    ;(fprint (current-error-port) "include file found as function: " file)
		    ;(log-message (format "include file found as function: ~a" inc-name))
		    (begin
		       (debug-trace 2 "  Including file " lib-inc-name " from lib.")
		       (hashtable-put! *all-files-ever-included* lib-inc-name #t)
		       (php-funcall lib-inc-name 'unset))
		    ;; oh well...
		    (begin
		       (debug-trace 2 "  Not including file " lib-inc-name " from lib (already included)")
		       FALSE)))
	     ;; II. look on disk
	     (let ((include-file (try (find-include file *PHP-FILE*)
				      (lambda (e p m o)
					 ((if require? php-error php-warning)
					  (format "couldn't find include file ~a (include path was ~a)"
						  file
						  (string-join *include-paths* (string (path-separator)))))
					 (e #f)))))
		(debug-trace 2 "Include file " include-file " NOT found in lib.")
		(if (and include-file
			 (not (and once? (hashtable-get *all-files-ever-included* (include-name include-file)))))
		    ;
		    ; found on disk
		    ;
		    (begin
		       (debug-trace 2 "  Including file " include-file)
		       (hashtable-put! *all-files-ever-included* (include-name include-file) #t)
		       (let ((ret (evaluate-from-file include-file (include-name include-file))))
			  ; XXX note, this is still not semantically correct if the include file exits with "return NULL"
			  (if (null? ret)
			      *one*
			      ret)))
		    ;; oh well...
		    (begin
		       (debug-trace 2 "  Not including file " include-file " (already included)")
		       FALSE)))))))

;; this does steps II-a and II-b
(define (find-include include-file current-file)
   (or
    (let ((cwd (string-append (pwd) (string (pcc-file-separator)))))
       (cond
          ;; absolute paths skip the include path search entirely
          ((and (not (pathname-relative? include-file))
                (file-exists? include-file))
           include-file)
          
          ((or (substring-at? include-file "../" 0)  ; note that this is only paths that start with .., not all relative paths.
               (substring-at? include-file "..\\" 0))
           (debug-trace 2 "Include file starts with ../, so searching only relative to cwd.")
           (find-file/path include-file (list cwd)))
          
          (else
           (or
            ;; II-a
            (let ((include-paths-relative-to-cwd
                   (map (lambda (include-path)
                           (if (pathname-relative? include-path)
                               (merge-pathnames cwd include-path)
                               include-path))
                        *include-paths*)))
               (debug-trace 2 "Looking for " include-file " relative to cwd " cwd ".")
               (find-file/path include-file include-paths-relative-to-cwd))
            ;; II-b
            (let* ((script-directory (string-append (dirname current-file) (string (pcc-file-separator))))
                   (include-paths-relative-to-script
                    (map (lambda (include-path)
                            (if (pathname-relative? include-path)
                                (merge-pathnames script-directory include-path)
                                include-path))
                         *include-paths*)))
               (debug-trace 2 "at this point, php-file is: " current-file)
               (debug-trace 2 "Looking for " include-file " relative to script directory " script-directory ".")
               (find-file/path include-file include-paths-relative-to-script))))))
    (error 'find-include "couldn't find include file" include-file)))


;;; this ought to do steps I-a and I-b, but I toned it down a lot to
;;; make it a little more comprehensible.  We don't search the include
;;; path at all.  We just try the file as it is, and then try it once
;;; merged against the *library-cwd*.
(define (find-include-file-in-lib file cwd)
   (debug-trace 4 "trying to find " file " in library.")
   ;; try the filename just as it is
   (let ((inc-name (include-name file)))
      (if (or (get-user-function-sig inc-name)
              (get-library-include inc-name #f))
          (begin
             (debug-trace 4 "found it, as " inc-name)
             inc-name)
          ;; treat the script dir as cwd and try merging the filename with it
          (let ((merged-inc-name (include-name (merge-pathnames cwd file))))
             (if (or (get-user-function-sig merged-inc-name)
                     (get-library-include merged-inc-name #f))
                 (begin
                    (debug-trace 4 "found it after merging, as " merged-inc-name)
                    merged-inc-name)
                 (begin
                    (debug-trace 4 "couldn't find it.  merged was: " merged-inc-name " (" *PHP-FILE* " and " file ")")
                    (if (zero? (string-length cwd))
                        #f
                        (begin
                           (debug-trace 4 "going around once more with an empty cwd in an attempt "
                                        "to collapse ./ and /../ but not merge the pathname with "
                                        "any directory")
                           (find-include-file-in-lib file "")))))))))

(define (find-include-files ast)
   "resolve as many include references as we can at compile time, and
   return their names to be compiled.  include and require function
   calls are replaced with the actual file function."
   (let ((include-files '()))
      (walk-ast ast
		(lambda (ast k)
		   (when (function-invoke? ast)
		       (with-access::function-invoke ast (location name arglist)
			  (if (or (string=? (string-downcase (mkstr name)) "require")					      
				  (string=? (string-downcase (mkstr name)) "require_once")
				  (string=? (string-downcase (mkstr name)) "include")				  
				  (string=? (string-downcase (mkstr name)) "include_once"))
			      ;we want
			      (if (and (> (length arglist) 0)
				       (literal-string? (car arglist)))
				  (with-access::literal-string (car arglist) (value)
				     ; don't include it if it's already in a loaded library
				     (unless (find-include-file-in-lib value *PHP-FILE*)
					(let ((include-file
					       (try (find-include value (loc-file location))
						    (lambda (e p m o)
						       (debug-trace 1 (format "warning: couldn't find include file: ~a, will resolve at runtime" value))
						       (e #f)))))
					   (when include-file
					      (when (not (hashtable-get *all-files-ever-included* (include-name include-file)))
						 (hashtable-put! *all-files-ever-included* (include-name include-file) #t)
						 (pushf include-file include-files))
					      ;change the function-invoke to call the include itself
					      ;					   (set! name (include-name include-file))
					      ))))
				  ; here they most likely did include($someDir.'file.php')
				  (debug-trace 1 (format "warning: can't search for non-literal include file at ~A, will resolve at runtime" (ast-node-location (car arglist))))))))
		   (k)))
      (map util-realpath include-files)))



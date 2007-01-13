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

; parse configuration files and environment variables
(module config
   (include "../runtime/php-runtime.sch")
   (library php-runtime)
   (import (target "target.scm"))
   (export
    (read-config-file)
    (setup-library-paths)
    MINGW-ROOT-DIR
    PCC-HOME
    BIGLOO
    LD
    AR
    *web-libs*
    *config-file*
    ;; commands
    WINDRES)
   (extern 
    ;read registry entries from hkey_local_machine 
    (get-hklm-string::obj (key::string value-name::string) 
			  "get_hklm_string"))   )

(define *web-libs* '("php-std"))

; home
(define PCC-HOME (or (getenv "PCC_HOME")
		     (get-pcc-home-from-registry)
		     "/opt/roadsend/pcc/"
		     ))

;; on mingw, / isn't really /...
(define MINGW-ROOT-DIR (or (get-pcc-home-from-registry) 
                           "C:/msys/1.0/"))


(define *config-file-read* #f)


(define *config-file*
   (cond-expand
      (PCC_MINGW
       (or (get-pcc-conf-from-registry)
	   ;;the env var is no good for dos, services, etc.
	   ;;(getenv "PCC_CONF") 
	   "c:/msys/1.0/etc/pcc.conf"))
      (else
       (or (getenv "PCC_CONF")
	   "/etc/pcc.conf"))))

(define (setup-library-paths)
   ;; Add home/libs to dynamic-load-path by default.  Also add current
   ;; directory, which is important especially for microservers and
   ;; fastcgi stubs.
   (set! *dynamic-load-path* (cons* PCC-HOME
				    "./"
				    (append-paths PCC-HOME "/libs")
				    *dynamic-load-path*))
   ;; scheme include files, heap files
   (when *current-target*
      (map (lambda (p)
	      (add-target-option! scheme-include-paths: p))
	   (append (list PCC-HOME
			 (append-paths PCC-HOME "/libs"))
		   (or (target-option library-paths:) '())
		   (unix-path->list (or (getenv "LD_LIBRARY_PATH") ""))))))

; (set! RUNTIME-INC 
; 	    (append RUNTIME-INC 
; 		    (map (lambda (p)
; 			    (string-append 
; 			     "-L " (escape-path (append-paths PCC-HOME p))))
; 			 '("/local/include/gtk" 
; 			   "/local/include" 
; 			   "/local/lib/gtk+/include" 
; 			   "/local/include/glib-2.0" 
; 			   "/local/lib/glib-2.0/include"))))
; ;)
   
;    ; scheme libraries
;    (set! RUNTIME-LIB-INC (cons (string-append "-L " (escape-path PCC-HOME))
; 				 (cons (string-append "-L " (escape-path (append-paths PCC-HOME "/libs")))
; 				       (map (lambda (p) (string-append "-L " (escape-path p)))
; 					    (append 
; 					     ;*user-library-path*
;                                              (target-option library-paths:)
; 					     (unix-path->list (or (getenv "LD_LIBRARY_PATH") ""))))))))

; (define (setup-library-paths)
;    ;add home/libs to dynamic-load-path by default
;    (set! *dynamic-load-path* (cons PCC-HOME
; 				   (cons (append-paths PCC-HOME "/libs")
; 					 *dynamic-load-path*)))

;    ; scheme include files, heap files
;    (set! RUNTIME-INC (cons (string-append "-I " (escape-path PCC-HOME)
; 					 " -I " (escape-path (append-paths PCC-HOME "/libs")))
; 			   (map (lambda (p) (string-append "-I " (escape-path p)))
; 				(append 
; 				 ;*user-library-path*
;                                  (target-option library-paths:)
; 				 (unix-path->list (or (getenv "LD_LIBRARY_PATH") ""))))))

;    ;this is a no-no
; ;			     (append-paths "-I " PCC-HOME "/runtime")))

;    ;;this is a no-no
;    ;;for gtk:
; ;   (when (member "php-gtk" *cl-libs*)
;       (set! RUNTIME-INC 
; 	    (append RUNTIME-INC 
; 		    (map (lambda (p)
; 			    (string-append 
; 			     "-L " (escape-path (append-paths PCC-HOME p))))
; 			 '("/local/include/gtk" 
; 			   "/local/include" 
; 			   "/local/lib/gtk+/include" 
; 			   "/local/include/glib-2.0" 
; 			   "/local/lib/glib-2.0/include"))))
; ;)
   
;    ; scheme libraries
;    (set! RUNTIME-LIB-INC (cons (string-append "-L " (escape-path PCC-HOME))
; 				 (cons (string-append "-L " (escape-path (append-paths PCC-HOME "/libs")))
; 				       (map (lambda (p) (string-append "-L " (escape-path p)))
; 					    (append 
; 					     ;*user-library-path*
;                                              (target-option library-paths:)
; 					     (unix-path->list (or (getenv "LD_LIBRARY_PATH") ""))))))))







; binary
(define BIGLOO (or (getenv "BIGLOO")
		   "bigloo"))

(define LD (or (getenv "LD")
	       "gcc"))

(define AR (or (getenv "AR")
	       "ar"))

(define WINDRES (or (getenv "WINDRES")
		    "windres"))


; (define RUNTIME-INC 'call-setup-library-paths!)
; (define RUNTIME-LIB-INC 'call-setup-library-paths!)


; library cleaning
(define *clean-build?* #f)
(define *install-mode?* #f) 

; for gcc switches
(define *res-file* #f)

;; XXX fix me, make it so it makes sense to call this on every page load from run-url
(define (read-config-file)
   (unless *config-file-read*
      (set! *config-file-read* #t)
      (let ((directive-error
	     (lambda (directive)
		(php-error (format "~a: Malformed configuration directive: ~A" *config-file* directive))))
	    (not-a-dir
	     (lambda (dir)
		(php-warning (format "~a: Specified directory does not exist: ~A" *config-file* dir)))))
	 (if (not (file-exists? *config-file*))
	     (debug-trace 1 "Config file " *config-file* " not found.")
	     (with-input-from-file *config-file*
		(lambda ()
		   (let loop ((directive (read)))
		      ;(debug-trace 1 (format "config: ~a" directive))
		      (unless (eof-object? directive)
			 (if (not (and (pair? directive) (> (length directive) 1)))
			     (directive-error directive)
			     (let ((name (car directive))
				   (value (cdr directive)))
				(case name
				   ((home) (let ((dir (mkstr (car value))))
					      (unless (directory? dir)
						 (not-a-dir dir))
					      ;the environment variable dominates pcc.conf
					      (unless (getenv "PCC_HOME")
						 (set! PCC-HOME dir)
						 (debug-trace 3 "set pcc-home to " dir)
						 (pushf PCC-HOME *dynamic-load-path*)
						 ;this is for mod_pcc.  it's superfluous for the commandline.
						 (when (directory? (append-paths dir "/include"))
						    (pushf (append-paths dir "/include") *include-paths*))
						 (when (directory? (append-paths dir "/libs"))
						    (pushf (append-paths dir "/libs") *dynamic-load-path*)))))
				   ((include) (for-each (lambda (dir)
							   (set! dir (mkstr dir))
							   ;							  (if (directory? dir)
							   (pushf dir *include-paths*)
							   ;      (not-a-dir dir))
							   )
							value))
				   ((library) (for-each (lambda (dir)
							   (set! dir (mkstr dir))
							   (if (directory? dir)
							       (begin
								  (pushf dir *dynamic-load-path*)
								  ; (pushf dir *user-library-path*)
                                                                  (add-target-option! library-paths: dir)
                                                                  )
							       (not-a-dir dir)))
							value))
				   ((debug-level) (when (and (number? (car value))
							     ;only change the debug-level if it wasn't already set
							     ;this prevents us from overriding the commandline
							     (= *debug-level* 0))
						     (set! *debug-level* 
							   (if *RAVEN-DEVEL-BUILD*
							       (mkfixnum (car value))
							       (min (mkfixnum (car value)) 2)))))
				   ; deprecated, backward compatible
				   ((use) (for-each (lambda (libval)
						       (if (pair? libval)
							   (pushf (car libval) *web-libs*)
							   (pushf libval *web-libs*)))
						    value))
				   ; this replaces use
				   ((web-libs) (for-each (lambda (libval)
							    (pushf libval *web-libs*))
							 value))
				   ; use optimized web libs?
				   ((optimize-web-libs) 'deprecated)
				   ((default-commandline-lib) (for-each (lambda (libval)
									  (add-target-option! default-libs: libval))
                                                                        ;; we reverse them here, then they're reversed again because add-target-option!
                                                                        ;; adds then to the front of the list, so they end up in the same order as in
                                                                        ;; the config file.
									(map mkstr (reverse value))))
				   ((ini) (for-each (lambda (ini-entry)
						       (unless (and (list? ini-entry)
								    (= (length ini-entry) 2))
							  (directive-error value))
						       (debug-trace 6 (format "setting ini directive ~a to ~a"
									      (car ini-entry)
									      (cadr ini-entry)))
						       (config-ini-entry (car ini-entry)
									 (cadr ini-entry)))
						    value))
				   ((default-compile-ext) (set-target-option! compile-extensions: value))
				   (else (directive-error directive)))))
			 (loop (read)))))))
	 ; set include_path ini entry
	 (set-ini-entry "include_path" (string-join *include-paths* (string (path-separator)))))))


(awhen (getenv "PATH")
   (for-each (lambda (p) (pushf p *dynamic-load-path*))
             (unix-path->list it)))


;(print "dynamic load path is now: " *dynamic-load-path*)



(define (get-pcc-home-from-registry)
   (let ((retval 
	  (let ((root (get-hklm-string 
		       (mkstr "SOFTWARE\\Roadsend\\Compiler\\"
			      *RAVEN-VERSION-MAJOR* "."
			      *RAVEN-VERSION-MINOR*)
		       "root")))
	     (and root
		  (pregexp-replace* "\\\\"
				    root
				    "/" )))))
;      (print "the pcc-home found in the registry was: " retval)
      retval))

(define (get-pcc-conf-from-registry)
   (let ((retval 
	  (let ((root (get-hklm-string 
		       (mkstr "SOFTWARE\\Roadsend\\Compiler\\"
			      *RAVEN-VERSION-MAJOR* "."
			      *RAVEN-VERSION-MINOR*)
		       "root")))
	     (and root
		  (pregexp-replace* "\\\\"
				    (append-paths root "/etc/pcc.conf")
				    "/" )))))
;      (print "the pcc-conf found in the registry was: " retval)
      retval))


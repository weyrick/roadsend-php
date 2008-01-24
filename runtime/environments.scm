;; ***** BEGIN LICENSE BLOCK *****
;; Roadsend PHP Compiler Runtime Libraries
;; Copyright (C) 2007 Roadsend, Inc.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public License
;; as published by the Free Software Foundation; either version 2.1
;; of the License, or (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Lesser General Public License for more details.
;; 
;; You should have received a copy of the GNU Lesser General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
;; ***** END LICENSE BLOCK *****
(module environments
   (include "php-runtime.sch")
   (import
    (utils "utils.scm")
    (php-hash "php-hash.scm")
    (rt-containers "containers.scm")    
    (php-errors "php-errors.scm"))
   (export
    *superglobals*
    *global-env*
    *current-variable-environment*
    (superglobal? key)
    (env-php-hash-view env)
    (env-new)
    (env-import env source-hash prefix::bstring)
    (env-extend env name::bstring value)
    (env-lookup env name::bstring)
    (env-lookup-internal-index env name::bstring)
    (inline env-internal-index-value index)
    (inline env-internal-index-value-set! index value)    
    (var-lookup env name)
    (var-store env name value)))

;;;; environment
;the global environment
(define *global-env* 'unset)

;the variable environment of the currently executing function, if it
;has one.  if your function uses this, please add your function to
;*builtins-requiring-variable-env* in ../compiler/declare.scm
(define *current-variable-environment* 'unset)

;a table of all the variables considered superglobal, that is,
;implicitly declared global in every function
(define *superglobals* 'unset)

(define (superglobal? key)
   (let ((name (undollar key)))
      (hashtable-get *superglobals* name)))

(define (env-new)
   (let ((env (make-env))
	 (bindings (make-php-hash)))
      (env-bindings-set! env bindings)
      (hashtable-for-each *superglobals*
	 (lambda (k v)
	    (php-hash-insert! bindings k (env-lookup *global-env* k))))
      env))

; import values from a php hash into the specified environment
; see extract and import_request_variables in php-variables
(define (env-import env source-hash prefix::bstring)
   (debug-trace 2 "env-import: importing with prefix: " prefix)
   (let ((source (maybe-unbox source-hash)))
      (if (php-hash? source)
	  (php-hash-for-each source
	     (lambda (k v)
		(debug-trace 2 "env-import: importing: " k)
		(let ((sname (string-append prefix k)))
		   (if (pregexp-match "^[a-zA-Z_]\\w*" sname)
		       (env-extend env sname v)
		       (php-warning "env-import: can't import symbol: " k)))))
	  (debug-trace 2 "env-import: Not a hashtable: " source-hash))))

(define (env-extend env name::bstring value)
   ;   (let ((name (symbol->string name)))
;   (let ((env (if (hashtable-get *superglobals* name) *global-env* env)))
      ;      (set! name (substring name 1 (string-length name)))
      ;       (when (and (string= name "SM_siteManager")
      ; 		 (eqv? env *global-env*))
      ; 	 (fprint (current-error-port)
      ; 		 (with-output-to-string
      ; 		    (lambda ()
      ; 		       (print-stack-trace))))
      ; 	 (fprint (current-error-port) "Env-extend name " name " value " (mkstr value)
      ; 		 " file: " *PHP-FILE* " line: " *PHP-LINE*))
;       (fprint (current-error-port)
; 	   "storing up: " name)
      (php-hash-insert! (env-bindings env) name value))

(define (env-php-hash-view env)
   "return a view of an env as a php-hash"
   (let ((new-hash (make-php-hash)))
      (php-hash-for-each (env-bindings env)
	 (lambda (k v)
	    (php-hash-insert! new-hash k v)))
      new-hash))

(define (env-lookup env name::bstring)
   (php-hash-lookup-location (env-bindings env) #t name))

(define (env-lookup-internal-index env name::bstring)
   (let ((bindings (env-bindings env)))
      (or (php-hash-lookup-internal-index bindings name)
	  (begin
	     ;create it if it doesn't exist
	     (php-hash-lookup-location bindings #t name)
	     (php-hash-lookup-internal-index bindings name)))))

;; merely inlining these two makes a 14% improvement in the
;; globals1.php benchmark.
(define-inline (env-internal-index-value index)
   (php-hash-internal-index-value index))

(define-inline (env-internal-index-value-set! index value)
   (php-hash-internal-index-value-set! index value))

(define (var-lookup env name)
   (env-lookup env name))
; 	       (string->symbol
; 		(mkstr "$"  name))))
;      (if var
;	  var
;	  #f)))

(define (var-store env name value)
   (env-extend env ;(string->symbol (mkstr "$" name))
	       name value))

    
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
(module php-runtime
   (include "php-runtime.sch")
   ; for pcc scheme repl
   (eval (export-module))   
   (import (utils "utils.scm")
	   (php-hash "php-hash.scm")
	   (php-object "php-object.scm")
	   (signatures "signatures.scm")
           (php-errors "php-errors.scm")
	   (builtin-classes "builtin-classes.scm")
	   (output-buffering "output-buffering.scm")
           (php-ini "php-ini.scm"))
   ; from bindings are reexported
   (from (blib "blib.scm")
	 (extended-streams "extended-streams.scm")
	 (web-var-cache "web-var-cache.scm")
	 (constants "constants.scm")
	 (finalizers "finalizers.scm")
	 (php-resources "resources.scm")
	 (php-types "php-types.scm")
	 (php-operators "php-operators.scm")
	 (php-functions "php-functions.scm")
	 (rt-containers "containers.scm")
	 (environments "environments.scm"))
   (load (php-macros "../php-macros.scm"))
   
   (export
    ; vars
    SID
    DIRECTORY_SEPARATOR
    $argv
    $argc
    *RAVEN-DEVEL-BUILD*
    *RAVEN-VERSION-TAG*
    *RAVEN-VERSION-STRING*
    *RAVEN-VERSION-MAJOR*
    *RAVEN-VERSION-MINOR*
    *RAVEN-VERSION-RELEASE*
    *ZEND-VERSION*
    *ZEND2-VERSION*
    *user-libs*
    *commandline?*
    ;; init/reset
    *runtime-reset-serial*
    (init-php-runtime)
    (init-php-argv argv)
    (reset-runtime-state)
    (add-end-page-reset-func f)
    %runtime-library-version
    (check-runtime-library-version version)
    ;; startup/shutdown
    *shutdown-functions*
    (add-startup-function func)
    (add-startup-function-for-extension ext func)
    (run-startup-functions)
    (run-startup-functions-for-extension ext)
    (run-php-shutdown-funcs exit-stat)    
    ;; the extension info
    (extension-registered? extension)
    (register-extension extension version scheme-lib-name #!key (required-extensions '()))
    (get-extension-info extension key)
    (extensions-for-each thunk)
    ;; includes
    *all-files-ever-included*
    *orig-include-paths*
    *temp-include-paths*
    *include-paths*
    (set-include-paths! path-list)
    (set-temp-include-paths! path-list)

    ; cross platform
    (mingw-missing func)
    
    ))

;;
;; some global defines
;;

; this should be true for devlopment, false for a release build
(define *RAVEN-DEVEL-BUILD* (cond-expand
			       (unsafe #f)
			       (else #t)))

(define *RAVEN-VERSION-MAJOR* 2)
(define *RAVEN-VERSION-MINOR* 9)
(define *RAVEN-VERSION-RELEASE* 5)
(define *RAVEN-VERSION-STRING* (format "~a.~a.~a~a"
				       *RAVEN-VERSION-MAJOR*
				       *RAVEN-VERSION-MINOR*
				       *RAVEN-VERSION-RELEASE*
				       (cond-expand
					  (unsafe "")
					  (else " (debug/safe)"))
				       ))
(define *RAVEN-NAME* "Roadsend PHP")
(define *RAVEN-VERSION-TAG* (string-append *RAVEN-NAME*
					   "/"
					   *RAVEN-VERSION-STRING*))

(define *PHP5-VERSION* "5.2.5") 
(define *PHP-VERSION* *PHP5-VERSION*)
(define *ZEND2-VERSION* "2.2.0")
(define *ZEND-VERSION* *ZEND2-VERSION*)

;this version number gets put into compiled programs and libraries.
;Whenever non-backwards compatible changes are made to the runtime,
;increment this, so that nobody will be able to use programs
;compiled against the newer runtime on a system that only has the
;older runtime.
(define %runtime-library-version 2.9)
(define (check-runtime-library-version version)
   (if (> version %runtime-library-version)
       (php-error "Installed PCC runtime version "		  
		  %runtime-library-version
		  " is too old.  Version " version " required.")
       #t))

; list of functions to run before program execution
(define *startup-functions* (make-hashtable))

; for adding startup functions to the standard extension implicitly
(define (add-startup-function func)
   (add-startup-function-for-extension "std" func))
      
; for adding startup functions to an extension explicitly
(define (add-startup-function-for-extension ext func)
   (let* ((ext (string-downcase (mkstr ext)))
	  (current (hashtable-get *startup-functions* ext)))
      (hashtable-put! *startup-functions* ext (if current
						  (cons func current)
						  (list func)))))

; these get before each top level execution (in driver/commandline)
(define (run-startup-functions)
   (hashtable-for-each *startup-functions*
		       (lambda (ext funcs)
			  (debug-trace 3 "running startup functions for extension: " ext)
			  (for-each (lambda (f)
				       (f))
				    (reverse funcs)))))

; to be used for runtime loading of extensions
(define (run-startup-functions-for-extension ext)
   (debug-trace 3 "running startup functions for extension: " ext)
   (let* ((ext (string-downcase (mkstr ext)))
	  (funcs (hashtable-get *startup-functions* ext)))
      (when funcs
	 (for-each (lambda (f)
		      (f))
		   (reverse funcs)))))
   
; list of builtin functions to run at end of page view
; these should reset state in one way or another
(define *end-page-reset-functions* '())

(define (add-end-page-reset-func f)
   (set! *end-page-reset-functions* (cons f *end-page-reset-functions*)))

; list of php user functions to run at shutdown
(define *shutdown-functions* '())

(define (run-php-shutdown-funcs exit-stat)
   (for-each (lambda (a)
		(php-callback-call a))
	    (reverse *shutdown-functions*))
   exit-stat)
		
(register-exit-function! run-php-shutdown-funcs)

; every time we reset the runtime state for a page view, we increase the serial
(define *runtime-reset-serial* 0)

;; information about the extensions loaded
(define *extension-info* '())

(define (extension-registered? extension)
   (let ((v (assoc extension *extension-info*)))
      (if v
          (debug-trace 4 "Extension " extension " is registered")
          (debug-trace 4 "Extension " extension " is NOT registered"))
      v))

; make this include version?
(define (register-extension extension version scheme-lib-name #!key (required-extensions '()))
   ;; Store some information about an extension so that it can be
   ;; looked up later using get-extension-info and for-each-extension.
   ;; The required-extensions are other extensions that must be loaded
   ;; in order to load this extension.
   ;;
   ;; XXX it's kind of unfortunate that we have N extensions per
   ;; scheme library.  Confusing.
   (debug-trace 4 "Registering extension " extension)
   (when (assoc extension *extension-info*)
      (error 'register-extension "extension already registered" extension))
   (pushf `(,extension (version: ,version)
                       (scheme-lib-name: ,scheme-lib-name)
                       (required-extensions: ,required-extensions))
          *extension-info*))

(define (get-extension-info extension key)
   ;; look up a bit of information about an extension
   (let ((info (cond ((assoc extension *extension-info*) => cdr)
                     (else (error 'get-extension-info
                                  (mkstr "extension " extension " has not been registered")
                                  (cons extension *extension-info*))))))
      (cond ((assoc key info) => cadr)
            (else (error 'get-extension-info
                         "no such key"
                         (cons key *extension-info*))))))

(define (extensions-for-each thunk)
   ;; call thunk once on the name of each extension
   (for-each thunk (map car *extension-info*)))

;are we running on the commandline?
(define *commandline?* #t)

; php libraries loaded
(define *user-libs* '())

; the search list for include files, current page view
(define *include-paths* '("./"))

; a list of paths to add to this page view's include path list
; this needs its own list since apache.scm runs early enough
; where if we added it to *include-paths* when .htaccess was read,
; it was hang around in base-include-paths for subsequent page views
(define *temp-include-paths* '())

; set once at load (*after* config file read, command line but *before* .htaccess)
; so we can reset between page views
(define *orig-include-paths* '())

; we need this because init-php-runtime gets
; called more than once, and we don't want to squash anything
(define *runtime-uninitialized?* #t)

; standard constants
(defconstant ROADSEND_PHPC *one*)
(defconstant ROADSEND_PHP *one*)
(defconstant ROADSEND_PCC *one*)
(defconstant PHP_OS (cond-expand
		       (PCC_MINGW "WINNT")
		       (else (os-name))))
(defconstant PHP_VERSION *PHP-VERSION*)
(defconstant PCC_VERSION_MAJOR *RAVEN-VERSION-MAJOR*)
(defconstant PCC_VERSION_MINOR *RAVEN-VERSION-MINOR*)
(defconstant PCC_VERSION_RELEASE *RAVEN-VERSION-MAJOR*)
(defconstant PCC_VERSION *RAVEN-VERSION-STRING*)
(defconstant RAVEN_VERSION *RAVEN-VERSION-STRING*)
(defconstant PCC_VERSION_TAG *RAVEN-VERSION-TAG*)
(defconstant RAVEN_VERSION_TAG *RAVEN-VERSION-TAG*)
(defconstant PHP_INT_MAX (convert-to-integer *MAX-INT-SIZE-L*))
(defconstant PHP_INT_SIZE (convert-to-integer *SIZEOF-LONG*))
(defconstant PATH_SEPARATOR (path-separator))
(defconstant DIRECTORY_SEPARATOR (pcc-file-separator))
; XXX do a better job of this. also see php_sapi_name in php-core.scm in ext/standard
(store-special-constant "PHP_SAPI" (lambda() (if *commandline?*
						 "cli"
						 "apache")))

; session ID
(defconstant SID "")

; this function is run after a page view
; it should reset any toplevel variable to it's top level state
(define (reset-runtime-state)

   ; increase serial
   (set! *runtime-reset-serial* (+fx 1 *runtime-reset-serial*))
   
   ; run reset functions from other parts of the code
   ; NOTE we run this *first* so it has access to variables like SESSION
   ; and REQUEST
   (for-each (lambda (f)
		(f))
	     *end-page-reset-functions*)

   ; common reset
   (common-reset)

   )
  

; run at both initialize (per runtime load) and reset (per page)
(define (common-reset)

   ; environments
   (reset-superglobals!)
   (set! *current-variable-environment* *global-env*)

   (set! *delayed-errors* '())
   (set! *shutdown-functions* '())
   (set! *function-table* (make-hashtable))
   (set! *interpreted-function-table* (make-hashtable))

   ; output buffering
   (ob-reset!)
   ; various parts of the runtime
   (reset-constants!)
   (reset-signatures!)
   (reset-php-object-lib!)
   (reset-ini!)   
   (reset-errors!)
   
   (set! *PHP-LINE* 0)
   (set! *PHP-FILE* "unknown")

   )
   

; called only once per runtime load
(define (init-php-runtime)

   (when *runtime-uninitialized?*

      ; possibly turn on url rewriting
      (add-startup-function maybe-init-url-rewriter)
      
      ; error handling
      (init-php-error-lib)

      ; object system
      (init-php-object-lib)
      (init-builtin-classes)      

      ; initial superglobal def
      (init-superglobals)
            
      ; base reset
      (common-reset)

      ; if we have a date.timezone, set TZ
      (if (get-ini-entry "date.timezone")
	  (putenv "TZ" (mkstr (get-ini-entry "date.timezone"))))
      
      ; setup _ENV variable
      ; we don't change per runtime load. fastcgi parses environ each request
      ; into _SERVER instead
      (when *commandline?*
	 (init-env-superglobal))
      
      ; all better
      (set! *runtime-uninitialized?* #f)

      )
   
   )

(define $argv 'unset)
(define $argc 'unset)
;
; note this is called in generated stubs, not on reset
;
(define (init-php-argv argv)   
   (set! $argv (make-container (list->php-hash argv)))
   (env-extend *global-env* "argv" $argv)
   (set! $argc (make-container (convert-to-integer (length argv))))
   (env-extend *global-env* "argc" $argc)
   ; when in command line, add argv, argc
   (when *commandline?*
      ; copy variables from env as per php
      (for-each (lambda (a)
		   (php-hash-insert! (container-value $_SERVER) (car a) (cdr a)))
		(environ))
      (unless (null? argv)
	 (php-hash-insert! (container-value $_SERVER) "PHP_SELF" (car argv))
	 (php-hash-insert! (container-value $_SERVER) "SCRIPT_NAME" (car argv))
	 (php-hash-insert! (container-value $_SERVER) "SCRIPT_FILENAME" (car argv))
	 (php-hash-insert! (container-value $_SERVER) "PATH_TRANSLATED" (car argv))
	 (php-hash-insert! (container-value $_SERVER) "DOCUMENT_ROOT" "")
	 (php-hash-insert! (container-value $_SERVER) "argv" (container-value $argv))
	 (php-hash-insert! (container-value $_SERVER) "argc" (container-value $argc)))))


;; include files
; all include files actually included, per page load
(define *all-files-ever-included* (make-hashtable))

(define (set-include-paths! path-list)
   (when (list? path-list)
      (set! *include-paths* path-list)))

; note used in webconnect/apache for .htaccess
; call when include paths should be set for this page view only
(define (set-temp-include-paths! path-list)
    (when (list? path-list)
       (set! *temp-include-paths* path-list)))


;;;

; notify user that some functionality is missing, return #f
(define (mingw-missing func)
   (php-warning (mkstr "the function: '" func "' is not supported on this platform")))

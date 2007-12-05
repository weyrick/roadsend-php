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
	   (elong-lib "elongs.scm")
	   (grass "grasstable.scm")
	   (url-rewriter "url-rewriter.scm")
	   (signatures "signatures.scm")
	   (fast-string-append "fast-string-append.scm")
           (php-errors "php-errors.scm")
           (php-ini "php-ini.scm"))
   (from (blib "blib.scm"))
   (from (opaque-math "opaque-math-binding.scm"))
   (from (extended-streams "extended-streams.scm"))
   (from (slib "slib/slib.scm"))
   (from (constants "constants.scm"))
   (from (finalizers "finalizers.scm"))
   (from (php-resources "resources.scm"))
   (load (php-macros "../php-macros.scm"))
   
   (extern
    (include "math.h")
    (c-binary-strcmp::int (::string ::int ::string ::int) "binary_strcmp")
    (macro isfinite::bool (::float) "isfinite")
    (macro isnan::bool (::float) "isnan")
    (export *debug-level* "pcc_debug_level"))
   (export
    (init-php-runtime)
    (valid-php-type? value)
    FALSE
    TRUE
    NULL
    $_ENV
    $HTTP_ENV_VARS
    $_SERVER
    $HTTP_SERVER_VARS
    $HTTP_GET_VARS
    $_GET
    $HTTP_POST_VARS
    $_POST
    $HTTP_COOKIE_VARS
    $_COOKIE
    $_REQUEST
    $HTTP_SESSION_VARS
    $_SESSION
    $_FILES
    SID
    DIRECTORY_SEPARATOR
    $argv
    $argc
    *debug-level*
    *RAVEN-DEVEL-BUILD*
    *RAVEN-VERSION-TAG*
    *RAVEN-VERSION-STRING*
    *RAVEN-VERSION-MAJOR*
    *RAVEN-VERSION-MINOR*
    *RAVEN-VERSION-RELEASE*
    *ZEND-VERSION*
    *ZEND2-VERSION*
    *user-libs*
    (add-end-page-reset-func f)
    (reset-runtime-state)
    *commandline?*
    (php-null? a)
    (php-resource? a)
    *shutdown-functions*
    (add-startup-function func)
    (add-startup-function-for-extension ext func)
    (run-startup-functions)
    (run-startup-functions-for-extension ext)
    *global-env*
    *current-variable-environment*
    *superglobals*
    ;; the extension info
    (extension-registered? extension)
    (register-extension extension version scheme-lib-name lib-list #!key (required-extensions '()))
    (get-extension-info extension key)
    (extensions-for-each thunk)
    
    (mkstr::bstring a . args)
    ; these are for converting to php types
    (convert-to-boolean::bool rval)
    (convert-to-string::bstring rval)
    (convert-to-integer::onum rval)
    (convert-to-float rval)
    (convert-to-number::onum rval)
    (php-number? rval)
    ; these are for converting to functions for bigloo procedures
    (mkfixnum::int rval)
    (mkfix-or-flonum rval)
    ;
    (echo arg)
    (env-php-hash-view env)
    (php-%::onum a b)

    (debug-trace level . rest)
    
    (inline php-%/num::onum a::onum b::onum)
    (inline php-//num::onum a::onum b::onum)
    (inline php-*-/num::onum a::onum b::onum)
    (inline php--/num::onum a::onum b::onum)
    (inline php-+/num::onum a::onum b::onum)
    (inline less-than-or-equal-p/num a::onum b::onum)
    (inline less-than-p/num a::onum b::onum)
    (inline greater-than-or-equal-p/num a::onum b::onum)
    (inline greater-than-p/num a::onum b::onum)
    (inline equalp/num a::onum b::onum)
    (%general-lookup obj key)
    (%general-lookup/pre obj key pre)
    (%general-lookup-honestly-just-for-reading obj key)
    (%general-lookup-honestly-just-for-reading/pre obj key pre)
    (%general-lookup-ref obj key)
    (%coerce-for-insert obj)
    (%general-insert! obj key val)
    (%general-insert!/pre obj key pre val)
    (%general-insert-n! obj keys precalculated-hashnumbers val)
    (equalp a b)
    (logical-not a)
    (identicalp a b)
    (not-equal-p a b)
    (not-identical-p a b)
    (less-than-p a b)
    (greater-than-p a b)
    (less-than-or-equal-p a b)
    (greater-than-or-equal-p a b)
    (init-php-argv argv)
    (env-new)
    (env-import env source-hash prefix::string)
    (env-extend env name::bstring value)
    (env-lookup env name::bstring)
    (env-lookup-internal-index env name::bstring)
    (inline env-internal-index-value index)
    (inline env-internal-index-value-set! index value)
    
    (--::onum a)
    (inline --/num::onum a::onum)
    (++ a)
    (inline ++/num::onum a::onum)
    *zero*
    *one*
    (compare-as-strings a b)
    (compare-as-numbers a b)
    (compare-as-boolean a b) 
    (php-var-compare a b)
    (php-+ a b) ; may return an array
    (php--::onum a b)
    (php-*::onum a b)
    (php-/::onum a b)
    (php-< a b)
    (php-> a b)
    (php-<= a b)
    (php->= a b)
    (php-= a b)
    (var-lookup env name)
    *function-table*
    *interpreted-function-table*
    (hashtable-copy hash)
    (var-store env name value)
    (inline maybe-unbox thupet)
    (inline maybe-box thupet)
    (php-string-set! str char val)
    (php-string-ref str char)
    (php-funcall call-name . call-args)
    (php-callback-call callback . arglist)
    (php-get-funcall-handle call-name call-arity)
    (php-funcall/handle handle::struct call-args)
    (copy-php-data data)
    (bitwise-or a b)
    (bitwise-xor a b)
    (bitwise-and a b)
    (bitwise-not a)
    (bitwise-shift-left a b)
    (bitwise-shift-right a b)

    ; output buffering
    PHP_OUTPUT_HANDLER_START 
    PHP_OUTPUT_HANDLER_CONT 
    PHP_OUTPUT_HANDLER_END
    *output-buffer-implicit-flush?*
    *output-buffer-stack*
    *output-callback-stack*
    *output-rewrite-vars*
    (ob-start callback)
    (ob-pop-stacks)
    (ob-verify-stacks)
    (ob-flush-to-next from to callback)
    (ob-flush)
    (ob-flush-all)
    (ob-rewrite-urls output)

    *all-files-ever-included*
    *orig-include-paths*
    *temp-include-paths*
    *include-paths*
    (set-include-paths! path-list)
    (set-temp-include-paths! path-list)
    
    (float-is-finite? a)
    (float-is-nan? a)

    (inline make-container::pair value)
    (inline container->reference!::pair value)
    (inline container-reference? value)
    (inline container-value container::pair)
    (inline container? container)
    (inline container-value-set! container::pair value)

    (run-php-shutdown-funcs exit-stat)    
    (coerce-to-php-type orig)

    ; cross platform
    (mingw-missing func)
    
    ;for version checks
    %runtime-library-version
    (check-runtime-library-version version)

    ;; variable arity user functions
    *func-args-stack*
    (push-func-args list-of-arguments)
    (pop-func-args)

    ;; php-compat compat
    zval->phpval-coercion-routine
    PHP5?
;    (require-php5)
;    (go-php5)
    ) )

(define PHP5? #t)

;(define (go-php5)
;   (set! PHP5? #t)
;   (defconstant PHP_VERSION *PHP5-VERSION*))

;(define (require-php5)
;   (unless PHP5?
;      (php-error "This feature requires PHP5 compatibility to be enabled (in Project Properties, or -5 on the commandline)")))

;; it can be confusing that actually quite a bit of code gets executed
;; before commandline.scm or driver.scm has setup the *debug-level*.
;; We could set this to e.g. 'too-early, to make such bugs more
;; obvious, but that breaks a lot of code that calls debug-trace both
;; too-early and late enough.  Hmm.. what to do?
(define *debug-level* 0)


(define (debug-trace level . rest)
   "print REST when *DEBUG-LEVEL* is >= LEVEL"
   (let ((prefix (string-append ">>> " (make-string level #\space))))
      (when (>= *debug-level* level)
         (display prefix (current-error-port))
         (for-each
          (lambda (a)
             (cond
                ((php-object? (maybe-unbox a))
                 (fprint (current-error-port)
                         (with-output-to-string
                            (lambda ()
                               (when (container? a) (display "("))
                               (pretty-print-php-object (maybe-unbox a))
                               (when (container? a)
                                  (display " . ")
                                  (display (cdr a))
                                  (display ")"))))))
                (else (display-circle a (current-error-port)))))
          rest)
         (newline (current-error-port))))
   ;; we return false so that adding a debug-trace to the end of a
   ;; builtin won't cause an #unspecified to make its way up to PHP
   ;; user code.
   #f)

;;
;; some global defines
;;

; this should be true for devlopment, false for a release build
(define *RAVEN-DEVEL-BUILD* (cond-expand
			       (unsafe #f)
			       (else #t)))

(define *RAVEN-VERSION-MAJOR* 2)
(define *RAVEN-VERSION-MINOR* 9)
(define *RAVEN-VERSION-RELEASE* 3)
(define *RAVEN-VERSION-STRING* (format "~a.~a.~a~a"
				       *RAVEN-VERSION-MAJOR*
				       *RAVEN-VERSION-MINOR*
				       *RAVEN-VERSION-RELEASE*
				       (if *RAVEN-DEVEL-BUILD*
					   "_debug"
					   "")
				       ))
(define *RAVEN-NAME* "Roadsend PHP")
(define *RAVEN-VERSION-TAG* (string-append *RAVEN-NAME*
					   "/"
					   *RAVEN-VERSION-STRING*))

;(define *PHP-VERSION* "4.4.7")
(define *PHP5-VERSION* "5.2.5") 
(define *PHP-VERSION* *PHP5-VERSION*)
;(define *ZEND-VERSION* "1.3.0")
(define *ZEND2-VERSION* "2.2.0")
(define *ZEND-VERSION* *ZEND2-VERSION*)

;this version number gets put into compiled programs and libraries.
;Whenever non-backwards compatible changes are made to the runtime,
;increment this, so that nobody will be able to use programs
;compiled against the newer runtime on a system that only has the
;older runtime.
(define %runtime-library-version 1.2)
(define (check-runtime-library-version version)
   (if (> version %runtime-library-version)
       (php-error "Installed PCC runtime version "		  
		  %runtime-library-version
		  " is too old.  Version " version " required.")
       #t))

(define TRUE #t)
(define FALSE #f)
(define NULL '())

; XXX these are in opaque-math-bindings nows
; max size of an int (elong) expressed as a flonum
;(define *MAX-INT-SIZE* 2147483647.0)
;(define *MIN-INT-SIZE* (-fl (negfl *MAX-INT-SIZE*) 1.0))

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

;; information about the extensions loaded
(define *extension-info* '())

(define (extension-registered? extension)
   (let ((v (assoc extension *extension-info*)))
      (if v
          (debug-trace 4 "Extension " extension " is registered")
          (debug-trace 4 "Extension " extension " is NOT registered"))
      v))

; make this include version?
(define (register-extension extension version scheme-lib-name lib-list #!key (required-extensions '()))
   ;; Store some information about an extension so that it can be
   ;; looked up later using get-extension-info and for-each-extension.
   ;; The required-extensions are other extensions that must be loaded
   ;; in order to load this extension.
   ;;
   ;; XXX it's kind of unfortunate that we have N extensions per
   ;; scheme library.  Confusing.
   (debug-trace 4 "Registering extension " extension " c libs " lib-list)
   (when (assoc extension *extension-info*)
      (error 'register-extension "extension already registered" extension))
   (pushf `(,extension (version: ,version)
                       (scheme-lib-name: ,scheme-lib-name)
                       (lib-list: ,lib-list)
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

; all include files actually included, per page load
(define *all-files-ever-included* (make-hashtable))


; we need this because init-php-runtime gets
; called more than once, and we don't want to squash anything
(define *runtime-uninitialized?* #t)

;the table containing whole function structs
(define *function-table* (make-hashtable))


;this table contains the closures for interpreted functions 
(define *interpreted-function-table* (make-hashtable))


(define (mkstr::bstring a . args)
   (case (length args)
      ((0) (stringulate a))
      ((1) (fast-string-append (stringulate a) (stringulate (car args))))
      ((2) (string-append (stringulate a) (stringulate (car args)) (stringulate (cadr args))))
      (else (apply string-append (stringulate a) (map stringulate args)))))

(define zval->phpval-coercion-routine
    (lambda (x) (php-error (format "stub zval->phpval, please load php-compat (wanted to convert ~a)" x))))

(define *stringulate-recurse-protect* #f)
(define (stringulate::bstring a)
   ;a copy of unbuffered-echo
   (cond
      ((string? a) a)
      ((container? a) (stringulate (container-value a)))
      ((php-hash? a) "Array")
      ((onum? a) (fast-onum->string a *float-precision*))
      ((flonum? a) (stringulate-float a))
      ((fixnum? a) (integer->string a))
      ((boolean? a) (if a "1" ""))
      ((php-object? a) (if (eqv? *stringulate-recurse-protect* a)
			   (begin
			      (set! *stringulate-recurse-protect* #f)
			      "Object")
			   (begin
			      (set! *stringulate-recurse-protect* a)			      
			      (if (php-class-method-exists? (php-object-class a) "__toString")
				  (mkstr (maybe-unbox (call-php-method-0 a "__toString")))
				  (mkstr (php-recoverable-error "Object of class " (php-object-class a) " could not be converted to a string"))))))
      ((symbol? a) (symbol->string a))
      ((char? a) (string a))
      ((elong? a)
;       ; XXX hack. bigloo no likey print min ints
;       (if (=elong a *MIN-INT-SIZE-L*)
;	   "-2147483648"
	   (elong->string a))
      ((null? a) "")
      ((php-resource? a) (string-append "Resource id #" (integer->string (resource-id a))))
      (else
       (debug-trace 3 "object cannot be coerced to a string")
       ;;if we emit a warning here, and the data is circular, it'll stack overflow (segfault)
       ":ufo:")))


;;;;these are the type coercion functions, except for
;;;;convert-to-object, in php-object.scm, and convert-to-hash in
;;;;php-hash.scm

;just to be pretty
(define (convert-to-string::bstring rval)
   (mkstr rval))

(define (convert-to-boolean::bool rval)
   (when (container? rval)
       (set! rval (container-value rval)))   
   (cond
      ((boolean? rval) rval)
      ((eqv? rval NULL) #f)
      ((onum? rval) (not (= (onum-compare rval *zero*) 0)))
      ((and (number? rval) (= rval 0)) #f)
      ((and (string? rval)
	    (or (string=? rval "")
		(string=? rval "0")))
       #f)
      ((php-hash? rval) (not (zero? (php-hash-size rval))))
      ((php-object? rval)
       (not (zero? (php-hash-size (php-object-props rval)))))
      (else #t)))


; this is guaranteed to return an onum
(define (convert-to-number::onum rval)
   (when (container? rval)
       (set! rval (container-value rval)))
   (cond
      ((onum? rval) rval)
      ((flonum? rval) (float->onum rval))      
      ((elong? rval) (elong->onum rval))
      ((fixnum? rval) (int->onum rval))
      ((boolean? rval) (if rval (int->onum 1) (int->onum 0)))
      ((equal? rval NULL) (int->onum 0))
      ((equal? rval "") (int->onum 0))
      ((string? rval)
       (try (if (or (string-contains rval ".")
                    (string-contains-ci rval "e"))
                (string->onum/float rval)
                (string->onum/long rval))
            (lambda (e p m o)
               (e *zero*))))
      ((or (php-hash? rval)
	   (php-object? rval))
       (if (convert-to-boolean rval)
	   (int->onum 1)
	   (int->onum 0)))
      (else (int->onum 0))))

; should only be used for functions that require a fixnum
; and can't handle an elong (e.g. bigloo procedures)
; this returns a fixnum
(define (mkfixnum rval)
   (if (fixnum? rval)
       rval
       (onum->int (convert-to-number rval))))


; again, this should only be used for functions that require a fixnum
; or flonum (e.g. bigloo procedures). not for php values
(define (mkfix-or-flonum rval)
   (let ((val (convert-to-number rval)))
      (if (fast-onum-is-long val)
	  (onum->int val)
	  (onum->float val))))

(define (convert-to-float rval)
   ;see comment for convert-to-integer.
   (float->onum (onum->float (convert-to-number rval))))


(define (convert-to-integer::onum rval)
   ;we can't modify rval, so we make a copy and force it to be an integer like
   ;so, instead of with convert-onum-to-long!.
   (elong->onum (onum->elong (convert-to-number rval))))

; use instead of number?
(define (php-number? rval)
   (onum? rval))

(define (php-+ a b)
   (if (and (php-hash? (maybe-unbox a))
 	    (php-hash? (maybe-unbox b)))
       (php-hash-append (maybe-unbox a) (maybe-unbox b))
       (onum+ (convert-to-number a) (convert-to-number b))))

(define (php--::onum a b)
   (onum- (convert-to-number a) (convert-to-number b)))

(define (php-*::onum a b)
   (onum* (convert-to-number a) (convert-to-number b)))

(define (php-/::onum a b)
   (onum/ (convert-to-number a) (convert-to-number b)))

; conveneience wrappers
(define (php-< a b)
   (less-than-p a b))

(define (php-> a b)
   (greater-than-p a b))

(define (php->= a b)
   (greater-than-or-equal-p a b))

(define (php-<= a b)
   (less-than-or-equal-p a b))

(define (php-= a b)
   (equalp a b))

(define (php-%::onum a b)
   (onum% (convert-to-number a) (convert-to-number b)))

(define (float-is-finite? a)
   (if (isfinite a)
       #t
       #f))

(define (float-is-nan? a)
   (if (isnan a)
       #t
       #f))

(define (stringulate-float a)
   (cond
      ((zero? a) "0")
      ((float-is-finite? a) (onum->string (convert-to-number a) *float-precision*))
      ((float-is-nan? a) "NAN")
      ((positive? a) "INF")
      (else "-INF")))

(define *output-buffer-implicit-flush?* #f)
(define (unbuffered-echo a)
   (display (stringulate a))
   (when *output-buffer-implicit-flush?*
      (flush-output-port (current-output-port))))

(define (echo a)
   (if (pair? *output-buffer-stack*)
       (with-output-to-port (car *output-buffer-stack*)
	  (lambda ()
	     (unbuffered-echo a)))
       (unbuffered-echo a))
   ;; PHP's print function returns 1
   *one*)

(define (php-string-ref str char)
   (if (eqv? char :next)
       (php-error "[] operator not supported for strings")
       (let ((idx (mkfixnum char)))
	  (if (< idx (string-length str))
	      (mkstr (string-ref str idx))
	      ""))))

(define (php-string-set! str idx val)
   ;; This has a !, but it should actually have no side effect.
   ;; Otherwise, constant strings could be mutated, which is bad
   (let ((str (string-copy str)))
      (when (eqv? idx :next)
	 (php-error "[] operator not supported for strings"))
      (set! val (maybe-unbox val))
      (let ((char-to-insert (if (or (php-null? val)
				    (= 0 (string-length (mkstr val))))
				(integer->char 0)
				(string-ref (mkstr val) 0))))
	 (let ((idx (mkfixnum idx)))
	    (if (< idx 0)
		; this warning is verbatim from a zend warning.
		; please don't change it or remove the second space.
		(php-warning "Illegal string offset:  " idx)
		(begin
		   (when (>= idx (string-length str))
		      (let loop ((i (string-length str)))
			 (when (<= i idx)
			    (begin
			       (set! str (string-append str " "))
			       (loop (+ i 1))))))
		   (string-set! str idx char-to-insert)))
	    str))))


;bitwise ops.. could probably constructively be rewritten using elongs and the C operators.
(define (bitwise-or a b)
   (int->onum
    (bit-or (mkfixnum a) (mkfixnum b))))

(define (bitwise-xor a b)
   (int->onum
    (bit-xor (mkfixnum a) (mkfixnum b))))

(define (bitwise-and a b)
   (int->onum
    (bit-and (mkfixnum a) (mkfixnum b))))

(define (bitwise-not a)
   (int->onum
    (bit-not (mkfixnum a))))

(define (bitwise-shift-left a b)
   (int->onum
    (bit-lsh (mkfixnum a) (mkfixnum b))))

(define (bitwise-shift-right a b)
   (int->onum
    (bit-rsh (mkfixnum a) (mkfixnum b))))


      
; !$a TRUE if $a is not TRUE.
(define (logical-not a)
   (let ((a (if (container? a) (container-value a) a)))
      (not (convert-to-boolean a))))
   
;$a === $b Identical  TRUE if $a is equal to $b, and they are of the same type. (PHP 4 only)
(define (identicalp a b)
   (let ((a (if (container? a) (container-value a) a))
	 (b (if (container? b) (container-value b) b)))
      (if (onum? a)
	  (if (onum? b)
	      ;both are onums
	      (= 0 (onum-compare a b))
	      ;a is onum, b is not
	      #f)
	  (if (php-hash? a)
	      (if (php-hash? b)
		  ;both are php-hashes
		  (= 0 (php-hash-compare a b #t))
		  ;a is php-hash, b is not
		  #f)
	      (if (php-object? a)
		  (if (php-object? b)
		      ;both are php-objects
		      ;you can only compare objects of the same class, it seems.
		      (let ((o (php-object-compare a b #t)))
			 (and (number? o) (= 0 o)))
		      ;a is php-object, b is not
		      #f)
		  (if (or (onum? b) (php-hash? b) (php-object? b))
		      #f
		      ;neither is a php-hash or a php-object, so it's safe to call equal?
		      ;(which would overflow the stack on a php-hash)
		      (equal? a b)))))))


;$a != $b Not equal TRUE if $a is not equal to $b.
;$a <> $b Not equal TRUE if $a is not equal to $b.
(define (not-equal-p a b)
   (not (equalp a b)))

;$a !== $b Not identical  TRUE if $a is not equal to $b, or they are not of the same type. (PHP 4 only)
(define (not-identical-p a b)
   (not (identicalp a b)))

;;;;;;;;;

(define (compare-as-numbers a b)
   (onum-compare (convert-to-number a) (convert-to-number b)))

(define (compare-as-boolean a b)
   (let ((c (convert-to-boolean a))
	 (d (convert-to-boolean b)))
      (cond ((and c d) 0)
	    ((and c (not d)) 1)  
	    ((and (not c) d) -1)
	    ((and (not c) (not d)) 0))))

(define (compare-as-strings a b)
   (let* ((c (mkstr a))
	  (d (mkstr b))
	  (c-s (string-length c))
	  (d-s (string-length d)))
      (c-binary-strcmp c c-s d d-s)))

(define (convert-scalar-to-number a)
   (if (or (string? a)
	   (boolean? a)
	   (null? a)
	   (elong? a)
	   (number? a))
       (convert-to-number a)
       a))

(define (php-var-compare a b)
   "compare two php variables, returning < 0 if a is less than b,
    0 if they are the same, and > 0 if a is greater than b"
   (let ((l (maybe-unbox a))
	 (r (maybe-unbox b)))
      (cond
	 ;; the common number case
	 ((and (php-number? l) (php-number? r))
	  (onum-compare l r))
	 ;; more general stuff
	 ((or (and (string? l) (null? r))
	      (and (string? r) (null? l)))
	  (compare-as-strings l r))

	 ((and (string? l) (string? r))
	  ;; strings could both be numeric
	  (if (and (numeric-string? l) (numeric-string? r))
	      (compare-as-numbers l r)
	      (compare-as-strings l r)))

	 ((or (boolean? l) (boolean? r) (null? l) (null? r))
	  (compare-as-boolean l r))

	 ((and (php-hash? l) (php-hash? r))
	  (php-hash-compare l r #f))

	 ((and (php-object? l) (php-object? r))
	  (php-object-compare l r #f))

	 (else
	  (let ((l (convert-scalar-to-number l))
		(r (convert-scalar-to-number r)))
	     (cond
		((and (php-number? l) (php-number? r))
		 (compare-as-numbers l r))

		((php-hash? l) 1)
		((php-hash? r) -1)
		((php-object? l) 1)
		((php-object? r) -1)
		((php-resource? l) 1)
		((php-resource? r) -1)		
		(else (error 'php-var-compare "not a php type" (cons l r)))))))))


(define (equalp a b)
   (let ((rval (php-var-compare a b)))
      (cond ((boolean? rval) rval)
	    (else (= rval 0)))))

(define (greater-than-p a b)
   (let ((rval (php-var-compare a b)))
      (cond ((boolean? rval) rval)
	    (else (> rval 0)))))

(define (greater-than-or-equal-p a b)
      (let ((rval (php-var-compare a b)))
      (cond ((boolean? rval) rval)
	    (else (>= rval 0)))))

(define (less-than-p a b)
      (let ((rval (php-var-compare a b)))
	 (cond ((boolean? rval) rval)
	       (else (< rval 0)))))

(define (less-than-or-equal-p a b)
      (let ((rval (php-var-compare a b)))
      (cond ((boolean? rval) rval)
	    (else (<= rval 0)))))

;;;;
(define *zero* (int->onum 0))
(define *one* (int->onum 1))

(define (++ a)
   (let ((a (maybe-unbox a)))
      (if (and (string? a)
	       (not (numeric-string? a)))
	  (increment-string a)
	  (onum+ (convert-to-number a) *one*))))


(define-inline (++/num::onum a::onum)
   (onum+ a *one*))

(define (--::onum a)
   (onum- (convert-to-number a) *one*))
(define-inline (--/num::onum a::onum)
   (onum- a *one*))


;;;; these are fast entry-points, for when the compiler knows the type
(define-inline (equalp/num a b)
   (=fx (onum-compare a b) 0))

(define-inline (greater-than-p/num a b)
   (>fx (onum-compare a b) 0))

(define-inline (greater-than-or-equal-p/num a b)
   (>=fx (onum-compare a b) 0))

(define-inline (less-than-p/num a b)
   (<fx (onum-compare a b) 0))

(define-inline (less-than-or-equal-p/num a b)
   (<=fx (onum-compare a b) 0))

(define-inline (php-+/num a b)
   (onum+ a b))

(define-inline (php--/num a b)
   (onum- a b))

(define-inline (php-*-/num a b)
   (onum* a b))

(define-inline (php-//num a b)
   (onum/ a b))

(define-inline (php-%/num a b)
   (onum% a b))

;;;;





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

   ; new environments
   (set! *superglobals* (make-hashtable))
   (set! *global-env* (env-new))
   (set! *current-variable-environment* *global-env*)
   (env-extend *global-env* "GLOBALS" (env-bindings *global-env*))
   
   (hashtable-put! *superglobals* "GLOBALS" #t)
   (hashtable-put! *superglobals* "_GET" #t)
   (hashtable-put! *superglobals* "_POST" #t)
   (hashtable-put! *superglobals* "_COOKIE" #t)
   (hashtable-put! *superglobals* "_FILES" #t)
   (hashtable-put! *superglobals* "_ENV" #t)
   (hashtable-put! *superglobals* "_SERVER" #t)
   (hashtable-put! *superglobals* "_SESSION" #t)
   (hashtable-put! *superglobals* "_REQUEST" #t)

   


   ; reset server superglobals, ready for web backend to fill again
   (init-server-superglobal)
   
   (set! *output-buffer-stack* '())
   (set! *output-callback-stack* '())
   (set! *output-rewrite-vars* (make-hashtable))
   (set! *delayed-errors* '())
   (set! *shutdown-functions* '())
   (reset-constants!)
   (set! *function-table* (make-hashtable))
   (reset-signatures!)
   (set! *interpreted-function-table* (make-hashtable))
   (init-php-object-lib)
   (init-php-error-lib) ; build Exception object, so must follow init-php-object-lib
   (reset-ini!)   
   ; this doesn't change?
   ;(set! $argv 'unset)
   ;(set! $argc 'unset)
   (reset-errors!)   
   (set! *PHP-LINE* 0)
   (set! *PHP-FILE* "unknown"))
   

; called only once per runtime load
(define (init-php-runtime)

   (when *runtime-uninitialized?*

      ; base reset
      (common-reset)
      
      ; ini entries
      (set-ini-entry "register_globals" #f) ; always false right now
      
      ; setup _ENV variable
      ; doesn't change per runtime load and so not reset
      (init-env-superglobal)      
      
      ; all better
      (set! *runtime-uninitialized?* #f)

      )
   
   )

; this sets up the $_ENV superglobal
; which is a list of current environment variables
(define $_ENV 'unset)
(define $HTTP_ENV_VARS 'unset)

(define $HTTP_GET_VARS 'unset)
(define $_GET 'unset)
(define $HTTP_POST_VARS 'unset)
(define $_POST 'unset)
(define $HTTP_COOKIE_VARS 'unset)
(define $_COOKIE 'unset)

(define $_REQUEST 'unset)

(define $HTTP_SERVER_VARS 'unset)
(define $_SERVER 'unset)

(define $HTTP_SESSION_VARS 'unset)
(define $_SESSION 'unset)

(define $HTTP_POST_FILES 'unset)
(define $_FILES 'unset)

(define (init-server-superglobal)
   (set! $HTTP_SERVER_VARS (make-container (make-php-hash)))
   (env-extend *global-env* "HTTP_SERVER_VARS" $HTTP_SERVER_VARS)
   (set! $_SERVER (make-container (make-php-hash)))   
   (env-extend *global-env* "_SERVER" $_SERVER)
   (set! $HTTP_POST_FILES (make-container (make-php-hash)))
   (env-extend *global-env* "HTTP_POST_FILES" $HTTP_POST_FILES)
   (set! $_FILES (make-container (make-php-hash)))
   (env-extend *global-env* "_FILES" $_FILES)
   (set! $HTTP_GET_VARS (make-container (make-php-hash)))
   (env-extend *global-env* "HTTP_GET_VARS" $HTTP_GET_VARS)
   (set! $_GET (make-container (make-php-hash)))
   (env-extend *global-env* "_GET" $_GET)
   (set! $HTTP_POST_VARS (make-container (make-php-hash)))
   (env-extend *global-env* "HTTP_POST_VARS" $HTTP_POST_VARS)
   (set! $_POST (make-container (make-php-hash)))
   (env-extend *global-env* "_POST" $_POST)
   (set! $_REQUEST (make-container (make-php-hash)))
   (env-extend *global-env* "_REQUEST" $_REQUEST)
   (set! $HTTP_COOKIE_VARS (make-container (make-php-hash)))
   (env-extend *global-env* "HTTP_COOKIE_VARS" $HTTP_COOKIE_VARS)
   (set! $_COOKIE (make-container (make-php-hash)))
   (env-extend *global-env* "_COOKIE" $_COOKIE)
   (set! $HTTP_SESSION_VARS (make-container (make-php-hash)))   
   (env-extend *global-env* "HTTP_SESSION_VARS" $HTTP_SESSION_VARS)
   (set! $_SESSION (make-container (make-php-hash)))
   (env-extend *global-env* "_SESSION" $_SESSION)
   )

(define (init-env-superglobal)
   (set! $HTTP_ENV_VARS (make-container (make-php-hash)))
   (env-extend *global-env* "HTTP_ENV_VARS" $HTTP_ENV_VARS)
   (for-each (lambda (a)
		(php-hash-insert! (container-value $HTTP_ENV_VARS) (car a) (cdr a)))
	     (environ))
   (set! $_ENV (copy-php-data $HTTP_ENV_VARS))
   (env-extend *global-env* "_ENV" $_ENV))

(define $argv 'unset)
(define $argc 'unset)
(define (init-php-argv argv)   
   (set! $argv (make-container (list->php-hash argv)))
   (env-extend *global-env* "argv" $argv)
   (set! $argc (make-container (convert-to-integer (length argv))))
   (env-extend *global-env* "argc" $argc)
   ; when in command line, add argv, argc
   (when *commandline?*
      ; copy variables from env as per php
      (for-each (lambda (a)
		   (php-hash-insert! (container-value $HTTP_SERVER_VARS) (car a) (cdr a)))
		(environ))
      (unless (null? argv)
	 (php-hash-insert! (container-value $HTTP_SERVER_VARS) "PHP_SELF" (car argv))
	 (php-hash-insert! (container-value $HTTP_SERVER_VARS) "SCRIPT_NAME" (car argv))
	 (php-hash-insert! (container-value $HTTP_SERVER_VARS) "SCRIPT_FILENAME" (car argv))
	 (php-hash-insert! (container-value $HTTP_SERVER_VARS) "PATH_TRANSLATED" (car argv))
	 (php-hash-insert! (container-value $HTTP_SERVER_VARS) "DOCUMENT_ROOT" "")
	 (php-hash-insert! (container-value $HTTP_SERVER_VARS) "argv" (container-value $argv))
	 (php-hash-insert! (container-value $HTTP_SERVER_VARS) "argc" (container-value $argc)))
      ;; finally, copy the server vars into $_SERVER. 
      (container-value-set! $_SERVER (copy-php-data (container-value $HTTP_SERVER_VARS)))))


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
(define (env-import env source-hash prefix::string)
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
   (php-hash-lookup-ref (env-bindings env) #t name))

(define (env-lookup-internal-index env name::bstring)
   (let ((bindings (env-bindings env)))
      (or (php-hash-lookup-internal-index bindings name)
	  (begin
	     ;create it if it doesn't exist
	     (php-hash-lookup-ref bindings #t name)
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

(define-inline (maybe-unbox thupet)
   (let ((retval
	  (if (container? thupet)
	      (container-value thupet)
	      thupet)))
      [assert (retval) (not (container? retval))]
;;       (when (container? retval)
;; 	 (error 'maybe-unbox "Invariant lost: container found inside a container" thupet))
      retval))

(define-inline (maybe-box thupet)
   (if (container? thupet)
       thupet
       (make-container thupet)))


(define (hashtable-copy hash)
   (let ((new-hash (make-hashtable (max 1 (hashtable-size hash)))))
      (hashtable-for-each hash
			  (lambda (key val)
			     (hashtable-put! new-hash key val)))
      new-hash))

;; like php-funcall except the callback call also be a two-entry hash
;; where the first entry is the object or class and the second is the
;; method to call.
(define (php-callback-call callback . arglist)
   (if (php-hash? callback)
       (let ((class-or-obj (php-hash-lookup callback 0))
             (methodname (php-hash-lookup callback 1)))
          (if (php-object? class-or-obj)
              (apply call-php-method class-or-obj methodname arglist)
              (apply call-static-php-method class-or-obj NULL methodname arglist)))
       (apply php-funcall callback arglist)))

(define (php-funcall call-name . call-args)
   "do a function call at runtime"
   (let* ((sig (get-php-function-sig call-name))
	  (canonical-name (if sig (sig-canonical-name sig)))
	  (call-len (length call-args)))
      ;      (profile-enter canonical-name)
      ; 	  (arg-locations (map (lambda (arg)
      ; 				 (if (container? arg)
      ; 				     arg
      ; 				     (make-container arg)))
      ; 			      call-args)))
      (unless sig
	 ; no function signature, always fatal 
	 ; to simulate php we end manually if disable-errors is true
	 (if *errors-disabled*
	     (begin
		(php-warning "lookup-function - undefined function: " call-name)
		(exit -1))
	     (php-error "lookup-function - undefined function: " call-name)))
      (let ((the-function (sig-function sig)))
	 (unless the-function
	    (set! the-function
		  (or (hashtable-get *interpreted-function-table* canonical-name)
		      ;(eval canonical-name)
		      (error 'runtime-funcall-1 "function should be defined" sig)
		      ))
	    (sig-function-set! sig the-function))
	 [assert (the-function) (procedure? the-function)]
	 (php-check-arity sig call-name call-len)
	 (apply the-function
		(let ((args-num (if (sig-var-arity? sig)
				    call-len
				    (sig-length sig))))
		   ; pass each argument
		   (let loop ((i 0)
			      (call-args call-args)
			      (args '()))
		      (if (<fx i args-num)
			  (loop (+fx i 1)
				(gcdr call-args)
				(cons (if (<fx i call-len)
					  (if (sig-param-ref? (sig-ref sig i))
					      (maybe-box (car call-args))
					      (maybe-unbox (car call-args)))
					  ;when interpreting code, the function signatures have the _code_
					  ;for the default value in them
					  (evaluate-default-value (sig-param-default-value (sig-ref sig i))))
				      args))
			  (begin
			     ;(print "args is: " args ", args-num is " args-num)
			     (reverse! args)))))))))

(define-struct funcall-handle
   function ;the actual procedure
   sig ;the signature
   total-number-of-arguments ;call-arity + default args
   call-arity) ;number of arguments passed

(define (php-get-funcall-handle call-name call-arity)
   "get a function 'handle' which can be immediately applied later"
   (let* ((sig (get-php-function-sig call-name))
	  (canonical-name (if sig (sig-canonical-name sig)))
	  (min-args (if sig (sig-minimum-arity sig)))
	  (max-args (if sig (sig-maximum-arity sig))))
      (unless sig
	 ; no function signature, always fatal 
	 ; to simulate php we end manually if disable-errors is true
	 (if *errors-disabled*
	     (begin
		(php-warning "lookup-function - undefined function: " call-name)
		(exit -1))
	     (php-error "lookup-function - undefined function: " call-name)))
      (php-check-arity sig call-name call-arity)
      (let ((the-function (sig-function sig)))
	 (unless the-function
	    (set! the-function
		  (or (hashtable-get *interpreted-function-table* canonical-name)
		      (error 'runtime-funcall "function should be defined" sig)
		      ;(eval canonical-name)
		      ))
	    (sig-function-set! sig the-function))

	 [assert (the-function) (procedure? the-function)]
	 (funcall-handle the-function
			 sig
			 (if (sig-var-arity? sig)
			     call-arity
			     (sig-length sig))
			 call-arity))))

(define (php-funcall/handle handle::struct call-args)
   (let ((the-fun (funcall-handle-function handle))
	 (sig (funcall-handle-sig handle))
	 (args-num (funcall-handle-total-number-of-arguments handle))
	 (call-len (funcall-handle-call-arity handle)))
      (apply the-fun
	     ; pass each argument
	     (let loop ((i 0)
			(call-args call-args)
			(args '()))
		(if (<fx i args-num)
		    (loop (+fx i 1)
			  (gcdr call-args)
			  (cons (if (<fx i call-len)
				    (if (sig-param-ref? (sig-ref sig i))
					(maybe-box (car call-args))
					(maybe-unbox (car call-args)))
				    ;when interpreting code, the function signatures have the _code_
				    ;for the default value in them
				    (evaluate-default-value (sig-param-default-value (sig-ref sig i))))
				args))
		    (begin
		       ;(print "args is: " args ", args-num is " args-num)
		       (reverse! args)))))))



(define (evaluate-default-value value)
   "evaluate the default value of an optional argument"
   (match-case value
      (*zero* *zero*)
      (*one* *one*)
      ((quote ?FOO) FOO)
      ((lookup-constant ?CONST) (lookup-constant (mkstr CONST)))
      ((convert-to-number ?FOO) (convert-to-number FOO))
      ;negative numeric literal
      ((php-- *zero* (convert-to-number ?NUM))
       (php-- *zero* (convert-to-number NUM)))
      ;constant in a builtin
      ((and (? symbol?) ?A)
       (lookup-constant (symbol->string A)))
      ;literal array
      ((let ((?NEWHASH (make-php-hash))) . ?REST)
       (let ((new-hash (make-php-hash)))
	  (for-each (lambda (insert-stmt)
		       (when (pair? insert-stmt)
			  (php-hash-insert! new-hash
					    (caddr insert-stmt)
					    (cadddr insert-stmt))))
		    REST)
	  new-hash))
      (?FOO FOO)))
	  
(define (php-null? a)
   (eqv? a NULL))

(define (php-resource? a)
   ;;;XXX fixme this doesn't have a good definition!
   (and (struct? a)
	(not (php-constant? a))
	(not (php-hash? a))
	(not (php-object? a))))



;(define *copy-circle-table* (make-grasstable))

(define (copy-php-data data)
   (let ((box? #f))
      (when (container? data)
	 (set! box? #t)
	 (set! data (container-value data)))
      (let ((the-copy
	     (cond
		((php-hash? data)
		 (copy-php-hash data #f))
		((php-object? data)
                 (if PHP5?
                     data
                     (copy-php-object data #f)))
                ((foreign? data)
                 (copy-php-data (zval->phpval-coercion-routine data)))
		(else data))))
	 (if box?
	     (make-container the-copy)
	     the-copy))))


;;;;containers
;; we use 1 for regular containers and 3 for reference containers
;; because (bit-or 1 2) is 3 and (bit-or 3 2) is 3, so it's easy
;; to check what's a container.
(define-inline (make-container::pair value)
   (cons value 1))

(define-inline (container->reference!::pair value)
   (set-cdr! value 3)
   value)

(define-inline (container-reference? value)
   (= 3 (cdr value)))

(define-inline (container-value-set! container::pair value)
   ;; XXX without this when, and the unless in container-value,
   ;; several tests fail, including zthis.php and ref1.php.  The
   ;; problem showed up when we upgraded to bigloo 2.8b.
   (set-car! container value))

(define-inline (container-value container::pair)
   (car container))

(define-inline (container? container)
   (and (pair? container)
	;	(not (null? (cdr container))) ; XXX why does this happen?? weyrick 10/15/04
	;;
	;; because container? could be applied to anything, and some things,
	;; e.g. lists of length one, will have null in the cdr, which is a type error
	;; for bit-or.  But not for fixnum? !  So let's just use fixnum?. --tpd 10/19/04
	(fixnum? (cdr container))))
;	(= 3 (bit-or (cdr container) 2))))
;	(eqv? (cdr container) 'container)))



(define (valid-php-type? value)
   (let ((val (maybe-unbox value)))
      (if (or (php-number? val)
	      (string? val)
	      (boolean? val)
	      (php-hash? val)
	      (php-object? val)
	      (php-resource? val)
	      (null? val))
	  #t
	  #f)))

(define (coerce-to-php-type orig)
   ;make sure that a is a valid php type
   (let ((val (maybe-unbox orig)))
      (cond
	 ((valid-php-type? orig) orig)
	 ((or (elong? val) (number? val))
	  (convert-to-number orig))
	 ((symbol? val) (symbol->string val))
	 ((keyword? val) (keyword->string val))
	 ((char? val) (make-string 1 val))
	 (else
	  NULL))))

; XXX this should go in it's own module
; output buffering
(defconstant PHP_OUTPUT_HANDLER_START 1)
(defconstant PHP_OUTPUT_HANDLER_CONT  (bit-lsh 1 1))
(defconstant PHP_OUTPUT_HANDLER_END   (bit-lsh 1 2))

;the top of this stack is the current output buffer, if the stack is
;empty output is unbuffered
(define *output-buffer-stack* '())

; this should mirror the output-buffer-stack: always the same length.
; either there will be a string representing the function to call, or
; a nil.
(define *output-callback-stack* '())

; for url rewriter
(define *output-rewrite-vars* (make-hashtable))

; we need a hook here to possibly turn on url rewriting
(add-startup-function maybe-init-url-rewriter)

(define (maybe-init-url-rewriter)
   (when (convert-to-boolean (get-ini-entry "session.use_trans_id"))
      ; defbuiltin is defined in ext/standard/php-output-control.scm
      (ob-start "_internal_url_rewriter")))

; rewrite urls for transparent session ids

(define (ob-build-get-vars)
   (let ((getvars ""))
      (hashtable-for-each *output-rewrite-vars*
	 (lambda (k v)
	    (set! getvars (mkstr getvars k "=" v "&"))))
      (substring getvars 0 (max 0 (- (string-length getvars) 1)))))

(define (ob-build-post-vars)
   (let ((postvars ""))
      (hashtable-for-each *output-rewrite-vars*
			  (lambda (k v)
			     (set! postvars (string-append postvars
							   (format "<input type=\"hidden\" name=\"~a\" value=\"~a\">~%" k v)))))
      postvars))

(define (ob-rewrite-urls output)
   (let ((getvars (ob-build-get-vars))
	 (postvars (ob-build-post-vars))
	 (tags-to-rewrite (get-ini-entry "url_rewriter.tags")))
      ; list of tags to replace comes from tags-to-rewrite which defaults to
      ; "a=href,area=href,frame=src,input=src,form=fakeentry" per php ini
      (let ((a? #f) (area? #f) (frame? #f) (input? #f) (form? #f))
	 (let ((rg (regular-grammar ()
		      ("a=href" (set! a? #t))
		      ("area=href" (set! area? #t))
		      ("frame=src" (set! frame? #t))
		      ("input=src" (set! input? #t))
		      ("form=fakeentry" (set! form? #t))
		      ("," 'woo!))))	    
	    (get-tokens-from-string rg tags-to-rewrite)
	    (debug-trace 4 "rewrite tags: a? " a? ", area? " area? ", frame? " frame?
			 ", input? " input? ", form? " form?))
	 (rewrite-urls output getvars postvars a? area? frame? input? form?))))

(define (ob-start callback)
   (ob-verify-stacks)
   (set! *output-buffer-stack*
	 (cons (open-output-string) *output-buffer-stack*))
   (set! *output-callback-stack*
	 (cons (if (eqv? callback 'unpassed)
		   #f
		   (if (php-hash? callback)
		       (cons (container-value (php-hash-lookup-ref callback #f 0))
			     (php-hash-lookup callback 1))
		       callback))
	       *output-callback-stack*)) )

(define (ob-pop-stacks)
   (ob-verify-stacks)
   (if (pair? *output-buffer-stack*)
       (begin
	  (set! *output-buffer-stack* (cdr *output-buffer-stack*))
	  (set! *output-callback-stack* (cdr *output-callback-stack*))
	  #t)
       #f))

(define (ob-verify-stacks)
   (unless (= (length *output-callback-stack*)
	      (length *output-buffer-stack*))
      (php-error
       "verify-stacks: output buffer stacks currupted. callbacks: "
       *output-callback-stack*
       ", buffers "
       *output-buffer-stack*)))

(define (ob-flush-to-next from to callback)
   "flush output from buffer from into buffer to, if to is #f, display
   the output"
   (let* ((len (length *output-buffer-stack*))
	  ; XXX bigloo currently has a bug with flush-output-port, stick to close here
	  (output (flush-output-port from))
	  ; XXX this isn't right yet see #1156
	  (mode (cond ((= len 1) PHP_OUTPUT_HANDLER_START)
		      ((eqv? to #f) PHP_OUTPUT_HANDLER_END)
		      (else PHP_OUTPUT_HANDLER_END))))
      (when callback
	 ; a pair means we call a method
	 (if (pair? callback)
	     (set! output (mkstr (call-php-method (car callback) (cdr callback) output)))
	     (let ((callback-sig (get-php-function-sig callback)))
	     (if callback-sig
		 (case (sig-length callback-sig)
		    ((1) (set! output (mkstr (php-funcall callback output))))
		    ((2) (set! output (mkstr (php-funcall callback output mode))))
		    (else (php-error "output buffering callback has invalid number of arguments")))
		 (php-error "output buffering callback undefined: " callback)))))
      (if to
	  (display output to)
	  (begin
	     (display output)
	     ;(flush-output-port (current-output-port))
	     ))
      #t))


(define (ob-flush)
   (let ((len (length *output-buffer-stack*)))
      (cond 
	 ((= len 1) (ob-flush-to-next (car *output-buffer-stack*) #f
				      (car *output-callback-stack*)))
	 ((> len 1) (ob-flush-to-next (car *output-buffer-stack*)
				      (cadr *output-buffer-stack*)
				      (car *output-callback-stack*)))
	 (else #f))))

(define (ob-flush-all)
   (let loop ()
      (ob-flush)
      (if (ob-pop-stacks)
 	  (loop))))


;; include files

; 
(define (set-include-paths! path-list)
   (when (list? path-list)
      (set! *include-paths* path-list)))

; note used in webconnect/apache for .htaccess
; call when include paths should be set for this page view only
(define (set-temp-include-paths! path-list)
    (when (list? path-list)
       (set! *temp-include-paths* path-list)))



;;;;variable arity user function stuff, see also php-core.scm
(define *func-args-stack* '())

(define (push-func-args list-of-arguments)
   (pushf list-of-arguments *func-args-stack*))

(define (pop-func-args)
   [assert (*func-args-stack*) (not (null? *func-args-stack*))]
   (popf *func-args-stack*))

;;;;cruddy array operators
(define (%general-lookup-ref obj key)
   "Lookup key in obj. Always returns a container, if it returns.
Obj should not be in a container."
   (cond
      ((php-hash? obj) (let ((val (php-hash-lookup-ref obj #t key)))
			  ; XXX add this back when we fix isset/empty
			  ;(when (eqv? (container-value val) NULL)
			     ;(php-notice "Undefined index: " key))
			  val))
      ((string? obj) (php-error "Cannot create references to string offsets"))
      ((foreign? obj) (%general-lookup-ref 
                       (zval->phpval-coercion-routine obj)
                       key))
      (else ;(php-warning "Cannot use a scalar as an array -- " obj)
	    (make-container NULL))))

(define (%general-lookup obj key)
   "Lookup key in obj. Doesn't return a container.  Obj should not be
in a container."
   (cond
      ((php-hash? obj) (let ((val (php-hash-lookup obj key)))
			  ; XXX add this back when we fix isset/empty			  
			  ;(when (eqv? val NULL)
			  ;    (php-notice "Undefined index: " key))
			  val))
      ((string? obj) (php-string-ref obj key))
      ((foreign? obj) (%general-lookup 
                       (zval->phpval-coercion-routine obj)
                       key))
      (else ;(php-warning (format "Cannot use a scalar as an array -- ~A" obj))
	    NULL)))

(define (%general-lookup/pre obj key pre)
   "Lookup key in obj. Doesn't return a container.  Obj should not be
in a container."
   (cond
      ((php-hash? obj) (let ((val (php-hash-lookup/pre obj key pre)))
			  ; XXX add this back when we fix isset/empty			  
			  ;(when (eqv? val NULL)
			  ;    (php-notice "Undefined index: " key))
			  val))
      ((string? obj) (php-string-ref obj key))
      ((foreign? obj) (%general-lookup 
                       (zval->phpval-coercion-routine obj)
                       key))
      (else ;(php-warning (format "Cannot use a scalar as an array -- ~A" obj))
	    NULL)))

(define (%general-lookup-honestly-just-for-reading obj key)
   "Lookup key in obj. Doesn't return a container.  Obj should not be
in a container."
   (cond
      ((php-hash? obj) (let ((val (php-hash-lookup-honestly-just-for-reading obj key)))
			  ; XXX add this back when we fix isset/empty			     
			  ;(when (eqv? val NULL)
			     ; (php-notice "Undefined index: " key))			     
			  val))			  
      ((string? obj) (php-string-ref obj key))
      ((foreign? obj) (%general-lookup-honestly-just-for-reading
                       (zval->phpval-coercion-routine obj)
                       key))
      (else ;(php-warning (format "Cannot use a scalar as an array -- ~A" obj))
	    NULL)))

(define (%general-lookup-honestly-just-for-reading/pre obj key pre)
   "Lookup key in obj. Doesn't return a container.  Obj should not be
in a container."
   (cond
      ((php-hash? obj) (let ((val (php-hash-lookup-honestly-just-for-reading/pre obj key pre)))
			  ; XXX add this back when we fix isset/empty			     
			  ;(when (eqv? val NULL)
			     ; (php-notice "Undefined index: " key))			     
			  val))			  
      ((string? obj) (php-string-ref obj key))
      ((foreign? obj) (%general-lookup-honestly-just-for-reading
                       (zval->phpval-coercion-routine obj)
                       key))
      (else ;(php-warning (format "Cannot use a scalar as an array -- ~A" obj))
	    NULL)))

(define (%coerce-for-insert obj)
   (if (or (php-null? obj)
           (not obj) ;; false gets treated like NULL here, see bug 3210
	   (and (string? obj) (=fx 0 (string-length obj))))
       (make-php-hash)
       obj))

(define (%general-insert! obj key val)
   "Insert into obj at key.  Val may be a container, meaning
reference insert in the case of a hash."
   (cond
      ((php-hash? obj) (php-hash-insert! obj key val) obj)
      ((string? obj) (php-string-set! obj key val))
      ((foreign? obj) (%general-insert!
                       (zval->phpval-coercion-routine obj)
                       key
                       val))
      (else (php-warning "Cannot use a scalar value as an array")
	    obj)))

(define (%general-insert!/pre obj key pre val)
   "Insert into obj at key.  Val may be a container, meaning
reference insert in the case of a hash."
   (cond
      ((php-hash? obj) (php-hash-insert!/pre obj key pre val) obj)
      ((string? obj) (php-string-set! obj key val))
      ((foreign? obj) (%general-insert!
                       (zval->phpval-coercion-routine obj)
                       key
                       val))
      (else (php-warning "Cannot use a scalar value as an array")
	    obj)))

(define (%general-insert-n! obj keys precalculated-hashnumbers val)
   ;;this is the nested version of %general-insert!
   (let loop ((obj obj)
	      (key (car keys))
	      (keys (cdr keys))
              (pre (car precalculated-hashnumbers))
              (pres (cdr precalculated-hashnumbers)))
      ;;we loop over the keys, from left to right in the source code
      ;;i.e. $foo[0][2], we want 0 first in keys
      (if (null? keys)
	  ;;this is the base case -- finally insert the value
	  ;;whether it's a reference or not depends on whether or
	  ;;not it's in a container.  we don't decide that here.
          (if pre
              (%general-insert!/pre obj key pre val)
              (%general-insert! obj key val))
	  ;;in case of, say, $foo[0][2], we have to get the array
	  ;;or string for $foo[0], then insert into its [2] element
	  (let ((next (if pre
                          (%general-lookup/pre obj key pre)
                          (%general-lookup obj key))))
	     ;;null and empty strings are coerced to hashtables as of php 4.3.7
	     (if (or (php-null? next)
		     (and (string? next) (=fx 0 (string-length next))))
		 ;;create a hashtable and insert it, thereby performing the coercion
		 ;;then continue to loop over the new hashtable 
		 (let ((next (make-php-hash)))
                    (if pre
                        (%general-insert!/pre obj key pre next)
                        (%general-insert! obj key next))
		    (loop next (car keys) (cdr keys) (car pres) (cdr pres)))
		 (if (php-hash? next)
		     ;;$foo[0] is already a hashtable, so move on to the next key,
		     ;;[2] in our example
		     (loop next (car keys) (cdr keys) (car pres) (cdr pres))
		     ;;$foo[0] was a string, so we have to reinsert the result of
		     ;;inserting val into [2] into $foo[0], since the string-char-set!
		     ;;operation could return a fresh string.
 		     (if (string? next)
 			 (%general-insert! obj key (loop next (car keys) (cdr keys) (car pres) (cdr pres)))
			 ;;things other than null and empty strings aren't coerced.
			 ;;instead, we print a warning and give up.  php 4.3.7 behavior.
			 (php-warning "Cannot use a scalar value as an array")))))))
   ;;we return the original object, so that it can be assigned back into
   ;;the variable or whatever holds it, in case it was coerced in the argument
   ;;list of the call to %general-insert-n!
   ;;(i.e. (%general-insert-n (%coerce ...) ...))
   obj)


;;;;even cruddier string increment doodad
(define (increment-string str)
   (let ((len (string-length str)))
      (if (=fx len 0)
	  "1"
	  (let ((result (string-copy str)))
	     (let loop ((pos (-fx len 1))
			(carry? #t)
			(last 'dunno))
		(if (and carry? (>=fx pos 0))
		    (let ((c (string-ref str pos)))
		       (cond
			  ((and (char>=? c #\a) (char<=? c #\z))
			   (if (char=? c #\z)
			       (begin
				  (string-set! result pos #\a)
				  (loop (-fx pos 1) #t 'lowercase))
			       (begin
				  (string-set! result pos (integer->char (+ 1 (char->integer c))))
				  (loop (-fx pos 1) #f 'lowercase))))
			  ((and (char>=? c #\A) (char<=? c #\Z))
			   (if (char=? c #\Z)
			       (begin
				  (string-set! result pos #\A)
				  (loop (-fx pos 1) #t 'uppercase))
			       (begin
				  (string-set! result pos (integer->char (+ 1 (char->integer c))))
				  (loop (-fx pos 1) #f 'uppercase))))
			  ((and (char>=? c #\0) (char<=? c #\9))
			   (if (char=? c #\9)
			       (begin
				  (string-set! result pos #\0)
				  (loop (-fx pos 1) #t 'numeric))
			       (begin
				  (string-set! result pos (integer->char (+ 1 (char->integer c))))
				  (loop (-fx pos 1) #f 'numeric))))
			  (else
			   (loop pos #f 'dunno))))
		    (if carry?
			(ecase last
			   ((numeric) (string-append "1" result))
			   ((uppercase) (string-append "A" result))
			   ((lowercase) (string-append "a" result)))
			result)))))))

; notify user that some functionality is missing, return #f
(define (mingw-missing func)
   (php-warning (mkstr "the function: '" func "' is not supported on this platform")))

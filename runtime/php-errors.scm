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
;;;; PHP error signalling and handling
(module php-errors
   (include "php-runtime.sch")
   (import (php-runtime "php-runtime.scm")
	   (php-object "php-object.scm")
           (php-hash "php-hash.scm")
	   (constants "constants.scm")
           (signatures "signatures.scm"))
   (load (php-macros "../php-macros.scm"))
   (export
    *error-handler*
    *default-exception-handler*
    *error-level* ; per php error_reporting
    *errors-disabled*
    *stack-trace*
    *saved-stack-trace*
    *track-stack?*
    *compile-mode?*
    *delayed-errors*
    ;error constants
     E_ERROR
     E_WARNING
     E_PARSE 
     E_NOTICE
     E_CORE_ERROR
     E_CORE_WARNING
     E_COMPILE_ERROR
     E_COMPILE_WARNING
     E_USER_ERROR 
     E_USER_WARNING
     E_USER_NOTICE 
     E_ALL
     ;
    (init-php-error-lib)
    (push-stack class-name name . args)
    (pop-stack)
    (print-stack-trace)
    (print-stack-trace-html)
    delayed-error
    (php-exception try-stack except-obj)
    (php-error . msgs)
    (php-warning . msgs)
    (php-notice . msgs)
    (dump-bigloo-stack port num)
    (handle-delayed-errors)
    (handle-runtime-error escape proc msg obj)
    (reset-errors!)))


; are we compiling or runtime?
; current determines how we print errors
(define *compile-mode?* #f)


;;;;PHP errors

; this is #t when prefixing php
(define *errors-disabled* #f)

(defconstant E_ERROR 1)
(defconstant E_WARNING 2)
(defconstant E_PARSE 4)
(defconstant E_NOTICE 8)
(defconstant E_CORE_ERROR 16)
(defconstant E_CORE_WARNING 32)
(defconstant E_COMPILE_ERROR 64)
(defconstant E_COMPILE_WARNING 128)
(defconstant E_USER_ERROR 256)
(defconstant E_USER_WARNING 512)
(defconstant E_USER_NOTICE 1024)
(defconstant E_ALL 2047)

; implementations found in ext/standard/php-core.scm
(define *error-handler* "_default_error_handler")
(define *default-exception-handler* "_default_exception_handler")

(define *error-level* E_ALL)

(define *anti-error-recurse* #f)

; magic constants
(store-special-constant "__FUNCTION__" (lambda ()
					  (when (pair? *stack-trace*)
					     (let ((top (car *stack-trace*)))
						(stack-entry-function top)))))
(store-special-constant "__METHOD__" (lambda ()
					(when (pair? *stack-trace*)
					   (let ((top (car *stack-trace*)))
					      (if (stack-entry-class-name top)
						  (mkstr (stack-entry-class-name top) "::" (stack-entry-function top))
						  "")))))
(store-special-constant "__CLASS__" (lambda ()
					  (when (pair? *stack-trace*)
					     (let ((top (car *stack-trace*)))
						(stack-entry-class-name top)))))

; called at start and on page resets
(define (init-php-error-lib)
   (set! *error-handler* "_default_error_handler")
   (set! *default-exception-handler* "_default_exception_handler")
   (set! *error-level* E_ALL)
   (set! *anti-error-recurse* #f)
   ; always have to rebuild, because object system resets
   (build-Exception-class))

; Exception base class
; XXX this is incomplete
(define (build-Exception-class)
   (define-php-class 'Exception '())
   (define-php-property 'Exception "message" "Unknown exception" 'protected)
   (define-php-property 'Exception "code" *zero* 'protected)
   (define-php-method 'Exception "__construct" Exception:__construct)
   (define-php-method 'Exception "getMessage" Exception:getMessage))

(define (Exception:__construct this optional-args)
   (let ((message '())
	 (code '()))
      (when (pair? optional-args)
	 (set! message
	       (maybe-unbox (car optional-args)))
	 (set! optional-args (cdr optional-args)))
      (when (pair? optional-args)
	 (set! code
	       (maybe-unbox (car optional-args)))
	 (set! optional-args (cdr optional-args)))
      (when message
	 (php-object-property-set!/string this "message" message 'all))
      (when code
	 (php-object-property-set!/string this "code" code 'all))))

(define (Exception:getMessage this optional-args)
   (php-object-property-h-j-f-r/string this "message" 'all))

; try-stack is a list of pairs: (Classname . <exception proc>)
; we traverse the list, checking Classname's for is-a match
; if we find it, we call the associated exception proc
; if we don't we handle it via the default exception handler
(define (php-exception try-stack except-obj)
;   (debug-trace 0 "in php-exception stack is " try-stack " and obj is " except-obj)
  (let loop ((stack try-stack))
    (if (null? try-stack)
        (php-funcall *default-exception-handler* except-obj)
        (let ((ex (car stack)))
          (if (php-object-is-a except-obj (mkstr (car ex)))
              ((cdr ex) (cons (car ex) except-obj)) ; match: call the escape proc, with the matching class name . except-obj as an argument
              (loop (cdr stack)))))))

; ALWAYS FATAL
(define (php-error . msgs)
   ; if we're compiling or making a library from command line, just print to stderr else use error handler
   (if *compile-mode?*
       (begin
	  (fprint (current-error-port) (apply mkstr msgs))
	  (exit 1))
       (error 'error-handler (apply mkstr msgs) 'error-handler)))

(define (php-warning/notice msg type)
   (debug-trace 2 "php-warning/notice msg: " msg ", type: " type
		"(as fixnum: " (mkfixnum type) "), file: " *PHP-FILE* ", line: " *PHP-LINE*)
   (if *compile-mode?*
       (fprint (current-error-port) msg)
       (unless (and *errors-disabled*
		    (< *debug-level* 2))
	  (set! *saved-stack-trace* *stack-trace*)
	  ; call current php error handler
	  (let ((error-handler-sig (get-php-function-sig *error-handler*)))
	     (if error-handler-sig
		 (case (sig-length error-handler-sig)
		    ((2) (php-funcall *error-handler* type msg))
		    ((3) (php-funcall *error-handler* type msg *PHP-FILE*))
		    ((4) (php-funcall *error-handler* type msg *PHP-FILE* *PHP-LINE*))
		    ((5) (php-funcall *error-handler* type msg *PHP-FILE* *PHP-LINE* (make-php-hash))) ; XXX hash should be real
		    (else
		     (error 'php-warning/notice "error handler has invalid number of arguments" 'php-warning/notice)))
		 ; no error handler found, dump to error port
		 ; this should only happen before std lib is loaded
		 (fprint (current-error-port) msg)))))
   (debug-trace 2 (with-output-to-string
		     (lambda ()
			(dynamically-bind (*saved-stack-trace* *stack-trace*)
			   (print-stack-trace)))))
   ; these always return false, and much code depends on this
   #f)

(define (php-warning . msgs)
   (php-warning/notice (apply mkstr msgs) E_WARNING))

(define (php-notice . msgs)
   (php-warning/notice (apply mkstr msgs) E_NOTICE))

(define (dump-bigloo-stack port num)
    (cond-expand
       (unsafe
	; no stack dump in unsafe mode 
        #f)
       (else 
	(dump-trace-stack port num))))

(define (handle-runtime-error escape proc msg obj)
   (cond ((or (and (eqv? proc 'php-exit) (eqv? obj 'php-exit))
              (and *errors-disabled*
		   (< *debug-level* 2)))
	  ; error was signalled by us intentionally by php exit
	  ; or error messages are disabled
	  ; quit now in a way that will still allow web requests to return output to client
	  (escape #t))
	 ; compiler error, don't dupe file/line info from php-error/loc in ast
	 ; and no stack trace
	 ((eqv? proc 'compile-error)
	  (if *commandline?*	      
	      (fprint (current-error-port)
		      (with-output-to-string
			 (lambda ()
			    (print msg))))
	      (begin
		 (when (> *debug-level* 1)
                    ;mingw (log-error 
		    (fprint (current-error-port) msg))
		 (print msg)))
	  (escape #t))
	 ; triggered by php-error or unknown bigloo location
	 (else
	  (begin
	     (set! *saved-stack-trace* *stack-trace*)
	     (if *commandline?*
		 ; command line, no html
		 (fprint (current-error-port)
			 (with-output-to-string
			    (lambda ()
			       (print "Runtime error in file " *PHP-FILE* " on line " *PHP-LINE* ": " msg)
			       (print-stack-trace))))
		 ; web mode, html
		 (begin
		    (print "\n\n<br /><b>Runtime error</b> in file " *PHP-FILE* " on line " *PHP-LINE* ": " msg "<br />")
		    (print-stack-trace-html)
		    (when (> *debug-level* 1)
		       (print "<pre>--- Bigloo Stack:\n")
		       (dump-bigloo-stack (current-output-port) 10)
		       (print "</pre>\n"))))
	     (escape #t)))))


;;;;;;;stack trace stuff
(define *stack-trace* '())
;since php functions are used to handle errors, and they modify the stack trace
;themselves, we need to save the one from the last error.
(define *saved-stack-trace* '())


(define (push-stack class-name name . args)
   (set! *stack-trace* 
	 (cons (stack-entry *PHP-FILE* *PHP-LINE* name args class-name 'unset) *stack-trace*)))
	     
(define (pop-stack)
   (when (pair? *stack-trace*)
      (set! *stack-trace* (cdr *stack-trace*))))

(define (trunc-string s)
   (let ((ss (mkstr s)))
      (if (> (string-length ss) 20)
	  (string-append (substring ss 0 20) "...")
	  ss)))

(define (nice-stack-args args)
   (if (null? args)
       ""
       (let ((maxloop 30))
	  (string-append
	   "("
	   (with-output-to-string
	      (lambda ()
		 (let loop ((args args)
			    (i 0))
		    (unless (or (null? args) (> i maxloop))
		       (display (trunc-string (car args)))
		       (unless (null? (cdr args))
			  (display ", ")
			  (loop (cdr args) (+ i 1)))))))
	   ")"))))

(define (print-stack-trace)
   (unless (null? *stack-trace*)
      (print "Stack trace:"))
   (for-each (lambda (a)
		(print (format "File ~a line ~a: ~a~a"
			       (stack-entry-file a)
			       (stack-entry-line a)
			       (stack-entry-function a)
			       (nice-stack-args (stack-entry-args a)))))
	     (reverse *saved-stack-trace*)))

(define (print-stack-trace-html)
   (unless (null? *stack-trace*)
      (print "Stack trace:<br />\n")
      (for-each (lambda (a)
		   (print (format "File ~a line ~a: ~a~a"
				  (stack-entry-file a)
				  (stack-entry-line a)
				  (stack-entry-function a)
				  (nice-stack-args (stack-entry-args a)))
			  "<br />\n"))
		(reverse *saved-stack-trace*))))

(define *delayed-errors* '())

;; commandline.scm will set these according to the user's wishes.
;; They affect code generation in generate.scm, and the behavior of
;; the builtins.
(define *track-stack?* #t)


(define delayed-error
   (let ((errors-seen (make-hashtable)))
      (lambda (msg)
	 (unless (hashtable-get errors-seen msg)
	    (hashtable-put! errors-seen msg #t)
	    (pushf msg *delayed-errors*)))))

(define (handle-delayed-errors)
   (if (pair? *delayed-errors*)
       (begin
	  (for-each
	   (lambda (err)
	      (fprint (current-error-port) "Error: " err))
		    *delayed-errors*)
	  (set! *delayed-errors* '())
	  #t)
       #f))


(define (reset-errors!)
   (set! *errors-disabled* #f)
   (set! *error-handler* "_default_error_handler")
   (set! *error-level* E_ALL)
   (set! *stack-trace* '())
   (set! *saved-stack-trace* '()))

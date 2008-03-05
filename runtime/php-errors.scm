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
   (extern
    (export *debug-level* "pcc_debug_level"))    
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
    *debug-level*    
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
     E_STRICT
     E_RECOVERABLE_ERROR
     E_ALL
     ;
    (debug-trace level . rest)     
    (init-php-error-lib)
    (push-stack class-name name . args)
    (pop-stack)
    (get-stack-caller-file)
    (get-stack-caller-line)
    (print-stack-trace)
    (print-stack-trace-html)
    (push-try-stack class-list exception)
    (pop-try-stack)
    delayed-error
    (php-exception except-obj)
    (php-error . msgs)
    (php-throw-builtin-exception msg)
    (php-recoverable-error . msgs)
    (php-warning . msgs)
    (php-notice . msgs)
    (dump-bigloo-stack port num)
    (handle-delayed-errors)
    (handle-runtime-error escape proc msg obj)
    (reset-errors!)))


; are we compiling or runtime?
; current determines how we print errors
(define *compile-mode?* #f)

;; it can be confusing that actually quite a bit of code gets executed
;; before commandline.scm or driver.scm has setup the *debug-level*.
;; We could set this to e.g. 'too-early, to make such bugs more
;; obvious, but that breaks a lot of code that calls debug-trace both
;; too-early and late enough.  Hmm.. what to do?
(define *debug-level* 0)


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
(defconstant E_STRICT 2048)
(defconstant E_RECOVERABLE_ERROR 4096)
(defconstant E_ALL 8191)

; implementations found in ext/standard/php-core.scm
(define *error-handler* "_default_error_handler")
(define *default-exception-handler* "_default_exception_handler")

(define *error-level* E_ALL)

(define *anti-error-recurse* #f)

;current stack of catch blocks to try a thrown exception on
(define *try-stack* '())

; called once at initialization
(define (init-php-error-lib)
   (set! *error-handler* "_default_error_handler")
   (set! *default-exception-handler* "_default_exception_handler")
   (set! *error-level* E_ALL)
   (set! *anti-error-recurse* #f))

; try-stack is a list of pairs: (classname_list . <exception proc>)
; we traverse the list, and the list of classes for each exception, checking Classname's for is-a match
;
; note the first dimension list relates to nested try's, the second (classname_list) relates to number of
; catch blocks for that try. we have to traverse both lists
;
; if we find it, we call the associated exception proc
; if we don't we handle it via the default exception handler
(define (push-try-stack class-list exception)
   (set! *try-stack* (cons (cons class-list exception) *try-stack*)))
   
(define (pop-try-stack)
   (when (pair? *try-stack*)
      (set! *try-stack* (cdr *try-stack*))))

(define *in-default-exception-handler* #f)
(define (php-exception except-obj)
    (if (null? *try-stack*)
	(if *in-default-exception-handler*
	    (php-error "Exception thrown without a stack frame")
	    (dynamically-bind (*in-default-exception-handler* #t)
		(php-funcall *default-exception-handler* except-obj)))
	(bind-exit (excepted)
	   (let stack-loop ((stack-list *try-stack*))
	      (when (pair? stack-list)
		 (let ((stack-entry (car stack-list)))
		    (let ((class-list (car stack-entry))
			  (exception-proc (cdr stack-entry)))
		       (let class-loop ((class-list-run class-list))
			  (when (pair? class-list-run)
			     (let ((class-name (car class-list-run)))
				(when (php-object-is-a (maybe-unbox except-obj) (mkstr class-name))
				   (exception-proc (cons class-name except-obj))
				   (excepted #t)))
			     (class-loop (cdr class-list-run)))))
		    (stack-loop (cdr stack-list)))))
	   ; if we get here, we had a try stack but didn't catch anything, so go to default handler
	   (php-funcall *default-exception-handler* except-obj))))
	   

; the runtime uses this to throw catchable errors
(define (php-throw-builtin-exception msg)
   (let ((except-obj (construct-php-object 'Exception msg)))
      (php-exception except-obj)))

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

(define (php-recoverable-error . msgs)
   (php-warning/notice (apply mkstr msgs) E_RECOVERABLE_ERROR))   

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
   (if (getenv "PCC_NO_RUNTIME_ERROR_HANDLER")
       ; this sticks with bigloo error handler, for those strange bigloo errors that crop up
       (error proc msg obj)
       ; this is out nice php runtime error handler
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
		     (begin
			(fprint (current-output-port)
				(with-output-to-string
				   (lambda ()
				      (print "\nFatal error: " msg " in " *PHP-FILE* " on line " *PHP-LINE*)
				      (when (> *debug-level* 0)
					 (print-stack-trace)))))
			(when (or (> *debug-level* 1) (getenv "BIGLOOSTACKDEPTH"))
			   (print "\n--- Bigloo Stack:\n")
			   (dump-bigloo-stack (current-output-port) (or (mkfixnum (getenv "BIGLOOSTACKDEPTH")) 10))
			   (print "\n")))
		     ; web mode, html
		     (begin
			(print "\n\n<br /><b>Fatal error:</b> " msg " in " *PHP-FILE* " on line " *PHP-LINE* "<br />")
			(print-stack-trace-html)
			(when (or (> *debug-level* 1) (getenv "BIGLOOSTACKDEPTH"))
			   (print "<pre>--- Bigloo Stack:\n")
			   (dump-bigloo-stack (current-output-port) 10)
			   (print "</pre>\n"))))
		 (escape #t))))))


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

;
; a way for functions and methods to peek at who called them without
; popping the stack
;
(define (get-stack-caller-file)
   (if (pair? *stack-trace*)
       (stack-entry-file (car *stack-trace*))
       "unknown"))

(define (get-stack-caller-line)
   (if (pair? *stack-trace*)
       (stack-entry-line (car *stack-trace*))
       0))

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
   (set! *default-exception-handler* "_default_exception_handler")   
   (set! *error-level* E_ALL)
   (set! *stack-trace* '())
   (set! *saved-stack-trace* '()))

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


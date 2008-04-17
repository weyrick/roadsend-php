;; ***** BEGIN LICENSE BLOCK *****
;; Roadsend PHP Compiler Runtime Libraries
;; Copyright (C) 2008 Roadsend, Inc.
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
(module core-builtins
   (library profiler)
   (include "php-runtime.sch")
   (load
    (php-macros "../php-macros.scm"))
   (use
    (signatures "signatures.scm")
    (php-object "php-object.scm")
    (php-runtime "php-runtime.scm")
    (php-hash "php-hash.scm")
    (php-errors "php-errors.scm"))
   (export
    (init-core-builtins)
    (_default_error_handler errno errstr errfile errline vars)
    (_default_exception_handler exception_obj)
    (php-exit status)
    ))

(define (init-core-builtins)
   (register-extension "runtime" "1.0.0" "php-runtime"))

(defbuiltin (_default_exception_handler exception_obj)
   (php-error "Uncaught exception '" (php-object-class exception_obj) "'"))

(defbuiltin (_default_error_handler errno errstr (errfile "unknown file") (errline "unknown line") (vars 'unset))
   (let ((etype (check-etype (mkfixnum (convert-to-number errno)))))
      ; if etype wasn't a string, we're not showing the message
      ; due to error reporting level
      (when (string? etype)	 
	 (if *commandline?*
	     (begin
		(echo (mkstr "\n" etype ": " errstr " in " errfile " on line " errline "\n"))
		(when (or (equalp errno E_USER_ERROR)
			  (equalp errno E_RECOVERABLE_ERROR)) ;XXX any others?
		   (php-exit 255)))
	     (begin
		(when (equalp errno E_USER_ERROR)
		   (print-stack-trace-html))
		(echo (mkstr "<br />\n<b>" etype "</b>: " errstr " in <b>" errfile "</b> on line <b>" errline "</b><br />\n"))
		(when (or (equalp errno E_USER_ERROR)
			  (equalp errno E_RECOVERABLE_ERROR)) ;XXX any others?
		   (php-exit 255)))))))
	  
(defalias die php-exit)
(defalias exit php-exit)
(defbuiltin (php-exit (status 0))
   (set! status (maybe-unbox status))
   (if *commandline?*
       (if (string? status)
	   (begin
	      (echo status)
	      (exit 0))
	   (exit (mkfixnum status)))
       (begin
	  (when (string? status)
             (echo status))
	  ;special error that'll be filtered out.
	  (error 'php-exit "exiting" 'php-exit))))

; based on current error level return either #f if we shouldn't
; show this error, or a string detailing the error type
(define (check-etype errno)
   ;(print "errno is " errno " and level is " (mkstr *error-level*))
   (if (or (php-= *error-level* E_ALL) 
	   (php-> (bitwise-and *error-level* errno) 0))
       (begin
	  (cond ((or (php-= errno E_USER_WARNING)
		     (php-= errno E_WARNING)) "Warning")
		
		;((or (php-= errno E_USER_ERROR)
		;     (php-= errno E_ERROR)) "Fatal error")
		((php-= errno E_USER_ERROR) "Fatal error")

		((php-= errno E_RECOVERABLE_ERROR) "Catchable fatal error")
		
		((or (php-= errno E_USER_NOTICE)
		     (php-= errno E_NOTICE)) "Notice")

		(else "Unknown error")))
       ; they don't want to see this error
       ; based on error-level
       #f))


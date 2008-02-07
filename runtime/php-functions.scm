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
(module php-functions
   (include "php-runtime.sch")   
   (import
    (php-hash "php-hash.scm")
    (utils "utils.scm")    
    (php-object "php-object.scm")    
    (signatures "signatures.scm")
    (constants "constants.scm")
    (php-types "php-types.scm")
    (php-operators "php-operators.scm")    
    (rt-containers "containers.scm")    
    (php-errors "php-errors.scm"))
   (export
    *interpreted-function-table*    
    (reset-functions!)
    (php-funcall call-name . call-args)
    (php-callback-call callback . arglist)
    (php-get-funcall-handle call-name call-arity)
    (php-funcall/handle handle::struct call-args)
    *func-args-stack*
    (push-func-args list-of-arguments)
    (pop-func-args)))

;this table contains the closures for interpreted functions 
(define *interpreted-function-table* (make-hashtable))

(define (reset-functions!)
   (unless (=fx (hashtable-size *interpreted-function-table*) 0)
      (set! *interpreted-function-table* (make-hashtable))))

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
      (empty-hash (make-php-hash))
      ((quote ?FOO) FOO)
      ((lookup-constant ?CONST) (lookup-constant (mkstr CONST)))
      ((lookup-class-constant ?CLASS ?CONST) (lookup-class-constant (mkstr CLASS) (mkstr CONST)))
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
	  
;;;;variable arity user function stuff, see also php-core.scm
(define *func-args-stack* '())

(define (push-func-args list-of-arguments)
   (pushf list-of-arguments *func-args-stack*))

(define (pop-func-args)
   [assert (*func-args-stack*) (not (null? *func-args-stack*))]
   (popf *func-args-stack*))


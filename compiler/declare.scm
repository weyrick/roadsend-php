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


;;;;run over AST(s) and make sure that everything is declared, as
;;;;well as widen!ed to have room for whatever else might need to be
;;;;added in later passes.
(module declare
   (include "php-runtime.sch")
   (library php-runtime)
   (import (ast "ast.scm")
           (target "target.scm"))
   (export
    *class-decl-table*
    *function->ast-table* 
    (generic declare node parent k)
    (generic parameter-default-value-value node)
    (compile-time-subclass? sub super)    
    (store-ast-signature aliased-name variable-arity? location decl-args)
    (ensure-extension-will-load sig)
    (wide-class function-decl/gen::function-decl
       (variable-arity? (default #f))
       (toplevel? (default #f))       
       canonical-name
       symbol-table
       container-table
       static-vars
       (needs-env? (default #f))
       (needs-return? (default #f))
       (variable-names (default '())))
    
    (wide-class var/gen::var
       ;containers.scm
       (cont? (default #f))       
       ;see cfa.scm for some insight into these
       ;       (needs-copy? (default #t))
       (type (default #f))
       (want-type (default #f)))

    ;the string ports are variables on the lhs of assigning-string-cats
    ;that should be replaced by a port for the duration of the loop.
    (wide-class for-loop/gen::for-loop
       (needs-break? (default #f))
       (needs-continue? (default #f))
       (string-ports (default '())))

    (wide-class while-loop/gen::while-loop
       (needs-break? (default #f))
       (needs-continue? (default #f))
       (string-ports (default '())))
    
    (wide-class foreach-loop/gen::foreach-loop
       (needs-break? (default #f))
       (needs-continue? (default #f))
       (string-ports (default '())))
    
    (wide-class do-loop/gen::do-loop
       (needs-break? (default #f))
       (needs-continue? (default #f))
       (string-ports (default '())))

    (wide-class switch-stmt/gen::switch-stmt
       (needs-break? (default #f))
       (needs-continue? (default #f)))

    (wide-class assigning-string-cat/gen::assigning-string-cat
       (lhs-is-output-port? (default #f)))

    (wide-class assignment/gen::assignment
       (lhs-is-output-port? (default #f)))
    
    (wide-class method-decl/gen::method-decl
       (variable-arity? (default #f))
       canonical-name       
       symbol-table
       container-table
       static-vars
       (needs-env? (default #f))
       (needs-return? (default #f))
       (variable-names (default '())))
    
    (wide-class php-ast/gen::php-ast
       global-symbol-table
       container-table
       (needs-return? (default #f)))
    
    (wide-class return-stmt/gen::return-stmt
       (cont? (default #f))
       (type (default #f)))

    
    (wide-class static-decl/gen::static-decl
       (cont? (default #f))
       (type (default #f)))

    
    (wide-class required-formal-param/gen::required-formal-param
       (cont? (default #f))
       (needs-copy? (default #t))
       (type (default #f)))

    (wide-class optional-formal-param/gen::optional-formal-param
       (cont? (default #f))
       (needs-copy? (default #t))
       (type (default #f)))

    
    (wide-class class-decl/gen::class-decl
       canonical-name
       (rendered? (default #f))
       methods
       properties
       static-properties
       class-constants)

    (wide-class property-decl/gen::property-decl
       index)

    (wide-class function-invoke/gen::function-invoke
       (dastardly? (default #f)))))

; ;; extensions that must be loaded.  driver.scm will use this to ensure
; ;; that they are loaded by the compiled program.
; (define *required-extensions* '())

(define *current-block* 'unset)
(define *class-decl-table* (make-php-hash))

;; note that these names have to be post-canonicalization!  That means
;; that if something is an alias (e.g. include()), the real name
;; should be here, not the alias.
(define *builtins-requiring-variable-env*
   '(get_defined_vars php-include php-require include_once
     require_once extract parse_str php-eval))
(define *builtins-implying-variable-arity*
   '(func_get_arg func_get_args func_num_args))

;a table mapping functions to their ASTs, used when
;compiling libraries, to determine which modules to import
(define *function->ast-table* (make-hashtable))

;;;;declare
(define-generic (declare node parent k)
   (k) )

(define-method (declare node::php-ast parent k)
   (widen!::php-ast/gen node
      (global-symbol-table (make-hashtable))
      (container-table (make-hashtable)))
   (dynamically-bind (*current-block* node)
      ;   (set! *current-file* (string->symbol (php-ast)))
      ;   (set! *current-module* (string->symbol (php-ast-module node)))
      (set! *current-ast* node)
      (k)))

(define-method (declare node::return-stmt parent k)
   (widen!::return-stmt/gen node)
   (cond
      ((function-decl/gen? *current-block*)
       (function-decl/gen-needs-return?-set! *current-block* #t))
      ((method-decl/gen? *current-block*)
       (method-decl/gen-needs-return?-set! *current-block* #t))
      ((php-ast/gen? *current-block*)
       (php-ast/gen-needs-return?-set! *current-block* #t))
      (else (error 'a *current-block* 'c)))
   (k))


(define-method (declare node::var parent k)
   (widen!::var/gen node)
   (add-variable-name! (var-name node))
   (k))

(define (add-variable-name! name)
   ;; the list of variable names in method-decls and function-decls is
   ;; currently only used for refresh-lexicals in generate.scm.  This is
   ;; due to the historical development of things -- declare.scm is much
   ;; newer than generate.scm.  Eventually, the declarative stuff should
   ;; be moved out of generate.scm to here.
   (cond ((function-decl/gen? *current-block*)
	  (function-decl/gen-variable-names-set!
	   *current-block*
	   (lset-union! eqv? (function-decl/gen-variable-names *current-block*)
			(list name))))
	 ((method-decl/gen? *current-block*)
	  (method-decl/gen-variable-names-set!
	   *current-block*
	   (lset-union! eqv? (method-decl/gen-variable-names *current-block*)
			(list name))))))


(define-method (declare node::var-var parent k)
   ;set the var-var-used? 
   (cond
      ((function-decl/gen? *current-block*)
       (function-decl/gen-needs-env?-set! *current-block* #t)
       )
      ((method-decl/gen? *current-block*)
       (method-decl/gen-needs-env?-set! *current-block* #t)
       ))
   (k))
   

(define-method (declare node::required-formal-param parent k)
   (widen!::required-formal-param/gen node)
   (k))

(define-method (declare node::optional-formal-param parent k)
   (widen!::optional-formal-param/gen node)
   (k))

;;all the loops that we're in, so we can mark that they use
;;continue or break
(define *current-loops* '())

(define-method (declare node::for-loop parent k)
   (widen!::for-loop/gen node)
   (dynamically-bind (*current-loops* (cons node *current-loops*))
      (k)))

(define-method (declare node::foreach-loop parent k)
   (widen!::foreach-loop/gen node)
   (dynamically-bind (*current-loops* (cons node *current-loops*))
      (k)))

(define-method (declare node::while-loop parent k)
   (widen!::while-loop/gen node)
   (dynamically-bind (*current-loops* (cons node *current-loops*))
      (k)))

(define-method (declare node::do-loop parent k)
   (widen!::do-loop/gen node)
   (dynamically-bind (*current-loops* (cons node *current-loops*))
      (k)))

(define-method (declare node::switch-stmt parent k)
   (widen!::switch-stmt/gen node)
   (dynamically-bind (*current-loops* (cons node *current-loops*))
      (k)))

(define-method (declare node::continue-stmt parent k)
   (for-each (lambda (l)
		(cond
		   ((for-loop/gen? l) (for-loop/gen-needs-continue?-set! l #t))
		   ((do-loop/gen? l) (do-loop/gen-needs-continue?-set! l #t))
		   ((while-loop/gen? l) (while-loop/gen-needs-continue?-set! l #t))
		   ((foreach-loop/gen? l) (foreach-loop/gen-needs-continue?-set! l #t))
		   ((switch-stmt/gen? l) (switch-stmt/gen-needs-continue?-set! l #t))
		   (else (error 'declare-continue "not a loop" l))))
	     *current-loops*)
   (k))

(define-method (declare node::break-stmt parent k)
   (for-each (lambda (l)
		(cond
		   ((for-loop/gen? l) (for-loop/gen-needs-break?-set! l #t))
		   ((do-loop/gen? l) (do-loop/gen-needs-break?-set! l #t))
		   ((while-loop/gen? l) (while-loop/gen-needs-break?-set! l #t))
		   ((foreach-loop/gen? l) (foreach-loop/gen-needs-break?-set! l #t))
		   ((switch-stmt/gen? l) (switch-stmt/gen-needs-break?-set! l #t))
		   (else (error 'declare-break "not a loop" l))))
	     *current-loops*)
   (k))

(define-method (declare node::assignment parent k)
   (widen!::assignment/gen node)
   (k))

(define-method (declare node::assigning-string-cat parent k)
   (widen!::assigning-string-cat/gen node)
   (k))
   
(define-method (declare node::static-decl parent k)
;   (print "declaring node" node ", current-block " *current-block*)
   (widen!::static-decl/gen node)
   (when (current-static-vars)
      (with-access::static-decl node (var initial-value)
         (hashtable-put! (current-static-vars) var initial-value)))
   (k))

(define (undollar str)
   (let ((str (mkstr str)))
      (string->symbol
       (if (char=? (string-ref str 0) #\$)
	   (substring str 1 (string-length str))
	   str))))

; (define-method (declare node::static-decl/cont k)
; ;   (print "declaring node" node ", current-block " *current-block*)
;    (with-access::static-decl node (var initial-value)
;       (hashtable-put! (current-static-vars) var `(make-container ,(get-value initial-value))))
;    (k))

(define-method (declare node::class-decl parent k)
   ;classes have to be declared so that we can do inheritance
   (with-access::class-decl node (name class-body)
      (let ((properties (make-php-hash))
	    (static-properties (make-php-hash))
            (class-constants (make-php-hash))
	    (methods (make-php-hash))
	    (indexes 0))
	 (letrec ((insert-methods-or-properties
		   (lambda (p)
		      (cond
			 ((list? p)
			  (for-each insert-methods-or-properties p))
                         ;; normal property
			 ((and (property-decl? p) (not (property-decl-static? p)))
			  (widen!::property-decl/gen p
			     (index indexes))
			  (set! indexes (+ indexes 1))
			   (php-hash-insert! properties (undollar (property-decl-name p)) p))
			 ;; PHP5 static property
			 ((and (property-decl? p) (property-decl-static? p))
			   (php-hash-insert! static-properties (undollar (property-decl-name p)) p))
                         ;; PHP5 class constants 
                         ((class-constant-decl? p)
                          (php-hash-insert! class-constants (class-constant-decl-name p) (class-constant-decl-value p)))
			 ((method-decl? p)
;			  (fprint (current-error-port) "Method: " (method-decl-name p))
			  (php-hash-insert! methods (method-decl-name p) p))
			 (else (error 'declare-class "what's this noise doing in my class-decl?" p))))))
	    (insert-methods-or-properties class-body))
	 (let ((canonical-name (symbol-downcase name)))
	    (php-hash-insert! *class-decl-table* canonical-name
			    (widen!::class-decl/gen node
			       (canonical-name canonical-name)
			       (properties properties)
			       (static-properties static-properties)
                               (class-constants class-constants)
			       (methods methods))))))
   (k))

(define (compile-time-subclass? sub super)
   ;;; XXX this needs to check more than just the syntactically
   ;;; apparent classes
   (let ((sub-class (php-hash-lookup *class-decl-table*
				     (symbol-downcase sub)))
	 (canon-super (symbol-downcase super)))
      (debug-trace 4 "compile-time-subclass?: sub: " sub ", super: " super ", nil-sub?: " (null? sub-class))
      (cond
	 ;; can't find the class
	 ((not (class-decl? sub-class))
	  (debug-trace 2 "warning (compile-time-subclass?): class " sub " not defined in time.")
	  #f)
	 ;; recursively check parent of the subclass
	 ((and (not (null? (class-decl-parent-list sub-class)))
	       (symbol? (car (class-decl-parent-list sub-class))))
	  (or (eqv? canon-super (symbol-downcase (car (class-decl-parent-list sub-class))))
	      (compile-time-subclass? (car (class-decl-parent-list sub-class)) super)))
	 ;; nope
	 (else #f))))

(define-method (declare node::method-decl parent k)
   (widen!::method-decl/gen node
      (canonical-name (symbol-downcase
		       (method-decl-name node)))
      (symbol-table (make-hashtable))
      (container-table (make-hashtable))
      (static-vars (make-hashtable)))
   (dynamically-bind (*current-block* node)
      (k)))


(define-method (declare node::function-decl parent k)
   ;functions have to be declared so that we can tell what their parameters are
   (let ((canonical-name
	  (function-name-canonicalize (function-decl-name node))))      
      (widen!::function-decl/gen node
	 (canonical-name canonical-name)
	 (symbol-table (make-hashtable))
	 (container-table (make-hashtable))
	 (static-vars (make-hashtable))))
   (with-access::function-decl/gen node
	 (location toplevel? variable-arity? canonical-name name decl-arglist body ref?)
      (dynamically-bind (*current-block* node)
	 (k))
      ;non-toplevel functions and library functions are not declared
      ;at compile time, since they might never be declared at run
      ;time.  Unfortunately, this means that calls to such functions
      ;will not be rendered as inline calls.
      (when (and (php-ast? parent)); (not *library-mode?*))
	 ;;library mode functions can still be "toplevel", even though
	 ;;they aren't declared at compile time.
	 (set! toplevel? #t)
	 (unless *library-mode?*
	    (when (get-php-function-sig canonical-name)
	       (delayed-error/loc node (format "declare-function-decl: Illegal redefinition of function ~A" name)))
	    (let ((aliased-name (autoalias canonical-name)))
	       (when (needs-alias? canonical-name)
		  (store-alias canonical-name aliased-name))
	       (store-ast-signature aliased-name variable-arity? location decl-arglist)
	       (hashtable-put! *function->ast-table* aliased-name *current-ast*)) )) ))

(define-method (declare node::function-invoke parent k)   
   (widen!::function-invoke/gen node)
   (with-access::function-invoke/gen node (name dastardly?)      
      (when (symbol? name)
	 (let ((canon-name (function-name-canonicalize name)))            
            (ensure-extension-will-load (get-php-function-sig canon-name))
	    (when (memv canon-name *builtins-implying-variable-arity*)
	       (cond
		  ((function-decl? *current-block*)
		   (function-decl/gen-variable-arity?-set! *current-block* #t))
		  ((method-decl? *current-block*)
		   (method-decl/gen-variable-arity?-set! *current-block* #t))
		  (else
		   ;;we error out because calling func_get_args outside of a function
		   ;;will potentially give you the arguments for some random function,
		   ;;which is not what we want...
		   (delayed-error/loc node (format "~A won't work in global scope" name)))))
	    (if (memv canon-name *builtins-requiring-variable-env*)
		(begin
		   (debug-trace 4 "(declare): " canon-name " requires a variable env ")
		   (set! dastardly? #t)
		   (cond
		      ((function-decl? *current-block*)
		       (function-decl/gen-needs-env?-set! *current-block* #t))
		      ((method-decl? *current-block*)
		       (method-decl/gen-needs-env?-set! *current-block* #t))))
		(debug-trace 4 "(declare): " canon-name " does not require a variable env")))))
   (k))

(define-method (declare node::exit-stmt parent k)
   (ensure-extension-will-load
    (get-php-function-sig
     (function-name-canonicalize 'exit)))
   (k))


(define (current-static-vars)
   (cond
      ((function-decl/gen? *current-block*)
       (function-decl/gen-static-vars *current-block*))
      ((method-decl/gen? *current-block*)
       (method-decl/gen-static-vars *current-block*))
      ((php-ast/gen? *current-block*) #f)
      (else (error 'current-static-vars "something is screwed" *current-block*))))


;; parameter-default-value-value sort of evaluates the
;; default values half-way.  they will then be digested by
;; php-funcall when a function call is made.  That way things
;; like constants have a chance to get setup.
(define-generic (parameter-default-value-value node)
   (delayed-error/loc node "Illegal default value for parameter"))

(define-method (parameter-default-value-value node::php-constant)
   (with-access::php-constant node (name)
      `(lookup-constant ,(mkstr name))))

(define-method (parameter-default-value-value node::lyteral)
   (lyteral-value node))

(define-method (parameter-default-value-value node::literal-string)
   (mkstr (lyteral-value node)))

(define-method (parameter-default-value-value node::literal-null)
   ''())

(define-method (parameter-default-value-value node::literal-integer)
   `(convert-to-number ,(lyteral-value node)))

(define-method (parameter-default-value-value node::literal-float)
   `(convert-to-number ,(lyteral-value node)))

(define-method (parameter-default-value-value node::arithmetic-unop)
   (with-access::arithmetic-unop node (op a)
      (ecase op
	 ((php-+) `(convert-to-number ,(parameter-default-value-value a)))
	 ((php--) `(php-- *zero* ,(parameter-default-value-value a))))))


(define-method (parameter-default-value-value node::literal-array)
   (with-access::literal-array node (array-contents)
      (let ((new-hash (gensym 'newhash)))
	 `(let ((,new-hash (make-php-hash)))
	     ,@(map
		(lambda (a)
		   (with-access::array-entry a (key value ref?)
		      `(php-hash-insert! ,new-hash
					 ,(if (eqv? key :next)
					      ':next
					      (parameter-default-value-value key))
					 ,(if ref?
					      (maybe-box (parameter-default-value-value value))
					      (maybe-unbox (parameter-default-value-value value))))))
		array-contents)
	     ,new-hash))))


(define (store-ast-signature aliased-name variable-arity? location decl-args)
   (let ((maximum-arity (length decl-args))
	 (minimum-arity 0)
	 (brief-params '()))
      (map (lambda (a)
	      (if (required-formal-param? a)
		  (with-access::required-formal-param a (name ref?)
		     (set! minimum-arity (+fx minimum-arity 1))
		     (set! brief-params
			   (cons* (if ref? t-reference t-required)
				  name 0 brief-params)))
		  (with-access::optional-formal-param a (name default-value ref?)
		     (set! brief-params
			   (cons* (if ref? t-optional-reference t-optional)
				  name
				  (parameter-default-value-value default-value)
				  brief-params)))))
	   (reverse decl-args))
      ;      (fprint (current-error-port) "jjj: stored " aliased-name)
      (apply store-signature #f ft-user location aliased-name minimum-arity
	     (if variable-arity? -1 maximum-arity) brief-params)))


(define (ensure-extension-will-load sig)
   ;(debug-trace 0 "sig is " sig " signature extension is " (get-signature-extension sig))
   (when (and sig (get-signature-extension sig))
      (require-extension (get-signature-extension sig))))

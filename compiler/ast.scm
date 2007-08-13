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
(module ast
   (library php-runtime)
   (include "php-runtime.sch")
   (export
    (generic node-return-type node)
    *parse-loc*
    *library-mode?*
    ;; autoaliasing
    ; used by generate and declare 
    *current-ast*
    (needs-alias? name::symbol)
    (autoalias name::symbol)
    (ast-node->brief-string node)
    (warning/loc node::ast-node msg)
    (delayed-error/loc node::ast-node msg)
    (php-error/loc node::ast-node msg)
    *ast-print-depth*
    *ast-print-brief*
    *ast-brief-omit*
    (finish-ast nodes)
    (print-pretty-ast php-ast)
    (walk-ast php-ast thunk)
    (walk-ast/parent php-ast thunk)
    (types-eqv? t1 t2)
    (parse-require-php5)
    (final-class php-ast 
       original-filename ;the filename as given to us by the user
       real-filename ;the filename as given to us by realpath
       project-relative-filename ;the filename relative to the project path (pcc's cwd at the moment)
       program-name ;our program/library name
       import-asts ;asts that we import (include or import in the module header)
       nodes) ;the ast

    (class ast-node
       location)

    
    (final-class unset-stmt::ast-node
       lvals)
    (final-class if-stmt::ast-node
       condition
       then
       else)
    (final-class switch-stmt::ast-node
       rval
       cases)
    (final-class while-loop::ast-node
       condition
       body)
    (final-class do-loop::ast-node
       condition
       body)
    (final-class foreach-loop::ast-node
       array
       key
       value
       body)
    (final-class break-stmt::ast-node
       level)
    (final-class continue-stmt::ast-node
       level)
    (final-class return-stmt::ast-node
       value)
    (final-class exit-stmt::ast-node
       rval)
    (final-class echo-stmt::ast-node
       stuff)
    (final-class nop::ast-node
       )
    (final-class switch-case::ast-node
       val
       body)
    (final-class default-switch-case::ast-node
       body)
    (final-class for-loop::ast-node
       init
       condition
       step
       body)

    (abstract-class declaration::ast-node)
    (final-class constant-decl::declaration
       name
       value
       insensitive?)
    (final-class class-decl::declaration
       name
       parent
       class-body
       end-line) ;;the last line of the class
    (final-class property-decl::declaration
       name
       value
       static?
       visibility)
    (final-class method-decl::declaration
       name
       decl-arglist
       body
       ref?
       end-line) ;;the last line of the method
    (final-class function-decl::declaration
       name
       decl-arglist
       body
       ref?
       end-line) ;;the last line of the function
    (final-class global-decl::declaration
       var)
    (final-class static-decl::declaration
       var
       initial-value)
    
    (final-class parent-method-invoke::ast-node
       name
       arglist)
    

    (abstract-class formal-param::ast-node
       name
       ref?)
    (final-class required-formal-param::formal-param)
    (final-class optional-formal-param::formal-param default-value)
    
    
    
    (final-class literal-array::ast-node
       array-contents)
    (final-class array-entry::ast-node
       key
       value
       ref?)
    (final-class php-constant::ast-node
       name)
    (final-class disable-errors::ast-node
       body)
    (final-class function-invoke::ast-node
       name
       arglist)
    (final-class assignment::ast-node
       lval
       rval)
    (final-class reference-assignment::ast-node
       lval
       rval)
    (final-class list-assignment::ast-node
       lvals
       rval)
    (final-class typecast::ast-node
       typecast
       rval)

    (abstract-class boolean-op::ast-node
       op
       p
       q)

    (final-class boolean-and::boolean-op)
    (final-class boolean-or::boolean-op)
    (final-class boolean-xor::boolean-op)

    (final-class comparator::boolean-op)

    (final-class boolean-not::ast-node
       p)
    
    (final-class method-invoke::ast-node
       method
       arglist)
    (final-class static-method-invoke::ast-node
       class-name
       method
       arglist)
    (final-class constructor-invoke::ast-node
       class-name
       arglist)
    (final-class arithmetic-op::ast-node
       op
       a
       b)
    (final-class arithmetic-unop::ast-node
       op
       a)
    (final-class bitwise-op::ast-node
       op
       a
       b)
    (final-class bitwise-not-op::ast-node
       a)
    (final-class string-cat::ast-node
       a
       b)
    (final-class assigning-arithmetic-op::ast-node
       op
       lval
       rval)
    (final-class assigning-string-cat::ast-node
       lval
       rval)
    (final-class precrement::ast-node
       crement
       lval)
    (final-class postcrement::ast-node
       crement
       lval)

    ;XXX rename this to literal when variables.scm is out of the picture
    (class lyteral::ast-node
       value)
    (final-class literal-null::lyteral)
    (final-class literal-string::lyteral)
    (final-class literal-boolean::lyteral)
    (final-class literal-integer::lyteral)
    (final-class literal-float::lyteral)
    
    (final-class property-fetch::ast-node
       obj
       prop)

      ;; no more string-chars because there is no way to
      ;; syntactically distinguish them from array-refs.
      ;; See bug 1938. --tpd 5.7.2004 
;     (final-class string-char::ast-node
;        str
;        pos)
    
    (final-class var-var::ast-node
       lval)
;    (final-class global-hash-lookup::ast-node
;       key)
;    (final-class global-hash-var::ast-node)
    (final-class var::ast-node
       name)
    (final-class hash-lookup::ast-node
       hash
       key)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    ;; new PHP5 stuff
    (final-class class-constant::ast-node
       class
       name)))

(define *parse-loc* '("unknown line" . "unknown file"))

;are we currently compiling a library?
(define *library-mode?* #f)

;;some dummy::ast-node ast routines
(define (finish-ast nodes)
   (make-php-ast "unknown"
		 (if (and (pair? nodes)
			  (ast-node? (car nodes)))
		     (cdr (ast-node-location (car nodes)))
		     "unknown")
		 "unknown"
		 "unknown"
		 '()
		 nodes))

(define (print-pretty-ast php-ast)
   (if (or (php-ast? php-ast) (ast-node? php-ast))
;;        (display-circle (ast->list-of-symbols php-ast 0))
;;        (display-circle php-ast))
       (pp (ast->list-of-symbols php-ast 0))
       (pp php-ast))
   (newline))

(define *ast-print-depth* -1)

(define *ast-print-brief* #f)

(define *ast-brief-omit*
   '(methods class-body properties body))
(define (ast->list-of-symbols php-ast depth)
      (cond
	 ((list? php-ast)
	  (map (lambda (a) (ast->list-of-symbols a (+ depth 1))) php-ast))
	 ((object? php-ast)
	  (let ((the-class (object-class php-ast)))
	     (cons (string->symbol (string-upcase (symbol->string (class-name the-class))))
		   (if (= depth *ast-print-depth*)
		       '(...)
		       (map (lambda (field)
			       (list (symbol-append (class-field-name field) ':)
				     (ast->list-of-symbols ((class-field-accessor field) php-ast) (+ depth 1))))
			    (filter (lambda (a)
				       ;				   (print "the name: " (class-field-name a))
				       (not (and *ast-print-brief*
						 (member (class-field-name a) *ast-brief-omit*))))
				    (class-all-fields the-class)))))))
	 ;structs could be (and often are) circular
	 ((struct? php-ast) 'struct)
	 (else php-ast)))


(define (walk-ast php-ast thunk)
   (letrec ((walker
	     (lambda (php-ast)		
		(cond
		   ((list? php-ast)
		    (for-each walker php-ast))
		   ((or (ast-node? php-ast) (php-ast? php-ast))
; 		    (fprint (current-error-port)
; 			(if (wide-object? php-ast)
; 			    "Wide object of class: "
; 			    "Object of class: ")
; 			(object-class php-ast)
; 			", super-class: "
; 			(class-super (object-class php-ast)))
		    ;XXX note: wide fields are not walked.
		    (let ((the-class (if (wide-object? php-ast)
					 (class-super (object-class php-ast))
					 (object-class php-ast))))
		       (thunk php-ast
			      (lambda ()
				 (for-each (lambda (field)
					      (walker
					       ((class-field-accessor field) php-ast)))
					   (class-all-fields the-class))))))
		   (else #t)))))
      (walker php-ast)))

(define (walk-ast/parent php-ast thunk)
   "walk ast calling thunk. Thunk takes three args -- node, parent, and k."
   (letrec ((walker
	     (lambda (php-ast parent)
		(cond
		   ((list? php-ast)
		    (for-each (lambda (a) (walker a parent)) php-ast))
		   ((or (ast-node? php-ast) (php-ast? php-ast))
		    (let ((the-class (if (wide-object? php-ast)
					 (class-super (object-class php-ast))
					 (object-class php-ast))))
		       (thunk php-ast
			      parent
			      (lambda ()
				 (for-each (lambda (field)
					      (walker
					       ((class-field-accessor field) php-ast)
					       php-ast))
					   (class-all-fields the-class))))))
		   (else #t)))))
      (walker php-ast #f)))



   
	
(define (delayed-error/loc node::ast-node msg)
   (let ((line (car (ast-node-location node)))
	 (file (ast-node-file-sans-pwd node)))
      (if *RAVEN-DEVEL-BUILD*
	  (delayed-error (format "in ~A line ~A: ~A~%ast-node: ~A~%"
				 file line msg (ast-node->brief-string node)))
	  (delayed-error (format "in ~A line ~A: ~A~%"
				 file line msg)))))

(define (php-error/loc node::ast-node msg)
   (let ((line (car (ast-node-location node)))
	 (file (ast-node-file-sans-pwd node)))
      (if *RAVEN-DEVEL-BUILD*
	  (error 'compile-error 
		 (format "Error: in ~A line ~A: ~A~%ast-node: ~A~%"
			 file line msg (ast-node->brief-string node))
		 'compile-error)
	  (error 'compile-error 
		 (format "Error: in ~A line ~A: ~A~%"
			 file line msg)
		 'compile-error))))

(define (warning/loc node::ast-node msg)
   (let ((line (car (ast-node-location node)))
	 (file (ast-node-file-sans-pwd node)))
      (if *RAVEN-DEVEL-BUILD*
	  (php-warning (format "Warning: in ~A line ~A: ~A~%ast-node: ~A~%"
			       file line msg (ast-node->brief-string node)))
	  (php-warning (format "Warning: in ~A line ~A: ~A~%"
			       file line msg)))))


(define (ast-node->brief-string node)
   (with-output-to-string 
      (lambda ()
	 (if (ast-node? node)
	     (dynamically-bind (*ast-print-depth* 3)
		(dynamically-bind (*ast-print-brief* #t)
		   (print-pretty-ast node)))))))

(define (ast-node-file-sans-pwd node)
   (let ((file (cdr (ast-node-location node))))
      (if (substring=? file (pwd) (string-length (pwd)))
	  (substring file
		     (+ (string-length (pwd)) 1) ; + 1 for the trailing /
		     (string-length file))
	  file)))

(define-generic (node-return-type node)
   "Return an ast-node's return type when it's always the same"
   'any)

(define-method (node-return-type node::literal-array)
   'hash)

(define-method (node-return-type node::typecast)
   (ecase (typecast-typecast node)
      ((boolean) 'boolean)
      ((object) 'object)
      ((integer float) 'number)
      ((string) 'string)
      ((hash) 'hash)))

(define-method (node-return-type node::boolean-op)
   'boolean)

(define-method (node-return-type node::boolean-not)
   'boolean)

(define-method (node-return-type node::constructor-invoke)
   'object)

(define-method (node-return-type node::arithmetic-op)
   'number)

(define-method (node-return-type node::arithmetic-unop)
   'number)

(define-method (node-return-type node::bitwise-op)
   'number)

(define-method (node-return-type node::bitwise-not-op)
   'number)

(define-method (node-return-type node::string-cat)
   'string)

(define-method (node-return-type node::assigning-arithmetic-op)
   'number)

(define-method (node-return-type node::assigning-string-cat)
   'string)

(define-method (node-return-type node::precrement)
   'number)

(define-method (node-return-type node::postcrement)
   'any)

(define-method (node-return-type node::lyteral)
   (cond
      ((literal-null? node) 'null)
      ((literal-string? node) 'string)
      ((or (literal-integer? node) (literal-float? node)) 'number)
      ((literal-boolean? node) 'boolean)
      (else (error 'lyteral-node-return-type
		   "the type inferencer needs work" node))))

; (define-method (node-return-type node::string-char)
;    'string)

;;;autoaliasing
(define *current-ast* 'unset)

(define (needs-alias? name::symbol)
   "does name conflict with a builtin symbol?"
   ;this is short-circuited for now, since apropos apparently doesn't see
   ;our names, and it's not worth the time to figure it out.
   #t)


(define (autoalias name::symbol)
   (if (needs-alias? name)
       (symbol-append (string->symbol (php-ast-program-name *current-ast*)) ':
		      (string->symbol (php-ast-original-filename *current-ast*)) '/ ;'/ since the file always ends in /
		      ;(symbol-downcase name)
		      name
		      )
       name))


(define (types-eqv? t1 t2)
   (unless (pair? t1) (set! t1 (list t1)))
   (unless (pair? t2) (set! t2 (list t2)))
   (if (and (member 'any t1)
	    (member 'any t2))
       ;;anything as well as anything else is the same as anything
       #t
       ;;otherwise they have to have the same components, but in any order
       (let ((flag #t))
	  (for-each (lambda (a)
		       (unless (member a t2)
			  (set! flag #f)))
		    t1)
	  (for-each (lambda (a)
		       (unless (member a t1)
			  (set! flag #f)))
		    t2)
	  flag)))

(define (parse-require-php5)
   ;; Check if PHP5 support is enabled, and if not fixup the runtime
   ;; line numbers so that the error message comes out right and throw
   ;; and error.
   (set! *PHP-FILE* (loc-file *parse-loc*))
   (set! *PHP-LINE* (loc-line *parse-loc*))
   ;(require-php5)
   (unless PHP5?
      (debug-trace 1 "PHP 5 syntax detected: version 5 language compatibility enabled")
      (go-php5)))
   



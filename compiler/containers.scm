;; ***** BEGIN LICENSE BLOCK *****
;; Roadsend PHP Compiler
;; Copyright (C) 2007-2008 Roadsend, Inc.
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

;;;; Container Analysis:
;;;; Determine which variables need to be stored in containers.
(module containers
   (include "php-runtime.sch")
   (library php-runtime)   
   (import (ast "ast.scm")
	   (declare "declare.scm"))

   (export
    (generic find-containers node k)))
    
;a variable is in a container if it is:
;  - in global scope
;  - a superglobal
;  - in a scope containing variable-variables
;  - on either side of a reference-assignment
;  - passed to a function in a reference parameter position
;  - returned from a function returning a reference
;  - exception variable in a catch block

;no other variable is in a container.

;we are in global scope if we're not inside a function or method decl

;that means we can discover references inside of:

;every variable not inside of a function-decl or method-decl
;function-invoke
;method-invoke
;return inside of function-decl or method-decl
;inside of a function-decl or method-decl when it contains a var-var
;reference-assignment
;variables in a global-decl

;only valid lvals can become containers
;variables can become containers, but cannot lose their container status.

;an lval can be a:
;  var
;  var-var
;  hash-lookup
;  property-fetch
;  global-hash-lookup
;  string-char can be an lval, but not the target of a reference

;for now, hash entries and properties are always in containers, so there it
;only matters on a per-instance basis, whether it should return a container
;or not. 

;we need to remember to box the non-reference arguments that are boxed vars

;this step seems to be better done on the ast than the cfg

;map function names onto decl-arglists
(define *reference-positions-table* (make-hashtable))



;the current function or method that we are in
(define *current-block* 'unset)

(define *changed* #t)

(define-generic (find-containers node k)
   (k))
;    (if (list? node)
;        (for-each find-containers node)
;        (error 'find-containers "don't know what to do with node" node)))
;        ;consider implementing something like this:
; ;       (walk node find-containers)))

(define-method (find-containers node::php-ast k)
   ;mark the ast as having been container-analyzed, and add a symbol table to it
;   (widen!::php-ast/cont node (global-container-table (make-hashtable)))
   ;process all of the nodes in the ast, until we reach a fixed-point
   (set! *changed* #t)
;   (set! *reference-positions-table* (make-hashtable))
   (let loop ()
      (when *changed*
;	 (print "going around once")
	 (set! *changed* #f)
	 (dynamically-bind (*current-block* node)
	    (k))
	 (loop)))
;   *containered*
;   (print "in the end, following were containered: " *containered*)
   )

(define-method (find-containers node::function-decl k)
   (unless (hashtable-get *reference-positions-table*
			  (function-name-canonicalize (function-decl-name node)))
      (let ((symtab (make-hashtable)))
	 ;      (widen!::function-decl/cont node (container-table symtab))
	 (hashtable-put! *reference-positions-table*
			 (function-name-canonicalize (function-decl-name node))
			 (function-decl-decl-arglist node))
	 (for-each
	  (lambda (param)
	     (when (formal-param-ref? param)
		(hashtable-put! symtab (formal-param-name param) #t)))
	  (function-decl-decl-arglist node))
	 (set! *changed* #t)))
   (dynamically-bind (*current-block* node)
      (k)))

(define-method (find-containers node::formal-param k)
   (with-access::formal-param node (name ref?)
      (cond
	 ;in this case, the param won't come in as a container, so it will need to be boxed
	 ((and (not ref?) (hashtable-get (current-symtab) name))
	  ;don't think we need the set *changed* here, because nothing here depends on this
	  (if (required-formal-param? node)
	      (required-formal-param/gen-cont?-set! node #t)
	      (optional-formal-param/gen-cont?-set! node #t)))
	 ;in this case, the param comes in as a container.
	 ((and ref? (not (hashtable-get (current-symtab) name)))
	  (hashtable-put! (current-symtab) name #t)
	  (set! *changed* #t)))
      (k)))


; (define-method (find-containers node::optional-formal-param/cont k)
;    (k))

; (define-method (find-containers node::required-formal-param/cont k)
;    (k))

(define-method (find-containers node::method-decl k)
   ;   (widen!::method-decl/cont node (container-table (make-hashtable)))
   (dynamically-bind (*current-block* node)

;       (hashtable-put! (current-symtab) '$this #t)
;       (set! *changed* #t)
      (k)))

; (define-method (find-containers node::function-decl/cont k)
;    (dynamically-bind (*current-block* node)
;       (k)))

; (define-method (find-containers node::method-decl/cont k)
;    (dynamically-bind (*current-block* node)
;       (k)))

(define-method (find-containers node::global-decl k)
   ;the weird thing about the global-decls is that their var is often just the name
   ;not sure if that's a good thing...
   (with-access::global-decl node (var)
      ;checking if it's already in the symtab prevents infinite loops due to *changed*
      (unless (or (not (symbol? var)) (hashtable-get (current-symtab) var))
	 (hashtable-put! (current-symtab) var #t)
	 (set! *changed* #t))
      (k)))

(define-method (find-containers node::static-decl k)
   (with-access::static-decl/gen node (var cont?)
      ;checking if it's already in the symtab prevents infinite loops due to *changed*
      (when (and (not cont?) (symbol? var) (hashtable-get (current-symtab) var))
	 (set! cont? #t)
	 (set! *changed* #t))
      (k)))

; (define-method (find-containers node::static-decl/cont k)
;    (k))


(define-method (find-containers node::var k)
   (when (or (hashtable-get (current-symtab) (var-name node))
	     (superglobal? (var-name node))
	     (within-var-var-block?))
;	     (eqv? '$this (var-name node)))

      
      ;if this is an identified container variable, or
      ;we are in a var-var containing block (in which case all
      ;variables contain var-vars)
      (containerize node))
   (k))

(define-generic (containerize node)
   #t)

;(define *containered* '())

(define-method (containerize node::var)
;   (widen!::var/cont node)
   (with-access::var/gen node (cont?)
      (unless cont?
	 (set! *changed* #t)
	 (set! cont? #t)
	 ;   (pushf (mkstr (block-name *current-block*) "." (var-name node)) *containered*)
	 (hashtable-put! (current-symtab) (var-name node) node) )))

; (define-method (containerize node::var/cont)
;    #t)


(define (block-name block)
   (cond
      ((function-decl? block)
       (function-decl-name block))
      ((method-decl? block)
       (method-decl-name block))
      ((php-ast? block) "global")
      (else (error 'a "b" 'c))))

(define-method (find-containers node::var-var k)
   ;note that the current function, if there is one, uses var-var
   ;unless we've already noted it.
   (cond
      ((and (function-decl/gen? *current-block*)
	    (not (function-decl/gen-needs-env? *current-block*)))
       (error 'find-containers "declare didn't do its job" node))
;       (function-decl/gen-needs-env?-set! *current-block* #t)
;       (set! *changed* #t))
      ((and (method-decl/gen? *current-block*)
	    (not (method-decl/gen-needs-env? *current-block*)))
       (error 'find-containers "declare didn't do its job1" node)))
;        (method-decl/gen-needs-env?-set! *current-block* #t)
;        (set! *changed* #t)))
   (k))
 

(define-method (find-containers node::function-invoke k)
   (with-access::function-invoke node (name arglist)
      (let ((arg-pos 0))
	 (dolist (arg arglist)
	    (when (argument-is-referenced? name arg-pos)
	       (containerize arg))
	    (set! arg-pos (+ arg-pos 1)))))
   (k))

(define-method (find-containers node::method-invoke k)
   ;too complex for the first try. overdo it.
   (with-access::method-invoke node (arglist)
      (dolist (arg arglist)	 
	 (containerize arg)))
   (k))

(define-method (find-containers node::try-catch k)
   (with-access::try-catch node (catches)
      (dolist (citem catches)	 
	 (containerize (catch-catch-var citem))))
   (k))

(define-method (find-containers node::return-stmt k)
   (when (current-block-returns-reference?)
      (return-stmt/gen-cont?-set! node #t)
      (containerize (return-stmt-value node)))
   (k))
      
(define-method (find-containers node::reference-assignment k)
   (with-access::reference-assignment node (lval rval)
      (containerize lval)
      (containerize rval))
   (k))


(define (current-block-returns-reference?)
   (or (and (function-decl? *current-block*)
	    (function-decl-ref? *current-block*))
       (and (method-decl? *current-block*)
	    (method-decl-ref? *current-block*))))
	   

(define (argument-is-referenced? function-name arg-pos)
   (if (ast-node? function-name)
       #t ;best we can do
       (let ((function-args (hashtable-get *reference-positions-table*
					   (function-name-canonicalize function-name))))
	  ;if the function is being compiled right now
	  (if (and function-args
		   (> (length function-args) arg-pos))
	      (let ((arg (list-ref function-args arg-pos)))
		 (or (and (sig-param? arg) (sig-param-ref? arg))
		     (and (formal-param? arg) (formal-param-ref? arg))))
	      ;if the function was compiled/is a builtin
	      ;note that the interpreter has its own table, and we're not checking it...
	      (let ((function-sig (get-php-function-sig function-name)))
		 (and function-sig
		      (> (sig-length function-sig) arg-pos)
		      (sig-param-ref? (sig-ref function-sig arg-pos))))))))
		 
; 	  (fprint (current-error-port)
; 		  "function name: " function-name
; 		  ", arg-pos: " arg-pos
; 		  ", function args: " function-args)
; 	  (and function-args
; 	       (> (length function-args) arg-pos)
; 	       ))))

(define (within-var-var-block?)
   (cond 
      ((php-ast/gen? *current-block*) #t)
      ((function-decl/gen? *current-block*)
       (function-decl/gen-needs-env? *current-block*))
      ((method-decl/gen? *current-block*)
       (method-decl/gen-needs-env? *current-block*))
      (else
       (error 'within-var-var-block? "current block is something illegal"
	      *current-block*))))


(define (current-symtab)
   (cond
      ((php-ast/gen? *current-block*)
       (php-ast/gen-container-table *current-block*))
      ((function-decl/gen? *current-block*)
       (function-decl/gen-container-table *current-block*))
      ((method-decl/gen? *current-block*)
       (method-decl/gen-container-table *current-block*))
      (else
       (error 'current-symtab "current block has no symbol table"
	      *current-block*))))

       

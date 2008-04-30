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


;;;; Control flow analysis of PHP
(module php-cfa
   (include "php-runtime.sch")
   (library php-runtime)
   (import (ast "ast.scm")
	   (declare "declare.scm")
	   (basic-blocks "basic-blocks.scm"))
   (export
    (cfa-annotate flow-segments)))

;;;; We basically want to run along and decorate the AST in such
;;;; a way that the compiler can generate better code from it.  

;; limit on the number of times to loop before giving up
(define *loop-limit* 1000)

(define *changed* #t)

(define (cfa-annotate flow-segments)
   (for-each (lambda (f)
		(debug-trace 6 "(allsegs) segment's first block: " (basic-block-i (flow-segment-start f))))
	     flow-segments)
		
   (for-each annotate-segment flow-segments))

(define *do-string-port-optimization* #t)

(define (change . reason)
   (apply debug-trace 22 "change: " reason)
   (set! *changed* #t))

(define (annotate-segment flow-segment)
   ;; this goes forwards, gathering type information.
   (propagate-types-forward flow-segment #t)
   ;; this goes backwards.  The result of this path determines how we'll
   ;; initialize the variables.
   (collect-first-types flow-segment)
   ;; based on the reality of how the variables are initialized, we run
   ;; forwards again.

   ;; we make a dummy block and put it before the start block, as a way of
   ;; priming the propagation with the new initial types.  This is a kludge.
   (let ((start-block (flow-segment-start flow-segment))
	 (dummy-block (instantiate::basic-block
			 (place-it-started 'dummy)
			 (i 'bad)
			 (symtab-so-far (node-symbol-table (flow-segment-node flow-segment)))
			 (last-defs (make-hashtable)))))
      (basic-block-pred-set! start-block (list dummy-block))
      (propagate-types-forward flow-segment #f)
      ;; delete the dummy block so it doesn't confuse anybody
      (basic-block-pred-set! start-block '())) )

(define (propagate-types-forward flow-segment initial?)
   (debug-trace 6 "one invocation of propagate-types-forward.  initial? is " initial? ", flow segment's first block is: "
		(basic-block-i (flow-segment-start flow-segment)))
   (with-access::flow-segment flow-segment (node start end)
      ;functions and methods that use variable-variables ($$foo) are
      ;too hard, so skip them.  global code is also too hard, so just
      ;analyze stuff inside functions and methods.
      (if (or (and (function-decl/gen? node)
		   (not (function-decl/gen-needs-env? node)))
	      (and (method-decl/gen? node)
		   (not (method-decl/gen-needs-env? node))))
	  (begin
	     (if (function-decl/gen? node)
		 (debug-trace 22 "in-depth flow function/decl location: " (ast-node-location node) ", name: " (function-decl-name node) )
		 (debug-trace 22 "in-depth flow function/decl location: " (ast-node-location node) ", name: " (method-decl-name node) ))
	     
	     ;; special optimization of string appends
	     ;; just do this the first time around.
	     (when (and *do-string-port-optimization* initial?)
		(maybe-replace-append-with-port node))
	     
	     ;	     (set! *changed* #t)
	     (change "initialized walk-flow-segment loop")
	     ;loop until fixed point is reached.
	     (let loop ((i 0))
		(when *changed*
		   (set! *changed* #f)
		   ;visit each block once and apply annotate-block to it.
		   ;this is complicated because the blocks are actually
		   ;linked in a graph (may contain cycles).
		   (walk-flow-segment flow-segment annotate-block)
		   (if (< i *loop-limit*)
		       (loop (+fx i 1))
		       (warning/loc node
				    "propagate-types-forward: Too much optimization -- giving up")))))
	  (begin
	     ;just run around and type everything "any" or "container" for
	     ;functions and methods that use var-vars and global code
	     (walk-flow-segment flow-segment
				(lambda (block)
				   (for-each
				    (lambda (v)
				       (when (var? v)
					  (with-access::var/gen v (cont? type location name)
					     (debug-trace 6 "setting simple type for " name " on " location)
					     (if cont?
						 (set! type 'container)
						 (set! type 'any)))))
				    (basic-block-code block))))))))

(define-generic (annotate-block block)
   (error 'annotate-block "what's this?" block))

(define *current-symtab* #f)
(define *last-defs* #f)

;turning string-appends into displays on a string port is only enabled
;when we are inside a loop, because otherwise it's probably not worth it.
(define *inside-a-loop?* #f)

(define-method (annotate-block block::basic-block)
   (with-access::basic-block block (symtab-so-far last-defs inside-a-loop? pred code)
      ;reset the symbol table
      (set! symtab-so-far (make-hashtable))
      (set! last-defs (make-hashtable))
      (dynamically-bind (*current-symtab* symtab-so-far)
	 (dynamically-bind (*inside-a-loop?* inside-a-loop?)
	    (dynamically-bind (*last-defs* last-defs)
	    ;merge in the symbols from predecessors
	    (for-each (lambda (b)
			 (hashtable-for-each (basic-block-symtab-so-far b)
			    unify-binding))
		      pred)
	    ;merge the last defs
	    (for-each (lambda (b)
			 (hashtable-for-each (basic-block-last-defs b)
			    (lambda (k v)
			       (let ((v1 (or (hashtable-get last-defs k) '())))
				  (hashtable-put! last-defs k (uniq (append v v1)))))))
		      pred)
	    ;abstractly interpret the code, updating the symbol table
	    (for-each abstract-interpret code))))))

(define-generic (abstract-interpret node)
   #t)

;;;;no longer valid -- lookups alone do not a hashtable make
(define-method (abstract-interpret node::hash-lookup)
   (with-access::hash-lookup node (hash)
      (when (var? hash)
	 (unify-binding (var-name hash) 'hash))))

;;;;only for assignments
(define (assign-hash-type node::hash-lookup)
   (with-access::hash-lookup node (hash)
      (when (var? hash)
;	 (debug-trace 3 "abstract-interpret: assigning hash type to var, location: " (ast-node-location hash))
	 ;whatever it was, it's a hash now...
	 
	 ;XXX except if it was a string!
	 ;this isn't correct, but it gives users an easy way out
	 (if (types-eqv? (get-binding (var-name hash)) 'string)
;	     (debug-trace 3 "abstract-interpret: actually not assigning hash type to var, location: " (ast-node-location hash))
	     (update-binding (var-name hash) 'hash)))))


;;;needs-copy?
;figure that a formal-param needs to be copied if there's
  ;a hash-lookup on the lhs of any assignment
  ;a reference taken of any hash-lookup
  ;property-fetch on the lhs of any assignment
  ;any property-fetch in a method-invoke
  ;a reference taken of any property-fetch

(define-method (abstract-interpret node::function-invoke)
   (with-access::function-invoke node (name arglist)
      (let ((sig (if (ast-node? name) #f (get-php-function-sig name))))
	 (if (or (ast-node? name)
		 (not sig))
	     (begin
		(debug-trace 6 "cfa: no signature available for function " name)
		(for-each set-needs-copy arglist))
	     (let loop ((i 0)
			(args (gcdr arglist))
			(arg (gcar arglist)))
		(unless (or (null? arg)
			    (try (sig-ref sig i) (lambda (e p m o) (e #f))))
		   (when (sig-param-ref? (sig-ref sig i))
		      (set-needs-copy arg))
		   (loop (+fx i 1) (gcdr args) (gcar args))))))))

(define-method (abstract-interpret node::method-invoke)
   (with-access::method-invoke node (method arglist)
      (set-needs-copy method)
      (for-each set-needs-copy arglist)))

(define-method (abstract-interpret node::static-method-invoke)
   (with-access::static-method-invoke node (arglist)
      (for-each set-needs-copy arglist)))

(define-method (abstract-interpret node::constructor-invoke)
   (with-access::constructor-invoke node (arglist)
      (for-each set-needs-copy arglist)))



(define-method (abstract-interpret node::formal-param)
   (with-access::formal-param node (name)
      (update-binding name 'any)
      (set-last-def name node)
      (cond
	 ((and (required-formal-param/gen? node)
	       (not (required-formal-param/gen-cont? node)))
	  (required-formal-param/gen-needs-copy?-set! node #f))
	 ((and (optional-formal-param/gen? node)
	       (not (optional-formal-param/gen-cont? node)))
	  (optional-formal-param/gen-needs-copy?-set! node #f)))))

;I think that globalization means it's in a container, so this might be superfluous
(define-method (abstract-interpret node::global-decl)
   ;the weird thing about the global-decls is that their var is often just the name
   ;not sure if that's a good thing...
   (with-access::global-decl node (var)
      (when (symbol? var)
	 (update-binding var 'container)
	 (set-last-def var node))))

(define-method (abstract-interpret node::static-decl)
   (with-access::static-decl node (var)
      (when (symbol? var)
	 (update-binding var 'any)
	 (set-last-def var node))))


(define-method (abstract-interpret node::var)
   (with-access::var/gen node (type name cont? location)
      (let ((most-current-type (get-binding name)))
	 (debug-trace 6 "updating variable " name ", location " location
		      ", type " type ", most-current-type " most-current-type
		      ", cont? " cont?)
	 (when (or (not most-current-type) cont?)
	    ;variable is not typed or is in a container
	    (if cont?
		(begin
		   (update-binding name 'container)
		   (set! most-current-type 'container))
		(begin
		   ;(update-binding name 'any)
		   (set! most-current-type 'any))))
		
	 (unless (types-eqv? type most-current-type)
	    (change "variable " name " change type from " type " to " most-current-type)
	    (set! type most-current-type)

	    ;(set! *changed* #t)
	    ))))

(define-method (abstract-interpret node::precrement)
   (with-access::precrement node (lval)
      (cond
	 ((var? lval)
	  (update-binding (var-name lval) 'number)
	  (set-last-def (var-name lval) node))
	 ((hash-lookup? lval)
	  (assign-hash-type lval)
	  (set-needs-copy lval))
	 (else (set-needs-copy lval)))))

(define-method (abstract-interpret node::postcrement)
   (with-access::postcrement node (lval)
      (cond
	 ((var? lval)
	  (update-binding (var-name lval) 'number)
	  (set-last-def (var-name lval) node))
	 ((hash-lookup? lval)
	  (assign-hash-type lval)
	  (set-needs-copy lval))
	 (else (set-needs-copy lval)))))

(define-method (abstract-interpret node::assigning-arithmetic-op)
   (with-access::assigning-arithmetic-op node (lval)
      (cond
	 ((var? lval)
	  (update-binding (var-name lval) 'number)
	  (set-last-def (var-name lval) node))
	 ((hash-lookup? lval)
	  (assign-hash-type lval)
	  (set-needs-copy lval))
	 (else (set-needs-copy lval)))))


(define-method (abstract-interpret node::assigning-string-cat)
   (with-access::assigning-string-cat node (lval)
      (cond
	 ((var? lval)
	  (update-binding (var-name lval) 'string)
	  (set-last-def (var-name lval) node))
	 ((hash-lookup? lval)
	  (assign-hash-type lval)
	  (set-needs-copy lval))
	 (else (set-needs-copy lval)))))

(define-method (abstract-interpret node::foreach-loop)
   (with-access::foreach-loop node (key value)
      (when (var? key)
	 (update-binding (var-name key) 'any)
	 (set-last-def (var-name key) node))
      (when (var? value)
	 (update-binding (var-name value) 'any)
	 (set-last-def (var-name value) node))))


(define-method (abstract-interpret node::assignment)
   (with-access::assignment node (lval rval)
      (cond
	 ((var? lval)
	  (update-binding (var-name lval) (expression-type rval))
	  (set-last-def (var-name lval) node))
	 ((hash-lookup? lval)
	  (debug-trace 6 "abstract-interpret: assignment with hash lval, location: " (ast-node-location lval))
	  (assign-hash-type lval)
	  (set-needs-copy lval))
	 (else (set-needs-copy lval)))))

(define-method (abstract-interpret node::reference-assignment)
   (with-access::reference-assignment node (rval)
      ;assign hash type here?      
      (set-needs-copy rval)))


(define-method (abstract-interpret node::list-assignment)
   (with-access::list-assignment node (lvals)
      (for-each
       (lambda (lval)
	  (cond
	     ((var? lval)
	      (update-binding (var-name lval) 'any)
	      (set-last-def (var-name lval) node))
	     (else (set-needs-copy lval))))
       lvals)))

(define-method (abstract-interpret node::unset-stmt)
   ;; the current implementation of unset() is to assign NULL to
   ;; the variable.
   (with-access::unset-stmt node (lvals)
      (for-each (lambda (lval)
		   (cond
		      ((var? lval)
		       (update-binding (var-name lval) 'nil)
		       (set-last-def (var-name lval) node))
		      (else (set-needs-copy lval))))
		lvals)))


;merge a new binding
(define (unify-binding var-name::symbol new-binding)
   (let* ((binding-so-far (get-binding var-name)))
      (if (symbol? new-binding) (set! new-binding (list new-binding)))
      (if binding-so-far
	  (for-each
	   (lambda (n)
	      (unless (member n binding-so-far)
		 (hashtable-put! *current-symtab* var-name (cons n binding-so-far))))
	   new-binding)
	  (begin
	     (hashtable-put! *current-symtab* var-name new-binding)))))

;replace the old binding with a new one
(define (update-binding var-name::symbol new-binding)
   (if (symbol? new-binding) (set! new-binding (list new-binding)))
   (hashtable-put! *current-symtab* var-name new-binding))

(define (get-binding var-name::symbol)
   (hashtable-get *current-symtab* var-name))	 
			    
(define-generic (expression-type node)
   (let ((simple-type (node-return-type node)))
      (if simple-type
	  simple-type
	  'any)))

(define-method (expression-type node::assignment)
   (node-return-type (assignment-rval node)))


(define-method (expression-type node::var/gen)
   ;; containeredness doesn't actually propagate around like
   ;; the other types, because generate.scm will automatically box
   ;; and unbox things.
   (if (var/gen-cont? node)
       'any
       (if (get-binding (var-name node))
	   (get-binding (var-name node))
	   'any)))

;;;;mark cases where we can replace string-append with display on a port  
(define (maybe-replace-append-with-port node)
   ;;identify all the variables that are
   ;;1. in a loop and
   ;;2. only used as the LHS of a string-cat
   ;;and mark them for special treatment in code generation
   (walk-ast node mark-for-port-replacement)
   (walk-ast node remove-nested-ports-from-loops))



(define *loop-symbol-table* #f)
(define *loop-backpatch-list* #f)

;so that the method for assigning-string-cat can use (k) to
;treat the rval without borking the lval.
(define *string-cat-lval* '())

(define-generic (mark-for-port-replacement node k)
   (k))

(define (generic-loop-mark-for-port-replacement node k)
   (let ((symtab (make-hashtable))
	 (backpatch-list '()))
      ;collect all of the variables that should be replaced
      (dynamically-bind (*loop-symbol-table* symtab)
	 ;collect all of the assigning-string-cats and assignments that
	 ;might need to be marked
	 (dynamically-bind (*loop-backpatch-list* '())
	    (k)
	    (set! backpatch-list *loop-backpatch-list*)))
      ;copy the list of variables that should get replaced into the loop
      (hashtable-for-each symtab
	 (lambda (k v)
	    (when (eqv? 'matched v)
	       (debug-trace 6 "replacing " k " with a string-port in " (ast-node-location node))
	       ;this propagates the variable up to the surrounding loop
	       ;so that a case like while() { while() { $a .= ""; } } will have the
	       ;string-port outside the outermost loop. Otherwise it isn't seen by
	       ;the outer loop.
	       (when (and *loop-symbol-table*
			  (not (eqv? 'failed (hashtable-get *loop-symbol-table* k))))
		  (hashtable-put! *loop-symbol-table* k 'matched))

	       (cond
		  ((while-loop? node) 
		   (while-loop/gen-string-ports-set!
		    node (cons k (while-loop/gen-string-ports node))))
		  ((for-loop? node) 
		   (for-loop/gen-string-ports-set!
		    node (cons k (for-loop/gen-string-ports node))))
		  ((foreach-loop? node) 
		   (foreach-loop/gen-string-ports-set!
		    node (cons k (foreach-loop/gen-string-ports node))))
		  ((do-loop? node) 
		   (do-loop/gen-string-ports-set!
		    node (cons k (do-loop/gen-string-ports node))))))))
      ;backpatch the string-cats and assignments that should be backpatched
      (for-each (lambda (s)
		   (if (assigning-string-cat? s)
		       (when (eqv? 'matched (hashtable-get symtab (var-name (assigning-string-cat-lval s))))
			  (assigning-string-cat/gen-lhs-is-output-port?-set! s #t))
		       (when (eqv? 'matched (hashtable-get symtab (var-name (let loop ((a (assignment/gen-rval s)))
									       (if (string-cat? a)
										   (loop (string-cat-a a))
										   a)))))
			  (assignment/gen-lhs-is-output-port?-set! s #t))))
		backpatch-list)))

(define-method (mark-for-port-replacement node::while-loop k)
   (generic-loop-mark-for-port-replacement node k))

(define-method (mark-for-port-replacement node::for-loop k)
   (generic-loop-mark-for-port-replacement node k))

(define-method (mark-for-port-replacement node::foreach-loop k)
   (generic-loop-mark-for-port-replacement node k))

(define-method (mark-for-port-replacement node::do-loop k)
   (generic-loop-mark-for-port-replacement node k))


(define-method (mark-for-port-replacement node::var k)
   (with-access::var node (name)
      (when *loop-symbol-table*
	 ;if we see a variable anyplace other than as a string-cat lval, we
	 ;cannot port-replace it.
	 (if (and (memq node *string-cat-lval*)
		  (not (eqv? 'failed (hashtable-get *loop-symbol-table* name))))
	     (hashtable-put! *loop-symbol-table* name 'matched)
	     (hashtable-put! *loop-symbol-table* name 'failed)))
      (k)))

(define-method (mark-for-port-replacement node::assigning-string-cat k)
   (with-access::assigning-string-cat node (lval rval)
      (if (var? lval)
	  (dynamically-bind (*string-cat-lval* (cons lval *string-cat-lval*))
	     (pushf node *loop-backpatch-list*)
	     (k))
	  (k))))

(define-method (mark-for-port-replacement node::assignment k)
   ;catch $a = $a . foo and treat it like $a .= foo
   (with-access::assignment node (lval rval)
      ;string-cats are unfortunately left-recursively nested
      (let ((leftmost-rhs (let loop ((a rval))
			     (if (string-cat? a)
				 (loop (string-cat-a a))
				 a))))
	 (if (and (var? lval)
		  (string-cat? rval)
		  (var? leftmost-rhs)
		  (eqv? (var-name leftmost-rhs)
			    (var-name lval)))
	     (dynamically-bind (*string-cat-lval* (cons lval
							(cons leftmost-rhs
							      *string-cat-lval*)))
		(pushf node *loop-backpatch-list*)
		(k))
	     (k)))))



(define-generic (remove-nested-ports-from-loops node k)
   "delete string-ports from loops if they are already bound by a
containing loop"
   (k))

(define-method (remove-nested-ports-from-loops node::for-loop k)
   (with-access::for-loop/gen node (string-ports)
      (set! string-ports (remove-nested-ports string-ports k))))

(define-method (remove-nested-ports-from-loops node::foreach-loop k)
   (with-access::foreach-loop/gen node (string-ports)
      (set! string-ports (remove-nested-ports string-ports k))))

(define-method (remove-nested-ports-from-loops node::while-loop k)
   (with-access::while-loop/gen node (string-ports)
      (set! string-ports (remove-nested-ports string-ports k))))

(define-method (remove-nested-ports-from-loops node::do-loop k)
   (with-access::do-loop/gen node (string-ports)
      (set! string-ports (remove-nested-ports string-ports k))))

(define *ports* '())
(define (remove-nested-ports ports k)
   (let ((new-ports (filter (lambda (p)
			       (not (member p *ports*)))
			    ports)))
      (dynamically-bind (*ports* (append new-ports *ports*))
	 (k))
      new-ports))


(define (get-last-defs sym::symbol)
   (or (hashtable-get *last-defs* sym) '()))

(define (set-last-def sym::symbol node::ast-node)
   (hashtable-put! *last-defs* sym (list node)))

(define (must-copy-last-defs sym::symbol)
   (for-each (lambda (a)
		(cond
		   ((required-formal-param/gen? a)
		    (required-formal-param/gen-needs-copy?-set! a #t))
		   ((optional-formal-param/gen? a)
		    (optional-formal-param/gen-needs-copy?-set! a #t))))
	     (get-last-defs sym)))

(define-generic (set-needs-copy var)
   (debug-trace 4 "cfa: warning, can't set-needs-copy " var))

(define-method (set-needs-copy var::property-fetch)
   (with-access::property-fetch var (obj)
      (if (symbol? obj)
	  (must-copy-last-defs obj)
	  (set-needs-copy obj))))

(define-method (set-needs-copy var::hash-lookup)
   (with-access::hash-lookup var (hash)
      (if (symbol? hash)
	  (must-copy-last-defs hash)
	  (set-needs-copy hash))))

(define-method (set-needs-copy var::var)
   (with-access::var var (name)
      (if (symbol? name)
	  (must-copy-last-defs name)
	  (debug-trace 4 "cfa: warning, set-needs-copy(var): "
		       name " is not a symbol"))))


;;;; collect-first-types
(define (collect-first-types flow-segment)
   (with-access::flow-segment flow-segment (node start end)
      ;first, reset all the symtab-so-fars
      (walk-flow-segment-backwards flow-segment
		(lambda (b)
		   (basic-block-symtab-so-far-set! b (make-hashtable))))
      ;now we keep walking from the end to the beginning, so we can
      ;collect the first type of each variable and put it into the
      ;function or method's symbol-table
;      (set! *changed* #t)
      (change "initializing first-types loop")
      (let loop ((i 0))
	 (when *changed*
	    (set! *changed* #f)
	    (walk-flow-segment flow-segment
			       find-first-type)
	    (if (< i *loop-limit*)
		(loop (+fx i 1))
		(if (ast-node? node)
		    (warning/loc (flow-segment-node flow-segment)
				 "collect-first-types: Too much optimization -- giving up")
		    (php-warning "collect-first-types: Too much optimization -- giving up")))))
      ;it should leave the results in the start block
      ;we copy them into the function or method's symbol table
      (let ((symbol-table (node-symbol-table node)))
	 (cond
	    ((function-decl/gen? node)
	     (debug-trace 4 "types for variables in function " (function-decl-name node) ))
	    ((method-decl/gen? node)
	     (debug-trace 4 "types for variables in method " (method-decl-name node) ))
	    (else
	     (debug-trace 4 "types for global variables")))

	 (hashtable-for-each (basic-block-symtab-so-far start)
	    (lambda (k v)
	       (debug-trace 4 "first type of " k " is " v)
	       (hashtable-put! symbol-table k v))))))

(define (node-symbol-table node)
   (cond
      ((function-decl/gen? node)
       (function-decl/gen-symbol-table node))
      ((method-decl/gen? node)
       (method-decl/gen-symbol-table node))
      ((php-ast/gen? node)
       (php-ast/gen-global-symbol-table node))
      (else (error 'annotate-segment "unexpected node type in flow segment" node))))

(define (find-first-type block::basic-block)
   (with-access::basic-block block (symtab-so-far succ code i)
      (dynamically-bind (*current-symtab* symtab-so-far)
	 ;since we're running backwards, we merge the symbols
	 ;from the successors
	 (for-each (lambda (b)
		      (hashtable-for-each (basic-block-symtab-so-far b)
			 (lambda (k v)
			    (let ((old-binding (get-binding k)))
			       (unify-binding k v)
;			       (debug-trace 21 "name " k ", old-binding: " old-binding ", new binding: " (get-binding k))
			       (unless (types-eqv? (get-binding k) old-binding)
				  (change "first type of " k " changed from " old-binding " to " (get-binding k))
				  ;(set! *changed* #t)
				  )))))
		   succ)
	 ;now note the types of each variable
	 (for-each (lambda (v)
		      (cond
			 ((var? v)
			  (with-access::var/gen v (name type)
			     ;			    (debug-trace 22 "find-first-type: variable " name " block " i)
			     (if type
				 (begin
				    (unless (get-binding name)
				       ;				      (set! *changed* #t)
				       (change "first type of " name " was unbound."))
				    (unify-binding name type))
				 (error 'find-first-type "variable did not get typed" v))))
			 ;; global declarations are a special case, because they have no ast-node
			 ;; (a var/gen) to hold type info, just the name of the variable.  So if
			 ;; the variable declared global is never used, it wouldn't get declared,
			 ;; since we're scraping the types off the variables, instead of out of
			 ;; the symbol tables.
			 ((global-decl? v)
			  (with-access::global-decl v (var)
			     (when (symbol? var)
				(unless (get-binding var)
				   (change "first type of global " var " was unbound."))
				(unify-binding var 'container))))))
		   code) )))


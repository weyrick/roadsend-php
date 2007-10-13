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


;;;; A basic block is a collection of AST nodes with linear control-flow,
;;;; like a scheme begin statement.  Each basic block has a set of
;;;; predecessor basic blocks, a set of successor basic blocks, and a list
;;;; of ast-nodes in the order of execution.

(module basic-blocks
   (library php-runtime)
   (include "php-runtime.sch")
   (import (ast "ast.scm"))
   (export
    (dump-php-flow node::php-ast)
    (walk-flow-segment segment frobber-to-apply)
    (walk-flow-segment-backwards segment frobber-to-apply)
    (generic identify-basic-blocks node)
    (class flow-segment
       node
       start
       end
       node-list
       (node-count (default 0)))
    (final-class basic-block
       place-it-started
       i
       (symtab-so-far (default (make-hashtable)))
       (last-defs (default (make-hashtable)))
       (inside-a-loop? (default #f))
       (pred (default '()))
       (succ (default '()))
       (code (default '())))))


(define *current-block* 'unset)


;the current escape function for return statements
(define *current-return-escape* 'unset)

;block to link to for a break out 1..n levels
(define *break-stack* '())

;block to link to to continue the current loop
(define *continue-stack* '())

;; a "flow segment" associates an ast node and a section of control flow.
;; PHP ASTs, methods, and functions will be associated with flow segments,
;; because they are the starting points for later analysis.
;; Each flow segment is a directed graph.
(define *flow-segments* '())

(define *current-flow-segment* 'unset)

(define (reset-globals!)
   (set! *break-stack* '())
   (set! *continue-stack* '())
   (set! *flow-segments* '())
   (set! *current-flow-segment* 'unset)
   (set! *current-return-escape* 'unset)
   (set! *current-block* 'unset))

(define-generic (identify-basic-blocks node)
   (if (list? node)
       (for-each identify-basic-blocks node)
       (error 'identify-basic-blocks "Don't know what to do with" node)))

(define-method (identify-basic-blocks node::php-ast)
   (reset-globals!)

   ; (debug-trace 22 " (identify-basic-blocks node::php-ast)")
   (let ((global-flow-segment (make-flow-segment node 'no-first 'no-last '() 0)))
      (pushf global-flow-segment *flow-segments*)
      (dynamically-bind (*current-flow-segment* global-flow-segment)
	 (let ((first-block (start-block 1))
	       (last-block (start-block 2)))
	    (flow-segment-start-set! *current-flow-segment* first-block)
	    (flow-segment-end-set! *current-flow-segment* last-block)
	    (set! *current-block* first-block)
	    (identify-basic-blocks (php-ast-nodes node))
	    (link-blocks *current-block* last-block))))
   ;finish up the blocks
   (let ((block-count 0))
      (for-each (lambda (f)
		   (walk-flow-segment f; (flow-segment-start f)
;			       basic-block-succ
			       (lambda (b)
				  (set! block-count (+ block-count 1))
				  (basic-block-code-set! b
							 (reverse! (basic-block-code b))))))

		*flow-segments*)
      (debug-trace 22 "identify-basic-blocks: the block count is " the-eyes-have-it
				   " but I counted " block-count " blocks."))
		

   ;;try to fix dead-ends 
;    (for-each (lambda (f)
; 		(walk-dag (flow-segment-start f)
; 			     basic-block-succ
; 			     (lambda (b)
; 				(when (and (null? (basic-block-succ b))
; 					   (not (or
; 						 (= (basic-block-i b)
; 						    (basic-block-i (flow-segment-end f)))))
; 				   (debug-trace 22 "dead-end block " (basic-block-i b))
; 				   (link-blocks b (flow-segment-end f))))))
; 		*flow-segments*)
   *flow-segments*)


(define-method (identify-basic-blocks node::function-invoke)
   ; (debug-trace 22 " (identify-basic-blocks node::function-invoke)")
   (with-access::function-invoke node (name arglist)
      (when (ast-node? name)
	 (identify-basic-blocks name))
      (identify-basic-blocks (function-invoke-arglist node)))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::nop)
   ; (debug-trace 22 " (identify-basic-blocks node::nop)")
   '())

(define-method (identify-basic-blocks node::hash-lookup)
   ; (debug-trace 22 " (identify-basic-blocks node::hash-lookup)")
   (with-access::hash-lookup node (hash key)
      ;we want info to flow from the lookup to the variable, since
      ;$X[foo] means that $X is potentially a hashtable, not the other
      ;way around
      (add-to-current-block node)
      (identify-basic-blocks hash)
      (unless (eqv? key :next)
	 (identify-basic-blocks key))))

(define-method (identify-basic-blocks node::literal-array)
   ; (debug-trace 22 " (identify-basic-blocks node::literal-array)")
   (identify-basic-blocks (literal-array-array-contents node))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::array-entry)
   ; (debug-trace 22 " (identify-basic-blocks node::array-entry)")
   (with-access::array-entry node (key value)
      (unless (eqv? :next key)
	 (identify-basic-blocks key) )
      (identify-basic-blocks value)
      (add-to-current-block node)))

(define-method (identify-basic-blocks node::postcrement)
   ; (debug-trace 22 " (identify-basic-blocks node::postcrement)")
   (identify-basic-blocks (postcrement-lval node))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::precrement)
   ; (debug-trace 22 " (identify-basic-blocks node::precrement)")
   (identify-basic-blocks (precrement-lval node))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::arithmetic-unop)
   ; (debug-trace 22 " (identify-basic-blocks node::arithmetic-unop)")
   (identify-basic-blocks (arithmetic-unop-a node))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::assigning-arithmetic-op)
   ; (debug-trace 22 " (identify-basic-blocks node::assigning-arithmetic-op)")
   (with-access::assigning-arithmetic-op node (lval rval)
      (identify-basic-blocks rval)
      (identify-basic-blocks lval))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::assigning-string-cat)
   ; (debug-trace 22 " (identify-basic-blocks node::assigning-string-cat)")
   (with-access::assigning-string-cat node (lval rval)
      (identify-basic-blocks rval)
      (identify-basic-blocks lval))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::foreach-loop)
   ; (debug-trace 22 " (identify-basic-blocks node::foreach-loop)")
   (with-access::foreach-loop node (array key value body)
      (identify-basic-blocks array)
      (let ((loop-body (start-block 3))
	    (successor (start-block 4))
	    (predecessor *current-block*))
	 ; (debug-trace 22 " (identify-basic-blocks node::foreach-loop): predecessor is " (basic-block-i predecessor))
	 ; (debug-trace 22 " (identify-basic-blocks node::foreach-loop): loop-body is " (basic-block-i loop-body))
	 ; (debug-trace 22 " (identify-basic-blocks node::foreach-loop): successor is " (basic-block-i successor))
	 ;we might skip over the loop
	 (link-blocks predecessor successor)
	 ;or we might go through the loop
	 (link-blocks predecessor loop-body)
	 (set! *current-block* loop-body)

	 (dynamically-bind (*break-stack* (cons successor *break-stack*))
	    (dynamically-bind (*continue-stack* (cons loop-body *continue-stack*))
	       (add-to-current-block node)

	       (identify-basic-blocks value)
	       (unless (null? key)
		  (identify-basic-blocks key))
	 
	       (identify-basic-blocks body) ))
	 ;the loop loops
	 (link-blocks *current-block* loop-body)
	 ;the loop finishes
	 (link-blocks *current-block* successor)
	 (set! *current-block* successor))))

(define-method (identify-basic-blocks node::while-loop)
   ; (debug-trace 22 " (identify-basic-blocks node::while-loop)")
   (with-access::while-loop node (body condition)
      (identify-basic-blocks condition)
      (let ((loop-body (start-block 5))
	    (predecessor *current-block*)
	    (successor (start-block 6)))
	 (link-blocks predecessor loop-body)
	 (link-blocks predecessor successor)
	 (set! *current-block* loop-body)
	 (dynamically-bind (*break-stack* (cons successor *break-stack*))
	    (dynamically-bind (*continue-stack* (cons loop-body *continue-stack*))
	       (add-to-current-block node)
	       (identify-basic-blocks body)) )
	 (link-blocks *current-block* loop-body)
	 (link-blocks *current-block* successor)	 
	 (set! *current-block* successor))))


(define-method (identify-basic-blocks node::for-loop)
   ; (debug-trace 22 " (identify-basic-blocks node::for-loop)")
   (with-access::for-loop node (init condition step body)
      ;; for lack of a better place to put the for-loop node
      (add-to-current-block node)
      (identify-basic-blocks init)
      ;; We used to:     (identify-basic-blocks condition)
      ;; But, having the same nodes in more than one basic block can keep the cfa
      ;; from reaching a fixed point.  it'll keep trying to change the type
      ;; of var to match the block's symbol table, but there will be two block
      ;; symbol tables sharing the same var.  If they have different types, *poof*,
      ;; infinite loop.  So, we make a special basic block just for the
      ;; condition.
      (let ((predecessor *current-block*)
	    (condition-block (start-block "for-loop-condition"))
	    (successor (start-block "for-loop-successor"))
	    (loop-body (start-block "for-loop-body")))
	 (link-blocks predecessor condition-block)
	 (set! *current-block* condition-block)
	 (identify-basic-blocks condition)

	 (link-blocks condition-block loop-body)
	 (link-blocks condition-block successor)
	 (set! *current-block* loop-body)
	 
	 (dynamically-bind (*break-stack* (cons successor *break-stack*))
	    (dynamically-bind (*continue-stack* (cons loop-body *continue-stack*))
	       (identify-basic-blocks body)
	       (identify-basic-blocks step)))
	 
	 (link-blocks *current-block* condition-block)
;	 (link-blocks *current-block* successor)
 	 (set! *current-block* successor))))

(define-method (identify-basic-blocks node::break-stmt)
   ; (debug-trace 22 " (identify-basic-blocks node::break-stmt)")
   (with-access::break-stmt node (level)
      (let ((predecessor *current-block*)
	    ;;the successor is not unreachable until we actually pay some attention to the level.
	    (successor (start-block 9)))
	 ;;we don't pay attention to the level for the moment, since it isn't
	 ;;always an integer, and paying attention to it would be an optimization.
	 ;;for now, we err on the side of linking too many blocks.
	 ;;see bug 2385
	 (link-blocks predecessor successor) 
	 (set! *current-block* successor)
	 (for-each (lambda (succ)
		      (link-blocks predecessor succ))
		   *break-stack*) )))

(define-method (identify-basic-blocks node::continue-stmt)
   ; (debug-trace 22 " (identify-basic-blocks node::continue-stmt)")
   (with-access::continue-stmt node (level)
      (let ((predecessor *current-block*)
	    (successor (start-block 10)))
	 ;see break-stmt for why we ignore level
	 (link-blocks predecessor successor) ;XXX this isn't true, but is needed for the backwards linkes
	 (set! *current-block* successor)
	 (for-each (lambda (succ)
		      (link-blocks predecessor succ))
		   *continue-stack*))))


; (define-method (identify-basic-blocks node::continue-stmt)
;    (add-to-current-block node)
;    (if (basic-block? *current-loop-continue*)
;        (let ((predecessor *current-block*)
; 	     (successor (start-block)))
; 	  (set! *current-block* successor)
; 	  (link-blocks predecessor *current-loop-continue*))))
; ;       (php-error (format "identify-continue-stmt: continue not inside of a loop ~a" (ast-node-location node) ))))

(define-method (identify-basic-blocks node::return-stmt)
   ; (debug-trace 22 " (identify-basic-blocks node::return-stmt)")
   (identify-basic-blocks (return-stmt-value node))
   (add-to-current-block node)
   (let ((predecessor *current-block*)
	 (successor (start-unreachable-block 11)))

      ;; deleting the unreachable blocks is a separate optimization.
      (link-blocks predecessor successor)

      (when (basic-block? *current-return-escape*)
	 ;; returns are allowed in a global context too, in which case
	 ;; they're just like exits.
	 (link-blocks predecessor *current-return-escape*))
      (set! *current-block* successor)))
;	  (error 'identifier "return where it caint be" node))))

(define-method (identify-basic-blocks node::exit-stmt)
   ; (debug-trace 22 " (identify-basic-blocks node::exit-stmt)")
   (with-access::exit-stmt node (rval)
      (unless (null? rval)
	 (identify-basic-blocks rval))
      (add-to-current-block node)
      (let ((predecessor *current-block*)
	    (successor (start-unreachable-block 12)))

	 (link-blocks predecessor successor) 
	 (set! *current-block* successor))))

(define-method (identify-basic-blocks node::throw)
   (with-access::throw node (rval)
      (identify-basic-blocks rval)
      (add-to-current-block node)))

(define-method (identify-basic-blocks node::try-catch)
   (with-access::try-catch node (try-body catches)
      (identify-basic-blocks try-body)
      ; something special for catch blocks?
      (add-to-current-block node)))

(define-method (identify-basic-blocks node::if-stmt)
   ; (debug-trace 22 " (identify-basic-blocks node::if-stmt)")
   (with-access::if-stmt node (condition then else)
      (identify-basic-blocks condition)
      ;; put the if itself second? first?  does it matter?
      (add-to-current-block node)
      (let ((predecessor *current-block*)
	    (body-then (start-block "if-stmt-then"))
	    (successor (start-block "if-stmt-successor")))
	 (set! *current-block* body-then)
	 (identify-basic-blocks then)
	 (link-blocks predecessor body-then) 
;	 (link-blocks body-then successor)
	 (link-blocks *current-block* successor)
	 (if (null? else)
	     (link-blocks predecessor successor)
	     (let ((body-else (start-block "if-stmt-else")))
		(set! *current-block* body-else)
		(identify-basic-blocks else)
		(link-blocks predecessor body-else)
;		(link-blocks body-else successor)
		(link-blocks *current-block* successor)
		))
	 (set! *current-block* successor))))

(define-method (identify-basic-blocks node::lyteral)
   ; (debug-trace 22 " (identify-basic-blocks node::lyteral)")
   (add-to-current-block node))

(define-method (identify-basic-blocks node::typecast)
   ; (debug-trace 22 " (identify-basic-blocks node::typecast)")
   (identify-basic-blocks (typecast-rval node))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::arithmetic-op)
   ; (debug-trace 22 " (identify-basic-blocks node::arithmetic-op)")
   (with-access::arithmetic-op node (op a b)
      (identify-basic-blocks a)
      (identify-basic-blocks b)
      (add-to-current-block node)))

(define-method (identify-basic-blocks node::echo-stmt)
   ; (debug-trace 22 " (identify-basic-blocks node::echo-stmt)")
   (with-access::echo-stmt node (stuff)
      (identify-basic-blocks stuff)
      (add-to-current-block node)))


(define-method (identify-basic-blocks node::global-decl)
   ; (debug-trace 22 " (identify-basic-blocks node::global-decl)")
   (with-access::global-decl node (var)
      (when (ast-node? var)
	 (identify-basic-blocks var))
      (add-to-current-block node)))

(define-method (identify-basic-blocks node::static-decl)
   ; (debug-trace 22 " (identify-basic-blocks node::static-decl)")
   (with-access::static-decl node (var)
      (when (ast-node? var)
	 (identify-basic-blocks var))
      (add-to-current-block node)))

(define-method (identify-basic-blocks node::disable-errors)
   ; (debug-trace 22 " (identify-basic-blocks node::disable-errors)")
   (with-access::disable-errors node (body)
      (identify-basic-blocks body)
      (add-to-current-block node)))

(define-method (identify-basic-blocks node::var)
   ; (debug-trace 22 " (identify-basic-blocks node::var)")
   ; (debug-trace 22 " (identify-basic-blocks node::var): var named " (var-name node) " added to block " (basic-block-i *current-block*))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::var-var)
   ; (debug-trace 22 " (identify-basic-blocks node::var-var)")
   (with-access::var-var node (lval)
      (identify-basic-blocks lval)
      (add-to-current-block node)))

; (define-method (identify-basic-blocks node::string-char)
;    (with-access::string-char node (str pos)
;       (identify-basic-blocks str)
;       (identify-basic-blocks pos)
;       (add-to-current-block node)))



(define-method (identify-basic-blocks node::assignment)
   ; (debug-trace 22 " (identify-basic-blocks node::assignment)")
   (with-access::assignment node (lval rval)
      (identify-basic-blocks rval)
      ;for hash-lookups, we can say that the variable will be
      ;a hash -- but only *after* the assignment, because the
      ;assignment itself needs to create the hash.
      (when (hash-lookup? lval)
	 (identify-basic-blocks lval))
      (add-to-current-block node)
      (when (not (hash-lookup? lval))
	 (identify-basic-blocks lval))))

(define-method (identify-basic-blocks node::list-assignment)
   ; (debug-trace 22 " (identify-basic-blocks node::list-assignment)")
   (with-access::list-assignment node (lvals rval)
      (identify-basic-blocks rval)
      (for-each (lambda (lval) (unless (null? lval)
			     (identify-basic-blocks lval)))
		lvals)
      (add-to-current-block node)))

(define-method (identify-basic-blocks node::reference-assignment)
   ; (debug-trace 22 " (identify-basic-blocks node::reference-assignment)")
   (with-access::reference-assignment node (lval rval)
      (identify-basic-blocks rval)
      (identify-basic-blocks lval)
      (add-to-current-block node)))

(define-method (identify-basic-blocks node::unset-stmt)
   ; (debug-trace 22 " (identify-basic-blocks node::unset-stmt)")
   (with-access::unset-stmt node (lvals)
      (for-each identify-basic-blocks lvals)
      (add-to-current-block node)))


(define-method (identify-basic-blocks node::switch-stmt)
   ; (debug-trace 22 " (identify-basic-blocks node::switch-stmt)")
   (with-access::switch-stmt node (rval cases)
      (add-to-current-block node)
      (identify-basic-blocks rval)
      (let ((predecessor *current-block*)
	    (successor (start-block 16)))
	 (unless (null? cases)
	 (dynamically-bind (*break-stack* (cons successor *break-stack*))
	    (dynamically-bind (*continue-stack* (cons successor *continue-stack*))
	       (let ((prior-case #f))
		  (for-each (lambda (c)
			       (let ((body-block (start-block 17)))
				  (set! *current-block* body-block)
				  (if (default-switch-case? c)
				      (with-access::default-switch-case c (body)
					 (identify-basic-blocks body))
				      (with-access::switch-case c (val body)
					 (identify-basic-blocks val)
					 (identify-basic-blocks body)))
				  (link-blocks predecessor body-block)
;				  (link-blocks body-block successor)
				  (link-blocks *current-block* successor)
				  (when prior-case
				     (link-blocks prior-case body-block))
;				  (set! prior-case body-block)
				  (set! prior-case *current-block*)
				  ))
			    cases)))))
	 (link-blocks predecessor successor)
	 (set! *current-block* successor))))



(define-method (identify-basic-blocks node::do-loop)
   ; (debug-trace 22 " (identify-basic-blocks node::do-loop)")
   (with-access::do-loop node (condition body)
      ;; may as well put the loop itself first.
      (add-to-current-block node)
      (identify-basic-blocks condition)
      (let ((predecessor *current-block*)
	    (body-block (start-block 18))
	    (successor (start-block 19)))
	 ;we skip the loop
	 ;doesn't happen for a do, does it?
;	 (link-blocks predecessor successor)
	 ;we start the loop
	 (link-blocks predecessor body-block)
	 (set! *current-block* body-block)
	 (unless (null? body)
	    (dynamically-bind (*break-stack* (cons successor *break-stack*))
	       (dynamically-bind (*continue-stack* (cons body-block *continue-stack*))
		  (identify-basic-blocks body))))
	 ;we go around again
	 (link-blocks *current-block* body-block)
	 ;we are finished the loop
	 (link-blocks *current-block* successor)
	 (set! *current-block* successor))))


(define-method (identify-basic-blocks node::class-decl)
   ; (debug-trace 22 " (identify-basic-blocks node::class-decl)")
   (with-access::class-decl node (class-body)
      (identify-basic-blocks class-body)))

(define-method (identify-basic-blocks node::constructor-invoke)
   ; (debug-trace 22 " (identify-basic-blocks node::constructor-invoke)")
   (with-access::constructor-invoke node (class-name arglist)
      (identify-basic-blocks class-name)
      (for-each identify-basic-blocks arglist))
   (add-to-current-block node))


(define-method (identify-basic-blocks node::method-invoke)
   ; (debug-trace 22 " (identify-basic-blocks node::method-invoke)")
   (with-access::method-invoke node (method arglist)
      (with-access::property-fetch method (obj prop)
	 (identify-basic-blocks obj)
	 (identify-basic-blocks prop)
	 (for-each identify-basic-blocks arglist)))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::static-method-invoke)
   ; (debug-trace 22 " (identify-basic-blocks node::static-method-invoke)")
   (with-access::static-method-invoke node (method arglist)
      (identify-basic-blocks method)
      (for-each identify-basic-blocks arglist))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::parent-method-invoke)
   ; (debug-trace 22 " (identify-basic-blocks node::parent-method-invoke)")
   (with-access::parent-method-invoke node (name arglist)
      (identify-basic-blocks name)
      (for-each identify-basic-blocks arglist))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::property-fetch)
   ; (debug-trace 22 " (identify-basic-blocks node::property-fetch)")
   (with-access::property-fetch node (obj prop)
      (identify-basic-blocks obj)
      (identify-basic-blocks prop))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::class-constant)
   (add-to-current-block node))

(define-method (identify-basic-blocks node::formal-param)
   ; (debug-trace 22 " (identify-basic-blocks node::formal-param)")
   (add-to-current-block node))

(define-method (identify-basic-blocks node::optional-formal-param)
   ; (debug-trace 22 " (identify-basic-blocks node::optional-formal-param)")
   (with-access::optional-formal-param node (default-value)
      (identify-basic-blocks default-value))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::constant-decl)
   ; (debug-trace 22 " (identify-basic-blocks node::constant-decl)")
   (with-access::constant-decl node (value)
      (identify-basic-blocks value))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::php-constant)
   ; (debug-trace 22 " (identify-basic-blocks node::php-constant)")
   (add-to-current-block node))

(define-method (identify-basic-blocks node::string-cat)
   ; (debug-trace 22 " (identify-basic-blocks node::string-cat)")
   (with-access::string-cat node (a b)
      (identify-basic-blocks a)
      (identify-basic-blocks b))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::bitwise-op)
   ; (debug-trace 22 " (identify-basic-blocks node::bitwise-op)")
   (with-access::bitwise-op node (a b)
     (identify-basic-blocks a)
     (identify-basic-blocks b)
     (add-to-current-block node)))

(define-method (identify-basic-blocks node::bitwise-not-op)
   ; (debug-trace 22 " (identify-basic-blocks node::bitwise-not-op)")
   (identify-basic-blocks (bitwise-not-op-a node))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::comparator)
   ; (debug-trace 22 " (identify-basic-blocks node::comparator)")
   (with-access::comparator node (op p q)
      (identify-basic-blocks p)
      (identify-basic-blocks q))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::boolean-not)
   ; (debug-trace 22 " (identify-basic-blocks node::boolean-not)")
   (with-access::boolean-not node (p)
      (identify-basic-blocks p))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::boolean-or)
   ; (debug-trace 22 " (identify-basic-blocks node::boolean-or)")
   (with-access::boolean-or node (p q)
      (identify-basic-blocks p)
      (identify-basic-blocks q))
   (add-to-current-block node))

(define-method (identify-basic-blocks node::boolean-and)
   ; (debug-trace 22 " (identify-basic-blocks node::boolean-and)")
   (with-access::boolean-and node (p q)
      (identify-basic-blocks p)
      (identify-basic-blocks q))
   (add-to-current-block node))



(define-method (identify-basic-blocks node::boolean-xor)
   ; (debug-trace 22 " (identify-basic-blocks node::boolean-xor)")
   (with-access::boolean-xor node (p q)
      (identify-basic-blocks p)
      (identify-basic-blocks q))
   (add-to-current-block node))



(define-method (identify-basic-blocks node::static-decl)
   ; (debug-trace 22 " (identify-basic-blocks node::static-decl)")
   (with-access::static-decl node (var initial-value)
      (when (ast-node? var)
	  (identify-basic-blocks var))
      (identify-basic-blocks initial-value))
   (add-to-current-block node))


(define-method (identify-basic-blocks node::function-decl)
   ; (debug-trace 22 " (identify-basic-blocks node::function-decl)")
   (with-access::function-decl node (decl-arglist body)
      (let ((flow-segment (make-flow-segment node 'no-first 'no-last '() 0)))
	 (pushf flow-segment *flow-segments*)
	 (dynamically-bind (*current-flow-segment* flow-segment)
	    (let ((first-block (start-block "function-decl-start"))
		  (last-block (start-block "function-decl-end")))
	       (flow-segment-start-set! *current-flow-segment* first-block)
	       (flow-segment-end-set! *current-flow-segment* last-block)
	       (dynamically-bind (*current-block* first-block)
		  (add-to-current-block node)
		  (for-each identify-basic-blocks decl-arglist)
		  (dynamically-bind (*current-return-escape* last-block)
		     (identify-basic-blocks body))
		  ;	    (debug-trace 22 " (identify-basic-blocks node::function-decl): linking current "
		  ;			 (basic-block-i *current-block*) " to last " (basic-block-i last-block))
		  (link-blocks *current-block* last-block)))))))

(define-method (identify-basic-blocks node::method-decl)
   (with-access::method-decl node (decl-arglist body)
      ; (debug-trace 22 " (identify-basic-blocks node::method-decl)")
      (let ((flow-segment (make-flow-segment node 'no-first 'no-last '() 0)))
	 (pushf flow-segment *flow-segments*)
	 (dynamically-bind (*current-flow-segment* flow-segment)
	    (let ((first-block (start-block 22))
		  (last-block (start-block 23)))
	       (flow-segment-start-set! *current-flow-segment* first-block)
	       (flow-segment-end-set! *current-flow-segment* last-block)
	       (dynamically-bind (*current-block* first-block)
		  (add-to-current-block node)
		  (for-each identify-basic-blocks decl-arglist)
		  (dynamically-bind (*current-return-escape* last-block)
		     (identify-basic-blocks body))
		  (link-blocks *current-block* last-block)))))))


(define-method (identify-basic-blocks node::property-decl)
   ; (debug-trace 22 " (identify-basic-blocks node::property-decl)")
   ;XXX not sure quite what to do here.
   #t)
;    (with-access::property-decl node (value)
;       (identify-basic-blocks value))
;    (add-to-current-block node))

(define the-eyes-have-it 0)
(define (start-block place-it-started)
   (flow-segment-node-count-set! *current-flow-segment*
				 (+ 1 (flow-segment-node-count *current-flow-segment*)))
   
   (let ((block
	  (instantiate::basic-block
	     (place-it-started place-it-started)
	     (i the-eyes-have-it)
	     (inside-a-loop? (if (pair? *continue-stack*) #t #f)))))
      ;; The realization behind creating a node list here is that, since it's a
      ;; flow-/graph/ anyway, and we're iterating it to a fixed point, it's
      ;; only a performance optimization to topologically sort the nodes.
      ;; Meaning, we can really iterate over them in any order, it just might
      ;; take more iterations if it's a bad order.
      (flow-segment-node-list-set! *current-flow-segment*
					(cons block  (flow-segment-node-list *current-flow-segment*)))
      ; (debug-trace 22 "creating block " the-eyes-have-it)
      (set! the-eyes-have-it (+ the-eyes-have-it 1))
      block))

(define (start-unreachable-block place-it-started)
   (start-block place-it-started))

(define *check-that-blocks-are-added-uniquely* (make-grasstable))
(define (add-to-current-block code)
   [assert (code) (begin0 (not (grasstable-get *check-that-blocks-are-added-uniquely* code)) (grasstable-put! *check-that-blocks-are-added-uniquely* code #t))]
   (basic-block-code-set! *current-block*
			  (cons code (basic-block-code *current-block*))))

(define *node-count* 0)

(define (link-blocks from to)
   ; (debug-trace 22 "block " (basic-block-i from) " precedes block " (basic-block-i to))
   ; (debug-trace 22 "block " (basic-block-i to) " succedes block " (basic-block-i from))

   (basic-block-succ-set! from
			  (cons to (basic-block-succ from)))
   (basic-block-pred-set! to
			  (cons from (basic-block-pred to))))



(define (dump-php-flow ast::php-ast)
   "dump the flow graph in dot form (for graphviz)"
   ;example usage: pcc --dump-flow foo.php |dot -Tgif -o foo.gif (or s/gif/png/)
   (let ((nodenames (make-grasstable))
	 (flow-segments (identify-basic-blocks ast)))
      ; (debug-trace 22 "forward walk")
      (for-each (lambda (f)
		   (walk-flow-segment f 
			     (lambda (b)
				(grasstable-put! nodenames b (mkstr "node" (basic-block-i b))))))
		flow-segments)
      ; (debug-trace 22 "backward walk")
      (fluid-let ((*ast-print-depth* 2)
		  (*ast-print-brief* #t)
		  (*ast-brief-omit* '(location)))
	 (print "digraph " #\" "flow-graph" #\" " {")
	 (print " node [shape=box];")
	 (for-each (lambda (flow-segment)
		      (walk-flow-segment flow-segment
		       ;(flow-segment-start flow-segment)
;		       (flow-segment-end flow-segment)
;		       basic-block-succ
;		       basic-block-pred
				(lambda (block)
				   (print  (grasstable-get nodenames block)
					   " [ label = " #\"
					   (grasstable-get nodenames block) ": "
					   (basic-block-place-it-started block)
					   ":\\l"
					   (pregexp-replace* "\""
							     (pregexp-replace* "\n" 
									       (with-output-to-string
										  (lambda ()
										     (for-each print-pretty-ast
											       (basic-block-code block))))
									       "\\\\l")
							     "'")
					   #\" " ];")
				   (for-each (lambda (b)
						(print (grasstable-get nodenames block)
						       " -> " 
						       (grasstable-get nodenames b)
						       #\;))
					     (basic-block-succ block)
					     ;; uncomment this to make it a backwards walk
;					     (basic-block-pred block)
					     ))))
		   flow-segments)
	 (print "}")) ))
   

(define (walk-flow-segment segment frobber-to-apply)
   ;;visit each basic block in a flow segment once
   (let ((seen (make-hashtable))
	 (visited 0))
      (for-each (lambda (node)
		   (debug-trace 20 "walk-flow-segment: frobbing node" (basic-block-i node) )
		   (frobber-to-apply node))
		;; the blocks are pushed onto the list, so they end up
		;; in reverse order.  Odd things happen if you get
		;; them backwards.
		(reverse (flow-segment-node-list segment)))))

(define (walk-flow-segment-backwards segment frobber-to-apply)
   ;;visit each basic block in a flow segment once
   (let ((seen (make-hashtable))
	 (visited 0))
      (for-each (lambda (node)
		   (frobber-to-apply node))
		 (flow-segment-node-list segment))))



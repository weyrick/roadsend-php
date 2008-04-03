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
(module php-macros
   (export (add-function-name-to-warnings function-name code)))

;; defalias will tuck aliases in here, in an attempt to get the right
;; name in add-function-name-to-warnings.  Kinda fiddly, but whatever.
(define *aliases-for-errors* (make-hashtable))

(define-macro (defbuiltin (name . params) . code)
   (let ((retvalname (gensym 'retval)))
      `(begin
	  (define (,name ,@(param-names params))
	     ,@(if *fast-build*
		  (add-function-name-to-warnings name code)
		  (profile-wrap name
				(trace-wrap 'unset name (param-names params)
					    (add-function-name-to-warnings name code)))))
	  ,(generate-store-signature 'fixed name params))))

;;XXX maybe save up until the last form in the file, and then dump all of the signatures into it as a function, and then call that function, to cut down on global relocs.


(define-macro (defbuiltin-v (name . params) . code)
   (let ((param-names-reversed (reverse (param-names params)))
         (retvalname (gensym 'retval)))
      `(begin
	  ,(if (> (length param-names-reversed) 1)
	       `(define (,name ,@(reverse (cdr param-names-reversed)) . ,(car param-names-reversed))
		   ,@(if *fast-build*
			 (add-function-name-to-warnings name code)
			 (profile-wrap name
				       (trace-wrap 'unset name (param-names params)
						   (add-function-name-to-warnings name code)))))
	       `(define (,name . ,(car param-names-reversed))
		   ,@(if *fast-build*
			 (add-function-name-to-warnings name code)		   
			 (profile-wrap name
				       (trace-wrap 'unset name (param-names params)
						   (add-function-name-to-warnings name code))))))
	  ,(generate-store-signature 'variable name params))))

(define *fast-build* (member "-unsafe" (command-line)))

(define (trace-wrap class-name name param-names code)
   (let ((retvalname (gensym 'ret)))
      `((when *track-stack?* (push-stack ',class-name ',name ,@param-names))
	(let ((,retvalname (begin ,@code)))
	   (when *track-stack?* (pop-stack))
	   ,retvalname))))

(define (profile-wrap name code)
   (let ((retvalname (gensym 'ret)))
      `((when *source-level-profile* (profile-enter ',name))
	(let ((,retvalname (begin ,@code)))
	   (when *source-level-profile* (profile-leave ',name))
	   ,retvalname))))

(define-macro (defalias alias name)
   (hashtable-put! *aliases-for-errors* name alias)
   `(store-alias ',alias ',name))

(define-macro (defconstant name value)
   `(begin
       (define ,name (coerce-to-php-type ,value))
       (store-persistent-constant ,(symbol->string name) ,name)))

(define-macro (update-constant name value)
   `(begin
       (set! ,name (coerce-to-php-type ,value))
       (store-persistent-constant ,(symbol->string name) ,name)))


;this is simple, but it would save memory to put the descriptions in a table
(define-macro (defresource name description . fields)
   (let ((constructor-name
	  (string->symbol
	   (string-append
	    (symbol->string name) "-resource"))))
      `(begin
	  (define-struct ,name
	     (description ,description)
             id
	     ,@fields)
          ;; please use this constructor, not the normal struct constructor
	  (define (,constructor-name . args)
	     (let ((resource (apply ,name ,description *resource-id-counter* args)))
                ;; if we keep a count for each resource type, and
                ;; define a reasonable maximum of outstanding
                ;; resources of that type when defining the resource,
                ;; and force a GC when we've exceeded the counter,
                ;; with a finalizer that decrements the counter, and
                ;; preferably a user-initiated resource free path like
                ;; fclose or mysql_close that decrements it too, we
                ;; should be okay.  Maybe not as immediate as
                ;; reference counting, but it should still usually
                ;; mostly work.  For now I'm ad-hoc'ing it for files
                ;; and mysql connections.
                (set! *resource-id-counter* (+ 1 *resource-id-counter*))
;                (set! *resource-list* (cons resource *resource-list*))
                resource)))))
   
;;;get all of the names of the params in a defbuiltin
(define (param-names params)
   (map (lambda (a)
	   (match-case a
	      ;reference param
	      ((ref . ?x)
	       x)
	      ;optional param
	      (((and ?x (? symbol?)) ?y)
	       x)
	      ;optional reference param
	      (((ref . (and ?x (? symbol?))) ?y)
	       x)
	      ;normal param
	      ((and ?x (? symbol?))
	       x)
	      
	      (else
	       (error 'defbuiltin (format "syntax error in signature at ~a" a) a))))
	params))

;same in signatures
(define t-required 0)
(define t-reference 1)
(define t-optional 2)
(define t-optional-reference 3)
;function types, same in signatures
(define ft-main 0)
(define ft-builtin 1)
(define ft-user 2)
(define ft-builtin-constructor 3)
(define ft-builtin-method 4)
(define ft-compat 5)

(define (generate-store-signature arity-type name params)
   (let ((maximum-arity (case arity-type
			   ((fixed) (length params))
			   ((variable) -1)
			   (else (error 'generate-store-signature
					"unknown arity type"
					arity-type))))
	 (minimum-arity 0)
	 (store-routine (case (length params)
			   ((0) 'store-signature-0)
			   ((1) 'store-signature-1)
			   ((2) 'store-signature-2)
			   ((3) 'store-signature-3)
			   (else 'store-signature)))
	 (brief-params '()))
      (map (lambda (a)
	      (match-case a
		 ;reference param
		 ((ref . ?x)
		  (set! minimum-arity (+fx minimum-arity 1))
		  (set! brief-params
			(cons* t-reference `',x 0 brief-params)))
		 ;optional param
		 (((and ?x (? symbol?)) ?y)
		  (set! brief-params
			(cons* t-optional `',x `',y brief-params)))
		 ;optional reference param
		 (((ref . (and ?x (? symbol?))) ?y)
		  (set! brief-params
			(cons* t-optional-reference `',x `',y brief-params)))
		 ;normal param
		 ((and ?x (? symbol?))
		  (set! minimum-arity (+fx minimum-arity 1))
		  (set! brief-params
			(cons* t-required `',x 0 brief-params)))
		 (else
		  (error 'generate-store-signature
			 (format "syntax error in function signature at ~a" a)
			 params))))
	   (reverse params))
      `(,store-routine ,name ,ft-builtin ',(current-extension) ',name ,minimum-arity ,maximum-arity ,@brief-params)))

(define (current-extension)
   (basename (pwd)))

;; utility function that magically rewrites code to include the
;; function name in the warnings.
(define (add-function-name-to-warnings function-name code)
   (when (hashtable-get *aliases-for-errors* function-name)
      (set! function-name (hashtable-get *aliases-for-errors* function-name)))
   (when (symbol? function-name)
      (set! function-name (symbol->string function-name)))
   (match-case code
      ((php-warning ???-)
       `(php-warning ,function-name "():  " ,@(cdr code)))
      ((php-error ???-)
       `(php-error ,function-name "():  " ,@(cdr code)))
      ((php-notice ???-)
       `(php-notice ,function-name "():  " ,@(cdr code)))
      ((? pair?)
       (map (lambda (code)
               (add-function-name-to-warnings function-name code))
            code))
      (else code)))

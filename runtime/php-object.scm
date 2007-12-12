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

(module php-object
   (include "php-runtime.sch")
   (import (php-runtime "php-runtime.scm")
	   (elong-lib "elongs.scm")
	   (grass "grasstable.scm")
	   (php-hash "php-hash.scm")
	   (utils "utils.scm")
	   (signatures "signatures.scm")	   
	   (php-errors "php-errors.scm"))
   ; for pcc scheme repl
   (eval (export-module))
   (export
    +constructor-failed+
    ; definitions
    (define-php-class name extends implements flags)
    (define-extended-php-class name extends implements flags getter setter copier)
    (define-php-property class-name property-name default-value visibility static?)
    (define-php-method class-name method-name flags method)
    (php-class-def-finalize name)
    ; types
    (convert-to-object doohickey)
    (clone-php-object obj::struct)
    (copy-php-object obj::struct old-new)
    ; reflection
    (php-object-props obj)
    (php-class-methods class-name)
    (php-object-class obj)
    (php-object-parent-class obj)
    (php-class-parent-class class-name)
    (php-object-id obj)
    (get-declared-php-classes)
    ; tests
    (php-object? obj)
    (php-class-exists? class-name)
    (php-class-method-exists? class-name method-name)
    (php-object-is-subclass obj class-name)
    (php-class-is-subclass subclass superclass)
    (php-object-is-a obj class-name)
    (php-object-compare obj1 obj2 identical?)
    (internal-object-compare o1 o2 identical? seen)
    (php-object-instanceof a b)
    ; properties
    (php-class-props class-name)
    (php-object-property/index obj::struct property::int property-name)
    (php-object-property/string obj property::bstring access-type)
    (php-object-property-ref/string obj property::bstring access-type)
    (php-object-property-set!/string obj property::bstring value access-type)
    (php-object-property-h-j-f-r/string obj property::bstring access-type)
    (php-object-property obj property access-type)
    (php-object-property-ref obj property access-type)
    (php-object-property-set! obj property value access-type)
    (php-class-static-property class-name property access-type)
    (php-class-static-property-ref class-name property access-type)    
    (php-class-static-property-set! class-name property value access-type)
    (php-object-property-honestly-just-for-reading obj property access-type)
    ; visibility
    (php-object-property-visibility obj prop context)
    (php-class-static-property-visibility class prop context)
    (php-method-accessible obj-or-class method-name context)
    ; methods
    (make-php-object properties)
    (construct-php-object class-name . args)
    (construct-php-object-sans-constructor class-name)
    (call-php-method obj method-name . call-args)
    (call-php-method-0 obj method-name)
    (call-php-method-1 obj method-name arg)
    (call-php-method-2 obj method-name arg1 arg2)
    (call-php-method-3 obj method-name arg1 arg2 arg3)
    (call-php-parent-method parent-class-name obj method-name . call-args)
    (call-static-php-method class-name obj method-name . call-args)
    ; constants
    (define-class-constant class-name constant-name value)
    (lookup-class-constant class-name constant-name)    
    ; custom properties
    (php-object-custom-properties obj)
    (php-object-custom-properties-set! obj props)
    ; misc
    (init-php-object-lib)
    (pretty-print-php-object obj)
    (php-object-for-each-with-ref-status obj::struct thunk::procedure)
    ;
    ))

;;;;objects, woohoo!
(define-struct %php-object
   ;;instantiation id ::bint
   id
   ;;class is a pointer to the class of this object ::struct
   class
   ;;properties is a vector of properties. it starts as a copy of
   ;;the defaults from php-class properties vector ::vector
   properties
   ;;extended properties is either #f or a php-hash of additional properties
   extended-properties
   ;;this is where custom properties can be stored, for example
   custom-properties)

(define-struct %php-class
   ;;print-name is the class name as the user wrote it (case sensitive) ::bstring
   print-name
   ;;the canonical version of the class name (case insensitive) ::bstring
   name
   ;;list of parent %php-class pointers. this will have one item unless
   ;;this is an interface ::pair
   extends
   ;;list of interfaces %php-class pointers this class implements ::pair
   implements
   ;; class flags: interface, abstract, final ::pair
   flags
   ;; the constructor method if available
   constructor-proc
   ;; the destructor method if available   
   destructor-proc
   ;;a hashtable mapping names of declared properties to an index in a property vector
   declared-property-offsets
   ;; static properties: like declared-property-offsets, a hash table with index to properties
   static-property-offsets   
   ;;properties is a vector of all properties (which points to actual php data)
   ;;the values here are declared defaults, unless it's static in which case it's the
   ;;actual current value ::vector
   properties
   ;;hash of property visibility (protected and private only).
   ;;note: also stores static property visibility
   prop-visibility
   ;;extended properties is either #f or a php-hash of non-declared properties
   extended-properties
   ;;methods is a php-hash of methods, keyed by canonical method name, value is %php-method
   methods
   ;;this overrides the normal property lookup
   custom-prop-lookup
   ;;this overrides the normal property set
   custom-prop-set
   ;;the copier for the custom properties
   custom-prop-copy
   ;;php-hash of class constants, keyed by name (case sensitive), value is a literal
   class-constants)

; custom accessor. this is the normal case for classes,
; where we have only one parent
(define (%php-class-parent-class the-class::struct)
   (if (null? (%php-class-extends the-class))
       #f
       (car (%php-class-extends the-class))))

(define (%php-class-interface? the-class::struct)
   (if (member 'interface (%php-class-flags the-class))
       #t
       #f))

(define (%php-class-abstract? the-class::struct)
   (if (member 'abstract (%php-class-flags the-class))
       #t
       #f))

(define-struct %php-method
   ;; print name (case sensitive) ::bstring
   print-name
   ;; pointer to the original defining %php-class ::struct
   origin-class
   ;; public, protected, private ::symbol
   visibility
   ;; flags ::bbool
   final?
   abstract?
   ;; method ::procedure
   proc)

(define *highest-instantiation* 0)

;
; PHP5 case sensitivity:
;  - class names are NOT case sensitive
;  - method names are NOT case sensitive
;  - properties ARE case sensitive
; 
; regardless of whether it is case sensitive, each item must
; know the case it was defined as, because it's shown that way
; by various reporting functions
;

(define (php-object-custom-properties obj)
   "returns whatever the custom context was set to when defining the extended class"
   (%php-object-custom-properties obj))

(define (php-object-custom-properties-set! obj props)
   "returns whatever the custom context was set to when defining the extended class"
   (%php-object-custom-properties-set! obj props))

(define (copy-properties-vector old-properties)
   (let* ((properties-len (vector-length old-properties))
	  (new-properties (make-vector properties-len '())))
      (let loop ((i 0))
	 (when (< i properties-len)
	    (let ((old-prop (vector-ref old-properties i)))
	       (if (container-reference? old-prop)
		   (vector-set! new-properties i old-prop)
		   (vector-set! new-properties i
				(copy-php-data old-prop))))
	    (loop (+ i 1))))
      new-properties))

; shallow copy. call __clone on new object if it exists
(define (clone-php-object obj::struct)
   (let ((new-obj (copy-php-object obj #f)))
      (when (php-class-method-exists? (php-object-class obj) "__clone")
	 (call-php-method-0 new-obj "__clone"))
      new-obj))

(define (copy-php-object obj::struct old-new)
   (let* ((new-obj (%php-object (%next-instantiation-id) (%php-object-class obj) #f #f #f)))
      ;;copy the old declared properties
      (%php-object-properties-set!
       new-obj (copy-properties-vector (%php-object-properties obj)))
      ;;copy the old extended properties, if any
      (when (%php-object-extended-properties obj)
	 (%php-object-extended-properties-set!
	  new-obj
	  (copy-php-hash (%php-object-extended-properties obj) old-new)))
      (when (%php-object-custom-properties obj)
	 (%php-object-custom-properties-set!
	  new-obj
	  (let ((c (%php-class-custom-prop-copy (%php-object-class obj))))
	     (if c
		 (c (%php-object-custom-properties obj))
		 (error 'copy-php-object "no custom copier defined for object with custom properties" obj)))))
      new-obj))


(define (make-php-object properties)
   "Make an instance of an anonymous class with properties but no
methods.  Feed me a php-hash where the keys are the properties and the
values the values."
   (let ((new-object (construct-php-object 'stdclass)))
      (unless (php-hash? properties)
	 (error 'make-php-object "properties must be a php-hash" properties))
      (%php-object-extended-properties-set! new-object properties)
      new-object))

;for type coercion 
(define (convert-to-object doohickey)
   (when (container? doohickey)
      (set! doohickey (container-value doohickey)))
   (cond
      ((php-object? doohickey) doohickey)
      ((php-null? doohickey) (make-php-object (make-php-hash)))
      ((php-hash? doohickey) (make-php-object doohickey))
      (else
       (make-php-object (let ((props (make-php-hash)))
 			   (php-hash-insert! props "scalar" doohickey)
 			   props)))))
	  

(define (php-object-props obj)
   "return a php-hash of the keys and properties in an object"
   (if (not (php-object? obj))
       #f
       (let ((property-hash (make-php-hash))
	     (offsets-table (%php-class-declared-property-offsets
					(%php-object-class obj)))
	     (declared-props (%php-object-properties obj)))
	  ;;first copy in the declared properties. we loop over the vector instead
	  ;;of for-each'ing over the hashtable to preserve the ordering.
	  (let loop ((i 0))
	     (when (< i (vector-length declared-props))
		(let ((prop-value (vector-ref declared-props i))
		      (prop-key (hashtable-get offsets-table i)))
		   ; if it's not in offsets table, it's a static and we skip it
		   (when prop-key
		      (php-hash-insert! property-hash
					prop-key
					(if (container-reference? prop-value)
					    prop-value
					    (container-value prop-value)))
		      (loop (+fx i 1))))))
	  ;;now copy in the extended properties
	  (php-hash-for-each (%php-object-extended-properties obj)
	     (lambda (k v)
		(php-hash-insert! property-hash k v)))
	  property-hash)))

(define (php-object-for-each-with-ref-status obj::struct thunk::procedure)
   "Thunk will be called once on each key/value set. ref status is available to thunk"
   (let ((property-hash (make-php-hash))
	 (offsets-table (%php-class-declared-property-offsets
			 (%php-object-class obj)))
	 (declared-props (%php-object-properties obj)))
      (let loop ((i 0))
	 (when (< i (vector-length declared-props))
	    (let ((prop-value (vector-ref declared-props i))
		  (prop-key (hashtable-get offsets-table i)))
;  	       (fprint (current-error-port) "key is " (mkstr (hashtable-get offsets-table i)))
;  	       (fprint (current-error-port) "value is " (mkstr prop-value))
;  	       (fprint (current-error-port) "ref-status is " (mkstr (container-reference? prop-value)))
	       ; if we don't have prop key, it's a static and we skip it
	       (when prop-key
		  (thunk ;note the reverse lookup to get the name
		   (mkstr prop-key)
		   ;		(if (container-reference? prop-value)
		   (maybe-unbox prop-value)
		   ;		    (container-value prop-value))
		   (container-reference? prop-value))
		  (loop (+fx i 1))))))
      ;;now copy in the extended properties
      (php-hash-for-each-with-ref-status
       (%php-object-extended-properties obj) thunk)))

(define (php-class-props class-name)
   "return a php-hash of the keys and properties in a class"
   (let ((the-class (%lookup-class class-name)))
      (if (not (%php-class? the-class))
	  #f
	  (let ((property-hash (make-php-hash))
		(offsets-table (%php-class-declared-property-offsets the-class))
		(declared-props (%php-class-properties the-class)))
	     ;;first copy in the declared properties. we loop over the vector instead
	     ;;of for-each'ing over the hashtable to preserve the ordering.
	     (let loop ((i 0))
		(when (< i (vector-length declared-props))
		   (let ((prop-value (vector-ref declared-props i))
			 (prop-key (hashtable-get offsets-table i)))
		      ; if it's not in offsets table, it's a static and we skip it
		      (when prop-key
			 (php-hash-insert! property-hash
					   ;note the reverse lookup to get the name
					   prop-key
					   (if (container-reference? prop-value)
					       prop-value
					       (container-value prop-value))))
		      (loop (+fx i 1)))))
	     ;;now copy in the extended properties
	     (php-hash-for-each (%php-class-extended-properties the-class)
		(lambda (k v)
		   (php-hash-insert! property-hash k v)))
	     property-hash))))

(define (php-object-is-subclass obj class-name)
   (if (not (php-object? obj))
       #f
       (let ((the-class (%lookup-class class-name)))
	  (if (not (%php-class? the-class))
	      #f
	      (%subclass? (%php-object-class obj) the-class)))))

(define (php-class-is-subclass subclass superclass)
   (let ((the-subclass (%lookup-class subclass))
	 (the-superclass (%lookup-class superclass)))
;      (unless (%php-class? the-subclass)
;	 (debug-trace 1 "warning, class " subclass " not defined"))
;      (unless (%php-class? the-superclass)
;	 (debug-trace 1 "warning, class " superclass " not defined"))
      (and (%php-class? the-subclass)
	   (%php-class? the-superclass)
	   (%subclass? the-subclass the-superclass))))

(define (php-object-is-a obj class-name)
   (if (not (php-object? obj))
       #f
       (let ((the-class (%lookup-class class-name)))
	  (if (not (%php-class? the-class))
	      #f
	      (or (eqv? (%php-object-class obj) the-class)
		  (%subclass? (%php-object-class obj) the-class)
		  (%implements? (%php-object-class obj) the-class))))))

(define (php-class-exists? class-name)
   (let ((c (%lookup-class-with-autoload class-name)))
      (if (%php-class? c)
	  #t
	  #f)))

(define (php-class-methods class-name)
   (let ((the-class (%lookup-class class-name)))
      (if (not the-class)
	  #f
	  (%php-class-method-reflection the-class))))

(define (php-class-method-exists? class-name method-name)
   (let ((mlist (php-class-methods class-name)))
      (if mlist ;is this test REALLY necessary?
;	  (php-hash-in-array? mlist (string-downcase (mkstr method-name)) #f)
          (php-hash-in-array? mlist (mkstr method-name) #f)
	  #f)))

(define (method-minimum-arity method)
   ;;one less than the procedure arity, since the first argument is $this
   (-fx (let ((c (procedure-arity method)))
	   (if (<fx c 0)
	       (-fx (- c) 1)
	       c))
	1))

(define (method-correct-arity? method::procedure arity::int)
   (correct-arity? method (+ 1 arity)))

(define (get-callable-method obj method-name)
   (if (not (php-object? obj))
       (php-error "Unable to call method on non-object " obj)
       (let ((the-method (%lookup-method (%php-object-class obj) method-name)))
	  (unless the-method
	     (php-error "Call to undefined method "
			(%php-class-print-name (%php-object-class obj))
			"::" method-name "()"))
	  (when (%php-method-abstract? the-method)
	     (php-error (format "Cannot call abstract method ~a::~a()" (%php-class-print-name
									(%php-object-class obj)) method-name)))
	  (%php-method-proc the-method))))

(define (call-php-method obj method-name . call-args)
   (let ((the-method (get-callable-method obj method-name)))
      (if the-method
	  ;; We could just apply the method to (map maybe-box call-args), but
	  ;; that won't signal a nice error for methods compiled in extensions.
          (apply the-method obj (adjust-argument-list the-method call-args))
	  #f)))

(define (adjust-argument-list method args)
   ;; make sure the arguments are boxed and that the arity is okay.
   (if (method-correct-arity? method (length args))
       (map maybe-box args)
       (let ((minimum-arity (method-minimum-arity method)))
          (let loop ((i 0)
                     (new-args '())
                     (args args))
             (if (= i minimum-arity)
                 (reverse! new-args)
                 (if (pair? args)
                     (loop (+ i 1)
                           (cons (maybe-box (car args)) new-args)
                           (cdr args))
                     (loop (+ i 1)
                           (cons (make-container NULL) new-args)
                           '())))))))

(define (call-php-method-0 obj method-name)
   (let ((the-method (get-callable-method obj method-name)))
      (if the-method
          (the-method obj)
	  #f)))

(define (call-php-method-1 obj method-name arg)
   (let ((the-method (get-callable-method obj method-name)))
      (if the-method
          (the-method obj (maybe-box arg))
	  #f)))

(define (call-php-method-2 obj method-name arg1 arg2)
   (let ((the-method (get-callable-method obj method-name)))
      (if the-method
          (the-method obj (maybe-box arg1) (maybe-box arg2))
	  #f)))

(define (call-php-method-3 obj method-name arg1 arg2 arg3)
   (let ((the-method (get-callable-method obj method-name)))
      (if the-method
          (the-method obj (maybe-box arg1) (maybe-box arg2) (maybe-box arg3))
	  #f)))

(define (call-php-parent-method parent-class-name obj method-name . call-args)
   (let ((the-class (%lookup-class parent-class-name)))
      (unless the-class
	 (php-error
	  (format "Parent method call: Unable to call method parent::~A: can't find parent class ~A"
		  method-name parent-class-name)))
      (let ((the-method (%lookup-method the-class method-name)))
	 ; if the method we tried was __construct, and we didn't find it, try instead a php4 compatible constructor
	 (when (and (eqv? the-method #f) (string=? (%method-name-canonicalize method-name) "__construct"))
	    (set! the-method (%lookup-method the-class parent-class-name)))
	 (unless the-method
	    (php-error "Parent method call: Unable to find method "
		       method-name " of class " parent-class-name))
	 (when (%php-method-abstract? the-method)
	    (php-error (format "Cannot call abstract method ~a::~a()" parent-class-name method-name)))
	 (apply (%php-method-proc the-method) obj (adjust-argument-list (%php-method-proc the-method) call-args)))))


(define (call-static-php-method class-name obj method-name . call-args)
   (let ((the-class (%lookup-class-with-autoload class-name)))
      (unless the-class
	 (php-error "Calling static method " method-name
		    ": unable to find class definition " class-name))
      (let ((the-method (%lookup-method-proc the-class method-name)))
	 (unless the-method
	    (php-error "Calling static method " class-name "::" method-name ": undefined method."))
	 ;
	 ;
	 ; XXX FIXME: if this method wasn't defined static, make sure we have a compatible
	 ;            this context, otherwise throw a fatal
	 ;
         (apply the-method obj (adjust-argument-list the-method call-args)))))


(define (php-object? obj)
   (%php-object? obj))

(define (php-class? obj)
   (%php-class? obj))

(define (get-custom-lookup obj)
   (%php-class-custom-prop-lookup
    (%php-object-class obj)))

(define (get-custom-set obj)
   (%php-class-custom-prop-set
    (%php-object-class obj)))

(define (php-object-property/index obj::struct property::int property-name)
   "this is just for declared classes in user code.  it's an optimization."
   (assert (property property-name) (= (hashtable-get (%php-class-declared-property-offsets (%php-object-class obj))
						      (%property-name-canonicalize property-name))
				       property))
   (vector-ref (%php-object-properties obj) property)
   
   )


(define (php-object-property obj property access-type)
   (if (php-object? obj)
       (if (procedure? (get-custom-lookup obj))
	   (do-custom-lookup obj property #f)
	   (%lookup-prop obj property access-type))
       (begin
	  (php-warning "Referencing a property of a non-object")
	  NULL)))

(define (php-object-property-honestly-just-for-reading obj property access-type)
   (if (php-object? obj)
       (let ((l (get-custom-lookup obj)))
	  (if (procedure? l)
	      (do-custom-lookup obj property #f)	      
	      (%lookup-prop-honestly-just-for-reading obj property access-type)))
       (begin
	  (php-warning "Referencing a property of a non-object")
	  NULL)))

(define (php-object-property-ref obj property access-type)
   (if (php-object? obj)
       (let ((l (get-custom-lookup obj)))
	  (if (procedure? l)
	      (do-custom-lookup obj property #t)
	      (%lookup-prop-ref obj property access-type)))
       (begin
	  (php-warning "Referencing a property of a non-object")
	  (make-container NULL))))

(define (php-object-property-set! obj property value access-type)
   (if (php-object? obj)
       (let ((l (get-custom-set obj)))
	  (if (procedure? l)
	      (do-custom-set! obj property value)
	      (%assign-prop obj property value access-type)))
       (begin
	  (php-warning "Assigning to a property of a non-object")
	  NULL))
   value)


(define (do-custom-lookup obj property ref?)
   (debug-trace 4 "custom lookup of " (php-object-class obj) "->" property)
;   (if ref?
       ;; so spake the engine of zend
;       (php-error "Cannot create references to overloaded objects")
       (let loop ((cls (%php-object-class obj)))
	  (let ((lookup (%php-class-custom-prop-lookup cls)))
	     (if (procedure? lookup)
		 (let ((val (lookup obj property ref? (lambda ()
							 (loop (%php-class-parent-class cls))))))
		    (if ref? (maybe-box val) (maybe-unbox val)))
		 (if ref?
		     (%lookup-prop-ref obj property 'all)
		     (%lookup-prop obj property 'all))))))
;)

(define (do-custom-set! obj property value)
   (let loop ((cls (%php-object-class obj)))
      (let ((set (%php-class-custom-prop-set cls)))
	 (if (procedure? set)
	     (set obj property (container? value) value  (lambda ()
							   (loop (%php-class-parent-class cls))))
	     (%assign-prop obj property value 'public)))))

;
; a must be an object
; b can be a class (or interface) name OR
;   a string containing a class name OR
;   an instantiated object we get class (or interface) name from
(define (php-object-instanceof a b)
   (let ((l (maybe-unbox a))
	 (r (maybe-unbox b)))
      (unless (php-object? l)
	 (php-error "instanceof expects an object instance"))
      (if (php-object? r)
	  ; use object to get class to compare against
	  (php-object-is-a l (php-object-class r))
	  ; consider b as a literal class name
	  (php-object-is-a l (mkstr r)))))

(define (php-object-compare o1 o2 identical?)
   (internal-object-compare o1 o2 identical? (make-grasstable)))

(define (internal-object-compare o1 o2 identical? seen)
   (let ((compare-declared-properties
	  (lambda (o1 o2 seen)
	     (let loop ((i 0)
		       (continue? #t))
	       (if (>= i (vector-length (%php-object-properties o1)))
		   #t
		   (if continue?
		       (loop (+ i 1)
			     (let ((o1-value (vector-ref (%php-object-properties o1) i))
				   (o2-value (vector-ref (%php-object-properties o2) i)))
				(cond
				   ((and (php-object? o1-value)
					 (php-object? o2-value))
				    (if (and (grasstable-get o1-value seen)
					     (grasstable-get o2-value seen))
                                        #t
					(internal-object-compare o1-value o2-value identical? seen)))
				   ((and (php-hash? o1-value)
					 (php-hash? o2-value))
				    (if (and (grasstable-get o1-value seen)
					     (grasstable-get o2-value seen))
                                        #t
                                        (zero? (internal-hash-compare o1-value o2-value identical? seen))))
				   (else
				    ((if identical? identicalp equalp) o1-value o2-value)))))
		       #f)))))
	 ;;differently ordered properties in objects mean that they are not ===,
	 ;;but since the objects have to be of the same class to be compared,
	 ;;and the same class naturally declares its properties in the same
	 ;;order, that can only happen in the extended properties.
	 ;;internal-hash-compare will handle it properly, so we don't need to
	 ;;explicitly property order at all.
	 (compare-extended-properties
	  (lambda (o1 o2 seen)
	     (if (%php-object-extended-properties o1)
		(if (%php-object-extended-properties o2)
                    (let ((value (zero? (internal-hash-compare (%php-object-extended-properties o1)
                                                               (%php-object-extended-properties o2)
                                                               identical? seen))))
                       value)
		    #f)
		(if (%php-object-extended-properties o2)
		    #f
		    #t)))))
      ;;the return value is #f if the objects are of different classes
      ;;0 if they are identical, 1 if they are different (but of the same class)
      (if (not (string=? (php-object-class o1)
			 (php-object-class o2)))
	  #f
	  ;only compare objects of the same class
	  (begin
	     (grasstable-put! seen o1 #t)
	     (grasstable-put! seen o2 #t)
	     (if (and (compare-declared-properties o1 o2 seen)
		      (compare-extended-properties o1 o2 seen))
		 0
		 1)))))

(define (php-object-id obj)
   (if (not (php-object? obj))
       #f
       (%php-object-id obj)))
   
(define (php-object-class obj)
   (if (not (php-object? obj))
       #f
       (%php-class-print-name (%php-object-class obj))))

(define (php-object-parent-class obj)
   (if (not (php-object? obj))
       #f
       (%php-class-print-name
	(%php-class-parent-class
	 (%php-object-class obj)))))

(define (php-class-parent-class class-name)
   (let ((the-class (%lookup-class class-name)))
      (if (not (php-class? the-class))
          #f
	  (let ((parent-class (%php-class-parent-class the-class)))
	     (if parent-class
		 (if (string-ci=? (%php-class-print-name parent-class) "stdclass")
		     #f
		     (%php-class-print-name (%php-class-parent-class the-class)))
		 #f)))))


; case insensitive
(define (%class-name-canonicalize name)
   "define class names as case-insensitive strings"
   (string-downcase (mkstr name)))

; case insensitive
(define (%method-name-canonicalize name)
   "define method names as case-insensitive strings"
   (string-downcase (mkstr name)))

; always case sensitive
(define (%property-name-canonicalize name)
   "define property names as case-_sensitive_ strings"
   (if (string? name) name (mkstr name)))

(define %php-class-registry 'unset)
(define %php-autoload-registry 'unset)

(define (get-declared-php-classes)
   (let ((clist (make-php-hash)))
      (hashtable-for-each %php-class-registry
			  (lambda (k v)
			     (php-hash-insert! clist :next (%php-class-print-name v))))
      clist))

(define (init-php-object-lib)
   (set! %php-class-registry (make-hashtable))
   (set! %php-autoload-registry (make-hashtable))
   (set! *highest-instantiation* 0)
   ;define the root of the class hierarchy
   (let ((stdclass (%php-class "stdClass"       ; print name
			       "stdclass"       ; canonical name
			       '()              ; extends
			       '()              ; implements
			       '()              ; flags
			       #f               ; constructor proc
			       #f               ; destructor proc
			       (make-hashtable) ; declared prop offsets
			       (make-hashtable) ; static prop offets
			       (make-vector 0)  ; props
			       (make-hashtable) ; prop visibility
			       (make-php-hash)  ; extended properties
			       (make-php-hash)  ; methods
			       #f               ; custom prop lookup
			       #f               ; custom prop set
			       #f               ; custom prop copy
			       (make-php-hash)  ; class constants
			       ))
	 (inc-class (%php-class "__PHP_Incomplete_Class"       ; print name
			       "__php_incomplete_class"       ; canonical name
			       '()              ; extends
			       '()              ; implements
			       '()              ; flags
			       #f               ; constructor proc
			       #f               ; destructor proc
			       (make-hashtable) ; declared prop offsets
			       (make-hashtable) ; static prop offets
			       (make-vector 0)  ; props
			       (make-hashtable) ; prop visibility
			       (make-php-hash)  ; extended properties
			       (make-php-hash)  ; methods
			       #f               ; custom prop lookup
			       #f               ; custom prop set
			       #f               ; custom prop copy
			       (make-php-hash)  ; class constants
			       )))
      ;;default constructor
      (hashtable-put! %php-class-registry "stdclass" stdclass)
      (hashtable-put! %php-class-registry "__php_incomplete_class" inc-class)))

(define (%resolve-classes class-list)
   "return a list of resolved %php-class structures based on the list given
    in extends, or fatal in the process if we can't find them"
   (let ((ret-list '()))
      (for-each (lambda (class-name)
		   (let ((resolved-class (%lookup-class-with-autoload class-name)))
		      (if resolved-class
			  (set! ret-list (cons resolved-class ret-list))
			  (raise class-name))))
		class-list)
      (reverse ret-list)))

; inherit methods from extends and implements to new-class
; assumes extends and implements list is already resolved
(define (%inherit-methods new-class::struct)
   (let* ((extends-list (%php-class-extends new-class))
	  (implements-list (%php-class-implements new-class))
	  (parent-class (car extends-list)))
      ; first inherit non-abstract methods from direct parent if it's not abstract
      (unless (member 'abstract (%php-class-flags parent-class))
	 (php-hash-for-each (%php-class-methods parent-class)
			    (lambda (canonical-method-name the-method)
			       (unless (or (%php-method-abstract? the-method)
					   (eqv? (%php-method-visibility the-method) 'private))
				  (let ((new-method (%php-method (%php-method-print-name the-method)
								 (%php-method-origin-class the-method)
								 (%php-method-visibility the-method)
								 (%php-method-final? the-method)
								 #f ; abstract?
								 (%php-method-proc the-method))))
;    (debug-trace 0 "inherit non abstract: " (%php-class-print-name parent-class) "::" canonical-method-name " to " (%php-class-print-name new-class))
				     (php-hash-insert! (%php-class-methods new-class)
						       canonical-method-name
						       new-method))))))
      ; now do abstract methods
      (unless (and (null? extends-list)
		   (null? implements-list))
		(for-each
		 (lambda (the-class)
		    ;
		    ; for each method, create an abstract method in our new class
		    ; if they implement it in their class, it will be overwritten in define-php-method
		    ; if they don't it will be caught as an unimplemented abstract method
		    ;
		    (php-hash-for-each (%php-class-methods the-class)
				       (lambda (canonical-method-name the-method)
					  (when (%php-method-abstract? the-method)
					     (let ((existing-method (php-hash-lookup-honestly-just-for-reading (%php-class-methods new-class) canonical-method-name)))
						(when (or (php-null? existing-method)
							  (%php-method-abstract? existing-method))
						   ; if it already exists, and it's abstract, and the origin classes differ, we have a conflict
						   (unless (or (php-null? existing-method)
							       (string=? (%php-class-print-name (%php-method-origin-class existing-method))
									 (%php-class-print-name (%php-method-origin-class the-method))))
						      (php-error (format "Can't inherit abstract function ~A::~A() (previously declared abstract in ~A)"
									 (%php-class-print-name the-class)
									 (%php-method-print-name the-method)
									 (%php-class-print-name
									  (%php-method-origin-class existing-method)))))
						   ; we have either a new abstract method to inherit, or one to override
						   (let ((new-method (%php-method (%php-method-print-name the-method)
										  (%php-method-origin-class the-method)
										  (%php-method-visibility the-method)
										  #f ; final
										  #t ; abstract
										  'abstract-no-proc)))
;    (debug-trace 0 "inherit abstract: " (%php-class-print-name the-class) "::" canonical-method-name " to " (%php-class-print-name new-class))				
						      (php-hash-insert! (%php-class-methods new-class)
									canonical-method-name
									new-method))))))))
		 (append extends-list implements-list)))))
      
(define (define-php-class name extends implements flags)
   (if (%lookup-class name)
       #t ;leave the errors to the evaluator/compiler for now
       (let ((resolved-extends (if (null? extends)
				   (list (%lookup-class "stdclass"))
				   (with-exception-handler
				      (lambda (unknown-classname)
					 (php-error "Defining class " name ": unable to find parent class " unknown-classname))
				      (lambda ()
					 (%resolve-classes extends)))))
	     (resolved-implements (if (null? implements)
				      '()
				      (with-exception-handler
					 (lambda (unknown-classname)
					    (php-error "Interface  '" unknown-classname "' not found"))
					 (lambda ()
					    (%resolve-classes implements))))))
	  (let* ((parent-class (car resolved-extends))
		 (canonical-name (%class-name-canonicalize name))
		 (new-class (%php-class (mkstr name)
					canonical-name
					resolved-extends
					resolved-implements
					flags
                                        #f ; constructor
					#f ; destructor
					(copy-hashtable
					 (%php-class-declared-property-offsets parent-class))
					(copy-hashtable
					 (%php-class-static-property-offsets parent-class))					
					(copy-properties-vector (%php-class-properties parent-class))
					(copy-prop-visibility
					 (%php-class-prop-visibility parent-class))				 
					(copy-php-data (%php-class-extended-properties parent-class))
					(make-php-hash) ; methods we do below
					(%php-class-custom-prop-lookup parent-class)
					(%php-class-custom-prop-set parent-class)
					(%php-class-custom-prop-copy parent-class)
                                        (copy-php-data (%php-class-class-constants parent-class))
					)))
	     ; make sure implements only contains interfaces
	     (unless (null? resolved-implements)
		(for-each (lambda (the-class)
			     (unless (member 'interface (%php-class-flags the-class))
				(php-error (format "~a cannot implement ~a - it is not an interface" name (%php-class-print-name the-class)))))
			  resolved-implements))
	     ;
	     (%inherit-methods new-class)
	     (hashtable-put! %php-class-registry canonical-name new-class)))))

(define (define-extended-php-class name extends implements flags getter setter copier)
   "Create a PHP class with an overridden getter and setter.  The getter takes
four arguments: the object, the property, ref?, and the continuation.  The
continuation is a procedure of no arguments that can be invoked to get the
default property lookup behavior.  The setter takes an additional value
argument, before the continuation: (obj prop ref? value k)."
   ;xxx and a copier, and they can be false to inherit...
   (define-php-class name extends implements flags)
   (let ((klass (%lookup-class name)))
      (if (%php-class? klass)
	  (begin
	     (when getter (%php-class-custom-prop-lookup-set! klass getter))
	     (when setter (%php-class-custom-prop-set-set! klass setter))
	     (when copier (%php-class-custom-prop-copy-set! klass copier))
	     ;we set the print-name to be like php-gtk with its CamelCaps
	     (%php-class-print-name-set! klass name))
	  (error 'define-extended-php-class "could not define extended class" name))))

(define (copy-prop-visibility table)
   (let ((new-table (make-hashtable)))
      (hashtable-for-each table
	 (lambda (k v)
	    (unless (eqv? v 'private)
	       (hashtable-put! new-table k v))))
      new-table))

(define (copy-hashtable table)
   (let ((new-table (make-hashtable)))
      (hashtable-for-each table
	 (lambda (k v)
	    (hashtable-put! new-table k v)))
      new-table))

; XXX use copy-vector?
(define (cruddy-push-extend el vec)   
   ;yay, quadratic
   (let ((new (make-vector (+ 1 (vector-length vec)) '())))
      (let loop ((i 0))
	 (if (< i (vector-length vec))
	     (begin
		(vector-set! new i (vector-ref vec i))
		(loop (+ i 1)))
	     (vector-set! new i el)))
      new))

(define (vis->= vis1 vis2)
   (or (eqv? 'public vis1)
       (and (eqv? 'protected vis1) (eqv? 'protected vis2))
       (and (eqv? 'protected vis1) (eqv? 'private vis2))
       (and (eqv? 'private vis1) (eqv? 'private vis2))))

; XXX maybe make this required as separate param
(define (%extract-visibility method-flags)
   (let ((vis (or (member 'public method-flags)
		  (member 'protected method-flags)
		  (member 'private method-flags))))
      (if vis
	  (car vis)
	  ; ??
	  'public)))

(define (define-php-method class-name method-name flags method)
   (let ((the-class (%lookup-class class-name))
	 (visibility (%extract-visibility flags))
	 (final? (if (member 'final flags) #t #f))
	 (abstract? (if (member 'abstract flags) #t #f)))
      (unless the-class
	 (php-error "Defining method " method-name ": unknown class " class-name))
      ;; if this is an interface, this method must be abstract
      (when (and (member 'interface (%php-class-flags the-class))
		 (not abstract?))
	    (set! abstract? #t))
      ;; if method is abstract and class isn't, class becomes abstract-implied
      (when (and abstract? (not (member 'abstract (%php-class-flags the-class))))
	 (%php-class-flags-set! the-class (append '(abstract abstract-implied) (%php-class-flags the-class))))
      ; if class is an interface, visibility must be public
      (when (and (%php-class-interface? the-class)
		 (not (eqv? visibility 'public)))
	 (php-error (format "Access type for interface method ~a::~a() must be omitted" class-name method-name)))
      ;
      ;; can't be both final and abstract
      (when (and abstract? final?)
	 (php-error "Cannot use the final modifier on an abstract class member"))
      ;; visibility checks related to overridden methods
      (let* ((canon-method-name (%method-name-canonicalize method-name))
	     (overridden-method (php-hash-lookup (%php-class-methods the-class) canon-method-name)))
	 (unless (php-null? overridden-method)
	    ;; can't override a final method
	    (when (%php-method-final? overridden-method)
	       (php-error (format "Cannot override final method ~A::~A()"
				  (%php-class-print-name
				   (%php-class-parent-class the-class))
				  method-name
				  )))
	    ;; visibility must be same or better as overridden method
	    (unless (vis->= visibility (%php-method-visibility overridden-method))
	       (php-error (format "Access level to ~A::~A() must be ~A (as in class ~A)~A"
				  class-name
				  method-name
				  (%php-method-visibility overridden-method)
				  (%php-class-print-name
				   (%php-class-parent-class the-class))
				  (if (eqv? 'protected (%php-method-visibility overridden-method))
				      " or weaker"
				      "")				  
				  )))
	    )
	 ;; we are the origin
	 (let ((new-method (%php-method method-name
					the-class
					visibility
					final?
					abstract?
					method)))
	    ;; check if the method is a constructor
	    (when (or (string=? canon-method-name "__construct")
		      (and (not (%php-class-constructor-proc the-class))
			   (string=? canon-method-name (%php-class-name the-class))))
	       (%php-class-constructor-proc-set! the-class method))
	    ;; check if the method is a destructor
	    (when (string=? canon-method-name "__destruct")
	       (%php-class-destructor-proc-set! the-class method))
	    ;
;   (debug-trace 0 "defining " class-name "::" method-name " overridding: " (not (php-null? overridden-method)))
	    (php-hash-insert! (%php-class-methods the-class)
			      canon-method-name
			      new-method)))))

(define (mangle-property-private prop)
   "mangle given property string to private visibility"
   (mkstr prop ":private"))

(define (mangle-property-protected prop)
   "mangle given property string to protected visibility"
   (mkstr prop ":protected"))

(define (%property-name-mangle name visibility)
   (cond
      ((eqv? 'public visibility)
       name)
      ((eqv? 'private visibility)
       (mangle-property-private name))
      ((eqv? 'protected visibility)
       (mangle-property-protected name))))

(define (define-php-property class-name property-name default-value visibility static?)
   (let ((the-class (%lookup-class class-name)))
      (unless the-class
	 (php-error "Defining property " property-name ": unknown class " class-name))
      (when (%php-class-interface? the-class)
	 (php-error "Interfaces may not include member variables"))
      (let* ((properties (%php-class-properties the-class))
	     (offset (vector-length properties))
             (canonical-name (%property-name-canonicalize property-name))
	     (mangled-name (%property-name-mangle canonical-name visibility))
	     (offset-hash (if static?
			      (%php-class-static-property-offsets the-class)
			      (%php-class-declared-property-offsets the-class))))
         (aif (hashtable-get offset-hash mangled-name)
              ;; already defined, just set it
              (vector-set! properties it (make-container (maybe-unbox default-value)))
              ;; not defined yet, extend the properties vector and add
              ;; a new entry in the offset map
              (begin
                 (%php-class-properties-set!
                  the-class
                  (cruddy-push-extend (make-container (maybe-unbox default-value)) properties))
                 (hashtable-put! offset-hash
                                 mangled-name
                                 offset)
                 ;store the reverse, too
                 (hashtable-put! offset-hash
                                 offset
                                 mangled-name)
		 ;store visibility
		 (unless (eqv? 'public visibility)
		  (hashtable-put! (%php-class-prop-visibility the-class)
				  canonical-name
				  visibility)))))))

(define (php-class-def-finalize class-name)
   (let ((the-class (%lookup-class class-name)))
      (unless the-class
	 (php-error "Unable to finalize unknown class: " class-name))
      ; if this isn't an abstract class, fatal if there are any abstract methods unimplemented
      (unless (and (member 'abstract (%php-class-flags the-class))
		   (not (member 'abstract-implied (%php-class-flags the-class))))
	 (let ((acnt 0)
	       (amissing ""))
	    (php-hash-for-each (%php-class-methods the-class)
			       (lambda (k v)
				  (when (%php-method-abstract? v)
				     (set! acnt (+ acnt 1))
				     (set! amissing (mkstr amissing (if (string=? amissing "")
									""
									", ")
							   (%php-class-print-name (%php-method-origin-class v)) "::" (%php-method-print-name v))))))
	    (when (> acnt 0)
	       (php-error (format "Class ~A contains ~A abstract method~A and must therefore be declared abstract or implement the remaining methods (~A)"
				  class-name
				  acnt
				  (if (= acnt 1) "" "s")
				  amissing)))))))

(define (%lookup-class name)
   (hashtable-get %php-class-registry (%class-name-canonicalize name)))

; here we try magic __autoload global function if the class name is
; not found (PHP5 feature)
(define (%lookup-class-with-autoload name)
   (let ((the-class (%lookup-class name)))
      (if the-class
	  the-class
	  ; try autoload
	  (let ((canonical-name (%class-name-canonicalize name))
		(autoload-proc (get-php-function-sig "__autoload")))
	     (if autoload-proc
		 (unless (hashtable-get %php-autoload-registry canonical-name)
		    (hashtable-put! %php-autoload-registry canonical-name #t)
		    (php-funcall "__autoload" (mkstr name))
		    (%lookup-class name))
		 #f)))))

;;I think that all methods must be manifest when a class is defined
;;(i.e. before calling any of them), so we don't look at the parent
;;class.
(define (%lookup-method klass::struct name)
   (let ((m (php-hash-lookup (%php-class-methods klass) name)))
      (if (null? m)
	  (begin
	     ;	     (fprint (current-error-port) "slow path: " name)
	     ;;the slow path -- funky method case, method in superclass, etc
	     (let ((cname (%method-name-canonicalize name)))
		;;first we try looking the method up again, using the canonical name
		(let loop ((super klass))
		   (if (%php-class? super)
		       (let ((m (php-hash-lookup (%php-class-methods super) cname)))
			  (if (null? m)
			      ;;still not found, try the superclass
			      (loop (%php-class-parent-class super))
			      ;;found it.  store it for the next time.
			      (begin
				 ;
				 ; NOTE we store this even if it's private and from a
				 ; super class. we need to so that the visibility check
				 ; can know the difference between not having the method
				 ; vs. it not be accessible, so we can show the right
				 ; error message. visibility checks the origin-class
				 ;
				 (php-hash-insert! (%php-class-methods klass) cname m)
				 m)))
		       ;; there is no parent class, method not found.
		       #f))))
	  m)))

(define (%lookup-method-proc klass name)
   (let ((m (%lookup-method klass name)))
      (if m
	  (%php-method-proc m)
	  #f)))

(define (%lookup-constructor klass)
   (or
    (%php-class-constructor-proc klass)
    (let ((c (and (%php-class-parent-class klass)
                  (%lookup-constructor (%php-class-parent-class klass)))))
       (if c
           (begin
              (%php-class-constructor-proc-set! klass c)
              c)
           #f))))

(define (%lookup-destructor klass)
   (or
    (%php-class-destructor-proc klass)
    (let ((c (and (%php-class-parent-class klass)
                  (%lookup-destructor (%php-class-parent-class klass)))))
       (if c
           (begin
              (%php-class-destructor-proc-set! klass c)
              c)
           #f))))


; determine if the given method is accessible in the given context
(define (php-method-accessible obj-or-class method-name context)
   (let ((has-access #t)
	 (static? (not (php-object? obj-or-class)))
	 (the-class (if (php-object? obj-or-class)
			(%php-object-class obj-or-class)
			(%lookup-class-with-autoload obj-or-class))))
      (unless the-class
	 (php-error "Unable to identify class or object: " obj-or-class))
      (let ((the-method (%lookup-method the-class method-name))
	    (context-class (if context (%lookup-class-with-autoload context) #f)))
	 (when the-method
;  	    (debug-trace 0
;  			 " obj-or-class: " (%php-class-print-name the-class)
;  			 " | method-name: " method-name
;  			 " | context: " (if context-class (%php-class-print-name context-class) #f)
;  			 " | method-origin: " (%php-class-print-name (%php-method-origin-class the-method)))
	    (let ((accessible #t)
		  (no-access (cons (%php-method-visibility the-method)
				   (%php-class-print-name (%php-method-origin-class the-method)))))
	       (bind-exit (return)
		  (cond ((eqv? 'public (%php-method-visibility the-method))
			 ; public is always accessible
			 (return accessible))
			; if method is not public and there's no context, there will never be access
			((and (not (eqv? 'public (%php-method-visibility the-method)))
			      (eqv? context #f))
			 ; no access
			 (return no-access))
			; private
			((eqv? 'private (%php-method-visibility the-method))
			 (if (or (and (not static?)
				      (eqv? the-class (%php-method-origin-class the-method)))
				 (and context-class
				      ; make sure we are the origin-class
				      (eqv? context-class
					    (%php-method-origin-class the-method))))
			     (return accessible)
			     ; no access
			     (return no-access)))
			; protected
			((eqv? 'protected (%php-method-visibility the-method))
			 (if (or (and (not static?)
				      (eqv? the-class (%php-method-origin-class the-method)))
				 (and context-class
				      (or (eqv? context-class
						the-class)
					  (%subclass? context-class
						      the-class))))
			     (return accessible)
			     ; no access
			     (return no-access))))))))))

; decide what kind of visibility obj->prop has in the given context
(define (php-object-property-visibility obj prop context)
   (if (php-object? obj)
       (let ((access-type 'public))
	  (let ((ovis (hashtable-get
		       (%php-class-prop-visibility
			(%php-object-class obj))
		       (%property-name-canonicalize prop))))
	     ; ovis holds the declared visibility of prop. if it's private,
	     ; only allow it if caller is the same class. if it's protected,
	     ; allow it if caller has obj as a decendant
	     (when ovis
		; private
		(when (eqv? ovis 'private)
		   (if (and (php-object? context)
			    (eqv? (%php-object-class context)
				  (%php-object-class obj)))
		       (set! access-type 'all)
		       (set! access-type (cons ovis 'none))))
		; protected
		(when (eqv? ovis 'protected)
		   (if (and (php-object? context)
			    (or (eqv? (%php-object-class context)
				      (%php-object-class obj))
				(%subclass? (%php-object-class context)
					    (%php-object-class obj))))
		       (set! access-type 'protected)
		       (set! access-type (cons ovis 'none))))))
	  access-type)
       ; will result in referencing a property of a non object
       'public))

; decide what kind of visibility class::prop has in the given context
(define (php-class-static-property-visibility class-name prop context)
   ; context will be:
   ;  class name - if class-name == context class, allow all. subclass, allow proteced/public, otherwise public only
   ; #f - global context, only public access
   ; class-name should be a currently defined class symbol (with self and parent already processed)
   (let ((the-class (%lookup-class-with-autoload class-name))
	 (context-class (if context (%lookup-class-with-autoload context) #f))
	 (access-type 'public))
      (unless the-class
	 (php-error "static property check on unknown class: " class-name))
      (let ((ovis (hashtable-get
		   (%php-class-prop-visibility the-class)
		   (%property-name-canonicalize prop))))
	 ; ovis holds the declared visibility of prop
	 (when ovis
	    ; private
	    (when (eqv? ovis 'private)
	       (if (eqv? context-class
			 the-class)
		   (set! access-type 'all)
		   (set! access-type (cons ovis 'none))))
	    ; protected
	    (when (eqv? ovis 'protected)
	       (if (or (eqv? context-class
			     the-class)
		       (and context-class
			    (%subclass? context-class
					the-class)))
		   (set! access-type 'protected)
		   (set! access-type (cons ovis 'none))))))
      access-type))

(define (php-class-static-property class-name property access-type)
   (let ((the-class (%lookup-class-with-autoload class-name)))
      (unless the-class
	 (php-error "Getting static property " property ": unknown class " class-name))
      (let ((val (%lookup-static-prop class-name property access-type)))
	 (if val
	     val
	  (php-error "Access to undeclared static property: " class-name "::" property)))))	     

(define (php-class-static-property-ref class-name property access-type)
   (let ((the-class (%lookup-class-with-autoload class-name)))
      (unless the-class
	 (php-error "Getting static property " property ": unknown class " class-name))
      (let ((val (%lookup-static-prop-ref class-name property access-type)))
	 (if val
	     val
	     (begin
		(php-error "Access to undeclared static property: " class-name "::" property)
		(make-container NULL))))))

(define (php-class-static-property-set! class-name property value access-type)
   (let ((the-class (%lookup-class class-name)))
      (unless the-class
	 (php-error "Setting static property " property ": unknown class " class-name))
      (let* ((canon-name (%property-name-canonicalize property))
	     (offset (%prop-offset the-class canon-name access-type)))
	 (if offset
	     (begin
		(if (container? value)
		    ;reference insert, like for php-hash
		    (vector-set! (%php-class-properties the-class) offset (container->reference! value))
		    (let ((current-value (vector-ref (%php-class-properties the-class) offset)))
		       (if (container? current-value)
			   (container-value-set! current-value value)
			   (vector-set! (%php-class-properties the-class) offset (make-container value)))))
		value)
	     ;undeclared property
	     (php-error "Access to undeclared static property: " class-name "::" property)))))

;; this handles visibility mangling
;; since we use this for statics, it can be called for objects or classes
;; it will check in order: public (no mangle), protected, private
;; based on access-type, which should be either: public, protected, or all
(define (%prop-offset obj-or-class prop-canon-name access-type)
   (let ((prop-hash (cond ((php-object? obj-or-class)
			   (%php-class-declared-property-offsets
			    (%php-object-class obj-or-class)))
			  ((%php-class? obj-or-class)
			   (%php-class-static-property-offsets
			    obj-or-class))
			  (else
			   (error '%prop-offset "not an object or class" obj-or-class)))))
      (let ((prop (hashtable-get
		   prop-hash
		   prop-canon-name)))
	 (if prop
	     ; found a public
	     prop
	     (if (or (eqv? access-type 'protected)
		     (eqv? access-type 'all))
		 (let ((prop (hashtable-get
			      prop-hash
			      (mangle-property-protected prop-canon-name))))
		    (if prop
			; found a protected
			prop
			; either private or nothin'
			(if (eqv? access-type 'all)
			    (hashtable-get
			     prop-hash
			     (mangle-property-private prop-canon-name))
			    ; no visibility
			    #f)))
		 ; no visibility
		 #f)))))
		
;;;;the actual property looker-uppers
(define (%lookup-prop-ref obj property access-type)
   (let* ((canon-name (%property-name-canonicalize property))
	  (offset (%prop-offset obj canon-name access-type)))
      (if offset	  
	  (vector-ref (%php-object-properties obj) offset)
	  (php-hash-lookup-ref (%php-object-extended-properties obj)
			       #t
			       canon-name))))

(define (%lookup-prop obj property access-type)
   (container-value (%lookup-prop-ref obj property access-type)))

(define (%lookup-prop-honestly-just-for-reading obj property access-type)
   (let* ((canon-name (%property-name-canonicalize property))
	  (offset (%prop-offset obj canon-name access-type)))
      (if offset
	  (container-value (vector-ref (%php-object-properties obj) offset))
	  ;XXX this wasn't here.. copying bug?
	  (php-hash-lookup-honestly-just-for-reading
	   (%php-object-extended-properties obj)
	   canon-name) )))


(define (%assign-prop obj property value access-type)
   (let* ((canon-name (%property-name-canonicalize property))
	  (offset (%prop-offset obj canon-name access-type)))
      (if offset
	  ;declared property
	  (if (container? value)
	      ;reference insert, like for php-hash
              (vector-set! (%php-object-properties obj) offset (container->reference! value))
              (let ((current-value (vector-ref (%php-object-properties obj) offset)))
                 (if (container? current-value)
                     (container-value-set! current-value value)
                     (vector-set! (%php-object-properties obj) offset (make-container value)))))
   	  ;undeclared property
          (php-hash-insert! (%php-object-extended-properties obj)
                            canon-name value)))

   value)

(define (%lookup-static-prop-ref class-name property access-type)
   (let ((the-class (%lookup-class class-name)))
      (if the-class   
	  (let* ((canon-name (%property-name-canonicalize property))
		 (offset (%prop-offset the-class canon-name access-type)))
	     (if offset
		 (vector-ref (%php-class-properties the-class) offset)
		 #f))
	  #f)))

(define (%lookup-static-prop class-name property access-type)
   (container-value (%lookup-static-prop-ref class-name property access-type)))

(define (%php-class-method-reflection klass)
    (list->php-hash
     (let ((lst '()))
        (php-hash-for-each (%php-class-methods klass)
 	  (lambda (name method)
 	     (set! lst (cons (%php-method-print-name method) lst))))
        lst)))

(define (%next-instantiation-id)
   (set! *highest-instantiation* (+ 1 *highest-instantiation*))
   *highest-instantiation*)

(define +constructor-failed+ (cons '() '()))
(define (construct-php-object class-name . args)
   (let ((the-class (%lookup-class-with-autoload class-name)))
      (unless the-class
	 (php-error "Unable to instantiate " class-name ": undefined class."))
      (when (member 'interface (%php-class-flags the-class))
	 (php-error "Cannot instantiate interface " class-name))      
      (when (member 'abstract (%php-class-flags the-class))
	 (php-error "Cannot instantiate abstract class " class-name))
      ;
      ; XXX we're copying all properties here, but we shouldn't be copying static
      ; properties since they will never be accessed from the object vector (they use the
      ; class vector). so, we're wasting some memory      
      (let ((new-object (%php-object (%next-instantiation-id)
			             the-class
				     (copy-properties-vector
				      (%php-class-properties the-class))
				     (copy-php-data
				      (%php-class-extended-properties the-class))
				     #f)))
	 ;; if we have a destructor, make sure the class is finalized
	 (let ((destructor (%lookup-destructor the-class)))
	    (when destructor
	       (register-finalizer! new-object (lambda (obj)
						  (apply destructor obj (adjust-argument-list destructor args))))))
	 ; now run constructor, or return new obj if we have none
	 (let ((constructor (%lookup-constructor the-class)))
	    (if (not constructor)
                ;; no constructor defined
                new-object
		(if (eq? +constructor-failed+
			 (apply constructor new-object (adjust-argument-list constructor args)))
		    (begin
		       (php-warning "Could not create a " class-name " object.")
		       NULL)
		    new-object))))))


(define (construct-php-object-sans-constructor class-name)
   (let ((the-class (%lookup-class-with-autoload class-name)))
      (unless the-class
	 (php-error "Unable to instantiate " class-name ": undefined class."))
      (when (member 'interface (%php-class-flags the-class))
	 (php-error "Cannot instantiate interface " class-name))
      (when (member 'abstract (%php-class-flags the-class))
	 (php-error "Cannot instantiate abstract class " class-name))
      (let ((new-object (%php-object (%next-instantiation-id)
			             the-class
				     ;
				     ; XXX we're copying all properties here, but we shouldn't be copying static
				     ; properties since they will never be accessed from the object vector (they use the
				     ; class vector). so, we're wasting some memory
				     (copy-properties-vector
				      (%php-class-properties the-class))
				     (copy-php-data
				      (%php-class-extended-properties the-class))
				     #f)))
	 new-object)))



(define (%subclass? class-a::struct class-b::struct)
   "is class-a a subclass of class-b?"
;(debug-trace 0 "%subclass on " (%php-class-print-name class-a) " | " (%php-class-print-name class-b))
   (if (null? (%php-class-extends class-a))
       #f
       (bind-exit (return)
	  (for-each (lambda (parent-class)
;   (debug-trace 0 "sub check extend item for: " (%php-class-print-name parent-class))
		       (let ((result (or (eqv? parent-class class-b)
					 (%subclass? parent-class class-b))))
			  (when result
			     ; positive, break loop early
;			     (debug-trace 0 "positive subclass: " parent-class " || " class-b)
			     (return #t))))
		    (%php-class-extends class-a))
	  (return #f))))

(define (%implements-check? class::struct the-interface::struct)
;(debug-trace 0 "%implements-check on " (%php-class-print-name class) " | " (%php-class-print-name the-interface))
   (if (null? (%php-class-implements class))
       #f   
       (bind-exit (return)
	  (for-each (lambda (an-interface)
;   (debug-trace 0 "sub check implement item for: " (%php-class-print-name an-interface))
		       (let ((result (or (eqv? an-interface the-interface)
					 ; note we recurse on subclass? and not implements?, because interfaces
					 ; do not implement but rather subclass other interfaces
					 (%subclass? an-interface the-interface))))
			  (when result
			     ; positive, break loop early
;    (debug-trace 0 "positive interface")
			     (return #t))))
		    (%php-class-implements class))
	  (return #f))))

(define (%implements? class::struct the-interface::struct)
;(debug-trace 0 "%implements on " (%php-class-print-name class) " | " (%php-class-print-name the-interface))   
   "does class implement the-interface?"
   ; we check if we implement it directly, or if any of our parents implement it
   (bind-exit (return)
      (let ((result (or (%implements-check? class the-interface)
			(begin (for-each (lambda (parent-class)
;  (debug-trace 0 "%implements parent check on " (%php-class-print-name parent-class) " | " (%php-class-print-name the-interface))   		       
					    (let ((result (%implements? parent-class the-interface)))
					       (when result
						  (return #t))))
					 (%php-class-extends class))
			       #f))))
	 (if result (return #t) (return #f)))))
   

;;;string versions, for compiled code
(define (php-object-property/string obj property::bstring access-type)
   (php-object-property obj property access-type))

(define (php-object-property-h-j-f-r/string obj property::bstring access-type)
   (php-object-property-honestly-just-for-reading obj property access-type))

(define (php-object-property-set!/string obj property::bstring value access-type)
   (php-object-property-set! obj property value access-type))

(define (php-object-property-ref/string obj property::bstring access-type)
   (php-object-property-ref obj property access-type))

(define (%lookup-prop-ref/string obj property::bstring access-type)
   (%lookup-prop-ref obj property access-type))

(define (%lookup-prop/string obj property::bstring access-type)
   (%lookup-prop obj property access-type))

(define (%lookup-prop-h-j-f-r/string obj property::bstring access-type)
   (%lookup-prop-honestly-just-for-reading obj property access-type))

(define (%assign-prop/string obj property::bstring value)
   (%assign-prop obj property value 'public))
   
;;;end string versions


(define (pretty-print-php-object obj)
   (display "<php object, class: ")
   (display (%php-class-print-name
	     (%php-object-class obj)))
   (display ", properties: ")
   (php-object-for-each-with-ref-status
    obj
    (lambda (name value ref?)
       (display (mkstr name))
       (display "=>")
       (cond
	  ((php-hash? value)
	   (display "php-hash(")
	   (display (php-hash-size value))
	   (display ")"))
	  ((php-object? value)
	   (display "php-object(")
	   (display (%php-class-print-name
		     (%php-object-class obj)))
	   (display ")"))
	  (else (display (mkstr value))))
       (display " ")))
   (display ">"))


;;;; PHP5 "class constants".
(define (define-class-constant class-name constant-name value)
   (let ((the-class (%lookup-class class-name)))
      (unless the-class
         (php-error "Defining class constant " constant-name ": unknown class " class-name))
      (php-hash-insert! (%php-class-class-constants the-class) constant-name value)))

(define (lookup-class-constant class-name constant-name)
   (let ((fail (lambda ()
                  (php-error "Access to undeclared class constant: "
                             class-name "::"  constant-name))))
      (let* ((the-class (%lookup-class class-name)))
         (unless the-class (fail))
         (unless (php-hash-contains? (%php-class-class-constants the-class)
                                     constant-name)
            (fail))
         (php-hash-lookup (%php-class-class-constants the-class)
                          constant-name))))

   

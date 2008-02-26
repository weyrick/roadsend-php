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

(module php-skeleton-lib
   ; required
   (include "../phpoo-extension.sch")
   (library profiler)
   ; import any required modules here, e.g. c bindings
   (import
    (skeleton-c-bindings "c-bindings.scm"))
   ;
   ; list of exports. should include all defbuiltin and defconstant
   ;
   (export
    (init-php-skeleton-lib)
    ;
    SKELETON_CONST
    ;
    (skel_hello_world var1)
    (skel_hash str int)
    ;
    ))

;
; this procedure needs to exist, but it need not
; do much (normally just returns 1).
;
(define (init-php-skeleton-lib) 1)

; all top level statements are run on module initialization
; here we will initalize our builtin class
(create-skeleton-class)

; register the extension. required. note: version is not checked anywhere right now
(register-extension "skeleton" ; extension title, shown in e.g. phpinfo()
		    "1.0.0"              ; version
		    "skeleton")          ; library name. make sure this matches LIBNAME in Makefile

;
; this is how you can define a PHP resource. these are
; opaque objects in PHP, like a socket or database connection
; defresource is mostly a wrapper for define-struct.
; "Sample Resource" is the string this object coerces to
; in php land, if you try to print it
;
;(defresource php-skel-resource "Sample Resource"
;   field1
;   field2)

;
; if you use resources, you should use some code like that below
; which handles resource finalization. see the mysql extension,
; for example
;

; (define *resource-counter* 0)
; (define (make-finalized-resource)
;    (when (> *resource-counter* 255) ; an arbitrary constant which may be a php.ini entry
;       (gc-force-finalization (lambda () (<= *resource-counter* 255))))
;    (let ((new-resource (php-skel-resource 1 2)))
;       (set! *resource-counter* (+fx *resource-counter* 1))
;       (register-finalizer! new-resource (lambda (res)
; 					   ; some theoretical procedure that closes the resource properly
; 					   (resource-cleanup res)
; 					   (set! *resource-counter* (- *resource-counter* 1)))))
;       new-resource)


;;;;;;;;;;;;;;;;;;;;;;;;;;; PHP TYPES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Bigloo itself supports a variety of types, but the only ones we
; use in PHP land are: string, boolean, onum, php-hash and php-object
;
; You can use the normal bigloo functions for dealing with strings
; and booleans:
;
; string?
; boolean?
; make-string
; string=?
; substring
; ... etc
;
; Otherwise we have to do type juggling. If a bigloo type winds up
; in php land (such as a fixnum (bint) or #unspecified), it will
; show up strange when coerced to a string (i.e. ":ufo:") and may cause
; calculations to fail in general.
;
; "onum" is an "opaque number" and represents all numbers in php land.
; it follows zend's semantics for overflowing an integer into a float. you
; can use: onum-long? and onum-float? to see which it is
;
; You should use php versions of some normal scheme functions when
; dealing with php types. See runtime/php-types.scm and runtime/php-operators.scm
;
; Some commonly used functions:
;
; php-null?  php-empty?  php-hash?  php-object?  php-number?
;
; php-+  php--  php-=  php-/  php-*  php-%
;
;
; There are a few constants that should be used as well:
;
; NULL
; TRUE
; FALSE
; *zero*
; *one*
;
;;;;;;;;;;;;
;
; NOTE: You should coerce all input variables and return values to the required PHP type
;
; convert-to-number  - returns an onum, may be long or float depending on input
; convert-to-float   - returns an onum, forces float
; convert-to-integer - returns an onum, forces integer
; convert-to-boolean - returns boolean
; convert-to-string  - returns string (also see mkstr)
;
;;;;;


;;;;;;;;;;;;;;;;;;;;;;; LOCAL FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Normal scheme procedures created with define are not callable by
; PHP scripts.
;

;
; here we have a scheme procedure that's run on init, which creates
; a builtin php object
;
(define (create-skeleton-class)

   ; define a "builtin" class or interface. interfaces are simply abstract
   ; classes, but the 'interface flag should be used so the object system
   ; knows it is implementable
   ;
   ; a builtin class means it is always available while this extension is loaded,
   ; and it doesn't disappear at runtime reset

   ; note that for class/interface names, property names and method names, case
   ; will be kept but only properties are actually case sensitive
   
   ; class or interface defition. note that parent classes and interfaces should be defined
   ; first if the class will extend any
   (define-builtin-php-class 'Skeleton   ; class name. a symbol
                             '()         ; extends, a list of one entry, a symbol
			     '()         ; implements, a list of symbols
			     '()         ; flags: abstract, interface, final
			     )

   ; define a class property
   (define-php-property 'Skeleton           ; the class name. a symbol.
                        "message"           ; the property name. a string.
			"default message"   ; default value, a string or other php type (e.g. NULL)
			'protected          ; visibility, one of: public, private, protected
			#f                  ; static?
			)

   ; define a php class method
   (define-php-method 'Skeleton             ; the class name, a symbol.
                      "__construct"         ; method name, a string.
		      '(public)             ; flags: public, private, protected, final, abstract
		      Skeleton:__construct  ; scheme procedure that implements this method (see below)
		      )

   )

;
; Skeleton::__construct
;
; This is the scheme procedure that implements the "__construct" method for
; the Skeleton class, as defined in define-php-method above. The procedure
; name is arbitrary, but the arguments must be handled as shown. The first
; parameter will always be $this, which will always be a php-object or NULL
; for static methods.
;
; optional-args is a list of possible arguments that were passed into the method.
; this method looks for two arguments, message and code.
;
(define (Skeleton:__construct this-unboxed . optional-args)
   (let ((message '())
	 (code '()))
      ; do we have arguments passed in?
      (when (pair? optional-args)
	 ; yes, the first is message. save it and shift the argument list.
	 (set! message
	       (maybe-unbox (car optional-args)))
	 (set! optional-args (cdr optional-args)))
      ; do we have another argument?
      (when (pair? optional-args)
	 ; yes, save it as code. we aren't looking for any more,
	 ; so don't bother with a shift
	 (set! code
	       (maybe-unbox (car optional-args))))
      ;
      ; if the arguments now have a value, set our local properties
      ; note that 'all means we don't do a visibility check
      ;
      (when message
	 (php-object-property-set!/string this-unboxed "message" message 'all))
      (when code
	 (php-object-property-set!/string this-unboxed "code" code 'all))))


;;;;;;;;;;;;;;;


; a little function to compute x^n. not we don't do type conversion
; here, we assume it's done by our defbuiltin caller. that means
; we're just using bigloo's fixnums here. we've added type annotation
; to that effect (::bint)
(define (my-little-expt x::bint n::bint)
   (expt x n))

;;;;;;;;;;;;;;;; PHP VISIBLE BUILTIN FUNCTIONS ;;;;;;;;;;;;;;;;;;;
;
; Functions created with the defbuiltin macro are visible to
; PHP scripts
;

;
; defbuiltin creates a builtin php function
;

; take one parameter, echo it with a worldly greeting
(defbuiltin (skel_hello_world var1)
   ; one way to do debugging: add a debug-trace. the first parameter
   ; is the required debug level for the output to be shown (via -d)
   ;
   (debug-trace 1 "this is a debug message, shown at level 1. var1 is: " var1)
   ;
   (echo (mkstr "hello world" var1)))

; take two parameters and return a hash with two entries,
; one for each parameter. we'll force str to be a string,
; and int to be a number
(defbuiltin (skel_hash str int)
   (let ((result (make-php-hash)))
      ; :next is a special key which will use the next available int key
      ; mkstr coerces to a string
      ; convert-to-number coerces to a php number (onum)
      (php-hash-insert! result :next (mkstr str))
      (php-hash-insert! result :next (convert-to-number str))
      ; we can also specify a string key
      (php-hash-insert! result "somekey" "some value")
      result))

; this function uses our help scheme function above
; note that we do the type conversions here, and there is no
; type annotation for defbuiltin parameters. also, we have to
; not only convert the parameters, but the return value!
(defbuiltin (skel_expt x n)
   ; mkfixnum makes a bigloo fixnum (bint)
   ; it should only be used be calling bigloo functions
   ; that require it, otherwise stick with onum (php numbers)
   ; or bigloo elong
   (let ((real-x (mkfixnum x))
	 (real-n (mkfixnum n)))
      ; convert-to-number ensures we return a php number (onum)
      ; see definition on my-little-expt in LOCAL FUNCTIONS section above
      (convert-to-number (my-little-expt real-x real-n))))
   
;;;;;;;;;;;;;;;;;;;;; PHP VISIBLE CONSTANTS ;;;;;;;;;;;;;;;;;;;;;
;
; Constants created with the defconstant macro are visible to
; PHP scripts
;

;
; defconstant creates a builtin constant
; note, values are automatically coerced to php types
;
(defconstant SKELETON_CONST  0)


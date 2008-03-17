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
(module php-operators
   (include "php-runtime.sch")
   (import
    (opaque-math "opaque-math-binding.scm")
    (php-hash "php-hash.scm")
    (php-object "php-object.scm")
    (constants "constants.scm")
    (rt-containers "containers.scm")
    (output-buffering "output-buffering.scm")    
    (php-errors "php-errors.scm")
    (utils "utils.scm")        
    (php-types "php-types.scm"))
   (extern
    (include "math.h")
    (c-binary-strcmp::int (::string ::int ::string ::int) "binary_strcmp"))   
   (export
    (echo arg)    
    (php-%::onum a b)
    (inline php-%/num::onum a::onum b::onum)
    (inline php-//num::onum a::onum b::onum)
    (inline php-*-/num::onum a::onum b::onum)
    (inline php--/num::onum a::onum b::onum)
    (inline php-+/num::onum a::onum b::onum)
    (inline less-than-or-equal-p/num a::onum b::onum)
    (inline less-than-p/num a::onum b::onum)
    (inline greater-than-or-equal-p/num a::onum b::onum)
    (inline greater-than-p/num a::onum b::onum)
    (inline equalp/num a::onum b::onum)
    (%general-lookup obj key)
    (%general-lookup/pre obj key pre)
    (%general-lookup-honestly-just-for-reading obj key)
    (%general-lookup-honestly-just-for-reading/pre obj key pre)
    (%general-lookup-location obj key)
    (%coerce-for-insert obj)
    (%general-insert! obj key val)
    (%general-insert!/pre obj key pre val)
    (%general-insert-n! obj keys precalculated-hashnumbers val)
    (equalp a b)
    (logical-not a)
    (identicalp a b)
    (not-equal-p a b)
    (not-identical-p a b)
    (less-than-p a b)
    (greater-than-p a b)
    (less-than-or-equal-p a b)
    (greater-than-or-equal-p a b)
    (--::onum a)
    (inline --/num::onum a::onum)
    (++ a)
    (inline ++/num::onum a::onum)
    (compare-as-strings a b)
    (compare-as-numbers a b)
    (compare-as-boolean a b) 
    (php-var-compare a b)
    (php-+ a b) ; may return an array
    (php--::onum a b)
    (php-*::onum a b)
    (php-/::onum a b)
    (php-< a b)
    (php-> a b)
    (php-<= a b)
    (php->= a b)
    (php-= a b)
    (copy-php-data data)
    (bitwise-or a b)
    (bitwise-xor a b)
    (bitwise-and a b)
    (bitwise-not a)
    (bitwise-shift-left a b)
    (bitwise-shift-right a b)
    (php-string-set! str char val)
    (php-string-ref str char)))

(define (php-+ a b)
   (if (and (php-hash? (maybe-unbox a))
 	    (php-hash? (maybe-unbox b)))
       (php-hash-append (maybe-unbox a) (maybe-unbox b))
       (onum+ (convert-to-number a) (convert-to-number b))))

(define (php--::onum a b)
   (onum- (convert-to-number a) (convert-to-number b)))

(define (php-*::onum a b)
   (onum* (convert-to-number a) (convert-to-number b)))

(define (php-/::onum a b)
   (onum/ (convert-to-number a) (convert-to-number b)))

; conveneience wrappers
(define (php-< a b)
   (less-than-p a b))

(define (php-> a b)
   (greater-than-p a b))

(define (php->= a b)
   (greater-than-or-equal-p a b))

(define (php-<= a b)
   (less-than-or-equal-p a b))

(define (php-= a b)
   (equalp a b))

(define (php-%::onum a b)
   (onum% (convert-to-number a) (convert-to-number b)))

(define (unbuffered-echo a)
   (display (stringulate a))
   (when *output-buffer-implicit-flush?*
      (flush-output-port (current-output-port))))

(define (echo a)
   (if (pair? *output-buffer-stack*)
       (with-output-to-port (car *output-buffer-stack*)
	  (lambda ()
	     (unbuffered-echo a)))
       (unbuffered-echo a))
   ;; PHP's print function returns 1
   *one*)

(define (php-string-ref str char)
   (if (eqv? char :next)
       (php-error "[] operator not supported for strings")
       (let ((idx (mkfixnum char)))
	  (if (< idx (string-length str))
	      (mkstr (string-ref str idx))
	      ""))))

(define (php-string-set! str idx val)
   ;; This has a !, but it should actually have no side effect.
   ;; Otherwise, constant strings could be mutated, which is bad
   (let ((str (string-copy str)))
      (when (eqv? idx :next)
	 (php-error "[] operator not supported for strings"))
      (set! val (maybe-unbox val))
      (let ((char-to-insert (if (or (php-null? val)
				    (= 0 (string-length (mkstr val))))
				(integer->char 0)
				(string-ref (mkstr val) 0))))
	 (let ((idx (mkfixnum idx)))
	    (if (< idx 0)
		; this warning is verbatim from a zend warning.
		; please don't change it or remove the second space.
		(php-warning "Illegal string offset:  " idx)
		(begin
		   (when (>= idx (string-length str))
		      (let loop ((i (string-length str)))
			 (when (<= i idx)
			    (begin
			       (set! str (string-append str " "))
			       (loop (+ i 1))))))
		   (string-set! str idx char-to-insert)))
	    str))))


;bitwise ops.. could probably constructively be rewritten using elongs and the C operators.
(define (bitwise-or a b)
   (int->onum
    (bit-or (mkfixnum a) (mkfixnum b))))

(define (bitwise-xor a b)
   (int->onum
    (bit-xor (mkfixnum a) (mkfixnum b))))

(define (bitwise-and a b)
   (int->onum
    (bit-and (mkfixnum a) (mkfixnum b))))

(define (bitwise-not a)
   (int->onum
    (bit-not (mkfixnum a))))

(define (bitwise-shift-left a b)
   (int->onum
    (bit-lsh (mkfixnum a) (mkfixnum b))))

(define (bitwise-shift-right a b)
   (int->onum
    (bit-rsh (mkfixnum a) (mkfixnum b))))


      
; !$a TRUE if $a is not TRUE.
(define (logical-not a)
   (let ((a (if (container? a) (container-value a) a)))
      (not (convert-to-boolean a))))
   
;$a === $b Identical  TRUE if $a is equal to $b, and they are of the same type. (PHP 4 only)
(define (identicalp a b)
   (let ((a (if (container? a) (container-value a) a))
	 (b (if (container? b) (container-value b) b)))
      (if (onum? a)
	  (if (onum? b)
	      ;both are onums
	      (= 0 (onum-compare a b))
	      ;a is onum, b is not
	      #f)
	  (if (php-hash? a)
	      (if (php-hash? b)
		  ;both are php-hashes
		  (= 0 (php-hash-compare a b #t))
		  ;a is php-hash, b is not
		  #f)
	      (if (php-object? a)
		  (if (php-object? b)
		      ;both are php-objects
		      ;you can only compare objects of the same class, it seems.
		      (let ((o (php-object-compare a b #t)))
			 (and (number? o) (= 0 o)))
		      ;a is php-object, b is not
		      #f)
		  (if (or (onum? b) (php-hash? b) (php-object? b))
		      #f
		      ;neither is a php-hash or a php-object, so it's safe to call equal?
		      ;(which would overflow the stack on a php-hash)
		      (equal? a b)))))))



;$a != $b Not equal TRUE if $a is not equal to $b.
;$a <> $b Not equal TRUE if $a is not equal to $b.
(define (not-equal-p a b)
   (not (equalp a b)))

;$a !== $b Not identical  TRUE if $a is not equal to $b, or they are not of the same type. (PHP 4 only)
(define (not-identical-p a b)
   (not (identicalp a b)))

;;;;;;;;;

(define (compare-as-numbers a b)
   (onum-compare (convert-to-number a) (convert-to-number b)))

(define (compare-as-boolean a b)
   (let ((c (convert-to-boolean a))
	 (d (convert-to-boolean b)))
      (cond ((and c d) 0)
	    ((and c (not d)) 1)  
	    ((and (not c) d) -1)
	    ((and (not c) (not d)) 0))))

(define (compare-as-strings a b)
   (let* ((c (mkstr a))
	  (d (mkstr b))
	  (c-s (string-length c))
	  (d-s (string-length d)))
      (c-binary-strcmp c c-s d d-s)))

(define (convert-scalar-to-number a)
   (if (or (string? a)
	   (boolean? a)
	   (null? a)
	   (elong? a)
	   (number? a)
	   (php-object? a))
       (convert-to-number a)
       a))

(define (php-var-compare a b)
   "compare two php variables, returning < 0 if a is less than b,
    0 if they are the same, and > 0 if a is greater than b"
   (let ((l (maybe-unbox a))
	 (r (maybe-unbox b)))
      (cond
	 ;; the common number case
	 ((and (php-number? l) (php-number? r))
	  (onum-compare l r))
	 ;; more general stuff
	 ((or (and (string? l) (null? r))
	      (and (string? r) (null? l)))
	  (compare-as-strings l r))

	 ((and (string? l) (string? r))
	  ;; strings could both be numeric
	  (if (and (numeric-string? l) (numeric-string? r))
	      (compare-as-numbers l r)
	      (compare-as-strings l r)))

	 ((or (boolean? l) (boolean? r) (null? l) (null? r))
	  (compare-as-boolean l r))

	 ((and (php-hash? l) (php-hash? r))
	  (php-hash-compare l r #f))

	 ((and (php-object? l) (php-object? r))
	  (php-object-compare l r #f))

	 (else
	  (let ((l (convert-scalar-to-number l))
		(r (convert-scalar-to-number r)))
	     (cond
		((and (php-number? l) (php-number? r))
		 (compare-as-numbers l r))

		((php-hash? l) 1)
		((php-hash? r) -1)
		((php-object? l) 1)
		((php-object? r) -1)
		((php-resource? l) 1)
		((php-resource? r) -1)		
		(else (error 'php-var-compare "not a php type" (cons l r)))))))))


(define (equalp a b)
   (let ((rval (php-var-compare a b)))
      (cond ((boolean? rval) rval)
	    (else (= rval 0)))))

(define (greater-than-p a b)
   (let ((rval (php-var-compare a b)))
      (cond ((boolean? rval) rval)
	    (else (> rval 0)))))

(define (greater-than-or-equal-p a b)
      (let ((rval (php-var-compare a b)))
      (cond ((boolean? rval) rval)
	    (else (>= rval 0)))))

(define (less-than-p a b)
      (let ((rval (php-var-compare a b)))
	 (cond ((boolean? rval) rval)
	       (else (< rval 0)))))

(define (less-than-or-equal-p a b)
      (let ((rval (php-var-compare a b)))
      (cond ((boolean? rval) rval)
	    (else (<= rval 0)))))

;;;;

(define (++ a)
   (let ((a (maybe-unbox a)))
      (if (and (string? a)
	       (not (numeric-string? a)))
	  (increment-string a)
	  (onum+ (convert-to-number a) *one*))))


(define-inline (++/num::onum a::onum)
   (onum+ a *one*))

(define (--::onum a)
   (onum- (convert-to-number a) *one*))
(define-inline (--/num::onum a::onum)
   (onum- a *one*))


;;;; these are fast entry-points, for when the compiler knows the type
(define-inline (equalp/num a b)
   (=fx (onum-compare a b) 0))

(define-inline (greater-than-p/num a b)
   (>fx (onum-compare a b) 0))

(define-inline (greater-than-or-equal-p/num a b)
   (>=fx (onum-compare a b) 0))

(define-inline (less-than-p/num a b)
   (<fx (onum-compare a b) 0))

(define-inline (less-than-or-equal-p/num a b)
   (<=fx (onum-compare a b) 0))

(define-inline (php-+/num a b)
   (onum+ a b))

(define-inline (php--/num a b)
   (onum- a b))

(define-inline (php-*-/num a b)
   (onum* a b))

(define-inline (php-//num a b)
   (onum/ a b))

(define-inline (php-%/num a b)
   (onum% a b))

;;;;





;;;;cruddy array operators
(define (%general-lookup-location obj key)
   "Lookup key in obj. Always returns a container, if it returns.
Obj should not be in a container."
   (cond
      ((php-hash? obj) (let ((val (php-hash-lookup-location obj #t key)))
			  ; XXX add this back when we fix isset/empty
			  ;(when (eqv? (container-value val) NULL)
			     ;(php-notice "Undefined index: " key))
			  val))
      ((string? obj) (php-error "Cannot create references to string offsets"))
;      ((foreign? obj) (%general-lookup-location 
;                       (zval->phpval-coercion-routine obj)
;                       key))
      (else ;(php-warning "Cannot use a scalar as an array -- " obj)
	    (make-container NULL))))

(define (%general-lookup obj key)
   "Lookup key in obj. Doesn't return a container.  Obj should not be
in a container."
   (cond
      ((php-hash? obj) (let ((val (php-hash-lookup obj key)))
			  ; XXX add this back when we fix isset/empty			  
			  ;(when (eqv? val NULL)
			  ;    (php-notice "Undefined index: " key))
			  val))
      ((string? obj) (php-string-ref obj key))
      
      ((and (php-object? obj)
	    (php-object-instanceof obj "ArrayAccess")) (maybe-unbox (call-php-method-1 obj "offsetGet" key)))
       
;      ((foreign? obj) (%general-lookup 
;                       (zval->phpval-coercion-routine obj)
;                       key))
      (else ;(php-warning (format "Cannot use a scalar as an array -- ~A" obj))
	    NULL)))

(define (%general-lookup/pre obj key pre)
   "Lookup key in obj. Doesn't return a container.  Obj should not be
in a container."
   (cond
      ((php-hash? obj) (let ((val (php-hash-lookup/pre obj key pre)))
			  ; XXX add this back when we fix isset/empty			  
			  ;(when (eqv? val NULL)
			  ;    (php-notice "Undefined index: " key))
			  val))
      ((string? obj) (php-string-ref obj key))
;      ((foreign? obj) (%general-lookup 
;                       (zval->phpval-coercion-routine obj)
;                       key))
      (else ;(php-warning (format "Cannot use a scalar as an array -- ~A" obj))
	    NULL)))

(define (%general-lookup-honestly-just-for-reading obj key)
   "Lookup key in obj. Doesn't return a container.  Obj should not be
in a container."
   (cond
      ((php-hash? obj) (let ((val (php-hash-lookup-honestly-just-for-reading obj key)))
			  ; XXX add this back when we fix isset/empty			     
			  ;(when (eqv? val NULL)
			     ; (php-notice "Undefined index: " key))			     
			  val))
      ((and (php-object? obj)
	    (php-object-instanceof obj "ArrayAccess")) (maybe-unbox (call-php-method-1 obj "offsetGet" key)))      
      ((string? obj) (php-string-ref obj key))
;      ((foreign? obj) (%general-lookup-honestly-just-for-reading
;                       (zval->phpval-coercion-routine obj)
;                       key))
      (else ;(php-warning (format "Cannot use a scalar as an array -- ~A" obj))
	    NULL)))

(define (%general-lookup-honestly-just-for-reading/pre obj key pre)
   "Lookup key in obj. Doesn't return a container.  Obj should not be
in a container."
   (cond
      ((php-hash? obj) (let ((val (php-hash-lookup-honestly-just-for-reading/pre obj key pre)))
			  ; XXX add this back when we fix isset/empty			     
			  ;(when (eqv? val NULL)
			     ; (php-notice "Undefined index: " key))			     
			  val))
      ((and (php-object? obj)
	    (php-object-instanceof obj "ArrayAccess")) (maybe-unbox (call-php-method-1 obj "offsetGet" key)))      
      ((string? obj) (php-string-ref obj key))
;      ((foreign? obj) (%general-lookup-honestly-just-for-reading
;                       (zval->phpval-coercion-routine obj)
;                       key))
      (else ;(php-warning (format "Cannot use a scalar as an array -- ~A" obj))
	    NULL)))

(define (%coerce-for-insert obj)
   (if (or (php-null? obj)
           (not obj) ;; false gets treated like NULL here, see bug 3210
	   (and (string? obj) (=fx 0 (string-length obj))))
       (make-php-hash)
       obj))

(define (%general-insert! obj key val)
   "Insert into obj at key.  Val may be a container, meaning
reference insert in the case of a hash."
   (cond
      ((php-hash? obj) (php-hash-insert! obj key val) obj)
      ((and (php-object? obj)
	    (php-object-instanceof obj "ArrayAccess"))
       (maybe-unbox (call-php-method-2 obj "offsetSet" key val)))
      ((string? obj) (php-string-set! obj key val))
;      ((foreign? obj) (%general-insert!
;                       (zval->phpval-coercion-routine obj)
;                       key
;                       val))
      (else (php-warning "Cannot use a scalar value as an array")
	    obj)))

(define (%general-insert!/pre obj key pre val)
   "Insert into obj at key.  Val may be a container, meaning
reference insert in the case of a hash."
   (cond
      ((php-hash? obj) (php-hash-insert!/pre obj key pre val) obj)
      ((string? obj) (php-string-set! obj key val))
      ((and (php-object? obj)
	    (php-object-instanceof obj "ArrayAccess"))
       (maybe-unbox (call-php-method-2 obj "offsetSet" key val)))      
;      ((foreign? obj) (%general-insert!
;                       (zval->phpval-coercion-routine obj)
;                       key
;                       val))
      (else (php-warning "Cannot use a scalar value as an array")
	    obj)))

(define (%general-insert-n! obj keys precalculated-hashnumbers val)
   ;;this is the nested version of %general-insert!
   (let loop ((obj obj)
	      (key (car keys))
	      (keys (cdr keys))
              (pre (car precalculated-hashnumbers))
              (pres (cdr precalculated-hashnumbers)))
      ;;we loop over the keys, from left to right in the source code
      ;;i.e. $foo[0][2], we want 0 first in keys
      (if (null? keys)
	  ;;this is the base case -- finally insert the value
	  ;;whether it's a reference or not depends on whether or
	  ;;not it's in a container.  we don't decide that here.
          (if pre
              (%general-insert!/pre obj key pre val)
              (%general-insert! obj key val))
	  ;;in case of, say, $foo[0][2], we have to get the array
	  ;;or string for $foo[0], then insert into its [2] element
	  (let ((next (if pre
                          (%general-lookup/pre obj key pre)
                          (%general-lookup obj key))))
	     ;;null and empty strings are coerced to hashtables as of php 4.3.7
	     (if (or (php-null? next)
		     (and (string? next) (=fx 0 (string-length next))))
		 ;;create a hashtable and insert it, thereby performing the coercion
		 ;;then continue to loop over the new hashtable 
		 (let ((next (make-php-hash)))
                    (if pre
                        (%general-insert!/pre obj key pre next)
                        (%general-insert! obj key next))
		    (loop next (car keys) (cdr keys) (car pres) (cdr pres)))
		 (if (php-hash? next)
		     ;;$foo[0] is already a hashtable, so move on to the next key,
		     ;;[2] in our example
		     (loop next (car keys) (cdr keys) (car pres) (cdr pres))
		     ;;$foo[0] was a string, so we have to reinsert the result of
		     ;;inserting val into [2] into $foo[0], since the string-char-set!
		     ;;operation could return a fresh string.
 		     (if (string? next)
 			 (%general-insert! obj key (loop next (car keys) (cdr keys) (car pres) (cdr pres)))
			 ;;things other than null and empty strings aren't coerced.
			 ;;instead, we print a warning and give up.  php 4.3.7 behavior.
			 (php-warning "Cannot use a scalar value as an array")))))))
   ;;we return the original object, so that it can be assigned back into
   ;;the variable or whatever holds it, in case it was coerced in the argument
   ;;list of the call to %general-insert-n!
   ;;(i.e. (%general-insert-n (%coerce ...) ...))
   obj)


;;;;even cruddier string increment doodad
(define (increment-string str)
   (let ((len (string-length str)))
      (if (=fx len 0)
	  "1"
	  (let ((result (string-copy str)))
	     (let loop ((pos (-fx len 1))
			(carry? #t)
			(last 'dunno))
		(if (and carry? (>=fx pos 0))
		    (let ((c (string-ref str pos)))
		       (cond
			  ((and (char>=? c #\a) (char<=? c #\z))
			   (if (char=? c #\z)
			       (begin
				  (string-set! result pos #\a)
				  (loop (-fx pos 1) #t 'lowercase))
			       (begin
				  (string-set! result pos (integer->char (+ 1 (char->integer c))))
				  (loop (-fx pos 1) #f 'lowercase))))
			  ((and (char>=? c #\A) (char<=? c #\Z))
			   (if (char=? c #\Z)
			       (begin
				  (string-set! result pos #\A)
				  (loop (-fx pos 1) #t 'uppercase))
			       (begin
				  (string-set! result pos (integer->char (+ 1 (char->integer c))))
				  (loop (-fx pos 1) #f 'uppercase))))
			  ((and (char>=? c #\0) (char<=? c #\9))
			   (if (char=? c #\9)
			       (begin
				  (string-set! result pos #\0)
				  (loop (-fx pos 1) #t 'numeric))
			       (begin
				  (string-set! result pos (integer->char (+ 1 (char->integer c))))
				  (loop (-fx pos 1) #f 'numeric))))
			  (else
			   (loop pos #f 'dunno))))
		    (if carry?
			(ecase last
			   ((numeric) (string-append "1" result))
			   ((uppercase) (string-append "A" result))
			   ((lowercase) (string-append "a" result)))
			result)))))))

(define (copy-php-data data)
   (let ((box? #f))
      (when (container? data)
	 (set! box? #t)
	 (set! data (container-value data)))
      (let ((the-copy
	     (cond
		((php-hash? data)
		 (copy-php-hash data #f))
		((php-object? data) data)
;                ((foreign? data)
;                 (copy-php-data (zval->phpval-coercion-routine data)))
		(else data))))
	 (if box?
	     (make-container the-copy)
	     the-copy))))

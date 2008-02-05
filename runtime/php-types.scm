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
(module php-types
   (import
    (utils "utils.scm")
    (php-hash "php-hash.scm")
    (php-object "php-object.scm")
    (php-errors "php-errors.scm")
    (php-resources "resources.scm")
    (php-operators "php-operators.scm")
    (constants "constants.scm")
    (rt-containers "containers.scm"))
   (from (opaque-math "opaque-math-binding.scm"))
   (extern
    (macro isfinite::bool (::float) "isfinite")
    (macro isnan::bool (::float) "isnan"))
   (export
    FALSE
    TRUE
    NULL
    *zero*
    *one*
    (stringulate::bstring a)    
    (convert-to-boolean::bool rval)
    (convert-to-string::bstring rval)
    (convert-to-integer::onum rval)
    (convert-to-float rval)
    (convert-to-number::onum rval)
    (mkstr::bstring a . args)
    (get-php-datatype::bstring rval)
    (valid-php-type? value)
    (php-empty? a)
    (php-null? a)
    (php-resource? a)
    (php-number? rval)
    (float-is-finite? a)
    (float-is-nan? a)
    (coerce-to-php-type orig)
    ; these are for converting to functions for bigloo procedures
    (mkfixnum::int rval)
    (mkfix-or-flonum rval)))


(define TRUE #t)
(define FALSE #f)
(define NULL '())
(define *zero* (int->onum 0))
(define *one* (int->onum 1))

(define (mkstr::bstring a . args)
   (case (length args)
      ((0) (stringulate a))
      ((1) (string-append (stringulate a)
			  (stringulate (car args))))
      ((2) (string-append (stringulate a)
			  (stringulate (car args))
			  (stringulate (cadr args))))
      ((3) (string-append (stringulate a)
			  (stringulate (car args))
			  (stringulate (cadr args))
			  (stringulate (caddr args))))
      ((4) (string-append (stringulate a)
			  (stringulate (car args))
			  (stringulate (cadr args))
			  (stringulate (caddr args))
			  (stringulate (cadddr args))))
      (else (apply string-append (stringulate a) (map stringulate args)))))

(define (stringulate::bstring a)
   ;a copy of unbuffered-echo
   (cond
      ((string? a) a)
      ((container? a) (stringulate (container-value a)))
      ((null? a) "")
      ((onum? a) (onum->string a *float-precision*))
      ((boolean? a) (if a "1" ""))
      ((php-hash? a) "Array")
      ((elong? a) (elong->string a))
      ((symbol? a) (symbol->string a))      
      ((php-object? a) (if (php-class-method-exists? (php-object-class a) "__toString")
			   (mkstr (maybe-unbox (call-php-method-0 a "__toString")))
			   (mkstr (php-recoverable-error "Object of class "
							 (php-object-class a)
							 " could not be converted to string"))))
      ((flonum? a) (stringulate-float a))
      ((fixnum? a) (integer->string a))      
      ((char? a) (string a))
      ((php-resource? a) (string-append "Resource id #" (integer->string (resource-id a))))
      (else
       (debug-trace 3 "object cannot be coerced to a string")
       ;;if we emit a warning here, and the data is circular, it'll stack overflow (segfault)
       ":ufo:")))

;;;;these are the type coercion functions, except for
;;;;convert-to-object, in php-object.scm, and convert-to-hash in
;;;;php-hash.scm

;just to be pretty
(define (convert-to-string::bstring rval)
   (mkstr rval))

(define (convert-to-boolean::bool rval)
   (when (container? rval)
       (set! rval (container-value rval)))   
   (cond
      ((boolean? rval) rval)
      ((eqv? rval NULL) #f)
      ((onum? rval) (not (= (onum-compare rval *zero*) 0)))
      ((and (number? rval) (= rval 0)) #f)
      ((and (string? rval)
	    (or (string=? rval "")
		(string=? rval "0")))
       #f)
      ((php-hash? rval) (not (zero? (php-hash-size rval))))
      ((php-object? rval) #t) ; php5, always true?
;       (not (zero? (php-hash-size (php-object-props rval)))))
      (else #t)))


; this is guaranteed to return an onum
(define (convert-to-number::onum rval)
   (when (container? rval)
       (set! rval (container-value rval)))
   (cond
      ((onum? rval) rval)
      ((flonum? rval) (float->onum rval))      
      ((elong? rval) (elong->onum rval))
      ((fixnum? rval) (int->onum rval))
      ((boolean? rval) (if rval (int->onum 1) (int->onum 0)))
      ((equal? rval NULL) (int->onum 0))
      ((equal? rval "") (int->onum 0))
      ((string? rval) (string->onum rval))
      ((or (php-hash? rval)
	   (php-object? rval))
       (if (convert-to-boolean rval)
	   (int->onum 1)
	   (int->onum 0)))
      (else (int->onum 0))))

(define (string->onum::onum rval)
   (try (if (or (string-contains rval ".")
                (string-contains-ci rval "e"))
            (string->onum/float rval)
            (string->onum/long rval))
        (lambda (e p m o)
           (e *zero*))))

; should only be used for functions that require a fixnum
; and can't handle an elong (e.g. bigloo procedures)
; this returns a fixnum
(define (mkfixnum rval)
   (if (fixnum? rval)
       rval
       (onum->int (convert-to-number rval))))


; again, this should only be used for functions that require a fixnum
; or flonum (e.g. bigloo procedures). not for php values
(define (mkfix-or-flonum rval)
   (if (or (fixnum? rval)
	   (flonum? rval))
       rval
       (let ((val (convert-to-number rval)))
	  (if (fast-onum-is-long val)
	      (elong->fixnum (onum->elong val))
	      (onum->float val)))))

(define (convert-to-float rval)
   ;see comment for convert-to-integer.
   (float->onum (onum->float (convert-to-number rval))))


(define (convert-to-integer::onum rval)
   ;we can't modify rval, so we make a copy and force it to be an integer like
   ;so, instead of with convert-onum-to-long!.
   (elong->onum (onum->elong (convert-to-number rval))))

; use instead of number?
(define (php-number? rval)
   (onum? rval))


(define (float-is-finite? a)
   (if (isfinite a)
       #t
       #f))

(define (float-is-nan? a)
   (if (isnan a)
       #t
       #f))

(define (stringulate-float a)
   (cond
      ((zero? a) "0")
      ((float-is-finite? a) (onum->string (convert-to-number a) *float-precision*))
      ((float-is-nan? a) "NAN")
      ((positive? a) "INF")
      (else "-INF")))

(define (valid-php-type? value)
   (let ((val (maybe-unbox value)))
      (if (or (php-number? val)
	      (string? val)
	      (boolean? val)
	      (php-hash? val)
	      (php-object? val)
	      (php-resource? val)
	      (null? val))
	  #t
	  #f)))

(define (coerce-to-php-type orig)
   ;make sure that a is a valid php type
   (let ((val (maybe-unbox orig)))
      (cond
	 ((valid-php-type? orig) orig)
	 ((or (elong? val) (number? val))
	  (convert-to-number orig))
	 ((symbol? val) (symbol->string val))
	 ((keyword? val) (keyword->string val))
	 ((char? val) (make-string 1 val))
	 (else
	  NULL))))

(define (php-null? a)
   (eqv? a NULL))

(define (php-empty? a)
   (cond ((null? a) TRUE)
 	 ((boolean? a) (not a))
 	 ((php-number? a) (php-= a 0))
 	 ((string? a) (or (=fx (string-length a) 0) (string=? a "0")))
 	 ((php-hash? a) (= (php-hash-size a) 0)) 
 	 (else FALSE)))

(define (php-resource? a)
   ;;;XXX fixme this doesn't have a good definition!
   (and (struct? a)
	(not (php-constant? a))
	(not (php-hash? a))
	(not (php-object? a))))


(define (get-php-datatype::bstring rval)
   (let ((rval (maybe-unbox rval)))
      (cond
	 ((boolean? rval) "boolean")
	 ((and (php-number? rval) (onum-long? rval)) "integer")
	 ((and (php-number? rval) (onum-float? rval)) "double")
	 ((string? rval) "string")
	 ((php-hash? rval) "array")
	 ((php-object? rval) "object")
	 ((php-resource? rval) "resource")
	 ((php-null? rval) "NULL")
	 (else
	  (begin
	     (debug-trace 1 "not a valid php datatype: " rval)
	     "unknown type")))))


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
(module php-math-lib
   (include "../phpoo-extension.sch")
   (library profiler)
   (extern
    (include "math.h")
    (include "time.h")
    (include "stdlib.h")
    (include "mt_rand.h")
    (include "windows-time.h") ; rand related
    
    ;constants
    (macro c-m_e::double "M_E")     ; The base of natural logarithms.
    (macro c-m_log2e::double "M_LOG2E") ;     The logarithm to base "2" of "M_E".
    (macro c-m_log10e::double "M_LOG10E")  ;     The logarithm to base "10" of "M_E".
    (macro c-m_ln2::double    "M_LN2")  ;     The natural logarithm of "2".
    (macro c-m_ln10::double    "M_LN10")  ;     The natural logarithm of "10".
    (macro c-m_pi::double    "M_PI")  ;     Pi, the ratio of a circle"s circumference to its diameter.
    (macro c-m_pi_2::double    "M_PI_2")  ;     Pi divided by two.
    (macro c-m_pi_4::double    "M_PI_4")  ;     Pi divided by four.
    (macro c-m_1_pi::double    "M_1_PI")  ;     The reciprocal of pi (1/pi)
    (macro c-m_2_pi::double    "M_2_PI")  ;     Two times the reciprocal of pi.
    (macro c-m_2_sqrtpi::double    "M_2_SQRTPI")  ;     Two times the reciprocal of the square root of pi.
    (macro c-m_sqrt2::double    "M_SQRT2")  ;     The square root of two.
    (macro c-m_sqrt1_e::double    "M_SQRT1_2")  ;     The reciprocal of the square root of two (also the square root of 1/2).
;    (macro c-rand_max::elong    "RAND_MAX")  ;     The reciprocal of the square root of two (also the square root of 1/2).

    ;functions
    (macro c-atanh::double (::double) "atanh")
    (macro c-asinh::double (::double) "asinh")
    (macro c-acosh::double (::double) "acosh")
    (macro c-cosh::double (::double) "cosh")
    (macro c-sinh::double (::double) "sinh")
    (macro c-tanh::double (::double) "tanh")
    (macro c-hypot::double (::double ::double) "hypot")
    (macro c-expm1::double (::double) "expm1")
    (macro c-log1p::double (::double) "log1p")
    (macro c-log10::double (::double) "log10")
    (macro _c-sqrt::double (::double) "sqrt")
    (macro _c-pow::double (::double ::double) "pow")

    (macro seedMT::void (::double) "seedMT")
    (macro randomMT-range::long (::elong ::elong) "randomMTrange")
 
    )
   (export
    (init-php-math-lib)
    ; constants
    M_PI
    M_E
    M_LOG2E
    M_LOG10E
    M_LN2
    M_LN10
    M_PI_2
    M_PI_4
    M_1_PI
    M_2_PI
    M_SQRTPI
    M_2_SQRTPI
    M_SQRT2
    M_SQRT3
    M_SQRT1_2
    M_LNPI
    M_EULER
    PHP_RAND_MAX
    PHP_MT_RAND_MAX
    ;; standard math functions
    (php-abs num)
    (php-acos num)
    (acosh num)
    (php-asin num)
    (asinh num)
    (php-atan num)
    (atanh num)
    (atan2 num num1)
    (base_convert num-str frombase tobase)
    (bindec num-str)
    (ceil num)
    (php-cos num)
    (cosh num)
    (decbin num)
    (dechex num)
    (decoct num)
    (deg2rad num)
    (php-exp pow)
    (expm1 num)
    (php-floor num)
    ; fmod
    (getrandmax)
    (hexdec num-str)
    (hypot a b)
    (is_finite a)
    (is_infinite a)
    (is_nan a)
    ; lcg_value
    (php-log num base)
    (log10 num)
    (log1p num)    
    ;(php-max a0 . a1-n)
    ;(php-min a0 . a1-n)
    (php-max . a1-n)
    (php-min . a1-n)
    (mt_getrandmax)
    (mt_rand min max)
    (mt_srand seed)
    (octdec num-str)
    (php-pi)
    (pow base power)
    (rad2deg num)
    (php-round num prec)
    (php-sin num)
    (sinh num)
    (php-sqrt num)
    (php-tan num)
    (tanh num)
    ))


; init the module
(define (init-php-math-lib)
   1)


;XXXX
;still needs: lcg_value
;
;decbin, dechex, decoct etc. produce negative numbers, whereas Zend's is unsigned. 
;
;for Zend, min(23, "foo", 2) => "foo" (not for max, tho), for Roadsend => 0.  
;
;Zend seems to ignore certain values for dec_point and thousands_sep on number format..?

;;;; constants

;(defconstant PHP_RAND_MAX 2147483647.0)
(defconstant PHP_RAND_MAX (pragma::double "MT_RAND_MAX")) ; from mt_rand.h
(defconstant PHP_MT_RAND_MAX (pragma::double "MT_RAND_MAX")) ; from mt_rand.h

;PHP will take the ones in math.h, so we try to be compatble
(defconstant M_PI	c-m_pi)	;Pi
(defconstant M_E	c-m_e)	;e
(defconstant M_LOG2E	c-m_log2e)	;log_2 e
(defconstant M_LOG10E	c-m_log10e)	;log_10 e
(defconstant M_LN2	c-m_ln2)	;log_e 2
(defconstant M_LN10	c-m_ln10)	;log_e 10
(defconstant M_PI_2	c-m_pi_2)	;pi/2
(defconstant M_PI_4	c-m_pi_4)	;pi/4
(defconstant M_1_PI	c-m_1_pi)	;1/pi
(defconstant M_2_PI	c-m_2_pi)	;2/pi
(defconstant M_SQRTPI	1.77245385090551602729)	;sqrt(pi) [4.0.2]
(defconstant M_2_SQRTPI	c-m_2_sqrtpi)	;2/sqrt(pi)
(defconstant M_SQRT2	c-m_sqrt2)	;sqrt(2)
(defconstant M_SQRT3	1.73205080756887729352)	;sqrt(3) [4.0.2]
(defconstant M_SQRT1_2	0.70710678118654752440)	;1/sqrt(2)
(defconstant M_LNPI	1.14472988584940017414)	;log_e(pi) [4.0.2]
(defconstant M_EULER	0.57721566490153286061)	;Euler constant [4.0.2]


;; Math functions

; abs -- Absolute value
(defalias abs php-abs)
(defbuiltin (php-abs num)
   (abs (mkflo num)))
   
; acos -- Arc cosine
(defalias acos php-acos)
(defbuiltin (php-acos num)
   (acos (mkflo num)))
   
; acosh -- Inverse hyperbolic cosine
(defbuiltin (acosh num)
   (cond-expand
      ; not in mingw
      (PCC_MINGW (mingw-missing 'acosh))
      (else 
       (c-acosh (mkflo num)))))

; asin -- Arc sine
(defalias asin php-asin)
(defbuiltin (php-asin num)
   (asin (mkflo num)))

; asinh -- Inverse hyperbolic sine
(defbuiltin (asinh num)
   (cond-expand
      ; not in mingw
      (PCC_MINGW (mingw-missing 'asinh))
      (else 
       (c-asinh (mkflo num)))))

; atan -- Arc tangent
(defalias atan php-atan)
(defbuiltin (php-atan num)
   (atan (mkflo num)))

; atanh -- Inverse hyperbolic tangent
(defbuiltin (atanh num)
   (cond-expand
      ; not in mingw
      (PCC_MINGW (mingw-missing 'atanh))
      (else 
       (c-atanh (mkflo num)))))

; atan2 -- arc tangent of two variables
(defbuiltin (atan2 num num1) 
   (atan (mkflo num) (mkflo num1)))


; base_convert -- Convert a number between arbitrary bases
(defbuiltin (base_convert num-str frombase tobase)
   (let ((res (integer->string/base (garbage->number/base (mkstr num-str) (mkfixnum frombase))
				    (mkfixnum tobase))))
      res))
   

; bindec -- Binary to decimal
(defbuiltin (bindec num-str)
   (garbage->number/base (mkstr num-str) 2))


; ceil -- Round fractions up
(defbuiltin (ceil num)
   (ceiling (mkflo num)))

; cos -- Cosine
(defalias cos php-cos)
(defbuiltin (php-cos num)
   (cos (mkflo num)))

; cosh -- Hyperbolic cosine
(defbuiltin (cosh num)
   (c-cosh (mkflo num)))

; decbin -- Decimal to binary
(defbuiltin (decbin num)
   (integer->string/base (mkfixnum num) 2))

; dechex -- Decimal to hexadecimal
(defbuiltin (dechex num)
   (integer->string/base (mkfixnum num) 16))

; decoct -- Decimal to octal
(defbuiltin (decoct num)
   (integer->string/base (mkfixnum num) 8))

; deg2rad --  Converts the number in degrees to the radian equivalent
(defbuiltin (deg2rad num)
   (php-* M_PI (php-/ (mkflo num) 180)))

; exp -- e to the power of ...
(defalias exp php-exp)
(defbuiltin (php-exp pow)
   (exp (mkflo pow)))

; expm1 --  Returns exp(number) - 1, computed in a way that accurate even when the value of number is close to zero
(defbuiltin (expm1 num)
   (cond-expand
      ; not in mingw
      (PCC_MINGW (mingw-missing 'expm1))
      (else 
       (c-expm1 (mkflo num)))))

; floor -- Round fractions down
(defalias floor php-floor)
(defbuiltin (php-floor num)
   (floor (mkflo num)))

; getrandmax -- Show largest possible random value
(defbuiltin (getrandmax)
   PHP_RAND_MAX)

; hexdec -- Hexadecimal to decimal
(defbuiltin (hexdec num-str)
   (garbage->number/base (mkstr num-str) 16))

; hypot --  Returns sqrt( num1*num1 + num2*num2)
(defbuiltin (hypot a b)
   (c-hypot (mkflo a) (mkflo b)))

; is_finite --
(defbuiltin (is_finite a)
   (float-is-finite? (mkflo a)))
    
; is_infinite --
(defbuiltin (is_infinite a)
   (not (or (float-is-finite? (mkflo a))
	    (float-is-nan? (mkflo a)))))

; is_nan --
(defbuiltin (is_nan a)
   (float-is-nan? (mkflo a)))


; lcg_value -- Combined linear congruential generator

; log -- Natural logarithm
(defalias log php-log)
(defbuiltin (php-log num (base 'unpassed))
   (if (eqv? base 'unpassed)
       (log (mkflo num))
       ; log b (n) = log(n) / log(b)
       (/fl (log (mkflo num)) (log (mkflo base)))))

; log10 -- Base-10 logarithm
(defbuiltin (log10 num)
   (c-log10 (mkflo num)))

; log1p --  Returns log(1 + number), computed in a way that accurate even when the val ue of number is close to zero
(defbuiltin (log1p num)
   (c-log1p (mkflo num)))


; get array # that wins for <func>
;
;   0 1 2 list-ref number
;
;( (8 2 6)   0 
;  (4 2 1)   1  array number
;  (9 4 1) ) 2
;
; return array number for which <func> is wins in column col
(define (pick-winner func alist col)
   (let ((alen (length alist))
	 (best-val (list-ref (list-ref alist 0) col))
	 (best-arr 0)
	 (allsame #t))
      ;(print "alen is " alen " best-val " best-val " best-arr " best-arr)
      (let loop ((a 1))
	 ;(print "loop a " a)
	 (if (< a alen)
	     (let ((comp-val (list-ref (list-ref alist a) col)))
		;(print "best-val " best-val " vs comp-val " comp-val)
		(when (and allsame
			   (not (eqv? comp-val best-val)))
		   ;(print "not all same")
		   (set! allsame #f))		
		(when (func comp-val best-val)
		   (begin
		      (set! best-val comp-val)
		      (set! best-arr a)))		   
		(loop (+ a 1)))
	     (if allsame
		 #f
		 best-arr)))))
      
(define (minmax-hash func hash-list)
   (let ((maxsize (apply min (map php-hash-size hash-list)))
	 (alists (map php-hash->list hash-list)))
      (let loop ((x 0))
	 (when (< x maxsize)
	    (let ((result (pick-winner func alists x)))
	       (if result
		   (list-ref hash-list result)
		   (loop (+ x 1))))))))


; max -- Find highest value
(defalias max php-max)
(defbuiltin-v (php-max a1-n)
   (letrec ((max-1
             (lambda (a1-n)
                (cond ((and (> (length a1-n) 1) ; a list of non-hashes
                            (not (any? php-hash? a1-n)))
                       ;; no hashes
                       (let loop ((a (mkflo (car a1-n)))
                                  (b (mkflo (cadr a1-n)))
                                  (max (car a1-n))
                                  (args (cdr a1-n)))
                          (when (> b a)
                             (set! a b)
                             (set! max (car args)))
                          (if (null? (cdr args))
                              ;; we have to return the original argument, not the
                              ;; float we made for comparing them.
                              max
                              (loop a (mkflo (cadr args)) max (cdr args)))))
                      ;; a list of hashes
                      ((and (> (length a1-n) 1)
                            (every? php-hash? a1-n))
                       (minmax-hash php-> a1-n))
                      ;; mixed list with at least one hash - return the first hash
                      ((and (> (length a1-n) 1)
                            (any? php-hash? a1-n))
                       (car (filter php-hash? a1-n)))
                      ;; single hash
                      ((php-hash? (car a1-n))
                       (max-1 (php-hash->list (car a1-n))))
                      ;; "other"
                      (else
                       (php-warning "max requires at least 2 parameters, or a single array")
                       0)))))
      (max-1 a1-n)))
   
; min -- Find lowest value
(defalias min php-min)
(defbuiltin-v (php-min a1-n)
   (letrec ((min-1
             (lambda (a1-n)
                (cond
                   ;; no hashes
                   ((and (> (length a1-n) 1)
                         (not (any? php-hash? a1-n)))
                    (let loop ((a (mkflo (car a1-n)))
                               (b (mkflo (cadr a1-n)))
                               (min (car a1-n))
                               (args (cdr a1-n)))
                       (when (< b a)
                          (set! a b)
                          (set! min (car args)))
                       (if (null? (cdr args))
                           ;; we have to return the original argument, not the
                           ;; float we made for comparing them.
                           min
                           (loop a (mkflo (cadr args)) min (cdr args)))))
                   ;; a list of hashes
                   ((and (> (length a1-n) 1)	       
                         (every? php-hash? a1-n))
                    (minmax-hash php-< a1-n))
                   ;; mixed list with at least one hash - return the first non hash
                   ((and (> (length a1-n) 1)
                         (any? php-hash? a1-n))
                    (car (filter (lambda (f) (not (php-hash? f))) a1-n)))
                   ;; single hash
                   ((php-hash? (car a1-n))
                    (min-1 (php-hash->list (car a1-n))))
                   ;; "other"
                   (else
                    (php-warning "min requires at least 2 parameters, or a single array")
                    0)))))
      (min-1 a1-n)))


; mt_rand -- Generate a better random value
(defbuiltin (mt_rand (min 0) (max PHP_MT_RAND_MAX))
   (set! min (convert-to-number min))
   (set! max (convert-to-number max))
   ;implement this the interesting way that php does
   (unless *mt-rand-seeded?*
      (mt_srand (rand-seed)))
   (convert-to-number (randomMT-range (onum->elong min) (onum->elong max))))

; mt_srand -- Seed the better random number generator
(defbuiltin (mt_srand seed)
   (seedMT (mkflo seed))
   (set! *mt-rand-seeded?* #t)
   #t)

; mt_getrandmax -- Show largest possible random value
(defbuiltin (mt_getrandmax)
   PHP_MT_RAND_MAX)

; octdec -- Octal to decimal
(defbuiltin (octdec num-str)
   (garbage->number/base (mkstr num-str) 8))


; pi -- Get value of pi
(defalias pi php-pi)
(defbuiltin (php-pi)
   M_PI)

(define (php-expt base power)
  (define (maybe-integer-expt acc pwr) ;expects integer pwr>=1
    (debug-trace 0 "acc is " acc ", pwr is " pwr ", is it fixnum? " (fixnum? acc) " or flonum? " (flonum? acc))
    (if (fixnum? acc)
        (cond ((= pwr 1) acc)
              ((even? pwr) (maybe-integer-expt (onum*-bgl acc acc) (/ pwr 2)))
              (#t (maybe-integer-expt (onum*-bgl acc base) (- pwr 1))))
        (expt base power)))
  (if (and (fixnum? base) (fixnum? power))
      (if (= power 0) 1
          (maybe-integer-expt base power))
      (expt base power)))

(define (onum*-bgl a b)
  (mkfix-or-flonum (onum* (convert-to-number a) (convert-to-number b))))


;; pow -- Exponential expression
(defbuiltin (pow base power)
;  (_c-pow  (mkflo base) (mkflo power)))
  (php-expt (mkfix-or-flonum base) (mkfix-or-flonum power)))

;; rad2deg --  Converts the radian number to the equivalent number in degrees
(defbuiltin (rad2deg num)
   (php-* 180 (php-/ num M_PI)))


(define *mt-rand-seeded?* #f)


;generate a seed for srand
(define (rand-seed)
   (* (pragma::double "time((void*)0)")
      (cond-expand
	 (PCC_MINGW
	  (pragma::int "GetCurrentProcessId()"))
	 (else
	  (pragma::int "getpid()")))))
	  

; rand -- Generate a random value
(defalias rand mt_rand)
   

; round -- Rounds a float
(defalias round php-round)
(defbuiltin (php-round num (prec 0))
   (set! num (mkflo num))
   (set! prec (mkflo prec))
   (let ((schnoz (_c-pow 10.0 prec)))
      (set! num (*fl num schnoz))
      (if (>= num 0.0)
	  (set! num (floor (+ num 0.5)))
	  (set! num (ceil (- num 0.5))))
      (/fl (mkflo num) schnoz)))

; sin -- Sine
(defalias sin php-sin)
(defbuiltin (php-sin num)
   (sin (mkflo num)))


; sinh -- Hyperbolic sine
(defbuiltin (sinh num)
   (c-sinh (mkflo num)))

; sqrt -- Square root
(defalias sqrt php-sqrt)
(defbuiltin (php-sqrt num)
   (_c-sqrt (mkflo num)))


; srand -- Seed the random number generator
(defalias srand mt_srand)

; tan -- Tangent
(defalias tan php-tan)
(defbuiltin (php-tan num)
   (tan (mkflo num)))

; tanh -- Hyperbolic tangent
(defbuiltin (tanh num)
   (c-tanh (mkflo num)))

;this is for the C functions, because bigloo won't coerce a bint to a
;double. I suppose you could add the coercion, too.
(define (mkflo num)
   (onum->float (convert-to-number num)))


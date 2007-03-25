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

;;;;bind to the opaque math module
(module opaque-math
   (type
    (subtype onum          "obj_t"              (obj))
    ;; an onum is an obj
    (coerce onum obj           ()               ())
    (coerce obj onum           (onum?)          ())
    ;; an obj of type real or belong
    (coerce belong onum        ()               ())
    (coerce elong onum         ()               (elong->onum))
    
    (coerce real onum          ()               ())
    (coerce double onum        ()               (float->onum))
   

    )
   (extern
    (include "opaque-math.h")
    ;onum stands for opaque number.  we use void* instead of phpnum* so that
    ;nobody needs to include opaque-math.h.
    (onum+::onum (a::onum b::onum) "phpadd")
    (onum-::onum (a::onum b::onum) "phpsub")
    (onum*::onum (a::onum b::onum) "phpmul")
    (onum/::onum (a::onum b::onum) "phpdiv")
    (onum%::onum (a::onum b::onum) "phpmod")

    (macro elong->onum::onum (num::elong) "LONG_TO_BELONG") ;"long_to_phpnum")
    (macro float->onum::onum (num::double) "DOUBLE_TO_REAL") ;"double_to_phpnum")

    (onum->elong::elong (num::onum) "phpnum_to_long")
    (onum->float::double (num::onum) "phpnum_to_double")
    (onum-compare::int (a::onum b::onum) "phpnum_compare")
    (%onum->string::bstring (a::onum precision::int efg::int) "phpnum_to_string")
    (string->onum/float::onum (str::string) "string_to_float_phpnum")
    (string->onum/long::onum (str::string) "string_to_long_phpnum")
    (macro onum-is-long::int (a::onum) "phpnum_is_long")
    (macro onum-is-float::int (a::onum) "phpnum_is_float")

    (macro fast-onum-is-long::bool (a::onum) "PHPNUM_IS_LONG")
    (macro fast-onum-is-float::bool (a::onum) "PHPNUM_IS_FLOAT")
    (macro fast-onum-compare-long::int (a::onum b::onum) "PHPNUM_COMPARE_LONG")

    (macro onum-hashnumber::int (a::onum) "PHPNUM_HASHNUMBER")
    (export phpnum_fail "phpnum_fail"))
   (pragma
    (onum? (predicate-of onum) no-cfa-top nesting) )
   (export
    *float-precision*
    *MAX-INT-SIZE-L*
    *MIN-INT-SIZE-L*
    *MAX-INT-SIZE-F*
    *MIN-INT-SIZE-F*
    *SIZEOF-LONG*
    (onum->string::bstring a::onum precision::int)
    (onum->string/e::bstring a::onum precision::int)
    (onum->string/f::bstring a::onum precision::int)
    (onum->string/g::bstring a::onum precision::int)
    (phpnum_fail reason::string)
    (onum->int::int num::onum) 
    (int->onum::onum num::int)
    (onum-long? a::onum)
    (onum-float? a::onum)
    (inline onum?::bool ::obj)))

; the float version is used in the lexer
(define *MAX-INT-SIZE-L*
   (pragma::elong "PHP_LONGMAX"))

(define *MAX-INT-SIZE-F*
   (elong->flonum *MAX-INT-SIZE-L*))

(define *MIN-INT-SIZE-L*
   (pragma::elong "PHP_LONGMIN"))

(define *MIN-INT-SIZE-F*
   (elong->flonum *MIN-INT-SIZE-L*))

(define *SIZEOF-LONG*
   (pragma::elong "sizeof(long)"))

(define-inline (onum?::bool obj::obj)
   (pragma::bool "(ELONGP($1) || REALP($1))" obj))

(define (onum-long? a::onum)
   (>fx (onum-is-long a) 0))

(define (onum-float? a::onum)
   (>fx (onum-is-float a) 0))

;this routine is used by the C code to signal an arithmetic error
(define (phpnum_fail reason::string)
   (error "" (string-append "Arithmetic Error: " reason) ""))

(define *float-precision* 14) ;should come from an INI entry

(define (onum->int::int num::onum)
   (flonum->fixnum (elong->flonum (onum->elong num))))

(define (int->onum::onum num::int)
   (elong->onum (make-elong num)))

; (define (main argv)
;    (let ((bob (float->onum 1.1447298858494))
; 	 (cindy (int->onum 2)))
;       (print (onum->string bob 14))
;       (print (onum->string (onum* bob cindy) 14))))
	 
;    (bind-exit (return)
;       (let (($j::onum  #e0)
; 	    ($i (elong->onum #e0))
; 	    (million (float->onum 1000000.0))
; 	    (one (elong->onum #e1))
; 	    (two (elong->onum #e2)))
; 	 (set! $i (elong->onum #e0))
; ;	 (onum/ (elong->onum #e2) (elong->onum #e0))
; 	 (let ((started?1002 #f))
; 	    (let loop ()
; 	       (if started?1002
; 		   (set! $i (onum+ $i one))
; 		   (set! started?1002 #t))
; 	       (when (< (onum-compare $i million) 0)
; 		  (set! $j (onum+ $j (onum* $i two)))
; 		  (loop))))
; 	 (print "" (onum->string $j *float-precision*) ", " (onum->string $i *float-precision*) "\n"))
;       '()))

(define (onum->string::bstring a::onum precision::int)
   (onum->string/g a precision))

;; we're using these in php-printf, although at high precision the
;; least significant digits seem to differ from php.  Maybe it's worth
;; switching to ap-php-[efg]cvt.
(define (onum->string/e::bstring a::onum precision::int)
   (%onum->string a precision 0))

(define (onum->string/f::bstring a::onum precision::int)
   (%onum->string a precision 1))

(define (onum->string/g::bstring a::onum precision::int)
   (%onum->string a precision 2))


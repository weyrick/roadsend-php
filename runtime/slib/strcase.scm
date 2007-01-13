(module strcase
   (include "slib/bigloo.init")
   
   (export
;     (string-upcase! str)
;     (string-upcase str)
;     (string-downcase! str)
;     (string-downcase str)
;     (slib:string-capitalize! str)
;     (slib:string-capitalize str)
    string-ci->symbol
    ;	   slib:symbol-append
    (StudlyCapsExpand nstr . delimitr)))

;;; "strcase.scm" String casing functions.
; Written 1992 by Dirk Lutzebaeck (lutzeb@cs.tu-berlin.de)
;
; This code is in the public domain.

; Modified by Aubrey Jaffer Nov 1992.
; SLIB:SYMBOL-APPEND and StudlyCapsExpand added by A. Jaffer 2001.
; Authors of the original version were Ken Dickey and Aubrey Jaffer.

;string-upcase, string-downcase, slib:string-capitalize
; are obvious string conversion procedures and are non destructive.
;string-upcase!, slib:string-downcase!, slib:slib:string-capitalize!
; are destructive versions.

(define (slib:string-upcase! str)
  (do ((i (- (string-length str) 1) (- i 1)))
      ((< i 0) str)
    (string-set! str i (char-upcase (string-ref str i)))))

(define (slib:string-upcase str)
  (slib:string-upcase! (string-copy str)))

(define (slib:string-downcase! str)
  (do ((i (- (string-length str) 1) (- i 1)))
      ((< i 0) str)
    (string-set! str i (char-downcase (string-ref str i)))))

(define (slib:string-downcase str)
  (slib:string-downcase! (string-copy str)))

(define (slib:string-capitalize! str)	; "hello" -> "Hello"
  (let ((non-first-alpha #f)		; "hELLO" -> "Hello"
	(str-len (string-length str)))	; "*hello" -> "*Hello"
    (do ((i 0 (+ i 1)))			; "hello you" -> "Hello You"
	((= i str-len) str)
      (let ((c (string-ref str i)))
	(if (char-alphabetic? c)
	    (if non-first-alpha
		(string-set! str i (char-downcase c))
		(begin
		  (set! non-first-alpha #t)
		  (string-set! str i (char-upcase c))))
	    (set! non-first-alpha #f))))))

(define (slib:string-capitalize str)
  (slib:string-capitalize! (string-copy str)))

(define string-ci->symbol
  (let ((s2cis (if (equal? "x" (symbol->string 'x))
		   slib:string-downcase slib:string-upcase)))
    (lambda (str) (string->symbol (s2cis str)))))

(define slib:symbol-append
  (let ((s2cis (if (equal? "x" (symbol->string 'x))
		   slib:string-downcase slib:string-upcase)))
    (lambda args
      (string->symbol
       (apply string-append
	      (map
	       (lambda (obj)
		 (cond ((string? obj) (s2cis obj))
		       ((number? obj) (s2cis (number->string obj)))
		       ((symbol? obj) (symbol->string obj))
		       ((not obj) "")
		       (else (slib:error 'wrong-type-to 'slib:symbol-append obj))))
	       args))))))

(define (StudlyCapsExpand nstr . delimitr)
  (set! delimitr
	(cond ((null? delimitr) "-")
	      ((char? (car delimitr)) (string (car delimitr)))
	      (else (car delimitr))))
  (do ((idx (+ -1 (string-length nstr)) (+ -1 idx)))
      ((> 1 idx) nstr)
    (cond ((and (> idx 1)
		(char-upper-case? (string-ref nstr (+ -1 idx)))
		(char-lower-case? (string-ref nstr idx)))
	   (set! nstr
		 (string-append (substring nstr 0 (+ -1 idx))
				delimitr
				(substring nstr (+ -1 idx)
					   (string-length nstr)))))
	  ((and (char-lower-case? (string-ref nstr (+ -1 idx)))
		(char-upper-case? (string-ref nstr idx)))
	   (set! nstr
		 (string-append (substring nstr 0 idx)
				delimitr
				(substring nstr idx
					   (string-length nstr))))))))

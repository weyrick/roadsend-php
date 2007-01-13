(module soundex
   (include "slib/bigloo.init") 
   (export (remove-if pred? lst)
	   (soundex str)
	   do-SOUNDEX))

;"soundex.scm" Original SOUNDEX algorithm.
;From jjb@isye.gatech.edu Mon May  2 22:29:43 1994
;
; This code is in the public domain.

;Date: Mon, 2 May 94 13:45:39 -0500

; Taken from Knuth, Vol. 3 "Sorting and searching", pp 391--2

;(require 'common-list-functions)

(define (remove-if pred? lst)
  (let remove-if ((lst lst)
		  (result '()))
    (cond ((null? lst) (reverse result))
	  ((pred? (car lst)) (remove-if (cdr lst) result))
	  (else (remove-if (cdr lst) (cons (car lst) result))))))

(define (soundex str)
   (do-SOUNDEX str))

(define do-SOUNDEX
  (let* ((letters-to-omit
          (list #\A #\E #\H #\I #\O #\U #\W #\Y))
         (codes
          (list (list #\B #\1)
                (list #\F #\1)
                (list #\P #\1)
                (list #\V #\1)
                ;;
                (list #\C #\2)
                (list #\G #\2)
                (list #\J #\2)
                (list #\K #\2)
                (list #\Q #\2)
                (list #\S #\2)
                (list #\X #\2)
                (list #\Z #\2)
                ;;
                (list #\D #\3)
                (list #\T #\3)
                ;;
                (list #\L #\4)
                ;;
                (list #\M #\5)
                (list #\N #\5)
                ;;
                (list #\R #\6)))
         (xform
          (lambda (c)
            (let ((code (assv c codes)))
              (if code
                  (cadr code)
                  c)))))
    (lambda (name)
      (let ((char-list
             (map char-upcase
                  (remove-if (lambda (c)
                               (not (char-alphabetic? c)))
                             (string->list name)))))
        (if (null? char-list)
            name
            (let* ( ;; Replace letters except first with codes:
                   (n1 (cons (car char-list) (map xform char-list)))
                   ;; If 2 or more letter with same code are adjacent
                   ;; in the original name, omit all but the first:
                   (n2 (let loop ((chars n1))
                         (cond ((null? (cdr chars))
                                chars)
                               (else
                                (if (char=? (xform (car chars))
                                            (cadr chars))
                                    (loop (cdr chars))
                                    (cons (car chars) (loop (cdr chars))))))))
                   ;; Omit vowels and similar letters, except first:
                   (n3 (cons (car char-list)
                             (remove-if
                              (lambda (c)
                                (memv c letters-to-omit))
                              (cdr n2)))))
              ;;
              ;; pad with 0's or drop rightmost digits until of form "annn":
              (let loop ((rev-chars (reverse n3)))
                (let ((len (length rev-chars)))
                  (cond ((= 4 len)
                         (list->string (reverse rev-chars)))
                        ((> 4 len)
                         (loop (cons #\0 rev-chars)))
                        ((< 4 len)
                         (loop (cdr rev-chars))))))))))))



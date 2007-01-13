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

;;; There are two approaches to appending strings quickly:
;;;   - append them lazily
;;;   - memoize the append function
;;; These might be compatible with each other.  In this file, we
;;; will investigate both approaches.
(module fast-string-append
   (extern
    (include "opaque-math.h")
    (mixed-hashnumber::int (obj1::obj obj2::obj) "mixed_hash_number"))
   (import (utils "utils.scm")
	   (opaque-math "opaque-math-binding.scm"))
   (export (fast-string-append a b)
	   (fast-onum->string a precision)))

;;; we build a simple closed hashtable for memoizing results

;; the approximate maximum memory usage will be around 10000 x 1024
;; characters ~= 10 megs.  This important -- imagine if somebody
;; starts prepending to a megabyte string!
(define *string-table-size* 10000)
(define *maximum-memo-length* 1024)

(define *memoized-results*
   (make-memo-table *string-table-size*))

;;; maybe we could use bigloo's typed vectors here?
(define (make-memo-table size)
   (make-vector (least-power-of-2-greater-than size)
		#f))

; (define *matched* 0)
; (define *missed* 0)

(define (fast-string-append a b)
   ;; XXX it seems to me like the GC might free a string, and then
   ;; allocate a new one in the same spot... so even if they're
   ;; immutable, we still can't depend on their address as a memo key.
   ;; Hm.  So I should probably take this code out, but I want to do a
   ;; before/after benchmark and don't have time now.  --timjr 2006.3.22
   (if (> (+ (string-length a) (string-length b)) *maximum-memo-length*)
       (string-append a b)
       (let ((key 
              (bit-and (mixed-hashnumber a b)
                       (-fx (vector-length *memoized-results*) 1))))
          (let ((memoized-result (vector-ref *memoized-results* key)))
             (if (and (epair? memoized-result)
                      (eq? (car memoized-result) a)
                      (eq? (cdr memoized-result) b))
                 (begin
                    ;		(set! *matched* (+ *matched* 1))
                    (cer memoized-result))
                 (let ((new-result (string-append a b)))
                    (vector-set! *memoized-results*
                                 key
                                 (econs a b new-result))
                    ;		(set! *missed* (+ *missed* 1))
                    new-result))))))


(define *memoized-onums*
   (make-memo-table 10000))

; (define *onum-matched* 0)
; (define *onum-missed* 0)


(define (fast-onum->string a precision)
   (let ((key 
	  (bit-and (onum-hashnumber a)
		   (-fx (vector-length *memoized-onums*) 1))))
      (let ((memoized-result (vector-ref *memoized-onums* key)))
	 (if (and (pair? memoized-result)
		  (zero? (onum-compare (car memoized-result)
				       a)))
	     (begin
;		(set! *onum-matched* (+ *onum-matched* 1))
		(cdr memoized-result))
	     (let ((new-result (onum->string a precision)))
		(vector-set! *memoized-onums*
			     key
			     (cons a new-result))
;		(set! *onum-missed* (+ *onum-missed* 1))
		new-result)))))


; (register-exit-function!
;  (lambda (a)
;     (fprint (current-error-port) "matched: " *matched* " missed: " *missed*)
;     (fprint (current-error-port) "onum-matched: " *onum-matched* " onum-missed: " *onum-missed*)
;     a))



; (define (fast-string-append a b)
;    (let ((key (memo-index *memoized-results* a b)))
;       (or (memo-table-lookup *memoized-results* key a b)
; 	  (memo-table-update! *memoized-results* key
; 			      (string-append a b)))))



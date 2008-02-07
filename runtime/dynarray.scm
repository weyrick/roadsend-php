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
(module dynarray
;   (main main)
   (export
    (make-dynarray::%dyn)
    (dynarray-length::bint d::%dyn)
    (inline dynarray-ref::obj d::%dyn i::bint)
    (inline dynarray-set! d::%dyn i::bint el::obj)
    (dynarray-remove! d::%dyn i::bint)
    (dynarray-pushback!::bint d::%dyn el::obj)
    (dynarray-popback!::obj d::%dyn)
    (dynarray-shrink! d::%dyn)
    (dynarray-copy::%dyn d::%dyn)
    (class %dyn
       size::bint
       store::vector)))

(define *default-size* 8)
;; the longest vector bigloo will give us:
;;(define *longest-vector* (bit-lsh 1 23))
(define *tombstone* (cons 'tomb 'stone))

(define-inline (%empty? el)
   (eq? el *tombstone*))

(define (make-dynarray::%dyn)
   (make-%dyn 0 (make-vector *default-size*)))

(define (dynarray-length::bint d::%dyn)
   (%dyn-size d))

(define-inline (dynarray-ref::obj d::%dyn i::bint)
   (vector-ref (%dyn-store d) i))

(define-inline (dynarray-set! d::%dyn i::bint el::obj)
   (vector-set! (%dyn-store d) i el))

(define (dynarray-remove! d::%dyn i::bint)
   (with-access::%dyn d (size store)
;      [assert () (not (%empty? (vector-ref store i)))]
      (vector-set! store i *tombstone*)
      (set! size (- size 1))))

;; Push an item onto the end of the dynamic array, resizing if
;; necessary.  Returns the index of the new item.
(define (dynarray-pushback!::bint d::%dyn el::obj)
   (%grow! d)
   (with-access::%dyn d (size store)
      (let ((i size))
	 (vector-set! store i el)
	 (set! size (+ size 1))
	 i)))

(define (dynarray-popback!::obj d::%dyn)
   (with-access::%dyn d (size store)
;;      [assert () (> size 0)]
      (set! size (- size 1))
      (let ((el (vector-ref store size)))
;;	 [assert () (not (%empty? el))]
	 (vector-set! store size el)
	 el)))

;; If d is less than 1/4 full, shrink it by a factor of 4.  This
;; compacts d, so it will invalidate old indices! Not called
;; automatically.
(define (dynarray-shrink! d::%dyn)
   (with-access::%dyn d (size store)
      (when (< size (bit-rsh (vector-length store) 2))
	 (let ((new-store (make-vector (bit-rsh (vector-length store) 2))))
	    (flush-output-port (current-output-port))
	    (%copy-store! store new-store size)
	    (set! store new-store)))))

;; Grow is called automatically.  If the dynarray's store is full,
;; double it.  Preserves old indices.
(define-inline (%grow! d)
   (with-access::%dyn d (size store)
      (when (= size (vector-length store))
	 (let ((new-store (make-vector (*fx 2 (vector-length store)))))
	    (%copy-store! store new-store size)
	    (set! store new-store)))))

(define (%copy-store! from to cnt)
   (let loop ((i 0)
	      (j 0))
      (when (< j cnt)
	 (let ((el (vector-ref from i)))
	    (if (%empty? el)
		(loop (+ i 1) j)
		(begin
		   (vector-set! to j el)
		   (loop (+ i 1) (+ j 1))))))))

(define (dynarray-copy::%dyn d::%dyn)
   (with-access::%dyn d (size store)
      (%dyn size (copy-vector store (vector-length store)))))

; (define (main argv)
;    (let ((d (make-dynarray)))
;       (let loop ((i 0))
; 	 (when (< i 2000000)
; 	    (dynarray-pushback! d i)
; 	    (loop (+ i 1))))
;       (let loop ((i (- 2000000 1)))
; 	 (when (>= i 0)
; 	    (dynarray-remove! d i)
; 	    (loop (- i 1))))
;       (print (vector-length (%dyn-store d)))))

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

(module grass
   (extern
    ;the one is because bigloo bites
    (get-grassnumber::int (obj::obj) "whoop_obj_hash_number")
    (phpstring-hashnumber1::int (str::string) "php_string_hash_number"))
   (export  (make-grasstable::struct)
	    (make-grasstable/size::struct size::int)
	    (clear-grasstable! table::struct)
	    (grasstable?::bool ::obj)
	    (grasstable-size::int ::struct)
	    (grasstable-get::obj ::struct ::obj)
	    (grasstable-put! ::struct ::obj ::obj)
	    (grasstable-update! ::struct ::obj ::procedure ::obj)
	    (grasstable-remove!::bool ::struct ::obj)
	    (grasstable->vector::vector ::struct)
	    (grasstable->list::pair-nil ::struct)
	    (grasstable-key-list::pair-nil ::struct)
	    (grasstable-for-each ::struct ::procedure)))


(define default-grasstable-size 32)
(define default-max-bucket-length 10)

(define-struct %grasstable size max-bucket-len buckets)

(define (make-grasstable::struct)
   (%grasstable 0 default-max-bucket-length
		(make-vector default-grasstable-size '())))

(define (make-grasstable/size::struct size::int)
   (let ((size (least-power-of-2-greater-than (max 1 size))))
      (%grasstable 0 default-max-bucket-length
		   (make-vector size '()))))

(define (clear-grasstable! table::struct)
   ;   (fprint (current-error-port) "grstbl: " (vector-length (%grasstable-keys table)))
   (%grasstable-size-set! table 0)
   (if (> (vector-length (%grasstable-buckets table))
	  default-grasstable-size)
       (%grasstable-buckets-set! table (make-vector default-grasstable-size '()))
       (vector-fill! (%grasstable-buckets table) '())))

(define (grasstable?::bool obj::obj)
   (%grasstable? obj))

(define (grasstable-size::int table::struct)
   (%grasstable-size table))

(define (grasstable->vector table::struct)
   (let* ((vec (make-vector (grasstable-size table)))
	  (buckets (%grasstable-buckets table))
	  (buckets-len (vector-length buckets)))
      (let loop ((i 0)
		 (w 0))
	 (if (=fx i buckets-len)
	     vec
	     (let liip ((bucket (vector-ref-ur buckets i))
			(w w))
		(if (null? bucket)
		    (loop (+fx i 1) w)
		    (begin
		       (vector-set-ur! vec w (cdar bucket))
		       (liip (cdr bucket) (+fx w 1)))))))))

(define (grasstable->list table::struct)
   (let* ((vec (make-vector (grasstable-size table)))
	  (buckets (%grasstable-buckets table))
	  (buckets-len (vector-length buckets)))
      (let loop ((i 0)
		 (res '()))
	 (if (=fx i buckets-len)
	     res
	     (let liip ((bucket (vector-ref-ur buckets i))
			(res res))
		(if (null? bucket)
		    (loop (+fx i 1) res)
		    (liip (cdr bucket) (cons (cdar bucket) res))))))))

(define (grasstable-key-list table::struct)
   (let* ((vec (make-vector (grasstable-size table)))
	  (buckets (%grasstable-buckets table))
	  (buckets-len (vector-length buckets)))
      (let loop ((i 0)
		 (res '()))
	 (if (=fx i buckets-len)
	     res
	     (let liip ((bucket (vector-ref-ur buckets i))
			(res res))
		(if (null? bucket)
		    (loop (+fx i 1) res)
		    (liip (cdr bucket) (cons (caar bucket) res))))))))

(define (grasstable-for-each table::struct fun::procedure)
   (let* ((buckets (%grasstable-buckets table))
	  (buckets-len (vector-length buckets)))
      (let loop ((i 0))
	 (if (<fx i buckets-len)
	     (begin
		(for-each (lambda (cell)
			     (fun (car cell) (cdr cell)))
			  (vector-ref-ur buckets i))
		(loop (+fx i 1)))))))

(define (grasstable-get table::struct key::obj)
;   (print "grasstable-get key is :" key)
   (let* ((buckets (%grasstable-buckets table))
	  (bucket-len (vector-length buckets))
	  (bucket-num (bit-and (get-grassnumber key) (-fx bucket-len 1)))
	  (bucket (vector-ref-ur buckets bucket-num)))
      (let loop ((bucket bucket))
	 (cond
	    ((null? bucket)
	     #f)
	    ((eq? (caar bucket) key) (cdar bucket))
	    (else
	     (loop (cdr bucket)))))))

(define (grasstable-put! table::struct key::obj obj::obj)
   (let* ((buckets (%grasstable-buckets table))
	  (bucket-len (vector-length buckets))
	  (bucket-num (bit-and (get-grassnumber key) (-fx bucket-len 1)))
	  (bucket (vector-ref-ur buckets bucket-num))
	  (max-bucket-len (%grasstable-max-bucket-len table)))
      (if (null? bucket)
	  (begin
	     (%grasstable-size-set! table (+fx (%grasstable-size table) 1))
	     (vector-set-ur! buckets bucket-num (list (cons key obj)))
	     obj)
	  (let loop ((buck bucket)
		     (count 0))
	     (cond
		((null? buck)
		 (%grasstable-size-set! table (+fx (%grasstable-size table) 1))
		 (vector-set-ur! buckets bucket-num (cons (cons key obj) bucket))
		 (if (>fx count max-bucket-len)
		     (grasstable-expand! table))
		 obj)
		((eq? (caar buck) key)
		 (set-cdr! (car buck) obj))
		(else
		 (loop (cdr buck) (+fx count 1))))))))

(define (grasstable-update! table::struct key::obj proc::procedure obj)
   (let* ((buckets (%grasstable-buckets table))
	  (bucket-len (vector-length buckets))
	  (bucket-num (bit-and (get-grassnumber key) (-fx bucket-len 1)))
	  (bucket (vector-ref-ur buckets bucket-num))
	  (max-bucket-len (%grasstable-max-bucket-len table)))
      (if (null? bucket)
	  (begin
	     (%grasstable-size-set! table (+fx (%grasstable-size table) 1))
	     (vector-set-ur! buckets bucket-num (list (cons key obj)))
	     obj)
	  (let loop ((buck bucket)
		     (count 0))
	     (cond
		((null? buck)
		 (%grasstable-size-set! table (+fx (%grasstable-size table) 1))
		 (vector-set-ur! buckets bucket-num (cons (cons key obj) bucket))
		 (if (>fx count max-bucket-len)
		     (grasstable-expand! table))
		 obj)
		((eq? (caar buck) key)
		 (set-cdr! (car buck) (proc (cdar buck))))
		(else
		 (loop (cdr buck) (+fx count 1))))))))
   
(define (grasstable-remove! table::struct key::obj)
   (let* ((buckets (%grasstable-buckets table))
	  (bucket-len (vector-length buckets))
	  (bucket-num (bit-and (get-grassnumber key) (-fx bucket-len 1)))
	  (bucket (vector-ref-ur buckets bucket-num)))
      (cond
	 ((null? bucket)
	  #f)
	 ((eq? (caar bucket) key)
	  (vector-set-ur! buckets bucket-num (cdr bucket))
	  (%grasstable-size-set! table (-fx (%grasstable-size table) 1))
	  #t)
	 (else
	  (let loop ((bucket (cdr bucket))
		     (prev bucket))
	     (if (pair? bucket)
		 (if (eq? (caar bucket) key)
		     (begin
			(set-cdr! prev (cdr bucket))
			(%grasstable-size-set! table
					      (-fx (%grasstable-size table) 1))
			#t)
		     (loop (cdr bucket)
			   bucket))
		 #f))))))
   
(define (grasstable-expand! table)
   (let* ((old-bucks (%grasstable-buckets table))
	  (old-bucks-len (vector-length old-bucks))
	  (new-bucks-len (*fx 2 old-bucks-len))
	  (new-bucks (make-vector new-bucks-len '())))
      (%grasstable-buckets-set! table new-bucks)
      (let loop ((i 0))
	 (if (<fx i old-bucks-len)
	     (begin
		(for-each (lambda (cell)
			     (let* ((key (car cell))
				    (h   (bit-and (get-grassnumber key) (-fx new-bucks-len 1))))
				(vector-set-ur! new-bucks
					     h
					     (cons cell
						   (vector-ref-ur new-bucks h)))))
			  (vector-ref-ur old-bucks i))
		(loop (+fx i 1)))))))

(define (least-power-of-2-greater-than x)
   "calculate the least power of 2 greater than x"
   ;bugs here? probably. can you find them?  I bet not.
   (set! x (-fx x 1))
   (set! x (bit-or x (bit-rsh x 1)))
   (set! x (bit-or x (bit-rsh x 2)))
   (set! x (bit-or x (bit-rsh x 4)))
   (set! x (bit-or x (bit-rsh x 8)))
   (set! x (bit-or x (bit-rsh x 16)))
   (+fx x 1))

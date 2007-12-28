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
(module php-hash
   (include "php-runtime.sch")
   ; for pcc scheme repl
   (eval (export-module))
   (extern
    (include "opaque-math.h")
    (is-numeric-key::int (str::string length::int) "is_numeric")
    (phpstring-hashnumber::int (str::string) "php_string_hash_number"))
   (import (php-runtime "php-runtime.scm")
	   (php-object "php-object.scm")
	   (utils "utils.scm")
	   (grass "grasstable.scm")
	   (php-errors "php-errors.scm")
	   (opaque-math "opaque-math-binding.scm"))
   (export (make-php-hash::struct)
	   (make-custom-hash::struct read-single::procedure write-single::procedure read-entire::procedure context)
	   (php-hash-lookup-internal-index hash key)
	   (php-hash-internal-index-value::pair index)
	   (php-hash-internal-index-value-set!::pair index value)
	   (php-hash?::bool hash)
	   (php-hash-size::int hash)
	   (php-hash-insert! hash key value)
           (php-hash-insert!/pre hash key hashnumber value)
	   (php-hash-lookup hash key)
	   (php-hash-lookup/pre hash key hashnumber)
	   (php-hash-contains? hash key)
	   (php-hash-lookup-honestly-just-for-reading hash key)
           (php-hash-lookup-honestly-just-for-reading/pre hash key hashnumber)
	   (php-hash-lookup-location hash create?::bool key)
	   (php-hash-remove! hash key)
	   (php-hash-for-each hash thunk::procedure)
	   (php-hash-for-each-with-ref-status hash thunk::procedure)
	   (php-hash-reverse-for-each hash thunk::procedure)
	   (php-hash-for-each-ref hash thunk::procedure)
	   (php-hash-reverse-for-each-ref hash thunk::procedure)	   
	   (php-hash-has-next? hash)
	   (php-hash-has-prev? hash)
	   (php-hash-has-current? hash)
	   (php-hash-in-array? hash needle strict)
	   (php-hash-valid?::bool hash)
	   (php-hash-pop hash)
	   (php-hash-advance hash)
	   (php-hash-prev hash)
	   (php-hash-reset hash)
	   (php-hash-current hash)
	   (php-hash-current-key hash)
	   (php-hash-current-value hash)
	   (php-hash-end hash)
	   (php-hash-append hash-a::struct hash-b::struct)
	   (copy-php-hash::struct hash old-new)
	   (php-hash-compare hash1::struct hash2::struct identical?::bool)
	   (internal-hash-compare h1 h2 identical? seen)
	   (list->php-hash::struct lst)
           (php-hash-entry hash)
           (php-hash-entry-next entry)
           (php-hash-entry-prev entry)
           (php-hash-entry-value entry)
           (precalculate-string-hashnumber key)
	   (php-hash->list hash::struct)
	   (php-hash-keys->list hash::struct)
	   (list-append-php-hash array lst)
	   (php-hash-sort-by-values-trash-keys hash::struct predicate::procedure)
	   (php-hash-sort-by-values-save-keys hash::struct predicate::procedure)
	   (php-hash-sort-by-keys hash::struct predicate::procedure)
	   (convert-to-hash::struct doohickey)
           (php-hash-insert-and-return-container!::pair hash key value)
           (php-hash-next-free-element hash)) )


;this is a hashtable that maintains an ordering of its elements.
;the ordering is implemented as a doubly linked list: next and prev
;pointers in each table entry.  The list is circular, its head and
;tail are a sentinel object. 
;some notes:
;we do check if a string is entirely numeric, and if so treat it as
;a number.  we do _not_ check if a number starts with 0, and treat that
;as a string.  does /anybody/ actually want that?

;the size of the vector in the hashtable needs to always be a power
;of two, or it will royally screw things, because I've changed
;(remainder ...) to (bit-and ...)  

;XXX the internal-index stuff will badly violate PHP's copying semantics
;under the new lazy-copying regime, and must therefore only be used by
;hashes which are NEVER copied!

(define-struct %php-hash ; stuff with a % on front is private
   size
   buckets
   current-index
   maximum-integer-key ;this is one past the end of the integer keys
   head
   tail
   expand-threshold
   refcount
   ;; custom operations
   custom)

(define-struct %hash-overload
   ;; these three are required
   read-single
   write-single
   read-entire
   ;; this is the private data that the functions can use
   context)

(define-inline (%entry chained-entry next prev hashnumber key value)
   (vector chained-entry next prev hashnumber key value))

(define-inline (%entry? a)
   (vector? a))

(define-macro (entry-field name pos)
   `(begin
       (define-inline (,(symbol-append '%entry- name) a)
          (vector-ref-ur a ,pos))
       (define-macro (,(symbol-append '%entry- name '-set!) a b)
          `(vector-set-ur! ,a ,,pos ,b))))

(entry-field chained-entry 0)
(entry-field next 1)
(entry-field prev 2)
(entry-field hashnumber 3)
(entry-field key 4)
(entry-field value 5)

(define (%php-hash-shared? hash)
   (> (container-value (%php-hash-refcount hash)) 0))

(define *default-size* 8);4);16)

(define-inline (expand-threshold size)
   (+fx (bit-rsh size 1) (bit-rsh size 2))) 
;
(define *sentinel-value* 26) ;; random constant

;; more fun to say "sentry?" :)
(define (sentinel?::bool entry)
   (and (fixnum? entry)
	(=fx entry *sentinel-value*)))

;; start the max key at -1
(define *initial-max-key* (int->onum -1))

(define (make-php-hash::struct)
   (%php-hash 0
              (make-vector *default-size* '())
              *sentinel-value* ;; current index
              *initial-max-key*
              *sentinel-value*  ;; initial head
              *sentinel-value*  ;; initial tail
              ;(expand-threshold *default-size*)
              6
              (make-container 0)
              #f))

(define (make-php-hash/size-hint::struct size)
   "Make a php hash big enough for at least _size_ entries. This is
   useful to avoid resizing the hash a bunch of times as it grows."
   (let ((bucket-len (least-power-of-2-greater-than (max 1 size))))
      (when (< (expand-threshold bucket-len) size)
         (set! bucket-len (bit-lsh bucket-len 1)))      
      (%php-hash 0
                 (make-vector bucket-len '())
                 *sentinel-value* ;; current index
                 *initial-max-key*
                 *sentinel-value*  ;; initial head
                 *sentinel-value*  ;; initial tail
                 (expand-threshold bucket-len)
                 (make-container 0)
                 #f)))

(define (clear-php-hash hash::struct)
   "Make a php-hash like new"
   (%force-copy! hash)
   (let ((head *sentinel-value*))
      (%php-hash-size-set! hash 0)
      (%php-hash-buckets-set! hash (make-vector (max 1 *default-size*) '()))
      (%php-hash-current-index-set! hash head)
      (%php-hash-maximum-integer-key-set! hash *initial-max-key*)
      (%php-hash-head-set! hash head)
      (%php-hash-tail-set! hash head)
      (%php-hash-custom-set! hash #f)))

; XXX this can be adapted to sort php-hashs in place
(define (quicksort! vec pred)
   (let ((start-stack (make-vector 32))
	 (end-stack (make-vector 32))
	 (start 0) ; at current depth
	 (end 0)   ; at current depth
	 (offset 0)
	 (loop-i 0); sort depth
	 (i 0)     ; index from start+
	 (k 0))    ; index from end-
      ; initial entry looks at entire array, depth 0
      (vector-set-ur! start-stack 0 0)
      (vector-set-ur! end-stack 0 (- (vector-length vec) 1))
      ; main loop
      (let main-loop ()
	 (when (>= loop-i 0)
	    ; current start/end points of vector
	    (set! start (vector-ref-ur start-stack loop-i))
	    (set! end (vector-ref-ur end-stack loop-i)) 
	    (let next-loop ()
	       (when (< start end)
		  ; compute middle of current set
		  (set! offset (bit-rsh (- end start) 1)) 
		  ; swap begin and offset
		  (vector-swap! vec start (+ start offset))
		  (set! i (+ start 1))
		  (set! k end)
		  (let loop ()
		     (let inc-i ()
			(when (and (< i k)
				   (pred (vector-ref-ur vec i) (vector-ref-ur vec start)))
			   (set! i (+ i 1))
			   (inc-i)))
		     (let dec-k ()
			(when (and (>= k i)
				   (pred (vector-ref-ur vec start) (vector-ref-ur vec k)))
			   (set! k (- k 1))
			   (dec-k)))
		     (unless (>= i k)
			(vector-swap! vec i k)
			(set! i (+ i 1))
			(set! k (- k 1))
			(loop)))
		  (vector-swap! vec start k)
		  (let ((k2 k)) 
		     (if (<= (- k2 start) (- end k2)) 
			 (begin
			    (if (< (+ k2 1) end) 
				(begin
				   (vector-set-ur! start-stack loop-i (+ k2 1)) 
				   (vector-set-ur! end-stack loop-i end) 
				   (set! loop-i (+ loop-i 1))))
			    (set! end (- k2 1))) 
			 (begin
			    (if (> (- k2 1) start)
				(begin
				   (vector-set-ur! start-stack loop-i start)
				   (vector-set-ur! end-stack loop-i (- k2 1))
				   (set! loop-i (+ loop-i 1))))
			    (set! start (+ k2 1)))))
		  ;
		  (next-loop))) ; ie while start < end
	    (set! loop-i (- loop-i 1))
	    (main-loop))) ; while loop-i >= 0
      vec)) ; done
	    

;create a vector from a dlist of entries.
;ensure that the vector's size is a power of 2, for php-hash
(define (dlist->vector head size)
   (let ((vec (make-vector size))); (clp2 size) '())))
      (let loop ((i 0)
		 (entry head));(%entry-next head)))
	 (when (< i size)
	    (vector-set-ur! vec i entry)
	    (loop (+ i 1) (%entry-next entry))))
      vec))

(define (php-hash-sort-by-values-trash-keys hash::struct predicate::procedure)
   (%force-copy! hash)
   (if (custom? hash) (set! hash (custom-read-entire hash)))
   (let ((size (php-hash-size hash))
	 (head (%php-hash-head hash))
 	 (new-predicate (lambda (a b)
 			   (predicate (container-value (%entry-value a))
 				      (container-value (%entry-value b))))))
      (let ((elements-in-order (quicksort! (dlist->vector head size)
					   new-predicate)))
	 (clear-php-hash hash)
	 (let loop ((i 0))
	    (when (< i size)
	       (let ((entry (vector-ref-ur elements-in-order i)))
		  (php-hash-insert! hash i (let ((val (%entry-value entry)))
					      (if (container-reference? val)
						  val
						  (container-value val)))))
	       (loop (+ i 1))))))
   hash)


(define (php-hash-sort-by-values-save-keys hash::struct predicate::procedure)
   (%force-copy! hash)
   (if (custom? hash) (set! hash (custom-read-entire hash)))
   (let ((size (php-hash-size hash))
	 (head (%php-hash-head hash))
	 (new-predicate (lambda (a b)
			   (predicate (container-value (%entry-value a))
				      (container-value (%entry-value b))))))
      (let ((elements-in-order
	     (quicksort! (dlist->vector head size)
			 new-predicate)))
	 (clear-php-hash hash)
	 (let loop ((i 0))
	    (when (< i size)
	       (let ((entry (vector-ref-ur elements-in-order i)))
		  (php-hash-insert! hash
				    (%entry-key entry)
				    (let ((val (%entry-value entry)))
				       (if (container-reference? val)
					   val
					   (container-value val)))))
	       (loop (+ i 1))))
	 hash)))


(define (php-hash-sort-by-keys hash::struct predicate::procedure)
   (%force-copy! hash)
   (if (custom? hash) (set! hash (custom-read-entire hash)))
   (let ((size (php-hash-size hash))
	 (new-predicate (lambda (a b)
			   (predicate (%entry-key a)
				      (%entry-key b)))))
      (let ((elements-in-order
	     (quicksort! (dlist->vector (%php-hash-head hash) size) new-predicate)))
	 (clear-php-hash hash)
	 (let loop ((i 0))
	    (when (< i size)
	       (let ((entry (vector-ref-ur elements-in-order i)))
		  (php-hash-insert! hash (%entry-key entry)
				    (let ((val (%entry-value entry)))
				       (if (container-reference? val)
					   val
					   (container-value val)))))
	       (loop (+ i 1))))
	 hash)))
	    
   
;for type coercion
(define (convert-to-hash::struct doohickey)
   (when (container? doohickey)
      (set! doohickey (container-value doohickey)))
   (cond
      ((php-hash? doohickey) doohickey)
      ((php-null? doohickey) (make-php-hash))
      ((php-object? doohickey) (php-object-props doohickey))
      (else
       (let ((newhash (make-php-hash)))
	  (php-hash-insert! newhash :next doohickey)
	  newhash))))


(define (copy-php-hash::struct hash old-new)
   "Return a copy of a php-hash that doesn't share any structure.
Copies containers.  Keys are not copied."
   (cond
      ((custom? hash) (custom-read-entire hash))
      (else (%copy-php-hash hash old-new))))

(define (%copy-php-hash::struct hash::struct old-new)
   ;;XXX this might have a problem because it doesn't have access to the original container
   (let* ((new-hash (%php-hash
		     (%php-hash-size hash)
		     (%php-hash-buckets hash) ;this is the lazy part -- %force-copy will copy the buckets
		     (%php-hash-current-index hash)
		     (%php-hash-maximum-integer-key hash)
		     (%php-hash-head hash) ;we reuse the old head -- %force-copy will copy it
		     (%php-hash-tail hash) ;we reuse the old tail -- %force-copy will copy it
		     (%php-hash-expand-threshold hash)
		     (%php-hash-refcount hash)
                     (%php-hash-custom hash))))

      (container-value-set! (%php-hash-refcount hash)
                            (+ 1 (container-value (%php-hash-refcount hash))))
      new-hash))

(define (%force-copy! hash::struct)
   (when (%php-hash-shared? hash)
      (if (custom? hash)
         (set! hash (custom-read-entire hash))
         (%separate-internal-hash-structure hash))
      ;; decrement the shared reference counter
      (container-value-set! (%php-hash-refcount hash)
                            (- (container-value (%php-hash-refcount hash))
                               1))
      ;; and start a new reference counter
      (%php-hash-refcount-set! hash (make-container 0))))


(define (%separate-internal-hash-structure hash)
   ;make fresh copies of the internal structures of a php-hash
   (let ((old-current-index (%php-hash-current-index hash))
	 (new-buckets (make-vector (vector-length (%php-hash-buckets hash)) '()))
	 (old-head (%php-hash-head hash))
	 (new-head *sentinel-value*) ;(make-a-hash-head))
	 (new-tail *sentinel-value*) ;(make-a-hash-head))
	 (old-size (%php-hash-size hash))
	 (index-fixed? #f))

;      (debug-trace 1 "in separate, the old current index is " (if (sentinel? old-current-index) 'sentinel 'not-sentinel)
;		   " and the old size is " old-size)
      
      ;reset the table in preparation for recreating it
      (%php-hash-size-set! hash 0)
      (%php-hash-head-set! hash new-head)
      (%php-hash-tail-set! hash new-tail)
      ;(debug-trace 0 "setting index in separate")
      (%php-hash-current-index-set! hash new-head)
      (%php-hash-buckets-set! hash new-buckets)
      
      ;now recreate the hashtable by reinserting all the old entries
      (let loop ((old-entry old-head)
		 (i 0))
	 (unless (sentinel? old-entry)
	    (let* ((old-container (%entry-value old-entry))
		   (ref? (container-reference? old-container)))
	       (let ((new-value
		      (if ref?
			  old-container
			  (let ((old-value (container-value old-container)))
                             (cond ((php-hash? old-value)
                                    ;;this is very important -- if we recursively copy the hash
                                    ;;we're copying, then it will create a new hash that shares
                                    ;;structure with this one, yet this one must be separate after
                                    ;;the call to %separate-i-h-s!
                                    (if (eqv? old-value hash)
                                        hash
                                        (copy-php-hash old-value #f)))
                                   ((php-object? old-value) (copy-php-object old-value #f))
                                   (else old-value))))))
		  (let ((new-entry
			 (%php-hash-insert! hash ref? (%entry-hashnumber old-entry)
					    (%entry-key old-entry) new-value)))
		     (when (eqv? old-entry old-current-index)
;			(debug-trace 1 "index fixed 1, the old entry is " (if (sentinel? old-entry) 'sentinel 'not-sentinel)
;				     " and the old index is " (if (sentinel? old-current-index) 'sentinel 'not-sentinel))
			(set! index-fixed? #t)
                        ;(debug-trace 0 "setting index in separate")
			(%php-hash-current-index-set! hash new-entry)))))
	    (loop (%entry-next old-entry) (+fx i 1))))
;      (cond
	 (when (sentinel? old-current-index)
; 	    ((and (not index-fixed?) (eqv? old-current-index old-head))
; 	    (debug-trace 1 "index fixed 2, the old head is " (if (sentinel? old-head) 'sentinel 'not-sentinel)
; 			 "and the old index is " (if (sentinel? old-current-index) 'sentinel 'not-sentinel))
;	    (debug-trace 1 "the old current index was a sentinel.  thus the new.")
	    (set! index-fixed? #t)
            ;(debug-trace 0 "setting index in separate-internal bork")
	    (%php-hash-current-index-set! hash *sentinel-value*))
; 	 ((and (= old-size 0) (sentinel? old-current-index))
; 	  (%php-hash-current-index-set! hash *sentinel-value*)
; 	  (set! index-fixed? #t)))
      [assert (hash) (or (sentinel? (%php-hash-head hash)) (sentinel? (%entry-prev (%php-hash-head hash))))]
      [assert (hash) (or (sentinel? (%php-hash-tail hash)) (sentinel? (%entry-next (%php-hash-tail hash))))]

      
      ;simple sanity checks
      [assert (index-fixed?) index-fixed?]
      [assert (old-size hash) (=fx old-size (%php-hash-size hash))] ))



(define (php-hash?::bool hash)
   (%php-hash? hash))

(define (php-hash-insert! hash key value)
   (%force-copy! hash)
   (if (custom? hash)
       (custom-write-single hash key value (container? value))
       (let ((key (->insert-key key hash)))
	  (if key
	      (let ((hashnumber (php-hashnumber key)))
		 (%php-hash-insert! hash (if (container? value) #t #f)
				    hashnumber key value) ;)
		 value)
	      value))))

(define (php-hash-insert!/pre hash key hashnumber value)
   ;; same as above, except with a precalculated hashnumber
   ;; key is assumed to be a non-numeric string
   (%force-copy! hash)
   (if (custom? hash)
       (custom-write-single hash key value (container? value))
       (begin
          (%php-hash-insert! hash (if (container? value) #t #f)
                             hashnumber key value)
          value)))


(define (php-hash-insert-and-return-container!::pair hash key value)
   ;; whether we insert by reference or not, this always returns the
   ;; container used to store the value in the hash entry.  I added
   ;; this for php-compat, but it might be generally useful for
   ;; n-dimensional array stuff too.  --timjr
   (%force-copy! hash)
   ;; custom hashes don't necessarily store everything in containers.
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (let ((key (->insert-key key hash)))
      (if key
          (let ((hashnumber (php-hashnumber key)))
             (%entry-value
              (%php-hash-insert! hash (if (container? value) #t #f)
                                 hashnumber key value)))
          (make-container NULL))))

(define (%php-hash-insert!::vector hash::struct ref?::bool hashnumber key value)
;   [assert (hash) (not (%php-hash-shared? hash))]
   [assert (value) (not (%internal-index? value))]
   (when (>fx (%php-hash-size hash) (%php-hash-expand-threshold hash))
      (php-hash-expand! hash))
   (let ((head (%php-hash-head hash))
	 (size (%php-hash-size hash)))
      (let* ((buckets (%php-hash-buckets hash))
	     (bucket-len (vector-length buckets))
	     (bucket-num (bit-and hashnumber (-fx bucket-len 1)))
	     (bucket (vector-ref-ur buckets bucket-num)))
	 (let ((retval
		(let loop ((buck bucket))
		   (cond
		      ((null? buck)
		       (let ((end (%php-hash-tail hash))) ;(%entry-prev head)))
			  (let ((new-entry (%entry bucket
						   *sentinel-value* *sentinel-value* hashnumber key
						   (if ref?
						       (container->reference! value)
						       (make-container value)))))
			     ;; connect new entry to the former tail
			     (%entry-prev-set! new-entry end)
			     ;; set new entry as the new tail
			     (%php-hash-tail-set! hash new-entry)
			     ;; note that we're at the end of the road (XXX redundant)  
			     (%entry-next-set! new-entry *sentinel-value*)

			     ;; XXX can these just go behind an if size == 0?
			     (when (not (sentinel? end))
				;; in case the former tail is a real entry, link it to the new entry
				(%entry-next-set! end new-entry))
			     (when (sentinel? head)
				;; in case the head hadn't been set yet, we're it!
				(%php-hash-head-set! hash new-entry))
			     (when (sentinel? (%php-hash-current-index hash))
				;(debug-trace 0 "I'm assuming this is running.  Is it?")

				;; if there was no current index, we're it!
				(%php-hash-current-index-set! hash new-entry))
			     (%php-hash-size-set! hash (+fx (%php-hash-size hash) 1))
			     (vector-set-ur! buckets bucket-num new-entry);(cons new-entry bucket))
			     new-entry)))
		      ((%php-hash-equal? (%entry-key buck);(car buck))
					 key)
		       (let ((old-entry buck));(car buck)))
			  (if ref?
			      (begin
				 ;(%entry-ref?-set! old-entry ref?)
				 (%entry-value-set! old-entry (container->reference! value)))
			      (container-value-set! (%entry-value old-entry) value))
			  old-entry))
		      (else
		       (loop (%entry-chained-entry buck)
			;(cdr buck)
			     ))))))
	    [assert (hash) (not (=fx (%php-hash-size hash) 0))]
;            [assert (hash) (not (sentinel? (%php-hash-current-index hash)))]
	    [assert (hash) (sentinel? (%entry-prev (%php-hash-head hash)))]
	    [assert (hash) (sentinel? (%entry-next (%php-hash-tail hash)))]
	    retval))))



(define-struct %internal-index
   value
   table)

;;;; the internal-index interface.. leaky?
(define (php-hash-lookup-internal-index hash key)
   "returns the actual a magical value that you can use to refer to
one entry in the hash using the php-hash-internal-index-value and
php-hash-internal-index-value-set! functions.  It's used in evaluate
for all variables, and by compiled code to implement globals.  Returns
#f if the key wasn't in the hash."
   (%force-copy! hash)
   (let* ((key (->lookup-key key hash)))
      (if key
	  (let* ((hashnumber (php-hashnumber key))
		 (value (%php-hash-lookup hash hashnumber key)))
	     (and value
		  ;(cons hash value)
		  (%internal-index value hash)
		  ))
	  #f)))

(define (php-hash-internal-index-value::pair index)
   (%entry-value (%internal-index-value index)));(cdr index)))

(define (php-hash-internal-index-value-set!::pair index value)
   [assert (value) (container? value)]
   (%force-copy! (%internal-index-table index));(car index))
   (%entry-value-set! (%internal-index-value index);(cdr index)
		      value)
   value)

(define (php-hash-lookup hash key)
   (%force-copy! hash)
   (php-hash-lookup-honestly-just-for-reading hash key))

(define (php-hash-lookup/pre hash key hashnumber)
   (%force-copy! hash)
   (php-hash-lookup-honestly-just-for-reading/pre hash key hashnumber))

;this won't force any pending copies, but if you mutate the data
;you looked up, you'll end up violating php's copying semantics.
(define (php-hash-lookup-honestly-just-for-reading hash key)
   (if (custom? hash)
       (custom-read-single hash key #f)
       (let ((key (->lookup-key key hash)))
	  (if key
	      (let* ((hashnumber (php-hashnumber key))
		     (entry (%php-hash-lookup hash hashnumber key)))
		 (if entry
		     (container-value (%entry-value entry))
		     NULL))
	      NULL))))

(define (php-hash-lookup-honestly-just-for-reading/pre hash key hashnumber)
   ;; same as above, except with a precalculated hashnumber
   ;; key is assumed to be a non-numeric string
   (if (custom? hash)
       (custom-read-single hash key #f)
       (let* ((entry (%php-hash-lookup hash hashnumber key)))
          (if entry
              (container-value (%entry-value entry))
              NULL))))

(define (php-hash-contains? hash key)
   "like php-hash-lookup, except it only returns true or false."
   (if (custom? hash)
       (and (custom-read-single hash key #f))
       (let ((key (->lookup-key key hash)))
	  (if key
	      (let* ((hashnumber (php-hashnumber key))
		     (entry (%php-hash-lookup hash hashnumber key)))
		 (if entry
		     #t
		     #f))))))

(define (php-hash-lookup-location hash create?::bool key)
   "get the container of a hash value.  if create? is true, add the
   value if it doesn't exist, so that the container returned will be a
   valid location."
   (%force-copy! hash)
   (if (custom? hash)
       (let ((value (custom-read-single hash key #t)))
          (if (or (and create? (php-null? value))
                  (not (container? value)))
              (let ((c (make-container value)))
                 (custom-write-single hash key c #t)
                 c)
              value))
       (let ((key (->lookup-key key hash)))
	  (if key
	      (let* ((hashnumber (php-hashnumber key))
		     (entry (%php-hash-lookup hash hashnumber key)))
                 (if entry
                     (%entry-value entry)
                     (if create?
                         (%entry-value
                          (%php-hash-insert! hash #f hashnumber key NULL))
                         (make-container NULL))))
	      (make-container NULL)))))

(define (%php-hash-lookup hash::struct hashnumber key)
   (let* ((buckets (%php-hash-buckets hash))
	  (bucket-len (vector-length buckets))
	  (bucket-num (bit-and hashnumber (-fx bucket-len 1)))
	  (bucket (vector-ref-ur buckets bucket-num)))
      (let loop ((bucket bucket))
	 (cond
	    ((null? bucket) #f)
	    ((%php-hash-equal? (%entry-key bucket) key)
	     bucket)
	    (else
	     (loop
	      (%entry-chained-entry bucket)))))))


(define (php-hash-size::int hash)
   (%php-hash-size hash))

(define (php-hash-valid?::bool hash)   
   "validate the integrity of a hash. useful for making sure
a hash unserialized properly"
   (and (php-hash? hash)
	(number? (%php-hash-size hash))
	(vector? (%php-hash-buckets hash))
	(%entry? (%php-hash-current-index hash))
	(onum? (%php-hash-maximum-integer-key hash))
;	(elong? (%php-hash-maximum-integer-key hash))
	(or (%entry? (%php-hash-head hash))
	    (sentinel? (%php-hash-head hash)))
	(or (%entry? (%php-hash-tail hash))
	    (sentinel? (%php-hash-tail hash)))))

					     
(define (php-hash-remove! hash key)
   (cond
      ((custom? hash)
       (php-warning "cannot remove entries from an overridden array")))
   (%force-copy! hash)
   (let ((key (->lookup-key key hash)))
      (if key
	  (let* ((buckets (%php-hash-buckets hash))
		 (bucket-len (vector-length buckets))
		 (bucket-num (bit-and (php-hashnumber key) (-fx bucket-len 1)))
		 (bucket (vector-ref-ur buckets bucket-num)))
	     (cond
		((null? bucket)
		 #f)
		((%php-hash-equal? (%entry-key ;(car bucket)
				    bucket
				    ) key)
		 (vector-set-ur! buckets bucket-num ;(cdr bucket)
				 (%entry-chained-entry bucket))
		 (%php-hash-size-set! hash (-fx (%php-hash-size hash) 1))
		 (%internal-remove hash bucket)
		 
		 ; 		    (%entry-next-set! (%entry-prev entry) (%entry-next entry))
		 ; 		    (%entry-prev-set! (%entry-next entry) (%entry-prev entry)))
		 [assert (hash) (or (sentinel? (%php-hash-head hash)) (sentinel? (%entry-prev (%php-hash-head hash))))]
		 [assert (hash) (or (sentinel? (%php-hash-tail hash)) (sentinel? (%entry-next (%php-hash-tail hash))))]
		 
		 #t)
		(else
		 (let loop ((bucket ;(cdr bucket)
				    (%entry-chained-entry bucket))
			    (prev bucket))
		    (if ;(pair? bucket)
		     (%entry? bucket)
			(if (%php-hash-equal? (%entry-key ;(car bucket)
					       bucket
							  ) key)
			    (begin
			       (%internal-remove hash bucket)
; 				  (%entry-next-set! (%entry-prev entry) (%entry-next entry))
; 				  (%entry-prev-set! (%entry-next entry) (%entry-prev entry)))

			       ;			       (set-cdr! prev (cdr bucket))
			       ;; update the chain
			       (%entry-chained-entry-set! prev (%entry-chained-entry bucket))
			       (%php-hash-size-set! hash
						    (-fx (%php-hash-size hash) 1))
			       [assert (hash) (or (sentinel? (%php-hash-head hash)) (sentinel? (%entry-prev (%php-hash-head hash))))]
			       [assert (hash) (or (sentinel? (%php-hash-tail hash)) (sentinel? (%entry-next (%php-hash-tail hash))))]

			       #t)
			    (loop ;(cdr bucket)
			     (%entry-chained-entry bucket)
				  bucket))

			#f)))))
	  #f)))

(define (%internal-remove hash entry)
   "Remove an entry from the doubly linked list of entries, and update
the current index if it was this entry."
   (let ((prev (%entry-prev entry))
	 (next (%entry-next entry)))
      (if (sentinel? prev)
	  ;; this was the head of the list, so update the head
	  (%php-hash-head-set! hash next)
	  ;; not the head, so update the previous element
	  (%entry-next-set! prev next) )
      (if (sentinel? next)
	  ;; this was the tail of the list, so update the tail
	  (%php-hash-tail-set! hash prev)
	  ;; not the tail, so update the next element
	  (%entry-prev-set! next prev))
      ;; fix current index so we don't point at entries that are gone
      (when (eqv? (%php-hash-current-index hash) entry)
         ;(debug-trace 0 "setting index in internal remove" )
	 (%php-hash-current-index-set! hash next))))

;;;; iteration
(define-inline (get-key-php-type-friendly entry)
   (%entry-key entry))
;    (let ((key (%entry-key entry)))
;       (if (or (fixnum? key)
; 	      (elong? key))
; 	  (convert-to-number key)
; 	  key)))

(define (php-hash-for-each hash thunk::procedure)
   "Thunk will be called once on each key/value set"
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (let loop ((entry (%php-hash-head hash)))
      (unless (sentinel? entry)
         (thunk (get-key-php-type-friendly entry) (container-value (%entry-value entry)))
         (loop (%entry-next entry)))))

(define (php-hash-for-each-with-ref-status hash thunk::procedure)
   "Thunk will be called once on each key/value set. ref status is available to thunk"
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (let loop ((entry (%php-hash-head hash)))
      (unless (sentinel? entry)
         (thunk (get-key-php-type-friendly entry)
                (container-value (%entry-value entry))
                (container-reference? (%entry-value entry)))
         ;		(%entry-ref? entry))
         (loop (%entry-next entry)))))

(define (php-hash-reverse-for-each hash thunk::procedure)
   "In reverse order, thunk will be called once on each key/value set"
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (let loop ((entry (%php-hash-tail hash)))
      (unless (sentinel? entry)
         (thunk (get-key-php-type-friendly entry) (container-value (%entry-value entry)))
         (loop (%entry-prev entry)))))

(define (php-hash-for-each-ref hash thunk::procedure)
   "Thunk will be called once on each key/value set on the actual containers"
   (%force-copy! hash)
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (let loop ((entry (%php-hash-head hash)))
      (unless (sentinel? entry)
         (thunk (get-key-php-type-friendly entry) (%entry-value entry))
         (loop (%entry-next entry)))))

(define (php-hash-reverse-for-each-ref hash thunk::procedure)
   "In reverse order, thunk will be called once on each key/value set on the actual containers"
   (%force-copy! hash)
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (let loop ((entry (%php-hash-tail hash)))
      (unless (sentinel? entry)
         (thunk (get-key-php-type-friendly entry) (%entry-value entry))
         (loop (%entry-prev entry)))))


(define (php-hash-in-array? hash needle strict)
   "Returns true if needle is found in hash values. If strict, we check types as well"
   (let ((found #f)
	 (pred (if strict identicalp equalp)))
      (php-hash-for-each hash (lambda (k v)
				 (unless found
				    (if (pred needle v)
					(set! found #t)))))
      found))

(define (php-hash-current hash)
   "Return current key/value as a pair, or #f if current is past the end"
   ;; since this returns the value by reference, we need to copy it
   (%force-copy! hash)
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (let ((entry (%php-hash-current-index hash)))
      (if (sentinel? entry)
          #f
	  (cons (get-key-php-type-friendly entry)
		(%entry-value entry)))))

;; current-key, current-value, has-current?, and advance, are what the
;; code generator currently spits out for a foreach loop.
(define (php-hash-current-key hash)
   "Return current key, or #f if current is past the end"
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (let ((entry (%php-hash-current-index hash)))
      (if (sentinel? entry)
          #f
          (get-key-php-type-friendly entry))))

(define (php-hash-current-value hash)
   "Return current value, or #f if current is past the end"
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (let ((entry (%php-hash-current-index hash)))
      (if (sentinel? entry)
          #f
          (container-value (%entry-value entry)))))

(define (php-hash-has-next? hash)
   "Can the hash be advanced any more?"
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (not (or (sentinel? (%php-hash-current-index hash))
            (sentinel? (%entry-next
                        (%php-hash-current-index hash))))))

(define (php-hash-has-prev? hash)
   "Can the hash decrement any more?"
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (not (or (sentinel? (%php-hash-current-index hash))
            (sentinel? (%entry-prev (%php-hash-current-index hash))))))

(define (php-hash-has-current? hash)
   "Is the current index valid?"
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (not (sentinel? (%php-hash-current-index hash))))

(define (php-hash-advance hash)
   "Advance the current index by one."
   ;(debug-trace 0 "advancing hash ")
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (let ((index (%php-hash-current-index hash)))
      (or (sentinel? index)
          (begin
             ;(debug-trace 0 "setting index in php-hash-advance")
             (%php-hash-current-index-set! hash
                                           (%entry-next index)))))
   hash)

(define (php-hash-prev hash)
   "Decrement the current index by one"
   ;(debug-trace 0 "rewinding hash")
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (let ((index (%php-hash-current-index hash)))
      (or (sentinel? index)
          ;((debug-trace 0 "setting index in php-hash-prev")
          (%php-hash-current-index-set! hash
                                        (%entry-prev index))))
   hash)

(define (php-hash-reset hash)
   "Reset the current index to zero."
   ;(debug-trace 0 "resetting hash")
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (%php-hash-current-index-set! hash (%php-hash-head hash)))

(define (php-hash-end hash)
   "Set current index to last item in hash"
   ;(debug-trace 0 "sending hash to end hash")
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (%php-hash-current-index-set! hash (%php-hash-tail hash)))

(define (php-hash-pop hash)
   "pop element off end of array, ala array_pop"
   (%force-copy! hash)
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (let ((popped (%php-hash-tail hash))) ;(%entry-prev (%php-hash-head hash))))
      (if (sentinel? popped)
	  NULL
	  (begin
	     (php-hash-remove! hash (%entry-key popped))
	     ;maybe drop the maximum integer key. you would expect this to be
	     ;in php-hash-remove!, but it seems to be here.
	     (when (and (onum? (%entry-key popped))
			(=fx 0 (fast-onum-compare-long (%entry-key popped);(onum+ *one* (%entry-key popped))
						       (%php-hash-maximum-integer-key hash))))
		; 		 (=elong (+elong *one* (onum->elong (%entry-key popped)))
		; 			 (%php-hash-maximum-integer-key hash)))
		(%php-hash-maximum-integer-key-set! hash
						    (onum-
						     (%php-hash-maximum-integer-key hash)
						     *one*)
						    ;  					     (-elong
						    ;  					      (%php-hash-maximum-integer-key hash)
						    ;  					      #e1)
						    ))
	     (%entry-value popped)))))

(define (php-hash-append hash-a::struct hash-b::struct)
   "append hash-b onto hash-a, will NOT overwrite duplicate keys"
   (let ((newhash (make-php-hash)))
      (php-hash-for-each (maybe-unbox hash-a)
			 (lambda (k v)
			    (php-hash-insert! newhash k (copy-php-data v))))
      (php-hash-for-each (maybe-unbox hash-b)
			 (lambda (k v)
			    ;(print "checking " k " " v " which is " (php-hash-lookup newhash k))
			    (when (null? (php-hash-lookup newhash k)) 
			       (php-hash-insert! newhash k (copy-php-data v)))))
      newhash))


(define (precalculate-string-hashnumber key)
   (and (string? key)
        (=fx 0 (is-numeric-key key (string-length key)))
        (php-hashnumber key)))

(define (->lookup-key key hash::struct)
   ;note that this is the same as ->insert-key below, except for the fix-max-key
   (cond
      ((onum? key) (if (fast-onum-is-long key) 
		       key
		       (elong->onum (onum->elong key))))
      ((string? key)
       (if (=fx 0 (is-numeric-key key (string-length key)))
	   key
	   (string->onum/long key)))
      ((container? key) (->lookup-key (container-value key) hash))
      ((fixnum? key) (int->onum key))
      ((elong? key) (elong->onum key))
      ((flonum? key) (convert-to-integer key))
      ((symbol? key) (symbol->string key))
      ((boolean? key) (if key *one* *zero*))
      ((php-null? key) "")
      ((php-resource? key) (int->onum (resource-id key)))
      ((eqv? key :next) (php-error "Can't use [] for reading") #f)
      (else
       (php-warning "Illegal array index " key) #f)))



(define (->insert-key key hash::struct)
   (let ((fix-max-key
	  (lambda (key)
	     (let ((max-key (%php-hash-maximum-integer-key hash)))
		;      XXX really >, or >=?!
		(unless (>fx (fast-onum-compare-long max-key key) 0)
		   (%php-hash-maximum-integer-key-set! hash key));(onum+ key *one*)))
		key))))
      (cond
	 ((onum? key) (if (fast-onum-is-long key) 
			  (fix-max-key key)
			  (let ((lkey (elong->onum (onum->elong key))))
			     ; check for overflow on the float when we convert to long
			     ; XXX checking this by seeing if the float->long conversion returns 0
			     ; is this correct?
			     (if (= lkey 0)
				 ; in this case, zend always uses MIN-INT-SIZE..?
				 (fix-max-key (convert-to-integer *MIN-INT-SIZE-L*))
				 (fix-max-key lkey)))))
	 ((keyword? key)
	  [assert (key) (eqv? key :next)]
	  (let ((max-key (onum+ *one* (%php-hash-maximum-integer-key hash))))
	     (%php-hash-maximum-integer-key-set! hash max-key)
	     max-key))
	 ((string? key)
	  (if (=fx 0 (is-numeric-key key (string-length key)))
	      key
	      (let ((lkey (string->onum/long key)))
		 ; check for overflow, in which case keep as string
		 (if (or (=elong (onum->elong lkey) *MAX-INT-SIZE-L*)
			 (=elong (onum->elong lkey) *MIN-INT-SIZE-L*))
		     key
		     (fix-max-key lkey)))))
	 ((container? key) (->insert-key (container-value key) hash))
	 ((fixnum? key) (fix-max-key (int->onum key)))
	 ((elong? key) (fix-max-key (elong->onum key)))
	 ((flonum? key) (fix-max-key (convert-to-integer key)))
	 ((symbol? key) (symbol->string key))
	 ((php-null? key) "")
	 ((boolean? key) (fix-max-key (if key *one* *zero*)))
         ((php-resource? key) (fix-max-key (int->onum (resource-id key))))
	 (else
	  (php-warning "Illegal offset type") #f))))




(define *max-fixnum* 536870911)

;;;convenience functions

(define (list->php-hash lst)
   ;; it may seem weird to run over the list twice, but it turns out
   ;; to really help for big lists and not matter for small lists.
   (let ((hash (make-php-hash/size-hint (length lst))))
      (enumerate (el i lst)
         (%php-hash-insert! hash (container? el) i (int->onum i) el))
      hash))

(define (php-hash->list hash)
   "Make a list based on the values in the hash. Ignores keys."
   (let ((newlist (list)))
      (php-hash-for-each hash (lambda (k v)
				 (set! newlist (cons v newlist))))
      (reverse! newlist)))

(define (php-hash-keys->list hash)
   "Make a list based on the values in the hash. Ignores values."
   (let ((newlist (list)))
      (php-hash-for-each hash (lambda (k v)
				 (set! newlist (cons k newlist))))
      (reverse! newlist)))

(define (list-append-php-hash array lst)
   "Append items in list onto the given hash, using next available keys"
   (if (php-hash? array)
       (let loop ((lst lst))
	  (if (pair? lst)
	      (begin
		 (php-hash-insert! array :next (car lst))
		 (loop (cdr lst)))
	      array))))


(define (php-hash-compare h1 h2 identical?)
   (internal-hash-compare h1 h2 identical? (make-grasstable)))

(define (internal-hash-compare h1 h2 identical? seen)
   ;;this routine will return 0 if the arrays are the same
   ;;and 1 (and/or -1?) if they are different
   (when (custom? h1) (set! h1 (custom-read-entire h1)))
   (when (custom? h2) (set! h2 (custom-read-entire h2)))
   (grasstable-put! seen h1 #t)
   (grasstable-put! seen h2 #t)
   (let ((size-difference (- (php-hash-size h1) (php-hash-size h2))))
      (if (not (zero? size-difference))
	  size-difference
	  (bind-exit (return)
             ;; The non-obvious thing about this function is that it has to actually
             ;; (return x) if x is not zero, because otherwise the for-each loop down
             ;; below will just keep on keepin' on.
	     (let ((compare-two-values
		    (lambda (h1-value h2-value)
                       (cond
                          ((and (php-hash? h1-value)
                                (php-hash? h2-value))
                           ;;XXX pretend that the recursive hashes are the same
                           (if (and (grasstable-get seen h1-value)
                                    (grasstable-get seen h2-value))
                               0
                               (let ((value (internal-hash-compare h1-value h2-value identical? seen)))
                                  (unless (zero? value)
                                     (return value))
                                  value)))
                          ((and (php-object? h1-value)
                                (php-object? h2-value))
                           (if (and (grasstable-get seen h1-value)
                                    (grasstable-get seen h2-value))
                               0
                               (let ((object-compare-result
                                      (internal-object-compare h1-value h2-value identical? seen)))
                                  ;;internal-object-compare returns #f, 0, or 1
                                  (if (and object-compare-result (= 0 object-compare-result))
                                      0
                                      ;;arbitrary choice
                                      (return 1)))))
                          (else (if identical?
                                    (if (identicalp h1-value h2-value)
                                        0
                                        ;XXX arbitrary
                                        (return 1))
                                    (let ((retval (php-var-compare h1-value h2-value)))
                                       (if (zero? retval)
                                           0
                                           (return retval)))))))))
		(if identical?
		    ;;in this case, the order has to be the same
		    (let loop ((entry1 (%php-hash-head h1))
			       (entry2 (%php-hash-head h2))
			       (i 0))
		       (unless (sentinel? entry1)
			  ;;we already checked the sizes, so theoretically they're the same
			  [assert (entry2) (not (sentinel? entry2))]
			  (let ((key-difference (php-var-compare (get-key-php-type-friendly entry1)
								 (get-key-php-type-friendly entry2))))
			     (if (not (zero? key-difference))
				 (return key-difference)
				 (let ((value-difference (compare-two-values
							  (container-value (%entry-value entry1))
							  (container-value (%entry-value entry2)))))
				    (if (not (zero? value-difference))
					(return value-difference)
					(loop (%entry-next entry1) (%entry-next entry2) (+ i 1))))))))
		    ;;compare irrespective of order
		    (php-hash-for-each h1
		       (lambda (key h1-value)
			  (let ((h2-value (php-hash-lookup h2 key)))
			     (compare-two-values h1-value h2-value))))))
	     ;;the bind-exit evaluates to 0 unless somebody calls the
	     ;;exit-function with something else
	     0))))


(define +bigloo-max-vector-size+ 16777215)

(define (php-hash-expand! table)
   ;;XXX this routine should change the max-bucket-len instead of
   ;;attempting to increase the vector size beyond the max above
   (let* ((old-bucks (%php-hash-buckets table))
	  (old-bucks-len (vector-length old-bucks))
	  (new-bucks-len (*fx 2 old-bucks-len))
	  (new-expand-threshold ;; (* *default-load-factor* new-bucks-len)
                                (expand-threshold new-bucks-len))
	  (new-bucks (make-vector new-bucks-len '()))
	  (mask (-fx new-bucks-len 1)))

      (%php-hash-buckets-set! table new-bucks)
      (%php-hash-expand-threshold-set! table new-expand-threshold)
      (let loop ((i 0))
	 (when (<fx i old-bucks-len)
	     (begin
		(let loop ((cell (vector-ref-ur old-bucks i)))
		   (when (%entry? cell)
		      (let* ((key (%entry-key cell))
			     (h (bit-and (%entry-hashnumber cell) mask))
			     (old-chained-entry (%entry-chained-entry cell)))
			 (%entry-chained-entry-set! cell (vector-ref-ur new-bucks h))
			 (vector-set-ur! new-bucks
					 h
					 cell)
			 (loop old-chained-entry))))
		(loop (+fx i 1)))))))

(define-inline (php-hashnumber::int key)
   (cond
      ((onum? key) (onum-hashnumber key))
      ((string? key) (phpstring-hashnumber key))
      (else (error 'cosmic "unity" 'destroyed)) ))


(define-inline (%php-hash-equal? obj1 obj2)
   (if (string? obj1)
       (if (string? obj2)
	   (string=? obj1 obj2)
	   #f)
       (if (string? obj2)
	   #f
	   (=fx 0 (fast-onum-compare-long obj1 obj2)))))

(define (php-hash-next-free-element hash)
   ;; this function was implemented for php-compat
   (when (custom? hash) (set! hash (custom-read-entire hash)))
   (php-+ 1 (%php-hash-maximum-integer-key hash)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; custom hashes
(define (make-custom-hash::struct read-single::procedure write-single::procedure read-entire::procedure context)
   ;;read-single gets the key and the context
   ;;write-single gets the key, the value, and the context
   ;;read-entire gets the context 
   (let ((new-head *sentinel-value*));(make-a-hash-head)))
      (%php-hash 0
		 ;(make-vector *default-size* '())
                 (make-vector 1 '())
		 new-head
		 *initial-max-key*
;		 #e0
		 new-head
		 new-head
		 ;(* *default-load-factor* *default-size*)
                 ;(expand-threshold *default-size*)
                 0
		 (make-container 0)
		 (%hash-overload read-single write-single read-entire context))))

(define (custom? hash::struct)
   (%php-hash-custom hash))

(define (custom-read-entire::struct hash)
   ;;this should return a new php-hash
   (let ((o (%php-hash-custom hash)))
      ((%hash-overload-read-entire o)
       (%hash-overload-context o))))

(define (custom-read-single hash key ref?)
   (let* ((o (%php-hash-custom hash))
          (v ((%hash-overload-read-single o)
              (maybe-unbox key)
              (%hash-overload-context o))))
      (if ref?
          ;; XXX we don't maybe-box here because that wouldn't really
          ;; be a reference into the hash
          v
          (maybe-unbox v))))

(define (custom-write-single hash key value ref?)
   (let ((o (%php-hash-custom hash)))
      ((%hash-overload-write-single o)
       (maybe-unbox key)
       value
       (%hash-overload-context o))))

(define (php-hash-entry hash)
  (%php-hash-head hash))

(define (php-hash-entry-next entry)
  (%entry-next entry))

(define (php-hash-entry-prev entry)
  (%entry-prev entry))

(define (php-hash-entry-value entry)
  (%entry-value entry))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; php arrays with dense integer keys
;; ... nothing here yet.  implementing them in terms of custom-hashes was
;; not particularly faster.

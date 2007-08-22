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

(module php-array-lib
   (include "../phpoo-extension.sch")
   (import (php-string-lib "php-strings.scm"))
   (import (php-math-lib "php-math.scm"))
   (library profiler)
;   (import (php-variable-lib "php-variable.scm"))
   ; exports
   (export
    (init-php-array-lib)

    (array_change_key_case arr key-case)
    (array_chunk arr size preserve-keys)    
    ;(array_combine keys vals) ; PHP5
    (array_count_values arr)
    (array_diff_assoc arr1 . arr2-n)     
    (array_diff arr1 . arr2-n)
    (array_fill start num value)
    (array_filter arr callback)
    (array_flip arr)
    ; array_intersect_assoc
    (array_intersect arr1 . arr2-n)
    (array_key_exists key arr)
    (array_keys arr search-value)
    (array_map callback . arrays)
    (array_merge_recursive arr1 . arr2-n)
    (array_merge arr1 . arr2-n)
    ;* array_multisort
    (array_pad inarray padsize padval)
    (array_pop array)
    (array_push arr1 . var2-n)
    (array_rand array amt)
    (array_reduce array callback initial)
    (array_reverse array preserve) 
    (array_search needle haystack strict)
    (array_shift array) 
    (array_slice array offset length)
    (array_splice array offset length replacement)
    (array_sum array)
    (array_unique array)
    (array_unshift arr1 . var2-n)
    (array_values arr)
    (array_walk arr callback extra-arg)
    (arsort array predicate)
    (asort array predicate)
    ; compact
    (php-count array mode)
    (php-current array)
    (each array)
    (end array)
    (extract array extr-type prefix)
    (in_array needle haystack strict)
    (key array)
    (krsort arr sort-flags)
    (ksort arr sort-flags)
    (natcasesort array)
    (natsort array)
    (next array)
    (prev array)
    (range low hi step)
    (reset array)
    (rsort array predicate)
    (shuffle array)
    (php-sort array predicate)
    (uasort array callback)
    (uksort array callback)
    (usort array callback)

    ;; constants
    EXTR_OVERWRITE
    EXTR_SKIP
    EXTR_PREFIX_SAME
    EXTR_PREFIX_ALL
    EXTR_PREFIX_INVALID
    EXTR_IF_EXISTS
    EXTR_PREFIX_IF_EXISTS
    EXTR_REFS
    COUNT_NORMAL
    COUNT_RECURSIVE
    SORT_REGULAR
    SORT_NUMERIC
    SORT_STRING 
    CASE_LOWER
    CASE_UPPER ))


; init the module
(define (init-php-array-lib)
   1)


; CONSTANTS
(defconstant SORT_REGULAR 1)
(defconstant SORT_NUMERIC 2)
(defconstant SORT_STRING  3)

(defconstant COUNT_NORMAL    1)
(defconstant COUNT_RECURSIVE 2)

(defconstant EXTR_OVERWRITE         1)
(defconstant EXTR_SKIP              2)
(defconstant EXTR_PREFIX_SAME       3)
(defconstant EXTR_PREFIX_ALL        4)
(defconstant EXTR_PREFIX_INVALID    5)
(defconstant EXTR_IF_EXISTS         6)
(defconstant EXTR_PREFIX_IF_EXISTS  7)
(defconstant EXTR_REFS              8)

;; sorting support

(define (get-sort-pred type dir)
   (cond ((equalp type 1) (if (eqv? dir 'normal) php-< php->))
 	 ((equalp type 2) (if (eqv? dir 'normal) comp-numb<? comp-numb>?))
 	 ((equalp type 3) (if (eqv? dir 'normal) comp-string<? comp-string>?))
 	 (else (if (eqv? dir 'normal) php-< php->))))

(define (comp-string<? a b)
   (let ((rval (compare-as-strings a b)))
      (cond ((boolean? rval) rval)
	    (else (< rval 0)))))

(define (comp-string>? a b)
   (let ((rval (compare-as-strings a b)))
      (cond ((boolean? rval) rval)
	    (else (> rval 0)))))

(define (comp-numb<? a b)
   (< (compare-as-numbers a b) 0))

(define (comp-numb>? a b)
   (> (compare-as-numbers a b) 0))


;;;

(define (ensure-hash fun-name arr)
   (if (php-hash? arr)
       arr
       (begin
          (php-warning (format "~a: not an array: ~a" fun-name (mkstr arr)))
	  (convert-to-hash arr))))

;;;;Array Functions

; array --  Create an array
;this is a special form

; array_change_key_case -- Returns an array with all string keys lowercased or uppercased
(defconstant CASE_LOWER 0)
(defconstant CASE_UPPER 1)
(defbuiltin (array_change_key_case arr (key-case CASE_LOWER))
   (set! arr (ensure-hash 'array_change_key_case arr))
   (let ((newhash (make-php-hash)))
      (php-hash-for-each arr
	 (lambda (key val)
	    (php-hash-insert! newhash
			      (if (string? key)
				 (if (equalp key-case CASE_LOWER)
				     (string-downcase key)
				     (string-upcase key))
				 key)
			      val)))
      newhash))


; array_chunk -- Split an array into chunks
(defbuiltin (array_chunk arr size (preserve-keys 'unpassed))
   (set! arr (ensure-hash 'array_chunk arr))
   (when (eqv? preserve-keys 'unpassed) (set! preserve-keys #f))
   (set! size (mkfixnum (convert-to-number size)))
   (if (< size 1)
       (begin
	  (php-warning "size must be greater than 0")
	  NULL)
       (let ((newhash (make-php-hash)))
	  (php-hash-reset arr)
	  (let loop ((chunk (make-php-hash))
		     (i 0))
	     (when (php-hash-has-current? arr)
		(let fill-chunk ((j 0)
				 (current (php-hash-current arr)))
		   (when (and current (< j size))
		      (php-hash-insert! chunk (if preserve-keys
						  (car current)
						  j)
					(container-value (cdr current)))
		      (php-hash-advance arr)
		      (fill-chunk (+ j 1) (php-hash-current arr))))
		(php-hash-insert! newhash i chunk)
		(loop (make-php-hash) (+ i 1))))
	  newhash)))


; array_combine --  Creates an array by using one array for keys and another for its values


 
; array_count_values -- Counts all the values of an array
(defbuiltin (array_count_values arr)
   (set! arr (ensure-hash 'array_count_values arr))
   (let ((histogram (make-php-hash)))
      (php-hash-for-each arr
	 (lambda (key val)
	    (when (and (not (php-hash? val))
		       (not (php-object? val)))
	       (let ((frequency (php-hash-lookup histogram val)))
		  (if (php-number? frequency)
		      (php-hash-insert! histogram val (php-+ frequency 1))
		      (php-hash-insert! histogram val (int->onum 1)))))))
      histogram))



; array_diff -- returns an array containing all the values of array1
; that are not present in any of the other arguments. Note that keys
; are preserved.
(defbuiltin-v (array_diff arr1 arr2-n)
   ;check that we're working with php-hashes
   (set! arr1 (ensure-hash 'array_diff arr1))
   (set! arr2-n (map (lambda (a) (ensure-hash 'array_diff a)) arr2-n))
   ;put every value into a hashtable
   (let ((union-of-values (make-hashtable)))
      (for-each (lambda (h)
		   (php-hash-for-each h
		      (lambda (key val)
			 (hashtable-put! union-of-values (mkstr val) #t))))
		arr2-n)
      ;now compute and return the "difference"
      (let ((difference (make-php-hash)))
	 (php-hash-for-each arr1
	    (lambda (key val)
	       (unless (hashtable-get union-of-values (mkstr val))
		  (php-hash-insert! difference key val))))
	 difference)))
	    
; array_diff_assoc -- Computes the difference of arrays with additional index check			      
(defbuiltin-v (array_diff_assoc arr1 arr2-n)
   ;check that we're working with php-hashes
   (set! arr1 (ensure-hash 'array_diff_assoc arr1))
   (set! arr2-n (map (lambda (a) (ensure-hash 'array_diff_assoc a)) arr2-n))
   ;put every value into a hashtable
   (let ((union-of-values (make-hashtable)))
      (for-each (lambda (h)
		   (php-hash-for-each h
		      (lambda (key val)
			 (hashtable-put! union-of-values (mkstr key "::" val) #t))))
		arr2-n)
      ;now compute and return the "difference"
      (let ((difference (make-php-hash)))
	 (php-hash-for-each arr1
	    (lambda (key val)
	       (unless (hashtable-get union-of-values (mkstr key "::" val))
		  (php-hash-insert! difference key val))))
	 difference)))
   
; array_filter -- returns an array containing all the elements of
; input filtered according a callback function. 
(defbuiltin (array_filter arr callback)
   (set! arr (ensure-hash 'array_filter arr))
   (let ((filtered (make-php-hash)))
      (php-hash-for-each arr
	 (lambda (key val)
	    (when (convert-to-boolean (php-callback-call callback val))
	       (php-hash-insert! filtered key val))))
      filtered))



; array_flip -- Flip all the values of an array
(defbuiltin (array_flip arr)
   (set! arr (ensure-hash 'array_flip arr))
   (let ((flipped (make-php-hash)))
      (php-hash-for-each arr
	 (lambda (key val)
	    (php-hash-insert! flipped val key)))
      flipped))


; array_fill -- Fill an array with values
(define (array-fill start num value)
   (set! start (mkfixnum (convert-to-number start)))
   (set! num (mkfixnum (convert-to-number num)))
   (let ((filled (make-php-hash)))
      (let loop ((i start))
	 (when (< i (+ start num))
	    (php-hash-insert! filled i value)
	    (loop (+ i 1))))
      filled))

(defbuiltin (array_fill start num value)
   (array-fill start num value))
      
; array_intersect -- Computes the intersection of arrays
(defbuiltin-v (array_intersect arr1 arr2-n)
   ;check that we're working with php-hashes
   (set! arr1 (ensure-hash 'array_diff arr1))
   (set! arr2-n (map (lambda (a) (ensure-hash 'array_diff a)) arr2-n))
   ;put the frequency every value into a hashtable
   (let ((union-of-values (make-hashtable)))
      (for-each (lambda (h)
		   (php-hash-for-each h
		      (lambda (key val)
			 (let* ((valstr (mkstr val))
				(freq (or (hashtable-get union-of-values valstr) 0)))
			    (hashtable-put! union-of-values valstr (+ freq 1))))))
		arr2-n)
      ;now compute and return the "intersection"
      (let ((intersection (make-php-hash))
	    (threshold (length arr2-n)))
	 (php-hash-for-each arr1
	    (lambda (key val)
	       (when (eqv? threshold (hashtable-get union-of-values (mkstr val)))
		  (php-hash-insert! intersection key val))))
	 intersection)))
   

; array_key_exists -- Checks if the given key or index exists in the array
(defbuiltin (array_key_exists key arr)
   ; this function allows php objects, so we don't want to warn 
   (if (php-object? arr)
      (set! arr (convert-to-hash arr))
      (set! arr (ensure-hash 'array_key_exists arr)))
   (if (null? (php-hash-lookup arr key))
       #f
       #t))
   

; array_keys -- Return all the keys of an array. If the optional
; search_value is specified, then only the keys for that value are
; returned. Otherwise, all the keys from the input are returned.
(defbuiltin (array_keys arr (search-value 'unpassed))
   (set! arr (ensure-hash 'array_keys arr))
   (let ((keys (make-php-hash))
	 (i 0))
      (php-hash-for-each arr
	 (if (eqv? search-value 'unpassed)
	     (lambda (key val)
		(php-hash-insert! keys i key)
		(set! i (+ i 1)))
	     (lambda (key val)
		(when (string=? (mkstr search-value) (mkstr val))
		   (php-hash-insert! keys i key)
		   (set! i (+ i 1))))))
      keys))
			    


; array_map --  Applies the callback to the elements of the given arrays
(defbuiltin-v (array_map callback arrays)
   (letrec ((grok-hash (lambda (h)
			  (let ((c (php-hash-current h)))
			     (php-hash-advance h)
			     ;there either is no current entry (#f) or it's a key/value pair
			     (if c
				 (container-value (cdr c))
				 c)))))
      (if (null? arrays)
	  (php-warning "no array passed, not doing anything")
	  (begin
	     ;make sure they're all arrays
	     (set! arrays (map (lambda (a) (ensure-hash 'array_map a)) arrays))
	     ;reset all the arrays
	     (for-each php-hash-reset arrays)
	     ;check that they're all the same length
	     (let ((size (php-hash-size (car arrays))))
		(when (pair? (filter (lambda (a) (not (= a size)))
				     (map php-hash-size (cdr arrays))))
		   (php-warning "some of the arrays are of different sizes!"))
		;apply function to each set of arguments, collect the results in a list
		(let loop ((i 0)
			   (results '()))
		   (if (< i size)		   
		       (loop (+ i 1)
			     (cons (if (null? callback)
				       (list->php-hash (map grok-hash arrays))
				       (apply php-callback-call callback (map grok-hash arrays)))
				    results))
			(list->php-hash (reverse results)))))))))

      
      

;; array_merge -- Merge two or more arrays
;; return NULL if there is any non-array
(define (array-merge arr1 arr2-n)
  (if (and (php-hash? arr1)
           (every php-hash? arr2-n))
      (let ((merged (make-php-hash)))
        (for-each (lambda (arr)
                    (php-hash-for-each arr
                                       (lambda (key val)
                                         (if (php-number? key)
                                             (php-hash-insert! merged :next val)
                                             (php-hash-insert! merged key val)))))
                  (cons arr1 arr2-n))
        merged)
      NULL))

(defbuiltin-v (array_merge arr1 arr2-n)
   (array-merge arr1 arr2-n))

; array_merge_recursive -- Merge two or more arrays recursively
(defbuiltin-v (array_merge_recursive arr1 arr2-n)
   (set! arr1 (ensure-hash 'array_merge_recursive arr1))
   (set! arr2-n (map (lambda (a) (ensure-hash 'array_merge_recursive a)) arr2-n))
   (letrec ((recursive-array-merge
	     (lambda (merged to-merge seen)
		;for each array
		(for-each (lambda (arr)
			     ;for each entry in the array
			     (php-hash-for-each arr
				(lambda (key val)
				   ;if the key is an integer
				   (if (php-number? key)
				       ;insert the value using the next integer key
				       (php-hash-insert! merged :next val)
				       ;if key is not an integer, see what, if anything, is already
				       ;merged under this key
 				       (let ((submerged (php-hash-lookup merged key))
 					     (seen? (grasstable-get seen val)))
 					  (cond
 					     ;two arrays
  					     ((and (php-hash? submerged) (php-hash? val)  (not seen?))
   					      (grasstable-put! seen val #t)
					      (recursive-array-merge submerged (list val) seen))
 					     ;old value is array, new value is not
 					     ((and (php-hash? submerged) (not (php-hash? val)))
 					      (php-hash-insert! submerged :next val))
; 					     ;old value is not array, new value is
					     ((and (not (php-hash? submerged)) (php-hash? val) (not seen?))
					      (grasstable-put! seen val #t)
					      (let ((new-submerged (make-php-hash)))
						 (unless (php-null? submerged)
						    (php-hash-insert! new-submerged :next submerged))
						 (php-hash-insert! merged key new-submerged)
						 (recursive-array-merge new-submerged (list val) seen)))
; 					     ;neither value is array
					     ((and (not (php-hash? submerged)) (not (php-hash? val)))
					      (if (php-null? submerged)
						  (php-hash-insert! merged key val)
						  (let ((new-submerged (make-php-hash)))
						     (php-hash-insert! new-submerged :next submerged)
						     (php-hash-insert! new-submerged :next val)
						     (php-hash-insert! merged key new-submerged)) ))
					      (else (error 'array_merge_recursive "wtf?" 'foo))))))))
			  to-merge)
		;return the finished product
		merged)))
      ;kick things off with a bang
      (recursive-array-merge (make-php-hash) (cons arr1 arr2-n) (make-grasstable))))


   
; array_multisort -- Sort multiple or multi-dimensional arrays


; array_pad --  Pad array to the specified length with a value   
(defbuiltin (array_pad inarray padsize padval)
   (set! inarray (ensure-hash 'array_pad inarray))
   (let* ((isize (php-hash-size inarray))
	  (psize (- (abs (mkfixnum padsize)) isize)))
      (if (> psize 0)
	  (let ((pad-array (array-fill 0 psize padval)))
	     (if (php-< padsize 0)
		 ; pad left
		 (array-merge pad-array (list inarray))
		 ; pad right
		 (array-merge inarray (list pad-array))))
	  ; no padding
	  inarray)))
      

; array_pop -- Pop the element off the end of array
(defbuiltin (array_pop array)
   (set! array (ensure-hash 'array_pop array))
   (php-hash-pop array))

;    (php-hash-end array)
;    (let* ((end-val (php-hash-current array))
; 	  (k (car end-val))
; 	  (v (cdr end-val)))
;       (php-hash-remove! array k)
;       (php-hash-reset array)
;       (unless (string? k)
; 	 (php-hash-decrement-max-integer-key array))
;       v))

; array_push --  Push one or more elements onto the end of array
(defbuiltin-v (array_push arr1 var2-n)
   (set! arr1 (ensure-hash 'array_push arr1))
   (for-each (lambda (val)
		(php-hash-insert! arr1 :next val))
	     var2-n)
   arr1)

; array_rand --  Pick one or more random entries out of an array
(defbuiltin (array_rand array (amt *one*))
   (set! array (ensure-hash 'array_rand array))
   (set! amt (convert-to-number amt))
   (if (or (php-< amt *one*) (php-> amt (php-hash-size array)))
       (begin
          (php-warning "Second argument has to be between 1 and the number of elements in the array")
          NULL)
       (let ((keys '())
             (found *zero*)
             (size (php-hash-size array)))
          (bind-exit (done)
             (php-hash-for-each array
                (lambda (k v)
                   ;; quit early if we can
                   (when (php-= found amt)
                      (done #t))
                   ;; We always get enough keys: We decrement the size
                   ;; each time around.  As soon as it equals amt, (/
                   ;; amt size) is at least one, so we'll take every
                   ;; key.
                   (when (php-< (php-/ (php-funcall 'rand) (php-+ PHP_RAND_MAX 1.0))
                                (php-/ amt size))
                      (pushf k keys)
                      (set! found (php-+ found *one*)))
                   (set! size (php-- size *one*)))))
          ;; done
          (if (php-= amt *one*)
              (car keys)
              (let ((result (make-container (list->php-hash keys))))
                 (php-funcall 'shuffle result)
                 (container-value result))))))

; array_reverse --  Return an array with elements in reverse order
(defbuiltin (array_reverse array (preserve 'unpassed))
   (set! array (ensure-hash 'array_reverse array))
   (let ((vals (make-php-hash)))
      (php-hash-reverse-for-each array
				 (lambda (key val)
				    (if (or (eqv? preserve #t)
					    (not (php-number? key)))
					(php-hash-insert! vals key val)
					(php-hash-insert! vals :next val))))
      vals))

; array_reduce --  Iteratively reduce the array to a single value using a callback function
(defbuiltin (array_reduce array callback (initial *zero*))
   (set! array (ensure-hash 'array_reduce array))
   (php-hash-reset array)
   (let loop ((val (convert-to-number initial)))
      (if (php-hash-has-current? array)
	  (let ((next-val (php-callback-call callback val (cdr (php-hash-current array)))))
	     (php-hash-advance array)
	     (loop next-val))
	  val)))
   
; array_shift --  Shift an element off the beginning of array
(defbuiltin (array_shift (ref . array))
   (if (php-hash? (container-value array))
       (let ((first 'unset)
	     (new-array (make-php-hash)))
	  (php-hash-reset (container-value array))
	  (php-hash-for-each (container-value array)
			     (lambda (key val)
				; nab the first
				(if (eqv? first 'unset)
				    (set! first val)
				    ; copy
				    (if (php-number? key)
					(php-hash-insert! new-array :next val)
					(php-hash-insert! new-array key val)))))
	  (container-value-set! array new-array)
	  first)
       #f))

; array_slice -- Extract a slice of the array
(defbuiltin (array_slice array offset (length 'unset))
   (let* ((safe-array (ensure-hash 'array_slice array))
	  (a-size (php-hash-size safe-array))
	  (new-array (make-php-hash))
	  (cur-len 0)
	  (max-len a-size)
	  (real-offset (convert-to-number offset)))
      (if (php-number? real-offset)
	  (begin
	     (if (php-< real-offset 0)
		 (set! real-offset (php-+ a-size real-offset)))
	     (if (php-< real-offset (php-- a-size 1))
		 (begin
		    (cond ((eqv? length 'unset) (set! max-len (php-- a-size real-offset)))
			  ((and (php-number? length)
				(php-< length 0))   (set! max-len (php-+ (php-- a-size real-offset) length)))
			  ((and (php-number? length)
				(php->= length 0))  (set! max-len length)))
                    (let ((i 0))
                       (php-hash-for-each safe-array
                          (lambda (k v)
                             (when (and (php->= i real-offset)
                                        (php-< cur-len max-len))
                                (set! cur-len (+ cur-len 1))
                                (php-hash-insert! new-array :next v))
                             (set! i (+ i 1))))))
		 #f)
	     new-array)
	  #f)))
						       

; array_splice --  Remove a portion of the array and replace it with something else
(defbuiltin (array_splice (ref . array) offset (length 'unset) (replacement 'unset))
   (container-value-set! array (ensure-hash 'array_splice (container-value array))) 
   (let ((a-size (php-hash-size (container-value array)))
	 (new-array (make-php-hash)) ; altered input array
	 (ret-array (make-php-hash)) ; return value of extracted items
	 (cur-len 0)
	 (max-len 0)
	 (need-replace #t)
	 (real-offset (convert-to-number offset)))
      (if (php-number? real-offset)
	  (begin
	     (cond ((eqv? replacement 'unset) (set! replacement (make-php-hash)))
		   ((not (php-hash? replacement)) (set! replacement (convert-to-hash replacement))))
	     (if (php-< real-offset 0)
		 (set! real-offset (php-+ a-size real-offset)))
	     (if (php-< real-offset a-size)
		 (begin
		    (cond ((eqv? length 'unset) (set! max-len (php-- a-size real-offset)))
			  ((and (php-number? length)
				(php-< length 0))   (set! max-len (php-+ (php-- a-size real-offset) length)))
			  ((and (php-number? length)
				(php->= length 0))  (set! max-len length)))
                    (let ((i 0))
                       (php-hash-for-each (container-value array)
                          (lambda (k v)
                             (begin0
                              (cond
                                 ; before splice area
                                 ((php-< i real-offset) (php-hash-insert! new-array (if (php-number? k) :next k) v))
                                 ; after splice area
                                 ((and (php-> i real-offset)
                                       (php->= cur-len max-len)) (php-hash-insert! new-array (if (php-number? k) :next k) v))
                                 ; in splice area, no length
                                 ((and (php-= i real-offset)
                                       (php-= max-len 0)) (begin
                                       (set! new-array (array-merge
                                                        new-array
                                                        (list replacement)))
                                       (set! cur-len (+ cur-len 1))
                                       (php-hash-insert! new-array (if (php-number? k) :next k) v)))
                                 ; in splice area, with length
                                 ((and (php->= i real-offset)
                                       (php-< cur-len max-len)) (begin
                                       (when need-replace
                                          (set! new-array (array-merge
                                                           new-array
                                                           (list replacement)))
                                          (set! need-replace #f))
                                       (set! cur-len (+ cur-len 1))
                                       (php-hash-insert! ret-array (if (php-number? k) :next k) v))))
                              (set! i (+ i 1))))))
		    ; set the input array to the newly splice version
		    (container-value-set! array new-array)
		    ret-array)
		 (make-php-hash)))
	  #f)))

; array_sum --  Calculate the sum of values in an array.
(defbuiltin (array_sum array)
   (set! array (ensure-hash 'array_sum array))
   (let ((sum *zero*))
      (php-hash-for-each array
			 (lambda (k v)
			    (set! sum (php-+ sum v))))
      sum))


; array_unique -- Removes duplicate values from an array
(defbuiltin (array_unique array)
   (set! array (ensure-hash 'array_unique array))
   (let ((sort-copy (copy-php-data array))
	 (original-order (make-php-hash))
	 (last-seen 'unset))
      (asort sort-copy SORT_STRING); side effects
      (php-hash-for-each array
	 (let ((i 0))
	    (lambda (k v)
	       (php-hash-insert! original-order k i)
	       (set! i (+ i 1)))))
      (php-hash-for-each sort-copy
			 (lambda (k v)
			    ;(print "checking k " k " v " v)
			    (if (eqv? last-seen 'unset)
				(set! last-seen (cons k v))
				(if (equalp (cdr last-seen) v)
				    (if (> (php-hash-lookup original-order (car last-seen))
					   (php-hash-lookup original-order k))
					(begin
					   ;(print "last seen comes later than current, removing key of " (car last-seen))
					   (php-hash-remove! array (car last-seen))
					   (set! last-seen (cons k v)))
					(begin
					   ;(print "current comes later than last seen, removing key of " k)
					   (php-hash-remove! array k)))
; 				    (let ((lastseen-idx (php-hash-lookup-internal-index array (car last-seen)))
; 					  (current-idx (php-hash-lookup-internal-index array k)))
; 				       ;(print "indexes are " lastseen-idx " / " current-idx)
; 				       (if (> lastseen-idx current-idx)
; 					   (begin
; 					      ;(print "last seen comes later than current, removing key of " (car last-seen))
; 					      (php-hash-remove! array (car last-seen))
; 					      (set! last-seen (cons k v)))
; 					   (begin
; 					      ;(print "current comes later than last seen, removing key of " k)
; 					      (php-hash-remove! array k))))
				    (set! last-seen (cons k v))))))
      array))

; array_unshift --  Prepend one or more elements to the beginning of array
(defbuiltin-v (array_unshift (ref . arr1) var2-n)
   (if (php-hash? (container-value arr1))
       (container-value-set! arr1 (array-merge (list->php-hash var2-n) (list (container-value arr1))))
       #f))

; array_values -- Return all the values of an array
(defbuiltin (array_values arr)
   (set! arr (ensure-hash 'array_values arr))
   (let ((vals (make-php-hash)))
      (php-hash-for-each arr
			 (lambda (key val)
			    (php-hash-insert! vals :next val)))
      vals))


; array_walk --  Apply a user function to every member of an array
(defbuiltin (array_walk arr callback (extra-arg 'unpassed))
   (set! arr (ensure-hash 'array_walk arr))
   (php-hash-for-each-ref arr
      (lambda (key val)
	 (if (eqv? extra-arg 'unpassed)
	     (php-callback-call callback val key)
	     (php-callback-call callback val key extra-arg)))))
	     
;   42) ; no idea what to return here, but the docs say int.
;amazingly enough, this'll make the test script return 42

; arsort --  Sort an array in reverse order and maintain index association
(defbuiltin (arsort array (predicate SORT_REGULAR))
   (php-hash-sort-by-values-save-keys (ensure-hash 'arsort array) (get-sort-pred predicate 'reverse)))

; asort -- Sort an array and maintain index association
(defbuiltin (asort array (predicate SORT_REGULAR))
   (php-hash-sort-by-values-save-keys (ensure-hash 'asort array) (get-sort-pred predicate 'normal)))   

; compact --  Create array containing variables and their values

; count -- Count elements in a variable
(defalias sizeof php-count)
(defalias count php-count)
(defbuiltin (php-count array (mode COUNT_NORMAL))
   (letrec ((get-total 
	  (lambda (a)
	     (let ((total 0))
		(php-hash-for-each a
				   (lambda (k v)
				      (if (php-hash? v)
					  (set! total (+ total (get-total v) 1))
					  (set! total (+ total 1)))))
		total))))       
      (cond ((php-hash? array)
	     (if (equalp mode COUNT_RECURSIVE)
		 ; recursive
		 (convert-to-integer (get-total array))
		 ; normal
		 (convert-to-integer (php-hash-size array))))
	    ((null? array)
	     *zero*)
	    (else
	     *one*))))

; current -- Return the current element in an array
(defalias pos php-current)
(defalias current php-current)
(defbuiltin (php-current array)
   (set! array (ensure-hash 'current array))
   (let ((cur (php-hash-current array)))
      (if cur
	  (container-value (cdr cur))
	  #f)))

; each --  Return the current key and value pair from an array and advance the array cursor
(defbuiltin (each (ref . array))
   "Return the current key and value pair from an array and advance
   the array cursor"
   (set! array (ensure-hash 'each (container-value array)))
   (let ((new-hash (make-php-hash))
	 (current (php-hash-current array)))
      (if current
	  (begin
	     (php-hash-insert! new-hash 1 (copy-php-data (container-value (cdr current))))
	     (php-hash-insert! new-hash "value" (copy-php-data (container-value (cdr current))))
	     ;remember that the key wasn't in a container, but values
	     ;must always be in a container, so when the key
	     ;becomes a value, we must containerize it!
	     (php-hash-insert! new-hash 0 (copy-php-data (car current)))
	     (php-hash-insert! new-hash "key" (copy-php-data (car current)))
	     (php-hash-advance array)
	     new-hash)
	  #f)))

; end --  Set the internal pointer of an array to its last element
(defbuiltin (end array)
   (set! array (ensure-hash 'end array))
   ; set internal pointer to the end
   (php-hash-end array)
   ; return last element
   (php-current array))

; extract --  Import variables into the current symbol table from an array
(defbuiltin (extract array (extr-type EXTR_OVERWRITE) (prefix ""))
   (let* ((sprefix (mkstr prefix))
	  (cur-vars (env-php-hash-view *current-variable-environment*))
	  (do-env (lambda (prefix-style overwrite-style as-ref?)
		     (let ((cur-env *current-variable-environment*)
			   (overwrite? #t)
			   (source (maybe-unbox array)))
			(when (php-hash? source)
			   (php-hash-for-each
			    source
			    (lambda (key v)
			       (let* ((k (mkstr key))
				      (var-exists? (if (null? (php-hash-lookup cur-vars k)) #f #t))
				      (valid-id? (pregexp-match "^[a-zA-Z_]\\w*" k))
				      (sname (cond ((eqv? prefix-style 'all)
						    (string-append sprefix "_" k))
						   ;
						   ((eqv? prefix-style 'same)
						    (if var-exists?
							(string-append sprefix "_" k)
							k))
						   ;
						   ((eqv? prefix-style 'invalid)
						    (if valid-id?
							k
							(string-append sprefix "_" k)))
						   ;
						   (else k))))
				  ;(print "key is " k " val is " v " new key is " sname " valid-id? " valid-id?)
				  ;(print "currently exists? " (php-hash-lookup cur-vars k))
				  (cond ((eqv? overwrite-style 'skip) (set! overwrite? #f))
					((eqv? overwrite-style 'ifexists)
					 (if (not var-exists?)
					     (begin
						(set! var-exists? #t)
						(set! overwrite? #f)))))
				  ; ref?
				  (if as-ref?
				      (set! v (php-hash-lookup-ref source #f key)))
				  ; go
				  (when (or overwrite?
					    (not var-exists?))
				     (env-extend cur-env sname v))))))))))
      ;
      (if (or (= (string-length sprefix) 0)
	      (and (> (string-length sprefix) 0)
		   (pregexp-match "^[a-zA-Z_]\\w*" sprefix)))
	  (if (php-hash? array)
	     (cond
		((php-= extr-type EXTR_PREFIX_ALL) (do-env 'all 'overwrite #f))
		((php-= extr-type EXTR_SKIP) (do-env 'none 'skip #f))
		((php-= extr-type EXTR_PREFIX_SAME) (do-env 'same 'overwrite #f))
		((php-= extr-type EXTR_PREFIX_INVALID) (do-env 'invalid 'overwrite #f))
		((php-= extr-type EXTR_IF_EXISTS) (do-env 'none 'ifexists #f))
		((php-= extr-type EXTR_PREFIX_IF_EXISTS) (do-env 'all 'ifexists #f))
		((php-= extr-type EXTR_REFS) (do-env 'none 'overwrite #t))
		(else
		 ; EXTR_OVERWRITE
		 (do-env 'none 'overwrite #f)))
	     (php-warning "not an array"))
	  (php-warning "invalid prefix"))))

; in_array -- Return TRUE if a value exists in an array
(defbuiltin (in_array needle haystack (strict 'unpassed))
   (set! haystack (ensure-hash 'in_array haystack))
   (php-hash-in-array? haystack needle (if (eqv? strict #t) #t #f)))

; array_search --  Searches the array for a given value and returns the corresponding key if successful
(defbuiltin (array_search needle haystack (strict 'unset))
   (let ((safe-haystack (ensure-hash 'array_search haystack))
	 (pred (if (eqv? strict #t) identicalp equalp))
	 (found-key #f))
      (php-hash-for-each haystack (lambda (k v)
				     (unless found-key
					(if (pred needle v)
					    (set! found-key k)))))
      found-key))

; key -- Fetch a key from an associative array
(defbuiltin (key array)
   (let ((cur (php-hash-current (ensure-hash 'key array))))
      (if cur
	  (car cur)
	  NULL)))

; krsort -- Sort an array by key in reverse order
(defbuiltin (krsort arr (sort-flags SORT_REGULAR))
   (php-hash-sort-by-keys (ensure-hash 'krsort arr) (get-sort-pred sort-flags 'reverse)))

; ksort -- Sort an array by key
(defbuiltin (ksort arr (sort-flags SORT_REGULAR))
   (php-hash-sort-by-keys (ensure-hash 'ksort arr) (get-sort-pred sort-flags 'normal)))


; natsort --  Sort an array using a "natural order" algorithm
(defbuiltin (natsort arr)
   (let ((pred (lambda (a b)
		  (< (strnatcmp (mkstr a) (mkstr b)) 0))))		      
      (php-hash-sort-by-values-save-keys (ensure-hash 'natsort arr) pred)))

; natcasesort --  Sort an array using a case insensitive "natural order" algorithm
(defbuiltin (natcasesort arr)
   (let ((pred (lambda (a b)
		  (< (strnatcasecmp (mkstr a) (mkstr b)) 0))))		      
      (php-hash-sort-by-values-save-keys (ensure-hash 'natcasesort arr) pred)))

; next --  Advance the internal array pointer of an array
(defbuiltin (next array)
   (set! array (ensure-hash :next array))
   (php-hash-advance array))

; pos -- Get the current element from an array
; ^-- alias for current()

; prev -- Rewind the internal array pointer
(defbuiltin (prev array)
   (set! array (ensure-hash 'prev array))
   ; rewind pointer
   (php-hash-prev array)
   ; return entry
   (php-current array))

; range --  Create an array containing a range of elements
(defbuiltin (range low hi (step *one*))
   (bind-exit (return)
      (let ((array (make-php-hash))
	    (inc-action php-+)
	    (loop-check php-<))
	 ; per > 4.3.2 convert numeric strings to ints 
	 (if (numeric-string? low)
	     (set! low (convert-to-number low)))
	 (if (numeric-string? hi)
	     (set! hi (convert-to-number hi)))
	 ; cleanup
	 (unless (php-number? low)
	   (cond ((or (php-hash? low)
		      (php-object? low)) (set! low *one*))
		 (else (set! low (mkstr low))
		       (if (= (string-length low) 0)
			   (set! low *zero*)
			   (set! low (string-ref low 0))))))
	 (unless (php-number? hi)
	    (cond ((or (php-hash? hi)
		       (php-object? hi)) (set! hi *one*))
		  (else (set! hi (mkstr hi))
			(if (= (string-length hi) 0)
			    (set! hi *zero*)
			    (set! hi (string-ref hi 0))))))
	 ; make sure step is a number
	 (set! step (convert-to-number step))
	 ;(print "low " (mkstr low) " hi " (mkstr hi) " step " (mkstr step))
	 ;(print "low " low " hi " hi " step " step)
	 ; get direction right
	 (cond ((and (char? low) (char? hi))
		   (if (char>? low hi)
		       (begin
			  (set! inc-action php--)   
			  (set! loop-check php->))))
	       ((and (php-number? low) (php-number? hi))
		(if (php-> low hi)
		       (begin
			  (set! inc-action php--)   
			  (set! loop-check php->))))
	       (else (return array)))
	 (let loop ((cur low))
	    ;(print "cur is " (mkstr cur))
	    (php-hash-insert! array :next (if (char? cur)
					      (string cur)
					      cur))
	    (if (char? cur)
		(when (loop-check (char->integer cur) (char->integer hi)) 
		   (loop (integer->char (mkfixnum (inc-action (char->integer cur) step)))))
		(when (loop-check cur hi) 
		   (loop (inc-action cur step)))))
	 array)))

; reset --  Set the internal pointer of an array to its first element
(defbuiltin (reset array)
   "Set the internal pointer of an array to its first element"
   (php-hash-reset (ensure-hash 'reset array)))


; rsort -- Sort an array in reverse order
(defbuiltin (rsort array (predicate SORT_REGULAR))
   "Sort an array"
   (php-hash-sort-by-values-trash-keys (ensure-hash 'rsort array) (get-sort-pred predicate 'reverse)))

; shuffle -- Shuffle an array
(defbuiltin (shuffle (ref . array))
   (container-value-set! array (ensure-hash 'shuffle (container-value array)))
   (let ((temp (make-php-hash)))
      (php-hash-for-each (container-value array)
         (lambda (k v)
            (php-hash-insert! temp (php-funcall 'rand) v)))
      (set! temp (php-hash-sort-by-keys temp php-<))
      (let ((retval (make-php-hash)))
         (php-hash-for-each temp
            (lambda (k v)
               (php-hash-insert! retval :next v)))
         (container-value-set! array retval))))
   
; sizeof -- Get the number of elements in variable
;just an alias of count, above

; sort -- Sort an array
(defalias sort php-sort)
(defbuiltin (php-sort array (predicate SORT_REGULAR))
   "Sort an array"
   (php-hash-sort-by-values-trash-keys (ensure-hash 'sort array) (get-sort-pred predicate 'normal)))


; uasort --  Sort an array with a user-defined comparison function and maintain index association
(defbuiltin (uasort array callback)
   (let ((pred (lambda (a b)
		  (php-<= (php-callback-call callback a b) 0))))		      
      (php-hash-sort-by-values-save-keys (ensure-hash 'uasort array) pred)))

; uksort --  Sort an array by keys using a user-defined comparison function
(defbuiltin (uksort array callback)
   (let ((pred (lambda (a b)
		  (php-<= (php-callback-call callback a b) 0))))		      
      (php-hash-sort-by-keys (ensure-hash 'uksort array) pred)))

; usort --  Sort an array by values using a user-defined comparison function
(defbuiltin (usort array callback)
   (let ((pred (lambda (a b)
		  (php-<= (php-callback-call callback a b) 0))))		      
      (php-hash-sort-by-values-trash-keys (ensure-hash 'usort array) pred)))

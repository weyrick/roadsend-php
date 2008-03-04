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
(module php-pack
   (include "../phpoo-extension.sch")
   (library profiler)
   (export
    (do-pack format args)
    (do-unpack format data)))

; this comes from bigloo_config.h. thanks manuel.
(define *little-endian?* (not (pragma::bool "BGL_BIG_ENDIAN")))

(define (format-char->bytes-used char)
   "return the number of bytes consumed by a given format directive"
   (case char
      ((#\h #\H) .5)
      ((#\a #\A #\c #\C #\x) 1)
      ((#\s #\S #\n #\v) 2)
      ((#\i #\I) (pragma::int "sizeof(int)"))
      ((#\l #\L #\N #\V) 4)
      ((#\f) (pragma::int "sizeof(float)"))
      ((#\d) (pragma::int "sizeof(double)"))
      ((#\X) -1)
      (else 0)))

(define-inline (get-byte-0 n::elong)
   (pragma::long "$1 & 0xFF" n))
(define-inline (get-byte-1 n::elong)
   (pragma::long "($1 >> 8) & 0xFF" n))
(define-inline (get-byte-2 n::elong)
   (pragma::long "($1 >> 16) & 0xFF" n))
(define-inline (get-byte-3 n::elong)
   (pragma::long "($1 >> 24) & 0xFF" n))
(define-inline (get-byte-n n::elong bytenum::bint)
   (pragma::long "($1 >> $2) & 0xFF" n (*fx 8 bytenum)))

(define (pack-unsigned-int-machine n::elong)
   (let* ((intsize (format-char->bytes-used #\i))
	  (start-byte (if *little-endian?* 0 intsize))
	  (stop-byte (if *little-endian?* intsize 0))
	  (move (if *little-endian?* +fx -fx))
	  (check (if *little-endian?* <fx >fx))
	  (packed-string (make-string intsize)))
      (let loop ((byte-i start-byte)
		 (str-i 0))
	 (when (check byte-i stop-byte)
	    (string-set! packed-string str-i (integer->char (get-byte-n n byte-i)))
	    (loop (move byte-i 1) (+fx str-i 1))))
      packed-string))

(define (pack-unsigned-long-machine n::elong)
   (if *little-endian?*
       (pack-unsigned-long-little-endian n)
       (pack-unsigned-long-big-endian n)))

(define (pack-unsigned-short-machine n::elong)
   (if *little-endian?*
       (pack-unsigned-short-little-endian n)
       (pack-unsigned-short-big-endian n)))

(define (pack-unsigned-long-big-endian n::elong)
   "convert a number to a string packed as an unsigned long in big endian byte order"
   (string (integer->char (get-byte-3 n))
	   (integer->char (get-byte-2 n))
	   (integer->char (get-byte-1 n))
	   (integer->char (get-byte-0 n))))

(define (pack-unsigned-long-little-endian n::elong)
   "convert a number to a string packed as an unsigned long in little endian byte order"
   (string (integer->char (get-byte-0 n))
	   (integer->char (get-byte-1 n))
	   (integer->char (get-byte-2 n))
	   (integer->char (get-byte-3 n))))

(define (pack-unsigned-short-little-endian n::elong)
   "convert a number to a string packed as an unsigned short in little endian byte order"
   (string (integer->char (get-byte-0 n))
	   (integer->char (get-byte-1 n))))

(define (pack-unsigned-short-big-endian n::elong)
   "convert a number to a string packed as an unsigned short in big endian byte order"
   (string (integer->char (get-byte-1 n))
	   (integer->char (get-byte-0 n))))

(define (pack-unsigned-char n::elong)
   "convert a number to a string packed as an unsigned char"
   (integer->char (get-byte-0 n)))

(define-inline (mkelong::elong thing)
   (if (elong? thing)
       thing
       (onum->elong (convert-to-number thing))))

;;; XXXXXX Beware! Do not touch with a ten-foot pole. Do not sit in a box with this fox.
;;; I will fix this later. --Nate 2004-07-05
;; Pack data into binary string.
(define (do-pack format args)
   (let* ((num-of-args (length args))
 	  (args-consumed 0)
 	  (bytes-used 0)
 	  (current-format-char #f)
 	  (format-error? #f)
  	  (args-and-space-counting-grammar
	   (regular-grammar ()
	      ((in #\N #\n #\V #\v #\C #\c #\L #\l #\I #\i #\S #\s)
	       (set! args-consumed (+ args-consumed 1))
	       (set! bytes-used (+ bytes-used (format-char->bytes-used (the-character))))
	       (set! current-format-char (the-character))
	       #t)
	      (#\*
	       (let ((remaining-args (max 0 (- num-of-args args-consumed))))
		  (cond ((not current-format-char)
			 (php-warning "invalid format string: '" format
				      "' -- '*' not preceeded by a valid format character.")
			 (set! format-error? #t)
			 #f)
			(else
			 (set! args-consumed (+ args-consumed remaining-args))
			 (set! bytes-used (+ bytes-used
					     (* (format-char->bytes-used current-format-char)
						remaining-args)))
			 #t))))
	      ((or all #\Newline)
	       (php-warning "illegal format character: '" (the-character) "'")
	       (set! format-error? #t)
	       #f)
	      (else #f))))
      ;; determine number of arguments and bytes of space consumed by format string
      (with-input-from-string format
 	 (lambda ()
 	    (let loop ()
 	       (when (and (not format-error?)
 			  (read/rp args-and-space-counting-grammar (current-input-port)))
 		  (loop)))))
;       (debug-trace 0 "format: " format)
;       (debug-trace 0 "num-of-args: " num-of-args)
;       (debug-trace 0 "args-consumed: " args-consumed)
;       (debug-trace 0 "bytes-used: " bytes-used)
;       (debug-trace 0 "format-error?: " (if format-error? "yes" "no"))
      ;; check for some error conditions and then pack baby pack!!
      (cond (format-error? FALSE)
 	    ((< num-of-args args-consumed)
 	     (php-warning "too few arguments. Format string '" format "' requires " args-consumed
 			  ", but only " num-of-args " were provided.")
 	     FALSE)
 	    ((> num-of-args args-consumed)
 	     (php-warning "too many arguments. Format string '" format "' requires " args-consumed
 			  ", but " num-of-args " were provided.")
 	     FALSE)
 	    (else
	     (with-output-to-string
		(lambda ()
		   (let* ((current-format-char #f)
			  (offset 0)
			  (next-arg (let ((local-args-list args))
				       (lambda ()
					  ;(d "remaining args: " (length local-args-list))
					  (if (null? local-args-list)
					      #f
					      (let ((next (car local-args-list)))
						 ;(d "next arg: " next)
						 (set! local-args-list (cdr local-args-list))
						 next)))))
			  (pack-grammar (regular-grammar ()
					   ((in #\C #\c #\N #\n #\V #\v #\L #\l #\I #\i #\S #\s)
					    ;; set current format character
					    (set! current-format-char (the-character))
					    ;; pack the next argument according to the format character
					    (case current-format-char
					       ((#\C #\c) (display (pack-unsigned-char (mkelong (next-arg)))))
					       ((#\L #\l) (display (pack-unsigned-long-machine (mkelong (next-arg)))))
					       ((#\I #\i) (display (pack-unsigned-int-machine (mkelong (next-arg)))))
					       ((#\S #\s) (display (pack-unsigned-short-machine (mkelong (next-arg)))))					       
					       ((#\N) (display (pack-unsigned-long-big-endian (mkelong (next-arg)))))
					       ((#\n) (display (pack-unsigned-short-big-endian (mkelong (next-arg)))))
					       ((#\V) (display (pack-unsigned-long-little-endian (mkelong (next-arg)))))
					       ((#\v) (display (pack-unsigned-short-little-endian (mkelong (next-arg))))))
					    ;; increment the offset
					    (set! offset (+ offset (format-char->bytes-used current-format-char))))
					   (#\*
					    (let loop ((next (next-arg)))
					       (when next
						  ;; pack the next argument according to the format character
						  ;(d "mkfixnum(" next ") ==> " (mkfixnum next))
						  ;; duplicate some code. very important.
						  (case current-format-char
						     ((#\C #\c) (display (pack-unsigned-char (mkelong next))))
						     ((#\L #\l) (display (pack-unsigned-long-machine (mkelong next))))
						     ((#\I #\i) (display (pack-unsigned-int-machine (mkelong next))))
						     ((#\S #\s) (display (pack-unsigned-short-machine (mkelong next))))
						     ((#\N) (display (pack-unsigned-long-big-endian (mkelong next))))
						     ((#\n) (display (pack-unsigned-short-big-endian (mkelong next))))
						     ((#\V) (display (pack-unsigned-long-little-endian (mkelong next))))
						     ((#\v) (display (pack-unsigned-short-little-endian (mkelong next)))))
						  ;; increment the offset
						  (set! offset (+ offset (format-char->bytes-used current-format-char)))
						  ;(d "*loop offset: " offset)
						  (loop (next-arg)))))
					   (else #f))))
		      (with-input-from-string format
			 (lambda ()
			    (let loop ()
			       ;(d "offset: " offset)
			       (when (read/rp pack-grammar (current-input-port))
				  (loop))))))))))))


; ;Syntax highlighting of a file
; (defbuiltin (show_source)
;    )

(define (directive-char directive-triplet)
   (list-ref directive-triplet 0))

(define (directive-repeater directive-triplet)
   (list-ref directive-triplet 1))

(define (directive-label directive-triplet)
   (list-ref directive-triplet 2))

(define (split-directive-string dstring)
   (let ((parts (pregexp-match "^([NVLlCcv])([0-9]+|\*)?(.+)?$" dstring)))
      (if (not parts)
	  #f ;; invalid directive string
	  (let* ((parts-vector (list->vector (cdr parts)))
		 (directive-char (string-ref (vector-ref parts-vector 0) 0))
		 (repeater-arg   (vector-ref parts-vector 1))
		 (label          (vector-ref parts-vector 2)))
	     (list directive-char
		   (if repeater-arg
		       (or (string->number repeater-arg)
			   #\*)
		       1)
		   label)))))
			      
(define (split-unpack-format-string format)
   (let loop ((triplets '()) (directive-strings (pregexp-split "/" format)))
      (if (null? directive-strings)
	  (reverse triplets)
	  (loop (cons (split-directive-string (car directive-strings)) triplets) (cdr directive-strings)))))

(define (unpack-unsigned-long-machine binstr)
   (if *little-endian?*
       (unpack-unsigned-long-little-endian binstr)
       (unpack-unsigned-long-big-endian binstr)))

(define (unpack-signed-long-machine binstr)
   (if *little-endian?*
       (unpack-signed-long-little-endian binstr)
       (unpack-signed-long-big-endian binstr)))

(define (unpack-signed-long-big-endian binstr)
   (elong->onum (pragma::elong "($1 << 24) | ($2 << 16) | ($3 << 8) | $4"
			       (string-ref binstr 0)
			       (string-ref binstr 1)
			       (string-ref binstr 2)
			       (string-ref binstr 3)
			       )))

(define (unpack-signed-long-little-endian binstr)
   (elong->onum (pragma::elong "($1 << 24) | ($2 << 16) | ($3 << 8) | $4"
			       (string-ref binstr 3)
			       (string-ref binstr 2)
			       (string-ref binstr 1)
			       (string-ref binstr 0)
			       )))

(define (unpack-unsigned-long-big-endian binstr)
   (elong->onum (pragma::elong "($1 << 24) + ($2 << 16) + ($3 << 8) + $4"
			       (string-ref binstr 0)
			       (string-ref binstr 1)
			       (string-ref binstr 2)
			       (string-ref binstr 3)
			       )))

(define (unpack-unsigned-long-little-endian binstr)
   (elong->onum (pragma::elong "($1 << 24) + ($2 << 16) + ($3 << 8) + $4"
			       (string-ref binstr 3)
			       (string-ref binstr 2)
			       (string-ref binstr 1)
			       (string-ref binstr 0)
			       )))

(define (unpack-unsigned-short-little-endian binstr)
   (int->onum (pragma::int "($1 << 8) + $2"
			   (string-ref binstr 1)
			   (string-ref binstr 0))))

(define (unpack-unsigned-short-big-endian binstr)
   (int->onum (pragma::int "($1 << 8) + $2"
			   (string-ref binstr 0)
			   (string-ref binstr 1))))   
   
(define (unpack-unsigned-char binstr)
   (int->onum (char->integer (string-ref binstr 0))))

(define (unpack-signed-char binstr)
   (int->onum (pragma::int "(signed char)$1" (string-ref binstr 0))))

;; Unpack data from binary string
(define (do-unpack format data)
   (set! data (mkstr data))
   (set! format (mkstr format))
   (let ((directive-triplets (split-unpack-format-string format))
	 (h (make-php-hash))
	 (data-len (string-length data)))
      (if (or (not (list? directive-triplets))
	      (member #f directive-triplets))
	  FALSE ;; XXX error reporting
	  (let loop ((triplets directive-triplets) (binstr data))
	     (if (null? triplets)
		 h
		 (let* ((next (car triplets))
			(char (directive-char next))
			(bytes-used (format-char->bytes-used char))
			(repeater (let ((r (directive-repeater next)))
				     (cond ((number? r) r)
					   ((equal? r #\*)
					    (inexact->exact (floor (/ (string-length binstr)
								      bytes-used))))
					   (else 1))))
			(label (or (directive-label next) :next))
			(label-n (lambda (n)
                                    (cond
                                       ((and (= n 0) (eqv? label :next))
                                        ;; force 1-based arrays
                                        1)
                                       ((eqv? label :next) label)
                                       (else (mkstr label n))))))
		    (let repeat ((i 0) (binstr binstr))
		       (if (< i repeater)
			   (let ((val (case char
					 ((#\L) (unpack-unsigned-long-machine binstr))
					 ((#\l) (unpack-signed-long-machine binstr))
					 ((#\N) (unpack-unsigned-long-big-endian binstr))
					 ((#\n) (unpack-unsigned-short-big-endian binstr))					 
					 ((#\V) (unpack-unsigned-long-little-endian binstr))
					 ((#\v) (unpack-unsigned-short-little-endian binstr))
					 ((#\C) (unpack-unsigned-char binstr))
					 ((#\c) (unpack-signed-char binstr))
					 (else ""))))
			      (php-hash-insert! h (label-n i) val)
			      (repeat (+ i 1) (substring binstr bytes-used (string-length binstr))))
			   (loop (cdr triplets) binstr)))))))))

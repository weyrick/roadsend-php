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

(module utils
   (extern
    (include "limits.h")
    (include "stdlib.h")
    (include "stdio.h")
    (macro c-path-max::int "PATH_MAX") )
   (import
    (grass "grasstable.scm")
    (php-types "php-types.scm"))
   (extern
    ;; bigloo's flush-output-port is not binary safe on string ports,
    ;; and in recent versions it no longer resets the position to 0
    (flush-string-port/bin::bstring (::output-port) "strport_bin_flush"))
   (export
    (string-subst::bstring text::bstring old::bstring new::bstring . rest)
    (hashtable-copy hash)
    (undollar str)    
    (vector-swap! v a b)
    (escape-path path)
    (normalize-path loc)
    (append-paths a b . rest)
    (merge-pathnames absolute::bstring relative::bstring)
    ;(copy-file string1 string2)
    (util-realpath path::bstring) 
    (re-string-split split-on str)
    (char-position char str)
    (integer->string/digits int base digits . chop)
    (get-tokens-from-string regular-grammar astring)
    (get-tokens regular-grammar input-port)
    (inline gcar arg)
    (inline gcdr arg)
    (append-strings strings)
    (string->integer/base str base)
    (garbage->number/base str base)
    (string->number/base str base floatify? stop-at-garbage?)
    (integer->string/base num base)
    (number->string/base num base)
    (fill-indexed-prop obj settor list-of-values)
    (symbol-downcase sym)
    (numeric-string? str)
    (hex-string->flonum str)
    (walk-dag first-node generate-list-of-next-nodes frobber-to-apply)
    (least-power-of-2-greater-than x)
    (strip-string-prefix str prefix)
    (uniq lst)
    (unique-strings list-of-strings)
    (sublist-copy lst start end)
    (y-or-n-p prompt)
    (pathname-relative? pathname::bstring)
    (windows->unix-path p::bstring)
;    (walk-dag-breadth-first first-node generate-list-of-next-nodes frobber-to-apply)
    (loc-line location)
    (loc-file location)
    (safety-ext)
    (make-tmpfile-name dir pref)
    (pcc-file-separator)
    (force-trailing-/ p)))

; a version of php's str_replace
(define (string-subst::bstring text::bstring old::bstring new::bstring . rest)
   (multiple-value-bind (num-matches matches) (find-idxs text old)
      (if (=fx num-matches 0)
	  (if (null? rest)
	      text
	      (apply string-subst text rest))
	  (let* ((text-len (string-length text))
		 (new-len (string-length new))
		 (old-len (string-length old))
		 (new-buf-size (cond ((=fx new-len old-len) text-len)
				     ((<fx new-len old-len) (-fx text-len
								 (*fx (-fx old-len new-len) num-matches)))
				     ((>fx new-len old-len) (+fx text-len
								 (*fx (-fx new-len old-len) num-matches)))))
		 (result (make-string new-buf-size)))
	     (let loop ((o-text 0)
			(o-result 0)
			(i 0))
		(if (=fx i num-matches)
		    ; no more matches, copy ending if we have it
		    (when (<fx o-text text-len)
		       (blit-string! text o-text result o-result (-fx text-len o-text)))
		    ; copy match
		    (let ((copy-len (-fx (vector-ref matches i) o-text)))
		       ; fill before match
		       (when (>fx copy-len 0)
			  (blit-string! text o-text result o-result copy-len))
		       ; fill replacement
		       (blit-string! new 0 result (+fx o-result copy-len) new-len)
		       ; next match
		       (loop (+fx (vector-ref matches i) old-len)
			     (+fx o-result (+fx new-len copy-len))
			     (+fx i 1)))))
	     (if (null? rest)
		 result
		 (apply string-subst result rest))))))

(define (find-idxs haystack::bstring needle::bstring)
   (let ((tbl (kmp-table needle))
	 (matches (make-vector 10))
	 (vsize 10)
	 (pages 1)
	 (num-matches 0)
	 (text-len (string-length haystack))
	 (old-len (string-length needle)))
      (let loop ((offset 0))
	 (when (<fx offset text-len)
	    (let ((match-i (kmp-string tbl haystack offset)))
	       (when (>=fx match-i 0)
		  ; do we need to expand our vector?
		  (when (=fx num-matches vsize)
		     (set! pages (+fx 1 pages))
		     (set! vsize (+fx vsize (*fx pages vsize)))
		     (set! matches (copy-vector matches vsize)))
		  (vector-set! matches num-matches match-i)
		  (set! num-matches (+fx num-matches 1))
		  (loop (+fx match-i old-len))))))
      (values num-matches matches)))

(define (make-tmpfile-name dir prefix)
   (let* ((alphabet (list->vector '(0 1 2 3 4 5 6 7 8 9
					A B C D E F G H I
					J K L M N O P Q R
					S T U V W X Y Z
					a b c d e f g h i
					j k l m n o p q r
					s t u v w x y z
					)))
	    (the-date (current-date))
	    (pick-char (lambda ()
			  (let ((c (vector-ref alphabet (random (vector-length alphabet)))))
			     (if (number? c)
				 (number->string c)
				 (symbol->string c))))))
      (string-append
       dir
       (string (pcc-file-separator))
       prefix
       (number->string (date-second the-date))
       (pick-char)
       (pick-char)
       (number->string (date-minute the-date))
       (pick-char)
       (pick-char))))

(define (windows->unix-path p::bstring)
   (string-case p
      ;; just z: becomes just /z/
      ((: alpha ":")
       (string-append "/" (the-substring 0 1) "/"))
      ;; replace z:\ with /z/
      ((: alpha #\: #\\ (* all))
       (string-append "/" (the-substring 0 1)
		      "/" (windows->unix-path (the-substring 3 (the-length)))))
      ;; replace \ with /
      (else
       (pregexp-replace* "\\\\" p "/"))))

(define (y-or-n-p prompt)
   (let loop ()
      (display* #\newline prompt)
      (string-case (read-line)
	 ((or "y" "yes") #t)
	 ((or "n" "no") #f)
	 (else (print "Please enter yes or no.")
	       (loop)))))

(define (vector-swap! v a b)
   (when (not (= a b))
      (let ((c (vector-ref v a))
	    (d (vector-ref v b)))
	 ;(print "a " a " b " b " c " c " d " d)
	 (vector-set! v a d)
	 (vector-set! v b c))))


(define (escape-path path)
   "escape a path e.g. for use on a commandline"
					;    (pregexp-replace* " "
					; 		     (pregexp-replace* "\\\\" path "/")
					; 		     "\\\\ "))
   (string-append 
    "\"" ;(pregexp-replace* 
	 ;" " 
	 (pregexp-replace* "\\\\" path "/")
	 ;"\\\\ ") 
    "\""))
   

(define (input-fill-string! port s)
   (let ((len::int (string-length s))
	 (s::string s))
      (pragma::int "fread($1, 1, $2, BINARY_PORT( $3 ).file)"
		   s
		   len
		   port)))


(define (util-realpath path::bstring)
   (cond-expand
      (PCC_MINGW
       (if (pathname-relative? path)
	   (merge-pathnames (string-append (pwd) "\\")
			    path)
	   (let ((p (merge-pathnames (string-append path "\\") "")))
              (substring p 0 (- (string-length p) 1)))))
      (else
       (let* ((pathbuf::string (make-string c-path-max))
	      (path::string path)
	      (the-realpath::string (pragma::string "realpath($1, $2)"
						   path pathbuf)))
	  (if (string-ptr-null? the-realpath)
	      path
	      the-realpath)))))

(define (get-tokens regular-grammar input-port)
   "this will show you the tokens on a port with rg lexer"
   (let ((alist '()))
      (do ((toker (read/rp regular-grammar input-port)
		  (read/rp regular-grammar input-port)))
	  ((eof-object? toker))
	  (set! alist (cons toker alist)))
      (reverse! alist)))

(define (get-tokens-from-string regular-grammar astring)
   "this will show you the tokens in a string with rg lexer"
   (with-input-from-string astring
   	 (lambda ()
	    (get-tokens regular-grammar (current-input-port)))))

;; return either a list of the two parts, or #f if split-on wasn't
;; present.  split-on should be a character, not a string.
(define (re-string-split split-on str)
   (let ((pos (char-position split-on str)))
      (if pos
	  (list (substring str 0 pos)
		(substring str (+ pos 1) (string-length str)))
          #f)))

(define (char-position char str)
   (let ((len (string-length str)))
      (let loop ((c 0))
	 (if (>= c len)
	     #f
	     (if (char=? (string-ref str c) char)
		 c
		 (loop (+ c 1)))))))

(define (integer->string/digits int base digits . chop)
   "Print a fixed-width integer. If chop is non-null, chop numbers
   from the left."
   (let* ((num (integer->string int base))
	  (len (string-length num)))
      (cond
	 ;pad with leading zeros
	 ((> digits len)
	  (let ((nstr (make-string digits #\0)))
	     (blit-string! num 0 nstr (- digits len) len)
	     nstr))
	 ;already the right width
	 ((= digits len) num)
	 ;user wants the number to be shorter than it is
	 ((< digits len)
	  (if (null? chop)
	      ;either don't chop
	      num
	      ;or return just the rightmost digits
	      (if (= digits 0)
		  ""
		  (substring num (- len digits) len)))))))

(define *append-strings-port* (open-output-string))
(define (append-strings strings)
   "return a new string that is the concatenation of strings"
   (for-each (lambda (str) (display str *append-strings-port*))
             strings)
   (flush-string-port/bin *append-strings-port*))


;good car, good cdr
(define-inline (gcar arg) (if (null? arg) arg (car arg)))
(define-inline (gcdr arg) (if (null? arg) arg (cdr arg)))



(define *little-a* (char->integer #\a))
(define *big-a* (char->integer #\A))
(define *zero* (char->integer #\0))

(define (char->digit char)
   "convert one character into a digit (number)"
   (set! char (char->integer char))
   (cond 
      ((and (>= char *zero*)
	    (<= char (+ *zero* 9)))
       (- char *zero*))
      ((and (>= char *little-a*)
	    (<= char (+ *little-a* 25)))
       (+ 10 (- char *little-a*)))
      ((and (>= char *big-a*)
	    (<= char (+ *big-a* 25)))
       (+ 10 (- char *big-a*)))
      (else -1)))

(define (digit->char digit)
   "convert one digit (number) into a character"
   (let ((alphanums "0123456789abcdefghijklmnopqrstuvwxyz"))
      (string-ref alphanums (modulo digit (string-length alphanums)))))


(define (string->integer/base str base)
   "read a whole number from a string in any base"
   (string->number/base str base #f #t))

(define (garbage->number/base str base)
   "read a whole number from a string in any base, ignoring garbage"
   (string->number/base str base #t #f))


(define *max-int* (expt 2.0 31))
(define (string->number/base str base floatify? stop-at-garbage?)
   "read a whole number from a string in any base, approximating with
   a float if an integer would overflow"
   (let ((cutoff (floor (- (/ *max-int* base) base))))
      (let loop ((i 0)
		 (num 0))
	 (if (= i (string-length str))
	     num
	     (let ((digit (char->digit (string-ref str i))))
		(if (or (< digit 0) (>= digit base))
		    (if stop-at-garbage?
			;invalid digit: end of number.
			num
			(loop (+ i 1) num))
		    (if (and floatify? (fixnum? num) (> num cutoff))
			(loop i (fixnum->flonum num))
			(loop (+ i 1)
			      (+ (* num base) digit)))))))))



(define (integer->string/base num base)
   "write a whole number to a string in any base"
   (let loop ((x (abs (if (flonum? num)
			  (flonum->fixnum num)
			  num)))
	      (chars '()))
      (if (>= (abs x) 1)
	  (loop (/fx x base)
		(cons (digit->char (modulo x base)) chars))
	  (if (null? chars)
	      "0"
	      (list->string (if (< num 0)
				(cons #\- chars)
				chars))))))
		      


(define (number->string/base num base)
   "??? maybe handle floats? this one needs work."
   (error 'number->string/base "This function is not yet implemented."
	  (cons num base)) )


(define (fill-indexed-prop obj settor list-of-values)
   "utility to fill an indexed field of a bigloo object from a list of values"
   (let ((i 0))
      (for-each (lambda (val)
		   (settor obj i val)
		   (set! i (+ i 1)))
	   list-of-values)))

(define (symbol-downcase sym)
   "make a symbol lower case"
   (string->symbol (string-downcase (symbol->string sym))))


(define (numeric-string? str)
   (if (and (string? str)
	    (> (string-length str) 0))
       (let ((slen (string-length str))
	     (allow-dot #t))
	  (let loop ((i 0))
	     (if (< i slen)
		 (let ((ch (string-ref str i)))
		    (if (or (char-numeric? ch)
			    ; negative
			    (and (= i 0)
				 (char=? (string-ref str 0) #\-)
				 (> slen 1))
			    ; floating point
			    (and (char=? ch #\.)
				 allow-dot))
			(begin
			   (if (char=? ch #\.)
			       (set! allow-dot #f)) 
			   (loop (+ i 1)))
			#f))
		 #t)))
       #f))

(define (hex-string->flonum str)
   "convert a string representing a hex number into a bigloo flonum"
   (let ((slen (string-length str))
	 (val 0.0))
      (let loop ((i 0))
	 (if (< i slen)
	     (begin
		(let ((tval (fixnum->flonum (string->integer (string (string-ref str i)) 16))))
		   (if (>fl val 0.0)
		       (set! val (+fl (*fl val 16.0) tval))
		       (set! val tval))
		   (loop (+ i 1))))))
      val))


(define (walk-dag first-node generate-list-of-next-nodes frobber-to-apply)
   (let ((seen (make-grasstable)))
      (letrec ((visit-once (lambda (node)
			      (unless (grasstable-get seen node)
				 (grasstable-put! seen node #t)
				 (frobber-to-apply node)
				 (for-each visit-once
					   (generate-list-of-next-nodes node))))))
	 (visit-once first-node))))


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

; unsigned clp2(unsigned x) {
;    x = x - 1;
;    x = x | (x >> 1);
;    x = x | (x >> 2);
;    x = x | (x >> 4);
;    x = x | (x >> 8);
;    x = x | (x >>16);
;    return x + 1;
; }

(define (strip-string-prefix prefix str)
   "if prefix matches the beginning of str, return str without it, otherwise
return str unchanged"
   (let ((str-len (string-length str))
 	 (prefix-len (string-length prefix)))
      (if (and (<= prefix-len str-len)
	       (substring-at? str prefix 0))
	  (substring str prefix-len str-len)
	  str)))

;;;;PATH STUFF

(define *normalize-path-string-port* (open-output-string))

; /var/blah//baz//foo.php -> /var/blah/baz/foo.php
(define (normalize-path path)
   "eliminate multiple adjacent slashes"
   (let  ((sep-seen? #f)
          (out *normalize-path-string-port*)
          (len (string-length path)))
      (let loop ((i 0))
         (when (<fx i len)
            (let ((char (string-ref path i)))
               (if (file-separator? char)
                   (unless sep-seen?
                      (display (pcc-file-separator) out)
                      (set! sep-seen? #t))
                   (begin
                      (display char out)
                      (set! sep-seen? #f))))
            (loop (+fx i 1))))
      (flush-string-port/bin out)))

(define (append-paths a b . rest)
;   (print "append paths " a " " b " " rest)
   "try to stick two or more strings together separated by slashes in
   a sane way"
;   (normalize-path (append-strings (cons a (cons b rest)))))
   (cond
      ((zero? (string-length a))
       (if (pair? rest)
	   (apply append-paths b rest)
	   b))
      ((zero? (string-length b))
       (if (pair? rest)
	   (apply append-paths a rest)
	   a))
      ((not (file-separator? (string-ref a (- (string-length a) 1))))
       (apply append-paths (string-append a (string (pcc-file-separator))) b rest))
      ((file-separator? (string-ref b 0))
       (apply append-paths a (substring b 1 (string-length b)) rest))
      (else
       (if (pair? rest)
	   (apply append-paths (merge-pathnames a b) rest)
	   (merge-pathnames a b)))))
	       



(define (pathname-relative? pathname::bstring)
   (string-case pathname
      ((: "/" (* all)) #f)
      ((: alpha ":" (or "/" "\\") (* all)) #f)
      (else #t)))

(define (file-separator? char)
   (cond-expand
    (PCC_MINGW
     (or (char=? char #\/)
	 (char=? char #\\)))
    (else 
     (char=? char #\/))))

(define (pcc-file-separator)
   (cond-expand
    ;; the file-separator in bigloo on mingw is still forward slash
    (PCC_MINGW #\\)
    (else #\/)))

(define (merge-pathnames absolute::bstring relative::bstring)
   "merge an absolute path and a relative path, return the new path
for example:  /foo/bar/baz + ../bling/zot = /foo/bling/zot"
;   (print "merge-pathnames: attempting to merge absolute " absolute " with relative " relative)
   (let ((absolute-len (string-length absolute))
         (relative-len (string-length relative)))
      ;;we collect the new directory as a stack (reversed list) in pwd
      (let ((pwd '())
            ;;the number of directories we've gone up past the root 
            ;;in the absolute path
            (past-root 0))
         (let ((cd (lambda (dir)
                                        ;(print "cding to " dir)
                      (cond
                        ((string=? dir "..") (if (null? pwd)
                                                 (set! past-root (+ past-root 1))
                                                 (set! pwd  (gcdr pwd))))
                        ((string=? dir ".") #t)
                        ;; ignore empty directories resulting from double slashes
                        ((string=? dir "") #t)
                        (else (set! pwd (cons dir pwd)))))))
            ;;cd up the absolute path, skipping a slash, if it starts with one
            (let ((start (if (and (not (zero? absolute-len))
                                  (file-separator? (string-ref absolute 0)))
                             1
                             0)))
               (let loop ((left start)
                          (right start))
                    (when (<fx right absolute-len)
                       (if (file-separator? (string-ref absolute right))
                           (begin
                            (cd (substring absolute left right))
                            (loop (+fx right 1) (+fx right 1)))
                           (loop left (+fx right 1))))))
                                        ;cd up the relative path
            (let loop ((left 0)
                       (right 0))
                 (if (<fx right relative-len)
                     (if (file-separator? (string-ref relative right))
                         (begin
                          (cd (substring relative left right))
                          (loop (+fx right 1) (+fx right 1)))
                         (loop left (+fx right 1)))
                     ;; return the new path + the file part of the relative path
                     (with-output-to-string
                         (lambda ()
                            ;;first, in case we went up past the root of the "absolute" path,
                            ;;tack on the appropriate number of ../'s
                            (do ((i 0 (+ i 1)))
                                ((>= i past-root))
                               (display "..")
                               (display (pcc-file-separator)))
                            ;;in case we didn't go past the root, and the left path is
                            ;;absolute, generate an absolute path
                            (when (and (> absolute-len 0)
                                       (file-separator? (string-ref absolute 0))
                                       (= 0 past-root))
                               (display (pcc-file-separator)))
                            (for-each (lambda (p)
                                         (display p)
                                         (display (pcc-file-separator)))
                                      (reverse pwd))
                            (display (substring relative left right))))))))))


(define (force-trailing-/ p)
   ;; add a terminating slash (file separator) if not there
   (if (char=? (string-ref p (- (string-length p) 1))
               (pcc-file-separator))
       p
       (string-append p (string (pcc-file-separator)))))

(define (uniq lst)
   "return lst without any values that are eq? to each other"
   (let ((u (make-grasstable)))
      (for-each (lambda (e) (grasstable-put! u e #t)) lst)
      (grasstable-key-list u)))

(define (unique-strings list-of-strings)
   (let ((myhash (make-hashtable)))
      (for-each (lambda (x) (hashtable-put! myhash x x)) list-of-strings)
      (hashtable->list myhash)))

(define (sublist-copy lst start end)
   "return a copy of the sublist of LST from START index to END index"
   (let loop ((i start)
	      (old-list (list-tail lst (min start (length lst))))
	      (new-list '()))
      (if (or (null? old-list) (>= i end))
	  (reverse new-list)
	  (loop (+ i 1)
		(cdr old-list)
		(cons (car old-list) new-list)))))


(define (loc-line location)
   (car location))

(define (loc-file location)
   (cdr location))

(define (safety-ext)
   (cond-expand
      (unsafe "_u")
      (else "_s")))

(define (undollar str)
   (let ((str (mkstr str)))
      (if (char=? (string-ref str 0) #\$)
	  (substring str 1 (string-length str))
	  str)))

(define (hashtable-copy hash)
   (let ((new-hash (make-hashtable (max 1 (hashtable-size hash)))))
      (hashtable-for-each hash
			  (lambda (key val)
			     (hashtable-put! new-hash key val)))
      new-hash))


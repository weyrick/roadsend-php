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

(module php-string-lib
   (include "../phpoo-extension.sch")
;   (library "common")
   (import (php-variable-lib "php-variable.scm"))
   (import (php-math-lib "php-math.scm"))
   (library profiler)
   (extern
    (include "crc.h")
    (include "strnatcmp.h")
    (include "string.h")
    (include "locale.h")
    (macro strcmp::int (s1::string s2::string) "strcmp")
    ;(macro strrchr::string (s1::string s2::int) "strrchr")
    (macro strncmp::int (s1::string s2::string len::int) "strncmp")
    (macro strcspn::int (s1::string s2::string) "strcspn")
    (macro strcoll::int (s1::string s2::string) "strcoll")  
    (macro strspn::int (s::string accept::string) "strspn")  
    (macro b64enc::string (data::string len::int) "b64enc")
    (macro b64dec::string (data::string len::int) "b64dec")
    (crc32::elong (str::string len::uint) "woot_crc32")
    (macro strnatcmp::int (str1::string str2::string) "strnatcmp")
    (macro strnatcasecmp::int (str1::string str2::string) "strnatcasecmp")
    (macro lc-all::int "LC_ALL")
    (macro lc-collate::int "LC_COLLATE")
    (macro lc-ctype::int "LC_CTYPE")
    (macro lc-monetary::int "LC_MONETARY")
    (macro lc-messages::int "LC_MESSAGES")
    (macro lc-numeric::int "LC_NUMERIC")
    (macro lc-time::int "LC_TIME")
    )
   (export
    (init-php-string-lib)
    ;;; standard php functions
    (addcslashes str chars)
    (addslashes str)
    (base64_encode str)
    (base64_decode str)
    ; bin2hex
    (chr ascii)
    (chunk_split body chunklen end)
    ; convert_cyr_string
    (count_chars str mode)
    (php-crc32 str)
    (php-crypt str salt)
    (explode sep str limit)
    (get_html_translation_table table quote-style)
    ; hebrev
    ; hebrevc
    (html_entity_decode string quote-style charset)
    (htmlentities string quote-style charset)
    (htmlspecialchars string quote-style charset)
    (implode glue pieces)
    ; levenshtein
    ; localeconv
    (ltrim str to-trim)
    (md5_file fname)
    (md5 str)
    ; metaphone
    ; money_format
    ; nl_langinfo
    (nl2br str)
    (number_format num decimals point thousands-sep)
    (ord char)
    (parse_str str array)
    (parse_url url)
    (php-printf . data)
    (quoted_printable_decode str)
    (quotemeta str)
    (rawurlencode str)
    (rawurldecode str)
    (rtrim str to-trim)
    (php-setlocale category . locales)
    ; sha1_file
    ; sha1
    (similar_text first second percent)
    (php-soundex str)
    (sprintf . t-data)
    (sscanf str format var1)
    ; str_ireplace PHP5
    (str_pad str len pad pad-type)
    (str_repeat str iter)
    (str_replace search replace subj) 
    (str_rot13 str)
    (str_shuffle str)
    ; str_split PHP5
    ; str_word_count
    (strcasecmp str1 str2)
    (php-strcmp str1 str2)
    (php-strcoll str1 str2)
    (php-strcspn str1 str2 start len)
    (strip_tags str allow-tags)
    (stripcslashes str)
    (stripos haystack needle offset)
    (stripslashes str)    
    (stristr haystack needle)
    (strlen str)
    (php-strnatcasecmp str1 str2)
    (php-strnatcmp str1 str2)
    (strncasecmp str1 str2 len)
    (php-strncmp str1 str2 len)
    (strpos haystack needle offset)
    (strrchr haystack needle)
    (strrev str)
    (strripos haystack needle)
    (strrpos haystack needle)
    (php-strspn str1 str2 start len)
    (strstr haystack needle)
    (strtok arg1 arg2)
    (strtolower str)
    (strtoupper str)
    (strtr str from to)
    (substr_count haystack needle)
    (substr_replace str replace start len)
    (substr str start len)
    (trim str to-trim)
    (ucfirst str)
    (ucwords str)
    (urlencode str)
    (urldecode str)
    (version_compare ver1 ver2 op)
    (vprintf format args)
    (vsprintf format args)
    (wordwrap str width break cut)
    ;; CONSTANTS
    STR_PAD_RIGHT
    STR_PAD_LEFT
    STR_PAD_BOTH
    HTML_ENTITIES
    HTML_SPECIALCHARS
    ENT_COMPAT
    ENT_QUOTES
    ENT_NOQUOTES

    LC_ALL
    LC_COLLATE
    LC_CTYPE
    LC_MONETARY
    LC_MESSAGES
    LC_NUMERIC
    LC_TIME    
    ))



; init the module
(define (init-php-string-lib)
   1)


(defconstant HTML_ENTITIES 0)
(defconstant HTML_SPECIALCHARS 1)
(defconstant ENT_COMPAT    0)
(defconstant ENT_QUOTES    1)
(defconstant ENT_NOQUOTES  2)


(defconstant LC_ALL lc-all) 
(defconstant LC_COLLATE lc-collate) 
(defconstant LC_CTYPE lc-ctype) 
(defconstant LC_MONETARY lc-monetary) 
(defconstant LC_MESSAGES (cond-expand 
			  (PCC_MINGW  lc-all)
			  (else lc-messages) ))
(defconstant LC_NUMERIC lc-numeric) 
(defconstant LC_TIME lc-time)

   
; possibly turn an integer needle into a string of
; one character using the number as the ascii code
(define (maybe-int->char-str needle)
   (if (php-number? needle)
       (string (integer->char (mkfixnum needle)))
       (mkstr needle)))

;; String functions

; rawurlencode
(defbuiltin (rawurlencode str)
  (let ((rp (regular-grammar
		  ()
	       ((or
		 alpha
		 digit
		 #\_
		 #\-
		 #\.
		 )
		(the-string))
	       (else
		(if (eof-object? (the-failure))
		    (the-failure)
		    (string-append "%" (string-upcase (char->hex (the-failure)))))))))
     (append-strings (get-tokens-from-string rp (mkstr str)))))

; rawurldecode
(defbuiltin (rawurldecode str)
   (let ((rp (regular-grammar
		   ()
		((: #\% xdigit xdigit)
		 (integer->char (string->number (the-substring 1 3) 16))))))
      (list->string (get-tokens-from-string rp (mkstr str)))))

; urldecode
(defbuiltin (urldecode str)
   (let ((rp (regular-grammar
		   ()
		((: #\% xdigit xdigit)
		 (integer->char (string->number (the-substring 1 3) 16)))
		(#\+ #\space))))
      (list->string (get-tokens-from-string rp (mkstr str)))))

; urlencode
(defbuiltin (urlencode str)
  (let ((rp (regular-grammar
		  ()
	       ((or
		 alpha
		 digit
		 #\_
		 #\-
		 #\.
		 )
		(the-string))
	       (#\space "+")
	       (else
		(if (eof-object? (the-failure))
		    (the-failure)
		    (string-append "%" (string-upcase (char->hex (the-failure)))))))))
     (append-strings (get-tokens-from-string rp (mkstr str)))))

; base64_encode
(defbuiltin (base64_encode str)
   (base64-encode (mkstr str)))

; base64_decode
(defbuiltin (base64_decode str)
   (base64-decode (mkstr str)))

; crypt
; FIXME need to support multiple crypt types, per PHP docs
; right now this only handles standard DES
(define (rand-salt)
   (let ((stock "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/."))
      (string (string-ref stock (random 64)) (string-ref stock (random 64)))))

(define(c-crypt::bstring passwd::bstring salt::bstring)
  (pragma "char* crypt(const char*, const char*)")
  (pragma::string "crypt($1, $2)"
                  ($bstring->string passwd)
                  ($bstring->string salt)))

(defalias crypt php-crypt)
(defbuiltin (php-crypt str (salt 'unpassed))
   (when (eqv? salt 'unpassed) (set! salt (rand-salt)))
   (c-crypt str salt))

; md5
(defbuiltin (md5 str)
   (md5sum (mkstr str)))

; strtolower
(defbuiltin (strtoupper str)
   (string-upcase (mkstr str)))

; strtoupper
(defbuiltin (strtolower str)
   (string-downcase (mkstr str)))

; strlen
(defbuiltin (strlen str)
   (convert-to-integer
    (string-length (mkstr str))))

; ucwords
(defbuiltin (ucwords str)
   (string-capitalize (mkstr str)))

; trim

; This function returns a string with whitespace stripped from the beginning and end of str.
; Without the second parameter, trim() will strip these characters:
;      " " (ASCII 32 (0x20)), an ordinary space.
;      "\t" (ASCII 9 (0x09)), a tab.
;      "\n" (ASCII 10 (0x0A)), a new line (line feed).
;      "\r" (ASCII 13 (0x0D)), a carriage return.
;      "\0" (ASCII 0 (0x00)), the NUL-byte.
;      "\x0B" (ASCII 11 (0x0B)), a vertical tab. 
; You can also specify the characters you want to strip, by means of the charlist parameter.
; Simply list all characters that you want to be stripped. With .. you can specify a range of characters.

; FIXME
; 1) if we use this version, need to handle character ranges
(define (do-ltrim s chars-to-trim)
   (let ((len (string-length s)))
      (let loop ((i 0))
	 (if (<fx i len)
	     (if (char-member? (string-ref s i) chars-to-trim)
		 (loop (+fx i 1))
		 (substring s i len))
	     ""))))
	      
;    (cond ((null? s) s)
; 	 ((not (member (car s) chars-to-trim)) s)
; 	 ((member (car s) chars-to-trim) (do-ltrim (cdr s) chars-to-trim))))

; (define (do-rtrim s c)
;    (reverse! (do-ltrim (reverse! s) c)))

(define (do-rtrim s chars-to-trim)
   (let ((len (string-length s)))
      (let loop ((i (-fx len 1)))
	 (if (>=fx i 0)
	     (if (char-member? (string-ref s i) chars-to-trim)
		 (loop (-fx i 1))
		 (substring s 0 (+fx i 1)))
	     ""))))

(define (do-trim s c)
   (do-ltrim (do-rtrim s c) c))

(define (char-member? c bag)
   (if (null? bag)
       #f
       (let loop ((flag #f)
		  (bag bag))
	  (if (or flag (null? bag))
	      flag
	      (loop (char=? c (car bag))
		    (cdr bag))))))

(defbuiltin (ltrim str (to-trim '(#a032 #a009 #a010 #a013 #a000 #a011)))
   ;   (let ((s (string->list (mkstr str))))
   (unless (list? to-trim)
      (set! to-trim (string->list to-trim)))
   (do-ltrim (mkstr str) to-trim))
;      (list->string (do-ltrim s to-trim))))   

; chop is an alias to rtrim
(defalias chop rtrim)
(defbuiltin (rtrim str (to-trim '(#a032 #a009 #a010 #a013 #a000 #a011)))
   (set! str (mkstr str))
;   (let ((s (string->list str)))
   (unless (list? to-trim)
      (set! to-trim (string->list to-trim)))
   (do-rtrim str to-trim))
;      (list->string (do-rtrim s to-trim))))

(defbuiltin (trim str (to-trim '(#a032 #a009 #a010 #a013 #a000 #a011)))
   (set! str (mkstr str))
;   (let ((s (string->list str)))
   (unless (list? to-trim)
      (set! to-trim (string->list to-trim)))
   (do-trim str to-trim))
;      (list->string (do-trim s to-trim))))

; FIXME
; 1) if we use version below, it should also handle ltrim and rtrim
; 2) need to check expasion, php example in manual uses 0x00 format to specify ascii chars

;auxiliary for builtin trim - does range expansion
; (define (bag-expand bag)
;    (let ((dot? (lambda (c)
; 		  (char=? c #\.))))
;       (let loop ((bag-chars (string->list bag))
; 		 (chars-so-far '()))
; 	 (if (pair? bag-chars)
; 	     (match-case bag-chars
; 		(((and (? char?) ?left) (? dot?) (? dot?) (and (? char?) ?right) ???-)
; 		 (loop (cddddr bag-chars)
; 		       (cons `(:char-range ,left ,right) chars-so-far)))
; 		(((and (? char?) ?c) ???-)
; 		 (loop (cdr bag-chars) (cons c chars-so-far))))
; 	     (reverse chars-so-far)))))
	    
; (defbuiltin (trim string-to-trim
; 		  (bag (list->string '(#a032 #a009 #a010 #a013 #a000 #a011))))
;    (set! bag (bag-expand bag))
;    (let ((swallow `(:sub
; 		    (:or
; 		     (:seq :bos
; 			   (:between #f 1 #f (:one-of-chars ,@bag)))
; 		     (:seq (:between #f 1 #f (:one-of-chars ,@bag))
; 			   :eos)))))
;       (pregexp-replace* swallow string-to-trim "")))


; substr
; substr() returns the portion of string  specified by the start and length parameters.
; -If start is non-negative, the returned string will start at the start'th position in string,
; counting from zero.
; -If start is negative, the returned string will start at the start'th character from the end of string.
; -If length is given and is positive, the string returned will contain at most length characters
; beginning from start (depending on the length of string).
; -If string is less than start characters long, FALSE will be returned.
; -If length is given and is negative, then that many characters will be omitted from the end of
; string (after the start position has been calculated when a start is negative).
; -If start denotes a position beyond this truncation, an empty string will be returned. 

; (define (do-substr str start end)
;   (cond ((< start 0) (let ((s (- (string-length str) (abs start))))
; 			(if (< s 0)
; 			    (do-substr str 0 end)
; 			    (do-substr (substring str (- (string-length str) (abs start)) (string-length str) ) 0 end))))
; 	((< end 0) (do-substr str start (- (string-length str) (abs end))))
; 	((> start end) FALSE)
; 	((> start (string-length str)) FALSE)
; 	((> end (string-length str)) (substring str start (string-length str)))
; 	(else (substring str start end))))

(defbuiltin (substr str start (len 'unpassed))
    (set! str (mkstr str))
   (set! start (mkfixnum (convert-to-number start)))
   (if (not (eqv? len 'unpassed))
       (set! len (mkfixnum (convert-to-number len))))
   (letrec ((do-substr
	     (lambda (str start end)
		(cond ((< start 0) (let ((s (- (string-length str) (abs start))))
				      (if (< s 0)
					  (do-substr str 0 end)
					  (do-substr (substring str (- (string-length str) (abs start)) (string-length str) ) 0 end))))
		      ((< end 0) (do-substr str start
					    (max 0 (- (string-length str) (abs end)))))
		      ((> start end) FALSE)
		      ((> start (string-length str)) FALSE)
		      ((> end (string-length str)) (substring str start (string-length str)))
		      (else (substring str start end))))))
      (when (eqv? len 'unpassed) (set! len (string-length str)))
      (cond ((or (< start 0) (< len 0)) (do-substr str start len))
	    ((> start (string-length str)) FALSE)
	    (else (do-substr str start (+ start len))))))

      

; (let loop ((i 32))
;    (when (< i 127)
;       (if (= 0 (modulo i 8))
; 	  (display (format "~%")))
;       (let ((c (integer->char i)))
; 	 (if (member i '(8 9 10 11 12 13 97))
; 	     (display "special")
; 	     (display (format "\"\\\\~a\" " c))))
;       (loop (+ i 1))))


(define (translate-chars str char-set trans-table)
   "Translate characters in str that are in char-set (a vector of 256 bools)
    to their entries in trans-table (a vector of 256 strings) and return
    a new string."
   (let ((len (string-length str)))
      (let loop ((i 0)
		 (nstr ""))
	 (if (< i len)
	    (let ((intval (char->integer (string-ref str i))))
	       (if (vector-ref char-set intval)
		   (loop (+ i 1)
			 (string-append nstr
					(vector-ref trans-table intval)))
		   (loop (+ i 1)
			 (string-append nstr (substring str i (+ i 1))))))
	    nstr))))

;addcslashes -- Quote string with slashes in a C style
(defbuiltin (addcslashes str chars)
   (translate-chars (mkstr str)
		    (make-char-set (mkstr chars))
		    c-translation-table))   


	    
; addslashes -- Quote string with slashes
(defbuiltin (addslashes str)
   (translate-chars (mkstr str)
		    (make-char-set (string-append "\"\'\\" (string #a000)))
		    normal-translation-table))


; bin2hex --  Convert binary data into hexadecimal representation

; chr -- Return a specific character
(defbuiltin (chr ascii)
   (string (integer->char (mkfixnum ascii))))

; chunk_split -- Split a string into smaller chunks
(defbuiltin (chunk_split body (chunklen 76) (end "\r\n"))
   (set! chunklen (mkfixnum (convert-to-number chunklen)))
   (set! end (mkstr end))
   (let loop ((string-i 0)
	      (chunk-i 0)
	      (rstr ""))
      (if (< string-i (string-length body))
	  (if (= chunk-i chunklen)
	      (loop string-i 0 (string-append rstr end))
	      (loop (+ string-i 1) (+ chunk-i 1) (string-append rstr (substring body string-i (+ 1 string-i)))))
	  (string-append rstr end))))

; convert_cyr_string --  Convert from one Cyrillic character set to another

; count_chars --  Return information about characters used in a string
(defbuiltin (count_chars str (mode 0))
   (let ((str (mkstr str))
	 (mode (convert-to-number mode))
	 (convert-to-str 'no)
	 (result (make-php-hash)))
      ; 
      (cond ((php-= mode 3) (begin
			       (set! mode 0)
			       (set! convert-to-str 'only)))
	    ((php-= mode 4) (begin
			       (set! mode 0)
			       (set! convert-to-str 'not))))
      (when (or (php-= mode 0)
		(php-= mode 2))
	 (let loop ((i 0))
	    (when (< i 256)
	       (php-hash-insert! result i *zero*)
	       (loop (+ i 1)))))
      ; count
      (let loop ((i 0))
	 (when (< i (string-length str))
	    (if (php-= mode 2)
		(php-hash-remove! result (char->integer (string-ref str i)))
		(let ((curval (php-hash-lookup result (char->integer (string-ref str i)))))
		   (php-hash-insert! result
				     (char->integer (string-ref str i))
				     (if (null? curval) *one* (php-+ curval 1)))))
	    (loop (+ i 1))))
      ; sort
      (php-hash-sort-by-keys result php-<)
      ; results
      (cond ((eqv? convert-to-str 'no) result)
	    ((eqv? convert-to-str 'only) (let ((rstr ""))
					    (php-hash-for-each result
							       (lambda (k v)
								  (when (php-> v 0)
								     (set! rstr (mkstr rstr (chr k))))))
					    rstr))
	    ((eqv? convert-to-str 'not) (let ((rstr ""))
					   (php-hash-for-each result
							      (lambda (k v)
								 (when (php-= v 0)
								    (set! rstr (mkstr rstr (chr k))))))
					   rstr)))))

; crc32 -- Calculates the crc32 polynomial of a string
(defalias crc32 php-crc32)
(defbuiltin (php-crc32 str)
   (set! str (mkstr str))
   (crc32 str (string-length str)))

; explode -- Split a string by string
; FIXME this would be a lot simpler with pregexp-split
(defbuiltin (explode sep str (limit 'unpassed))
   (let* ((str (mkstr str))
          (str-len::long (string-length str))
          (sep (mkstr sep))
          (sep-len::long (string-length sep))
	  (limit-p (not (eqv? limit 'unpassed)))
          (limit::long (if limit-p (mkfixnum limit) 0)))
      (cond
         ((zero? sep-len)
          FALSE)
         ((or (> sep-len str-len) (and limit-p (zero? limit)))
          (let ((result-array (make-php-hash)))
	    (php-hash-insert! result-array :next str)
	    result-array))
         (else
	  (let* ((results (cons '() '()))
		 (add-result! (lambda (value)
				(let ((new-cons (cons value '())))
				  (set-cdr! (car results) new-cons)
				  (set-car! results new-cons))))
		 (finish-results (lambda ()
				   (list->php-hash (cdr results)))))
	    (set-car! results results)
	    (if (= 1 sep-len)
		
		(let ((sep-char (string-ref sep 0)))
		  (let loop ((left 0)
			     (count 1))
		    (if (= count limit)
			(begin
			  (add-result! (substring str left str-len))
			  (finish-results))
			(do ((pos::long left (+ 1 pos)))
			    ((or (>= pos str-len)
				 (char=? sep-char (string-ref str pos)))
			     (if (< pos str-len)
				 (begin
				   (add-result! (substring str left pos))
				   (loop (+fx pos 1) (+fx count 1)))
				 (begin
				   (add-result! (substring str left str-len))
				   (finish-results))
				 ))))))
		
		(let loop ((count 1)
			   (str2 str))
		  (if (= count limit)
 		      (begin
			(add-result! str2)
			(finish-results))
		      (let ((pos (substring? sep str2)))
			(if pos
			    (begin
			      (add-result! (substring str2 0 pos))
			      (loop (+fx count 1)
				    (substring str2 (+fx pos sep-len)
					       (string-length str2))))
			    (begin
			      (add-result! str2)
			      (finish-results))))))))
	  ))))

; (defbuiltin (explode sep str (limit 'unpassed))
;    (let* ((str (mkstr str))
;           (str-len (string-length str))
;           (sep (mkstr sep))
;           (sep-len (string-length sep))
;           (limit (if (eqv? limit 'unpassed) #f (mkfixnum limit)))
;           (result-array (make-php-hash)))
;       (cond
;          ((zero? sep-len)
;           FALSE)
;          ((or (> sep-len str-len) (and limit (zero? limit)))
;           (php-hash-insert! result-array :next str)
;           result-array)
;          (else
;           (let loop ((left 0)
;                      (right 0)
;                      (count 1))
;              (cond
;                 ;; reached the end of the string or the match limit
;                 ((or (> right (-fx str-len sep-len))
;                      (and limit (= count limit)))
;                  (php-hash-insert! result-array :next (substring str left str-len))
;                  result-array)
;                 ;; separator matches
;                 ((substring-at? str sep right)
;                  (php-hash-insert! result-array :next (substring str left right))
;                  (loop (+fx right sep-len) (+fx right sep-len) (+fx count 1)))
;                 ;; no match
;                 (else
;                  (loop left (+fx right 1) count))))))))

; get_html_translation_table --  Returns the translation table used by htmlspecialchars() and htmlentities()
; this is all horribly ethnocentric. but hey, it works just fine here in the good ol' U.S.
(defbuiltin (get_html_translation_table table (quote-style ENT_COMPAT))
   (let ((array (make-php-hash)))
      (if (php-= table 0)
	  (let loop ((i 160)) ; 160 and above only
	     (if (< i (vector-length iso8859-1-translation-table))
		 (begin
		    (php-hash-insert! array
				      (string (integer->char i))
				      (vector-ref iso8859-1-translation-table i))
		    (loop (+ i 1))))))
      ; always do special
      ; watch quotes
      (unless (php-= quote-style ENT_NOQUOTES)
	 (php-hash-insert! array "\"" "&quot;"))
      (when (php-= quote-style ENT_QUOTES)
	 (php-hash-insert! array "'" "&#39;"))
      (php-hash-insert! array "<" "&lt;")
      (php-hash-insert! array ">" "&gt;")
      (php-hash-insert! array "&" "&amp;")    
      array))

; get_meta_tags --  Extracts all meta tag content attributes from a file and returns an array
; hebrev --  Convert logical Hebrew text to visual text
; hebrevc --  Convert logical Hebrew text to visual text with newline conversion


(define *iso8859-1-decode-table* 'nil)

(define (make-iso8859-1-decode-table)
   (let ((t-size (vector-length iso8859-1-translation-table)))
      (set! *iso8859-1-decode-table* (make-vector (* t-size 2))) 
      (let loop ((i 0)
		 (t 0))
	 (if (< i t-size)
	     (begin
		(vector-set! *iso8859-1-decode-table* t (vector-ref iso8859-1-translation-table i))
		(vector-set! *iso8859-1-decode-table* (+ t 1) (string (integer->char i)))
		(loop (+ i 1) (+ t 2)))))))

; build this when required
(define (get-iso8859-1-decode-table)
   (if (eqv? *iso8859-1-decode-table* 'nil)
       (make-iso8859-1-decode-table))
   *iso8859-1-decode-table*)

; html_entity_decode
; FIXME ignores charset
(defbuiltin (html_entity_decode str (quote-style ENT_COMPAT) (charset 'ISO8859-1))
   (let ((t-vec (copy-vector (get-iso8859-1-decode-table) 512))
	 (newstr ""))
;       (let loop ((i 0))
; 	 (if (< i 512)
; 	     (begin 
; 		(print i ": " (vector-ref t-vec i))
; 		(loop (+ i 1)))))	 
      (when (php-= quote-style ENT_NOQUOTES)
	 (vector-set! t-vec 69 "&quot;"))
      (when (or (php-= quote-style ENT_COMPAT)
		(php-= quote-style ENT_NOQUOTES))
	 (vector-set! t-vec 79 "&#039;"))
      (set! newstr (apply string-subst (append (list (mkstr str)) (vector->list t-vec))))
      newstr))

; htmlentities --  Convert all applicable characters to HTML entities
; FIXME ignores charset
(defbuiltin (htmlentities string (quote-style ENT_COMPAT) (charset 'ISO8859-1))
   (let ((tchars (copy-vector iso8859-1-bit-table 256)))
      (when (php-= quote-style ENT_NOQUOTES)
	  (vector-set! tchars 34 #f))
      (when (php-= quote-style ENT_QUOTES)
	 (vector-set! tchars 39 #t))
      (translate-chars (mkstr string) tchars iso8859-1-translation-table)))

; htmlspecialchars --  Convert special characters to HTML entities
; FIXME ignores charset
(defbuiltin (htmlspecialchars string (quote-style ENT_COMPAT) (charset 'ISO8859-1))
   (let ((tchars "&<>"))
      (unless (php-= quote-style ENT_NOQUOTES)
	 (set! tchars (string-append tchars "\"")))
      (when (php-= quote-style ENT_QUOTES)
	 (set! tchars (string-append tchars "'")))
      (translate-chars (mkstr string)
		       (make-char-set tchars)
		       iso8859-1-translation-table)))

; implode -- Join array elements with a string
(defbuiltin (implode glue (pieces 'unpassed))
   (if (eqv? pieces 'unpassed)
       (if (php-hash? glue)
	   (begin
	      ; no glue
	      (set! pieces glue)
	      (set! glue ""))
	   ; bad, set to #f which will fail later
	   (set! pieces #f)))
   (let ((real-glue glue)
	 (real-pieces pieces))
   (if (and (not (php-hash? pieces))
	    (php-hash? glue))
       (begin
	  ; swapped order
	  (set! real-glue pieces)
	  (set! real-pieces glue)))
   (if (php-hash? real-pieces)
       (let ((the-glue (mkstr real-glue))
	     (p-list (list)))
	  (php-hash-for-each real-pieces (lambda (key val)
					    (set! p-list (cons (mkstr val) p-list))))
	  (string-join (reverse p-list) the-glue))
       #f)))
	  

; join -- (alias for implode)
(defalias join implode)
   
; levenshtein --  Calculate Levenshtein distance between two strings
; localeconv -- Get numeric formatting information

; md5_file -- Calculates the md5 hash of a given filename
(defbuiltin (md5_file fname)
   (md5sum-file (mkstr fname)))

; metaphone -- Calculate the metaphone key of a string

; nl2br --  Inserts HTML line breaks before all newlines in a string
(defbuiltin (nl2br str)
   (set! str (mkstr str))
   (let loop ((f-str "")
	      (si 0))
      (if (< si (string-length str))
	  (if (or (char=? (string-ref str si) #\newline)
		  (char=? (string-ref str si) #\return))
	      (begin
		 (set! f-str (string-append f-str "<br />" (string (string-ref str si))))
		 (if (and (< si (- (string-length str) 1))
			  (or (and (char=? (string-ref str si) #\newline)
				   (char=? (string-ref str (+ si 1)) #\return))
			      (and (char=? (string-ref str si) #\return)
				   (char=? (string-ref str (+ si 1)) #\newline))))
		     (loop (string-append f-str (string (string-ref str (+ si 1)))) (+ si 2))
		     (loop f-str (+ si 1))))
	      (loop (string-append f-str (string (string-ref str si))) (+ si 1)))
	  f-str)))

; number_format -- Format a number with grouped thousands
(defbuiltin (number_format num (decimals 0) (point ".") (thousands-sep ","))
   (let* ((num (convert-to-number num))
	  (negative? (php-< num 0))
	  (decimals (mkfixnum decimals))
	  (point (mkstr point))
	  (point (if (> (string-length point) 0)
		     (substring point 0 1)
		     "."))
	  (thousands-sep (mkstr thousands-sep))
	  (numstr (mkstr num))
	  (numstr-len (string-length numstr))
	  (numstr (if (and (> numstr-len 0)
			   (member (string-ref numstr 0) '(#\+ #\-)))
		      (substring numstr 1 numstr-len)
		      numstr))
	  (whole/frac (pregexp-split "\\." numstr))
	  (whole-part (with-output-to-string
			 (lambda ()
			    (if (null? whole/frac)
				(display #\0)
				(let loop ((count 0)
					   (digits (reverse (string->list (car whole/frac)))))
				   (when (not (null? digits))
				      (when (and (zero? (modulo count 3)) (> count 0))
					 (display thousands-sep))
				      (display (car digits))
				      (loop (+ 1 count) (cdr digits))))))))
	  (whole-part (list->string (reverse (string->list whole-part))))
	  (frac-part  (if (or (zero? decimals)
			      (< (length whole/frac) 2))
			  (make-string decimals #\0)
			  (let* ((frac (cadr whole/frac))
				 (len (string-length frac)))
			     (cond ((= len decimals) frac)
				   ((< len decimals) (string-append frac (make-string (- decimals len) #\0)))
				   (else (mkstr (substring frac 0 (- decimals 1))
						(if (> 5  (mkfixnum (string-ref frac (- decimals 1))))
						    (string-ref frac decimals)
						    (+ 1 (mkfixnum (string-ref frac decimals)))))))))))
      (with-output-to-string
	 (lambda ()
	    (when negative?
	       (display #\-))
	    (display whole-part)
	    (when (> decimals 0)
	       (display point)
	       (display frac-part))))))

; ord -- Return ASCII value of character
(defbuiltin (ord char)
   (let ((str (mkstr char)))
      (if (>= (string-length str) 1)
          (convert-to-integer (char->integer (string-ref str 0)))
          *zero*)))

; parse_str -- Parses the string into variables
(defbuiltin (parse_str str ((ref . array) 'undef))
   (let ((delim "&")
	 (php-hash (if (eqv? array 'undef)
		       (make-php-hash)
		       (if (php-hash? (container-value array))
			   (container-value array)
			   (make-php-hash))))) 
      ; if argument starts with &, ignore it
      (let* ((arg-string (mkstr str))
	     (do-insert (lambda (a k v)
			   ; handle hashes
			   (let ((amatch (pregexp-match "^(\\w+)\\[(\\w*)\\]$" k)))
			      ; convert to hash?
			      (cond ((not amatch) (php-hash-insert! a k v))
				    ; array, no key
				    ((string=? (list-ref amatch 2) "")
				     (let* ((h1 (php-hash-lookup a (list-ref amatch 1)))
					    (h (if h1 h1 (make-php-hash))))
					; XXX
					;(log-message (format "adding hash with no key: ~a" (list-ref amatch 1)))
					; do we have to convert h to a hash?
					(unless (php-hash? h)
					   (set! h (convert-to-hash h)))
					(php-hash-insert! h :next v)
					(php-hash-insert! a (list-ref amatch 1) h)))
				    ; array with key
				    (else (let* ((h1 (php-hash-lookup a (list-ref amatch 1)))
						 (h (if h1 h1 (make-php-hash))))
					     ; XXX
					     ;(log-message (format "adding hash with key: ~a, key ~s"
					     ;		       (list-ref amatch 1)
					     ;		       (list-ref amatch 2)
					     ;		       ))				  
					     ; do we have to convert h to a hash?
					     (unless (php-hash? h)
						(set! h (convert-to-hash h)))
					     (php-hash-insert! h (list-ref amatch 2) v)
					     (php-hash-insert! a (list-ref amatch 1) h))))))))
	 (if (and (> (string-length arg-string) 2)
		  (char=? (string-ref arg-string 0) #\&))
	     (set! arg-string (substring arg-string 1 (string-length arg-string))))
	 (for-each (lambda (name+value)
		      (match-case name+value
			 ((?name ?value)
			  (do-insert php-hash (urldecode name) (urldecode value)))
			  ;(php-hash-insert! php-hash (urldecode name) (urldecode value)))
			 ((?name)
			  (do-insert php-hash (urldecode name) ""))
			  ;(php-hash-insert! php-hash (urldecode name) ""))
			 (?-
			  (php-warning
			   (format "invalid data in argument list ~A"
				   name+value arg-string)))))
		   (map (lambda (a)
			   (pregexp-split "=" a))
			(pregexp-split delim arg-string))))
      ; finalize
      (if (container? array)
	  ; they passed us a hash to use
	  (container-value-set! array php-hash)
	  ; import into current environment
	  (env-import *current-variable-environment* php-hash ""))))

; parse_url -- Parse a URL and return its components
; XXX this is convoluted and ugly but mostly because php is so leniant
; but it should be rewritten in a more modular fashion
(defbuiltin (parse_url url)
   (let ((surl (mkstr url))
	 (rethash (make-php-hash))
	 (maybe-path (lambda (v w) ; possibly make it a path instead of what we thought
			(if (and (string? v)
				 (> (string-length v) 0)
				 (char=? (string-ref v 0) #\/))
			    "path"
			    w)))
	 (insert-if (lambda (h k v i) ; make sure it's there and has a value
		       (if (and (< i (vector-length v))
				(vector-ref v i)
				(not (string=? "" (vector-ref v i))))
			   (begin
			      (php-hash-insert! h k (vector-ref v i))
			      #t)
			   #f))))
      (if (> (string-length surl) 0)
	  ; http://rfc.sunsite.dk/rfc/rfc2396.html appendix B
	  (let ((parts (list->vector (pregexp-match "^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\\?([^#]*))?(#(.*))?"
						    surl))))
	     ; scheme
	     ; if it doesn't match scheme regex, make it host instead
	     (if (and (vector-ref parts 2)
		      ;  scheme        = alpha *( alpha | digit | "+" | "-" | "." )
		      ; XXX modified slightly, we don't allow the . which seems to work better
		      ; with php
		      (pregexp-match "^[a-zA-Z][a-zA-Z0-9\\+\\-]*$" (vector-ref parts 2)))
		 (insert-if rethash (maybe-path (vector-ref parts 2) "scheme") parts 2)
		 ; shift
		 (begin
		    (vector-set! parts 5 (vector-ref parts 4))
		    (vector-set! parts 4 (vector-ref parts 2)))) 
	     ; check host/authority
	     (if (vector-ref parts 4)
		(let ((host-auth (vector-ref parts 4)))
		   (cond ((string-contains host-auth "@")
			  ; parse auth info
			  (begin
			     (let ((auth-parts (list->vector (pregexp-split "@" host-auth))))
				; check for port. this duplicates code below argg
				(if (and (> (vector-length auth-parts) 1)
					 (string-contains (vector-ref auth-parts 1) ":"))
				    ; yes port
				    (let ((h-parts (list->vector (pregexp-split ":" (vector-ref auth-parts 1)))))
				       (insert-if rethash (maybe-path (vector-ref h-parts 0) "host") h-parts 0)
				       (insert-if rethash "port" h-parts 1))
				    ; no port
				    (insert-if rethash (maybe-path (vector-ref auth-parts 1) "host") auth-parts 1))
				; now user/pass
				(let ((user-pass (list->vector (pregexp-split ":" (vector-ref auth-parts 0)))))
				   (insert-if rethash "user" user-pass 0)
				   (insert-if rethash "pass" user-pass 1)))))
			 ((string-contains host-auth ":")
			  ; port
			  (begin
			     (let ((h-parts (list->vector (pregexp-split ":" host-auth))))
				(insert-if rethash (maybe-path (vector-ref h-parts 0) "host") h-parts 0)
				(insert-if rethash "port" h-parts 1))))
			 ((not (string=? host-auth ""))
			  ; no auth info
			  (php-hash-insert! rethash (maybe-path host-auth "host") host-auth))))
		; no host/auth info
		(insert-if rethash "path" parts 3))
	     ; if path doesn't start with a slash, take part before slash and assume port
	     (when (and (vector-ref parts 5)
			(> (string-length (vector-ref parts 5)) 0))
		(let ((p-parts (vector-ref parts 5)))
		   (if (not (char=? (string-ref p-parts 0) #\/))
		       ; split
		       (begin
			  (let ((h-parts (list->vector (pregexp-split "/" p-parts))))
			     (insert-if rethash "path" h-parts 1)
			     (insert-if rethash "port" h-parts 0)))
		       ; just path
		       (insert-if rethash "path" parts 5))))
	     (insert-if rethash "query" parts 7)
	     (insert-if rethash "fragment" parts 9))
	  ; nothin
	  (php-hash-insert! rethash "path" ""))
      ; cleanup port, changing type if necessary
      (when (is_numeric (php-hash-lookup rethash "port"))
	  (php-hash-insert! rethash "port" (convert-to-number (php-hash-lookup rethash "port"))))
      ; another masterpiece
      rethash))
		

; printf -- Output a formatted string
(defalias printf php-printf)
(defbuiltin-v (php-printf data)
   (echo (apply sprintf data)))

; quoted_printable_decode --  Convert a quoted-printable string to an 8 bit string
(defbuiltin (quoted_printable_decode str)
   (let ((rp (regular-grammar
		   ()
		((: #\= xdigit xdigit)
		 (integer->char (string->number (the-substring 1 3) 16)))
		; ignore newlines
		(#\Newline (ignore))
		; ignore whitespace at end of line		
		((eol (: #\= (* space))) (ignore)))))
      (list->string (get-tokens-from-string rp (mkstr str)))))

; quotemeta -- Quote meta characters
(defbuiltin (quotemeta str)
   (let ((rp (regular-grammar ((nasties (in ".\\+*?[^]($)")))
		(nasties (string-append "\\" (the-string)))
		((+ (out nasties)) (the-string))
		; pass the rest thru
		(else (the-failure)))))
      (append-strings (get-tokens-from-string rp (mkstr str)))))

; str_rot13 -- Perform the rot13 transform on a string
(defbuiltin (str_rot13 str)
   (let ((fr "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
	 (to "nopqrstuvwxyzabcdefghijklmNOPQRSTUVWXYZABCDEFGHIJKLM"))
      (strtr str fr to)))

; sscanf --  Parses input from a string according to a format
(defbuiltin (sscanf str format ((ref . var1) 'unpassed))
   ;; XXX write me!
   FALSE)

; setlocale -- Set locale information
(defalias setlocale php-setlocale)
(defbuiltin-v (php-setlocale category locales)
   (set! category (maybe-unbox category))
   (let ((category
	  (if (php-number? category)
	      (mkfixnum category)
	      (cond
		 ((string=? category "LC_ALL") (mkfixnum LC_ALL))
		 ((string=? category "LC_COLLATE") (mkfixnum LC_COLLATE))
		 ((string=? category "LC_CTYPE") (mkfixnum LC_CTYPE))
		 ((string=? category "LC_MESSAGES") 
		  (cond-expand 
		   (PCC_MINGW 
		    (php-warning "No LC_MESSAGES available on win32. Using LC_ALL.")
		    (mkfixnum LC_ALL))
		   (else 
		    (mkfixnum LC_MESSAGES))))
		 ((string=? category "LC_MONETARY") (mkfixnum LC_MONETARY))
		 ((string=? category "LC_NUMERIC") (mkfixnum LC_NUMERIC))
		 ((string=? category "LC_TIME") (mkfixnum LC_TIME))
		 (else (php-error "Invalid locale category name " category
				  " should be one of "
				  "LC_ALL, LC_COLLATE, LC_CTYPE, LC_MONETARY, LC_NUMERIC, or LC_TIME."))))))
      (let ((locales-to-try
	     (if (and (= (length locales) 1) (php-hash? (car locales)))
		 (map mkstr (php-hash->list (car locales)))
		 ;; we ignore the possibility that the user's passed
		 ;; us a hash _and_ extra args.  Perhaps that's not best.
		 (map mkstr locales))))
	 (bind-exit (return)
	    (for-each (lambda (locale)
			 (debug-trace 5 "setlocale() trying locale: " locale)
			 (let* ((category::int category)
				(locale::string locale)
				(retval::void* (pragma::void* "setlocale($1, $2)"
							      category locale)))
			    (when (not (void*-null? retval))
			       (let ((successful-retval (pragma::string "(char*)$1" retval)))
				  (debug-trace 5 "setlocale() successful: " successful-retval)
				  (return successful-retval)))))
		      locales-to-try)
	    ;; fallthrough return value (keep inside the bind-exit)
	    FALSE))))


; similar_text --  Calculate the similarity between two strings
(defbuiltin (similar_text first second ((ref . percent) 'unpassed))
   (set! first (mkstr first))
   (set! second (mkstr second))
   (when (eqv? percent 'unpassed)
      (set! percent (make-container 0)))
   (let ((len1 (string-length first))
	 (len2 (string-length second)))
      (if (zero? (+ len1 len2))
	  (container-value-set! percent (convert-to-float 0.0))
	  (let ((similarity (similar-chars first second)))
	     (container-value-set! percent
				   (convert-to-float
				    (/ (* similarity 200.0)
				       (+ len1 len2))))
	     (convert-to-number similarity)))))

(define (greatest-similar-str txt1 txt2)
   (let ((len1 (string-length txt1))
	 (len2 (string-length txt2))
	 (max 0)
	 (pos1 0)
	 (pos2 0))
      (dotimes (i len1)
	 (dotimes (j len2)
	    (let loop ((l 0))
	       (if (and (< (+ i l) len1)
			(< (+ j l) len2)
			(char=? (string-ref txt1 (+ i l))
				(string-ref txt2 (+ j l))))
		   (loop (+ l 1))
		   (when (> l max)
		      (set! max l)
		      (set! pos1 i)
		      (set! pos2 j))))))
      (values max pos1 pos2)))

(define (similar-chars first second)
   (let ((len1 (string-length first))
	 (len2 (string-length second)))
      (multiple-value-bind (max pos1 pos2)
	 (greatest-similar-str first second)
	 (let ((sum max))
	    (unless (zero? max)
	       (when (and (> pos1 0) (> pos2 0))
		  (set! sum (+ sum (similar-chars (substring first 0 pos1)
						  (substring second 0 pos2)))))
	       (when (and (< (+ pos1 max) len1)
			  (< (+ pos2 max) len2))
		  (set! sum (+ sum (similar-chars (substring first (+ pos1 max) len1)
						  (substring second (+ pos2 max) len2))))))
	    sum))))

	       
	    


; soundex -- Calculate the soundex key of a string
(defalias soundex php-soundex)
(defbuiltin (php-soundex str)
   (set! str (mkstr str))
   (soundex str))

; sprintf -- Return a formatted string
(defbuiltin-v (sprintf t-data)
   (if (not (pair? t-data))
       ; if only one arg, same as echo
       (mkstr t-data)
       (let ((template (car t-data))
	     (data (cdr t-data)))
   ;loop through the template, printing the result as we go
   (bind-exit (return)
      (let*  ((in (open-input-string (mkstr template)))
	      (out (open-output-string))
	      ;a stack to pop the arguments off
	      (data-in-order data)
	      ;pop the next arg if pos is -1, otherwise return the arg at pos
	      (consume (lambda (pos)
			  (cond
			     ((and (= -1 pos) (pair? data-in-order))
			      (let ((v (car data-in-order)))
				 (set! data-in-order (cdr data-in-order))
				 v))
			     ((and (> pos 0) (<= pos (length data)))
			      (list-ref data (- pos 1)))
			     ((zero? pos)
			      (php-warning
			       (format "zero is not a valid argument number in format string ~A"
				       template))
			      (return ""))
			     (else
			      (php-warning
			       (format "not enough arguments for format string ~A, pos: ~A, data ~A"
				       template pos data))
			      (return "")))))

	      ;get an argument as an int
	      (consume-int (lambda (pos)
			      (onum->elong
			       (convert-to-integer (consume pos)))))
; 	      (consume-int (lambda (pos)
; 			      (let ((n (convert-to-number (consume pos))))
; 				 (if (flonum? n)
; 				     (flonum->fixnum n)
; 				     n))))
	      
	      ;get an argument as a float
	      (consume-flonum (lambda (pos)
				 (onum->float
				  (convert-to-float (consume pos)))))
; 	      (consume-flonum (lambda (pos)
; 			      (let ((n (convert-to-number (consume pos))))
; 				 (if (fixnum? n)
; 				     (fixnum->flonum n)
; 				     n))))
	      
	      ;these routines implement the various conversions %d = convert-decimal, etc.
	      (convert-decimal (lambda (pos width padding alignment)
				  (pad-string (elong->string (consume-int pos))
					      width padding alignment)))
	      (convert-binary (lambda (pos width padding alignment)
				 (pad-string (elong->string (consume-int pos) 2)
					     width padding alignment)))
	      (convert-ascii (lambda (pos)
				(integer->char (mkfixnum (consume-int pos)))))
	      (convert-unsigned (lambda (pos)
				   (elong->ustring (consume-int pos))))
	      (convert-float (lambda (form pos width precision padding alignment)
				(let* ((prec (mkfixnum (if (> precision 0)
							   (if (string=? form "f")
							       precision
							       (php-- precision 1))
							   ; default precision
							   6)))
				       (parts (re-string-split #\. ; (string-downcase (cl-format (mkstr "~," prec form) (consume-flonum pos)))
                                                            (if (string=? form "f")
                                                                (onum->string/f (convert-to-float (consume pos)) prec)
                                                                ;; downcase the E and make lose any leading zeros on the exponent
                                                                ;; (the libc printf always uses a double-digit exponent)
                                                                (pregexp-replace "e\\+0"
                                                                                 (string-downcase 
                                                                                  (onum->string/e (convert-to-float (consume pos)) prec))
                                                                                 "e\\+")))))
				   (pad-string (string-append  (car parts) "."
							       (pad-string (cadr parts) prec "0" STR_PAD_RIGHT))
					       width padding alignment))))
	      (convert-octal (lambda (pos)
				(elong->string (consume-int pos) 8)))
	      (convert-string (lambda (pos width precision padding alignment)
				 ; precision can trim a string from the left if set
				 (let ((ps (pad-string (mkstr (consume pos)) width padding alignment)))
				    (if (and (> precision 0)
					     (> (string-length ps) precision))
					(substring ps 0 precision)
					ps))))				 
	      (convert-hex-lower (lambda (pos width padding alignment)
				    (pad-string (string-downcase
						 (elong->string (consume-int pos) 16))
						width padding alignment)))
	      (convert-hex-upper (lambda (pos width padding alignment)
				    (pad-string (string-upcase
						 (elong->string (consume-int pos) 16))
						width padding alignment)))
	      ;call the appropriate conversion based on the letter after the %
	      (conversion-dispatch
	       (lambda (c pos always-sign width precision padding alignment)
		  (case c
		     ((#\d) (convert-decimal pos width padding alignment)) 
		     ((#\b) (convert-binary pos width padding alignment))   
		     ((#\c) (convert-ascii pos))	   
		     ((#\u) (convert-unsigned pos)) 
		     ((#\e) (convert-float "e" pos width precision padding alignment))
		     ((#\f) (convert-float "f" pos width precision padding alignment))
		     ((#\o) (convert-octal pos))	   
		     ((#\s) (convert-string pos width precision padding alignment))   
		     ((#\x) (convert-hex-lower pos width padding alignment))
		     ((#\X) (convert-hex-upper pos width padding alignment))
		     (else (php-warning (format "unknown conversion specifier: %~A" c))
			   (return "")))))

	      ;we use a recursive descent type parser, (without the descent),
	      ;to parse the template.  I'm sure this can be made faster.

	      ;this will hold the 'first' set
	      (first '(start))

	      ;one half of the parser - a context sensitive lexer
 	      (r (regular-grammar ((argnum (: (in (#\1 #\9)) (* digit) #\$))
				   (modifier (in "0 -+'"))
				   (width (: (in (#\1 #\9)) (* digit)))
				   (precision (: "." (+ digit)))
				   (conversion alpha))
		    ((when (member 'start first) (+ (out #\%)))
		     (cons 'text (the-string)))
		    ((when (member 'start first) "%%")
		     (cons 'text "%"))
		    ((when (member 'start first) "%")
		     (cons 'variable "%"))
		    ((when (member 'argnum first) argnum)
		     (cons 'argnum (string->integer (the-substring 0 (- (the-length) 1)))))
		    ((when (member 'modifier first) modifier)
		     (cons 'modifier (the-character)))
		    ((when (member 'pad-char first) (or #\Newline all))
		     (cons 'pad-char (the-character)))
		    ((when (member 'width first) width)
		     (cons 'width (the-fixnum)))
		    ((when (member 'precision first) precision)
		     (cons 'precision (string->integer (the-substring 1 (the-length)))))
		    ((when (member 'conversion first) conversion)
		     (cons 'conversion (the-character)))
		    (else (the-failure)))))

	 ;the other half - context changes and semantic actions
	 (let reset-variables ()
	    (let ((alignment STR_PAD_LEFT)
		  (padding #\space)
		  (always-sign #f)
		  (width -1)
		  (precision -1)
		  (argument-number -1))
	    
	    (do ((toker (read/rp r in)
			(read/rp r in)))
		((eof-object? toker))

		(unless (pair? toker)
		   (php-warning
		    (format "sprintf: Unexpected character '~A' in format string ~A"
			    toker template))
		   (return ""))
;		(print "toker: " toker)
		(case (car toker)
		   ((text) (display (cdr toker) out))
		   ((variable) (set! first '(argnum modifier width precision conversion)))
		   ((argnum) (set! first (remq 'argnum first))
			     (set! argument-number (cdr toker)))
		   ((modifier) (case (cdr toker)
				  ((#\-) (set! alignment STR_PAD_RIGHT))
				  ;space seems to be the default anyway..?
				  ((#\0) (set! padding #\0))
				  ((#\space) (set! padding #\space))
				  ((#\+) (set! always-sign #t))
				  ((#\') (set! first (cons 'pad-char first)))))
		   ((pad-char) (set! first (remq 'pad-char first))
			       (set! padding (cdr toker)))
		   ((width) (set! first '(precision conversion))
			    (set! width (cdr toker)))
		   ((precision) (set! first '(conversion))
				(set! precision (cdr toker)))
		   ((conversion) (set! first '(start))
				 (display
				  (conversion-dispatch (cdr toker) argument-number always-sign
						       width precision (string padding) alignment)
				  out)
				 (reset-variables))))))
	 
	 (get-output-string out))))))


   

; strncasecmp --  Binary safe case-insensitive string comparison of the first n characters
(defbuiltin (strncasecmp str1 str2 max)
   (coerce-to-php-type
    (bind-exit (return)
       (let* ((vstr1 (mkstr str1))
	      (vstr2 (mkstr str2))
	      (len1 (string-length vstr1))
	      (len2 (string-length vstr2))
	      (len (min (mkfixnum max) (min len1 len2))))
	  (let loop ((i len)
		     (sr 0))
	     (when (> i 0)
		(let ((c1 (char-downcase (string-ref vstr1 sr)))
		      (c2 (char-downcase (string-ref vstr2 sr))))
		   (if (not (char=? c1 c2))
		       (return (- (char->integer c1) (char->integer c2))))
		   (loop (- i 1) (+ sr 1)))))
	  (- (min (mkfixnum max) len1) (min (mkfixnum max) len2))))))

; strcasecmp --  Binary safe case-insensitive string comparison
(defbuiltin (strcasecmp str1 str2)
   (coerce-to-php-type
    (bind-exit (return)
       (let* ((vstr1 (mkstr str1))
	      (vstr2 (mkstr str2))
	      (len1 (string-length vstr1))
	      (len2 (string-length vstr2))
	      (len (min len1 len2)))
	  (let loop ((i len)
		     (sr 0))
	     (when (> i 0)
		(let ((c1 (char-downcase (string-ref vstr1 sr)))
		      (c2 (char-downcase (string-ref vstr2 sr))))
		   (if (not (char=? c1 c2))
		       (return (- (char->integer c1) (char->integer c2))))
		   (loop (- i 1) (+ sr 1)))))
	  (- len1 len2)))))
	    

; strcmp -- Binary safe string comparison
(defalias strcmp php-strcmp)
(defbuiltin (php-strcmp str1 str2)
   (convert-to-integer
    (let ((res (strcmp (mkstr str1) (mkstr str2))))
       (cond
	  ((positive? res) 1)
	  ((negative? res) -1)
	  (else 0)))))

; strcoll -- Locale based string comparison
(defalias strcoll php-strcoll)
(defbuiltin (php-strcoll str1 str2)
   (coerce-to-php-type
    (strcoll (mkstr str1) (mkstr str2))))

; strcspn --  Find length of initial segment not matching mask
(defalias strcspn php-strcspn)
(defbuiltin (php-strcspn str1 str2 (start 'unpassed) (len 'unpassed))
   (let ((s1 (mkstr str1))
	 (s2 (mkstr str2)))
      (if (eqv? start 'unpassed)
	  (set! start 0)
	  (set! start (mkfixnum start)))
      (if (< start 0)
	  (set! start 0))
      (if (eqv? len 'unpassed)
	  (set! len (- (string-length s1) start))
	  (set! len (mkfixnum len)))
      (if (or (> start (string-length s1))
	      (> (+ len start) (string-length s1))) 
	  #f
	  (coerce-to-php-type (strcspn (substring s1 start (+ len start)) s2))))  )
;   (strcspn (mkstr str1) (mkstr str2)))

; strip_tags -- Strip HTML and PHP tags from a string

; this could be done better
(define (check-tag allow str)
   ;(print "checktag allow " allow " and " str)
   (let* ((t1 (pregexp-replace "^\\/*([a-zA-Z]+)\s*" str "<\\1>"))
	  (t2 (substring t1 0 (+ (mkfixnum (strpos t1 ">" 0)) 1))))
      (if (not (eqv? (substring-ci? t2 allow) #f))
	  (string-append "<" str ">")
	  "")))

(defbuiltin (strip_tags str (allow-tags ""))
    (let* ((state 'text)
	   (cur-tag "")
	   (in-state (lambda (st)
			(eqv? state st)))
	   (change-state (lambda (newstate)
			    ;(print "switching to state " newstate)
			    (set! state newstate)
			    ""))
	   (rp (regular-grammar ()
 		  ("<?"  (change-state 'code-tag))
 		  ("?>"  (change-state 'text))
 		  ("<!--" (change-state 'comment))
 		  ("-->" (change-state 'text))
		  ( (: "<" (out blank))  (cond ((in-state 'html)
				; woopsie. make cur-tag text instead
				(let ((save-text cur-tag))
				   (set! cur-tag "")
				   (string-append "<" save-text)))
			       (else
				   (begin
				      (change-state 'html)
				      (set! cur-tag (the-substring 1 2))
				      (ignore)
				      ))))
		  (">"   (cond ((in-state 'text) ">")
			       ((in-state 'html) (begin
						    (change-state 'text)
						    (let ((c (check-tag allow-tags cur-tag)))
						       (set! cur-tag "")
						       c)))
			       (else "")))
		  ; only newline when in text
		  (#\Newline (cond ((in-state 'text) (the-string))
				   ((in-state 'html) (begin
							(set! cur-tag
							      (string-append cur-tag (string #\Newline)))
							(ignore))) 
				   (else (ignore))))
		  ; pass the rest through when in text
		  (all   (cond ((in-state 'text) (the-string))
			       ((in-state 'html) (begin (set! cur-tag (string-append cur-tag (the-string))) (ignore)))
			       (else (ignore)))))))
       (append-strings (get-tokens-from-string rp (mkstr str)))))


; stripcslashes --  Un-quote string quoted with addcslashes()
(define *stripcslashes-output-port* #f)
(defbuiltin (stripcslashes astring)
   (unless *stripcslashes-output-port*
      (set! *stripcslashes-output-port* (open-output-string)))
   (let ((len (string-length astring))
	 (out *stripcslashes-output-port*)
	 (octal? (lambda (c)
		    (and (char>=? c #\0)
			 (char<=? c #\7))))
	 (hex? (lambda (c)
		  (or (and (char>=? c #\0) (char<=? c #\7))
		      (and (char>=? c #\a) (char<=? c #\f))
		      (and (char>=? c #\A) (char<=? c #\F)))))
	 (seen-backslash? #f))
      (let loop ((i 0))
	 (when (<fx i len)
	    (let ((c (string-ref astring i)))
	       (if seen-backslash?
		   (begin
		      (set! seen-backslash? #f)
		      (case c
			 ((#\\) (display #\\ out))
			 ((#\a) (display #a007 out))
			 ((#\f) (display #a012 out))
			 ((#\n) (display #\newline out))
			 ((#\r) (display #a013 out))
			 ((#\t) (display #\tab out))
			 ((#\$) (display #\$ out))
			 ((#\{) (display #\{ out))
			 ((#\") (display #\" out))
			 ((#\x) (let loop ((j (+ i 1)))
				   (if (and (< j len)
					    (<= j (+ i 3))
					    (hex? (string-ref astring j)))
				       (loop (+fx j 1))
				       (if (> j (+ i 1))
					   (begin
					      (display (integer->char
							(string->integer
							 (substring astring (+ i 1) j)
							 16))
						       out)
					      (set! i (- j 1)))
					   (display "\\x" out)))))
			 (else (let loop ((j (+ i 1)))
				  (if (and (< j len)
					   (<= j (+ i 3))
					   (octal? (string-ref astring j)))
				      (loop (+fx j 1))
				      (if (> j (+ i 1))
					  (begin
					     (display (integer->char
						       (string->integer
							(substring astring i j)
							8))
						      out)
					     (set! i (- j 1)))
					  (begin
					     ;						(display #\\ out)
					     (display c out))))))))
		   (if (char=? c #\\)
		       (set! seen-backslash? #t)
		       (display c out))))
	    (loop (+fx i 1))))
      ;in case astring ended in a backslash
      (when seen-backslash? (display #\\ out))
      (flush-string-port/bin out)))


; stripslashes --  Un-quote string quoted with addslashes()
(defbuiltin (stripslashes str)
   ; this is a hack of bigloo's list->string to allow for strings
   ; in the list, not just characters. this is because i couldn't
   ; easily get the second character from the first match in the grammar,
   ; i had to get it as a string with the-substring. 
   (let ((list->string (lambda (list)
			  (let* ((len    (length list))
				 (string (make-string len)))
			     (let loop ((i 0)
					(l list))
				(if (=fx i len)
				    string
				    (begin
				       (if (string? (car l))
					   (string-set! string i (string-ref (car l) 0))
					   (string-set! string i (car l)))
				       (loop (+fx i 1) (cdr l)))))))))
      (list->string
       (get-tokens-from-string
	(regular-grammar ()
	   ((: #\\ (out #\\ #\' #\" #\0)) (the-substring 1 2))
	   ((: #\\ #\\) #\\)
	   ((: #\\ #\') #\')
	   ((: #\\ #\") #\")
	   ((: #\\ #\0) #a000)
	   (else (the-failure)))
	(mkstr str)))))


; stristr --  Case-insensitive strstr()
(defbuiltin (stristr haystack needle)
   (set! haystack (mkstr haystack))
   (set! needle (mkstr needle))
   (let ((s-pos (substring-ci? needle haystack)))
      (if (eqv? s-pos #f)
	  #f
	  (substring haystack s-pos (string-length haystack)))))

; strnatcmp --  String comparisons using a "natural order" algorithm
(defalias strnatcmp php-strnatcmp)
(defbuiltin (php-strnatcmp str1 str2)
   (coerce-to-php-type
    (strnatcmp (mkstr str1) (mkstr str2))))

; strnatcasecmp --  Case insensitive string comparisons using a "natural order" algorithm
(defalias strnatcasecmp php-strnatcasecmp)
(defbuiltin (php-strnatcasecmp str1 str2)
   (coerce-to-php-type
    (strnatcasecmp (mkstr str1) (mkstr str2))))

; strncmp --  Binary safe string comparison of the first n characters
(defalias strncmp php-strncmp)
(defbuiltin (php-strncmp str1 str2 len)
   (coerce-to-php-type
    (strncmp (mkstr str1) (mkstr str2) (mkfixnum len))))

(defconstant STR_PAD_RIGHT 0)
(defconstant STR_PAD_LEFT 1)
(defconstant STR_PAD_BOTH 2)

(define (pad-string str len pad pad-type)
   (set! len (mkfixnum (convert-to-number len)))
   (let ((original-len (string-length str)))
      (if (< len original-len)
	  str
	  (let ((pad-string-len (string-length pad))
		(new-string (make-string len))
		(left-pad 0))
	     (cond 
		((php-= pad-type STR_PAD_RIGHT) (set! left-pad 0))
		((php-= pad-type STR_PAD_LEFT) (set! left-pad (- len original-len)))
		((php-= pad-type STR_PAD_BOTH) (set! left-pad (quotient (- len original-len) 2)))
		(else (php-warning
		       (format "unknown pad-type: ~A, padding right." pad-type))
		      (set! left-pad 0)))
	     (let ((right-start (+ left-pad original-len)))
		(let loop ((i 0)  ;new-string index
			   (p 0)) ;pad string index
		   (cond
		      ;on the left and the right, copy from the pad-string
		      ((or (< i left-pad) (and (>= i right-start) (< i len)))
		       (string-set! new-string i (string-ref pad p))
		       (loop (+ i 1) (modulo (+ p 1) pad-string-len)))
		      ;in the middle, blit in the original string
		      ((and (>= i left-pad) (< i right-start))
		       (blit-string! str 0 new-string i original-len)
		       (loop (+ i original-len) 0)))))
	     new-string))))


; str_pad --  Pad a string to a certain length with another string
(defbuiltin (str_pad str len (pad " ") (pad-type STR_PAD_RIGHT))
   (pad-string (mkstr str) len (mkstr pad) pad-type) )		   
				    

; strpos --  Find position of first occurrence of a string
(defbuiltin (strpos haystack needle (offset 'unpassed))
   (set! haystack (mkstr haystack))
   (set! needle (mkstr needle))
   (if (= (string-length needle) 0)
       (begin
	  (php-warning "empty needle")
	  #f)
       (if (eqv? offset 'unpassed)
	   (coerce-to-php-type
	    (substring? needle haystack))
	   (let ((m (substring? needle (substring haystack (mkfixnum offset) (string-length haystack)))))
	      (if (eqv? m #f)
		  #f
		  (php-+ offset m))))))

; stripos
(defbuiltin (stripos haystack needle (offset 'unpassed))
   (set! haystack (mkstr haystack))
   (set! needle (mkstr needle))
   (if (= (string-length needle) 0)
       (begin
	  (php-warning "empty needle")
	  #f)
       (if (eqv? offset 'unpassed)
	   (substring-ci? needle haystack)
	   (let ((m (substring-ci? needle (substring haystack (mkfixnum offset) (string-length haystack)))))
	      (if (eqv? m #f)
		  #f
		  (php-+ offset m))))))

; str_repeat -- Repeat a string
(defbuiltin (str_repeat str iter)
   (set! str (mkstr str))
   (let loop ((i (convert-to-number iter))
	      (new-str ""))
      (if (php-> i 0)
	  (loop (php-- i 1) (string-append new-str str))
	  new-str)))

; strrev -- Reverse a string
(defbuiltin (strrev str)
   (list->string (reverse (string->list (mkstr str)))))

(define (do-strrpos h n pred)
   (bind-exit (return)
      (let ((real-needle (string-ref (mkstr n) 0)))
	 (let loop ((c 1)
		    (rstr (reverse (string->list (mkstr h)))))
	    (if (pair? rstr)
		(begin 
		   (if (pred (car rstr) real-needle)
		       (return (- (string-length h) c)))
		   (loop (+ c 1) (cdr rstr)))
		#f)))))

; strrpos --  Find position of last occurrence of a char in a string
(defbuiltin (strrpos haystack needle)
   (coerce-to-php-type
    (do-strrpos haystack needle char=?)))
   
; strripos
(defbuiltin (strripos haystack needle)
   (coerce-to-php-type
    (do-strrpos haystack needle (lambda (a b)
				   (char=? (char-upcase a)
					   (char-upcase b))))))

; strspn --  Find length of initial segment matching mask
(defalias strspn php-strspn)
(defbuiltin (php-strspn str1 str2 (start 'unpassed) (len 'unpassed))
   (let ((s1 (mkstr str1))
	 (s2 (mkstr str2)))
      (if (eqv? start 'unpassed)
	  (set! start 0)
	  (set! start (mkfixnum start)))
      (if (< start 0)
	  (set! start 0))
      (if (eqv? len 'unpassed)
	  (set! len (- (string-length s1) start))
	  (set! len (mkfixnum len)))
      (if (or (> start (string-length s1))
	      (> (+ len start) (string-length s1))) 
	  #f
	  (coerce-to-php-type (strspn (substring s1 start (+ len start)) s2)))))

; strchr --  Find the first occurrence of a character
(defalias strchr strstr)

; strstr -- Find first occurrence of a string
(defbuiltin (strstr haystack needle)
   (set! haystack (mkstr haystack))
   (set! needle (maybe-int->char-str needle))
   (if (= (string-length needle) 0)
       (begin
	  (php-warning "empty needle")
	  #f)
       (let ((s-pos (substring? needle haystack)))
	  (if (eqv? s-pos #f)
	      #f
	      (coerce-to-php-type
	       (substring haystack s-pos (string-length haystack)))))))

; (define (string-reverse str)
;    (let* ((len (string-length str))
;           (new-string (make-string len)))
;       (let loop ((i 0))
;          (if (< i len)
;              (begin
;                 (string-set! new-string i (string-ref str (- len i 1)))
;                 (loop (+ i 1)))
;              new-string))))

; strrchr --  Find the last occurrence of a character
(defbuiltin (strrchr haystack needle)
   (let ((haystack (mkstr haystack))
         (needle (maybe-int->char-str needle)))
      (if (zero? (string-length needle))
          (php-warning "empty needle")
          (let ((len (string-length haystack))
                (chr (string-ref needle 0)))
             (let loop ((i (- len 1)))
                (if (< i 0)
                    FALSE
                    (if (char=? chr (string-ref haystack i))
                        (substring haystack i len)
                        (loop (- i 1)))))))))


; strtok -- Tokenize string

; wackyness
(define *cur-strtok-str* "")
(define *cur-strtok-tok* "")
(defbuiltin (strtok arg1 (arg2 'unpassed))
   ;(print "called with arg1 " arg1 " and arg2 " arg2)
   ; if both arguments are passed, reset
   (unless (eqv? arg2 'unpassed)
      (set! *cur-strtok-str* arg1)
      (set! *cur-strtok-tok* ""))
   (let ((delim-list (string->list (if (eqv? arg2 'unpassed)
				       arg1
				       arg2)))
	 (earliest-match (+ (string-length *cur-strtok-str*) 1)))
      ; loop through each character in token and find first match in string
      (for-each (lambda (v)
		   ;(print "checking " *cur-strtok-str* " for delim [" v "]")
		   (let ((idx (string-index *cur-strtok-str* (mkstr v))))
		      (when idx
			 (if (< idx earliest-match)
			     (set! earliest-match idx)))))
		delim-list)
      ; get earliest match, or return #f if no match
      (if (> earliest-match (string-length *cur-strtok-str*))
	  ; not found. if something in str, return it, otherwise #f
	  (if (string=? *cur-strtok-str* "")
	      #f
	      (let ((oval *cur-strtok-str*)) 
		 (set! *cur-strtok-str* "")
		 oval))
	  ; found, return latest token
	  (begin
	     (set! *cur-strtok-tok* (substring *cur-strtok-str*
					       0
					       earliest-match))
	     (set! *cur-strtok-str* (substring *cur-strtok-str*
					       (+ earliest-match 1)
					       (string-length *cur-strtok-str*)))
	     ; if token is blank, call again
	     (if (string=? *cur-strtok-tok* "")
		 (strtok (if (eqv? arg2 'unpassed) arg1 arg2) 'unpassed)
		 *cur-strtok-tok*)))))
   
; str_replace --  Replace all occurrences of the search string with the replacement string
; return a list extracted from s/r hashes to hand to string-subst
(define (get-sr-list s r)
   (php-hash-reset s)
   (if (php-hash? r)
       (php-hash-reset r))
   (let loop ((a-list (list))
	      (s-hash s)
	      (r-hash r))
      (if (php-hash-has-current? s-hash)
	  (begin
	     (set! a-list (append a-list (list (container-value (cdr (php-hash-current s-hash))))))
	     (if (php-hash? r-hash)
		 (if (php-hash-has-current? r-hash)
		     (begin 
			(set! a-list (append a-list (list (container-value (cdr (php-hash-current r-hash))))))
			(php-hash-advance r-hash))
		     (set! a-list (append a-list (list ""))))		 
		 (set! a-list (append a-list (list r-hash)))) ; assumed string
	     (php-hash-advance s-hash)
	     (loop a-list s-hash r-hash))
	  a-list)))

(defbuiltin (str_shuffle str)
   (let* ((sstr (mkstr str))
	  (vsize (string-length sstr))
	  (vec (list->vector (string->list sstr))))
      (let loop ((i 0))
	 (when (< i (- vsize 1))
	    (let ((j (+ i (mkfixnum (mt_rand 0 (+ (- vsize i) 1))))))
	       (vector-swap! vec i j)
	       (loop (+ i 1)))))
      (list->string (vector->list vec))))

(defbuiltin (str_replace search replace subj)
   (if (php-hash? search)
       (apply string-subst (append (list (mkstr subj)) (get-sr-list search replace)))
       (string-subst (mkstr subj) (mkstr search) (mkstr replace))))

;; two variables that we'll lazily initialize and reuse to make things
;; go a little faster.
(define *strtr-string-port* #f)
(define *strtr-identity-translation* #f)
(define *strtr-scratch-translation* #f)
(defbuiltin (strtr str from (to 'unpassed))
   (let ((strtr-strings
	  ;; three argument case
	  ;; this is about twice as long as it needs to be, for performance.
	  (lambda (str from to)
	     ;; lazily initialize the identity translation vector
	     (unless *strtr-identity-translation*
		(set! *strtr-identity-translation* 
		      (let ((trans (make-string 256)))
			 (dotimes (i 256)
			    (string-set! trans i (integer->char i)))
			 trans))
		(set! *strtr-scratch-translation* (make-string 256)))
	     ;; refresh our scratch translation vector
	     (blit-string! *strtr-identity-translation*
			   0
			   *strtr-scratch-translation*
			   0
			   256)
	     (let ((trans *strtr-scratch-translation*))
		;; setup the translation vector
		(dotimes (i (min (string-length from) (string-length to)))
		   (string-set! trans
				(char->integer (string-ref from i))
				(string-ref to i)))
		;; this is the actual translation, the part we've all
		;; been waiting for...
		(let ((retval (string-copy str)))
		   (dotimes (i (string-length retval))
		      (string-set! retval i
				   (string-ref trans (char->integer
						      (string-ref str i)))))
		   (dotimes (i (min (string-length from) (string-length to)))
		      (string-set! trans
				   (char->integer (string-ref from i))
				   (integer->char i)))
		   retval))))
	 (strtr-array
	  ;; two argument case (from must be a hash)
	  (lambda (str translations)
	     (unless *strtr-string-port*
		(set! *strtr-string-port* (open-output-string)))
	     (let ((keys-longest-to-shortest
		    (sort (php-hash-keys->list translations)
			  (lambda (a b)
			     (> (string-length a) (string-length b))))))
		(let loop ((i 0))
		   (when (< i (string-length str))
		      ;; loop over the translations from longest to shortest
		      (let liip ((key (gcar keys-longest-to-shortest))
				 (keys (gcdr keys-longest-to-shortest)))			    
			 (cond
			    ((null? key)
			     ;; no match found
			     (display (string-ref str i) *strtr-string-port*)
			     (loop (+ i 1)))
			    ((substring-at? str key i)
			     ;; translation found
			     (display (mkstr (php-hash-lookup translations key))
				      *strtr-string-port*)
			     (loop (+ i (string-length key))))
			    (else
			     ;; try the next shorter translation
			     (liip (gcar keys) (gcdr keys))))))))
	     (flush-string-port/bin *strtr-string-port*))))
      ;; process arguments
      (let ((str (mkstr str)))
	 (if (eqv? to 'unpassed)
	     (if (php-hash? from)
		 (strtr-array str from)
		 (php-warning "The second argument is not an array."))
	     (strtr-strings str (mkstr from) (mkstr to))))))


; substr_count -- Count the number of substring occurrences
(defbuiltin (substr_count haystack needle)
   (set! haystack (mkstr haystack))
   (set! needle (mkstr needle))
   (if (string=? needle "")
       (begin
	  (php-warning "empty substring")
	  #f)
       (let ((count 0)
	     (h-len (string-length haystack))
	     (n-len (string-length needle)))
	  (let loop ((i (substring? needle haystack))
		     (offset 0))
	     (if (not (eqv? i #f))
		 (begin
		    (set! count (+ count 1))
		    (loop (substring? needle (substring haystack (+ i n-len offset) h-len)) (+ i n-len offset)))
		 (convert-to-number count))))))

; substr_replace -- Replace text within a portion of a string
(define (get-sub-start str start)
   (cond ((< start 0) (let ((s (- (string-length str) (abs start))))
			 (if (< s 0) 0 s)))
	 ((> start (string-length str)) #f)
	 (else start)))

(define (get-sub-end str start end)
   (when start
      (cond ((< end 0) (let ((s (- (string-length str) (abs end))))
			 (if (< s 0) 0 s)))
	    ((> start end) #f)
	    ((> end (string-length str)) (string-length str))
	    (else end))))

(defbuiltin (substr_replace str replace start (len 'unpassed))
   (set! str (mkstr str))
   (when (eqv? len 'unpassed) (set! len (string-length str)))
   (let* ((s1 (get-sub-start str (mkfixnum start)))
	  (s2 (get-sub-end str s1 (mkfixnum len))))
      (if (and s1 s2)
	  (string-append (substring str 0 s1)
			 (mkstr replace)
			 (substring str s2 (string-length str)))
	  str)))

; ucfirst -- Make a string's first character uppercase
(defbuiltin (ucfirst str)
   (set! str (mkstr str))
   (if (> (string-length str) 0)
       (string-append (string (char-upcase (string-ref str 0))) (substring str 1 (string-length str)))
       ""))

; version_compare --  Compares two "PHP-standardized" version number strings
; ugly
(define (clean-version ver)
   (let ((cver ver))
      ;(print "before cleanup is " cver)
      (set! cver (pregexp-replace* "[\\_\\-\\+]" cver "\\."))
      (set! cver (pregexp-replace* "([^0-9\\.])(\\d)" cver "\\1\\.\\2"))
      (set! cver (pregexp-replace* "(\\d)([^0-9\\.])" cver "\\1\\.\\2"))
      ;(print "after cleanup is " cver)
      (list->vector (pregexp-split "\\." cver))))

(define (get-ver-val a)
   (if (string? a)
       (cond ((string=? a "dev") 0)
	     ((or (string=? a "alpha")
		  (string=? a "a")) 1)
	     ((or (string=? a "beta")
		  (string=? a "b")) 2)
	     ((string=? a "RC") 3)
	     ((string=? a "#") 4)
	     ((or (string=? a "pl")
		  (string=? a "p")) 5)
	     (else 0))
       0))

(define (do-v-compare ver1 ver2)
   (let* ((vec1 (clean-version (mkstr ver1)))
	  (vec2 (clean-version (mkstr ver2)))
	  (v1l (vector-length vec1))
	  (v2l (vector-length vec2))
	  (at-most (min v1l v2l))
	  (compare-string-version (lambda (a b)
				     (php-- (get-ver-val a) (get-ver-val b)))))
      ;(print "lengths 1 " v1l " 2 " v2l) 
      (let loop ((i 0)
		 (cval 0))
	 ;(print "looping i is " i)
	 (if (and (< i at-most)
		  (php-= cval 0))
	     (let ((a (vector-ref vec1 i))
		   (b (vector-ref vec2 i)))
		;(print "a is " a " b is " b)
		(cond ((and (numeric-string? a) 
			    (numeric-string? b)) (set! cval (php-- (convert-to-number a)
								   (convert-to-number b))))
		      (else (set! cval (compare-string-version a b))))
		(loop (+ i 1) cval))
	     ; matched all we can
	     (begin
		;(print "cval is " cval)
		; if different lengths and cval is 0 ... 
		(when (and (not (= v1l v2l))
			   (php-= cval 0))  
		   (if (= i v1l)
		       ; v2 longer than v1
		       (begin
			;(print "differing lengths, checking " (vector-ref vec2 i) " from v2")
			(cond ((numeric-string? (vector-ref vec2 i)) (set! cval -1))
			      ; the only text greater than a number "patch level"
			      ((string=? (vector-ref vec2 i) "pl") (set! cval -1))
			      (else (set! cval 1))))
			; v1 longer than v2
			(begin
			 ;(print "differing lengths, checking " (vector-ref vec1 i) " from v1")
			 (cond ((numeric-string? (vector-ref vec1 i)) (set! cval 1))
			       ; the only text greater than a number "patch level"
			       ((string=? (vector-ref vec1 i) "pl") (set! cval 1))
			       (else (set! cval -1))))))
		; same length or set cval from different lengths
		(cond ((php-= cval 0) 0)
		      ((php-< cval 0) -1)
		      (else 1)))))))

(defbuiltin (version_compare ver1 ver2 (op 'unpassed))
   (let ((sop (if (not (eqv? op 'unpassed)) (mkstr op) "unpassed")) 
	 (rval (do-v-compare ver1 ver2)))
      ;(print "rval is " rval " sop is " sop)
      (cond ((or (string=? sop "<")
		 (string=? sop "lt")) (= rval -1))
	    ((or (string=? sop "<=")
		 (string=? sop "le")) (not (= rval 1)))
	    ((or (string=? sop ">")
		 (string=? sop "gt")) (= rval 1))
	    ((or (string=? sop ">=")
		 (string=? sop "ge")) (not (= rval -1)))
	    ((or (string=? sop "==")
		 (string=? sop "=")
		 (string=? sop "eq")) (= rval 0))
	    ((or (string=? sop "!=")
		 (string=? sop "<>")
		 (string=? sop "ne")) (not (= rval 0)))
	    (else rval))))
   
; vprintf -- Output a formatted string
(defbuiltin (vprintf format args)
   (when (php-hash? args)
      (echo (apply sprintf (append (list (mkstr format)) (php-hash->list args))))))
	     
; vsprintf -- Return a formatted string
(defbuiltin (vsprintf format args)
   (when (php-hash? args)
      (apply sprintf (append (list (mkstr format)) (php-hash->list args)))))

(define (internal-rtrim str)
   (rtrim str (list #a032 #a009 #a010 #a013 #a000 #a011)))

; wordwrap --  Wraps a string to a given number of characters using a string break character.
(defbuiltin (wordwrap str (width 75) (break #\newline) (cut 0))
   (let ((width (max 1 (- (mkfixnum width) 1)))
	 (break (let ((breakstr (mkstr break)))
		   (if (= 0 (string-length breakstr))
		       #\newline
		       (string-ref breakstr 0))))
	 (cut? (if (= 1 (mkfixnum cut))
		   #t
		   #f)))
      (with-output-to-string
	 (lambda ()
	    (let loop ((str (mkstr str)) (len (string-length str)))
;	       (fprintf (current-error-port) (mkstr "loop: str = " str " len = " len "\n"))
	       (cond ((> len width)
		      (let inner-loop ((str-index width))
;			 (fprintf (current-error-port) (mkstr "inner loop: str-index = " str-index "\n"))
			 (cond ((< str-index 0) ; we've walked to whole string backward and there are no spaces
				(cond (cut?
				       ;; cut it
				       (let* ((width+1 (+ 1 width))
					      (newlen (- len width+1)))
					  (display (internal-rtrim (substring str 0 width+1)))
					  (when (< 0 newlen)
					     (display break))
					  (loop (substring str width+1 len) newlen)))
				      (else
				       ;; find the next space and break there
				       (let 2nd-inner-loop ((str-index (+ 1 width)))
					  (cond ((>= str-index len)
						 (display str))
						((char=? (string-ref str str-index) #\space)
						 (let ((str-index-plus-1 (+ 1 str-index)))
						    (display (internal-rtrim (substring str 0 str-index-plus-1)))
						    (display break)
						    (loop (substring str str-index-plus-1 len) (- len str-index-plus-1))))
						(else (2nd-inner-loop (+ str-index 1))))))))
			       ((char=? (string-ref str str-index) #\space)
				;; found a space so break here
				(let ((str-index-plus-1 (+ 1 str-index)))
				   (display (internal-rtrim (substring str 0 str-index-plus-1)))
				   (display break)
				   (loop (substring str str-index-plus-1 len) (- len str-index-plus-1))))
			       (else (inner-loop (- str-index 1))))))
		     ((> len 0)
		      (display str))))))))


		   
		       
; nl_langinfo --  Query language and locale information

;for addcslashes
(define c-translation-table
   '#("\\000" "\\001" "\\002" "\\003" "\\004" "\\005" "\\006" "\\007"
      "\\b" "\\t" "\\n" "\\v" "\\f" "\\r" "\\016" "\\017"
      "\\020" "\\021" "\\022" "\\023" "\\024" "\\025" "\\026" "\\027"
      "\\030" "\\031" "\\032" "\\033" "\\034" "\\035" "\\036" "\\037"
      	      
      "\\ " "\\!" "\\\"" "\\#" "\\$" "\\%" "\\&" "\\'" 
      "\\(" "\\)" "\\*" "\\+" "\\," "\\-" "\\." "\\/" "\\0" "\\1" 
      "\\2" "\\3" "\\4" "\\5" "\\6" "\\7" "\\8" "\\9" "\\:" "\\;" 
      "\\<" "\\=" "\\>" "\\?" "\\@" "\\A" "\\B" "\\C" "\\D" "\\E" 
      "\\F" "\\G" "\\H" "\\I" "\\J" "\\K" "\\L" "\\M" "\\N" "\\O" 
      "\\P" "\\Q" "\\R" "\\S" "\\T" "\\U" "\\V" "\\W" "\\X" "\\Y" 
      "\\Z" "\\[" "\\\\" "\\]" "\\^" "\\_" "\\`" "\\a" "\\b" "\\c" 
      "\\d" "\\e" "\\f" "\\g" "\\h" "\\i" "\\j" "\\k" "\\l" "\\m" 
      "\\n" "\\o" "\\p" "\\q" "\\r" "\\s" "\\t" "\\u" "\\v" "\\w" 
      "\\x" "\\y" "\\z" "\\{" "\\|" "\\}" "\\~"
      
      "\\177" "\\200" "\\201" 
      "\\202" "\\203" "\\204" "\\205" "\\206" "\\207" "\\210" "\\211"
      "\\212" "\\213" "\\214" "\\215" "\\216" "\\217" "\\220" "\\221"
      "\\222" "\\223" "\\224" "\\225" "\\226" "\\227" "\\230" "\\231"
      "\\232" "\\233" "\\234" "\\235" "\\236" "\\237" "\\240" "\\241"
      "\\242" "\\243" "\\244" "\\245" "\\246" "\\247" "\\250" "\\251" 
      "\\252" "\\253" "\\254" "\\255" "\\256" "\\257" "\\260" "\\261"
      "\\262" "\\263" "\\264" "\\265" "\\266" "\\267" "\\270" "\\271"
      "\\272" "\\273" "\\274" "\\275" "\\276" "\\277" "\\300" "\\301"
      "\\302" "\\303" "\\304" "\\305" "\\306" "\\307" "\\310" "\\311"
      "\\312" "\\313" "\\314" "\\315" "\\316" "\\317" "\\320" "\\321"
      "\\322" "\\323" "\\324" "\\325" "\\326" "\\327" "\\330" "\\331"
      "\\332" "\\333" "\\334" "\\335" "\\336" "\\337" "\\340" "\\341"
      "\\342" "\\343" "\\344" "\\345" "\\346" "\\347" "\\350" "\\351"
      "\\352" "\\353" "\\354" "\\355" "\\356" "\\357" "\\360" "\\361"
      "\\362" "\\363" "\\364" "\\365" "\\366" "\\367" "\\370" "\\371" 
      "\\372" "\\373" "\\374" "\\375" "\\376" "\\377" ))


;this one's bs except for a few positions
(define normal-translation-table
   '#("\\0" "\\001" "\\002" "\\003" "\\004" "\\005" "\\006" "\\007"
      "\\b" "\\t" "\\n" "\\v" "\\f" "\\r" "\\016" "\\017"
      "\\020" "\\021" "\\022" "\\023" "\\024" "\\025" "\\026" "\\027"
      "\\030" "\\031" "\\032" "\\033" "\\034" "\\035" "\\036" "\\037"
      	      
      "\\ " "\\!" "\\\"" "\\#" "\\$" "\\%" "\\&" "\\'" 
      "\\(" "\\)" "\\*" "\\+" "\\," "\\-" "\\." "\\/" "\\0" "\\1" 
      "\\2" "\\3" "\\4" "\\5" "\\6" "\\7" "\\8" "\\9" "\\:" "\\;" 
      "\\<" "\\=" "\\>" "\\?" "\\@" "\\A" "\\B" "\\C" "\\D" "\\E" 
      "\\F" "\\G" "\\H" "\\I" "\\J" "\\K" "\\L" "\\M" "\\N" "\\O" 
      "\\P" "\\Q" "\\R" "\\S" "\\T" "\\U" "\\V" "\\W" "\\X" "\\Y" 
      "\\Z" "\\[" "\\\\" "\\]" "\\^" "\\_" "\\`" "\\a" "\\b" "\\c" 
      "\\d" "\\e" "\\f" "\\g" "\\h" "\\i" "\\j" "\\k" "\\l" "\\m" 
      "\\n" "\\o" "\\p" "\\q" "\\r" "\\s" "\\t" "\\u" "\\v" "\\w" 
      "\\x" "\\y" "\\z" "\\{" "\\|" "\\}" "\\~"
      
      "\\177" "\\200" "\\201" 
      "\\202" "\\203" "\\204" "\\205" "\\206" "\\207" "\\210" "\\211"
      "\\212" "\\213" "\\214" "\\215" "\\216" "\\217" "\\220" "\\221"
      "\\222" "\\223" "\\224" "\\225" "\\226" "\\227" "\\230" "\\231"
      "\\232" "\\233" "\\234" "\\235" "\\236" "\\237" "\\240" "\\241"
      "\\242" "\\243" "\\244" "\\245" "\\246" "\\247" "\\250" "\\251" 
      "\\252" "\\253" "\\254" "\\255" "\\256" "\\257" "\\260" "\\261"
      "\\262" "\\263" "\\264" "\\265" "\\266" "\\267" "\\270" "\\271"
      "\\272" "\\273" "\\274" "\\275" "\\276" "\\277" "\\300" "\\301"
      "\\302" "\\303" "\\304" "\\305" "\\306" "\\307" "\\310" "\\311"
      "\\312" "\\313" "\\314" "\\315" "\\316" "\\317" "\\320" "\\321"
      "\\322" "\\323" "\\324" "\\325" "\\326" "\\327" "\\330" "\\331"
      "\\332" "\\333" "\\334" "\\335" "\\336" "\\337" "\\340" "\\341"
      "\\342" "\\343" "\\344" "\\345" "\\346" "\\347" "\\350" "\\351"
      "\\352" "\\353" "\\354" "\\355" "\\356" "\\357" "\\360" "\\361"
      "\\362" "\\363" "\\364" "\\365" "\\366" "\\367" "\\370" "\\371" 
      "\\372" "\\373" "\\374" "\\375" "\\376" "\\377" ))

; only important ones are from 160 on is plus <>&"'
(define iso8859-1-translation-table
   '#("\\0" "\\001" "\\002" "\\003" "\\004" "\\005" "\\006" "\\007"
      "\\b" "\\t" "\\n" "\\v" "\\f" "\\r" "\\016" "\\017"
      "\\020" "\\021" "\\022" "\\023" "\\024" "\\025" "\\026" "\\027"
      "\\030" "\\031" "\\032" "\\033" "\\034" "\\035" "\\036" "\\037"
      	      
      "\\ " "\\!" "&quot;" "\\#" "\\$" "\\%" "&amp;" "&#039;" 
      "\\(" "\\)" "\\*" "\\+" "\\," "\\-" "\\." "\\/" "\\0" "\\1" 
      "\\2" "\\3" "\\4" "\\5" "\\6" "\\7" "\\8" "\\9" "\\:" "\\;" 
      "&lt;" "\\=" "&gt;" "\\?" "\\@" "\\A" "\\B" "\\C" "\\D" "\\E" 
      "\\F" "\\G" "\\H" "\\I" "\\J" "\\K" "\\L" "\\M" "\\N" "\\O" 
      "\\P" "\\Q" "\\R" "\\S" "\\T" "\\U" "\\V" "\\W" "\\X" "\\Y" 
      "\\Z" "\\[" "\\\\" "\\]" "\\^" "\\_" "\\`" "\\a" "\\b" "\\c" 
      "\\d" "\\e" "\\f" "\\g" "\\h" "\\i" "\\j" "\\k" "\\l" "\\m" 
      "\\n" "\\o" "\\p" "\\q" "\\r" "\\s" "\\t" "\\u" "\\v" "\\w" 
      "\\x" "\\y" "\\z" "\\{" "\\|" "\\}" "\\~"
      
      "\\177" "\\200" "\\201" 
      "\\202" "\\203" "\\204" "\\205" "\\206" "\\207" "\\210" "\\211"
      "\\212" "\\213" "\\214" "\\215" "\\216" "\\217" "\\220" "\\221"
      "\\222" "\\223" "\\224" "\\225" "\\226" "\\227" "\\230" "\\231"
      "\\232" "\\233" "\\234" "\\235" "\\236" "\\237"
        "&nbsp;" "&iexcl;" "&cent;" "&pound;" "&curren;" "&yen;" "&brvbar;"
	"&sect;" "&uml;" "&copy;" "&ordf;" "&laquo;" "&not;" "&shy;" "&reg;"
	"&macr;" "&deg;" "&plusmn;" "&sup2;" "&sup3;" "&acute;" "&micro;"
	"&para;" "&middot;" "&cedil;" "&sup1;" "&ordm;" "&raquo;" "&frac14;"
	"&frac12;" "&frac34;" "&iquest;" "&Agrave;" "&Aacute;" "&Acirc;"
	"&Atilde;" "&Auml;" "&Aring;" "&AElig;" "&Ccedil;" "&Egrave;"
	"&Eacute;" "&Ecirc;" "&Euml;" "&Igrave;" "&Iacute;" "&Icirc;"
	"&Iuml;" "&ETH;" "&Ntilde;" "&Ograve;" "&Oacute;" "&Ocirc;" "&Otilde;"
	"&Ouml;" "&times;" "&Oslash;" "&Ugrave;" "&Uacute;" "&Ucirc;" "&Uuml;"
	"&Yacute;" "&THORN;" "&szlig;" "&agrave;" "&aacute;" "&acirc;"
	"&atilde;" "&auml;" "&aring;" "&aelig;" "&ccedil;" "&egrave;"
	"&eacute;" "&ecirc;" "&euml;" "&igrave;" "&iacute;" "&icirc;"
	"&iuml;" "&eth;" "&ntilde;" "&ograve;" "&oacute;" "&ocirc;" "&otilde;"
	"&ouml;" "&divide;" "&oslash;" "&ugrave;" "&uacute;" "&ucirc;"
	"&uuml;" "&yacute;" "&thorn;" "&yuml;" ))

(define iso8859-1-bit-table
   '#(   #f #f #f #f #f #f #f #f #f #f
	 #f #f #f #f #f #f #f #f #f #f
	 #f #f #f #f #f #f #f #f #f #f
	 #f #f #f #f #t ; 34/35 is double quote

	 #f #f #f #t ; 38/39 is amp
	 #f ; 39/40 is single quote, off by default
	 
	 #f #f #f #f #f #f #f #f #f #f
	 #f #f #f #f #f #f #f #f #f #f
	 
	 #t #f #t ; 60/61, 62/63 are < >

	 #f #f #f #f #f #f #f
	 
	 #f #f #f #f #f #f #f #f #f #f
	 #f #f #f #f #f #f #f #f #f #f
	 #f #f #f #f #f #f #f #f #f #f
	 #f #f #f #f #f #f #f #f #f #f
	 #f #f #f #f #f #f #f #f #f #f
	 #f #f #f #f #f #f #f #f #f #f
	 #f #f #f #f #f #f #f #f #f #f
	 #f #f #f #f #f #f #f #f #f #f
	 #f #f #f #f #f #f #f #f #f #f

	 ; 160+ are always on
	 #t #t #t #t #t #t #t #t #t #t
	 #t #t #t #t #t #t #t #t #t #t
	 #t #t #t #t #t #t #t #t #t #t
	 #t #t #t #t #t #t #t #t #t #t
	 #t #t #t #t #t #t #t #t #t #t
	 #t #t #t #t #t #t #t #t #t #t
	 #t #t #t #t #t #t #t #t #t #t
	 #t #t #t #t #t #t #t #t #t #t
	 #t #t #t #t #t #t #t #t #t #t
	 #t #t #t #t #t #t))



(define (make-char-set bag)
   "Parse ranges, like 'a..b', and individual chars, and return a
   vector of 256 booleans representing the set.  This, of course, is
   an ascii only i18n nightmare."
   ;start out with no characters in the set
   (let ((char-set (make-vector 256 #f))
	 (len (string-length bag)))
      (let loop ((i 0))
	 (when (< i len)
	    ;; if there's enough space for an a..b to fit
	    (if (and (< (+ i 3) len)
		     ;; and there are a pair of dots
		     (char=? (string-ref bag (+ i 1)) #\.)
		     (char=? (string-ref bag (+ i 2)) #\.)
		     ;; and the end is greater than the beginning
		     (char<=? (string-ref bag i) (string-ref bag (+ i 3))))
		;; then put all of the chars in the range into the set and loop
		(let ((range-start (char->integer (string-ref bag (+ i 0))))
		      (range-end (char->integer (string-ref bag (+ i 3)))))
		   (do ((i range-start (+ i 1)))
		       ((> i range-end))
		       (vector-set! char-set i #t))
		   (loop (+ i 3)))
		;; if there's no a..b, just put the first char in the set and loop
		(begin
		   (vector-set! char-set (char->integer (string-ref bag i)) #t)
		   (loop (+ i 1))))))
      ;; return the populated char set
      char-set))


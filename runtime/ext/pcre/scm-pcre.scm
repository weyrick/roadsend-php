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
(module php-pcre
   (include "../phpoo-extension.sch")
;   (library common)
   (library profiler)
   (import (pcre-c-bindings "c-bindings.scm"))
;   (use (driver "../../../compiler/driver.scm"))
   ;this is too hairy
   (library phpeval)
   ; exports
   (export
    PREG_OFFSET_CAPTURE
    PREG_PATTERN_ORDER
    PREG_SET_ORDER
    PREG_SPLIT_NO_EMPTY
    PREG_SPLIT_DELIM_CAPTURE
    PREG_SPLIT_OFFSET_CAPTURE
    (init-php-pcre-lib)
    (preg_replace pattern replacement subject limit)
    (preg_replace_callback pattern callback subject limit)
    (preg_match pattern subject match-hash flags)
    (preg_match_all pattern subject match-hash flags)
    (preg_quote subject delim)
    (preg_grep pattern input-hash)
    (preg_split pattern subject limit flags)))


; magical init routine
(define (init-php-pcre-lib)
   1)

; tell the PCRE library to use the BOEHM routines
; for malloc
(pcc-pcre-setup)

; register the extension
(register-extension "pcre" "1.0.0"
                    "php-pcre" '("-lpcre")
                    required-extensions: '("compiler"))

;
; STRUCTURES
;

; for caching compiled regexs
(define-struct compiled-regex
   (re *null-pcre*)
   (extra *null-pcre-extra*)
   (eval-replacement #f))

;
; GLOBALS
;

; for storing compiled regexs
(define *compiled-regexs* (make-hashtable))

;
; CONSTANTS
;

;; flags for builtins
;; We define the +...+ variables for the flags because we
;; want to use the fixnum values for non-consing operations
;; later. (Instead of the onum values).
(define +preg-pattern-order+ 1)
(defconstant PREG_PATTERN_ORDER +preg-pattern-order+)

(define +preg-set-order+ (bit-lsh 1 1))
(defconstant PREG_SET_ORDER +preg-set-order+)

(define +preg-offset-capture+ (bit-lsh 1 2))
(defconstant PREG_OFFSET_CAPTURE +preg-offset-capture+)

(define +preg-split-no-empty+ 1)
(defconstant PREG_SPLIT_NO_EMPTY +preg-split-no-empty+)

(define +preg-split-delim-capture+ (bit-lsh 1 1))
(defconstant PREG_SPLIT_DELIM_CAPTURE +preg-split-delim-capture+)

(define +preg-split-offset-capture+ (bit-lsh 1 2))
(defconstant PREG_SPLIT_OFFSET_CAPTURE +preg-split-offset-capture+)
   
;
; BUILTINS
;

; preg_match
; returns 0 or 1, since it can only match at most once
(defbuiltin (preg_match pattern subject ((ref . match-hash) 'unpassed) (flags 0))
   (preg-match-exec pattern subject
		    (if (container? match-hash)
			match-hash
			#f)
		    (mkfixnum flags) #f))

; preg_match_all
; return number of times matched
(defbuiltin (preg_match_all pattern subject ((ref . match-hash) 'unpassed) (flags 0))
   (preg-match-exec pattern subject
		    (if (container? match-hash)
			match-hash
			#f)
		    (mkfixnum flags) #t))

; preg_replace
; return string with replacements swapped in
(defbuiltin (preg_replace pattern replacement subject (limit -1))
   (if (php-hash? subject)
       ; call for each entry in subject, return a hash
       (let ((result-hash (make-php-hash)))
	  (php-hash-for-each subject
			     (lambda (key val)
				(php-hash-insert! result-hash :next (preg-replace-exec pattern replacement val (mkfixnum limit) #f))))
	  result-hash)
       ; single
       (preg-replace-exec pattern replacement subject (mkfixnum limit) #f)))

; preg_replace_callback
; return string with replacements swapped in, using a callback
(defbuiltin (preg_replace_callback pattern callback subject (limit -1))
   (if (php-hash? subject)
       ; call for each entry in subject, return a hash
       (let ((result-hash (make-php-hash)))
	  (php-hash-for-each subject
			     (lambda (key val)
				(php-hash-insert! result-hash :next (preg-replace-exec pattern callback val (mkfixnum limit) #t))))
	  result-hash)
       ; single
       (preg-replace-exec pattern callback subject (mkfixnum limit) #t)))

; preg_split
(defbuiltin (preg_split pattern subject (limit -1) (flags 0))
   (preg-split-exec (mkstr pattern) (mkstr subject) (mkfixnum limit) (mkfixnum flags)))

; preg_quote
; FIXME this is potentially unsafe since the caller can directly manipulate the regexp used to quote out characters
(defbuiltin (preg_quote subject (delim "$"))
   (let ((pattern (string-append "([\\$\\\.\\\+\\\*\\\?\\\\\\\[\\\]\\\^\\\(\\\)\\\{\\\}\\\=\\\!\\\<\\\>\\\|\\\:\\" (mkstr delim) "])")))
      (pregexp-replace* pattern subject "\\\\\\1")))

; preg_grep
(defbuiltin (preg_grep pattern input-hash)
   (preg-grep-exec pattern input-hash))

;;;;
;;;; IMPLEMENTATION
;;;;

; add a substring match to matches hash
(define (add-sub-match hash-var match-num substring)
   (php-hash-insert! hash-var match-num substring))

; add a substring match/offset pair to matches hash
(define (add-offset-sub-match hash-var match-num substring offset)
   (let ((offset-pair (make-php-hash)))
      (php-hash-insert! offset-pair 0 substring)
      (php-hash-insert! offset-pair 1 offset)
      (php-hash-insert! hash-var match-num offset-pair)))

; add a substring match to a global matches hash, in either "pattern" or "set" order
(define (add-global-offset-sub-match hash-var match-num sub-num substring offset order)
   (let ((offset-pair (make-php-hash)))
      (php-hash-insert! offset-pair 0 substring)
      (php-hash-insert! offset-pair 1 offset)
      (if (eqv? order 'pattern)
	  ; pattern order
	  (let ((f-array (php-hash-lookup hash-var sub-num)))
	     (unless (php-hash? f-array)
		(set! f-array (make-php-hash)))
	     (php-hash-insert! f-array (- match-num 1) offset-pair)
	     (php-hash-insert! hash-var sub-num f-array))
	  ; set order
	  (let ((f-array (php-hash-lookup hash-var (- match-num 1))))
	     (unless (php-hash? f-array)
		(set! f-array (make-php-hash)))
	     (php-hash-insert! f-array sub-num offset-pair)
	     (php-hash-insert! hash-var (- match-num 1) f-array)))))

; add a substring match/offset pair to a global matches hash, in either "pattern" or "set" order
(define (add-global-sub-match hash-var match-num sub-num substring order)
   (if (eqv? order 'pattern)
       ; pattern order
       (let ((f-array (php-hash-lookup hash-var sub-num)))
	  (unless (php-hash? f-array)
	     (set! f-array (make-php-hash)))
	  (php-hash-insert! f-array (- match-num 1) substring)
	  (php-hash-insert! hash-var sub-num f-array))
       ; set order
       (let ((f-array (php-hash-lookup hash-var (- match-num 1))))
	  (unless (php-hash? f-array)
	     (set! f-array (make-php-hash)))
	  (php-hash-insert! f-array sub-num substring)
	  (php-hash-insert! hash-var (- match-num 1) f-array))))

; for pulling matches from exec-single 
(define (pull-matches-single match-hash subject match-sub-count ovector* flags)
   ; loop for each found subpattern
   (let loop ((i 0))
      (if (< i match-sub-count)
	  (let* ((m-str (make-const-string* 1))
		 (sb-len (pcre-get-substring subject
					     ovector*
					     match-sub-count
					     i
					     m-str)))
	     (if (> (bit-and flags +preg-offset-capture+) 0)
		 ; with offset
		 (add-offset-sub-match (container-value match-hash)
				       i
				       (const-string*-ref m-str 0)
				       (int*-ref ovector* (* i 2)))
		 ; normal
		 (add-sub-match (container-value match-hash)
				i
				(const-string*-ref m-str 0)))
	     (loop (+ i 1))))))

; for pulling matches from exec-global
(define (pull-matches-global match-hash subject match-count max-sub-matches match-sub-count ovector* flags)
   ; loop for each found subpattern
   (let loop ((i 0))
      (if (< i match-sub-count)
	  (let* ((m-str (make-const-string* 1))
		 (sb-len (pcre-get-substring subject
					     ovector*
					     match-sub-count
					     i
					     m-str)))
	     (if (> (bit-and flags +preg-offset-capture+) 0)
		 ; with offset
		 (add-global-offset-sub-match (container-value match-hash)
					      match-count
					      i
					      (const-string*-ref m-str 0)
					      (int*-ref ovector* (* i 2))
					      (if (> (bit-and flags +preg-set-order+) 0) 'set 'pattern))
		 ; normal
		 (add-global-sub-match (container-value match-hash)
				       match-count
				       i
				       (const-string*-ref m-str 0)
				       (if (> (bit-and flags +preg-set-order+) 0) 'set 'pattern)))
	     (loop (+ i 1)))))
   ; if we're in pattern mode, and we didn't fill all the sub matches
   ; we could have, fill the rest with blank strings
   (if (and (zero? (bit-and flags +preg-set-order+))
	    (< match-sub-count (+ max-sub-matches 1)))
       (let fill-loop ((i match-sub-count))
	  (if (< i (+ max-sub-matches 1))
	      (begin
		 (add-global-sub-match (container-value match-hash)
				       match-count
				       i
				       ""
				       'pattern)
		 (fill-loop (+ i 1)))))))


; exec a pattern in single more, optionall retrieve substrings
(define (preg-exec-single c-re
			  subject
			  match-hash
			  ovector*
			  ovector-count
			  flags)
   (let ((match-sub-count (pcre-exec (compiled-regex-re c-re)
				     (compiled-regex-extra c-re)
				     subject
				     (string-length subject)
				     0
				     (bpcre-options->pcre-options (list))
				     ovector*
				     ovector-count)))
      ; match-sub-count is number of subpatterns matched and should be at most (max-sub-matches+1)
      (if (< match-sub-count 0)
	  ; no match
	  0
	  ; match
	  (begin
	     (when match-hash
		; they want sub patterns
		; check for too many substring condition
		(if (and (= match-sub-count 0) (> ovector-count 0))
		    (begin
		       (php-warning "pattern matched but had too many substrings")
		       (set! match-sub-count (/ ovector-count 3))))
		; go for pull
		(pull-matches-single match-hash subject match-sub-count ovector* flags))
	     ; final statement after finding a match
	     ; if matches array was passed, it's been filled
	     1))))

; this call will actually exec a pattern and get substrings
(define (preg-exec-global c-re
			  subject
			  match-hash
			  max-sub-matches
			  ovector*
			  ovector-count
			  flags)
   ; setup match-hash when global and pattern order
   (when (and (zero? (bit-and flags +preg-set-order+))
	      (php-hash? (container-value match-hash)))
      (let loop ((i 0))	 
	 (when (<= i max-sub-matches)
	    (php-hash-insert! (container-value match-hash) (convert-to-integer i) (make-php-hash))
	    (loop (+ i 1)))))
   ; the global loop checks the entire subject for pattern until no more matches
   (let global-loop ((subject-offset 0)
		     (match-count 0)
		     (flag-notempty (list)))
      (let ((match-sub-count (pcre-exec (compiled-regex-re c-re)
					(compiled-regex-extra c-re)
					subject
					(string-length subject)
					subject-offset
					(bpcre-options->pcre-options flag-notempty) 
					ovector*
					ovector-count)))
	 ; match-sub-count is number of subpatterns matched and should be at most (max-sub-matches+1)
	 (if (< match-sub-count 0)
	     ; no match
	     (begin
		; if the notempty flag was set, we need to advance offset and try again
		; as long as we don't go past end of string
		(if (and (memq 'not-empty flag-notempty) (< subject-offset (string-length subject)))
		    ; recurse with advanced offset
		    (global-loop (+ subject-offset 1)
				 match-count
				 (list)) ; clear the empty flag on this call
		    ; all done, return match count
		    match-count))
	     ; match
	     (begin
		; increase match count
		(set! match-count (+ match-count 1))
		(when match-hash
		   ; they want sub patterns
		   ; check for too many substring condition
		   (if (and (= match-sub-count 0) (> ovector-count 0))
		       (begin
			  (php-warning "pattern matched but had too many substrings")
			  (set! match-sub-count (/ ovector-count 3))))
		   ; go for pull
		   (pull-matches-global match-hash subject match-count max-sub-matches match-sub-count ovector* flags))
		; final statement after finding a match
		; if matches array was passed, it's been filled for this iteration
		; at this point if we're not out of room, we need to look for more matches
		(if (< subject-offset (string-length subject))
		    (begin			  
		       ; if we matched an empty string, set not empty flag for next go round
		       (set! flag-notempty (if (eqv? (int*-ref ovector* 0) (int*-ref ovector* 1))
					       (list 'not-empty 'anchored)
					       (list)))
		       ; match again with offset at end character of current match
		       (global-loop (int*-ref ovector* 1)
				    match-count
				    flag-notempty))
		    ; end of string, return final match count
		    match-count))))))

; get a backref from ovector* by index
(define (get-backref subject i match-sub-count ovector* do-eval)
   (if (< i match-sub-count)
       (let* ((m-str (make-const-string* 1))
	      (sb-len (pcre-get-substring subject
					  ovector*
					  match-sub-count
					  i
					  m-str)))
	  (let ((val (const-string*-ref m-str 0)))
             (when do-eval
                (set! val (string-subst val "\"" "\\\"" "'" "\\'")))
	     ;(print "backref " i " is " val)
	     val))
       ""))
   

(define *backrefs-port* (open-output-string))
(define (do-backrefs subject replacement match-sub-count ovector* do-eval)
   ; Replacement may contain references of the form \\n or (since PHP 4.0.4) $n, with the latter form being the preferred one.
   ; Every such reference will be replaced by the text captured by the n'th parenthesized pattern. n can be from 0 to 99,
   ; and \\0 or $0 refers to the text matched by the whole pattern. Opening parentheses are counted from left to right
   ; (starting from 1) to obtain the number of the capturing subpattern.
   ; .... in this case the solution is to use \${1}
   (let* ((len (string-length replacement))
          ;; turn character into a number
          (char->num (lambda (c)
                        (-fx (char->integer c) (char->integer #\0))))
          ;; read a digit or return #f.
          (get-digit (lambda (i)
                        (if (>=fx i len)
                            #f
                            (let ((c1 (string-ref replacement i)))
                               (if (char-numeric? c1)
                                   (char->num c1)
                                   #f)))))
          ;; read a 1 or 2 digit number.  increments i by 1 or two.
          (get-number (lambda (i)
                         (let ((d1 (get-digit (+fx i 1))))
                            (if d1
                                (let ((d2 (get-digit (+fx i 2))))
                                   (if d2
                                       (+fx (*fx d1 10) d2)
                                       d1))
                                #f))))
          ;; read a given character or return #f.
          (get-char (lambda (c i)
                       (if (>=fx i len)
                           #f
                           (if (char=? c (string-ref replacement i))
                               c
                               #f))))
          ;; read a 1 or 2 digit number surrounded by braces.
          (get-braced-number (lambda (i)
                                (let ((number #f))
                                   (if (and (get-char #\{ (+fx i 1))
                                            (begin
                                               (set! number (get-number (+fx i 1)))
                                               number)
                                            (get-char #\} (+fx i (if (>fx number 9) 4 3))))
                                       number
                                       #f)))))
   (let loop ((i 0))
      (when (<fx i len)
         (let ((c (string-ref replacement i))
               (backref-num #f))
            (cond
               ((char=? c #\\)
                (if (get-char #\\ (+fx i 1))
                    ;; doubled backslashes reduce to one backslash
                    (set! i (+fx i 1))
                    (let ((number (get-number i)))
                       (when number
                          (set! backref-num number)
                          (set! i (+fx i (if (>fx number 9) 2 1)))))))
               ((char=? c #\$)
                (let* ((number (get-number i)))
                   (if number
                       (begin
                          (set! backref-num number)
                          (set! i (+fx i (if (>fx number 9) 2 1))))
                       (begin
                          (set! number (get-braced-number i))
                          (when number
                             (set! backref-num number)
                             (set! i (+fx i (if (>fx number 9) 4 3)))))))))
            (if backref-num
                (begin
                   (display (get-backref subject backref-num match-sub-count ovector* do-eval)
                         *backrefs-port*))
                (write-char c *backrefs-port*)))
         (loop (+fx i 1)))))
   (flush-string-port/bin *backrefs-port*))
;;;; the old version was much more elegant, but much slower too:
;;    (let ((rp (regular-grammar
;; 	      ()
;; 	      ((: #\$ (** 1 2 digit) ) (get-backref subject
;; 						    (string->integer (the-substring 1 (the-length)))
;; 						    match-sub-count
;; 						    ovector*))
;; 	      ((: #\\ (** 1 2 digit) ) (get-backref subject
;; 						    (string->integer (the-substring 1 (the-length)))
;; 						    match-sub-count
;; 						    ovector*))
;; 	      ((: #\\ #\\ (** 1 2 digit) ) (the-substring 1 (the-length)))
;; 	      ((: #\$ #\{ (** 1 2 digit) #\} ) (get-backref subject
;; 							    (string->integer (the-substring 2 (- (the-length) 1)))
;; 							    match-sub-count
;; 							    ovector*))
;; 	      ((+ (out #\$ #\\)) (the-string))
;; 	      ((or #\$ #\\) (the-string))
;; 	      (else (the-failure)))))
;;       (append-strings (get-tokens-from-string rp replacement))))


; handle replacement of replacement string into subject at offsets
; provided in ovector. must retrieve substrings, up to match-sub-count,
; for possible use as back referrences
(define (do-sub-replace orig-subject subject replacement last-offset match-sub-count ovector* do-eval)
   (let* ((s-start (- (int*-ref ovector* 0) last-offset))
	  (s-end (- (int*-ref ovector* 1) last-offset))
	  (my-offset 0)
	  (subject-part-len (- s-end s-start)))
      ;(print "found match: " (substring subject s-start s-end))
      ;(print "replacement is: " replacement)
      ; do back references
      (set! replacement (do-backrefs orig-subject replacement match-sub-count ovector* do-eval))
      ;(print "after backrefs replacement is: " replacement)
      ; do eval if /e was specified
      (when do-eval
         (set! replacement (mkstr (php-funcall 'eval replacement)))
	 ;; (set! replacement (with-output-to-string
;; 			      (lambda () (php-eval (string-append "echo " replacement ";")))))
         )
      (set! my-offset (- subject-part-len (string-length replacement)))
      (values
       ;; using blit-string! avoids allocating the two substrings
;        (string-append (substring subject 0 s-start)
;                       replacement
;                       (substring subject s-end (string-length subject)))
       (let ((s (make-string (+ s-start
                                (string-length replacement)
                                (- (string-length subject) s-end)))))
          ;; copy the subject up to where the replaced piece starts
          (blit-string! subject 0 s 0 s-start)
          ;; 
          ;; copy the replacement
          (blit-string! replacement 0 s s-start (string-length replacement))
          ;; copy the subject from where the replaced piece ends to the end
          (blit-string! subject s-end s
                        (+ s-start (string-length replacement))
                        (- (string-length subject) s-end))

          s)
       my-offset)))


; replace, always globally
(define (preg-replace-global c-re
			     replacement
			     subject
			     ovector*
			     ovector-count
			     limit
			     callback)
   (let ((new-subject (mkstr subject))
	 (subject (mkstr subject))
	 (last-match-offset 0)
	 (rval "")
	 (match-hash (make-container (make-php-hash)))
	 (subject-len (string-length (mkstr subject))))
      (if (not callback)
	  (set! rval (mkstr replacement)))
      ; the global loop checks the entire subject for pattern until no more matches
      (let global-loop ((subject-offset 0)
			(match-count 0)
			(flag-notempty (list)))
	 (if (and (> limit 0) (>= match-count limit))
	     ; hit limit
	     new-subject
	     ; no limit, or not there yet
	     (let ((match-sub-count (pcre-exec (compiled-regex-re c-re)
					       (compiled-regex-extra c-re)
					       subject
					       subject-len
					       subject-offset
					       (bpcre-options->pcre-options flag-notempty) 
					       ovector*
					       ovector-count)))
		; match-sub-count is number of subpatterns matched and should be at most (max-sub-matches+1)
		(if (< match-sub-count 0)
		    ; no match
		    (begin
		       ; if the notempty flag was set, we need to advance offset and try again
		       ; as long as we don't go past end of string
		       (if (and (memq 'not-empty flag-notempty) (< subject-offset (string-length subject)))
			   ; recurse with advanced offset
			   (global-loop (+ subject-offset 1)
					match-count
					(list)) ; clear the empty flag on this call
			   ; all done
			   new-subject))
		    ; match
		    (begin
	;(print "subject is " new-subject)
		       ; increase match count
		       (set! match-count (+ match-count 1))
		       (begin
			  ; check for too many substring condition
			  (if (and (= match-sub-count 0) (> ovector-count 0))
			      (begin
				 (php-warning "pattern matched but had too many substrings")
				 (set! match-sub-count (/ ovector-count 3))))
			  ; if callback, get matches array
			  (if callback
			      (begin
				 (pull-matches-single match-hash subject match-sub-count ovector* 0)
				 (set! rval (mkstr (php-callback-call replacement match-hash)))))
			  ; go for replace
			  (receive (r-subject r-last-match-offset)
			     (do-sub-replace subject new-subject rval last-match-offset
					     match-sub-count ovector* (compiled-regex-eval-replacement c-re))
			     (set! new-subject r-subject)
			     (set! last-match-offset (+ r-last-match-offset last-match-offset)))
			  ; final statement after finding a match
			  ; if matches array was passed, it's been filled for this iteration
			  ; at this point if we're not out of room, we need to look for more matches
			  (if (< subject-offset (string-length subject))
			      (begin
				 ; if we matched an empty string, set not empty flag for next go round
				 (set! flag-notempty (if (= (int*-ref ovector* 0) (int*-ref ovector* 1))
							 (list 'not-empty 'anchored)
							 (list)))
				 ; match again with offset at end character of current match
				 (global-loop (int*-ref ovector* 1)
					      match-count
					      flag-notempty))
			      ; end of string, return final match count
			      new-subject)))))))))



; this function either gets a cached compiled pattern (which will cache if not already done)
; and hands it off to the exec function
(define (preg-match-exec pattern subject match-hash flags global)
   (let ((ovector* (make-null-int*))
	 (ovector-count 0))
      ; make sure these are strings
      (set! pattern (mkstr pattern))
      (set! subject (mkstr subject))
      ; setup match-hash if it's going to be used
      (when match-hash
	 (container-value-set! match-hash (make-php-hash)))
      ; get compiled regex...
      (let ((max-sub-matches 0)
	    (c-re (get-compiled-regex pattern)))
	 (if (compiled-regex? c-re)
	     (begin
		; study pattern for subpattern count
		(when match-hash
		   (let* ((max-sub-matches* (make-int* 1))
			  (fi (pcre-fullinfo (compiled-regex-re c-re)
					     (compiled-regex-extra c-re)
					     (bpcre-info-flags->pcre-info-flags (list 'capture-count))
					     max-sub-matches*)))
		      (set! max-sub-matches (int*-ref max-sub-matches* 0))
		      (set! ovector-count (* (+ max-sub-matches 1) 3))
		      (set! ovector* (make-int* ovector-count))))
		; execute
		(if global
		    (preg-exec-global c-re subject match-hash max-sub-matches ovector* ovector-count flags)
		    (preg-exec-single c-re subject match-hash ovector* ovector-count flags)))
	     #f))))

; this function either gets a cached compiled pattern (which will cache if not already done)
; and hands it off to the replace function
(define (preg-replace-exec pattern replacement subject limit callback)
   (let ((ovector* (make-null-int*))
	 (ovector-count 0))
      ; if pattern is an array...
      (if (php-hash? pattern)
	  ; array of patterns
	  (let ((c-pattern "")
		(c-replacement replacement))
	     (php-hash-reset pattern)
	     (if (php-hash? replacement)
		 (php-hash-reset replacement))
	     (let loop ((new-subject subject))
		(set! c-pattern (php-hash-current pattern))
		(if (php-hash? replacement)
		    ;  replacement is hash
		    (begin
		       (set! c-replacement (php-hash-current replacement))
		       ; but are there any left?
		       (if (eqv? c-replacement #f)
			   (set! c-replacement "")
			   (set! c-replacement (container-value (cdr c-replacement))))))
		(if (not (eqv? c-pattern #f))
		    (begin
		       ; pull out pattern
		       (set! c-pattern (container-value (cdr c-pattern)))
		       ; get compiled regex...
		       (let ((max-sub-matches 0)
			     (c-re (get-compiled-regex c-pattern)))
			  (if (compiled-regex? c-re)
			      ; study pattern for subpattern count
			      (let* ((max-sub-matches* (make-int* 1))
				     (fi (pcre-fullinfo (compiled-regex-re c-re)
							(compiled-regex-extra c-re)
							(bpcre-info-flags->pcre-info-flags (list 'capture-count))
							max-sub-matches*)))
				 (set! max-sub-matches (int*-ref max-sub-matches* 0))
				 (set! ovector-count (* (+ max-sub-matches 1) 3))
				 (set! ovector* (make-int* ovector-count))
				 ; advance arrays
				 (php-hash-advance pattern)
				 (when (php-hash? replacement)
				     (php-hash-advance replacement))
				 (loop (preg-replace-global c-re c-replacement new-subject ovector* ovector-count limit callback)))
			      ; bad regex
			      #f)))
		    ; done with pattern hash
		    new-subject)))
	  ; single pattern
	  (begin
	     ; get compiled regex...
	     (let ((max-sub-matches 0)
		   (c-re (get-compiled-regex pattern)))
		(if (compiled-regex? c-re)
		    (begin
		       ; study pattern for subpattern count
		       (let* ((max-sub-matches* (make-int* 1))
			      (fi (pcre-fullinfo (compiled-regex-re c-re)
						 (compiled-regex-extra c-re)
						 (bpcre-info-flags->pcre-info-flags (list 'capture-count))
						 max-sub-matches*)))
			  (set! max-sub-matches (int*-ref max-sub-matches* 0))
			  (set! ovector-count (* (+ max-sub-matches 1) 3))
			  (set! ovector* (make-int* ovector-count)))				 		       
		       (preg-replace-global c-re replacement subject ovector* ovector-count limit callback))))))))


; for pulling matches from delim capture
(define (split-pull-delim match-hash subject match-count match-sub-count ovector* flags)
   ; loop for each found subpattern
   (let loop ((i 1))
      (if (< i match-sub-count)
	  (let* ((m-str (make-const-string* 1))
		 (sb-len (pcre-get-substring subject
					     ovector*
					     match-sub-count
					     i
					     m-str)))
	     ;(print "delim pull i " i " match " (const-string*-ref m-str 0)) 
	     (if (or (zero? (bit-and flags +preg-split-no-empty+))
		     (> sb-len 0))
		 (if (> (bit-and flags +preg-split-offset-capture+) 0)
		     ; with offset
		     (add-offset-sub-match match-hash :next (const-string*-ref m-str 0) (int*-ref ovector* (* i 2)))
		     ; normal
		     (add-sub-match match-hash :next (const-string*-ref m-str 0))))
	     (loop (+ i 1))))))


(define (split-add-match match-hash substring offset flags)
   ;(print "split " substring " at " offset)
   (if (> (bit-and flags +preg-split-offset-capture+) 0)
       ; with offset
       (let ((offset-pair (make-php-hash)))
	  (php-hash-insert! offset-pair 0 substring)
	  (php-hash-insert! offset-pair 1 offset)
	  (php-hash-insert! match-hash :next offset-pair))
       ; normal
       (php-hash-insert! match-hash :next substring)))

; pull splits from a subject
(define (split-pull match-hash subject subject-offset last-match ovector* flags)
   (let* ((delim-start (int*-ref ovector* 0))
	  (delim-end (int*-ref ovector* 1))
	  (delim-len (- delim-end delim-start)))
    ;  (print "delim-start " delim-start " delim-end " delim-end " subject offset " subject-offset " last match " last-match)
      (if (> (bit-and flags +preg-split-no-empty+) 0)
	  ; check not empty, meaning a string before the delimiter
	  (if (> (- delim-start last-match) 0)
	      (split-add-match match-hash (substring subject last-match delim-start) last-match flags))
	  ; normal
	  (split-add-match match-hash (substring subject last-match delim-start) subject-offset flags))))

; return from subject-offset to end of string as final match
(define (split-final-match match-hash subject subject-offset last-match flags)
   ;(print "final subject " subject " offset " subject-offset " last-match " last-match)
   (if (> (string-length subject) subject-offset)
       (let ((substring (substring subject last-match (string-length subject))))
	  (when (or (zero? (bit-and flags +preg-split-no-empty+))
		    (and (> (bit-and flags +preg-split-no-empty+) 0)
			 (> (string-length substring) 0)))
	     (if (> (bit-and flags +preg-split-offset-capture+) 0)
		 ; with offset
		 (let ((offset-pair (make-php-hash)))
		    (php-hash-insert! offset-pair 0 substring)
		    (php-hash-insert! offset-pair 1 subject-offset)
		    (php-hash-insert! match-hash :next offset-pair))
		 ; normal
		 (php-hash-insert! match-hash :next substring)))))
   match-hash)
   
; do split
(define (preg-split-global c-re
			   subject
			   ovector*
			   ovector-count
			   flags
			   limit)
   (bind-exit (return)
      (let ((match-hash (make-php-hash)))
	 ; the global loop checks the entire subject for pattern until no more matches
	 (let global-loop ((subject-offset 0)
			   (match-count 0)
			   (last-match 0)
			   (flag-notempty (list)))
	;    (print "loop, match-count " match-count " flags " flag-notempty)
	    ; hit limit?
	    (if (and (> limit 0)
		     (= match-count (- limit 1)))
		; thats all folks
		(return (split-final-match match-hash subject subject-offset last-match flags)))
	    ; try match
	    (let ((match-sub-count (pcre-exec (compiled-regex-re c-re)
					      (compiled-regex-extra c-re)
					      subject
					      (string-length subject)
					      subject-offset
					      (bpcre-options->pcre-options flag-notempty) 
					      ovector*
					      ovector-count)))
	       ; match-sub-count is number of subpatterns matched and should be at most (max-sub-matches+1)
	       (if (< match-sub-count 0)
		   ; no match
		   (begin
		      ;(print "no match " match-count " last-match is " last-match)
		      ; if the notempty flag was set, we need to advance offset and try again
		      ; as long as we don't go past end of string
		      (if (and (memq 'not-empty flag-notempty)
			       (< subject-offset (- (string-length subject) 1)))
			  ; recurse with advanced offset
			  (global-loop (+ subject-offset 1)
				       match-count
				       last-match
				       (list)) ; clear the empty flag on this call
			  ; all done, return match hash
			  ; add last match if necessary
			  (split-final-match match-hash subject subject-offset last-match flags)))
		   ; match
		   (begin
		      ;(print "match from " (int*-ref ovector* 0) " to " (int*-ref ovector* 1) " on " subject)
		      ; increase match count
		      (set! match-count (+ match-count 1))
		      ; check for too many substring condition
		      (if (and (= match-sub-count 0) (> ovector-count 0))
			  (begin
			     (php-warning "pattern matched but had too many substrings")
			     (set! match-sub-count (/ ovector-count 3))))
		      ; we are go for extraction
		      (split-pull match-hash subject subject-offset last-match ovector* flags)
		      ; if we want delim capture, pull them here
		      (when (and (> match-sub-count 1)
				 (> (bit-and flags +preg-split-delim-capture+) 0))
			 (split-pull-delim match-hash subject match-count match-sub-count ovector* flags))
		      ; keep track of this match for next iteration
		      (set! last-match (int*-ref ovector* 1))
		      ; final statement after finding a match
		      ; at this point if we're not out of room, we need to look for more matches
		      (if (< subject-offset (- (string-length subject) 1))
			  (begin
			     ; if we matched an empty string, set not empty flag for next go round
			     (set! flag-notempty (if (= (int*-ref ovector* 0) (int*-ref ovector* 1))
						     (list 'not-empty 'anchored)
						     (list)))
			     ; match again with offset at end character of current match
			     (global-loop (int*-ref ovector* 1)
					  match-count
					  last-match
					  flag-notempty))
			  ; end of string, return final match hash
			  ; add final match if necessary
			  (split-final-match match-hash subject subject-offset last-match flags)))))))))
		       

(define (preg-split-exec pattern::bstring subject::bstring limit::int flags::int)
   (let ((ovector* (make-null-int*))
	 (ovector-count 0))
      ; get compiled regex...
      (let ((max-sub-matches 0)
	    (c-re (get-compiled-regex pattern)))
	 (if (compiled-regex? c-re)
	     (begin
		; study pattern for subpattern count
		(let* ((max-sub-matches* (make-int* 1))
		       (fi (pcre-fullinfo (compiled-regex-re c-re)
					  (compiled-regex-extra c-re)
					  (bpcre-info-flags->pcre-info-flags '(capture-count))
					  max-sub-matches*)))
		   (set! max-sub-matches (int*-ref max-sub-matches* 0))
		   (set! ovector-count (* (+ max-sub-matches 1) 3))
		   (set! ovector* (make-int* ovector-count)))
		; execute
		(preg-split-global c-re subject ovector* ovector-count flags limit))
	     #f))))

; return an array container only mateched elements from input hash
(define (preg-grep-exec pattern input-hash)
   (let ((ovector* (make-null-int*))
	 (output-hash (make-php-hash))
	 (ovector-count 0))
      ; make sure these are strings
      (set! pattern (mkstr pattern))
      ; get compiled regex...
      (let ((max-sub-matches 0)
	    (c-re (get-compiled-regex pattern)))
	 (if (and (compiled-regex? c-re) (php-hash? input-hash))
	     (begin
		; study pattern for subpattern count
		(let* ((max-sub-matches* (make-int* 1))
		       (fi (pcre-fullinfo (compiled-regex-re c-re)
					  (compiled-regex-extra c-re)
					  (bpcre-info-flags->pcre-info-flags (list 'capture-count))
					  max-sub-matches*)))
		   (set! max-sub-matches (int*-ref max-sub-matches* 0))
		   (set! ovector-count (* (+ max-sub-matches 1) 3))
		   (set! ovector* (make-int* ovector-count)))
		; execute for each hash
		(php-hash-for-each input-hash
				   (lambda (key val)
				      (if (> (preg-exec-single c-re (mkstr val) #f ovector* ovector-count 0) 0)
					  (php-hash-insert! output-hash key val))))
		output-hash)
	     #f))))

; pull pattern and options string
(define (parse-php-pattern php-pattern)
   (let* ((start-delim (string-ref php-pattern 0))
	  (end-delim start-delim))
      (if (or (char-alphabetic? start-delim)
	      (char-numeric? start-delim)
	      (char=? #\\ start-delim))
	  (begin
	     (php-warning "Delimiter must not be alphanumeric or backslash")
	     (values #f #f))
	  (begin
	     ; check for magical delimiters
	     ; ([{< )]}>
	     (cond ((char=? start-delim #\() (set! end-delim #\)))
		   ((char=? start-delim #\[) (set! end-delim #\]))
		   ((char=? start-delim #\<) (set! end-delim #\>))
		   ((char=? start-delim #\{) (set! end-delim #\})))
	     ; loop through pattern char by char
	     (let loop ((pattern "")
			(i 1))
		(if (< i (string-length php-pattern))
		    ; look for delimiter but make sure it's not escaped
		    (if (and (char=? (string-ref php-pattern i) end-delim)
			     (not (char=? (string-ref php-pattern (- i 1)) #\\)))
			; found delimiter, return extracted pattern and results of option parsing
			(values pattern (parse-pcre-options (substring php-pattern (+ i 1) (string-length php-pattern))))
			; didn't hit delimiter, keep lookin
			(if (and (char=? (string-ref php-pattern i) end-delim)
				 (char=? (string-ref php-pattern (- i 1)) #\\))
			    ; don't include escape character
			    (loop (string-append (substring pattern 0 (- i 2)) (substring php-pattern i (+ 1 i))) (+ i 1))
			    ; there's no escape!
			    (loop (string-append pattern (substring php-pattern i (+ 1 i)))
				  (+ i 1))))
		    ; ran out of string
		    (begin
		       (php-warning "End delimiter not found in pattern")
		       (values #f #f))))))))

    
	  
; parse options string, return properly flagged option list
(define (parse-pcre-options option-list)
   (bind-exit (return)
      (let loop ((parsed-options (list))
		 (i 0))
	 (if (< i (string-length option-list))
	     ; parse option character
	     (let ((opt-char (string-ref option-list i)))
		(cond ((char=? opt-char #\i) (set! parsed-options (cons 'caseless parsed-options)))
		      ((char=? opt-char #\m) (set! parsed-options (cons 'multi-line parsed-options)))
		      ((char=? opt-char #\s) (set! parsed-options (cons 'dot-all parsed-options)))
		      ((char=? opt-char #\x) (set! parsed-options (cons 'extended parsed-options)))
		      ((char=? opt-char #\e) (set! parsed-options (cons 'eval parsed-options)))
		      ((char=? opt-char #\A) (set! parsed-options (cons 'anchored parsed-options)))
		      ((char=? opt-char #\D) (set! parsed-options (cons 'dollar-end-only parsed-options)))
		      ; note S isn't a real PCRE option, we use it internally for a study 
		      ((char=? opt-char #\S) (set! parsed-options (cons 'study parsed-options)))
		      ((char=? opt-char #\U) (set! parsed-options (cons 'ungreedy parsed-options)))
		      ((char=? opt-char #\X) (set! parsed-options (cons 'extra parsed-options)))
		      ((char=? opt-char #\u) (set! parsed-options (cons 'utf8 parsed-options)))		   
		      (else
		       (begin
			  (php-warning (format "Unknown pcre modifier: '~a'" opt-char))
			  (return #f))))
		; go to next character
		(loop parsed-options (+ i 1)))
	     ; no more text, return current parsed options
	     parsed-options))))

(define (non-consing-strip-left-whitespace str::bstring)
   ;since this gets called for every single pcre operation,
   ;it's very important that it not cons. -tim
   (let ((len (string-length str))
	 (whitespace '(#\space #\tab #\newline #\return #a011 #a012 #a160)))
      (let loop ((s 0))
	 (if (<fx s len)
	     (let ((ch (string-ref str s)))
		(if (memq ch whitespace)
		    (loop (+fx s 1))
		    (if (=fx s 0)
			str
			(substring str s len))))
	     (begin
		(php-warning "Empty pcre regular expression")
		"")))))


   

; handle parsing of the pattern for delimiter and options, return compiled regex
; if this pattern has already been compiled, return a cached version
(define (get-compiled-regex pattern::bstring)
   ; check to see if it's already compiled
   ; note we trim the pattern for whitespace
   (let* ((stripped-regex (non-consing-strip-left-whitespace pattern))
	  (cp (hashtable-get *compiled-regexs* stripped-regex)))
      (if cp
	  cp
	  ; no good, compiled and then cache it
	  (handle-regex-compile stripped-regex))))

; compile and cache a pattern
(define (handle-regex-compile pattern::bstring)
   (let ((errormsg (make-const-string* 1))
	 (erroroffset (make-int* 1))
	 (tableptr (make-null-const-uchar*))
	 (will-study #f)
	 (will-eval #f))
      (receive (pcre-pattern options) (parse-php-pattern pattern)
	 (begin
	    ; if pcre-pattern is false, there was a problem parsing the php pattern
	    (if (or (eqv? pcre-pattern #f) (eqv? options #f))
		#f
		;ok we have good pattern and options
		(begin
		   ; if study option is passed, nab it from options
		   (if (memq 'study options)
		       (begin
			  (set! will-study #t)
			  (set! options (remq 'study options))))
		   ; if eval option is passed, nab it from options
		   (if (memq 'eval options)
		       (begin
			  (set! will-eval #t)
			  (set! options (remq 'eval options))))
		   (let ((new-cp (make-compiled-regex))
			 (re (pcre-compile pcre-pattern options errormsg erroroffset tableptr)))
		      (when (null-pcre? re)
			 (begin
			    ; woops didn't compile
			    (php-warning (format "regex compile error: ~a at offset ~a"
						 (const-string*-ref errormsg 0)
						 (int*-ref erroroffset 0)))
			    #f))
		      ; handle cache here, then return structure
		      (compiled-regex-re-set! new-cp re)
		      (compiled-regex-eval-replacement-set! new-cp will-eval)
		      ; studying?
		      (if will-study
			  (let ((errormsg (make-const-string* 1)))
			     (compiled-regex-extra-set! new-cp (pcre-study re 0 errormsg))))
		      (hashtable-put! *compiled-regexs* pattern new-cp))))))))



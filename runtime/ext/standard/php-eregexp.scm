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

(module php-eregexp-lib
   (include "../phpoo-extension.sch")
   (library profiler)
   (export
    (init-php-eregexp-lib)
    (ereg pattern str ref)
    (ereg_replace pattern replacement str)
    (split pattern str limit)
    (eregi pattern str ref)
    (eregi_replace pattern replacement str)
    (spliti pattern str limit)
    ))


; init the module
(define (init-php-eregexp-lib)
   1)





;hehe.. from the php docs: "Note: Up to (and including) PHP 4.1.0 $regs
;will be filled with exactly ten elements, even though more or fewer
;than ten parenthesized substrings may actually have matched. This has
;no effect on ereg()'s ability to match more substrings. If no matches
;are found, $regs will not be altered by ereg()."
;Sick.

; bigloo's implementation isn't exactly posixly correct
; this attempts to fix some things so it works more like php
(define (posixify pat)
   ; first, we need to fix character classes
   ; turn all backslashes in character classes into literals, since posix see's them this way
   (let ((m  (pregexp-replace* "\\[([^\\\\]*)\\\\([^\\\\]*)\\]" pat "[\\1\\\\\\\\\\2]")))
      m))

;ereg -- Regular expression match
;warning! parameter regs is modified!
(defbuiltin (ereg pattern str ((ref . regs) 'unpassed))
   (let ((match-result (pregexp-match (posixify (mkstr pattern)) (mkstr str))))
      (if match-result
	  (begin
	     (if (container? regs)
		 ;store a new array of the matches into the original container
		 (container-value-set! regs (list->php-hash match-result))
		 ;regs was not passed
		 (car match-result))
	     ; php does this
	     (string-length str))
	  ;no match
	  #f)))


;XXX bug in ereg_replace:
;this hangs
;ereg_replace ("^", "<br />", $string); 
   
;ereg_replace -- Replace regular expression
(defbuiltin (ereg_replace pattern replacement str)
   (set! pattern (posixify (mkstr pattern)))
   (set! str (mkstr str))
;   (print "pattern is " pattern ", length " (string-length pattern) ", replacement is " replacement ", str is " str)
   ;deal with extreme PHP weirdness.. 
   (when (php-number? replacement)
      ;if the replacement is an integer, treat it as a char code
      (set! replacement (mkstr (integer->char (mkfixnum replacement)))))
   (pregexp-replace* pattern str replacement))



;eregi -- case insensitive regular expression match
(defbuiltin (eregi pattern str ((ref . regs) 'unpassed))
   (ereg (string-append "(?i:" (posixify (mkstr pattern)) ")") (mkstr str) regs))

;eregi_replace -- replace regular expression case insensitive
(defbuiltin (eregi_replace pattern replacement str)
   (ereg_replace (string-append "(?i:" (posixify (mkstr pattern)) ")") (mkstr replacement) (mkstr str)))

;split -- split string into array by regular expression
(defbuiltin (split pattern str (limit 'unpassed))
   ;XXX this function is greatly complicated by the fact that
   ;pregexp-split doesn't take a limit.
   (set! pattern (posixify (mkstr pattern)))
   (set! str (mkstr str))
   (let ((fragments (let* ((length (string-length str))
			   (limit (if (eqv? limit 'unpassed)
				      ;each match must be at least one char anyway
				      (+ 1 length)
				      (mkfixnum (convert-to-number limit))))
			   ;convert pattern only once
			   (compiled-pattern (pregexp pattern)))
		       (let loop ((frags '())
				  (count 1)
				  (start 0))
			  (if (< count limit)
			      (let ((pos (pregexp-match-positions compiled-pattern str start length)))
				 (if pos
				     (if (= (caar pos) (cdar pos))
					 ;if the match is of length 0, it's broken
					 (php-warning (format "invalid regular expression: ~a" pattern))
					 ;if we matched, save the match and go again, starting after the match
					 (loop (cons (substring str start (caar pos)) frags)
					       (+ 1 count)
					       (cdar pos)))
				     ;if it didn't match, return the fragments including the rest
				     (reverse (cons (substring str start length) frags))))
			      (if (< start length)
				  ;return all of the fragments, including the rest
				  (reverse (cons (substring str start length) frags))
				  ;there is no rest, return the fragments
				  (reverse frags)))))))
      ;if we got some matches
      (if (and fragments (pair? fragments))
	  ;return them as an array
	  (list->php-hash fragments)
	  ;otherwise, return false
	  #f)))

;spliti --  Split string into array by regular expression case insensitive
(defbuiltin (spliti pattern str (limit 'unpassed))
   (split (string-append "(?i:" (posixify (mkstr pattern)) ")") (mkstr str) limit))

;sql_regcase --  Make regular expression for case insensitive match



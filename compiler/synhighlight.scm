;; ***** BEGIN LICENSE BLOCK *****
;; Roadsend PHP Compiler
;; Copyright (C) 2007-2008 Roadsend, Inc.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
;; ***** END LICENSE BLOCK *****


(module pcc-highlighter
   (library php-runtime)
   (include "php-runtime.sch")
   (library profiler)
   (export
    (syntax-highlight-file file format)    
    (syntax-highlight-string str format)
    (syntax-highlight-line line format))
   (import (lexers "lexers.scm")))


(define (syntax-highlight-file file format)
   (with-input-from-file file
      (lambda ()
	 (syntax-highlight-port (current-input-port) format))))

(define (syntax-highlight-string str format)
   (with-input-from-string str
      (lambda () 
	 (syntax-highlight-port (current-input-port) format))))

(define (syntax-highlight-line line format)
   (let*((has-twib (string-contains line "<?"))
	 (line-hash (with-input-from-string (if has-twib
						line
						(mkstr "<? " line))
			(lambda () 
			   (syntax-highlight-port (current-input-port) format))))
	  (last-line ""))
       (hashtable-for-each line-hash
			   (lambda (k v)
			      (set! last-line v)))
       (if has-twib
	   last-line
	   (substring last-line 3 (string-length last-line)))))

(define (syntax-highlight-port port format)
   (let ((source (make-hashtable))
	 (tok-list '()))
      (fluid-let ((*syntax-highlight?* #t))
		 (set-input-port-position! port 0)
		 (with-input-from-port port
		    (lambda ()
		       (with-input-from-string (php-preprocess (current-input-port) "syntaxhighlight" #t)
			  (lambda ()
			     (set! tok-list (get-tokens (php-surface) (current-input-port))))))))
      (with-input-from-string (with-output-to-string
				 (lambda ()
				    (set-input-port-position! port 0)
				    (with-input-from-port port
				       (lambda ()
					  (for-each (lambda (t)
						       (let* ((token (car t))
							      (len (cdr t))
							      (sstr (read-chars len)))
							  ;(debug-print "token: " token " len: " len " read: [" sstr "]")
							  (display (markup token sstr format))))
						    tok-list)))))
	 (lambda ()
	    (let loop ((line (read-line (current-input-port)))
		       (n 1))	       
	       (if (not (eof-object? line))
		   (begin
		      ;(debug-print "line here is " line)
		      (hashtable-put! source n line)
		      (loop (read-line (current-input-port)) (+ n 1)))))))
      source))

(define yellow 33)
(define red 31)
(define green 32)
(define blue 34)
(define purple 35)

(define (ansi-color col txt)
   (format "\033[~am~a\033[0m" col txt))

(define (markup token str format)
   (let* ((clean-str (lambda (s)
			(if (eqv? format 'html)
			    (php-funcall 'htmlspecialchars s)
			    s)))
	  (mark (lambda (c)
		   (if (eqv? format 'html)
		       ; html - css (defined by caller)
		       (let ((pass-1 (mkstr "<span class=\"" c "\">"
					    (clean-str str)
					    "</span>")))
			  ; we have to do the span for each new line
			  (pregexp-replace* "\n" pass-1 (mkstr "</span>\n<span class=\"" c "\">")))
		       ; ansi - hard coded colors
		       (case c
			  ((string) (ansi-color blue str))
			  ((comment) (ansi-color green str))
			  ((ident) (ansi-color purple str))
			  ((number) (ansi-color yellow str))
			  ((var) (ansi-color red str))
			  ((whitespace) str))))))
      ;(debug-trace 0 "looking at token: " token)
      (case token
	 ((whitespace) (mark 'whitespace))
	 ((string) (mark 'string))
	 ((varnamed var) (mark 'var))
	 ((elsekey elseifkey includekey requirekey include-once
	   require-once continue definekey parent exitkey diekey
	   echokey boolean echokey printkey id) (mark 'ident))
	 ((comment) (mark 'comment))
	 ((float integer) (mark 'number))
	 (else
	  (clean-str str)))))


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

;;;;; This is a minimal HTML parser that rewrites the URLs that
;;;;; it finds (and forms) to include extra variables
(module url-rewriter
   (export (rewrite-urls::bstring input::bstring
				  get-vars::bstring
				  post-vars::bstring
				  a?::bool
				  area?::bool
				  frame?::bool
				  input?::bool
				  form?::bool)))


;;;;
;for example:
; (rewrite-html "zinger=foo"
; 	        "<input type=\"hidden\" name=\"boingo\" value=\"farkas\">"
; 	        #t #t #t #t #f)
;
;The postvars will be added to forms if form? is #t.
;The getvars will be added to URLs in the certain tags if the
;respective parameter is #t.


(define (rewrite-urls::bstring
	 input::bstring
	 get-vars::bstring postvars::bstring a?::bool
	 area?::bool frame?::bool input?::bool form?::bool)
   (with-input-from-string input
      (lambda ()
	 (with-output-to-string
	    (lambda ()
	       (letrec ((non-tag-lexer
			 (regular-grammar ()
			    ((+ (out #\<)) (the-string))
			    ((: #\< (* space) (uncase "a") (+ space))
			     (if a?
				 (cons rewrite-tag-lexer (the-string))
				 (cons tag-lexer (the-string))))
			    ((: #\< (* space) (uncase "area") (+ space))
			     (if area?
				 (cons rewrite-tag-lexer (the-string))
				 (cons tag-lexer (the-string))))
			    ((: #\< (* space) (uncase "frame") (+ space))
			     (if frame?
				 (cons rewrite-tag-lexer (the-string))
				 (cons tag-lexer (the-string))))
			    ((: #\< (* space) (uncase "input") (+ space))
			     (if input?
				 (cons rewrite-tag-lexer (the-string))
				 (cons tag-lexer (the-string))))
			    ((: #\< (* space) (uncase "form") (+ (out #\>)) #\>)
			     (if form?
				 (string-append (the-string) postvars)
				 (the-string)))
			    (#\< (cons tag-lexer (the-string)))))
			(rewrite-tag-lexer
			 (regular-grammar ()
			    ((: (or (uncase "href") (uncase "src"))
				(* space) #\= (* space) #\" (+ (out #\? #\# #\: #\")) #\")
			     (string-append (the-substring 0 (- (the-length) 1)) "?" get-vars "\""))
			    ;the same, with single quote
			    ((: (or (uncase "href") (uncase "src"))
				(* space) #\= (* space) #\' (+ (out #\? #\# #\: #\')) #\')
			     (string-append (the-substring 0 (- (the-length) 1)) "?" get-vars "'"))
			    ;the same two, this time with #\?
			    ((: (or (uncase "href") (uncase "src"))
				(* space) #\= (* space) #\" (+ (out #\# #\: #\")) #\")
			     (string-append (the-substring 0 (- (the-length) 1)) "&" get-vars "\""))
			    ((: (or (uncase "href") (uncase "src"))
				(* space) #\= (* space) #\' (+ (out #\# #\: #\')) #\')
			     (string-append (the-substring 0 (- (the-length) 1)) "&" get-vars "'"))
			    ((out #\> #\space) (the-string))
			    (#\space (the-string))
			    (#\> (cons non-tag-lexer (the-string)))))
			(tag-lexer
			 (regular-grammar ()
			    ((+ (out #\>)) (the-string))
			    (#\> (cons non-tag-lexer (the-string))))))
		  (let loop ((token (read/rp non-tag-lexer (current-input-port)))
			     (the-lexer non-tag-lexer))
		     (cond
			((string? token) (display token)
					 (loop (read/rp the-lexer (current-input-port))
					       the-lexer))
			((pair? token) (display (cdr token))
				       (loop (read/rp (car token) (current-input-port))
					     (car token)))
			((eof-object? token) #t)
			(else (error 'oops "broken" token))))))))))

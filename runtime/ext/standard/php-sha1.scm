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

(module php-sha1
   (extern
    (include "sha1.h")
    (type sha1-context (opaque) "SHA1Context*")
    (macro sha1-make-context::sha1-context () "re_make_sha1_context")
    (macro sha1-get-digest::void (::sha1-context ::bstring) "re_get_sha1_digest")
    (macro sha1-reset::void (::sha1-context) "SHA1Reset")
    (macro sha1-input::void (::sha1-context ::bstring) "SHA1Input")
    (macro sha1-result::void (::sha1-context) "SHA1Result"))
   (export
    (sha1 in-port::input-port raw?::bbool)))


(define (sha1 in-port::input-port raw?::bbool)
   (let ((ctxt (sha1-make-context))
	 (digest (make-string 20)))
      (sha1-reset ctxt)
      (let loop ((buf (read-chars 1024 in-port)))
	 (if (eof-object? buf)
	     #t
	     (begin
		(sha1-input ctxt buf)
		(loop (read-chars 1024 in-port)))))
      (sha1-result ctxt)
      (sha1-get-digest ctxt digest)
      (if raw?
	  ; raw 20 digit digest
	  digest
	  ; convert to 40 digit hex string
	  (with-output-to-string
	     (lambda ()
		(let loop ((i 0))
		   (when (<fx i 20)
		      (display (unsigned->string (char->integer (string-ref digest i)) 16))
		      (loop (+fx i 1)))))))))

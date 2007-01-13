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

(module cgi
   (library php-runtime)
   (library phpeval)
   (library webconnect)
;   (library common)
   (library profiler)
   (load (php-macros "../../php-macros.scm"))
   (include "../../runtime/php-runtime.sch")
   (eval (export-all))
   (export
    ;
    (init-cgi-lib)
    (cgi-init)
    (cgi-print-headers)
    ;
    ))


(define (init-cgi-lib)
   1)

(define cgi-log-message
   (lambda (msg)
      (fprint (current-error-port) msg)))

(define cgi-log-warning
   (lambda (msg)
      (fprint (current-error-port) (format "Warning: ~a " msg))))

(define cgi-log-error
   (lambda (msg)
      (fprint (current-error-port) (format "Error: ~a " msg))))

(define (cgi-init)

   (set! *backend-type* "CGI")
   (set! *headers* (make-hashtable))
   (set! *response-code* HTTP-OK)
   (set! *commandline?* #f)
   
   (set! log-message cgi-log-message)
   (set! log-warning cgi-log-warning)
   (set! log-error cgi-log-error)

   ; php runtime is done in program prologue

   ; define our target   
   (setup-web-target)

   ; add default headers
   (header "Content-type: text/html" #t) 

   ; servervars
   (let ((request (getenv "REQUEST_URI")))
      (php-hash-insert! (container-value $HTTP_SERVER_VARS) "REQUEST_URI" request)
      (php-hash-insert! (container-value $HTTP_SERVER_VARS) "REQUEST_METHOD" (getenv "REQUEST_METHOD"))
      (php-hash-insert! (container-value $HTTP_SERVER_VARS) "QUERY_STRING" (getenv "QUERY_STRING"))
      (php-hash-insert! (container-value $HTTP_SERVER_VARS) "REMOTE_ADDR" (getenv "REMOTE_ADDR"))
      
      (php-hash-insert! (container-value $HTTP_SERVER_VARS) "PHP_SELF" (getenv "SCRIPT_NAME"))
      (php-hash-insert! (container-value $HTTP_SERVER_VARS) "SCRIPT_NAME" (getenv "SCRIPT_NAME"))
      (php-hash-insert! (container-value $HTTP_SERVER_VARS) "DOCUMENT_ROOT" (getenv "DOCUMENT_ROOT"))
      (php-hash-insert! (container-value $HTTP_SERVER_VARS) "SCRIPT_FILENAME" (getenv "SCRIPT_FILENAME"))

      (when (getenv "PATH_INFO")
	 (php-hash-insert! (container-value $HTTP_SERVER_VARS) "PATH_INFO" (getenv "PATH_INFO"))
	 (php-hash-insert! (container-value $HTTP_SERVER_VARS) "PATH_TRANSLATED" (getenv "PATH_TRANSLATED")))
      )

   ;; finally, copy the server vars into $_SERVER. 
   (container-value-set! $_SERVER (copy-php-data (container-value $HTTP_SERVER_VARS)))
   ; cookies
   (parse-cookies (getenv "HTTP_COOKIE"))
   
   ; parse CGI env vars
   (when (getenv "REQUEST_METHOD")
      (string-case (getenv "REQUEST_METHOD")
	 ("GET" (parse-get-args (getenv "QUERY_STRING")))
	 ("POST" (parse-get-args (getenv "QUERY_STRING"))
                 (parse-post))))

   )

(define (parse-post)
   (let ((clen (mkfixnum (getenv "CONTENT_LENGTH"))))
      (when (> clen 2)
	 (let ((content (read-chars clen (current-input-port))))
	    (when (= (string-length content) clen)
	       (parse-post-args content))))))


(define (cgi-print-headers)
   ; only need to print status if it's not 200   
   (unless (= *response-code* HTTP-OK)
      (display (mkstr "Status: " *response-code* "\r\n") (current-output-port)))
   (hashtable-for-each *headers*
      (lambda (key headerlist)
	 (for-each (lambda (header)
		      (display (mkstr (car header) ": " (cdr header) "\r\n") (current-output-port))
		      #t)
		   headerlist)))
   (display "\r\n" (current-output-port))
   (flush-output-port (current-output-port)))


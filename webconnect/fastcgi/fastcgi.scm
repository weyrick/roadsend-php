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

(module fastcgi
   (library php-runtime)
   (library phpeval)
   (library webconnect)
   (library profiler)
   (import (fcgi-binding "fcgi-binding.scm"))
   (load (php-macros "../../php-macros.scm"))
   (include "../../runtime/php-runtime.sch")
;   (main fastcgi-main)
   (export
    (fastcgi-main argv)
    *fastcgi-webapp*)
;    (export
;     (init-fastcgi-lib)
;     (fastcgi-init)
;     (fastcgi-print-headers))
   )


(define *fastcgi-version* (mkstr "Roadsend PHP FastCGI " *RAVEN-VERSION-STRING*))
(define *fastcgi-webapp* #f)

(set! *backend-type* *fastcgi-version*)

(register-extension "fastcgi" "1.0.0"
                    "fastcgi" '("-lfcgi")
                    required-extensions: '("webconnect" "compiler"))

; clean upload temp files at end of page
(define (clean-upload-tmps)
   (when (and (hashtable? *current-uploads*)
	      (> (hashtable-size *current-uploads*) 0))
      (hashtable-for-each *current-uploads*
			  (lambda (k v)
			     (when (file-exists? k)
				(delete-file k))))))

; note this depends on *current-uploads* not already having been cleaned
(add-end-page-reset-func clean-upload-tmps)

(define (fastcgi-main argv)
   (let ((web-doc-root (mkstr (getenv "WEB_DOC_ROOT")))
         (count::int 0))
      
      (args-parse (cdr argv)
         ((("-h" "--help") (help "This help message"))
          (args-parse-usage #f)
          (exit 0))
         ((("-e" "--external") ?port (help "Start an external server on port"))
          (pragma "close(0)")
          (unless (zero? (FCGX_OpenSocket (string-append ":" (integer->string (string->integer port))) 100))
             (php-error "Unable to open socket.")))
	 ((("-i" "--default-index") ?name (help (mkstr "Set the default index page name [default: " *webapp-index-page* "]")))
	  (set! *webapp-index-page* name))
         ((("-n" "--not-found") ?name (help (mkstr "Set the default not found page [default: " *webapp-404-page* "]")))
          (set! *webapp-404-page* name))
         ((("-r" "--web-doc-root") ?root (help "Set the web document root"))
          (set! web-doc-root (mkstr root)))
         (else
          (when (char=? (string-ref else 0) #\-)
             (print "Illegal argument `" else "'. ")
             (args-parse-usage #f)
             (exit 1))))

      (when (getenv "PCC_INDEX_PAGE")
	 (set! *webapp-index-page* (mkstr (getenv "PCC_INDEX_PAGE"))))
      
      (when (getenv "PCC_NOTFOUND_PAGE")
         (set! *webapp-404-page* (mkstr (getenv "PCC_NOTFOUND_PAGE"))))

      (let loop ()
         (when (>= (FCGI_Accept) 0)
            (fastcgi-init)
            (let* ((server-vars (container-value $HTTP_SERVER_VARS))
                   (script-path (if *fastcgi-webapp*
                                    (let ((path (mkstr (php-hash-lookup server-vars "PATH_INFO"))))
				       (if (> (string-length path) 1)
					   (substring path 1 (string-length path))
					   ""))
				    ; apache 1/mod_fastcgi use PATH_TRANSLATED,
				    ; while apache 2/mod_fcgid and lighttpd use SCRIPT_FILENAME
				    (let ((pt (php-hash-lookup server-vars "PATH_TRANSLATED")))
				       (if (string=? (mkstr pt) "")
					   (php-hash-lookup server-vars "SCRIPT_FILENAME")
					   pt))))
                   (content ""))
	       
;                (FCGX_FPrintF err "PATH_INFO %s\nPATH_TRANSLATED %s\nchdir retval %d\n"
;                              (mkstr (php-hash-lookup server-vars "WEB_DOC_ROOT"))
;                              (append-paths (mkstr (php-hash-lookup server-vars "WEB_DOC_ROOT"))
	       ; (php-hash-lookup server-vars "PATH_INFO"))
	       
               (when (and *fastcgi-webapp*
                          (not *static-webapp?*))
                  (load-runtime-libs (list *fastcgi-webapp*)))
               
               
               (chdir (dirname (append-paths web-doc-root   ;(php-hash-lookup server-vars "WEB_DOC_ROOT")
                                             (mkstr (php-hash-lookup server-vars "PATH_INFO")))))
	       ; (FCGX_FPrintF err "webdocroot is now %s\n" (mkstr (php-hash-lookup server-vars "WEB_DOC_ROOT")))
;                (FCGX_FPrintF err "other webdocroot is now %s\n" (mkstr (getenv "WEB_DOC_ROOT")))
;                (FCGX_FPrintF err "pwd is now %s\n" (pwd))
;                (FCGX_FFlush err)
	       
	       ; if no script is passed, default to index page in root
	       (when (or (eqv? script-path '())
			 (string=? script-path "")
			 (string=? script-path (car (command-line))))
		  (set! script-path (file-name-canonicalize (mkstr "/" *webapp-index-page*))))
	       
	       (try (set! content (run-url script-path *fastcgi-webapp* *webapp-index-page*))
		    (lambda (e p m o)
		       (if (eq? o 'file-not-found)
			   (set! content (404-handler script-path))
			   (set! content (runtime-error-handler p m o)))
		       (e #t)))
	       (let ((headers (fastcgi-get-headers)))
		  (FCGI_fwrite headers 1 (string-length headers) FCGI_stdout))
	       (FCGI_fwrite content 1 (string-length content) FCGI_stdout)
	       (FCGI_fflush FCGI_stdout)
	       (loop))))))

; show the runtime error in a nice page, with backtrace
(define (runtime-error-handler p m o)
   (let ((content ""))
      (set-header "Status" "Status" HTTP-INTERNAL-SERVER-ERROR #t)
      ;; using out or err in this error handler seems to screw something up,
      ;; giving us segfaults when we print on them (even outside the error
      ;; handler -- bigloo's boxing it or something)
      (let ((error-message (format "Error: ~A: ~A ~A" p m o))
	    (stack (if (> *debug-level* 2)
		       (with-output-to-string (lambda ()
						 (dump-bigloo-stack
						  (current-output-port) 10)))
		       "")))
	 (set! content (mkstr "<h2><font color=\"red\">" error-message
			      "</h2><pre>" stack "</pre></font>")))
      content))

; try to run the user defined 404 page, otherwise a default Not Found page
(define (404-handler script-path)
   (let ((content ""))
      (try (set! content (run-url (file-name-canonicalize (mkstr "/" *webapp-404-page*))
				  *fastcgi-webapp*
				  *webapp-index-page*))
	   (lambda (e p m o)
	      (if (eq? o 'file-not-found)
		  (begin
		     (set-header "Status" "Status" HTTP-NOT-FOUND #t)
		     (set! content (format "
<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0//EN\">
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL ~a was not found on this server.</p>
<hr>
</body></html>\n" script-path)))
		  (set! content (runtime-error-handler p m o)))
	      (e #t)))
      content))

; (define (print-env out::FCGX_Stream* label::string envp::string*)
;    (FCGX_FPrintF out "%s:<b>\n<pre>\n" label)
;    (let loop ((envp envp))
;       (when (pragma::bool "*$1 != NULL" envp)
;          (FCGX_FPrintF out "%s\n" (pragma::string "*$1" envp))
;          (loop (pragma::string* "$1+1" envp))))
;    (FCGX_FPrintF out "</pre><p>\n"))


               
;               (print "main!")))

; (define (init-fastcgi-lib)
;    1)

(define fastcgi-log-message
   (lambda (msg)
      (fprint (current-error-port) msg)))

(define fastcgi-log-warning
   (lambda (msg)
      (fprint (current-error-port) (format "Warning: ~a " msg))))

(define fastcgi-log-error
   (lambda (msg)
      (fprint (current-error-port) (format "Error: ~a " msg))))

(define (fastcgi-init)
   (let ((server-vars (container-value $HTTP_SERVER_VARS)))
      
      (set! *backend-type* "FASTCGI")
      (set! *headers* (make-hashtable))
      (set! *response-code* HTTP-OK)
      (set! *commandline?* #f)
      
      (set! log-message fastcgi-log-message)
      (set! log-warning fastcgi-log-warning)
      (set! log-error fastcgi-log-error)
      
      ; startup runtime
      (init-php-runtime)
      
      ; define our target   
      (setup-web-target)
      
      ; read settings
      (read-config-file)
      
      ; add default headers
      (header "Content-type: text/html" #t) 
      
      ; $_SERVER vars
      (for-each (lambda (a)
		   (php-hash-insert! server-vars (car a) (cdr a)))
		(environ))
      
;       (let loop ((envp envp))
;          (when (pragma::bool "*$1 != NULL" envp)
;             (multiple-value-bind (var value)
;                (split-on-first #\= (pragma::string "*$1" envp))
;                (php-hash-insert! server-vars var value))           
;             (loop (pragma::string* "$1+1" envp))))

      ;; PHP_SELF is not set by fastcgi, for obvious reasons, but it
      ;; seems to be the same as PATH_INFO (apache1/mod_fastcgi) or SCRIPT_NAME
      (php-hash-insert! server-vars "PHP_SELF"
			(let ((pi (php-hash-lookup server-vars "PATH_INFO")))
			   (if (string=? (mkstr pi) "")
			       (mkstr (php-hash-lookup server-vars "SCRIPT_NAME"))
			       pi)))
      
      ; $_COOKIE
      (parse-cookies (mkstr (php-hash-lookup server-vars "HTTP_COOKIE")))
	    
      ; $_GET and $_POST
      (when (convert-to-boolean (php-hash-lookup server-vars "REQUEST_METHOD"))
         (string-case (php-hash-lookup server-vars "REQUEST_METHOD")
            ("GET" (parse-get-args (mkstr (php-hash-lookup server-vars "QUERY_STRING")))
                   ;; "when the script is valled via the GET method,
                   ;; this will contain the query string", from php.net
                   (php-hash-insert! server-vars "argv"
                                     (mkstr (php-hash-lookup server-vars "QUERY_STRING"))))
            ("POST"
	     ; always handle GET if there (rare)
             (parse-get-args (mkstr (php-hash-lookup server-vars "QUERY_STRING")))
	     ; handle POST, possibly multipart
	     (let* ((ctype (php-hash-lookup server-vars "CONTENT_TYPE"))
		    (content-length (mkfixnum (php-hash-lookup server-vars "CONTENT_LENGTH")))
		    (boundary (if ctype
				  (pregexp-match "^multipart/form-data; boundary=\"*(.+)\"*$" (mkstr ctype))
				  #f))
		    (post-data (if (> content-length 0)
				   (read-post content-length)
				   "")))
		(if boundary
		    ; multipart post
		    (try (let ((upload-max-size (mkfixnum (or (get-ini-entry "upload_max_filesize") 2048000)))
			       (multiparsed (cgi-multipart->list (or (get-ini-entry "upload_tmp_dir") (os-tmp))
								 (open-input-string post-data)
								 (fixnum->elong content-length)
								 (cadr boundary)
								 make-tmpfile-name)))
			    ; handle multipart
			    (for-each (lambda (v)
				; file or variable?
				(if (member :file v)
				    (begin
				       (debug-trace 2 "handle multipart file: " (car v))
				       (if (> content-length upload-max-size)
					   ; file too big
					   (php-warning (mkstr "upload file (" (car v)
							       ") larger than max size: " upload-max-size))
					   ; add to $_FILES
					   (let ((fileinfo (make-php-hash))
						 (id (car v))
						 (filename (caddr v))
						 (tmpname (list-ref v 6))
						 (size content-length))
						 
					      ; add this temp file name onto the list for this page view
					      (hashtable-put! *current-uploads* tmpname #t)
					      (php-hash-insert! fileinfo "name" filename)
					      (php-hash-insert! fileinfo "size" (convert-to-number size))
					      ; this we can get from (list-ref v 4) if we need it
					      ;(php-hash-insert! fileinfo "type" type)
					      (php-hash-insert! fileinfo "tmp_name" tmpname)
					      (php-hash-insert! fileinfo "error" *zero*)
					      ;
					      (php-hash-insert! (container-value $_FILES) id fileinfo))
					   
					   ))
				    (begin
				       (debug-trace 2 "handle multipart  var: " (car v))
				       ; we call store-request-args-in-php-hash so
				       ; it can handle $array_vars[]
				       (store-request-args-in-php-hash
					(container-value $HTTP_POST_VARS)
					(mkstr (car v) "=" (caddr v))
					'normal)
				       (container-value-set! $_POST
							     (copy-php-data
							      (container-value $HTTP_POST_VARS)))
				       (store-request-args-in-php-hash
					(container-value $_REQUEST)
					(mkstr (car v) "=" (caddr v))
					'normal)
				       )))
				      multiparsed))
			 ; multipart post error handler
			 (lambda (e p m o)
			    (php-warning (format "invalid multipart POST request: ~a / ~a" m o))
			    (e #t)))
		    ;
		    ; normal post
		    (parse-post-args post-data))))))


      ;; finally, copy the server vars into $_SERVER. 
      (container-value-set! $_SERVER (copy-php-data (container-value $HTTP_SERVER_VARS)))))

(define (read-post content-length)
   (let ((buffer (make-string content-length)))
      (FCGI_fread buffer 1 content-length FCGI_stdin)
      buffer))

;      (parse-post-args buffer)))


;; "To return an HTTP status other than 200, add a 'Status:' header
;; from your CGI. mod_fastcgi will look for that header and set the
;; HTTP status. The Status: header is not sent to the client, but the
;; HTTP status (first line of the server response) is." (fastcgi docs)

(define  (fastcgi-get-headers)
   (with-output-to-string
      (lambda ()
	 (unless (= *response-code* HTTP-OK)
	    (display (mkstr "Status: " *response-code* "\r\n")))
         (hashtable-for-each *headers*
            (lambda (key headerlist)
               (for-each (lambda (header)
                            (display (mkstr (car header) ": " (cdr header) "\r\n")))
                         headerlist)))
         (display "\r\n"))))


(define (split-on-first char str)
   "Split a string on the first occurrence of char and return the left
   part and right parts as multiple values.  The char is omitted.  If
   the string is empty, both values will be empty.  If the char sign
   is not present, the entire string is returned as the first value."
   (let ((len (string-length str)))
      (do ((i 0 (+ i 1)))
          ((or (>= i len)
               (char=? char (string-ref str i)))
           (values (substring str 0 i)
                   (substring str (min (+ i 1) len)
                              len))))))


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
(module micro-httpd
   (library php-runtime)
   (library phpeval)
   (library webconnect)
   (library profiler)
   (load (php-macros "../../php-macros.scm"))
   (include "../../runtime/php-runtime.sch")
   (import (libws-c-bindings "libws-c-bindings.scm")) 
   (eval (export-all))
   (export
    *micro-web-lib*
    *micro-web-port*
    *micro-web-log*
    *micro-web-current-server*
    *micro-debugger?*
    *micro-web-root*
    ; defbuiltin
    (re_mhttpd_stop)
    ; internal
    (run-micro-server)
    (stop-micro-server)
    (register-micro-handler regexp func)
    (req-handler))
   (extern
    (export req-handler "mhttpd_req_handler"))
    )

;   (main main))

;*---------------------------------------------------------------------*/
;*    Global parameters ...                                            */
;*---------------------------------------------------------------------*/
(define *micro-web-version* (mkstr "Roadsend PHP microhttpd " *RAVEN-VERSION-STRING*))

(define *micro-web-port* 8000)
(define *micro-web-log* 0)

; running from pdb debugger?
(define *micro-debugger?* #f)
; root is only used when microserver needs to interpret from
; files on disk, ie in the debugger. otherwise they come from the web-lib
(define *micro-web-root* #f)

; if this is a real microweb app, the stub sets this
; if this is the debugger, false means we will interpret only
(define *micro-web-lib* #f)

(define *micro-web-current-server* #f)
(define *micro-web-output-port* #f)

; custom handlers. hash table, keyed by a regular expression
; to match on the url, value is a function to call upon match
; XXX this is lazily initialized since it's only used by the
; debugger currently
(define *url-handler-table* #f)

(set! *backend-type* *micro-web-version*)

(define *root-directory* (pwd))

;; logging
(define (mhttpd-log-error message)
   (fprint (current-error-port) "** mhttpd error  : " message)
   (flush-output-port (current-error-port))
   )
(define (mhttpd-log-warning message)
   (fprint (current-error-port) "** mhttpd warning: " message)
   (flush-output-port (current-error-port))
)
(define (mhttpd-log-message message)
   (fprint (current-error-port) "[] " message)
   (flush-output-port (current-error-port))
   )
(define (mhttpd-log-debug message)
   (when (> *debug-level* 0)
      (fprint (current-error-port) "******** mhttpd debug  : " message)
      (flush-output-port (current-error-port))))

(set! log-message mhttpd-log-message)
(set! log-warning mhttpd-log-warning)
(set! log-error mhttpd-log-error)

(define log-debug mhttpd-log-debug)

(define *mime-types* (make-hashtable))

; we hard code these so we don't need an external mime file
; downside is, we have to hope we get everything people need in here
; these come from apache's mime file 
(hashtable-put! *mime-types* 'GIF "image/gif")
(hashtable-put! *mime-types* 'TXT "text")
(hashtable-put! *mime-types* 'JPG "image/jpeg")
(hashtable-put! *mime-types* 'JPEG "image/jpeg")
(hashtable-put! *mime-types* 'PNG "image/png")
(hashtable-put! *mime-types* 'ICO "image/jpeg")
(hashtable-put! *mime-types* 'MOV "video/quicktime")
(hashtable-put! *mime-types* 'JAR "application/java")
(hashtable-put! *mime-types* 'SWF "application/x-shockwave-flash")
(hashtable-put! *mime-types* 'MP3 "audio/mpeg")
(hashtable-put! *mime-types* 'PDF "application/pdf")
(hashtable-put! *mime-types* 'PS  "application/postscript")
(hashtable-put! *mime-types* 'OGG "application/x-ogg")
(hashtable-put! *mime-types* 'XML "application/xml")
(hashtable-put! *mime-types* 'XSL "application/xml")
(hashtable-put! *mime-types* 'DTD "application/xml-dtd")
(hashtable-put! *mime-types* 'ZIP "application/zip")
(hashtable-put! *mime-types* 'TAR "application/x-tar")
(hashtable-put! *mime-types* 'WAV "audio/x-wav")
(hashtable-put! *mime-types* 'JS  "application/x-javascript")
(hashtable-put! *mime-types* 'RA  "audio/x-pn-realaudio")
(hashtable-put! *mime-types* 'RAM "audio/x-pn-realaudio")
(hashtable-put! *mime-types* 'TIF "image/tiff")
(hashtable-put! *mime-types* 'BMP "image/bmp")
(hashtable-put! *mime-types* 'XPM "image/x-xpixmap")
(hashtable-put! *mime-types* 'CSS "text/css")
(hashtable-put! *mime-types* 'RTF "text/rtf")
(hashtable-put! *mime-types* 'DOC "application/msword")
(hashtable-put! *mime-types* 'SGML "text/sgml")
(hashtable-put! *mime-types* 'HTML "text/html")
(hashtable-put! *mime-types* 'HTM "text/html")
(hashtable-put! *mime-types* 'SGM "text/sgml")
(hashtable-put! *mime-types* 'AVI "video/x-msvideo")

;(hashtable-put! *mime-types* ' "")

(define (make-web-path file)
   (if *micro-web-root*
       ; absolute path on current platform based on web root
       (normalize-path (mkstr *micro-web-root* (file-separator) file))
       ; relative path in web lib
       (mkstr "/" file)))

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


; register a new url handler
(define (register-micro-handler regexp func)
   (unless *url-handler-table*
      (set! *url-handler-table* (make-hashtable)))
   (hashtable-put! *url-handler-table* regexp func))
   

;*---------------------------------------------------------------------*/
;*    main ...                                                         */
;*---------------------------------------------------------------------*/
(define (run-micro-server)

   ; define a web target, unless we're in debugger mode
   (unless *micro-debugger?*
      (setup-web-target))
   
   ;so the rest of the system knows that we're in a webserver now
   (set! *commandline?* #f)
   (let* ((server (webserver* 0 0 "" "" 0 "" "" 0
			      (pragma::gethandler* "NULL")
			      (pragma::web-client* "NULL")
			      0))
	 (res (web-server-init server
			       *micro-web-port*
			       (if (string? *micro-web-log*)
				   *micro-web-log*
				   "")
			       0)))

      (when (eqv? res 0)
	 (log-error "Server would not start.")
	 (exit 1))

      ; set port constant
      (defconstant RE_MHTTPD_PORT *micro-web-port*)

      ; possibly run startup page, showing output in stderr and ignoring if not found
      (try (let ((content (run-url (make-web-path "mhttpd_startup.inc") *micro-web-lib* "")))
	      (when (and (string? content)
			 (> (string-length content) 0))
		 (display content (current-error-port))
		 (flush-output-port (current-error-port))))
	   (lambda (e p m o)
	      (if (not (eq? o 'file-not-found))		  
		  ;(mhttpd-log-error (format "Error: ~A: ~A ~A" p m o)))
                  (handle-runtime-error e p m o))
	      (e #t)))

      ; notice, if debug
      (when (> *debug-level* 0)
	    (log-message (format "Running http server on http://localhost:~a/"  *micro-web-port*))
	    (when (string? *micro-web-log*)
		  (log-message (mkstr "Logging requests to " *micro-web-log*))))

      ; save outport port. this is needed because in run-url we do some redirection
      ; and (current-output-port) may not be the one we need
      (set! *micro-web-output-port* (current-output-port))
      
      ; our request handler callback
      (web-server-addhandler server "* *" (pragma::void* "mhttpd_req_handler") 0)

      ; run until a signal forces us to stop
      (set! *micro-web-current-server* server)
      (web-server-run server)

      ; doesn't ever reach here because signal handler exits()
      #t))

(define (stop-micro-server)
   (when *micro-web-current-server*
      (web-server-stop *micro-web-current-server*)))

; this is so php scripts can stop the server programatically
(defbuiltin (re_mhttpd_stop)
   (stop-micro-server))

; main request handler
(define (req-handler)
   (let* ((request (pragma::string "ClientInfo->request"))
	  (inetname (pragma::string "ClientInfo->inetname"))
	  (method (pragma::string "ClientInfo->method"))
	  (user (pragma::string "ClientInfo->user"))
	  (pass (pragma::string "ClientInfo->pass"))
	  (header (pragma::string "ClientInfo->Header(NULL)"))
	  (content-type (pragma::string "ClientInfo->Header(\"Content-type\")"))
	  (query (cond ((string=? "POST" (mkstr method)) (pragma::string "ClientInfo->Post(NULL)"))
		       (else (pragma::string "ClientInfo->Query(NULL)"))))
	  (cookie (pragma::string "ClientInfo->Cookie(NULL)")))

      (set! *headers* (make-hashtable))
      (set! *response-code* HTTP-OK)

      ;(log-debug (mkstr "content-type: " content-type))
      ;(log-debug (mkstr "headers: " header))
      
      ; servervars
      (php-hash-insert! (container-value $_SERVER) "REQUEST_URI" request)
      (php-hash-insert! (container-value $_SERVER) "REQUEST_METHOD" method)
      (php-hash-insert! (container-value $_SERVER) "QUERY_STRING" query)
      (php-hash-insert! (container-value $_SERVER) "SERVER_PORT" (convert-to-integer *micro-web-port*))
      (php-hash-insert! (container-value $_SERVER) "SERVER_SOFTWARE" (mkstr *micro-web-version*))
      (php-hash-insert! (container-value $_SERVER) "REMOTE_ADDR" inetname)

      (unless (string=? user "")
	 (php-hash-insert! (container-value $_SERVER) "PHP_AUTH_USER" user))
      (unless (string=? pass "")
	 (php-hash-insert! (container-value $_SERVER) "PHP_AUTH_PW" pass))

      ; if a directory is requested, try the index page
      (when (char=? (string-ref request (- (string-length request) 1)) #\/)
	 (set! request (mkstr request *webapp-index-page*)))

      (php-hash-insert! (container-value $_SERVER) "PHP_SELF" request)
      (php-hash-insert! (container-value $_SERVER) "SCRIPT_NAME" request)
      (php-hash-insert! (container-value $_SERVER) "DOCUMENT_ROOT" (pwd))
      (php-hash-insert! (container-value $_SERVER) "SCRIPT_FILENAME" (normalize-path (mkstr (pwd) request)))
      (php-hash-insert! (container-value $_SERVER) "PATH_TRANSLATED" (normalize-path (mkstr (pwd) request)))
      
      ; cookies
      (parse-cookies cookie)

      ; upload?
      (when (pregexp-match "^multipart/form-data" content-type)
	 (parse-multipart-form header)) 

      (debug-trace 2 "processing request: " request)
      
      (cond ((string=? method "GET") (http-get request query))
	    ((string=? method "POST") (http-post request query))
	    (else
	     (http-reply (mkstr "Unknown method: " method))))

      ))


; libwebserver doesn't let us know which variables are available in the
; multipart form. currently we parse the header ourself to find out. we could
; change libwebserver instead....
(define (parse-multipart-form header)
   ;
   ; check some ini settings first
   ;
   (when (eqv? (convert-to-boolean (get-ini-entry "file_uploads")) TRUE)

      ; get list of variables from client
      (let ((upload-tmp-dir (or (get-ini-entry "upload_tmp_dir") (os-tmp)))
	    (upload-max-size (or (get-ini-entry "upload_max_filesize") 2048000))
	    (form-vars (let* ((length (string-length header))
			      (compiled-pattern (pregexp "Content-Disposition: form-data; name=\"([^\"]+)\"")))
			  (let loop ((frags '())
				     (start 0))
			     (let ((pos (pregexp-match-positions compiled-pattern header start length)))
				;(fprint (current-error-port) "loop pos: " pos)
				(if pos
				    ;if we matched, save the match and go again, starting after the match
				    (loop (cons (substring header (caadr pos) (cdadr pos)) frags)
					  (cdar pos))
				    ;if it didn't match, return the fragments
				    frags))))))
	 ;
	 ;(fprint (current-error-port) "multipart names: " form-vars))
	 ;
	 ; parse form variables. handle uploadeded files and regular POST variables
	 ;
	 (when form-vars
	    (let loop ((vlist form-vars))
	       (when (pair? vlist)
		  (let* ((id::string (car vlist))

			 (size (pragma::int "ClientInfo->MultiPart($1).size" id))
			 (data (pragma::bstring "string_to_bstring_len(ClientInfo->MultiPart($1).data, $2)" id size))
			 (filename (pragma::string "ClientInfo->MultiPart($1).filename" id)))

		     ;(fprint (current-error-port) "id: " id ", size: " size ", filename: " filename)

		     ; is this a file or a variable?
		     (if (string=? filename "")
			 ; variable
			 (begin
;			    (log-debug (mkstr "found variable in " id))
			    
			    ; we call store-request-args-in-php-hash so
			    ; it can handle $array_vars[]
			    (store-request-args-in-php-hash
			     (container-value $_POST)
			     (mkstr id "=" data)
			     "&")
			    (store-request-args-in-php-hash
			     (container-value $_REQUEST)
			     (mkstr id "=" data)
			     "&")
			    )
			 ; file
			 (if (<= size upload-max-size) 
			     (let ((tmpname (make-tmpfile-name upload-tmp-dir "pcc"))
				   (fileinfo (make-php-hash)))
;				(log-debug (mkstr "found file in " id " temp is " tmpname))
				; write data to temp file
				(if (file-exists? tmpname)
				    (php-error (mkstr "upload temp file already exists: " tmpname))
				    (with-output-to-binary-file (of tmpname)
								(output-string of data)))				     
				; add this temp file name onto the list for this page view
				(hashtable-put! *current-uploads* tmpname #t)
				(php-hash-insert! fileinfo "name" filename)
				(php-hash-insert! fileinfo "size" (convert-to-number size))
				;(php-hash-insert! fileinfo "type" (mkstr (aptable-get (ApacheUpload*-info cur-upload) "Content-type")))
				(php-hash-insert! fileinfo "tmp_name" tmpname)
				(php-hash-insert! fileinfo "error" *zero*)
				;
				(php-hash-insert! (container-value $_FILES) id fileinfo))
			     ; file too big
			     (php-warning (mkstr "uploaded file (" id ") larger than max size: " upload-max-size))))
		     ; next!
		     (loop (cdr vlist))
		     ))))
	 ;
	 )))

(define (get-mime-type fname)
   (let* ((ext (string->symbol (string-upcase (suffix fname))))
	  (mtype (hashtable-get *mime-types* ext)))
      ;(print "mimetype for " ext " was " mtype)
      (if mtype
	  mtype
	  "application/octect-stream")))  

; this makes sure user headers, session headers etc are in place
(define (do-headers)
   (hashtable-for-each *headers*
      (lambda (key headerlist)
	 (for-each (lambda (header)
		      ; XXX
		      ;(mhttpd-log-error (mkstr "Adding header type: " (car header) ", value: " (cdr header)))
		      (display (mkstr (car header) ": " (cdr header) "\r\n") *micro-web-output-port*)
		      #t)
		   headerlist))))

(define (http-binary-file file-name)
   (let* ((bin-file (substring file-name 1 (string-length file-name)))
	  (file-length (if (and (file-exists? bin-file)
				(not (directory? bin-file)))
			   (file-size bin-file)
			   0)))
      (debug-trace 2 "serving binary file: " bin-file ", len: " file-length)
     (cond 
      ((= file-length 0)
       (begin
	  ; if it's a directory, try the index of that directory
	  (if (directory? bin-file)
	      (http-get-php (mkstr file-name "/" *webapp-index-page*))
	      (http-fnf bin-file))))
      (else
       (web-client-h-ttpdirective (mkstr "HTTP/1.1 " *response-code* " OK"))

       (set-header "Content-Type" (get-mime-type bin-file) #t)
       (set-header "X-Powered-By" *RAVEN-VERSION-TAG* #f)
       (set-header "Content-Length" file-length #t)
       (set-header "Connection" "close" #t)
       (do-headers)
       
       (display "\r\n" *micro-web-output-port*)
       (web-client-addfile bin-file)))))

; try to run user defined 404 page, otherwise default Not Found
(define (http-fnf fname)
   (set! *response-code* HTTP-NOT-FOUND)
   (try (let ((content (run-url (make-web-path *webapp-404-page*)
				*micro-web-lib*
				*webapp-index-page*)))
	   (http-reply content))
	(lambda (e p m o)
	   (if (eq? o 'file-not-found)
	       (begin
		  (http-reply (format "
<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0//EN\">
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL ~a was not found on this server.</p>
<hr>
<address>~a port ~a</address>
</body></html>" fname *micro-web-version* *micro-web-port*)))
	       (http-reply (format "Error: ~A: ~A ~A" p m o)))
	   (e #t))))


(define (http-reply str)

   (web-client-h-ttpdirective (mkstr "HTTP/1.1 " *response-code* " OK"))

   (set-header-if-empty "Content-Type" "text/html")
   (set-header-if-empty "X-Powered-By" *RAVEN-VERSION-TAG*)
   (set-header-if-empty "Content-Length" (string-length str))
   (set-header-if-empty "Connection" "close")
   (do-headers)
   
   (display "\r\n" *micro-web-output-port*)
   (display str *micro-web-output-port*))   


(define (http-get url query)
   (parse-get-args query)
   (let ((handled #f))
      (when *url-handler-table*
	 (hashtable-for-each *url-handler-table*
			     (lambda (k f)
				(when (pregexp-match k url)
				   (http-reply (mkstr (f url)))
				   (set! handled #t)))))
      (unless handled   
	 (case (string->symbol (suffix url))	 
	    ((php)
	     (http-get-php url))
	    (else
	     (http-binary-file url))))))

(define (http-post url query)
   (parse-post-args query)
   (let ((handled #f))
      (when *url-handler-table*
	 (hashtable-for-each *url-handler-table*
			     (lambda (k f)
				(when (pregexp-match k url)
				   (http-reply (mkstr (f url)))
				   (set! handled #t)))))
      (unless handled
	 (case (string->symbol (suffix url))	 
	    ((php)
	     (http-get-php url))
	    (else
	     (http-binary-file url))))))


(define (http-get-php file)
   (try (let ((content (run-url (make-web-path (substring file 1 (string-length file)))
				*micro-web-lib* *webapp-index-page*)))
	   (http-reply content))
	(lambda (e p m o)
	   (if (eq? o 'file-not-found)
	       (http-fnf file)
	       (http-reply (format "Error: ~A: ~A ~A" p m o)))
	   (e #t))))

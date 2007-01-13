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

(module apache2
   (library webconnect)
   (library phpeval)
;   (library php-std)
   (library php-runtime)
   (include "../runtime/php-runtime.sch")
   (export (aplog lvl msg)
	   (apache-run-url::int ::ApacheRequest*)
;	   (slub-apache-run-url::int ::string)
;	   (apache-run-webapp::int areq::ApacheRequest* webapp-lib::string mount-point::string index-file::string)
	   (apache-run-webapp::int areq::ApacheRequest* webapp-lib::string filename::string directory::string index-file::string)
	   (apache-process-upload::int upload::ApacheUpload*)
	   (apache-get-ini-string::string key::string)
	   (apache-get-ini-num::int key::string)
	   (handle-config-directive::int ::string ::string))

   (main init-apache-backend)

   (extern
    (include "windows-apache2.h")

    (type aptable (opaque) "apr_table_t*")
    (type appool (opaque) "apr_pool_t*")
    
    ;;the apache types
    (type request-rec
	  (struct (uri::string "uri")
		  (filename::string "filename")
		  (args::string "args")
		  (content-type::string "content_type")
		  (header-only::int "header_only")
		  (headers-out::aptable "headers_out")
		  (headers-in::aptable "headers_in")
		  (status::int "status")
		  (method::string "method")
		  (pool::appool "pool")
		  (subprocess-env::aptable "subprocess_env"))
	  "request_rec")

    (type server-rec
	  (struct)
	  "server_rec")

    (type table-entry
	  (struct (key::string "key")
		  (val::string "val"))
	  "apr_table_entry_t")

    (type array-header
	  (struct (pool::appool "pool")
		  (elt-size::int "elt_size")
		  (nelts::int "nelts")
		  (nalloc::int "nalloc")
		  (elts::table-entry* "elts"))
	  "apr_array_header_t")

    (type ApacheUpload
	  (struct (next::ApacheUpload* "next")
		  (filename::string "filename")
		  (name::string "name")
		  (tempname::string "tempname")
		  (info::aptable "info")
		  (size::long "size"))
	  "ApacheUpload")

    (type ApacheRequest
	  (struct (parms::aptable "parms")
		  (req::request-rec* "r"))
	  "ApacheRequest")		  	   

    (type ApacheCookie
	  (struct (name::string "name"))
	  "ApacheCookie")

    (type ApacheCookieJar
	  (struct (pool::appool "pool")
		  (elt-size::int "elt_size")
		  (nelts::int "nelts")
		  (nalloc::int "nalloc")
		  (elts::ApacheCookie* "elts"))
	  "ApacheCookieJar")

    (macro ap-cookie-parse::ApacheCookieJar* (req::request-rec*
					      data::int) ;;actually a const char *
	   "ApacheCookie_parse")
    
    (macro ap-cookiejar-fetch::ApacheCookie* (jar::ApacheCookieJar*
					      num::int)
	   "ApacheCookieJarFetch")

    (macro ap-cookie-numvals::int (cookie::ApacheCookie*)
	   "ApacheCookieItems")
    
    (macro ap-cookie-fetch::string (cookie::ApacheCookie*
				    num::int)
	   "ApacheCookieFetch")
    
    (macro aptable-add::void (table::aptable
			      name::string
			      value::string)
	   "apr_table_add")

    (macro aptable-get::string (table::aptable
				name::string)
	   "(char*)apr_table_get")

    (macro aptable-elts::array-header* (table::aptable)
	   "apr_table_elts")

    (macro ap-uudecode::string (pool::appool
				bufcoded::string)
	   "ap_pbase64decode")

    ; XXX apreq v2
    (macro apreq-params-as-array::array-header (pool::appool
						table::aptable
						key::string)
	   "apreq_params_as_array")	   
	   

    
    ;;the log levels
    (macro aplog-emerg::int "APLOG_EMERG")
    (macro aplog-alert::int "APLOG_ALERT")
    (macro aplog-crit::int "APLOG_CRIT")
    (macro aplog-err::int "APLOG_ERR")
    (macro aplog-warning::int "APLOG_WARNING")
    (macro aplog-notice::int "APLOG_NOTICE")
    (macro aplog-info::int "APLOG_INFO")
    (macro aplog-debug::int "APLOG_DEBUG")
    (macro aplog-noerrno::int "APLOG_NOERRNO")

    ;;module return codes
    (macro declined::int "DECLINED")
    (macro done::int "DONE")
    (macro ok::int "OK")

    ; status, used in log functions
;    (macro apr-status::int "apr_status_t")
    
    ;;the apache functions
    (macro ap-rputs::int (str::string
			  r::request-rec*)
	   "ap_rputs")

    ;send Status-Line and header fields for HTTP response
    ; XXX not in apache2
;    (macro ap-send-http-header::void (r::request-rec*)
;	   "ap_send_http_header")
     
    ;log a request error
    (macro ap-log-rerror::void (file::string
				line::int
				level::int
				status::int				
				r::request-rec*
				fmt::string
				. ::long)
	   "ap_log_rerror")
    ;log an error with no request
    (macro ap-log-error::void (file::string
			       line::int
			       level::int
			       status::int
			       s::server-rec*
			       fmt::string
			       . ::long)
	   "ap_log_error")

    (macro add-common-vars::void (r::request-rec*)
	   "ap_add_common_vars")

    (macro add-cgi-vars::void (r::request-rec*)
	   "ap_add_cgi_vars")
    
    ;(macro read-request-body::string (r::request-rec*)
	;   "pcc_read_request_body")

    (export apache-run-url "run_url")
    (export apache-run-webapp "run_webapp")
    (export apache-process-upload "process_upload")
    (export apache-get-ini-string "pcc_get_ini_string")
    (export apache-get-ini-num "pcc_get_ini_num")
    (export handle-config-directive "handle_config_directive")))


(define *current-request* #f)

(define (init-apache-backend argv)
   (set! *backend-type* "Apache")
   (set! *headers* (make-hashtable))
   (set! *response-code* HTTP-OK)
   (set! log-message apache-log-message)
   (set! log-warning apache-log-warning)
   (set! log-error apache-log-error)

   ;(apache-log-error ">>>>>>>>>>> init-apache-backend")

   ; startup runtime
   (init-php-runtime)

   ; define our target   
   (setup-web-target)

   ; read settings
   (read-config-file)
   
   ;so the rest of the system knows that we're in a webserver now
   (set! *commandline?* #f) )

; handle apache configuration directives
; XXX note this appears to get called from apache sometimes when run-url isn't!
;     it needs to be careful not to upset the reset runtime state
;     if it's not serving a page
(define (handle-config-directive::int arg1::string arg2::string)
;   (fprint (current-error-port) "handle-config-directive arg1 arg2")
   (string-case arg1
      ("include_path" (set-temp-include-paths! (unix-path->list arg2))))
   (when (> *debug-level* 1)
      (apache-log-message (format "directive ~a => ~a" arg1 arg2)))
   0)


; for access from mod_pcc
(define (apache-get-ini-string key)
   (mkstr (get-ini-entry key)))

(define (apache-get-ini-num key)
   (mkfixnum (get-ini-entry key)))

; process an upload from client
(define (apache-process-upload upload::ApacheUpload*)
;     (apache-log-message (format "file upload [~a] [~a] [~a]"
;  			       (ApacheUpload*-filename upload)
;  			       (ApacheUpload*-name upload)
;  			       (ApacheUpload*-tempname upload)))
   ;
   (let loop ((cur-upload upload))
      (let ((fileinfo (make-php-hash)))
	 ; add this temp file name onto the list for this page view
	 (hashtable-put! *current-uploads* (mkstr (ApacheUpload*-tempname cur-upload)) #t)
	 (php-hash-insert! fileinfo "name" (mkstr (ApacheUpload*-filename cur-upload)))
	 (php-hash-insert! fileinfo "size" (convert-to-number (ApacheUpload*-size cur-upload)))
	 (php-hash-insert! fileinfo "type" (mkstr (aptable-get (ApacheUpload*-info cur-upload) "Content-type")))
	 (php-hash-insert! fileinfo "tmp_name" (mkstr (ApacheUpload*-tempname cur-upload)))
	 (php-hash-insert! fileinfo "error" *zero*)
	 (php-hash-insert! (container-value $_FILES)
			   (ApacheUpload*-name cur-upload)
			   fileinfo))
      ; possibly handle multiple uploads
      (when (pragma::bool "$1 != NULL" (ApacheUpload*-next cur-upload))
	  (loop (ApacheUpload*-next cur-upload))))
   1)

; might run a web app if it's in our list
; called from mod_pcc
(define (apache-run-webapp::int areq::ApacheRequest* webapp-lib::string
				filename::string directory::string index-file::string)
   (let ((req (ApacheRequest*-req areq)))
      (when (> *debug-level* 0) 
	 (apache-log-message (format "run-webapp: uri [~A] filename [~A] webapp-lib [~A] directory [~A], index-file [~A]"
				     (request-rec*-uri req) filename webapp-lib directory index-file)))
      (when (directory? directory)
	 (chdir directory))
      (do-run-url areq filename webapp-lib index-file)))

;    (let ((app-filename (find-web-app (request-rec*-uri req))))
;       ;(apache-log-message (format "checking for webapp with [~a] got [~a]" (request-rec*-uri req) app-filename))
;       (if app-filename
; 	  (do-run-url req app-filename)
; 	  declined)))

; only runs a url (interpreted)
; called from mod_pcc
(define (apache-run-url::int areq::ApacheRequest*)
   (let ((req (ApacheRequest*-req areq)))
;   (apache-log-error (format "in apache-run-url,  running ~a" (request-rec*-filename req))) 
      (do-run-url areq (request-rec*-filename req) #f #f)))

; will run either a web app or a url
; called only internally
(define (do-run-url areq filename webapp-lib index-file)
   (let ((req (ApacheRequest*-req areq)))
      (set! *current-request* req)
      (if (not (or webapp-lib (file-exists? filename)))
	  declined
	  (bind-exit (return)
	     ; these two calls add variables used in _SERVER
	     (add-common-vars req)
	     (add-cgi-vars req)
	     ;
	     (string-case (request-rec*-method req)
		("GET" (apreq-parse-get-vars areq))
		("POST" (apreq-parse-get-vars areq)
                        (apreq-parse-post-vars areq))
		(else (apache-log-warning (format "Don't know how to handle request type: ~A"
						  (request-rec*-method req)))))
	     ; server vars
	     (register-server-vars req)
	     (let ((content ""))
		(try (set! content (run-url filename webapp-lib index-file))
		     (lambda (e p m o)
			(if (eq? o 'file-not-found)
			    (begin
			       (apache-log-error (format "PCC file not found: ~A" filename))
			       (return HTTP-NOT-FOUND))
			    (begin
			       (apache-log-error (format "Error: ~A: ~A ~A" p m o))
			       (return HTTP-INTERNAL-SERVER-ERROR)))
			(e #t)))
		(add-headers-to-request req)
		(request-rec*-status-set! req *response-code*)
		(request-rec*-content-type-set! req "text/html")
;		(ap-send-http-header req)
		(when (zero? (request-rec*-header-only req))
		   (ap-rputs content req))
		(set! *current-request* #f)
		(set! *headers* (make-hashtable))
		ok) ))))

   
; setup HTTP_SERVER_VARS and _SERVER
; (define (register-server-vars req::request-rec*)
;    ; get SERVER variables
;    (aptable->php-hash (request-rec*-subprocess-env req) (container-value $HTTP_SERVER_VARS))
;    ; register PATH_TRANSLATED
;    ; XXX is it ok to generate it this way?
;    (let ((docroot (aptable-get (request-rec*-subprocess-env req) "DOCUMENT_ROOT")))
;       (when (> (string-length docroot) 0)
; 	 (php-hash-insert! (container-value $HTTP_SERVER_VARS)
; 			   "PATH_TRANSLATED"
; 			   (string-append docroot (request-rec*-uri req)))))
;    ; register PHP_SELF
;    (php-hash-insert! (container-value $HTTP_SERVER_VARS) "PHP_SELF" (request-rec*-uri req)))

(define (register-server-vars req::request-rec*)

   (let ((headers (make-php-hash)))
      
      ; get SERVER variables
      (aptable->php-hash (request-rec*-subprocess-env req) (container-value $HTTP_SERVER_VARS))
      
      ; HEADERS - this is a pcc extension, php doesn't do this
      (aptable->php-hash (request-rec*-headers-in req) headers)
      (php-hash-insert! (container-value $HTTP_SERVER_VARS) "HEADERS" headers)

      ; AUTH
      (let ((auth-header (php-hash-lookup headers "Authorization")))
	 (when (and (string? auth-header)
		    (substring=? auth-header "Basic " 6))
	    (let* ((magic (substring auth-header 6 (string-length auth-header)))
		   (auth (ap-uudecode (request-rec*-pool req) magic))
		   ; XXX is this insecure?
		   (userpass (pregexp-split ":" auth)))
	       ;(apache-log-error (format "auth is ~a from ~a" auth magic))
	       (when userpass
		  (php-hash-insert! (container-value $HTTP_SERVER_VARS) "PHP_AUTH_USER" (car userpass))
		  (when (= (length userpass) 2)
		     (php-hash-insert! (container-value $HTTP_SERVER_VARS) "PHP_AUTH_PW" (cadr userpass)))))))

      ; COOKIES
;       (let ((cookie-header (php-hash-lookup headers "Cookie")))
; 	 (when (string? cookie-header)
; 	    (parse-cookies cookie-header)))
      (apreq-parse-cookies req)
      
      ; register PATH_TRANSLATED
      ; XXX is it ok to generate it this way?
      (let ((docroot (aptable-get (request-rec*-subprocess-env req) "DOCUMENT_ROOT")))
	 (when (> (string-length docroot) 0)
	    (php-hash-insert! (container-value $HTTP_SERVER_VARS)
			      "PATH_TRANSLATED"
			      (string-append docroot (request-rec*-uri req)))))
      
      
      ; register PHP_SELF
      (php-hash-insert! (container-value $HTTP_SERVER_VARS) "PHP_SELF" (request-rec*-uri req))

      ;; finally, copy the server vars into $_SERVER. 
      (container-value-set! $_SERVER (copy-php-data (container-value $HTTP_SERVER_VARS)))))

; convert an apache table to a php-hash
; this also magically converts variables named as arrays
; ie "name[]" or "name[key]" to php hashs
(define (aptable->php-hash table::aptable phphash)
;   (debug-trace 2 "in aptable->php-hash")
   (let* ((header (aptable-elts table))
	  (num-iter (array-header*-nelts header))
	  (entrylist (array-header*-elts header)))
      (let loop ((i::int 0))
	 (when (< i num-iter)
	    (if (pragma::bool "(int)($1[$2].val)" entrylist i)
		(let* ((k (pragma::string "$1[$2].key" entrylist i))
		       (v (pragma::string "$1[$2].val" entrylist i))
		       (amatch (pregexp-match "^(\\w+)\\[(\\w*)\\]$" k)))
;		   (debug-trace 2 "sucking in " k " => " v " amatch: " amatch)
		   ; convert to hash?
		   (cond ((not amatch) (php-hash-insert! phphash k v))
		         ; array, no key
		         ((string=? (list-ref amatch 2) "") (let* ((h1 (php-hash-lookup phphash (list-ref amatch 1)))
								   (h (if h1 h1 (make-php-hash))))
							       ; XXX
							       ;(log-message (format "adding hash with no key: ~a" (list-ref amatch 1)))
							       ; do we have to convert h to a hash?
							       (unless (php-hash? h)
								  (set! h (convert-to-hash h)))
							       (php-hash-insert! h :next v)
							       (php-hash-insert! phphash (list-ref amatch 1) h)))
		         ; array with key
		         (else (let* ((h1 (php-hash-lookup phphash (list-ref amatch 1)))
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
				  (php-hash-insert! phphash (list-ref amatch 1) h))))) 
		;
		(php-hash-insert! phphash
				  (pragma::string "$1[$2].key" entrylist i) ""))
	    (loop (+ i 1))))))


(define (get-cookie-vals cookie::ApacheCookie*)
   (let ((numvals (ap-cookie-numvals cookie)))
      (let loop ((i 0)
		 (vals ""))
	 (if (< i numvals)
	     (loop (+ i 1) (string-append vals (ap-cookie-fetch cookie i)))
	     vals)))) 

(define (apreq-parse-cookies req::request-rec*)
   (let* ((jar (ap-cookie-parse req (pragma::int "NULL")))
	  (num-iter (ApacheCookieJar*-nelts jar)))
      (let loop ((i 0))      
	 (when (< i num-iter)
	    (let ((cookie (ap-cookiejar-fetch jar i)))
	       (store-cookie-val (ApacheCookie*-name cookie)
				 (get-cookie-vals cookie))
	       (loop (+ i 1)))))))
   

(define (apreq-parse-get-vars req::ApacheRequest*)
   (aptable->php-hash (ApacheRequest*-parms req) (container-value $HTTP_GET_VARS))
   (aptable->php-hash (ApacheRequest*-parms req) (container-value $_REQUEST)))

(define (apreq-parse-post-vars req::ApacheRequest*)
   ;(debug-trace 2 "parsing post variables")
   (aptable->php-hash (ApacheRequest*-parms req) (container-value $HTTP_POST_VARS))
   (aptable->php-hash (ApacheRequest*-parms req) (container-value $_REQUEST)))

(define (add-headers-to-request req::request-rec*)
   (hashtable-for-each *headers*
      (lambda (key headerlist)
	 (for-each (lambda (header)
		      ;(fprint (current-error-port) "Adding header type: " (car header) ", value: " (cdr header))
		      (aptable-add (request-rec*-headers-out req) (car header) (cdr header))
		      #t)
		   headerlist))))

(define (aplog lvl msg)
   (if *current-request*
       (ap-log-rerror "" 0
		      (bit-or aplog-noerrno lvl)
		      0
		      *current-request* msg)
       (ap-log-error "" 0
		     (bit-or aplog-noerrno lvl)
		     0
		     (make-null-server-rec*) msg))
   #unspecified)


(define (apache-log-message message)
   (aplog aplog-notice message))

(define (apache-log-warning message)
   (aplog aplog-warning message))

(define (apache-log-error message)
   (aplog aplog-err message))

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

(module webconnect
   (library php-runtime)
   (library profiler)
   (load (php-macros "../php-macros.scm"))
   (include "../runtime/php-runtime.sch")
   ; tmp until we move to bigloo 2.8
   (from (__web_cgi "cgi.scm"))
   (eval (export-all))
   (export
    (init-webconnect-lib)
    *backend-type*
    *headers*
    *response-code*
    *ignore-user-abort*
    *static-webapp?*
    ; web app pages
    *webapp-index-page*
    *webapp-404-page*
    ;
    log-message
    log-warning
    log-error
    header
    headers_sent
    import_request_variables
    setcookie
    (set-header header-type header-key header-value replace)
    (is_uploaded_file filename)
    (move_uploaded_file filename dest)
    *current-uploads*
    (ignore_user_abort val)
    (store-cookie-val key val)
    (urldecode str)
    (store-request-args-in-php-hash php-hash a-string delim)
    (parse-get-args args)
    (parse-post-args args)
    (parse-cookies args)
    ;;response codes
    HTTP-CONTINUE                      
    HTTP-SWITCHING-PROTOCOLS           
    HTTP-PROCESSING                    
    HTTP-OK                            
    HTTP-CREATED                       
    HTTP-ACCEPTED                      
    HTTP-NON-AUTHORITATIVE             
    HTTP-NO-CONTENT                    
    HTTP-RESET-CONTENT                 
    HTTP-PARTIAL-CONTENT               
    HTTP-MULTI-STATUS                  
    HTTP-MULTIPLE-CHOICES              
    HTTP-MOVED-PERMANENTLY             
    HTTP-MOVED-TEMPORARILY             
    HTTP-SEE-OTHER                     
    HTTP-NOT-MODIFIED                  
    HTTP-USE-PROXY                     
    HTTP-TEMPORARY-REDIRECT            
    HTTP-BAD-REQUEST                   
    HTTP-UNAUTHORIZED                  
    HTTP-PAYMENT-REQUIRED              
    HTTP-FORBIDDEN                     
    HTTP-NOT-FOUND                     
    HTTP-METHOD-NOT-ALLOWED            
    HTTP-NOT-ACCEPTABLE                
    HTTP-PROXY-AUTHENTICATION-REQUIRED 
    HTTP-REQUEST-TIME-OUT              
    HTTP-CONFLICT                      
    HTTP-GONE                          
    HTTP-LENGTH-REQUIRED               
    HTTP-PRECONDITION-FAILED           
    HTTP-REQUEST-ENTITY-TOO-LARGE      
    HTTP-REQUEST-URI-TOO-LARGE         
    HTTP-UNSUPPORTED-MEDIA-TYPE        
    HTTP-RANGE-NOT-SATISFIABLE         
    HTTP-EXPECTATION-FAILED            
    HTTP-UNPROCESSABLE-ENTITY          
    HTTP-LOCKED                        
    HTTP-FAILED-DEPENDENCY             
    HTTP-INTERNAL-SERVER-ERROR         
    HTTP-NOT-IMPLEMENTED               
    HTTP-BAD-GATEWAY                   
    HTTP-SERVICE-UNAVAILABLE           
    HTTP-GATEWAY-TIME-OUT              
    HTTP-VERSION-NOT-SUPPORTED         
    HTTP-VARIANT-ALSO-VARIES           
    HTTP-INSUFFICIENT-STORAGE          
    HTTP-NOT-EXTENDED ))


(define (init-webconnect-lib)
   1)

(register-extension "webconnect" "1.0.0" "webconnect"
                    required-extensions: '("compiler"))

;;;these functions and variables are the generic names for the stuff
;;;exposed by the various backends.

(define *backend-type* "No backend")

(define *ignore-user-abort* #f)

; used in driver.scm, run-url to signal that we shouldn't
; try to load the webapp (and extensions) dynamically, since they're already compiled in
(define *static-webapp?* #f)

; default page micro/fastcgi
(define *webapp-index-page* "index.php")
; default 404 not found page
(define *webapp-404-page* "404.php")

;;;written with lambda to emphasize their variable aspect

;;write messages to the webserver's log
(define log-message
   (lambda (msg)
      (error 'log-message
	     (format "This function is not implemented by the ~a backend." *backend-type*)
	     msg)))

(define log-warning
   (lambda (msg)
      (error 'log-warning
	     (format "This function is not implemented by the ~a backend." *backend-type*)
	     msg)))

(define log-error
   (lambda (msg)
      (error 'log-error
	     (format "This function is not implemented by the ~a backend." *backend-type*)
	     msg)))


(define *headers* 'unset)

(define *response-code* 'unset)

(define (set-header header-type header-key header-value replace)
   (debug-trace 2 (mkstr "set header ===> " header-type " / " header-key " / " header-value))
   (unless (eqv? *headers* 'unset)
      (set! header-key (string-downcase header-key))
      (if replace
	  (hashtable-put! *headers* header-key (list (cons header-type header-value)))
	  (hashtable-put! *headers* header-key
			  (let ((similar-header (hashtable-get *headers* header-key)))
			     (if similar-header
				 (cons (cons header-type header-value) similar-header)
				 (list (cons header-type header-value))))))))

(define (store-cookie-val key val)
   (php-hash-insert! (container-value $HTTP_COOKIE_VARS) key val)
   (php-hash-insert! (container-value $_REQUEST) key val))

; convert "foo[val1][val2][val3]...[valN]" given in GET/POST to
; a list that's easy to parse into a php hash
; the result is (varname . (index1 index2 index3 indexN))
; or if there were no (valid) indexes, just (varname . nil)
(define (cgi-array->php-array val)
   (let* ((key-list '())
	  (field-name "")
	  (gram (regular-grammar ((identifier (: (or alpha "_") (* (or alnum "_")))))
		   ((bol identifier)
		    (set! field-name (the-string))
		    (ignore))
		   ((: "[" (+ (out "]")) "]" )
		    (set! key-list (cons (the-substring 1 (-fx (the-length) 1))
					 key-list))
		    (ignore))
		   (else
		    (reverse key-list)))))
      (let ((p (open-input-string val)))
	 (let ((res (read/rp gram p)))
	    (close-input-port p)
	    (cons field-name res)))))

; access a hash, possibly several dimensions deep at once
; ** key list should be (key1 key2 keyN)
(define (php-deep-hash-insert! top-hash key-list final-val)
   (if (null? key-list)
       (begin
	  (php-hash-insert! top-hash :next final-val)
	  top-hash)
       (let loop ((prnt-hash top-hash)
		  (cur-key-list key-list))	  
	  (let* ((cur-key (car cur-key-list))
		 (cur-hash (php-hash-lookup prnt-hash cur-key)))
	     ; if we have more keys, keep going otherwise add final-val and return
	     (if (null? (cdr cur-key-list))
		 (begin
		    (php-hash-insert! prnt-hash cur-key final-val)
		    top-hash)
		 (begin
		    (unless (php-hash? cur-hash)
		       (set! cur-hash (make-php-hash)))
		    (php-hash-insert! prnt-hash cur-key cur-hash)
		    (loop cur-hash (cdr cur-key-list))))))))
   
(define (maybe-array str)
   (let ((len (string-length str)))
      (let loop ((n 0))
	 (if (< n len)
	    (if (char=? (string-ref str n) #\[)
		#t
		(loop (+ n 1)))
	    #f))))

; convert CGI request variables in PHP variables, including possible (deep) arrays
(define (store-request-args-in-php-hash php-hash arg-string type)
   (let ((parsed-args (if (eqv? type 'cookie)
			  (cookie-args->list arg-string)
			  (cgi-args->list arg-string))))
      (for-each (lambda (v)
		   (if (maybe-array (car v))
		       ; array value
		       (let* ((ares (cgi-array->php-array (car v)))
			      (prnt-hash (php-hash-lookup php-hash (car ares)))
			      (deep-hash (php-deep-hash-insert! (if (php-hash? prnt-hash)
								    prnt-hash
								    (make-php-hash)) 
								(cdr ares) ; key list
								(cdr v)))) ; final-val
			  ; add the completed array to the main hash
			  (php-hash-insert! php-hash (car ares) deep-hash))
		      ; normal value
		      (php-hash-insert! php-hash (car v) (cdr v))))
		parsed-args)))

; XXX this comes from standard/php-strings
; we copy it cuz we don't want to import the whole thing
(define (urldecode str)
   (let ((rp (regular-grammar
 		   ()
 		((: #\% xdigit xdigit)
 		 (integer->char (string->number (the-substring 1 3) 16)))
 		(#\+ #\space))))
      (list->string (get-tokens-from-string rp (mkstr str)))))

;; parse out GET variables into _GET, _SERVER etc
(define (parse-get-args args)
   (when args
      (store-request-args-in-php-hash
       (container-value $HTTP_GET_VARS) args 'normal)
      (container-value-set! $_GET (copy-php-data (container-value $HTTP_GET_VARS)))
      (store-request-args-in-php-hash
       (container-value $_REQUEST) args 'normal)))

(define (parse-post-args args)
   (when args
      (store-request-args-in-php-hash
       (container-value $HTTP_POST_VARS) args 'normal)
      (container-value-set! $_POST (copy-php-data (container-value $HTTP_POST_VARS)))
      (store-request-args-in-php-hash
       (container-value $_REQUEST) args 'normal)))

(define (parse-cookies args)
   (when args
      (store-request-args-in-php-hash
       (container-value $HTTP_COOKIE_VARS) args 'cookie)
      (container-value-set! $_COOKIE (copy-php-data (container-value $HTTP_COOKIE_VARS)))
      (store-request-args-in-php-hash
       (container-value $_REQUEST) args 'cookie)))

;header -- Send a raw HTTP header
(defbuiltin (header str (replace #t))
   (set! str (mkstr str))
   (set! replace (convert-to-boolean replace))
   ;(debug-trace 2 (mkstr "header: " str))
   (if (hashtable? *headers*)
       ; check for HTTP status special case
       (let ((special-parts (pregexp-match  "^HTTP/1.\\d (\\d+)" str)))
	  (if special-parts
	      (begin
		 ; set reponse code
		 (debug-trace 2 (mkstr "header: setting response code to " (cadr special-parts)))
		 (set! *response-code* (mkfixnum (cadr special-parts))))
	      ; go for normal header. the other special case (location) is below
	      (let ((header-parts
		     ;split on the first colon, skip whitespace immediately after the colon.
		     (pregexp-match "(^.*?):\\s*(.*)" str)))
		 (if (or (eqv? header-parts #f)
			 (not (= 3 (length header-parts))))
		     (php-warning (format "unable to handle header [~A] correctly" str))
		     (let* ((header-type (cadr header-parts))
			    (header-value (caddr header-parts))
			    (header-key (string-downcase (cadr header-parts))))
			(string-case header-key
			   ("location" (set! *response-code* HTTP-MOVED-TEMPORARILY)))
			(set-header header-type header-key header-value replace)))))
	      ; silently ignore as per php
	      #f)))
       ;(php-warning "Unable to set header -- not running in the belly of a webserver.")))


; import_request_variables -- Import GET/POST/Cookie variables into the global scope
(defbuiltin (import_request_variables types (prefix ""))
   (when (not *commandline?*)
      (let ((sprefix (mkstr prefix))
	    (stypes (string-downcase (mkstr types))))
	 (when (= (string-length sprefix) 0)
	    (php-notice "import_request_variables: possible security hazard by not using a prefix"))
	 (let loop ((i 0))
	    (when (< i (string-length stypes))
	       (let ((c (string-ref stypes i)))
		  (cond ((char-ci=? c #\g) (env-import *global-env* $HTTP_GET_VARS sprefix))
			((char-ci=? c #\p) (env-import *global-env* $HTTP_POST_VARS sprefix))
			((char-ci=? c #\c) (env-import *global-env* $HTTP_COOKIE_VARS sprefix))))
	       (loop (+ i 1)))))))


;headers_sent -- Returns TRUE if headers have been sent
(defbuiltin (headers_sent)
   #f)

; XXX this comes from standard/php-strings
(define (urlencode str)
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

;
(defbuiltin (ignore_user_abort (val 'unset))
   (if (eqv? val 'unset)
       *ignore-user-abort*
       (let ((oldval *ignore-user-abort*))
	  ; XXX
	  ;(php-warning "ignore_user_abort: this function isn't implemented yet")
	  ;
	  (set! *ignore-user-abort* (convert-to-boolean val))
	  oldval)))

;setcookie -- Send a cookie
; http://wp.netscape.com/newsref/std/cookie_spec.html
(defbuiltin (setcookie name (value "") (expire 0) (path "") (domain "") (secure 0))
   (letrec ((gmdate
	     ; XXX this will be off by however much locale is off from GMT
	     ; should use real gmdate from php-time instead 
	     (lambda (f d)
		(let ((sd (seconds->date d)))
		   (string-append (mkstr (day-name (date-wday sd)))
				  ", "
				  (mkstr (date-day sd))
				  "-"
				  (mkstr (month-aname (date-month sd)))
				  "-"
				  (mkstr (date-year sd))
				  " "
				  (mkstr (date-hour sd))
				  ":"
				  (mkstr (date-minute sd))
				  ":"
				  (mkstr (date-second sd))
				  " GMT")))))
      (let ((cook (format "~a=~a" name (urlencode value)))
	    (spath (mkstr path))
	    (sdomain (mkstr domain))
	    (sexpire (onum->elong (convert-to-integer expire)))
	    (ssecure (onum->elong (convert-to-number secure))))
	 (unless (php-= sexpire 0)
	    (set! cook (string-append cook (format "; expires=~a" (gmdate "l, d-M-Y H:i:s GMT" sexpire)))))
	 (unless (string=? spath "")
	    (set! cook (string-append cook (format "; path=~a" spath))))
	 (unless (string=? sdomain "")
	    (set! cook (string-append cook (format "; domain=~a" sdomain))))
	 (when (convert-to-boolean secure)
	    (set! cook (string-append cook "; secure")))
	 ; go
	 (set-header "Set-Cookie" "Set-Cookie" cook #f)
	 ; currently always succedes
	 #t)))

;;;
;;; FILE UPLOADS
;;;
(define *current-uploads* (make-hashtable))

(default-ini-entry "file_uploads" #t)
(default-ini-entry "upload_tmp_dir" (os-tmp))
(default-ini-entry "upload_max_filesize" 2048000)

; clean out any file uploads for this page view
; actual temp files should be removed per web backend
; apache does this for us by apache_request.c
(define (clean-uploads)
   (set! *current-uploads* (make-hashtable)))

(add-end-page-reset-func clean-uploads)

; is_uploaded_file -- Tells whether the file was uploaded via HTTP POST
(defbuiltin (is_uploaded_file filename)
   ;(print "current is " *current-uploads*)
   (if (and (file-exists? (mkstr filename))
	    (hashtable-get *current-uploads* (mkstr filename)))
       #t
       #f))

; move_uploaded_file -- Moves an uploaded file to a new location
(defbuiltin (move_uploaded_file filename dest)
   (if (is_uploaded_file filename)
       ; we let web backend do the cleanup of removing the temp file
       (copy-file (mkstr filename) (mkstr dest))
       #f))

; (make-container))
; (env-extend *global-env* '$HTTP_GET_VARS $HTTP_GET_VARS)
;(php-hash-insert! $HTTP_GET_VARS "agetvar" "agetvalue")


;;;; the HTTP response codes
(define HTTP-CONTINUE                      100)
(define HTTP-SWITCHING-PROTOCOLS           101)
(define HTTP-PROCESSING                    102)
(define HTTP-OK                            200)
(define HTTP-CREATED                       201)
(define HTTP-ACCEPTED                      202)
(define HTTP-NON-AUTHORITATIVE             203)
(define HTTP-NO-CONTENT                    204)
(define HTTP-RESET-CONTENT                 205)
(define HTTP-PARTIAL-CONTENT               206)
(define HTTP-MULTI-STATUS                  207)
(define HTTP-MULTIPLE-CHOICES              300)
(define HTTP-MOVED-PERMANENTLY             301)
(define HTTP-MOVED-TEMPORARILY             302)
(define HTTP-SEE-OTHER                     303)
(define HTTP-NOT-MODIFIED                  304)
(define HTTP-USE-PROXY                     305)
(define HTTP-TEMPORARY-REDIRECT            307)
(define HTTP-BAD-REQUEST                   400)
(define HTTP-UNAUTHORIZED                  401)
(define HTTP-PAYMENT-REQUIRED              402)
(define HTTP-FORBIDDEN                     403)
(define HTTP-NOT-FOUND                     404)
(define HTTP-METHOD-NOT-ALLOWED            405)
(define HTTP-NOT-ACCEPTABLE                406)
(define HTTP-PROXY-AUTHENTICATION-REQUIRED 407)
(define HTTP-REQUEST-TIME-OUT              408)
(define HTTP-CONFLICT                      409)
(define HTTP-GONE                          410)
(define HTTP-LENGTH-REQUIRED               411)
(define HTTP-PRECONDITION-FAILED           412)
(define HTTP-REQUEST-ENTITY-TOO-LARGE      413)
(define HTTP-REQUEST-URI-TOO-LARGE         414)
(define HTTP-UNSUPPORTED-MEDIA-TYPE        415)
(define HTTP-RANGE-NOT-SATISFIABLE         416)
(define HTTP-EXPECTATION-FAILED            417)
(define HTTP-UNPROCESSABLE-ENTITY          422)
(define HTTP-LOCKED                        423)
(define HTTP-FAILED-DEPENDENCY             424)
(define HTTP-INTERNAL-SERVER-ERROR         500)
(define HTTP-NOT-IMPLEMENTED               501)
(define HTTP-BAD-GATEWAY                   502)
(define HTTP-SERVICE-UNAVAILABLE           503)
(define HTTP-GATEWAY-TIME-OUT              504)
(define HTTP-VERSION-NOT-SUPPORTED         505)
(define HTTP-VARIANT-ALSO-VARIES           506)
(define HTTP-INSUFFICIENT-STORAGE          507)
(define HTTP-NOT-EXTENDED                  510)

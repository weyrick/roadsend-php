;*=====================================================================*/
;*    serrano/prgm/project/bigloo/api/web/src/Llib/url.scm             */
;*    -------------------------------------------------------------    */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Sat May 28 13:32:00 2005                          */
;*    Last change :  Tue Jun 20 17:01:25 2006 (serrano)                */
;*    Copyright   :  2005-06 Manuel Serrano                            */
;*    -------------------------------------------------------------    */
;*    URL parsing                                                      */
;*=====================================================================*/


;*
;* NOTE: This is originally from the Bigloo web API. It has been modified to 
;* reproduce Zend PHP's parse_url semantics. Don't bother Manuel for anything
;* in this file
;*

;*---------------------------------------------------------------------*/
;*    The module                                                       */
;*---------------------------------------------------------------------*/
(module pcc-web-url
   (export (pcc-url-parse ::obj)))

;*---------------------------------------------------------------------*/
;*    parse-error ...                                                  */
;*---------------------------------------------------------------------*/
(define (parse-error port msg obj)
   (raise (instantiate::&io-parse-error
	     (obj obj)
	     (proc 'url-parse)
	     (msg msg))))

(define (test-purl url)
   (multiple-value-bind (scheme user pass host port path query fragment)
      (pcc-url-parse url)
      (print scheme "][" user "][" pass "][" host "][" port "][" path "][" query "][" fragment)))

;*---------------------------------------------------------------------*/
;*    uri-grammar ...                                                  */
;*---------------------------------------------------------------------*/
(define uri-grammar
   (regular-grammar ((CRLF "\r\n"))
;      ("*"
;       (values "*" #f #f #f #f #f #f #f))
      ; this is a standard scheme, we will check for host
      ((: (out #\/) (* (out #\:)) "://")
       (read/rp absolute-uri-grammar (the-port) (the-substring 0 -3) #f #f #f #f))
      ; this is a scheme with no host, just path part
      ((: (out #\/) (+ (in lower digit #\+ #\- #\.)) ":" (out digit))
       (rgc-buffer-unget-char (the-port) (the-byte))
       (let ((scheme (the-substring 0 -1)))
	  (multiple-value-bind (abspath query fragment)
	     (read/rp abspath-grammar (the-port) #f #f)
	     (values scheme #f #f #f #f abspath query fragment))))
;      (else
;       (rgc-buffer-unget-char (the-port) (the-byte))       
;       (multiple-value-bind (abspath query fragment)
;	  (read/rp abspath-grammar (the-port) #f #f)
;	  (values #f #f #f #f #f abspath query fragment)))))
       ((: "/" (* (out " \r\n")))
        (values #f #f #f #f #f (the-string) #f #f))
       (else
        (rgc-buffer-unget-char (the-port) (the-byte))
        (read/rp absolute-uri-grammar (the-port) #f #f #f #f #f ))))      


;*---------------------------------------------------------------------*/
;*    absolute-uri-grammar ...                                         */
;*---------------------------------------------------------------------*/
(define absolute-uri-grammar
   (regular-grammar ((CRLF "\r\n")
		     (unreserved (or alpha digit #\- #\. #\_ #\~))
		     (pct-encoded (: #\% xdigit xdigit))
		     (sub-delims (in "!$&'()*+,;= "))
		     protocol
		     user
		     pass
		     query
		     fragment)
      ((: (* (or unreserved pct-encoded sub-delims #\@)) #\@)
       (set! user (the-substring 0 -1))
       (ignore))      
      ((: (* (or unreserved pct-encoded sub-delims #\:)) #\@)
       (set! user (the-substring 0 (string-index (the-string) ":")))
       (set! pass (the-substring (+fx (string-index (the-string) ":") 1) (-fx (the-length) 1)))
       (when (string=? user "")
	  (set! user #f))
       (when (string=? pass "")
	  (set! pass #f))       
       (ignore))
      ((: (+ (out "@:/")) ":")
       (let ((host (the-substring 0 (-fx (the-length) 1))))
	  (let* ((port (read/rp http-port-grammar (the-port))))
	     (multiple-value-bind (abspath query fragment)
		(read/rp abspath-grammar (the-port) #f #f)
		(values protocol user pass host port abspath query fragment)))))
      ((: (+ (out "@:/")))
       (let* ((host (the-substring 0 (the-length)))
	      (port #f))
	  (multiple-value-bind (abspath query fragment)
	     (read/rp abspath-grammar (the-port) #f #f)
	     (values protocol user pass host port abspath query fragment))))
      ((: "/" (* (out ":\r\n")))
       (values protocol #f #f #f #f (the-string) #f #f))
      (CRLF
       #f)
      (else
       (parse-error (the-port) "Illegal character" (the-failure)))))

;*---------------------------------------------------------------------*/
;*    abspath-grammar ...                                              */
;*---------------------------------------------------------------------*/
(define abspath-grammar
   (regular-grammar ((pdelim (out #\? #\# "\r\n"))
		     (anchor (+ (out "\r\n"))) ; is this ok?
		     query
		     fragment)
      ((: "/" (+ pdelim) #\? (+ pdelim) #\# (+ anchor))
       (let ((abspath (the-substring 0 (string-index (the-string) "?")))
	     (query (the-substring (+fx 1 (string-index (the-string) "?"))
				   (string-index (the-string) "#")))
	     (fragment (the-substring (+fx 1 (string-index (the-string) "#"))
				      (the-length))))
	  (values abspath query fragment)))
      ((: "/" (+ pdelim) #\? (+ pdelim))
       (let ((abspath (the-substring 0 (string-index (the-string) "?")))
	     (query (the-substring (+fx 1 (string-index (the-string) "?"))
				   (the-length))))
	  (values abspath query #f)))
      ((: "/" (+ pdelim) #\# (+ anchor))
       (let ((abspath (the-substring 0 (string-index (the-string) "#")))
	     (fragment (the-substring (+fx 1 (string-index (the-string) "#"))
				      (the-length))))
	  (values abspath #f fragment)))
      ((: "/?" (+ pdelim))
       (let ((query (the-substring (+fx 1 (string-index (the-string) "?"))
				   (the-length))))
	  (values "/" query #f)))      
      ((: "/#" (+ anchor))
       (let ((fragment (the-substring (+fx 1 (string-index (the-string) "#"))
				      (the-length))))
	  (values "/" #f fragment)))
      ((: "/" (* (out "\r\n")) #\? #\#)
       (values (the-substring 0 -2) #f #f))      
      ((: "/" (* (out "\r\n")) #\?)
       (values (the-substring 0 -1) #f #f))
      ((: (* "/") (* (out "\r\n")))
       (values (if (string=? (the-string) "") #f (the-string)) #f #f))
      (else
       (let ((c (the-failure)))
	  (if (eof-object? c)
	      (values #f #f #f)
	      (parse-error (the-port) "Illegal character" (the-failure)))))))
      
;*---------------------------------------------------------------------*/
;*    http-port-grammar ...                                            */
;*---------------------------------------------------------------------*/
(define http-port-grammar
   (regular-grammar ()
      ((+ digit)
       (the-fixnum))
      (else
       (parse-error (the-port) "Illegal character" (the-failure)))))
      
;*---------------------------------------------------------------------*/
;*    pcc-url-parse ...                                                    */
;*---------------------------------------------------------------------*/
(define (pcc-url-parse url)
   (cond
      ((input-port? url)
       (read/rp uri-grammar url))
      ((string? url)
       (let ((p (open-input-string url)))
	  (unwind-protect
	     (read/rp uri-grammar p)
	     (close-input-port p))))))


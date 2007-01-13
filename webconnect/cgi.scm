;
; XXX this is from a beta bigloo distribution of 2.8, with a few
; fixes. replace with release version from 2.8
;

;*=====================================================================*/
;*    serrano/prgm/project/bigloo/api/web/src/Llib/cgi.scm             */
;*    -------------------------------------------------------------    */
;*    Author      :  Manuel Serrano                                    */
;*    Creation    :  Sun Feb 16 11:17:40 2003                          */
;*    Last change :  Fri Feb 10 18:33:56 2006 (serrano)                */
;*    Copyright   :  2003-06 Manuel Serrano                            */
;*    -------------------------------------------------------------    */
;*    CGI scripts handling                                             */
;*=====================================================================*/

;*---------------------------------------------------------------------*/
;*    The module                                                       */
;*---------------------------------------------------------------------*/
(module __web_cgi

   (export (cgi-args->list::pair-nil ::bstring)
	   (cookie-args->list::pair-nil ::bstring)
	   (cgi-fetch-arg ::bstring ::bstring)
	   (cgi-url-encode::bstring ::bstring)
	   (cgi-multipart->list ::bstring ::input-port ::elong ::bstring ::procedure)
	   (cgi-post-arg-field ::obj ::pair-nil)))

;*---------------------------------------------------------------------*/
;*    unhex ...                                                        */
;*---------------------------------------------------------------------*/
(define (unhex hexadecimal-string)
   (string (integer->char (string->integer hexadecimal-string 16))))

;*---------------------------------------------------------------------*/
;*    decode ...                                                       */
;*---------------------------------------------------------------------*/
(define (decode str)
   (let ((len (string-length str)))
      (let loop ((i 0))
	 (cond
	    ((=fx i len)
	     str)
	    ((char=? (string-ref str i) #\+)
	     (string-set! str i #\space)
	     (loop (+fx i 1)))
	    (else
	     (loop (+fx i 1)))))))
	     
;*---------------------------------------------------------------------*/
;*    cgi-args->list ...                                               */
;*---------------------------------------------------------------------*/
(define (cgi-args->list query)
   (let* ((fields-list '())
	  (field-name "")
	  (field-value "")
	  (gram (regular-grammar ()
		   ((when (not (rgc-context? 'val))
		       (+ (or (: (? #a013) #\newline) #\&)))
		    (ignore))
		   ((when (not (rgc-context? 'val))
		       (: (* (out "=%&")) "="))
		    (set! field-name
			  (string-append
			   field-name
			   (decode (the-substring 0 (-fx (the-length) 1)))))
		    (rgc-context 'val)
		    (ignore))
		   ((when (not (rgc-context? 'val))
		       (: (* (out "=%&")) "%" xdigit xdigit))
		    (set! field-name
			  (string-append
			   field-name
			   (decode (the-substring 0 (-fx (the-length) 3)))
			   (unhex (the-substring (-fx (the-length) 2)
						 (the-length)))))
		    (ignore))
		   ((when (rgc-context? 'val)
		       (+ (or (: (? #a013) #\newline) #\&)))
		    (set! fields-list (cons (cons field-name field-value)
					    fields-list))
		    (set! field-name "")
		    (set! field-value "")
		    (rgc-context)
		    (ignore))
		   ((when (rgc-context? 'val)
		       (: (* (out "&%+")) #\% xdigit xdigit))
		    (set! field-value
			  (string-append
			   field-value
			   (the-substring 0 (-fx (the-length) 3))
			   (unhex (the-substring (-fx (the-length) 2)
						 (the-length)))))
		    (ignore))
		   ((when (rgc-context? 'val)
		       (: (* (out "&%+")) "+"))
		    (set! field-value (string-append
				       field-value
				       (the-substring 0 (-fx (the-length) 1))
				       " "))
		    (ignore))
		   ((when (rgc-context? 'val)
		       (* (out "&%+")))
		    (set! field-value (string-append field-value
						     (the-string)))
		    (set! fields-list (cons (cons field-name field-value)
					    fields-list))
		    (set! field-name "")
		    (set! field-value "")
		    (rgc-context)
		    (ignore))
		   (else (reverse fields-list)))))
      (let ((p (open-input-string query)))
	 (let ((res (read/rp gram p)))
	    (close-input-port p)
	    res))))

; this is lame since the only difference is cookies are delimited by "; "
; instead of "&" like request arguments
(define (cookie-args->list query)
   (let* ((fields-list '())
	  (field-name "")
	  (field-value "")
	  (gram (regular-grammar ((delim (: #\; space)))
		   ((when (not (rgc-context? 'val))
		       (+ (or (: (? #a013) #\newline) delim)))
		    (ignore))
		   ((when (not (rgc-context? 'val))
		       (: (* (out "=%;" )) "="))
		    (set! field-name
			  (string-append
			   field-name
			   (decode (the-substring 0 (-fx (the-length) 1)))))
		    (rgc-context 'val)
		    (ignore))
		   ((when (not (rgc-context? 'val))
		       (: (* (out "=%;")) "%" xdigit xdigit))
		    (set! field-name
			  (string-append
			   field-name
			   (decode (the-substring 0 (-fx (the-length) 3)))
			   (unhex (the-substring (-fx (the-length) 2)
						 (the-length)))))
		    (ignore))
		   ((when (rgc-context? 'val)
		       (+ (or (: (? #a013) #\newline) delim)))
		    (set! fields-list (cons (cons field-name field-value)
					    fields-list))
		    (set! field-name "")
		    (set! field-value "")
		    (rgc-context)
		    (ignore))
		   ((when (rgc-context? 'val)
		       (: (* (out "%+;")) #\% xdigit xdigit))
		    (set! field-value
			  (string-append
			   field-value
			   (the-substring 0 (-fx (the-length) 3))
			   (unhex (the-substring (-fx (the-length) 2)
						 (the-length)))))
		    (ignore))
		   ((when (rgc-context? 'val)
		       (: (* (out "%+;")) "+"))
		    (set! field-value (string-append
				       field-value
				       (the-substring 0 (-fx (the-length) 1))
				       " "))
		    (ignore))
		   ((when (rgc-context? 'val)
		       (* (out "%+;")))
		    (set! field-value (string-append field-value
						     (the-string)))
		    (set! fields-list (cons (cons field-name field-value)
					    fields-list))
		    (set! field-name "")
		    (set! field-value "")
		    (rgc-context)
		    (ignore))
		   (else (reverse fields-list)))))
      (let ((p (open-input-string query)))
	 (let ((res (read/rp gram p)))
	    (close-input-port p)
	    res))))

;*---------------------------------------------------------------------*/
;*    cgi-fetch-arg ...                                                */
;*---------------------------------------------------------------------*/
(define (cgi-fetch-arg arg query)
   (let* ((fields-list '())
	  (field-name "")
	  (field-value "")
	  (gram (regular-grammar ()
		   ((when (not (rgc-context? 'val))
		       (+ (or (: (? #a013) #\newline) #\&)))
		    (ignore))
		   ((when (not (rgc-context? 'val))
		       (: (* (out "=%&")) "="))
		    (set! field-name
			  (string-append
			   field-name
			   (decode (the-substring 0 (-fx (the-length) 1)))))
		    (rgc-context 'val)
		    (ignore))
		   ((when (not (rgc-context? 'val))
		       (: (* (out "=%&")) "%" xdigit xdigit))
		    (set! field-name
			  (string-append
			   field-name
			   (decode (the-substring 0 (-fx (the-length) 3)))
			   (unhex (the-substring (-fx (the-length) 2)
						 (the-length)))))
		    (ignore))
		   ((when (rgc-context? 'val)
		       (+ (or (: (? #a013) #\newline) #\&)))
		    (if (string=? field-name arg)
			field-value
			(begin
			   (set! field-name "")
			   (set! field-value "")
			   (rgc-context)
			   (ignore))))
		   ((when (rgc-context? 'val)
		       (: (* (out "&%+")) #\% xdigit xdigit))
		    (set! field-value
			  (string-append
			   field-value
			   (the-substring 0 (-fx (the-length) 3))
			   (unhex (the-substring (-fx (the-length) 2)
						 (the-length)))))
		    (ignore))
		   ((when (rgc-context? 'val)
		       (: (* (out "&%+")) "+"))
		    (set! field-value (string-append
				       field-value
				       (the-substring 0 (-fx (the-length) 1))
				       " "))
		    (ignore))
		   ((when (rgc-context? 'val)
		       (* (out "&%+")))
		    (if (string=? field-name arg)
			(string-append field-value (the-string))
			(begin
			   (set! field-name "")
			   (set! field-value "")
			   (rgc-context)
			   (ignore))))
		   (else #f))))
      (let ((p (open-input-string query)))
	 (let ((res (read/rp gram p)))
	    (close-input-port p)
	    res))))

;*---------------------------------------------------------------------*/
;*    cgi-url-encode ...                                               */
;*---------------------------------------------------------------------*/
(define (cgi-url-encode str)
   (define (count str ol)
      (let loop ((i 0)
		 (n 0))
	 (if (=fx i ol)
	     n
	     (let ((c (string-ref str i)))
		(case c
		   ((#\# #\Space #\" #\' #\+ #\& #\= #\%)
		    (loop (+fx i 1) (+fx n 3)))
		   (else
		    (if (or (char>=? c #a128) (char<? c #a032))
			(loop (+fx i 1) (+fx n 3))
			(loop (+fx i 1) (+fx n 1)))))))))
   (define (int->char c)
      (cond
	 ((<fx c 10)
	  (integer->char (+fx c (char->integer #\0))))
	 ((<fx c 16)
	  (integer->char (+fx (-fx c 10) (char->integer #\A))))))
   (define (encode-char res j c)
      (let ((n (char->integer c)))
	 (string-set! res j #\%)
	 (cond
	    ((<fx n 16)
	     (string-set! res (+fx j 1) #\0)
	     (string-set! res (+fx j 2) (int->char n)))
	    (else
	     (let ((n1 (/fx n 16))
		   (n2 (remainder n 16)))
		(string-set! res (+fx j 1) (int->char n1))
		(string-set! res (+fx j 2) (int->char n2)))))))
   (define (encode str ol nl)
      (if (=fx nl ol)
	  str
	  (let ((res (make-string nl)))
	     (let loop ((i 0)
			(j 0))
		(if (=fx j nl)
		    res
		    (let ((c (string-ref str i)))
		       (case c
			  ((#\# #\Space #\" #\' #\+ #\& #\= #\%)
			   (encode-char res j c)
			   (loop (+fx i 1) (+fx j 3)))
			  (else
			   (if (or (char>=? c #a128) (char<? c #a032))
			       (begin
				  (encode-char res j c)
				  (loop (+fx i 1) (+fx j 3)))
			       (begin
				  (string-set! res j c)
				  (loop (+fx i 1) (+fx j 1))))))))))))
   (let ((ol (string-length str)))
      (encode str ol (count str ol))))

;*---------------------------------------------------------------------*/
;*    fill-line! ...                                                   */
;*---------------------------------------------------------------------*/
(define (fill-line! buffer port)
   (let ((len (string-length buffer)))
      (let loop ((i 0))
	 (if (>=fx i (-fx len 2))
	     (values i #f)
	     (let ((c (read-char port)))
		(string-set! buffer i c)
		(if (char=? c #\Return)
		    (let ((c2 (read-char port)))
		       (string-set! buffer (+fx i 1) c2)
		       (if (char=? c2 #\Newline)
			   (values i #t)
			   (loop (+fx i 2))))
		    (loop (+fx i 1))))))))
   
;*---------------------------------------------------------------------*/
;*    flush-line ...                                                   */
;*---------------------------------------------------------------------*/
(define (flush-line port)
   (let ((grammar (regular-grammar ((xall (or (out #\Return)
					      (: #\Return (out #\Newline))
					      #a000)))
		     ((: (* xall) #\Return #\Newline)
		      (the-substring 0 (-fx (the-length) 2)))
		      ;(the-substring 0 -2))
		     ((+ xall)
		      (the-string))
		     (else
		      (the-failure)))))
      (read/rp grammar port)))

;*---------------------------------------------------------------------*/
;*    is-boundary? ...                                                 */
;*---------------------------------------------------------------------*/
(define (is-boundary? line boundary)
   (and (>=fx (string-length line) (+fx 2 (string-length boundary)))
	(char=? (string-ref line 0) #\-)
	(char=? (string-ref line 1) #\-)
	(substring-at? line boundary 2)))

;*---------------------------------------------------------------------*/
;*    last-boundary? ...                                               */
;*---------------------------------------------------------------------*/
(define (last-boundary? line boundary)
   (let ((len (string-length boundary)))
      (and (>=fx (string-length line) (+fx 4 len))
	   (char=? (string-ref line 0) #\-)
	   (char=? (string-ref line 1) #\-)
	   (char=? (string-ref line (+fx 2 len)) #\-)
	   (char=? (string-ref line (+fx 3 len)) #\-))))

;*---------------------------------------------------------------------*/
;*    cgi-parse-boundary ...                                           */
;*---------------------------------------------------------------------*/
(define (cgi-parse-boundary buffer port boundary)
   (multiple-value-bind (len crlf)
      (fill-line! buffer port)
      ; XXX
;      (fprint (current-error-port) (format "parse-boundary: fill line filled [~a] crlf? " (substring buffer 0 len) crlf))
      ;; according to RFC 2046, there may be additional characters
      ;; on the line after the boundary
      (if (is-boundary? buffer boundary)
	  (begin
	     (unless crlf (flush-line port))
	     (last-boundary? buffer boundary))
	  (error 'cgi-multipart->list "Illegal boundary"
		 (format "\n wanted:--~a\n  found:~a" boundary
			 (substring buffer 0 len))))))

;*---------------------------------------------------------------------*/
;*    cgi-parse-content-disposition ...                                */
;*---------------------------------------------------------------------*/
(define (cgi-parse-content-disposition port)
   (let* ((str "Content-Disposition: form-data; name=")
	  (len (string-length str)))
      (let ((buf (read-chars len port)))
	 ; XXX
;	 (fprint (current-error-port) (format "cd read: [~a] and wants [~a]" buf str))
	 (if (string-ci=? str buf)
	     (let ((s (read port)))
		(if (string? s)
		    (let ((rest (flush-line port))
			  (pref "; filename=\""))
		       (if (substring-at? rest pref  0)
			   (let ((fname (substring
					 rest
					 (string-length pref)
					 (-fx (string-length rest) 1))))
			      (values s fname))
			   (values s #f)))
		    (error 'cgi-multipart->list "Illegal name" s)))
	     (error 'cgi-multipart->list
		    "Illegal Content-Disposition: "
		    buf)))))

;*---------------------------------------------------------------------*/
;*    cgi-parse-header ...                                             */
;*---------------------------------------------------------------------*/
(define (cgi-parse-header port)
   (let ((header '()))
      (define value-grammar
	 (regular-grammar ()
	    ((+ (in " \t"))
	     (ignore))
	    ((: (out " \t\r\n") (* (out "\r\n")) "\r\n")
	     (the-substring 0 (-fx (the-length) 2)))
	    ((: (out " \t\r\n") (* (out "\r\n")) "\n")
	     (the-substring 0 (-fx (the-length) 1)))
	    ((: (? #\Return) #\Newline)
	     "")
	    (else
	     (let ((c (the-failure)))
		(if (eof-object? c)
		    '()
		    c)))))
      (define blank-grammar
	 (regular-grammar ()
	    ((+ (in " \t")) (ignore))))
      (define header-grammar
	 (regular-grammar ()
	    ((: (+ (or (out " :\r\n\t") (: #\space (out #\:)))) #\:)
	     (let ((k (string->keyword (string-downcase (keyword->string (the-keyword))))))
		(let ((v (read/rp value-grammar (the-port))))
		   (set! header (cons (cons k v) header))
		   (ignore))))
	    ((: (* (in #\space #\tab)) (? #\Return) #\Newline)
	     header)
	    (else
	     ;; accumultate all the character to EOL for a better error message
	     (let ((c (the-failure)))
		(let ((s (if (char? c)
			     (string-for-read
			      (string-append "<" (string c) ">"
					     (read-line (the-port))))
			     c)))
		   (error 'cgi-multipart->list "Illegal characters" s))))))
      (read/rp header-grammar port)))


; added in 2.8 (weyrick). hopefully this does it.
(define (display-substring string start end output-port)
   (when (and (>=fx end start)
	      (>=fx start 0)
	      (string? string)
	      (<=fx end (string-length string)))
      (let ((s (substring string start end)))
	 (display s output-port))))

(define (file-name-canonicalize path)
   ; could call util-realpath on this?
   path)

;*---------------------------------------------------------------------*/
;*    cgi-read-file ...                                                */
;*---------------------------------------------------------------------*/
(define (cgi-read-file name header buffer port file tmp boundary tmpname-proc)
   (let* (;(path (make-file-name tmp file))
	  (path (tmpname-proc tmp "pcc"))
	  (dir (dirname (file-name-canonicalize path))))
      (when (substring-at? dir tmp 0) (make-directory dir))
      (let ((op (open-output-file path)))
	 (if (not (output-port? op))
	     (error 'cgi-multipart->list "Can't open file for output" path)
	     (unwind-protect
		(let loop ((ocrlf #f))
		   (multiple-value-bind (len crlf)
		      (fill-line! buffer port)
		      (if (is-boundary? buffer boundary)
			  (begin
			     (unless crlf (flush-line port))
			     (values (last-boundary? buffer boundary)
				     (list name
					   :file file
					   :header header
					   :tmpfile path
					   )))
			  (begin
			     (when ocrlf (display "\r\n" op))
			     (display-substring buffer 0 len op)
			     (loop crlf)))))
		(close-output-port op))))))

;*---------------------------------------------------------------------*/
;*    cgi-read-data ...                                                */
;*---------------------------------------------------------------------*/
(define (cgi-read-data name header buffer port boundary)
   (let loop ((lines '())
	      (first #t))
      (multiple-value-bind (len crlf)
	 (fill-line! buffer port)
	 ; XXX
;	 (fprint (current-error-port) (format "read-data: fill line filled [~a] crlf? " (substring buffer 0 len) crlf))	 
	 (if (is-boundary? buffer boundary)
	     (begin
		(unless crlf (flush-line port))
		(values (last-boundary? buffer boundary)
			(list name
			      :data (apply string-append (reverse! lines))
			      :header header)))
	     (if (or first (not crlf))
		 (loop (cons (substring buffer 0 len) lines) #f)
		 (loop (cons* (substring buffer 0 len) "\r\n" lines) #f))))))

;*---------------------------------------------------------------------*/
;*    cgi-parse-entry ...                                              */
;*---------------------------------------------------------------------*/
(define (cgi-parse-entry buffer port tmp boundary tmpname-proc)
   (multiple-value-bind (name file)
      (cgi-parse-content-disposition port)
      ; XXX
;      (fprint (current-error-port) (format "parse entry read: name [~a] file [~a], getting data..." name file))
      (let ((header (cgi-parse-header port)))
	 ; XXX
;	 (fprint (current-error-port) (format "header: [~a]" header))
	 (multiple-value-bind (last entry)
	    (if (string? file)
		(cgi-read-file name header buffer port file tmp boundary tmpname-proc)
		(cgi-read-data name header buffer port boundary))
	    ; XXX
;	    (fprint (current-error-port) (format "after data read: last [~a] entry [~a]" last entry))
	    (values last entry)))))

;*---------------------------------------------------------------------*/
;*    cgi-multipart->list ...                                          */
;*---------------------------------------------------------------------*/
(define (cgi-multipart->list tmp port content-length boundary tmpname-proc)
   ;(fprint (current-error-port) tmp)
   ;(fprint (current-error-port) port)
   ;(fprint (current-error-port) content-length)
   ;(fprint (current-error-port) boundary)
	   
   (let ((buffer (make-string (+fx (string-length boundary) 256))))
      (if (cgi-parse-boundary buffer port boundary)
	  '()
	  (let loop ((res '()))
	     (multiple-value-bind (last entry)
		(cgi-parse-entry buffer port tmp boundary tmpname-proc)
		; XXX
;		(fprint (current-error-port) (format "success: [~a], last [~a]" entry last))	
		(if last
		    (reverse! (cons entry res))
		    (loop (cons entry res))))))))

;*---------------------------------------------------------------------*/
;*    cgi-post-arg-field ...                                           */
;*---------------------------------------------------------------------*/
(define (cgi-post-arg-field key field)
   (let ((l (memq key field)))
      (and (pair? l) (pair? (cdr l)) (cadr l))))
      

#|
-----------------------------14979831520386643701129566413
Content-Disposition: form-data; name="team"

acacia
-----------------------------14979831520386643701129566413
Content-Disposition: form-data; name="file"; filename="foo"
Content-Type: application/octet-stream

toto

-----------------------------14979831520386643701129566413--
|#

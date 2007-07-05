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


(module php-curl-lib
   (include "../phpoo-extension.sch")
   (include "../standard/php-streams.sch")
   (include "../../php-runtime.sch")   
   (import (curl-c-bindings "curl-c-bindings.scm"))
   (import (curl-bindings "curl-bindings.scm"))
   (library php-runtime)
   (library profiler)
   (export

    (init-php-curl-lib)

    ;;builtins
    (curl_version)
    (curl_init url)
    (curl_setopt link option value)
    (curl_exec link)
    (curl_getinfo link opt)
    (curl_error link)
    (curl_errno link)
    (curl_close link)
    
    ; c callbacks
    (curl-write-callback::int buffer::void*
			      size::int
			      nitems::int
			      proc::procedure)
    (curl-read-callback::int  buffer::void*
			      size::int
			      nitems::int
			      proc::procedure)
    (curl-header-callback::int buffer::string
			       size::int
			       nitems::int
			       proc::procedure)
    (curl-progress-callback::bool proc::procedure
				  dltotal::double
				  dlnow::double
				  ultotal::double
				  ulnow::double)
    (curl-passwd-callback::bool proc::procedure
				prompt::string
				buffer::string
				buflen::int)
    )
   
   (static
    (class curl-stream
       curl
       url
       multi
       pending
       (headers (default (make-php-hash)))
       (read-buffer (default (make-curl-buffer))))

    (class %curl-buffer
       size
       position
       strings
       strings-tail))

   (extern
    (export curl-write-callback "pcc_curl_write_callback")
    (export curl-read-callback "pcc_curl_read_callback")
    (export curl-header-callback "pcc_curl_header_callback")
    (export curl-progress-callback "pcc_curl_progress_callback")
    (export curl-passwd-callback "pcc_curl_passwd_callback"))
   (eval    (export-all)))

(define (init-php-curl-lib)
   1)

(register-extension "curl" "1.0.0"
                    "php-curl"
                    ;; XXX we enable multiple definitions because the
                    ;; SSL support causes duplicate definitions of a
                    ;; bunch of symbols from libcrypto, (which is also
                    ;; linked into our license code).  Allowing
                    ;; multiple definitions is not nice because it
                    ;; might hide real errors.
                    (cond-expand
                       (PCC_MINGW '("-lcurl" "-lz" "-lwinmm" "-lws2_32" "-lssl" "-lcrypto" "-lgw32c" "-lgdi32"
                                             "-Wl,--allow-multiple-definition"))
                       (PCC_FREEBSD '("-lcurl" "-lssl" "-lcrypto" "-lz"
                                               "-Wl,--allow-multiple-definition"))
                       (else '("-lcurl" "-ldl" "-lssl" "-lcrypto" "-lz"
                                        "-Wl,--allow-multiple-definition")))
		    required-extensions: '("standard"))

(define *curl-wrapper*
   (make-stream-wrapper
    ;   (instantiate::stream-wrapper
    ;      (name
    "curl wrapper"
    ;	    )
    ;      (open-fun
    curl-stream-open
    ;       )
    ;      (close-fun
    #f
    ;)
    ;      (stat-fun
    #f
    ;       )
    ;      (url-stat-fun
    #f
    ;       )
    ;      (dir-open-fun
    #f
    ;       )
    ;      (context
    #f
    ;       )
    ;      (url?
    #t
    ;       )
    ;      (errors
    #f
    ;       )
    ))

(register-stream-wrapper "http" *curl-wrapper*)
(register-stream-wrapper "https" *curl-wrapper*)
(register-stream-wrapper "ftp" *curl-wrapper*)
(register-stream-wrapper "ldap" *curl-wrapper*)


(define (open-curl-stream foo) #f)


;;;;;;;;;;;;;
; c callbacks
; these are called directly by curl, but end up calling scheme functions
; that are defined with pcc-set-callbacks

; curl -> php
(define (curl-write-callback::int buffer::void*
				  size::int
				  nitems::int
				  proc::procedure)
   (proc (pragma::bstring "string_to_bstring_len($1, $2 * $3)"
			 buffer size nitems)))

; php -> curl 
(define (curl-read-callback::int buffer::void*
				 size::int
				 nitems::int
				 proc::procedure) 
  (let* ((maxlen (*fx size nitems))
	 (result (proc maxlen)))
    (cond ((and (string? result)
		(>fx (string-length result) 0))
	   (let ((result (if (>fx (string-length result) maxlen)
			     (substring result 0 maxlen)
			     result)))
	     (pragma "memcpy($1, BSTRING_TO_STRING($2), $3)" buffer result (string-length result))
	     (string-length result)))
	  (else 0))))

(define (curl-header-callback::int buffer::string
				   size::int
				   nitems::int
				   proc::procedure)
    (proc (pragma::bstring "string_to_bstring_len($1, $2 * $3)"
			   buffer size nitems)))

(define (curl-progress-callback::bool
	 proc::procedure
	 dltotal::double
	 dlnow::double
	 ultotal::double
	 ulnow::double)
  (proc dltotal dlnow ultotal ulnow))

(define (curl-passwd-callback::bool
	 proc::procedure
	 prompt::string
	 buffer::string
	 buflen::int)
   (let((result(proc prompt buflen)))
      (cond ((string? result)
	     (if (<fx (string-length result)buflen)
		 (let((result::string result))
		    (pragma "strcpy($1, $2)" buffer result))
		 (error "curl-passwd-callback" "passwd loo long" ""))
	     #f)
	    (else #t))))

(define (pcc-set-errbuf curl::CURL* buf::string)
   (curle-error-check "pcc-set-errbuf"
		      (let ((value::string buf))
			 (pragma::CURLcode
			  "curl_easy_setopt($1, CURLOPT_ERRORBUFFER, $2)"
			  curl value))))

(define (pcc-set-callbacks curl::CURL* write-from-curl read-from-php header progress)
   (when write-from-curl
      (let ((value::procedure write-from-curl))
	 (curle-error-check "pcc-set-callbacks: write function"
			    (pragma::CURLcode
			     "curl_easy_setopt($1, CURLOPT_WRITEFUNCTION, pcc_curl_write_callback)"
			     curl))
	 (curle-error-check "pcc-set-callbacks: write data"
			    (pragma::CURLcode
			     "curl_easy_setopt($1, CURLOPT_WRITEDATA, $2)"
			     curl value))))
   (when read-from-php
      (let ((value::procedure read-from-php))
	       (curle-error-check "pcc-set-callbacks: read function"   
				  (pragma::CURLcode
				   "curl_easy_setopt($1, CURLOPT_READFUNCTION, pcc_curl_read_callback)"
				   curl))
	       (curle-error-check "pcc-set-callbacks: read data"
				  (pragma::CURLcode
				   "curl_easy_setopt($1, CURLOPT_READDATA, $2)"
				   curl value))))
   (when header
      (let ((value::procedure header))
      (curle-error-check "pcc-set-callbacks: header function"
			 (pragma::CURLcode
			  "curl_easy_setopt($1, CURLOPT_HEADERFUNCTION, pcc_curl_header_callback)"
			  curl))
      (curle-error-check "pcc-set-callbacks: header data"
			 (pragma::CURLcode
			  "curl_easy_setopt($1, CURLOPT_HEADERDATA, $2)"
			  curl value))))
   
   (when progress
      (let ((value::procedure progress))
	 (curle-error-check "pcc-set-callbacks: progress function"
			    (pragma::CURLcode
			     "curl_easy_setopt($1, CURLOPT_PROGRESSFUNCTION, pcc_curl_progress_callback)"
			     curl))
	 (curle-error-check "pcc-set-callbacks: progress data"   
			    (pragma::CURLcode
			     "curl_easy_setopt($1, CURLOPT_PROGRESSDATA, $2)"
			     curl value)))))

;;;;;;;;;;;;;;;;
; easy interface
(define (pcc-easy-setopt curl::CURL* . options)
   (let loop ((options options))
      (when (pair? options)
	 (let* ((key (car options))
		(value (cadr options)))
;	    (debug-trace 3 "pcc-easy-setopt loop on " key " to " value)
	    ; if it's a php val, translate it
	    (unless (CURLoption? key)
	       (let ((copt (hashtable-get *curl-opt-table* (mkfixnum key))))
		  (when copt
		     (let ((cenum::CURLoption (car copt))
			   (ctype (cadr copt)))
			(curle-error-check "pcc-easy-setopt"
			  (cond
			     ((eqv? ctype 'slist) 
			      (let ((value::void* value))
				 (pragma::CURLcode "curl_easy_setopt($1, $2, $3)"
						   curl
						   cenum
						   value)))
			     ((eqv? ctype 'int) 
			      (let ((value::int value))
				 (pragma::CURLcode "curl_easy_setopt($1, $2, $3)"
						   curl
						   cenum
						   value)))
			     ((eqv? ctype 'bool)
			      (let ((value::bool value))
				 (pragma::CURLcode "curl_easy_setopt($1, $2, $3)"
						   curl
						   cenum
						   value)))			    
			     ((eqv? ctype 'str)
			      (let ((value::string value))
				 (pragma::CURLcode "curl_easy_setopt($1, $2, $3)"
						   curl
						   cenum
						   value)))))))))
	    (loop (cddr options))))))

(define (pcc-easy-getinfo curl::CURL* option::CURLINFO)
   (let ((buffer::void* (pragma::void* "GC_malloc_atomic(sizeof(double))")))
      (curle-error-check
       "curl-easy-getinfo"
       (pragma::CURLcode "curl_easy_getinfo($1, $2, $3)" curl option buffer))
      (cond
	 ((pragma::bool "($1 & CURLINFO_TYPEMASK) == CURLINFO_STRING" option)
	  (pragma::string "*((char**)$1)" buffer))
	 ((pragma::bool "($1 & CURLINFO_TYPEMASK) == CURLINFO_LONG" option)
	  (pragma::long "*((long*)$1)" buffer))
	 (else
	  (pragma::double "*((double*)$1)" buffer)))))

;;;;;;;;;;;;;;;;;
; multi interface
(define (pcc-multi-perform curlm::CURLM*)
   (let ((handles::int* (make-int* 1)))
      (let ((mcode (ccurl_multi_perform curlm handles)))
	 (values mcode (int*-ref handles 0)))))

(define (curle-error-check name::bstring code::CURLcode)
;   (debug-trace 1 "from " name " result was " code)
 (unless (=CURLcode? (CURLcode-CURLE_OK) code)
  (error
   name
   "curl error"
   code)))

(define (curlm-error-check name::bstring code::CURLMcode)
  (unless
	(or (=CURLMcode? (CURLMcode-CURLM_OK) code)
	    (=CURLMcode? (CURLMcode-CURLM_CALL_MULTI_PERFORM) code)
	    (=CURLMcode? (CURLMcode-CURLM_LAST) code))
   (error
    name
    "curl multi error"
    code)))

(define (pcc-multi-fdset curlm::CURLM*)
  (let((read-fd-set::fd-set (pragma::fd-set "(fd_set*)GC_malloc_atomic(sizeof(fd_set))"))
       (write-fd-set::fd-set (pragma::fd-set "(fd_set*)GC_malloc_atomic(sizeof(fd_set))"))
       (exc-fd-set::fd-set (pragma::fd-set "(fd_set*)GC_malloc_atomic(sizeof(fd_set))"))
       (max-fd::int* (make-int* 1)))
    (pragma::void "FD_ZERO($1)" read-fd-set)
    (pragma::void "FD_ZERO($1)" write-fd-set)
    (pragma::void "FD_ZERO($1)" exc-fd-set)
   (curlm-error-check
    "curl-multi-fdset"
    (ccurl_multi_fdset curlm read-fd-set write-fd-set exc-fd-set max-fd))
   (values read-fd-set write-fd-set exc-fd-set (int*-ref max-fd 0))))

(define (curlm-call-multi-perform-again? name::bstring code::CURLMcode)
    (if (=CURLMcode? (CURLMcode-CURLM_CALL_MULTI_PERFORM) code)
	#t
	;;I'm assuming that CURLM_LAST means no need to call it again and no error, 
	;;but I can't find it documented anywhere.
	(if (or (=CURLMcode? (CURLMcode-CURLM_OK) code)
		(=CURLMcode? (CURLMcode-CURLM_LAST) code))
	    #f
	    (curlm-error-check name code))))

;;;;;;;;;;;;;

(define (read-buffer foo) #f)
(define (stream-wrapper-data-set! bar foo) #f)

(define *curl-operations*
   (make-stream-operations
    "CURL Stream"
    curl-stream-write
    curl-stream-read
    curl-stream-close
    curl-stream-flush))

;; stream layer curl writefunction callback
; curl -> php
(define (wrapper-write-from-curl data stream)
   (curl-buffer-add-string (curl-stream-read-buffer stream)
			   data)
   ;;curl seems to block if you don't return the length of the data
   (string-length data))

;; stream layer curl headerfunction callback
(define (wrapper-on-header-available data stream)
   ;;curl seems to block if you don't return the length of the data
   (php-hash-insert! (curl-stream-headers stream) 'next data)
   (string-length data))

;; stream layer curl progressfunction callback
(define (wrapper-on-progress-available dltotal dlnow ultotal ulnow)
   (debug-trace 3  "curl progress -- dltotal: " dltotal
		"  dlnow: " dlnow "  ultotal: " ultotal "  ulnow: " ulnow)
   ;;if you don't return #f (zero), curl will abort the transfer
   #f)

(define (curl-stream-open wrapper filename mode options stream-context)
   (debug-trace 3 "Opening CURL stream for " filename)
   (let ((readable? (or (substring=? mode "r" 1)
			(substring=? mode "a+" 2)
			(substring=? mode "w+" 2)))
	 (writeable? (or (substring=? mode "w" 1)
			 (substring=? mode "a" 1)
			 (substring=? mode "r+" 2))))
      (cond
	 ((and writeable? (substring=? filename "http" 4))
	  (php-warning "failed to open stream: HTTP wrapper does not support writeable connections")
	  #f)
	 ((and writeable? readable? (substring=? filename "ftp" 3))
	  (php-warning "failed to open stream: FTP wrapper does not support simultaneous read/write connections")
	  #f)
	 (else 
	  (let* ((curl-stream
		  (instantiate::curl-stream
		     (curl (ccurl_easy_init))
		     (multi (ccurl_multi_init))
		     (pending 1)
		     (url filename)
		     (headers (make-php-hash))))
		 (curl (curl-stream-curl curl-stream))
		 (stream (make-extended-stream filename
					       readable?
					       writeable?
					       *curl-operations*
					       curl-stream) )
		 (wrapper-options (append (list
					   CURLOPT_URL (curl-stream-url curl-stream)
					   ; in php it says "currently buggy (bug is in curl)" */
					   CURLOPT_FOLLOWLOCATION 1
					   ;			errorbuffer: errstr
					   ;			verbose: 0
					   ; enable progress notification */
					   CURLOPT_NOPROGRESS #f
					   CURLOPT_USERAGENT *RAVEN-VERSION-TAG*)
					  ; on windows we don't have a ca file do don't verify
					  (cond-expand
					     (PCC_MINGW
					      (list CURLOPT_SSL_VERIFYPEER 0))
					     (else
					      '())))))

	     ; set options
	     (pcc-set-callbacks curl
				(lambda (data) (wrapper-write-from-curl data curl-stream))
				#f
				(lambda (data) (wrapper-on-header-available data curl-stream))
				wrapper-on-progress-available)
	     (apply pcc-easy-setopt curl wrapper-options)
			       
	     ; TODO: read cookies and options from context */
	     
	     ; prepare for "pull" mode */
	     (ccurl_multi_add_handle (curl-stream-multi curl-stream) curl)
	     
	     ; Prepare stuff for file-get-wrapper-data: the data is an array:
	     ;
	     ;data = array(
	     ;  "headers" => array("Content-Type: text/html", "Xxx: Yyy"),
	     ;  "readbuf" => resource (equivalent to curlstream->readbuffer)
	     ;);
	 ;*/
	     (let ((data (make-php-hash)))
		(php-hash-insert! data "headers" (curl-stream-headers curl-stream))
		(php-hash-insert! data "readbuf" read-buffer)
		
		(stream-wrapper-data-set! stream data)) ;mmm...
	     
	     ; fire up the connection; we need to detect a connection error here,
	     ; otherwise the curlstream we return ends up doing nothing useful. */
	     
	     (let loop ()
		(let ((r (pcc-multi-perform (curl-stream-multi curl-stream))))
		   ;	   (debug-trace 3 "multi-perform returned " r )
		   (when (curlm-call-multi-perform-again? "curl-stream-open" r)
		      (loop))))
	     stream) ))))

(define +EOF+ #f)

(define *curl-read-timeout-seconds* 15)

(define (curl-stream-read curl-stream read-length)
   (with-access::curl-stream curl-stream (multi pending read-buffer)
      (cond
	 ((zero? pending)
	  ;;the connection is closed, so whatever's in the buffer is all that's left
	  (let ((remaining (curl-buffer-remaining read-buffer)))
	     (if (zero? remaining)
		 +EOF+
		 (curl-buffer-read read-buffer (min remaining read-length)))))
	 ((> (curl-buffer-remaining read-buffer) read-length)
	  ;;the connection is not closed, but there's enough left in the buffer
	  ;;to satisfy this request
	  (let ((r (curl-buffer-read read-buffer read-length)))
;	     (fprint (current-error-port) "foo returning " r)
	     r))
	 (else
	  ;;try to read more data
	  (let ((read-some
		 (lambda ()
		    (let loop ()
		       (multiple-value-bind (errcode new-pending)
			  (pcc-multi-perform (curl-stream-multi curl-stream))
			  (if (curlm-call-multi-perform-again? "curl-stream-read" errcode)
			      (loop)
			      (set! pending new-pending)))))))
	     (let loop ()
		(read-some)
		(if (> (curl-buffer-remaining read-buffer) read-length)
		    (let ((r (curl-buffer-read read-buffer read-length)))
;		       (fprint (current-error-port) " 123 returning " r)
		       r)
		    (if (zero? pending)
			;;no more data coming
			(let ((r (curl-buffer-read read-buffer (curl-buffer-remaining read-buffer))))
;			   (fprint (current-error-port) "Returning " r)
			   r)
			;;wait for more data and try again
			(cond-expand
			   (PCC_MINGW
			    ; curl/mingw segfaults when we try to be nice to the cpu
			    ; with select, because of the async dns stuff. the hack here is to
			    ; busy loop :/
			    (loop))
			   (else
			(let ((tv (make-timeval))); (make-timeval*)))
			   (timeval*-usec-set! tv 0)
			   (timeval*-sec-set! tv 15)
;			   (let ((a-fdset::fd-set (pragma::fd-set "(fd_set*)GC_malloc_atomic(sizeof(fd_set))")))
;			      (fprint (current-error-port) "successfully made: " a-fdset)

			   (multiple-value-bind (readfds writefds excfds maxfd)
			      (pcc-multi-fdset multi)
			      (case (select (+ maxfd 1) readfds writefds excfds tv)
				 ((-1) (curl-buffer-read read-buffer
							 (curl-buffer-remaining read-buffer))) ;;error
				 ((0) (curl-buffer-read read-buffer
							(curl-buffer-remaining read-buffer)))  ;;no data yet -- timed out
				 (else (loop)))))))))))))))


(define (curl-stream-write . foo)
   (debug-trace 3 "Curl-stream-write " foo))

(define (curl-stream-close . foo)
   (debug-trace 3 "Curl-stream-close " foo))

(define (curl-stream-flush . foo)
   (debug-trace 3 "Curl-stream-flush " foo))




;;;;curl-buffer stuff
(define (make-curl-buffer)
   (instantiate::%curl-buffer
      (size 0)
      (position 0)
      (strings '())
      (strings-tail '())))


(define (curl-buffer-add-string buf str)
   (with-access::%curl-buffer buf (size strings strings-tail)
;      (fprint (current-error-port) "adding string that starts: " (substring str 0 (min 10 (string-length str))))
      (if (zero? size)
	  (let ((new-strings (list str)))
	     (set! strings new-strings)
	     (set! strings-tail new-strings))
	  (let ((new-tail (list str)))
	     (set-cdr! strings-tail new-tail)
	     (set! strings-tail new-tail)))
      (set! size (+ size (string-length str)))))

(define (curl-buffer-remaining buf)
   (with-access::%curl-buffer buf (size position)
      (- size position)))

(define (curl-buffer-read buf len)
   (let ((retval 
	 (with-access::%curl-buffer buf (size position strings strings-tail)
      (cond
	 ((zero? len) "")
	 ((> len (curl-buffer-remaining buf))
	  (error 'curl-buffer-read "not enough chars in buffer for length" len))
	 (else
	  (with-output-to-string
	     (lambda ()
		(let loop ((len len)
			   (str (car strings))
			   (str-len (string-length (car strings))))
		   (if (<= (- str-len position) len)
		       ;;the first string is not enough, or is just enough for the requested length
		       (begin
			  (display (substring str position str-len))
			  (set! len (- len (- str-len position)))
			  (set! size (- size str-len))
			  (set! strings (cdr strings))
			  (if (null? strings)
			      (set! strings-tail '()))
			  (set! position 0)

			  (unless (zero? len)
			     (loop len (car strings) (string-length (car strings)))))
		       ;;the first string is more than the requested length
		       (begin
			  (display (substring str position  (+ position len)))
			  (set! position (+ position len))))))))))))
;      (fprint (current-error-port) "Returning: " retval)
      retval))



; (curl-buffer-self-test)
(define (curl-buffer-self-test)
   ;;if you make changes to the curl buffer, be sure to run once with the
   ;;self-test above uncommented
   (try
    (let ((c (make-curl-buffer)))
       (print "curl-buffer self test:")
       (curl-buffer-add-string c "foo")
       (unless (= 3 (curl-buffer-remaining c))
	  (error 'a "curl-buffer-remaining" c))
       (unless (string=? "foo" (curl-buffer-read c 3))
	  (error 'b "curl-buffer-read" c))
       
       (curl-buffer-add-string c "wibble")
       (curl-buffer-add-string c "wobble")
       (curl-buffer-add-string c "wubble")
       (unless (= 18 (curl-buffer-remaining c))
	  (error 'c "curl-buffer-remaining" c))
       (unless (string=? "wibblewobblewub" (curl-buffer-read c 15))
	  (error 'd "curl-buffer-read" c))
       (unless (string=? "ble" (curl-buffer-read c 3))
	  (error 'e "curl-buffer-read" c))
       (unless (= 0 (curl-buffer-remaining c))
	  (error 'f "curl-buffer-remaining" c))
       
       (curl-buffer-add-string c "wibble")
       (unless (string=? "wi" (curl-buffer-read c 2))
	  (error 'g "curl-buffer-read" c))
       (unless (string=? "b" (curl-buffer-read c 1))
	  (error 'g1 "curl-buffer-read" c))
       (curl-buffer-add-string c "wobble")
       (unless (= 9 (curl-buffer-remaining c))
	  (error 'h "curl-buffer-remaining" c))

       (unless (string=? "blewobble" (curl-buffer-read c 9))
	  (error 'i "curl-buffer-read" c))
       (unless (= 0 (curl-buffer-remaining c))
	  (error 'j "curl-buffer-remaining" c))
       (unless (null? (%curl-buffer-strings c))
	  (error 'k "strings left" c))
       (unless (null? (%curl-buffer-strings-tail c))
	  (error 'l "strings left in tail" c)))
    
    (lambda (e p m o)
       (fprint (current-error-port) "curl-buffer-self-test failed p: " p " m: " m "o: " o))))


;; API / builtin stuff


;
; TODO:
; - php user functions for HEADER*/PASSWD*/READ*/WRITEFUNCTION options
; - support for file handles to FILE, STDERR, WRITEHEADER
; - support for array based options HTTP200ALIASES, HTTPHEADER, POSTQUOTE, QUOTE
; - support passing a hash for POSTFIELDS instead of just a string

(defresource curl-link "curl link"
   handle
   active?
   errbuf
   errno
   ret-type
   outbuf
   in-php-stream ; INFILE
   )

;; curl readfunction callback
; php -> curl
(define (phpapi-read-from-php maxlen curl-stream)
   (if (curl-link-in-php-stream curl-stream)
       (php-funcall "fread" (curl-link-in-php-stream curl-stream) maxlen)
       0))

;; curl writefunction callback
; curl -> php
(define (phpapi-write-from-curl data link)
   (if (eqv? (curl-link-ret-type link) 'return)
       (curl-link-outbuf-set! link (string-append (curl-link-outbuf link) data))
       (echo data))
   ;;curl seems to block if you don't return the length of the data
   (string-length data))

;; curl header callback
(define (phpapi-on-header-available data link)
   ;(echo data)
   ;;curl seems to block if you don't return the length of the data
   (string-length data))

; curl_version
(defbuiltin (curl_version)
   (ccurl_version))

; curl_init
(defbuiltin (curl_init (url 'unpassed))
   (let ((ch (curl-link-resource #f #f #f #f #f #f #f)))
      (curl-link-handle-set! ch (ccurl_easy_init))
      (curl-link-active?-set! ch #t)
      (curl-link-errbuf-set! ch (make-string (pragma::int "CURL_ERROR_SIZE+1")))
      (curl-link-errno-set! ch 0)
      (curl-link-ret-type-set! ch 'echo)
      (curl-link-outbuf-set! ch "")
      (curl-link-in-php-stream-set! ch #f)
      (pcc-set-callbacks (curl-link-handle ch)
 			 (lambda (data) (phpapi-write-from-curl data ch))
 			 (lambda (maxlen) (phpapi-read-from-php maxlen ch))
 			 (lambda (data) (phpapi-on-header-available data ch))
 			 #f)
      (pcc-set-errbuf (curl-link-handle ch) (curl-link-errbuf ch))
      (pcc-easy-setopt (curl-link-handle ch)
			CURLOPT_VERBOSE #f
			CURLOPT_HEADER #f
			CURLOPT_NOPROGRESS #t
			CURLOPT_MAXREDIRS 20)
      (when (not (eqv? url 'unpassed))
	 (pcc-easy-setopt (curl-link-handle ch)
			   CURLOPT_URL url))
      ch))

; curl_getinfo
(defbuiltin (curl_getinfo link (opt 'unpassed))
   (if (and (curl-link? link)
	    (curl-link-active? link))
       (bind-exit (return)
	  (let ((result (if (eqv? opt 'unpassed) (make-php-hash) ""))
		(opt? (lambda (v)
			 (or (eqv? opt 'unpassed)
			     (eqv? opt v)))))
	     ;
	     ; XXX these have to be in this order to match the zend php hash
	     ;
	     (when (opt? CURLINFO_EFFECTIVE_URL)
		(if (eqv? opt 'unpassed) 
		    (php-hash-insert! result "url" (pcc-easy-getinfo
						    (curl-link-handle link)
						    (CURLINFO-CURLINFO_EFFECTIVE_URL)))
		    (return (pcc-easy-getinfo
			     (curl-link-handle link)
			     (CURLINFO-CURLINFO_EFFECTIVE_URL)))))
	     (when (opt? CURLINFO_CONTENT_TYPE)
		(if (eqv? opt 'unpassed)
		    (let ((ctype (pcc-easy-getinfo
				  (curl-link-handle link)
				  (CURLINFO-CURLINFO_CONTENT_TYPE))))
		       (unless (string=? (mkstr ctype) "")
			  (php-hash-insert! result "content_type" ctype)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_CONTENT_TYPE)))))
	     (when (or (opt? CURLINFO_HTTP_CODE) (opt? CURLINFO_RESPONSE_CODE))
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "http_code" (pcc-easy-getinfo
							  (curl-link-handle link)
							  (CURLINFO-CURLINFO_RESPONSE_CODE)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_RESPONSE_CODE)))))
	     (when (opt? CURLINFO_HEADER_SIZE)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "header_size" (pcc-easy-getinfo
							    (curl-link-handle link)
							    (CURLINFO-CURLINFO_HEADER_SIZE)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_HEADER_SIZE)))))
	     (when (opt? CURLINFO_REQUEST_SIZE)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "request_size" (pcc-easy-getinfo
							     (curl-link-handle link)
							     (CURLINFO-CURLINFO_REQUEST_SIZE)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_REQUEST_SIZE)))))
	     (when (opt? CURLINFO_FILETIME)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "filetime" (pcc-easy-getinfo
							 (curl-link-handle link)
							 (CURLINFO-CURLINFO_FILETIME)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_FILETIME)))))
	     (when (opt? CURLINFO_SSL_VERIFYRESULT)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "ssl_verify_result" (pcc-easy-getinfo
								  (curl-link-handle link)
								  (CURLINFO-CURLINFO_SSL_VERIFYRESULT)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_SSL_VERIFYRESULT)))))
	     (when (opt? CURLINFO_REDIRECT_COUNT)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "redirect_count" 0)
		    (return 0)))
	     ;
	     (when (opt? CURLINFO_TOTAL_TIME)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "total_time" (pcc-easy-getinfo
							   (curl-link-handle link)
							   (CURLINFO-CURLINFO_TOTAL_TIME)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_TOTAL_TIME)))))
	     (when (opt? CURLINFO_NAMELOOKUP_TIME)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "namelookup_time" (pcc-easy-getinfo
								(curl-link-handle link)
								(CURLINFO-CURLINFO_NAMELOOKUP_TIME)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_NAMELOOKUP_TIME)))))
	     (when (opt? CURLINFO_CONNECT_TIME)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "connect_time" (pcc-easy-getinfo
							     (curl-link-handle link)
							     (CURLINFO-CURLINFO_CONNECT_TIME)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_CONNECT_TIME)))))
	     (when (opt? CURLINFO_PRETRANSFER_TIME)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "pretransfer_time" (pcc-easy-getinfo
								 (curl-link-handle link)
								 (CURLINFO-CURLINFO_PRETRANSFER_TIME)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_PRETRANSFER_TIME)))))
	     (when (opt? CURLINFO_SIZE_UPLOAD)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "size_upload" (pcc-easy-getinfo
							    (curl-link-handle link)
							    (CURLINFO-CURLINFO_SIZE_UPLOAD)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_SIZE_UPLOAD)))))
	     (when (opt? CURLINFO_SIZE_DOWNLOAD)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "size_download" (pcc-easy-getinfo
							      (curl-link-handle link)
							      (CURLINFO-CURLINFO_SIZE_DOWNLOAD)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_SIZE_DOWNLOAD)))))
	     (when (opt? CURLINFO_SPEED_DOWNLOAD)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "speed_download" (pcc-easy-getinfo
							       (curl-link-handle link)
							       (CURLINFO-CURLINFO_SPEED_DOWNLOAD)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_SPEED_DOWNLOAD)))))
	     (when (opt? CURLINFO_SPEED_UPLOAD)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "speed_upload" (pcc-easy-getinfo
							     (curl-link-handle link)
							     (CURLINFO-CURLINFO_SPEED_UPLOAD)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_SPEED_UPLOAD)))))
	     (when (opt? CURLINFO_CONTENT_LENGTH_DOWNLOAD)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "download_content_length" (pcc-easy-getinfo
									(curl-link-handle link)
									(CURLINFO-CURLINFO_CONTENT_LENGTH_DOWNLOAD)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_CONTENT_LENGTH_DOWNLOAD)))))
	     (when (opt? CURLINFO_CONTENT_LENGTH_UPLOAD)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "upload_content_length" (pcc-easy-getinfo
								      (curl-link-handle link)
								      (CURLINFO-CURLINFO_CONTENT_LENGTH_UPLOAD)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_CONTENT_LENGTH_UPLOAD)))))
	     (when (opt? CURLINFO_STARTTRANSFER_TIME)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "starttransfer_time" (pcc-easy-getinfo
								   (curl-link-handle link)
								   (CURLINFO-CURLINFO_STARTTRANSFER_TIME)))
		    (return (pcc-easy-getinfo (curl-link-handle link) (CURLINFO-CURLINFO_STARTTRANSFER_TIME)))))
	     (when (opt? CURLINFO_REDIRECT_TIME)
		(if (eqv? opt 'unpassed)
		    (php-hash-insert! result "redirect_time" 0)
		    (return 0)))
	     result
	     ))
       (php-warning "invalid curl resource")))

(define (make-curl-slist value-list)
   (let((slist::void* (pragma::void* "NULL")))
      (for-each
       (lambda(s)
	  (let((s::string s))
	     (set! slist (pragma::void* "curl_slist_append((struct curl_slist*)$1, $2)" slist s))))
       value-list)
      slist))

(define (free-curl-slist slist)
   (pragma::void "curl_slist_free_all((struct curl_slist*)$1)" slist)
   #t)

; curl_setopt
(defbuiltin (curl_setopt link option value)
   (bind-exit (return) 
      (if (and (curl-link? link)
	       (curl-link-active? link))
	  (let ((copt (hashtable-get *curl-opt-table* (mkfixnum option))))
	     (if (eqv? copt #f)
		 ; it's not a real curl constant. may be special php constant
		 (cond
		    ((php-= option CURLOPT_RETURNTRANSFER)
		     (begin
			(if (php-= value TRUE)
			    (curl-link-ret-type-set! link 'return)
			    (curl-link-ret-type-set! link 'echo))
			(return TRUE)))
		    ((php-= option CURLOPT_BINARYTRANSFER)
		     ; unsupported?
		     (return TRUE))
		    ((php-= option CURLOPT_INFILE)
		     (let ((fd (extended-stream-get-fd (maybe-unbox value))))
			(if fd
			    (begin
			       (curl-link-in-php-stream-set! link (maybe-unbox value))
			       (return TRUE))
			    (return (php-warning "INFILE: file handle is invalid")))))
		    ((php-= option CURLOPT_TIMECONDITION)
		     (return TRUE))
		    ((php-= option CURLOPT_HTTP_VERSION)
		     (return TRUE))
		    (else
		     (php-warning (format "unknown or unsupported option: [~a]" option))
		     (return TRUE))) ; php silently ignores and returns true if bad option?
		 ;;;;;;;;;;;;
		 ; this is a valid curl option enum
		 ; some of them get special processing
		 (cond
		    ((php-= option CURLOPT_POSTFIELDS)
		     (when (eqv? (do-setopt link CURLOPT_POSTFIELDSIZE (string-length (convert-to-string value)))
				 FALSE)
			(return FALSE))
		     (return (do-setopt link CURLOPT_POSTFIELDS (convert-to-string value))))
		    (else
		     ; these are the generic passthroughs
		     (let ((cenum (car copt))
			   (ctype (cadr copt))
			   (retval FALSE))
			(cond
			   ((eqv? ctype 'int) (set! retval (do-setopt link option (mkfixnum value))))
			   ((eqv? ctype 'bool) (set! retval (do-setopt link option (convert-to-boolean value))))
			   ((eqv? ctype 'str) (set! retval (do-setopt link option (convert-to-string value))))
			   ((eqv? ctype 'slist)
			    (if (php-hash? value)
				(let ((slist (make-curl-slist (php-hash->list value))))
				   (set! retval (do-setopt link option slist))
				   (free-curl-slist slist))
				(return (php-warning "option requires an array as a value"))))
			   (else
			    (return (php-error "invalid curl option type: " ctype))))
			(return retval))))))
		 (php-warning "invalid curl resource"))))

                 
; 		 ((timecondition:) (let ((php-val (string->symbol (convert-to-string value))))
; 				      (if (or (eqv? php-val 'ifmodsince)
; 					      (eqv? php-val 'lastmod)
; 					      (eqv? php-val 'isunmodsince))
; 					  (set! final-val value)
; 					  (set! final-val 'none))))		 
                 
; 		 ((http-version:) (let ((php-val (string->symbol (convert-to-string value))))
;                                      (if (or (eqv? php-val 'none)
;                                              (eqv? php-val '1.0)
;                                              (eqv? php-val '1.1))
;                                          (set! final-val value)
;                                          (set! final-val 'none)))))

(define (do-setopt link option val)
   (let* ((had-error #f)
	  (handler (lambda (esc proc msg obj)
		      ; this is returned to caller on error, and stored in errno
		      (set! had-error #t)
			  ; convert it to a php userland error number
		      (let ((phpnum (pragma::int "FOREIGN_TO_COBJ($1)" obj)))
			 (esc (convert-to-number phpnum))))))
      
      (debug-trace 2 (format "setting curl option ~a to ~a" option val))
      
      (let ((result (try
		     (pcc-easy-setopt (curl-link-handle link)
				      option
				      val)
		     handler)))
	 (curl-link-errno-set! link result)
	 (if had-error
	     FALSE
	     TRUE))))

; curl_error
(defbuiltin (curl_error link)
   (if (and (curl-link? link)
	    (curl-link-active? link))
       (if (php-= (convert-to-number (curl-link-errno link)) CURLE_OK)
	   ""
	   ($string->bstring (curl-link-errbuf link)))
       (php-warning "invalid curl resource")))

; curl_errno
(defbuiltin (curl_errno link)
   (if (and (curl-link? link)
	    (curl-link-active? link))
       (convert-to-number (curl-link-errno link))
       (php-warning "invalid curl resource")))

; curl_exec
(defbuiltin (curl_exec link)
   (if (and (curl-link? link)
	    (curl-link-active? link))
       (let* ((had-error #f)
	      (handler (lambda (esc proc msg obj)
			  ; this is returned to caller on error, and stored in errno
			  (set! had-error #t)
			  ; convert it to a php userland error number
			  (let ((phpnum (pragma::int "FOREIGN_TO_COBJ($1)" obj)))
			     (esc (convert-to-number phpnum))))))
	  (curl-link-outbuf-set! link "")
	  (let ((result (try
			(curle-error-check "ccurl_easy_perform"			 
					   (ccurl_easy_perform (curl-link-handle link)))
			 handler)))
	     (curl-link-errno-set! link result)
	     (if had-error
		 FALSE
		 (if (eqv? (curl-link-ret-type link) 'return)
		     (if (> (string-length (mkstr (curl-link-outbuf link))) 0)
			 (curl-link-outbuf link)
			 TRUE)
		     TRUE))))
       (php-warning "invalid curl resource")))

; curl_close
(defbuiltin (curl_close link)
   (if (and (curl-link? link)
	    (curl-link-active? link))
       (begin
	  (ccurl_easy_cleanup (curl-link-handle link))
	  (curl-link-active?-set! link #f)	  
	  NULL)
       (php-warning "invalid curl resource")))

; and now for something COMPLETELY different - an enormous list of constants!!!


; used in get_info
(defconstant CURLINFO_EFFECTIVE_URL 0)
(defconstant CURLINFO_HTTP_CODE 1)
(defconstant CURLINFO_HEADER_SIZE 2)
(defconstant CURLINFO_REQUEST_SIZE 3)
(defconstant CURLINFO_TOTAL_TIME 4)
(defconstant CURLINFO_NAMELOOKUP_TIME 5)
(defconstant CURLINFO_CONNECT_TIME 6)
(defconstant CURLINFO_PRETRANSFER_TIME 7)
(defconstant CURLINFO_SIZE_UPLOAD 8)
(defconstant CURLINFO_SIZE_DOWNLOAD 9)
(defconstant CURLINFO_SPEED_DOWNLOAD 10)
(defconstant CURLINFO_SPEED_UPLOAD 11)
(defconstant CURLINFO_FILETIME 12)
(defconstant CURLINFO_SSL_VERIFYRESULT 13)
(defconstant CURLINFO_CONTENT_LENGTH_DOWNLOAD 14)
(defconstant CURLINFO_CONTENT_LENGTH_UPLOAD 15)
(defconstant CURLINFO_STARTTRANSFER_TIME 16)
(defconstant CURLINFO_CONTENT_TYPE 17)
(defconstant CURLINFO_REDIRECT_TIME 18)
(defconstant CURLINFO_REDIRECT_COUNT 19)
(defconstant CURLINFO_RESPONSE_CODE 20) ; XXX alias for HTTP_CODE

; curl option handling
(define *curl-opt-table* (make-hashtable))
; start real options at 1
(hashtable-put! *curl-opt-table* 0 #f)
 
(define-macro (defcurlopt name type)
   (let ((curl-enum (string->symbol (string-append
				     "CURLoption-"
				     (symbol->string name)))))
      `(begin
	  (hashtable-put! *curl-opt-table*
			  ; key is a sequential number
			  (hashtable-size *curl-opt-table*)
			  ; value is our enum from the binding
			  (list (,curl-enum) ',type))
	  (defconstant ,name (- (hashtable-size *curl-opt-table*) 1)))))

; php userspace options
; XXX don't change the order, only add new at the bottom!
;     this will prevent breakage of code that depends
;     on the value of the constant (even if it shouldn't)
(defcurlopt CURLOPT_URL str)
(defcurlopt CURLOPT_HEADER bool)
(defcurlopt CURLOPT_DNS_USE_GLOBAL_CACHE int)
(defcurlopt CURLOPT_DNS_CACHE_TIMEOUT int)
(defcurlopt CURLOPT_PORT int)
(defcurlopt CURLOPT_INFILESIZE int)
(defcurlopt CURLOPT_PROXY str)
(defcurlopt CURLOPT_VERBOSE bool)
(defcurlopt CURLOPT_NOPROGRESS bool)
(defcurlopt CURLOPT_NOBODY bool)
(defcurlopt CURLOPT_FAILONERROR bool)
(defcurlopt CURLOPT_UPLOAD bool)
(defcurlopt CURLOPT_POST bool)
(defcurlopt CURLOPT_FTPLISTONLY bool)
(defcurlopt CURLOPT_FTPAPPEND bool)
(defcurlopt CURLOPT_NETRC bool)
(defcurlopt CURLOPT_FOLLOWLOCATION int)
(defcurlopt CURLOPT_PUT int)
(defcurlopt CURLOPT_USERPWD str)
(defcurlopt CURLOPT_PROXYUSERPWD str)
(defcurlopt CURLOPT_RANGE str)
(defcurlopt CURLOPT_TIMEOUT int)
(defcurlopt CURLOPT_REFERER str)
(defcurlopt CURLOPT_USERAGENT str)
(defcurlopt CURLOPT_FTPPORT int)
(defcurlopt CURLOPT_FTP_USE_EPSV int)
(defcurlopt CURLOPT_LOW_SPEED_LIMIT int)
(defcurlopt CURLOPT_LOW_SPEED_TIME int)
(defcurlopt CURLOPT_RESUME_FROM int)
(defcurlopt CURLOPT_COOKIE str)
(defcurlopt CURLOPT_SSLCERT str)
(defcurlopt CURLOPT_SSLCERTPASSWD str)
(defcurlopt CURLOPT_WRITEHEADER proc)
(defcurlopt CURLOPT_SSL_VERIFYHOST int)
(defcurlopt CURLOPT_COOKIEFILE str)
(defcurlopt CURLOPT_SSLVERSION int)
(defcurlopt CURLOPT_TIMEVALUE int)
(defcurlopt CURLOPT_CUSTOMREQUEST str)
(defcurlopt CURLOPT_STDERR int)
(defcurlopt CURLOPT_TRANSFERTEXT int)
(defcurlopt CURLOPT_QUOTE proc)
(defcurlopt CURLOPT_POSTQUOTE int)
(defcurlopt CURLOPT_INTERFACE int)
(defcurlopt CURLOPT_KRB4LEVEL int)
(defcurlopt CURLOPT_HTTPPROXYTUNNEL int)
(defcurlopt CURLOPT_FILETIME int)
(defcurlopt CURLOPT_MAXREDIRS int)
(defcurlopt CURLOPT_MAXCONNECTS int)
(defcurlopt CURLOPT_CLOSEPOLICY int)
(defcurlopt CURLOPT_FRESH_CONNECT int)
(defcurlopt CURLOPT_FORBID_REUSE int)
(defcurlopt CURLOPT_RANDOM_FILE int)
(defcurlopt CURLOPT_EGDSOCKET int)
(defcurlopt CURLOPT_CONNECTTIMEOUT int)
(defcurlopt CURLOPT_SSL_VERIFYPEER int)
(defcurlopt CURLOPT_CAINFO int)
(defcurlopt CURLOPT_COOKIEJAR int)
(defcurlopt CURLOPT_SSL_CIPHER_LIST int)
(defcurlopt CURLOPT_HTTPGET int)
(defcurlopt CURLOPT_SSLKEY int)
(defcurlopt CURLOPT_SSLKEYTYPE int)
(defcurlopt CURLOPT_SSLKEYPASSWD str)
(defcurlopt CURLOPT_SSLENGINE int)
(defcurlopt CURLOPT_SSLENGINE_DEFAULT int)
(defcurlopt CURLOPT_CRLF int)
(defcurlopt CURLOPT_HTTPHEADER slist)
(defcurlopt CURLOPT_POSTFIELDS str)
(defcurlopt CURLOPT_POSTFIELDSIZE int)
;(defcurlopt CURLOPT_ENCODING)
;(defcurlopt CURLOPT_HTTPAUTH)
;(defcurlopt CURLOPT_CAPATH)

;; special php options that aren't in curl
(defconstant CURLOPT_BINARYTRANSFER  500)
(defconstant CURLOPT_FTPASCII        501)
(defconstant CURLOPT_RETURNTRANSFER  502)
(defconstant CURLOPT_MUTE            503)
(defconstant CURLOPT_WRITEFUNCTION   504)
(defconstant CURLOPT_READFUNCTION    505)
(defconstant CURLOPT_PASSWDFUNCTION  506)
(defconstant CURLOPT_HEADERFUNCTION  507)
(defconstant CURLOPT_INFILE          508)
(defconstant CURLOPT_TIMECONDITION   511)
(defconstant CURLOPT_HTTP_VERSION    512)

;  	(defconstant CURLAUTH_BASIC)
;  	(defconstant CURLAUTH_DIGEST)
;  	(defconstant CURLAUTH_GSSNEGOTIATE)
;  	(defconstant CURLAUTH_NTLM)
;  	(defconstant CURLAUTH_ANY)
;  	(defconstant CURLAUTH_ANYSAFE)

; 	(defconstant CURLOPT_PROXYAUTH)

; 	(defconstant CURLCLOSEPOLICY_LEAST_RECENTLY_USED)
; 	(defconstant CURLCLOSEPOLICY_LEAST_TRAFFIC)
; 	(defconstant CURLCLOSEPOLICY_SLOWEST)
; 	(defconstant CURLCLOSEPOLICY_CALLBACK)
; 	(defconstant CURLCLOSEPOLICY_OLDEST)


; error codes
(defconstant CURLE_OK 0)
(defconstant CURLE_UNSUPPORTED_PROTOCOL 1)
(defconstant CURLE_FAILED_INIT 2)
(defconstant CURLE_URL_MALFORMAT 3)
(defconstant CURLE_URL_MALFORMAT_USER 4)
(defconstant CURLE_COULDNT_RESOLVE_PROXY 5)
(defconstant CURLE_COULDNT_RESOLVE_HOST 6)
(defconstant CURLE_COULDNT_CONNECT 7)
(defconstant CURLE_FTP_WEIRD_SERVER_REPLY 8)
(defconstant CURLE_FTP_ACCESS_DENIED 9)
(defconstant CURLE_FTP_USER_PASSWORD_INCORRECT 10)
(defconstant CURLE_FTP_WEIRD_PASS_REPLY 11)
(defconstant CURLE_FTP_WEIRD_USER_REPLY 12)
(defconstant CURLE_FTP_WEIRD_PASV_REPLY 13)
(defconstant CURLE_FTP_WEIRD_227_FORMAT 14)
(defconstant CURLE_FTP_CANT_GET_HOST 15)
(defconstant CURLE_FTP_CANT_RECONNECT 16)
(defconstant CURLE_FTP_COULDNT_SET_BINARY 17)
(defconstant CURLE_PARTIAL_FILE 18)
(defconstant CURLE_FTP_COULDNT_RETR_FILE 19)
(defconstant CURLE_FTP_WRITE_ERROR 20)
(defconstant CURLE_FTP_QUOTE_ERROR 21)
(defconstant CURLE_HTTP_NOT_FOUND 22)
(defconstant CURLE_WRITE_ERROR 23)
(defconstant CURLE_MALFORMAT_USER 24)
(defconstant CURLE_FTP_COULDNT_STOR_FILE 25)
(defconstant CURLE_READ_ERROR 26)
(defconstant CURLE_OUT_OF_MEMORY 27)
(defconstant CURLE_OPERATION_TIMEOUTED 28)
(defconstant CURLE_FTP_COULDNT_SET_ASCII 29)
(defconstant CURLE_FTP_PORT_FAILED 30)
(defconstant CURLE_FTP_COULDNT_USE_REST 31)
(defconstant CURLE_FTP_COULDNT_GET_SIZE 32)
(defconstant CURLE_HTTP_RANGE_ERROR 33)
(defconstant CURLE_HTTP_POST_ERROR 34)
(defconstant CURLE_SSL_CONNECT_ERROR 35)
(defconstant CURLE_FTP_BAD_DOWNLOAD_RESUME 36)
(defconstant CURLE_FILE_COULDNT_READ_FILE 37)
(defconstant CURLE_LDAP_CANNOT_BIND 38)
(defconstant CURLE_LDAP_SEARCH_FAILED 39)
(defconstant CURLE_LIBRARY_NOT_FOUND 40)
(defconstant CURLE_FUNCTION_NOT_FOUND 41)
(defconstant CURLE_ABORTED_BY_CALLBACK 42)
(defconstant CURLE_BAD_FUNCTION_ARGUMENT 43)
(defconstant CURLE_BAD_CALLING_ORDER 44)
(defconstant CURLE_HTTP_PORT_FAILED 45)
(defconstant CURLE_BAD_PASSWORD_ENTERED 46)
(defconstant CURLE_TOO_MANY_REDIRECTS 47)
(defconstant CURLE_UNKNOWN_TELNET_OPTION 48)
(defconstant CURLE_TELNET_OPTION_SYNTAX 49)
(defconstant CURLE_OBSOLETE 50)
(defconstant CURLE_SSL_PEER_CERTIFICATE 51)
(defconstant CURLE_GOT_NOTHING 52)
(defconstant CURLE_SSL_ENGINE_NOTFOUND 53)
(defconstant CURLE_SSL_ENGINE_SETFAILED 54)
(defconstant CURLE_SEND_ERROR 55)
(defconstant CURLE_RECV_ERROR 56)
(defconstant CURLE_SHARE_IN_USE 57)
(defconstant CURLE_SSL_CERTPROBLEM 58)
(defconstant CURLE_SSL_CIPHER 59)
(defconstant CURLE_SSL_CACERT 60)
(defconstant CURLE_BAD_CONTENT_ENCODING 61)
(defconstant CURLE_LDAP_INVALID_URL 62)
(defconstant CURLE_FILESIZE_EXCEEDED 63)
(defconstant CURLE_FTP_SSL_FAILED 64)
(defconstant CURLE_SEND_FAIL_REWIND 65)
(defconstant CURLE_SSL_ENGINE_INITFAILED 66)
(defconstant CURLE_LOGIN_DENIED 67)

;(defconstant CURL_NETRC_OPTIONAL)
;(defconstant CURL_NETRC_IGNORED)
;(defconstant CURL_NETRC_REQUIRED)

(defconstant CURL_HTTP_VERSION_NONE 'none)
(defconstant CURL_HTTP_VERSION_1_0 '1.0)
(defconstant CURL_HTTP_VERSION_1_1 '1.1)


(defconstant CURL_TIMECOND_IFMODSINCE 'ifmodsince)
(defconstant CURL_TIMECOND_ISUNMODSINCE 'isunmodsince)
(defconstant CURL_TIMECOND_LASTMOD 'lastmod)


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

(module php-session-lib
   (library profiler)
   (import (php-variable-lib "php-variable.scm"))
   (import (php-string-lib "php-strings.scm"))
   (import (php-time-lib "php-time.scm"))
   (import (php-math-lib "php-math.scm"))
   (import (php-files-lib "php-files.scm"))
;   (import (webconnect "../../../webconnect/webconnect.scm"))
   (include "../phpoo-extension.sch")
   ; exports
   (export
    (init-php-session-lib)
    (session_cache_expire newval)
    (session_cache_limiter newval)
    (session_decode str)
    (session_destroy)
    (session_encode)
    (session_get_cookie_params)
    (session_id newid)
    (session_is_registered var)
    (session_module_name newname)
    (session_name newname)
    (session_regenerate_id)
    (session_register . var1-n)
    (session_save_path newpath)
    (session_set_cookie_params lifetime path domain secure)
    (session_set_save_handler open close read write destroy gc)
    (session_start)
    (session_unregister var)
    (session_unset)
    (session_write_close)
    ))

(define (init-php-session-lib)
   1)

; register the extension
(register-extension "session" "1.0.0"
                    "php-std" '())

; defaults are per php.ini defaults
(default-ini-entry "session.cookie_lifetime"   *zero*)
(default-ini-entry "session.cookie_path"       "/")
(default-ini-entry "session.cookie_domain"     "")
(default-ini-entry "session.cookie_secure"     #f)
(default-ini-entry "session.save_path"         (cond-expand
						  (PCC_MINGW "")
						  (else "/tmp")))
(default-ini-entry "session.name"              "PHPSESSID")
(default-ini-entry "session.save_handler"      "files")
(default-ini-entry "session.auto_start"        *zero*)
(default-ini-entry "session.serialize_handler" "php")
(default-ini-entry "session.use_cookies"       *one*) 
(default-ini-entry "session.use_only_cookies"  *zero*) 
(default-ini-entry "session.referer_check"     "")
(default-ini-entry "session.entropy_file"      "")
(default-ini-entry "session.entropy_length"    *zero*)
(default-ini-entry "session.cache_limiter"     "nocache")
(default-ini-entry "session.cache_expire"      (mkfixnum 180))
(default-ini-entry "session.use_trans_id"      *zero*)
(default-ini-entry "session.gc_probability"    *one*)
(default-ini-entry "session.gc_divisor"        (mkfixnum 100))
(default-ini-entry "session.gc_maxlifetime"    (mkfixnum 1440))


; current session
(define-struct session
   status          ; status
   sid             ; session id
   using-cookie    ; whether we got the session from a cookie or not
   rvars           ; current list of registered variables
   name            ; the session 'name'. alphanum chars
   save-path       ; session save path
   cache-expire    ; cache expire in minutes
   cache-limiter   ; cache limiter: none/nocache/private/private_no_expire/public
   cookie-lifetime ; cookie stuff
   cookie-path
   cookie-domain
   cookie-secure
   fd              ; session file descriptor for read/write/lock
   size            ; session file size
   php-open        ; php level handlers
   php-close
   php-read
   php-write
   php-destroy
   php-gc
   )

; end of page reset
(define (php-session-reset)
   ; we have an active, save first
   (when (eqv? (session-status *current-session*)
	     'active)
       (php-session-save))
   ; reset
   (session-status-set! *current-session* 'inactive)
   (session-sid-set! *current-session* 'unset)
   (session-using-cookie-set! *current-session* #f)
   (session-rvars-set! *current-session* '())
   (session-name-set! *current-session* (get-ini-entry "session.name"))
   (session-save-path-set! *current-session* (get-ini-entry "session.save_path"))
   (session-cache-expire-set! *current-session* (get-ini-entry "session.cache_expire"))
   (session-cache-limiter-set! *current-session* (get-ini-entry "session.cache_limiter"))
   (session-cookie-lifetime-set! *current-session* (get-ini-entry "session.cookie_lifetime"))
   (session-cookie-path-set! *current-session* (get-ini-entry "session.cookie_path"))
   (session-cookie-domain-set! *current-session* (get-ini-entry "session.cookie_domain"))
   (session-cookie-secure-set! *current-session* (get-ini-entry "session.cookie_secure"))
   (session-php-open-set! *current-session* #f)
   (session-php-close-set! *current-session* #f)
   (session-php-read-set! *current-session* #f)
   (session-php-write-set! *current-session* #f)
   (session-php-destroy-set! *current-session* #f)
   (session-php-gc-set! *current-session* #f)
   (session-fd-set! *current-session* #f)
   (session-size-set! *current-session* 0)
   )

; current session. initialize once at startup
(define *current-session* (make-session))
(php-session-reset)

; .. and then after every page
(add-end-page-reset-func php-session-reset)

; or in cli, since php-reset won't get run
(when *commandline?*
   (register-exit-function! php-cl-session-save))

; add startup function (from php-runtime)
(add-startup-function maybe-start-session)

(define (maybe-start-session)
;   (print "checking for session auto start:" (mkstr (get-ini-entry "session.auto_start")))
   (if (convert-to-boolean (get-ini-entry "session.auto_start"))
       (session_start)))

;;;;;;

; always file for now
(define *session-close-func* session-files-close)
(define *session-open-func* session-files-open)
(define *session-destroy-func* session-files-destroy)
(define *session-write-func* session-files-write)
(define *session-read-func* session-files-read) 
(define *session-gc-func* session-files-gc)

(define (php-cl-session-save status)
   (when (eqv? (session-status *current-session*) 'active)
      (php-session-save))
   status)
   
; if active session, save after a page load
(define (php-session-save)
   (debug-trace 2 (mkstr "saving session " (session-sid *current-session*)))
   ; writer
   (if (session-php-write *current-session*)
	     ; user land
	     (php-funcall (session-php-write *current-session*)
			  (session-sid *current-session*)
			  (session-encode))
	     ; in house
	     (*session-write-func*))
   ; closer
   (if (session-php-close *current-session*)
       ; user land
       (php-funcall (session-php-close *current-session*))
       ; in house
       (*session-close-func*)))

(define *session-files-prefix*   "sess_")

(define (session-files-getname)
   (mkstr
    (session-save-path *current-session*)
    (pcc-file-separator)
    *session-files-prefix*
    (session-sid *current-session*)))

; open/lock session file
(define (session-files-open)
   (when (eqv? (session-status *current-session*) 'active)
      (let ((file-name (session-files-getname)))
	 (session-fd-set! *current-session* (php-fopen file-name "a+" 'unpassed 'unpassed))
	 (if (session-fd *current-session*)
	     (begin
		(php-flock (session-fd *current-session*) LOCK_EX 'unpassed)
		(session-size-set! *current-session* (file-size file-name)))
	     (php-warning (format "could not open session file ~a: session will be lost" file-name))))))

; close/unlock session file
(define (session-files-close)
   (when (and (eqv? (session-status *current-session*) 'active)
	      (session-fd *current-session*))
      (php-flock (session-fd *current-session*) LOCK_UN 'unpassed)
      (fclose (session-fd *current-session*))
      (session-fd-set! *current-session* #f)))

; write out session
(define (session-files-write)
   (when (and (eqv? (session-status *current-session*) 'active)
	      (session-fd *current-session*))
      ; truncate
      (ftruncate (session-fd *current-session*) 0)
      ; seek
      ;(fseek (session-fd *current-session*) 0 SEEK_SET)
      ; write
      (fwrite (session-fd *current-session*) (session-encode) 'unpassed)))
   
; read in session
(define (session-files-read)
   (when (and (eqv? (session-status *current-session*) 'active)
	      (session-fd *current-session*))
      ; seek
      (fseek (session-fd *current-session*) 0 SEEK_SET)
      ; read
      (let ((sdata (fread (session-fd *current-session*) (session-size *current-session*))))
	 ;(print "sdata is [" sdata "]")
	 (when (and sdata
		    (> (string-length sdata) 0))
	    (session-decode sdata)))))

; destroy a session
(define (session-files-destroy)
   (when (eqv? (session-status *current-session*) 'active)
      (session-files-close)
      (let ((file-name (session-files-getname)))
	 (when (file-exists? file-name)
	    (delete-file file-name)))))

; garbage collect
; return number of sessions collected
(define (session-files-gc)
   (when (and (eqv? (session-status *current-session*) 'active)
	      (directory? (session-save-path *current-session*)))
      (let ((file-list (directory->list (session-save-path *current-session*))))
	 (let loop ((file file-list)
		    (cnt 0))
	    ;(if (pair? file) (fprint (current-error-port) (format "checking ~a" (car file))))
	    (if (and (pair? file)
		     (substring=? *session-files-prefix* (car file) (string-length *session-files-prefix*)))
		(let ((exp-time (+ (file-modification-time (car file))
					 (onum->elong (convert-to-number (get-ini-entry "session.gc_maxlifetime"))))))		     
		   (if (< exp-time (current-seconds))
		       (begin
			  ; nuke it
			  ;(fprint (current-error-port) (format "removing ~a" (car file)))
			  (delete-file (mkstr (session-save-path *current-session*)
					      (pcc-file-separator)
					      (car file)))
			  (loop (cdr file) (+ cnt 1)))
		       ; s'okay
		       (begin
			  ;(fprint (current-error-port) (format "not expired ~a ~a ~a" (car file) exp-time (current-seconds)))
			  (loop (cdr file) cnt))))
		; check next if we have no
		(if (pair? file)
		    (loop (cdr file) cnt)
		    ; all done, return # removed
		    cnt))))))
      
;;;;;;

(define (verify-session-id id)
   ; md5's fall in this range but also custom id's set with session_id()
   (pregexp-match "^[a-zA-Z0-9]+$" id))

; make a new (hopefully) unique md5 session id
; uniqid uses microtime
(define (make-session-id)
   (let ((newid (md5sum-string (uniqid (php-rand 0 2147483647.0) 'unset))))
      (set-session-id newid)))

; when setting a new id, if we are using a cookie we don't
; fill SID or add the session variable to transparent rewrite
(define (set-session-id newid)
   ; if transparent session id's are on, prep
   (when (convert-to-boolean (get-ini-entry "session.use_trans_id"))
      (if (session-using-cookie *current-session*)
	  (hashtable-remove! *output-rewrite-vars*
			     (session-name *current-session*))
	  (hashtable-put! *output-rewrite-vars*
			  (session-name *current-session*)
			  newid)))
   ; update constant
   (if (session-using-cookie *current-session*)
       (update-constant SID "")
       (update-constant SID (mkstr (session-name *current-session*) "=" newid)))
   ; current session
   (session-sid-set! *current-session* newid))

; 'encode' the current session by taking all variables in _SESSION
; and build a string delimited with | built from
; the key from _SESSION (var name) with it's serialized value
(define (session-encode)
   (if (php-hash? (container-value $_SESSION))
       (with-output-to-string
	  (lambda ()
	     (php-hash-for-each (container-value $_SESSION)
				(lambda (k v)
				   (display (format "~a|~a" k (serialize v)))))))
       ""))

; reverse the encode to fill the _SESSION variable
(define (session-decode str)
   (set! str (mkstr str))
   ; this would only happen if they unset() $_SESSION or did something else funky
   (unless (php-hash? (container-value $_SESSION))
      (container-value-set! $_SESSION (make-php-hash)))
   (let ((offset 0))
      (let loop ()
	 ;(print "at loop offset is " offset " dealing with " (substring str offset (string-length str))) 
	 (let ((delim-loc (mkfixnum (strpos str "|" offset)))
	       (varname ""))
	    (when delim-loc		     
	       (set! varname (substring str offset delim-loc))
	       (set! offset (+ delim-loc 1))
	       (multiple-value-bind (varval end-offset)
		  (php-hash-insert! (container-value $_SESSION)
				    varname
				    ; XXX if this fails, it may block loading of the page until
				    ; the bad session file is cleared away. not sure how zend
				    ; handles it
				    (unserialize (substring str offset (string-length str))))
		  (when (< (+ offset end-offset) (string-length str))
		     (set! offset (+ offset end-offset))
		     (loop))))))))


(define (send-session-cookie) #f)
;mingw    (when (eqv? (session-status *current-session*) 'active)
;mingw       (setcookie (session-name *current-session*)
;mingw 		 (session-sid *current-session*)
;mingw 		 (session-cookie-lifetime *current-session*)
;mingw 		 (session-cookie-path *current-session*)
;mingw 		 (session-cookie-domain *current-session*)
;mingw 		 (session-cookie-secure *current-session*))))

(define (limit-nocache)
;mingw   (header "Expires: Mon, 26 Jul 1997 05:00:00 GMT" #f)
;mingw   (header "Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0" #f)
;mingw   (header "Pragma: no-cache" #f)
   #t)

(define (limit-private)
;mingw   (header "Expires: Mon, 26 Jul 1997 05:00:00 GMT" #f)
   (limit-private-no-expire))

(define (limit-private-no-expire)
;mingw   (header (format "Cache-Control: private, max-age=~a, pre-check=~a"
;mingw		   (* (session-cache-expire *current-session*) 60)
;mingw		   (* (session-cache-expire *current-session*) 60)) #f)
    #f)

(define (limit-public)
;mingw   (header (format "Expires: ~a GMT"
;mingw		   (gmdate "D, d M Y H:i:s"
;mingw			   (+second (current-seconds)
;mingw				    (flonum->elong (fixnum->flonum
;mingw
;mingw						    (* (session-cache-expire *current-session*) 60)))))) #f)
;mingw   (header (format "Cache-Control: public, max-age=~a"
;mingw		   (* (session-cache-expire *current-session*) 60)) #f))
    #f)

(define (session-cache-limit)
   (when (eqv? (session-status *current-session*) 'active)
      (string-case (mkstr (session-cache-limiter *current-session*))
	 ("nocache" (limit-nocache))
	 ("private" (limit-private))
	 ("private_no_expire" (limit-private-no-expire))
	 ("public" (limit-public))
	 ("none" #t)
	 (else
	  (php-warning (format "unrecognized session cache limiter: ~a" (session-cache-limiter *current-session*))))))) 

;;;;;;

; session_cache_expire -- Return current cache expire
(defbuiltin (session_cache_expire (newval 'unset))
   (if (eqv? newval 'unset)
       (session-cache-expire *current-session*)
       (let ((oldval (session-cache-expire *current-session*)))
	  (session-cache-expire-set! *current-session* (mkfixnum newval))
	  oldval)))

; session_cache_limiter -- Get and/or set the current cache limiter
(defbuiltin (session_cache_limiter (newval 'unset))
   (if (eqv? newval 'unset)
       (session-cache-limiter *current-session*)
       (let ((oldval (session-cache-limiter *current-session*)))
	  (session-cache-limiter-set! *current-session* (mkstr newval))
	  oldval)))

; session_decode -- Decodes session data from a string
(defbuiltin (session_decode str)
   (session-decode str))

; session_destroy -- Destroys all data registered to a session
(defbuiltin (session_destroy)
   (if (session-php-destroy *current-session*)
	     ; user land
	     (php-funcall (session-php-destroy *current-session*)
			  (session-sid *current-session*))
	     ; in house
	     (*session-destroy-func*))
   (session_unset))

; session_encode --  Encodes the current session data as a string
(defbuiltin (session_encode)
   (session-encode))

; session_get_cookie_params --  Get the session cookie parameters
(defbuiltin (session_get_cookie_params)
   (let ((params (make-php-hash)))
      (php-hash-insert! params "lifetime" (convert-to-integer (session-cookie-lifetime *current-session*)))
      (php-hash-insert! params "path" (mkstr (session-cookie-path *current-session*)))
      (php-hash-insert! params "domain" (mkstr (session-cookie-domain *current-session*)))
      (php-hash-insert! params "secure" (convert-to-boolean (session-cookie-secure *current-session*)))
      params))

; session_id -- Get and/or set the current session id
(defbuiltin (session_id (newid 'unset))
   (if (eqv? newid 'unset)
       (session-sid *current-session*)
       (let ((oldid (session-sid *current-session*))
	     (snewid (mkstr newid)))
	  (if (verify-session-id snewid)
	      (session-sid-set! *current-session* snewid)
	      (php-warning "invalid session id. it must only contain a-z A-Z 0-9"))
	  oldid)))

; session_is_registered --  Find out whether a global variable is registered in a session
(defbuiltin (session_is_registered var)
   (php-warning "session_is_registered not supported: use $_SESSION instead")
   #f)

; session_module_name -- Get and/or set the current session module
(defbuiltin (session_module_name (newname 'unset))
   (if (eqv? newname 'unset)
       ;(get-ini-entry "session.save_handler")
       "files"
       (begin
	  (php-warning "'files' is the only session module available")
	  "files")))
	  ;(get-ini-entry "session.save_handler"))))

; session_name -- Get and/or set the current session name
(defbuiltin (session_name (newname 'unset))
   (if (eqv? newname 'unset)
       (session-name *current-session*)
       (let ((oldname (session-name *current-session*)))
	  ; XXX check value for validity?
	  ; no check done in zend
	  (session-name-set! *current-session* (mkstr newname))
	  oldname)))

; session_regenerate_id --  Update the current session id with a newly generated one
(defbuiltin (session_regenerate_id)
   (make-session-id)
   #t)

; session_register --  Register one or more global variables with the current session
(defbuiltin-v (session_register var1-n)
   (php-warning "session_register not supported: use $_SESSION instead")
   #f)

; session_save_path -- Get and/or set the current session save path
(defbuiltin (session_save_path (newpath 'unset))
   (if (eqv? newpath 'unset)
       (session-save-path *current-session*)
       (let ((oldpath (session-save-path *current-session*)))
	  ; XXX check value for validity?
	  ; no check done in zend
	  (session-save-path-set! *current-session* (mkstr newpath))
	  oldpath)))

; session_set_cookie_params --  Set the session cookie parameters
(defbuiltin (session_set_cookie_params lifetime (path 'unpassed) (domain 'unpassed) (secure 'unpassed))
   (session-cookie-lifetime-set! *current-session* (convert-to-integer lifetime))
   (unless (eqv? path 'unpassed)
      (session-cookie-path-set! *current-session* (mkstr path)))
   (unless (eqv? domain 'unpassed)
      (session-cookie-domain-set! *current-session* (mkstr domain)))
   (unless (eqv? secure 'unpassed)
      (session-cookie-secure-set! *current-session* (convert-to-boolean secure)))
   #t)
   
; session_set_save_handler --  Sets user-level session storage functions
(defbuiltin (session_set_save_handler open close read write destroy gc)
   (session-php-open-set! *current-session* (mkstr open))
   (session-php-close-set! *current-session* (mkstr close))
   (session-php-read-set! *current-session* (mkstr read))
   (session-php-write-set! *current-session* (mkstr write))
   (session-php-destroy-set! *current-session* (mkstr destroy))
   (session-php-gc-set! *current-session* (mkstr gc))
   #t)

; session_start -- Initialize session data
(defbuiltin (session_start)
   (unless (eqv? (session-status *current-session*) 'active)   
      (let ((send-cookie #t))
	 ; try cookies first
	 (if (convert-to-boolean (get-ini-entry "session.use_cookies"))
	     (let ((cookie-sid (if (php-hash? (container-value $_COOKIE))
				   (php-hash-lookup (container-value $_COOKIE)
						    (session-name *current-session*))
				   "")))
		(when (and (string? cookie-sid)
			   (verify-session-id cookie-sid))
		   (set! send-cookie #f)
		   (session-using-cookie-set! *current-session* #t) 
		   (set-session-id cookie-sid))))
	 ; try GET/POST next, if cookie didn't work
	 (if (and (eqv? (session-sid *current-session*) 'unset)
		  (not (convert-to-boolean (get-ini-entry "session.use_only_cookies"))))
	     (let ((req-sid (if (php-hash? (container-value $_REQUEST))
				(php-hash-lookup (container-value $_REQUEST)
						 (session-name *current-session*))
				"")))
		(when (and (string? req-sid)
			   (verify-session-id req-sid))
		   (set! send-cookie #f) 
		   (set-session-id req-sid))))
	 ; finally, make a new one if still not set
	 (if (eqv? (session-sid *current-session*) 'unset)
	     (make-session-id))
	 (debug-trace 2 (mkstr "opening session " (session-sid *current-session*)))
	 ; we are go for activity
	 (session-status-set! *current-session* 'active)
	 ; call opener
	 (if (session-php-open *current-session*)
	     ; php land
	     (php-funcall (session-php-open *current-session*)
			  (session-save-path *current-session*)
			  (session-name *current-session*))
	     ; in house
	     (*session-open-func*))
	 ; maybe send cookie
	 (when (and (convert-to-boolean (get-ini-entry "session.use_cookies"))
		    send-cookie)
	    (send-session-cookie))
	 ; session cache limiter
	 (session-cache-limit)
	 ; garbage collect?
	 (when (php-> (get-ini-entry "session.gc_probability") 0)
	    (let ((rnd (mt_rand 0 (get-ini-entry "session.gc_divisor"))))
	       (when (php-<= rnd (get-ini-entry "session.gc_probability"))
		  (if (session-php-gc *current-session*)
		      ; user land
		      (php-funcall (session-php-gc *current-session*)
				   (convert-to-number (get-ini-entry "session.gc_maxlifetime")))
		      ; in house
		      (let ((num-gcs (*session-gc-func*)))
			 (when (php-> num-gcs 0)
			    (debug-trace 2 (format "removed ~a expired sessions" num-gcs))))))))
	 ; attempt a load of current session
	 ; call opener
	 (if (session-php-read *current-session*)
	     ; user land
	     (php-funcall (session-php-read *current-session*)
			  (session-sid *current-session*))
	     ; in house
	     (*session-read-func*))	 
	 #t)))

; session_unregister --  Unregister a global variable from the current session
(defbuiltin (session_unregister var)
   (php-warning "session_unregister not supported: use $_SESSION instead")
   #f)

; session_unset --  Free all session variables
(defbuiltin (session_unset)
   ; clear _SESSION
   (container-value-set! $_SESSION (make-php-hash))
   #t)

; session_write_close -- Write session data and end session
(defbuiltin (session_write_close)
   ; will check for active session and save/close if necessary, then reset
   (php-session-reset))


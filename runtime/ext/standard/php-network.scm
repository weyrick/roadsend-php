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

(module php-network-lib
   (include "../phpoo-extension.sch")
   (include "php-streams.sch")
   (import (streams-c-bindings "streams-c-bindings.scm"))
   (import (php-streams-lib "php-streams.scm"))
   (library profiler)
   (export
    (init-php-network-lib)
    (checkdnsrr host type)
    (closelog)
    (define_syslog_variables)
    (fsockopen hostname port errno errstr timeout)
    (gethostbyaddr ip-address)
    (gethostbyname hostname)
    (gethostbynamel hostname)
    (getmxrr hostname mxhosts weight)
    (getprotobyname name)
    (getprotobynumber number)
    (getservbyname service protocol)
    (getservbyport port protocol)    
    (ip2long ip-address)
    (long2ip ip)
    (mail to subj msg headers params)
    (openlog identity option facility)
;    (pfsockopen hostname port errno errstr timeout)
    (syslog priority message)
    ;; openlog "options" constants
    LOG_CONS LOG_NDELAY LOG_ODELAY LOG_PERROR LOG_PID   
    ;; openlog "facilities" constants
    LOG_AUTH LOG_AUTHPRIV LOG_CRON LOG_DAEMON LOG_KERN    
    LOG_LPR LOG_MAIL LOG_NEWS LOG_SYSLOG LOG_USER    
    LOG_UUCP LOG_LOCAL0 LOG_LOCAL1 LOG_LOCAL2 LOG_LOCAL3  
    LOG_LOCAL4 LOG_LOCAL5 LOG_LOCAL6 LOG_LOCAL7
    ;; syslog "priorities" constants
    LOG_EMERG LOG_ALERT LOG_CRIT LOG_ERR LOG_WARNING
    LOG_NOTICE LOG_INFO LOG_DEBUG
    ))

;;;
;;; Module Init
;;; ===========

(define (init-php-network-lib)
   1)

(cond-expand
   (PCC_MINGW
    (define *winsock-initialized?* #f)

    (unless *winsock-initialized?*
       (if (zero? (init-winsock))
	   (php-warning "Unable to initialize winsock.  Network functions may not work right.")
	   (set! *winsock-initialized?* #t)))

    (register-exit-function!
     (lambda (status)
	(cleanup-winsock)
	status)))

   (else
    #t))

;;;
;;; Constants
;;; =========

(cond-expand
   ;; the syslog constants don't exist on MINGW, so define them to be
   ;; FALSE.
   (PCC_MINGW
    ;; openlog "options" constants
    (defconstant LOG_CONS FALSE)
    (defconstant LOG_NDELAY FALSE)
    (defconstant LOG_ODELAY FALSE)
    (defconstant LOG_PERROR FALSE)
    (defconstant LOG_PID FALSE)
    
    ;; openlog "facilities" constants
    (defconstant LOG_AUTH FALSE)
    (defconstant LOG_AUTHPRIV FALSE)
    (defconstant LOG_CRON FALSE)
    (defconstant LOG_DAEMON FALSE)
    (defconstant LOG_KERN FALSE)
    (defconstant LOG_LPR FALSE)
    (defconstant LOG_MAIL FALSE)
    (defconstant LOG_NEWS FALSE)
    (defconstant LOG_SYSLOG FALSE)
    (defconstant LOG_USER FALSE)
    (defconstant LOG_UUCP FALSE)
    (defconstant LOG_LOCAL0 FALSE)
    (defconstant LOG_LOCAL1 FALSE)
    (defconstant LOG_LOCAL2 FALSE)
    (defconstant LOG_LOCAL3 FALSE)
    (defconstant LOG_LOCAL4 FALSE)
    (defconstant LOG_LOCAL5 FALSE)
    (defconstant LOG_LOCAL6 FALSE)
    (defconstant LOG_LOCAL7 FALSE)
    
    ;; syslog "priorities" constants
    (defconstant LOG_EMERG FALSE)
    (defconstant LOG_ALERT FALSE)
    (defconstant LOG_CRIT FALSE)
    (defconstant LOG_ERR FALSE)
    (defconstant LOG_WARNING FALSE)
    (defconstant LOG_NOTICE FALSE)
    (defconstant LOG_INFO FALSE)
    (defconstant LOG_DEBUG FALSE))
   (else
    ;; openlog "options" constants
    (defconstant LOG_CONS (pragma::int "LOG_CONS"))
    (defconstant LOG_NDELAY (pragma::int "LOG_NDELAY"))
    (defconstant LOG_ODELAY (pragma::int "LOG_ODELAY"))
    (defconstant LOG_PERROR (pragma::int "LOG_PERROR"))
    (defconstant LOG_PID (pragma::int "LOG_PID"))
    
    ;; openlog "facilities" constants
    (defconstant LOG_AUTH (pragma::int "LOG_AUTH"))
    (defconstant LOG_AUTHPRIV (pragma::int "LOG_AUTHPRIV"))
    (defconstant LOG_CRON (pragma::int "LOG_CRON"))
    (defconstant LOG_DAEMON (pragma::int "LOG_DAEMON"))
    (defconstant LOG_KERN (pragma::int "LOG_KERN"))
    (defconstant LOG_LPR (pragma::int "LOG_LPR"))
    (defconstant LOG_MAIL (pragma::int "LOG_MAIL"))
    (defconstant LOG_NEWS (pragma::int "LOG_NEWS"))
    (defconstant LOG_SYSLOG (pragma::int "LOG_SYSLOG"))
    (defconstant LOG_USER (pragma::int "LOG_USER"))
    (defconstant LOG_UUCP (pragma::int "LOG_UUCP"))
    (defconstant LOG_LOCAL0 (pragma::int "LOG_LOCAL0"))
    (defconstant LOG_LOCAL1 (pragma::int "LOG_LOCAL1"))
    (defconstant LOG_LOCAL2 (pragma::int "LOG_LOCAL2"))
    (defconstant LOG_LOCAL3 (pragma::int "LOG_LOCAL3"))
    (defconstant LOG_LOCAL4 (pragma::int "LOG_LOCAL4"))
    (defconstant LOG_LOCAL5 (pragma::int "LOG_LOCAL5"))
    (defconstant LOG_LOCAL6 (pragma::int "LOG_LOCAL6"))
    (defconstant LOG_LOCAL7 (pragma::int "LOG_LOCAL7"))
    
    ;; syslog "priorities" constants
    (defconstant LOG_EMERG (pragma::int "LOG_EMERG"))
    (defconstant LOG_ALERT (pragma::int "LOG_ALERT"))
    (defconstant LOG_CRIT (pragma::int "LOG_CRIT"))
    (defconstant LOG_ERR (pragma::int "LOG_ERR"))
    (defconstant LOG_WARNING (pragma::int "LOG_WARNING"))
    (defconstant LOG_NOTICE (pragma::int "LOG_NOTICE"))
    (defconstant LOG_INFO (pragma::int "LOG_INFO"))
    (defconstant LOG_DEBUG (pragma::int "LOG_DEBUG"))))

; default sendmail path
(default-ini-entry "sendmail_path" "/usr/lib/sendmail -t -i")

;;;
;;; Resources
;;; =========

;;;
;;; Utility Functions
;;; =================

;; check if an optional parameter was provided
(define (passed? arg)
   (not (eqv? arg 'unpassed)))

;; check if an optional parameter was *not* provided
(define (unpassed? arg)
   (eqv? arg 'unpassed))

;;;
;;; Network Functions
;;; =================

;; checkdnsrr --  Check DNS records corresponding to a given Internet host name or IP address
(defbuiltin (checkdnsrr host (type "MX"))
   (let ((type (mkstr type)))
      (if (member type '("MX" "A" "NS" "PTR" "ANY" "SOA" "CNAME"))
	  (if (< 0 (php_checkdnsrr (mkstr host) type))
	      TRUE
	      FALSE)
	  (php-warning (format "invalid type: ~A" type)))))

   
;; closelog -- Close connection to system logger
(defbuiltin (closelog)
   (cond-expand
      (PCC_MINGW)
      (else
       (pragma::void "closelog()")))
   TRUE)

;; define_syslog_variables -- Initializes all syslog related constants
(defbuiltin (define_syslog_variables)
   ;; they do this to define all the constants in php namespace,
   ;; which we don't have to do, so we just return NULL
   NULL)

;; dns_check_record -- Synonym for checkdnsrr()
(defalias dns_check_record checkdnsrr)

;; dns_get_mx -- Synonym for getmxrr()
(defalias dns_get_mx getmxrr)

;; fsockopen --  Open Internet or Unix domain socket connection
(defbuiltin (fsockopen hostname port ((ref . errno) 'unpassed) ((ref . errstr) 'unpassed) (timeout 'unpassed))
    ;; XXX errstr, errno, and timeout don't work yet
    (let* ((hostname (string-downcase (mkstr hostname)))
	   (protocol/hostname (pregexp-split "://" hostname))
	   (protocol-given? (= (length protocol/hostname) 2))
	   (protocol (if protocol-given?
			 (case (string->symbol (car protocol/hostname))
			   ((tcp) net-SOCK_STREAM)
			   ((udp) net-SOCK_DGRAM)
			   (else  net-SOCK_STREAM))
			 net-SOCK_STREAM))
	   (hostname::string (if protocol-given?
				 (cadr protocol/hostname)
				 hostname))
	   (port::int (mkfixnum port))
	   (errno-buf (pragma::int "0"))
	   (errstr-buf::string "")
	   (type (if (zero? port) net-AF_UNIX net-AF_INET))
	   (sockfd (pragma::int "php_fsockopen($1, $2, $3, $4, &$5, &$6)"
				hostname port type protocol errno-buf errstr-buf)))
;       (fprint (current-error-port) "sockfd is : " sockfd)
;       (flush-output-port (current-error-port))
       (if (< sockfd 0)
	   (begin
	    (unless (eqv? 'unpassed errno)
	       (container-value-set! errno  errno-buf))
	    (unless (eqv? 'unpassed errstr)
	       (container-value-set! errstr errstr-buf))
	    FALSE)
	   (let ((s (socket-stream (mkstr hostname ":" port)
				   (cond-expand
				      (PCC_MINGW #f)
				      (else (net-fdopen sockfd "r+")))
				   #t #t sockfd)))
;(my-fdopen sockfd "r+") #t #t sockfd)))
;	      (set-stream-nonblocking! s)
              ;; It seems as if PHP's streams are blocking by default.
              ;; Try putting a print in tests/roadsend-socket.php to see
              ;; for yourself.  --timjr 2006.3.9
              (set-stream-blocking! s)
	      s))))
; 	  (let ((stream (socket-stream (mkstr hostname ":" port) (net-fdopen sockfd "r+") #t #t)))
; 	     (set-stream-nonblocking! stream)
; 	     (fprint (current-error-port) "stream is : " stream)
; 	     (flush-output-port (current-error-port))

; 	     stream))))

;; gethostbyaddr --  Get the Internet host name corresponding to a given IP address
(defbuiltin (gethostbyaddr ip-address)
   (cond-expand
      (PCC_MINGW TRUE)
      (else
       (let* ((ip-address (mkstr ip-address))
	      (size (pragma::int "sizeof(struct in_addr)"))
	      (pton-address (pragma::string "(char *)GC_malloc_atomic($1)" size))
	      (retval (net-inet_pton net-AF_INET ip-address pton-address)))
	  (if (> retval 0)
	      (let ((hostent (net-gethostbyaddr pton-address size net-AF_INET)))
		 (if (net-hostent-struct*-null? hostent)
		     ip-address
		     (net-hostent-struct*-h_name hostent)))
	      ip-address)))))

;; gethostbyname --  Get the IP address corresponding to a given Internet host name
(defbuiltin (gethostbyname hostname)
   (let* ((hostname (mkstr hostname))
	  (hostent (net-gethostbyname hostname)))
      (if (net-hostent-struct*-null? hostent)
	  hostname
	  (pragma::string "inet_ntoa(*((struct in_addr *)$1->h_addr))" hostent))))

;; gethostbynamel --  Get a list of IP addresses corresponding to a given Internet host name
(defbuiltin (gethostbynamel hostname)
   (let* ((hostname (mkstr hostname))
	  (hostent (net-gethostbyname hostname)))
      (if (net-hostent-struct*-null? hostent)
	  FALSE
	  (let loop ((index::int 0) (addrs '()))
	     (if (pragma::bool "$1->h_addr_list[$2] == 0" hostent index)
		 (list->php-hash (reverse addrs))
		 (loop (+ 1 index)
		       (cons (pragma::string "inet_ntoa(*((struct in_addr *)$1->h_addr_list[$2]))" hostent index)
			     addrs)))))))

; (defbuiltin (gethostbynamel hostname)
;    (let* ((hostname (mkstr hostname))
; 	  (hostent (net-gethostbyname hostname)))
;       (if (net-hostent-struct*-null? hostent)
; 	  FALSE
; 	  (let ((inaddr (net-inaddr-struct* 0)))
; 	     (let loop ((index 0) (addrs '()))
; 		(if (pragma::bool "$1->h_addr_list[$2] == 0" hostent index)
; 		    (list->php-hash (reverse addrs))
; 		    (begin (pragma "memcpy(($1), $2->h_addr_list[0], sizeof(struct in_addr))" inaddr hostent)
; 			   (loop (+ 1 index) (cons (pragma::string "inet_ntoa(*($1))" inaddr) addrs)))))))))


;; getmxrr --  Get MX records corresponding to a given Internet host name
(defbuiltin (getmxrr hostname (ref . mxhosts) ((ref . weight) 'unpassed))
   (let* ((hostname (mkstr hostname))
	  (mxlist (pragma::string "(char *)GC_malloc_atomic(sizeof(char) * MAXPACKET * 3)"))
	  (weightlist (pragma::string "(char *)GC_malloc_atomic(sizeof(char) * MAXPACKET * 3)"))
	  (retval (php_getmxrr hostname mxlist weightlist)))
      (if (zero? retval)
	  (begin
	     (container-value-set! mxhosts (list->php-hash (pregexp-split " +" mxlist)))
	     (container-value-set! weight  (list->php-hash (pregexp-split " +" weightlist)))
	     TRUE)
	  FALSE)))

;; getprotobyname --  Get protocol number associated with protocol name
(defbuiltin (getprotobyname name)
   (let ((proto (php_getprotobyname (mkstr name))))
      (if (< proto 0)
	  FALSE
	  proto)))

;; getprotobynumber --  Get protocol name associated with protocol number
(defbuiltin (getprotobynumber number)
   (let ((protoent (net-getprotobynumber (mkfixnum number))))
      (if (net-protoent-struct*-null? protoent)
	  FALSE
	  (net-protoent-struct*-p_name protoent))))

;; getservbyname --  Get port number associated with an Internet service and protocol
(defbuiltin (getservbyname service protocol)
   (let ((service (php_getservbyname (mkstr service) (mkstr protocol))))
      (if (< service 0)
	  FALSE
	  service)))

;; getservbyport --  Get Internet service which corresponds to port and protocol
(defbuiltin (getservbyport port protocol)
   (let ((servent (net-getservbyport (net-htons (mkfixnum port)) (mkstr protocol))))
      (if (net-servent-struct*-null? servent)
	  FALSE
	  (net-servent-struct*-s_name servent))))

;; ip2long --  Converts a string containing an (IPv4) Internet Protocol dotted address into a proper address.
(defbuiltin (ip2long ip-address)
;   (convert-to-integer (php_ip2long (mkstr ip-address)))
   (elong->onum (php_ip2long (mkstr ip-address))))

;; long2ip --  Converts an (IPv4) Internet network address into a string in Internet standard dotted format
(defbuiltin (long2ip ip)
   (let ((inaddr (net-inaddr-struct* (net-htonl (onum->elong (convert-to-number ip))))))
      (pragma::string "inet_ntoa(*($1))" inaddr)))

;; openlog -- Open connection to system logger
(defbuiltin (openlog identity option facility)
    (cond-expand
     (PCC_MINGW FALSE)
     (else
      (let ((identity::string (mkstr identity))
	    (option::int (mkfixnum option))
	    (facility::int (mkfixnum facility)))
	 (pragma::void "openlog($1, $2, $3)" identity option facility)
	 *one*))))

;; pfsockopen --  Open persistent Internet or Unix domain socket connection
; (defbuiltin (pfsockopen hostname port (errno 'unpassed) (errstr 'unpassed) (timeout 'unpassed))
;     1)

;; socket_get_status --  Alias of stream_get_meta_data().
;(defalias socket_get_status stream_get_meta_data)

;; socket_set_blocking -- Alias for stream_set_blocking()
;(defalias socket_set_blocking stream_set_blocking)

;; socket_set_timeout -- Alias for stream_set_timeout()
;(defalias socket_set_timeout stream_set_timeout)

; syslog -- Generate a system log message
(defbuiltin (syslog priority message)
    (cond-expand
     (PCC_MINGW FALSE)
     (else
      (let ((priority::int (mkfixnum priority))
	    (message::string (mkstr message)))
	 (pragma::void "syslog($1, $2)" priority message)
	 *one*))))

; mail
(defbuiltin (mail to subj msg (headers 'unpassed) (params 'unpassed))
   (let* ((body (mkstr "To:" to "\n"
		       "Subject: " subj "\n"
		       (if (passed? headers)
			   (mkstr headers "\n")
			   "")
		       "\n" msg "\n"))
	  (smcmd (pregexp-split " " (mkstr (get-ini-entry "sendmail_path"))))
	  (proc (apply run-process (append smcmd (list input: pipe:))))
	  (inport (process-input-port proc)))
      (fprint inport body)
      (flush-output-port inport)
      (close-output-port inport)
      (process-wait proc)
      (if (zero? (process-exit-status proc))
          TRUE
          FALSE)))


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

(module php-sockets-lib
   (include "../phpoo-extension.sch")
   (library profiler)
; not used
;   (import (sockets-c-bindings "c-bindings.scm"))
   (export
    (init-php-sockets-lib)
    ;
    AF_UNIX
    AF_INET
    AF_INET6
    SOCK_STREAM
    SOCK_DGRAM
    SOCK_RAW
    SOCK_SEQPACKET 
    SOCK_RDM
    MSG_OOB 
    MSG_WAITALL 
    MSG_PEEK 
    MSG_DONTROUTE 
    MSG_EOR 
    MSG_EOF 
    SO_DEBUG 
    SO_REUSEADDR 
    SO_KEEPALIVE 
    SO_DONTROUTE 
    SO_LINGER 
    SO_BROADCAST 
    SO_OOBINLINE 
    SO_SNDBUF 
    SO_RCVBUF 
    SO_SNDLOWAT 
    SO_RCVLOWAT
    SO_SNDTIMEO 
    SO_RCVTIMEO
    SO_TYPE 
    SO_ERROR
    PHP_NORMAL_READ
    PHP_BINARY_READ 
    SOL_TCP
    SOL_UDP
    SOL_SOCKET
    ;
    (socket_accept sock)    
    (socket_bind sock address port)
    (socket_clear_error sock)
    (socket_close sock)
    (socket_connect sock address cport)    
    (socket_create domain type protocol)
    (socket_getpeername sock address port)
    (socket_getsockname sock address port)
    (socket_last_error sock)
    (socket_listen sock backlog)
    (socket_read sock len readtype)
    (socket_shutdown sock how)
    (socket_strerror code)    
    (socket_write sock buffer len)
    ;
    ))

(define (init-php-sockets-lib) 1)

(defresource php-socket "Socket"
   bsocket
   connected?
   last-error-code
   last-error-str
   bind-addr
   bind-port)

(define *socket-counter* 0)
(define (make-finalized-socket)
   (when (> *socket-counter* 255) ; ARB
      (gc-force-finalization (lambda () (<= *socket-counter* 255))))
   (let ((new-sock (php-socket-resource #f #f 0 "" "" #f)))
      (set! *socket-counter* (+fx *socket-counter* 1))
      (register-finalizer! new-sock (lambda (sock)
				       (unless (socket-down? (php-socket-bsocket sock))
					  (socket-shutdown (php-socket-bsocket sock))
					  (set! *socket-counter* (- *socket-counter* 1)))))
      new-sock))

(define (proper-sock? sock)
   (and (php-socket? sock)
	(socket? (php-socket-bsocket sock))
	(not (socket-down? (php-socket-bsocket sock)))))

(define (proper-connected-sock? sock)
   (and (proper-sock? sock)
	(php-socket-connected? sock)))

(define (proper-server-sock? sock)
   (and (proper-sock? sock)
	(socket-server? (php-socket-bsocket sock))))

(define *last-socket-error* "")

; register the extension
(register-extension "sockets" "1.0.0" "php-sockets")

; socket_accept - Accepts a connection on a socket
(defbuiltin (socket_accept sock)
   (if (proper-server-sock? sock)
       (with-handler (lambda (e)
			; XXX no error codes? non 0 for now
			(php-socket-last-error-code-set! sock 1)
			(php-socket-last-error-str-set! sock (&io-error-msg e))
			(set! *last-socket-error* (&io-error-msg e))
			#f)
		     (let* ((new-bsocket (socket-accept (php-socket-bsocket sock)))
			    (new-php-socket (make-finalized-socket)))
			(php-socket-bsocket-set! new-php-socket new-bsocket)
			(php-socket-connected?-set! new-php-socket #t)
			new-php-socket))
       #f))
	  

; socket_bind - Binds a name to a socket
(defbuiltin (socket_bind sock address (port 'unset))
   (if (php-socket? sock)
       (begin
	  (php-socket-bind-addr-set! sock (mkstr address))
	  (php-socket-bind-port-set! sock (if (eqv? port 'unset) #f (mkfixnum port)))
	  #t)
       #f))       

; socket_clear_error - Clears the error on the socket or the last error code
(defbuiltin (socket_clear_error (sock 'unset))
   (if (php-socket? sock)
       (begin
	  (php-socket-last-error-str-set! sock "")
	  (php-socket-last-error-code-set! sock 0))
       (set! *last-socket-error* ""))
   #t)

; socket_close - Closes a socket resource
(defbuiltin (socket_close sock)
   (if (proper-connected-sock? sock)
       (begin
	  (socket-close (php-socket-bsocket sock))
	  (php-socket-connected?-set! sock #f)
	  #t)
       #f))

; socket_connect - Initiates a connection on a socket
(defbuiltin (socket_connect sock address cport)
   (if (php-socket? sock)
       (if (php-socket-connected? sock)
	   #f
	   (with-handler (lambda (e)
			    ; XXX no error codes? non 0 for now
			    (php-socket-last-error-code-set! sock 1)
			    (php-socket-last-error-str-set! sock (&io-error-msg e))
			    (set! *last-socket-error* (&io-error-msg e))			    
			    #f)
			 (begin
			    (cond-expand
			       (bigloo3.0c
				(php-socket-bsocket-set! sock (make-client-socket (mkstr address)
										  (mkfixnum cport)
										  :buffer #f)))
			       (else
				(php-socket-bsocket-set! sock (make-client-socket (mkstr address)
										  (mkfixnum cport)
										  :inbuf #f :outbuf #f))))
			    (php-socket-connected?-set! sock #t)
			    #t)))
       #f))

; socket_create_listen - Opens a socket on port to accept connections
; socket_create_pair - Creates a pair of indistinguishable sockets and stores them in an array

; socket_create - Create a socket (endpoint for communication)
(defbuiltin (socket_create domain type protocol)
   ;
   ; XXX bigloo only supports IP4, stream, and tcp
   ;
   (unless (and (php-= domain AF_INET)
		(php-= type SOCK_STREAM)
		(php-= protocol SOL_TCP))
      (set! *last-socket-error* "socket_create currently only supports AF_INET, SOCK_STREAM, SOL_TCP")
      #f)
   ; ok
   (make-finalized-socket))
   
; socket_get_option - Gets socket options for the socket

; socket_getpeername - Queries the remote side of the given socket which may either result in host/port or in a Unix filesystem path, dependent on its type
(defbuiltin (socket_getpeername sock (ref . address)  ((ref . port) #f))
   (if (proper-connected-sock? sock)
       (begin
	  (container-value-set! address (coerce-to-php-type
					 (socket-host-address
					  (php-socket-bsocket sock))))
	  (if (container? port)
	      (container-value-set! port (coerce-to-php-type
					 (socket-port-number
					  (php-socket-bsocket sock)))))
	  #t)
       #f))

; socket_getsockname - Queries the local side of the given socket which may either result in host/port or in a Unix filesystem path, dependent on its type
(defbuiltin (socket_getsockname sock (ref . address)  ((ref . port) #f))   
   (if (proper-connected-sock? sock)
       (begin
	  (container-value-set! address (coerce-to-php-type
					 (socket-local-address
					  (php-socket-bsocket sock))))
	  (if (container? port)
	      (container-value-set! port (coerce-to-php-type
					 (socket-port-number
					  (php-socket-bsocket sock)))))
	  #t)
       #f))

; socket_last_error - Returns the last error on the socket
(defbuiltin (socket_last_error (sock 'unset))
   (if (php-socket? sock)
       (php-socket-last-error-str sock)
       *last-socket-error*))
   
; socket_listen - Listens for a connection on a socket
(defbuiltin (socket_listen sock (backlog 'unset))
   (if (php-socket? sock)
       (if (php-socket-connected? sock)
	   #f
	   (with-handler (lambda (e)
			    ; XXX no error codes? non 0 for now
			    (php-socket-last-error-code-set! sock 1)
			    (php-socket-last-error-str-set! sock (&io-error-msg e))
			    (set! *last-socket-error* (&io-error-msg e))			    
			    #f)
			 (begin
			    (php-socket-bsocket-set! sock (make-server-socket (php-socket-bind-port sock) :buffer #f))
			    (php-socket-connected?-set! sock #t)
			    #t)))
       #f))

; socket_read - Reads a maximum of length bytes from a socket
(defbuiltin (socket_read sock len (readtype PHP_BINARY_READ))
   (if (proper-connected-sock? sock)
       (let* ((read-proc (cond ((php-= readtype PHP_NORMAL_READ) 'text)
			       ((php-= readtype PHP_BINARY_READ) 'binary)
			       (else 'binary)))
	      (read-len (maxfx 1 (mkfixnum len)))
	      (inbuf  (if (eqv? read-proc 'binary)
			  (read-chars read-len (socket-input (php-socket-bsocket sock)))
			  (read-line (socket-input (php-socket-bsocket sock))))))
	  (if (eof-object? inbuf)
	      ""
	      inbuf))
       #f))
	  
; socket_recv - Receives data from a connected socket
; socket_recvfrom - Receives data from a socket whether or not it is connection-oriented
; socket_select - Runs the select() system call on the given arrays of sockets with a specified timeout
; socket_send - Sends data to a connected socket
; socket_sendto - Sends a message to a socket, whether it is connected or not
; socket_set_block - Sets blocking mode on a socket resource
; socket_set_nonblock - Sets nonblocking mode for file descriptor fd
; socket_set_option - Sets socket options for the socket

; socket_shutdown - Shuts down a socket for receiving, sending, or both
(defbuiltin (socket_shutdown sock (how 'unset))
   (if (proper-connected-sock? sock)
       (begin
	  ;
	  ; XXX ignoring how
	  ;
	  (socket-shutdown (php-socket-bsocket sock))
	  (php-socket-connected?-set! sock #f)
	  #t)
       #f))

; socket_strerror - Return a string describing a socket error
(defbuiltin (socket_strerror code)
   ; XXX we don't have codes, just pass through now.
   ; last_error returns the string
   code)

; socket_write - Write to a socket
(defbuiltin (socket_write sock buffer (len 'unset))
   (if (proper-connected-sock? sock)
       (let* ((buf (mkstr buffer))
	      (buf-size (if (eqv? len 'unset)
			    (string-length buf)
			    (minfx (string-length buf) (mkfixnum len))))
	      (real-buf (if (<fx buf-size (string-length buf))
			    (substring buf 0 buf-size)
			    buf)))
	  (display real-buf (socket-output (php-socket-bsocket sock)))
	  (flush-output-port (socket-output (php-socket-bsocket sock)))
	  ; XXX we're assuming they were all written
	  buf-size
	  )
       #f))

(defconstant AF_UNIX  0)
(defconstant AF_INET  1)
(defconstant AF_INET6 2)

(defconstant SOCK_STREAM 0)
(defconstant SOCK_DGRAM 1)
(defconstant SOCK_RAW 2)
(defconstant SOCK_SEQPACKET 3)
(defconstant SOCK_RDM 4)

(defconstant MSG_OOB 0)
(defconstant MSG_WAITALL 1)
(defconstant MSG_PEEK 2)
(defconstant MSG_DONTROUTE 3)
(defconstant MSG_EOR 4)
(defconstant MSG_EOF 5)

(defconstant SO_DEBUG 0)
(defconstant SO_REUSEADDR 1)
(defconstant SO_KEEPALIVE 2)
(defconstant SO_DONTROUTE 3)
(defconstant SO_LINGER 4)
(defconstant SO_BROADCAST 5)
(defconstant SO_OOBINLINE 6)
(defconstant SO_SNDBUF 7)
(defconstant SO_RCVBUF 8)
(defconstant SO_SNDLOWAT 9)
(defconstant SO_RCVLOWAT 10)
(defconstant SO_SNDTIMEO 11)
(defconstant SO_RCVTIMEO 12)
(defconstant SO_TYPE 13) 
(defconstant SO_ERROR 14)
   
(defconstant PHP_NORMAL_READ 0)
(defconstant PHP_BINARY_READ 1)
   
(defconstant SOL_TCP 0)
(defconstant SOL_UDP 1)
(defconstant SOL_SOCKET 2)


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

(module php-streams-lib
   (include "../phpoo-extension.sch")
   (include "php-streams.sch")
   (import (streams-c-bindings "streams-c-bindings.scm"))
   (library profiler)
   (export
    (init-php-streams-lib)

    *stream-resource-counter*
    
    STREAM_NOTIFY_SEVERITY_ERR
    STREAM_NOTIFY_SEVERITY_WARN
    STREAM_NOTIFY_SEVERITY_INFO
    STREAM_NOTIFY_AUTH_RESULT
    STREAM_NOTIFY_FAILURE
    STREAM_NOTIFY_PROGRESS
    STREAM_NOTIFY_REDIRECTED
    STREAM_NOTIFY_FILE_SIZE_IS
    STREAM_NOTIFY_MIME_TYPE_IS
    STREAM_NOTIFY_AUTH_REQUIRED
    STREAM_NOTIFY_CONNECT
    STREAM_REPORT_ERRORS
    STREAM_USE_PATH
    
    ;;; streams functions
    (stream_context_create options)
    (stream_context_get_options stream-or-context)
    (stream_context_set_option stream-or-context wrapper option value)
    (stream_context_set_params stream-or-context params)
    ;     (stream_filter_append stream filtername read/write params)
    ;     (stream_filter_prepend stream filtername read/write params)
    (stream_get_meta_data stream)
    ;     (stream_register_wrapper protocol classname)
    (stream_select read write except sec usec)
    (stream_set_blocking stream mode)
    (stream_set_timeout stream sec usec)
    ;     (stream_set_write_buffer stream buffer-size)
    
    ;;; utility functions
    (php-stream-fd::int strm)
    (port->file port)
    (file->fd file-ptr)
    (port->fd port)
    (set-stream-nonblocking! stream)
    (set-stream-blocking! stream)
    (stream-close! stream)
    (local-stream? stream)
    (remote-stream? stream)
    (readable-stream? stream)
    (writeable-stream? stream)
    (local-file-stream name file-ptr readable? writeable?)
    (local-file-stream? stream)
    (remote-file-stream name in-port out-port readable? writeable?)
    (remote-file-stream? stream)
    (process-stream name file-ptr readable? writeable?)
    (process-stream? stream)
    (socket-stream name file-ptr readable? writeable? sockfd)
    (socket-stream? stream)))

;;;
;;; Module Init
;;; ===========

(define (init-php-streams-lib)
   1)

;;;
;;; Constants
;;; =========

(defconstant STREAM_USE_PATH 1)
(defconstant STREAM_REPORT_ERRORS 8)
(defconstant STREAM_NOTIFY_CONNECT 2)
(defconstant STREAM_NOTIFY_AUTH_REQUIRED 3)
(defconstant STREAM_NOTIFY_MIME_TYPE_IS 4)
(defconstant STREAM_NOTIFY_FILE_SIZE_IS 5)
(defconstant STREAM_NOTIFY_REDIRECTED 6)
(defconstant STREAM_NOTIFY_PROGRESS 7)
(defconstant STREAM_NOTIFY_FAILURE 9)
(defconstant STREAM_NOTIFY_AUTH_RESULT 10)
(defconstant STREAM_NOTIFY_SEVERITY_INFO 0)
(defconstant STREAM_NOTIFY_SEVERITY_WARN 1)
(defconstant STREAM_NOTIFY_SEVERITY_ERR 2)

(define (php-stream-fd::int strm)
   (if (eqv? 'socket (stream-type strm))
       (stream-context strm)
       (let ((fd (file->fd (stream-file-ptr strm))))
	  (if fd
	      fd
	      (error 'php-stream-fd "invalid file descriptor for stream" strm)))))
;;;
;;; Resources
;;; =========

;;
;; stream resource defined in php-streams.sch to allow easy sharing between modules
;;

(defresource context
   "stream context"
   options
   params)

;;;
;;; Utility Functions
;;; =================

(define (set-fd-nonblocking! fd)
   (cond-expand
      (PCC_MINGW
       #t)
      (else
       (and fd
	    (fcntl2 fd F_SETFL (pragma::long "($1 | O_NONBLOCK)" (fcntl1 fd F_GETFL)))
	    #t))))

(define (set-fd-blocking! fd)
   (cond-expand
      (PCC_MINGW
       #t)
      (else
       (and (number? fd)
	    (fcntl2 fd F_SETFL (pragma::long "($1 & ~O_NONBLOCK)" (fcntl1 fd F_GETFL)))
	    #t))))

(define (set-sock-nonblocking! fd::int)
   (cond-expand
      (PCC_MINGW
       (let ((iomode (pragma::int "1")))
	  (let ((retval (pragma::int "ioctlsocket($1, FIONBIO, (long *)&$2)" fd iomode)))
	     (cons iomode 'keepme)
	     (if (zero? retval)
		 #t
		 (begin
		    (php-warning "Couldn't set socket to non-blocking mode, error " 
				 (pragma::int "WSAGetLastError()"))
		    #f)))))
       (else
	(set-fd-nonblocking! fd))))

(define (set-sock-blocking! fd::int)
   (cond-expand
      (PCC_MINGW
       (let ((iomode (pragma::int "0")))
	  (let ((retval (pragma::int "ioctlsocket($1, FIONBIO, (long *)&$2)" fd iomode)))
	     (cons iomode 'keepme)
	     (if (zero? retval)
		 #t
		 (begin
		    (php-warning "Couldn't set socket to blocking mode, error " 
				 (pragma::int "WSAGetLastError()"))
		    #f)))))
       (else
	(set-fd-blocking! fd))))

(define (port->file port)
   ;; XXX this is so massively not safe
   (cond ((input-port? port)
	  (pragma::FILE* "PORT( $1 ).stream" port))
	 ((output-port? port)
	  (pragma::FILE* "PORT( $1 ).stream" port))
	 (else #f)))

(define (file->fd file-ptr)
;this is segfaulting on mingw, it seems, for example in the fsockopen test
;   (fprint (current-error-port) "file-ptr is: " file-ptr)
   (flush-output-port (current-error-port))
   (and file-ptr (fileno file-ptr)))
;   #f)

(define (port->fd port)
   (file->fd (port->file port)))

(define (set-stream-nonblocking! stream)
   (case (stream-type stream)
     ((socket) 
      (set-sock-nonblocking! (stream-context stream))   )
     (else
      (set-fd-nonblocking! (file->fd (stream-file-ptr stream)))
      (set-fd-nonblocking! (port->fd (stream-in-port stream)))
      (set-fd-nonblocking! (port->fd (stream-out-port stream)))))
   (stream-blocking?-set! stream #f))

(define (set-stream-blocking! stream)
   (case (stream-type stream)
     ((socket) 
      (set-sock-blocking! (stream-context stream)))
     (else
      (set-fd-blocking! (file->fd (stream-file-ptr stream)))
      (set-fd-blocking! (port->fd (stream-in-port stream)))
      (set-fd-blocking! (port->fd (stream-out-port stream)))))
   (stream-blocking?-set! stream #t))

(define (stream-close! stream)
   ;; NOTE: C file pointers and descriptors should be closed by the caller as needed
   ;; because processes, for example, must be closed differently than ordinary files
   (when (input-port? (stream-in-port stream))
      (close-input-port (stream-in-port stream)))
   (when (output-port? (stream-out-port stream))
      (close-output-port (stream-out-port stream)))
   (stream-file-ptr-set!   stream #f)
   (stream-in-port-set!    stream #f)
   (stream-out-port-set!   stream #f)
   (stream-readable?-set!  stream #f)
   (stream-writeable?-set! stream #f)
   #t)

(define (local-stream? stream)
   (and (stream? stream)
	(member (stream-type stream) '(local-file process))))

(define (remote-stream? stream)
   (and (stream? stream)
	(member (stream-type stream) '(remote-file socket))))

(define (readable-stream? stream)
   (and (stream? stream)
	(stream-readable? stream)))

(define (writeable-stream? stream)
   (and (stream? stream)
	(stream-writeable? stream)))

(define *std-operations*
   (make-stream-operations
    "Standard Stream"
    #f
    #f
    #f
    #f
    php-stream-fd))

(define *stream-resource-counter* 0)
(define (make-finalized-stream . rest)
   (let ((stream (apply stream-resource rest)))
      ;; when the stream counter exceeds an arbitrary limit, force the
      ;; finalizers to run.  This might be a pretty low limit, on
      ;; today's systems.
      (when (> *stream-resource-counter* 255)
         (gc-force-finalization (lambda () (<= *stream-resource-counter* 255))))
      ;; XXX fixme fclose doesn't close process streams, so we don't
      ;; increment the stream counter when we allocate one either.
      ;; This is a bad kludge, looking in the arglist like this.
      (unless (eqv? (cadr rest) 'process)
         ;; we expect fclose to decrement the stream counter. 
         (set! *stream-resource-counter* (+ *stream-resource-counter* 1)))
      (register-finalizer! stream
                           (lambda (s)
                              #t
                              ;(set! *stream-resource-counter* (- *stream-resource-counter* 1))
                              ;(fprint (current-error-port) "finalizing a stream")
                              (php-funcall 'fclose s)
                              ))
      stream))

(define (local-file-stream name file-ptr readable? writeable?)
   (make-finalized-stream name
                          'local-file
                          file-ptr
                          #f
                          #f
                          readable?
                          writeable?
                          0 0
                          #t
                          #f
                          ;extended ops
                          *std-operations*))

(define (local-file-stream? stream)
   (and (stream? stream)
	(eqv? (stream-type stream) 'local-file)))

(define (remote-file-stream name in-port out-port readable? writeable?)
   (make-finalized-stream name
                          'remote-file
                          #f
                          in-port
                          out-port
                          readable?
                          writeable?
                          0 0
                          #t
                          #f
                          ;extended ops
                          *std-operations*))

(define (remote-file-stream? stream)
   (and (stream? stream)
	(eqv? (stream-type stream) 'remote-file)))

(define (process-stream name file-ptr readable? writeable?)
   (make-finalized-stream name
                          'process
                          file-ptr
                          #f
                          #f
                          readable?
                          writeable?
                          0 0
                          #t
                          #f
                          ;extended ops
                          *std-operations*))

(define (process-stream? stream)
   (and (stream? stream)
	(eqv? (stream-type stream) 'process)))
   
(define (socket-stream name file-ptr readable? writeable? sockfd)
   (make-finalized-stream name
                          'socket
                          file-ptr
                          #f
                          #f
                          readable?
                          writeable?
                          0 0
                          #t
                          sockfd
                          ;extended ops
                          #f))

(define (socket-stream? stream)
   (and (stream? stream)
	(eqv? (stream-type stream) 'socket)))


;;;
;;; Wrappers
;;; ========

; (define *registered-wrappers* (make-hashtable))

; (define (lookup-wrapper name)
;    (hashtable-get *registered-wrappers* name))

; (define (register-wrapper wrapper)
;    (and (wrapper? wrapper)
; 	(hashtable-put! *registered-wrappers* (wrapper-name wrapper) wrapper)))
				    
;;;
;;; Streams Functions
;;; =================

;; stream_context_create -- Create a streams context
(defbuiltin (stream_context_create options)
   (if (php-hash? options)
       (context-resource options #f)
       FALSE))

;; stream_context_get_options -- Retrieve options for a stream/wrapper/context
(defbuiltin (stream_context_get_options obj)
   (let ((context (cond ((stream? obj) (or (stream-context obj)
					   (begin (stream-context-set! obj (context-resource (make-php-hash)
											     (make-php-hash)))
						  (stream-context obj))))
 			((context? obj) obj)
 			(else #f))))
      (if context
  	  (or (context-options context) FALSE)
  	  (make-php-hash))))

;; stream_context_set_option -- Sets an option for a stream/wrapper/context
(defbuiltin (stream_context_set_option obj wrapper option value)
   (let ((options-hash (cond ((stream? obj) (or (and-let* ((context (stream-context obj))) (context-options context))
						(begin (stream-context-set! obj (context-resource (make-php-hash)
												  (make-php-hash)))
						       (context-options (stream-context obj)))))
			((context? obj) (context-options obj))
			(else #f)))
	 (wrapper-name (mkstr wrapper)))
      (if options-hash
 	  (let ((wrapper-hash (let ((val (php-hash-lookup options-hash wrapper-name)))
				 (if (convert-to-boolean val)
				     (container-value val)
				     (let ((new-hash (make-php-hash)))
					(php-hash-insert! options-hash wrapper-name new-hash)
					new-hash)))))
	     (php-hash-insert! wrapper-hash option value)
	     TRUE)
 	  FALSE)))

;; stream_context_set_params -- Set parameters for a stream/wrapper/context
(defbuiltin (stream_context_set_params stream-or-context params)
   ;; Only accepted param, according to the documentation, is "notification" -
   ;; the value of which should be a function to be called whenever a stream
   ;; triggers a notification. Streams notification has not yet been
   ;; implemented.
   ;; XXX this is a waste of time.
   FALSE)

;; stream_copy_to_stream -- Copies data from one stream to another
;;; NOTE: CVS only

;; stream_filter_append -- Attach a filter to a stream.
(defbuiltin (stream_filter_append stream filtername read/write params)
   FALSE)

;; stream_filter_prepend -- Attach a filter to a stream.
(defbuiltin (stream_filter_prepend stream filtername read/write params)
   FALSE)

;; stream_get_filters -- Retrieve list of registered filters
;;; NOTE: CVS only

;; stream_get_line -- Gets line from stream resource up to a given delimiter
;;; NOTE: CVS only

;; stream_get_meta_data -- Retrieves header/meta data from streams/file pointers
(defbuiltin (stream_get_meta_data stream)
   FALSE)

;; stream_get_transports -- Retrieve list of registered socket transports
;;; NOTE: CVS only

;; stream_get_wrappers -- Retrieve list of registered streams
;;; NOTE: CVS only

;; stream_register_filter -- Register a stream filter implemented as a PHP class derived from php_user_filter
;;; NOTE: CVS only

;; stream_register_wrapper -- Register a URL wrapper implemented as a PHP class
(defbuiltin (stream_register_wrapper protocol classname)
   FALSE)

(define (make-fdset)
   (let ((the-fd-set (pragma::fd_set* "(fd_set *)GC_malloc_atomic(sizeof(fd_set))")))
      (fd_zero! the-fd-set)
      the-fd-set))

(define (fdset-set-fd! fdset fd)
   (fd_set! fdset fd)
   #t)

(define (fdset-fd-set? fdset fd)
   (if (zero? (fd_isset? fd fdset))
       #f
       #t))

;; stream_select -- Runs the equivalent of the select() system call on the given arrays of streams with a timeout specified by tv_sec and tv_usec 
(defbuiltin (stream_select (ref . read) (ref . write) (ref . except) sec (usec 0))
   FALSE)
;    (let ((maxfd 0)
; 	 (read-fdset (make-fdset))
; 	 (write-fdset (make-fdset))
; 	 (except-fdset (make-fdset))
; 	 (timeout (pfl-struct-timeval* (onum->elong (convert-to-number sec))
; 				       (onum->elong (convert-to-number usec))))
; 	 (fd-stream-map (make-hashtable))
; 	 (read-rethash (make-php-hash))
; 	 (write-rethash (make-php-hash))
; 	 (except-rethash (make-php-hash))
; 	 (read-cval (container-value read))
; 	 (write-cval (container-value write))
; 	 (except-cval (container-value except)))
;       (when (php-hash? read-cval)
; 	 (php-hash-for-each read-cval (lambda (k v)
; 					 (and-let* ((fd (when (readable-stream? v)
; 							   (case (stream-type v)
; 							      ((local-file socket process)
; 							       (file->fd (stream-file-ptr v)))
; 							      ((remote-file)
; 							       (port->fd (stream-in-port v)))))))
; 						   (fdset-set-fd! read-fdset fd)
; 						   (hashtable-put! fd-stream-map fd v)
; 						   (when (< maxfd fd) (set! maxfd fd))))))
;       (when (php-hash? write-cval)
; 	 (php-hash-for-each write-cval (lambda (k v)
; 					  (and-let* ((fd (when (writeable-stream? v)
; 							    (case (stream-type v)
; 							       ((local-file socket process)
; 								(file->fd (stream-file-ptr v)))
; 							       ((remote-file)
; 								(port->fd (stream-out-port v)))))))
; 						    (fdset-set-fd! write-fdset fd)
; 						    (hashtable-put! fd-stream-map fd v)
; 						    (when (< maxfd fd) (set! maxfd fd))))))
;       (when (php-hash? except-cval)
; 	 (php-hash-for-each except-cval (lambda (k v)
; 					   (when (stream? v)
; 					      (case (stream-type v)
; 						 ((local-file socket process)
; 						  (and-let* ((fd (file->fd (stream-file-ptr v))))
; 							    (fdset-set-fd! except-fdset fd)
; 							    (hashtable-put! fd-stream-map fd v)
; 							    (when (< maxfd fd) (set! maxfd fd))))
; 						 ((remote-file)
; 						  (and-let* ((fd (port->fd (stream-in-port v))))
; 							    (fdset-set-fd! except-fdset fd)
; 							    (hashtable-put! fd-stream-map fd v)
; 							    (when (< maxfd fd) (set! maxfd fd)))
; 						  (and-let* ((fd (port->fd (stream-out-port v))))
; 							    (fdset-set-fd! except-fdset fd)
; 							    (hashtable-put! fd-stream-map fd v)
; 							    (when (< maxfd fd) (set! maxfd fd)))))))))
;       (let ((retval (c-select (+ maxfd 1) read-fdset write-fdset except-fdset timeout)))
; 	 (when (> retval 0) ; when more than 0 fds got set
; 	    (let ((read-hash-index 0) (write-hash-index 0) (except-hash-index 0))
; 	       (hashtable-for-each fd-stream-map
; 				   (lambda (fd stream)
; 				      (when (fdset-fd-set? fd read-fdset)
; 					 (php-hash-insert! read-rethash read-hash-index stream)
; 					 (set! read-hash-index (+ 1 read-hash-index)))
; 				      (when (fdset-fd-set? fd write-fdset)
; 					 (php-hash-insert! write-rethash write-hash-index stream)
; 					 (set! write-hash-index (+ 1 write-hash-index)))
; 				      (when (fdset-fd-set? fd except-fdset)
; 					 (php-hash-insert! except-rethash except-hash-index stream)
; 					 (set! except-hash-index (+ 1 except-hash-index)))))))
; 	 (container-value-set! read read-rethash)
; 	 (container-value-set! write write-rethash)
; 	 (container-value-set! except except-rethash)
; 	 (if (< retval 0)
; 	     FALSE
; 	     retval))))
	 
;; stream_set_blocking -- Set blocking/non-blocking mode on a stream
(defbuiltin (stream_set_blocking stream mode)
   (if (stream? stream)
       (begin (if (convert-to-boolean mode)
		  (set-stream-blocking! stream)
		  (set-stream-nonblocking! stream))
	      TRUE)
       FALSE))

;; stream_set_timeout -- Set timeout period on a stream
(defbuiltin (stream_set_timeout stream sec (usec 0))
   (if (stream? stream)
       (begin (stream-timeout-sec-set! stream (mkfixnum sec))
	      (stream-timeout-usec-set! stream (mkfixnum usec))
	      TRUE)
	FALSE))

;; stream_set_write_buffer -- Sets file buffering on the given stream
(defbuiltin (stream_set_write_buffer stream buffer-size)
   FALSE)

;; stream_socket_accept --  Accept a connection on a socket created by stream_socket_server()
;;; NOTE: CVS only

;; stream_socket_client --  Open Internet or Unix domain socket connection
;;; NOTE: CVS only

;; stream_socket_get_name -- Retrieve the name of the local or remote sockets
;;; NOTE: CVS only

;; stream_socket_server --  Create an Internet or Unix domain server socket 
;;; NOTE: CVS only

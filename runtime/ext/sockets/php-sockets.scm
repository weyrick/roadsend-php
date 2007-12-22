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
   (import (sockets-c-bindings "c-bindings.scm"))
   (export
    (init-php-sockets-lib)
    ;
    (socket_close sock)
    (socket_create domain type protocol)
    ;
    ))

(define (init-php-sockets-lib) 1)

; register the extension
(register-extension "sockets" "1.0.0" "php-socket")

; socket_accept - Accepts a connection on a socket
; socket_bind - Binds a name to a socket
; socket_clear_error - Clears the error on the socket or the last error code
; socket_close - Closes a socket resource
(defbuiltin (socket_close sock)
   (echo "in socket_close"))

; socket_connect - Initiates a connection on a socket
; socket_create_listen - Opens a socket on port to accept connections
; socket_create_pair - Creates a pair of indistinguishable sockets and stores them in an array
; socket_create - Create a socket (endpoint for communication)
(defbuiltin (socket_create domain type protocol)
   (echo "in socket_create"))

; socket_get_option - Gets socket options for the socket
; socket_getpeername - Queries the remote side of the given socket which may either result in host/port or in a Unix filesystem path, dependent on its type
; socket_getsockname - Queries the local side of the given socket which may either result in host/port or in a Unix filesystem path, dependent on its type
; socket_last_error - Returns the last error on the socket
; socket_listen - Listens for a connection on a socket
; socket_read - Reads a maximum of length bytes from a socket
; socket_recv - Receives data from a connected socket
; socket_recvfrom - Receives data from a socket whether or not it is connection-oriented
; socket_select - Runs the select() system call on the given arrays of sockets with a specified timeout
; socket_send - Sends data to a connected socket
; socket_sendto - Sends a message to a socket, whether it is connected or not
; socket_set_block - Sets blocking mode on a socket resource
; socket_set_nonblock - Sets nonblocking mode for file descriptor fd
; socket_set_option - Sets socket options for the socket
; socket_shutdown - Shuts down a socket for receiving, sending, or both
; socket_strerror - Return a string describing a socket error
; socket_write - Write to a socket


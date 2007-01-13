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

(module curl-c-bindings
   (extern
    (include "curl-headers.h")
    (include "curl/curl.h")
    (type timeval
	  (struct (sec::elong "tv_sec")
		  (usec::elong "tv_usec"))
	  "struct timeval"))
;   (library common)
   (export
    (select n::int readfds::fd-set writefds::fd-set exceptfds::fd-set timeout::timeval*)
    (make-timeval::timeval*)))


(define (select n::int readfds::fd-set writefds::fd-set exceptfds::fd-set timeout::timeval*)
   (pragma::int "select($1, $2, $3, $4, $5)" n readfds writefds exceptfds timeout))
;     ;    (type fd_set* (opaque) "fd_set *")
;     (macro select::int (n::int
; 			readfds::fd-set
; 			writefds::fd-set
; 			exceptfds::fd-set
; 			timeout::timeval*)
; 	   "select")) )


(define (make-timeval::timeval*)
   (pragma::timeval* "GC_MALLOC_ATOMIC(sizeof(struct timeval))"))

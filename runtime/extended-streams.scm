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
(module extended-streams
   (load (php-macros "../php-macros.scm"))
   ;weird, but will do for now
   (include "ext/standard/php-streams.sch")
   (import (php-resources "resources.scm"))
   (export
    (register-stream-wrapper protocol wrapper)
    (lookup-stream-wrapper protocol)
    (extended-stream? stream)
    (make-extended-stream name::bstring readable? writeable? operations context)
    (make-stream-wrapper name open-fun close-fun stat-fun url-stat-fun dir-open-fun context url? errors)
    (make-stream-operations name write read close flush #!optional get-fd-fun)
    (stream-wrapper-open-fun stream-wrapper)
    (stream-operations-read stream-ops)
    (extended-stream-read stream read-length)
    (extended-stream-get-fd stream))
    
   (static
    
    (class %stream-wrapper
       ;name of the wrapper
       name
       ;open a stream
       open-fun
       ;close a stream
       close-fun
       ;stat a stream
       stat-fun
       ;stat a url
       url-stat-fun
       ;open a dir stream (??)
       dir-open-fun
       ;any context that the wrapper needs
       context
       ;is this a url, for the ini entry allow_url_fopen
       url?
       ;list of errors, so there can be more than one
       errors)

    (class %stream-operations
       name

       write
       read
       close
       flush

       ;optional
       (seek (default #f))
       (cast (default #f))
       (stat (default #f))
       (set-option (default #f))
       ;function to get the file descriptor, currently used by curl to
       ;get the fd for standard streams.
       (get-fd (default #f)))
    ))


(define *stream-wrappers* (make-hashtable))

(define (register-stream-wrapper protocol wrapper)
   (hashtable-put! *stream-wrappers* protocol wrapper))

(define (lookup-stream-wrapper protocol)
   (hashtable-get *stream-wrappers* protocol))


(define (extended-stream? stream)
   (and (stream? stream)
	(eqv? (stream-type stream) 'extended)))

(define (make-extended-stream name::bstring readable? writeable? operations context)
   (stream-resource name
		    'extended
		    #f
		    ;in-port
		    #f
		    ;out-port
		    #f
		    readable?
		    writeable?
		    0 0
		    #t
		    context
		    operations))

(define (extended-stream-read stream read-length)
   ((stream-operations-read (stream-extended-ops stream))
    (stream-context stream)
    read-length))

(define (extended-stream-get-fd stream)
   (let ((get-fd (and (stream? stream) (%stream-operations-get-fd (stream-extended-ops stream)))))
      (if get-fd
          (get-fd stream)
          #f)))

(define (make-stream-wrapper name open-fun close-fun stat-fun url-stat-fun dir-open-fun context url? errors)
   (make-%stream-wrapper name open-fun close-fun stat-fun url-stat-fun dir-open-fun context url? errors))

(define (make-stream-operations name write read close flush #!optional get-fd-fun)
   (make-%stream-operations name write read close flush #f #f #f #f get-fd-fun))

(define (stream-wrapper-open-fun stream-wrapper)
   (%stream-wrapper-open-fun stream-wrapper))


(define (stream-operations-read stream-ops)
   (%stream-operations-read stream-ops))



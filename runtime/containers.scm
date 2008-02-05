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
(module rt-containers
   (export
    (inline make-container::pair value)
    (inline container->reference!::pair value)
    (inline container-reference?::bbool value)
    (inline container-value container::pair)
    (inline container?::bbool container)
    (inline container-value-set! container::pair value)
    (inline maybe-unbox thupet)
    (inline maybe-box thupet)))

;;;;containers
;; we use 1 for regular containers and 3 for reference containers
;; because (bit-or 1 2) is 3 and (bit-or 3 2) is 3, so it's easy
;; to check what's a container.
(define-inline (make-container::pair value)
   (cons value 1))

(define-inline (container->reference!::pair value)
   (set-cdr! value 3)
   value)

(define-inline (container-reference?::bbool value)
   (=fx 3 (cdr value)))

(define-inline (container-value-set! container::pair value)
   (set-car! container value))

(define-inline (container-value container::pair)
   (car container))

(define-inline (container?::bbool container)
   (and (pair? container)
	;	(not (null? (cdr container))) ; XXX why does this happen?? weyrick 10/15/04
	;;
	;; because container? could be applied to anything, and some things,
	;; e.g. lists of length one, will have null in the cdr, which is a type error
	;; for bit-or.  But not for fixnum? !  So let's just use fixnum?. --tpd 10/19/04
	(fixnum? (cdr container))))
;	(= 3 (bit-or (cdr container) 2))))
;	(eqv? (cdr container) 'container)))

(define-inline (maybe-unbox thupet)
   (let ((retval
	  (if (container? thupet)
	      (container-value thupet)
	      thupet)))
      [assert (retval) (not (container? retval))]
;;       (when (container? retval)
;; 	 (error 'maybe-unbox "Invariant lost: container found inside a container" thupet))
      retval))

(define-inline (maybe-box thupet)
   (if (container? thupet)
       thupet
       (make-container thupet)))




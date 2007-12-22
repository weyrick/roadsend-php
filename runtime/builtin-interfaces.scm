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
;;;; PHP error signalling and handling
(module builtin-interfaces
   (include "php-runtime.sch")
   (import (php-runtime "php-runtime.scm")
	   (php-object "php-object.scm")
           (php-hash "php-hash.scm"))
   (load (php-macros "../php-macros.scm"))
   (export
    (init-builtin-interfaces)))

; called at start and on page resets
(define (init-builtin-interfaces)
   ; always have to rebuild, because object system resets
   (build-Traversable-class)
   (build-Iterator-class)
   (build-IteratorAggregate-class)
   (build-Serializable-class)
   (build-ArrayAccess-class)
   )

(define (build-Traversable-class)
   (define-php-class 'Traversable '() '() '(interface abstract))
)

(define (build-Iterator-class)
   (define-php-class 'Iterator '(Traversable) '() '(interface abstract))
   (define-php-method 'Iterator "rewind" '(public abstract) 'abstract-no-proc)
   (define-php-method 'Iterator "current" '(public abstract) 'abstract-no-proc)
   (define-php-method 'Iterator "key" '(public abstract) 'abstract-no-proc)
   (define-php-method 'Iterator "next" '(public abstract) 'abstract-no-proc)   
   (define-php-method 'Iterator "valid" '(public abstract) 'abstract-no-proc)
   )

(define (build-IteratorAggregate-class)
   (define-php-class 'IteratorAggregate '() '() '(interface abstract))
   (define-php-method 'IteratorAggregate "getIterator" '(public abstract) 'abstract-no-proc)
   )

(define (build-ArrayAccess-class)
   (define-php-class 'ArrayAccess '() '() '(interface abstract))
   (define-php-method 'ArrayAccess "offsetExists" '(public abstract) 'abstract-no-proc)
   (define-php-method 'ArrayAccess "offsetGet" '(public abstract) 'abstract-no-proc)
   (define-php-method 'ArrayAccess "offsetSet" '(public abstract) 'abstract-no-proc)
   (define-php-method 'ArrayAccess "offsetUnset" '(public abstract) 'abstract-no-proc)   
)


(define (build-Serializable-class)
   (define-php-class 'Serializable '() '() '(interface abstract))
   (define-php-method 'Serializable "serialize" '(public abstract) 'abstract-no-proc)
   (define-php-method 'Serializable "unserialize" '(public abstract) 'abstract-no-proc)
)

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
(module builtin-classes
   (include "php-runtime.sch")
   (import (php-runtime "php-runtime.scm")
	   (php-object "php-object.scm")
           (php-hash "php-hash.scm"))
   (load (php-macros "../php-macros.scm"))
   (export
    (init-builtin-classes)))

; called at start and on page resets
(define (init-builtin-classes)
   ; always have to rebuild, because object system resets
   (build-Exception-class)
   (build-Traversable-class)
   (build-Iterator-class)
   (build-IteratorAggregate-class)
   (build-Serializable-class)
   (build-ArrayAccess-class)
   )

; Exception base class
; XXX this is incomplete
(define (build-Exception-class)
   (define-builtin-php-class 'Exception '() '() '())
   (define-php-property 'Exception "message" "Unknown exception" 'protected #f)
   (define-php-property 'Exception "code" *zero* 'protected #f)
   (define-php-method 'Exception "__construct" '(public) Exception:__construct)
   (define-php-method 'Exception "getMessage" '(public) Exception:getMessage))

(define (Exception:__construct this-unboxed . optional-args)
   (let ((message '())
	 (code '()))
      (when (pair? optional-args)
	 (set! message
	       (maybe-unbox (car optional-args)))
	 (set! optional-args (cdr optional-args)))
      (when (pair? optional-args)
	 (set! code
	       (maybe-unbox (car optional-args)))
	 (set! optional-args (cdr optional-args)))
      (when message
	 (php-object-property-set!/string this-unboxed "message" message 'all))
      (when code
	 (php-object-property-set!/string this-unboxed "code" code 'all))))

(define (Exception:getMessage this-unboxed . optional-args)
   (make-container (php-object-property-h-j-f-r/string this-unboxed "message" 'all)))


;;;;;;;;;;;;

(define (build-Traversable-class)
   (define-builtin-php-class 'Traversable '() '() '(interface abstract))
)

(define (build-Iterator-class)
   (define-builtin-php-class 'Iterator '(Traversable) '() '(interface abstract))
   (define-php-method 'Iterator "rewind" '(public abstract) 'abstract-no-proc)
   (define-php-method 'Iterator "current" '(public abstract) 'abstract-no-proc)
   (define-php-method 'Iterator "key" '(public abstract) 'abstract-no-proc)
   (define-php-method 'Iterator "next" '(public abstract) 'abstract-no-proc)   
   (define-php-method 'Iterator "valid" '(public abstract) 'abstract-no-proc)
   )

(define (build-IteratorAggregate-class)
   (define-builtin-php-class 'IteratorAggregate '(Traversable) '() '(interface abstract))
   (define-php-method 'IteratorAggregate "getIterator" '(public abstract) 'abstract-no-proc)
   )

(define (build-ArrayAccess-class)
   (define-builtin-php-class 'ArrayAccess '() '() '(interface abstract))
   (define-php-method 'ArrayAccess "offsetExists" '(public abstract) 'abstract-no-proc)
   (define-php-method 'ArrayAccess "offsetGet" '(public abstract) 'abstract-no-proc)
   (define-php-method 'ArrayAccess "offsetSet" '(public abstract) 'abstract-no-proc)
   (define-php-method 'ArrayAccess "offsetUnset" '(public abstract) 'abstract-no-proc)   
)


(define (build-Serializable-class)
   (define-builtin-php-class 'Serializable '() '() '(interface abstract))
   (define-php-method 'Serializable "serialize" '(public abstract) 'abstract-no-proc)
   (define-php-method 'Serializable "unserialize" '(public abstract) 'abstract-no-proc)
)

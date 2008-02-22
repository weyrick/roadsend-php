;; ***** BEGIN LICENSE BLOCK *****
;; Roadsend PHP Compiler Runtime Libraries
;; Copyright (C) 2008 Roadsend, Inc.
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

(module php-skeleton-lib
   ; required
   (include "../phpoo-extension.sch")
   (library profiler)
   ; import any required modules here, e.g. c bindings
   (import
    (skeleton-c-bindings "c-bindings.scm"))
   ;
   ; list of exports. should include all defbuiltin and defconstant
   ;
   (export
    (init-php-skeleton-lib)
    ;
    SKELETON_CONST
    ;
    (skel_hello_world var1)
    (skel_hash str int)
    ;
    ))

;
; this procedure needs to exist, but it need not
; do much (normally just returns 1). note that ALL
; top level code will run upon initialization
;
(define (init-php-skeleton-lib) 1)

; register the extension. required. note: version is not checked anywhere right now
(register-extension "skeleton extension" ; extension title, shown in e.g. phpinfo()
		    "1.0.0"              ; version
		    "skeleton")          ; library name. make sure this matches LIBNAME in Makefile

;
; this is how you can define a PHP resource. these are
; opaque objects in PHP, like a socket or database connection
; defresource is mostly a wrapper for define-struct.
; "Sample Resource" is the string this object coerces to
; in php land, if you try to print it
;
;(defresource php-skel-resource "Sample Resource"
;   field1
;   field2)

;
; if you use resources, you should use some code like that below
; which handles resource finalization. see the mysql extension,
; for example
;

; (define *resource-counter* 0)
; (define (make-finalized-resource)
;    (when (> *resource-counter* 255) ; an arbitrary constant which may be a php.ini entry
;       (gc-force-finalization (lambda () (<= *resource-counter* 255))))
;    (let ((new-resource (php-skel-resource 1 2)))
;       (set! *resource-counter* (+fx *resource-counter* 1))
;       (register-finalizer! new-resource (lambda (res)
; 					   ; some theoretical procedure that closes the resource properly
; 					   (resource-cleanup res)
; 					   (set! *resource-counter* (- *resource-counter* 1)))))
;       new-resource)


;
; defbuiltin creates a builtin php function
;

; take one parameter, echo it with a worldly greeting
(defbuiltin (skel_hello_world var1)
   (echo (mkstr "hello world" var1)))

; take two parameters and return a hash with two entries,
; one for each parameter. we'll force str to be a string,
; and int to be a number
(defbuiltin (skel_hash str int)
   (let ((result (make-php-hash)))
      (php-hash-insert! result :next (mkstr str))
      (php-hash-insert! result :next (convert-to-number str))
      result))

;
; defconstant creates a builtin constant
;
(defconstant SKELETON_CONST  0)


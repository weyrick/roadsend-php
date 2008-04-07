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

(module re-c-interface
   (include "php-runtime.sch")
   (library php-runtime)
   (export
    (re-make-php-hash::struct)
    (re-php-hash-insert::bool ::struct ::string ::string))
   (extern
    (export re-make-php-hash "re_make_php_hash")
    (export re-php-hash-insert "re_php_hash_insert")
    ))


(define (re-make-php-hash::struct)
   (make-php-hash))

(define (re-php-hash-insert::bool hash::struct key::string value::string)
   (if (php-hash? hash)
       (php-hash-insert! hash key value)
       (php-warning "CFI: invalid hash object")))

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
(module web-var-cache
   (import
    (php-hash "php-hash.scm")
    (php-types "php-types.scm"))
   (export
    ;
    (store-persistent-var name::bstring value #!optional ttl)
    (persistent-var-exists?::bbool name::bstring)
    (remove-persistent-var name::bstring)
    (fetch-persistent-var name::bstring)    
    (reset-persistent-vars!)
    (get-persistent-var-stats)    
    ))

;;;; variables that persist between requests (for web backends)

(define *persistent-var-table* (make-hashtable))

(define (store-persistent-var name::bstring value #!optional ttl)
   ;; XXX do something with ttl
   (hashtable-put! *persistent-var-table* name value))

(define (remove-persistent-var name::bstring)
   (hashtable-remove! *persistent-var-table* name))

(define (fetch-persistent-var name::bstring)
   (hashtable-get *persistent-var-table* name))

(define (persistent-var-exists?::bbool name::bstring)
   (hashtable-contains? *persistent-var-table* name))

(define (reset-persistent-vars!)
   (set! *persistent-var-table* (make-hashtable)))   

(define (get-persistent-var-stats)
   (let ((h (make-php-hash)))
      (php-hash-insert! h "size" (convert-to-number
				  (hashtable-size *persistent-var-table*)))
      h))


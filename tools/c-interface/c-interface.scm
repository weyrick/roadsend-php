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
   (library phpeval)
   (library profiler)
   (library webconnect)
   (export
    ; init
    (re-runtime-init::obj)
    ; debug
    (re-var-dump::obj var::obj)
    ; strings
    (re-string::obj ::string)
    (re-is-string::bool ::obj)
    ; numbers
    (re-float::obj ::double)
    (re-int::obj ::long)
    (re-is-number::bool ::obj)
    (re-is-float::bool ::obj)
    (re-is-int::bool ::obj)    
    ; hash
    (re-make-php-hash::struct)
    (re-php-hash-insert-cstr::bool ::struct ::string ::string)
    (re-php-hash-insert::bool ::struct ::obj ::obj)
    (re-is-php-hash::bool ::obj)
    ; funcall
    (re-funcall::obj ::string ::obj)
    (re-list-1::obj ::obj)
    (re-list-2::obj ::obj ::obj)
    (re-list-3::obj ::obj ::obj ::obj)
    )
   (extern
    ; init
    (export re-runtime-init "re_runtime_init")
    ; debug
    (export re-var-dump "re_var_dump")
    ; strings
    (export re-string "re_string")
    (export re-is-string "re_is_string")
    ; numbers
    (export re-float "re_float")
    (export re-int "re_int")
    (export re-is-number "re_is_number")
    (export re-is-float "re_is_float")
    (export re-is-int "re_is_int")
    ; hash
    (export re-make-php-hash "re_make_php_hash")
    (export re-php-hash-insert-cstr "re_php_hash_insert_cstr")
    (export re-php-hash-insert "re_php_hash_insert")
    (export re-is-php-hash "re_is_php_hash")
    ; funcall
    (export re-funcall "re_funcall")
    (export re-list-1 "re_list_1")
    (export re-list-2 "re_list_2")
    (export re-list-3 "re_list_3")    
    ))


(define (re-runtime-init::obj)
   (setup-library-paths)
   (load-runtime-libs '(php-std))
;   (init-php-argv ?)
   (run-startup-functions))


;;;;;;;;;;;;;
;; DEBUG
;;;;;;;;;;;;;
(define (re-var-dump::obj var::obj)
   (php-funcall 'var_dump var))

;;;;;;;;;;;;;
;; STRINGS
;;;;;;;;;;;;;
(define (re-is-string::bool var::obj)
   (string? var))

(define (re-string::obj str::string)
   ($string->bstring str))

;;;;;;;;;;;;;
;; NUMBERS
;;;;;;;;;;;;;
(define (re-float::obj n::double)
   (float->onum n))

(define (re-int::obj n::long)
   (elong->onum n))

(define (re-is-number::bool var::obj)
   (onum? var))

(define (re-is-float::bool var::obj)
   (and (onum? var) (onum-float? var)))

(define (re-is-int::bool var::obj)
   (and (onum? var) (onum-long? var)))

;;;;;;;;;;;;;
;; PHP-HASH
;;;;;;;;;;;;;
(define (re-make-php-hash::struct)
   (make-php-hash))

(define (re-php-hash-insert::bool hash::struct key::obj value::obj)
   (if (php-hash? hash)
       (php-hash-insert! hash key value)
       (php-warning "CFI: invalid hash object")))

(define (re-php-hash-insert-cstr::bool hash::struct key::string value::string)
   (if (php-hash? hash)
       (php-hash-insert! hash ($string->bstring key) ($string->bstring value))
       (php-warning "CFI: invalid hash object")))

(define (re-is-php-hash::bool var::obj)
   (php-hash? var))

;;;;;;;;;;;
;; FUNCALL
;;;;;;;;;;;
(define (re-funcall::obj fun-name::string args::obj)
   (if (pair? args)
       (apply php-funcall (cons ($string->bstring fun-name) args))
       (php-warning "CFI: invalid argument structure (want pair)")))

(define (re-list-1::obj item1::obj)
   (list item1))

(define (re-list-2::obj item1::obj item2::obj)
   (list item1 item2))

(define (re-list-3::obj item1::obj item2::obj item3::obj)
   (list item1 item2 item3))


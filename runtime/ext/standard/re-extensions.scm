; ***** BEGIN LICENSE BLOCK *****
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
(module re-extension-lib
   (include "../phpoo-extension.sch")
   (library profiler)
   ; exports
   (export
    (init-re-extension-lib)
    (re_get_loaded_libs)    
    (re_copy thing)
    (re_register_extension php-ext-name ext-lib-name version depends-on)
    ))

;
; NOTE: the goal is to keep these to a minimum. this should only, only functions
; that hook into roadsend specific functionality
;
(define (init-re-extension-lib) 1)

; get a list of PHP libs loaded from pcc.conf
(defbuiltin (re_get_loaded_libs)
   (list->php-hash *user-libs*))			 

;explicitly copy
(defbuiltin (re_copy thing)
   (copy-php-data thing))

;a way for pcc PHP extensions to register
(defbuiltin (re_register_extension php-ext-name ext-lib-name version (depends-on #f))
   "PCC only function to register a PHP extension.
    Used for Roadsend PHP extensions written in PHP and compiled to libraries, e.g. PDO"
   (register-extension (mkstr php-ext-name)
		       (mkstr version)
		       (mkstr ext-lib-name)
		       required-extensions: (if (php-hash? depends-on)
						(php-hash->list depends-on)
						'())))

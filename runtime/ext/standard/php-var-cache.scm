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

(module php-var-cache-lib
   (include "../phpoo-extension.sch")
   (library profiler)
   ; exports
   (export
    (init-php-var-cache-lib)
    (re_store_var key val ttl)
    (re_fetch_var key)
    (re_remove_var key)
    (re_clear_var_cache)
    ))

(define (init-php-var-cache-lib)
   1)
   
;; php land interface
(defbuiltin (re_store_var key val (ttl 'unpassed))
   ; XXX ttl
   (store-persistent-var (mkstr key) val)
   TRUE)

(defbuiltin (re_fetch_var key)
   (fetch-persistent-var (mkstr key)))

(defbuiltin (re_remove_var key)
   (remove-persistent-var (mkstr key)))

(defbuiltin (re_clear_var_cache)
   (reset-persistent-vars!)
   TRUE)

(defbuiltin (re_var_cache_info)
   (get-persistent-var-stats))


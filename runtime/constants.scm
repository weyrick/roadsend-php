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
(module constants
   (export
    (reset-constants!)
    (constant-defined? name::string)
    (lookup-constant name::string)
    (lookup-constant/smash name::pair)
    (store-constant name::string value case-insensitive?)
    (store-persistent-constant name::string value)
    (store-special-constant name::string value)
    (constants-for-each k)
    (php-constant? value)
    *PHP-LINE*
    *PHP-FILE*))

;;;; constants

;;these are "superconstants".  They actually change value, so they are
;;associated with a function for getting the current value.
(define *special-constants* (make-hashtable))

(define *PHP-LINE* 0)
(define *PHP-FILE* "unknown")

; magical constants
(store-special-constant "__FILE__" (lambda () *PHP-FILE*))
(store-special-constant "__LINE__" (lambda () *PHP-LINE*))

; these are defined in php-errors, where the stack tracing happens
;(store-special-constant "__CLASS__" (lambda () ""))
;(store-special-constant "__METHOD__" (lambda () ""))
;(store-special-constant "__FUNCTION__" (lambda () ""))

; store a magical "dynamic constant"
(define (store-special-constant name::string value)
   (hashtable-put! *special-constants* name value))

(define %constant-not-defined% (cons '() '()))

;;these are user-defined constants (from the define() function)
(define *constant-table* (make-hashtable))

;;these are system-defined constants made using DEFCONSTANT  It's
;;called persistent because they are not removed from the table
;;between requests.
(define *persistent-constant-table* (make-hashtable))

(define (reset-constants!)
   (set! *constant-table* (make-hashtable)))

(define (constant-defined? name::string)
   (if (eq? (%get-constant name) %constant-not-defined%)
       #f
       #t))

(define (lookup-constant name::string)
   ;;XXX looks like special constants can't return false!
   (let ((c (%get-constant name)))
      (if (eq? c %constant-not-defined%)
	  ;;XXX perhaps there should be an "undefined constant" warning here
	  name
          c)))


;; this is lookup-constant, except it also stores the %constant
;; structure into the cdr of the pair that gets passed in.
;; We're playing fast and loose with literal scheme constants as well
;; as constant redefinition in php here, so expect bugs.  But it's a
;; first shot.
(define (lookup-constant/smash name::pair)
   (if (null? (cdr name))
       ;; no previous looked cached
       (let ((c (%get-constant-itself (car name))))
	  (if (%constant? c)
	      (begin
		 (set-cdr! name c)
		 (%constant-value c))
	      ;; we don't cache a failed lookup
	      (if (eq? c %constant-not-defined%)
		  ;; it's undefined, so return the name 
		  (car name)
                  ;; it's not a constant, and it's not undefined, so it
		  ;; must be a special-constant
		  c)))
       (%constant-value (cdr name))))


(define (store-constant name::string value case-insensitive?)
   ;;store a plain user constant
   ;;does not override existing constants
   (%put-constant name value case-insensitive? #f #f))

(define (store-persistent-constant name::string value)
   ;;store a constant that won't be discarded on page reload
   ;;overrides existing constants
   (%put-constant name value #f #t #t))


(define (constants-for-each k)
   ;;call k once for each constant, persistent ones first,
   ;;excluding the special constants
   (hashtable-for-each *persistent-constant-table* (lambda (key val) (k key (%constant-value val))))
   (hashtable-for-each *constant-table* (lambda (key val) (k key (%constant-value val)))))

(define-struct %constant
   name
   value
   case-insensitive?)

(define (php-constant? val)
   ;; analagous to php-hash? php-object? etc
   (%constant? val))

(define (%put-constant name value case-insensitive? persistent? force?)
   ;;only define the constant if it's being defined for the first time,
   ;;or FORCE? is true
   
   ;; PHP 4.3.7 allows for an uppercase
   ;; case-sensitive constant to coexist with
   ;; a case insensitive one of the same name,
   ;; hence we use string-downcase.
   (when case-insensitive? (set! name (string-downcase name)))
   (if (or force?
	   ;;%get-constant will find it if there's already a case-insensitive
	   ;;constant and we're defining a case-sensitive one, so we do the lookup
	   ;;ourselves
	   (not (or (hashtable-get *special-constants* name)
		    (hashtable-get *persistent-constant-table* name)
		    (hashtable-get *constant-table* name))))
       (begin
	  (hashtable-put! (if persistent?
			   *persistent-constant-table*
			   *constant-table*)
		       name
		       (%constant name value case-insensitive?))
	  #t)
       #f))


(define (%get-constant name)
   (let ((the-constant (%get-constant-itself name)))
      (if (eq? the-constant %constant-not-defined%)
          %constant-not-defined%
	  (if (%constant? the-constant)
	      (%constant-value the-constant)
	      ;; special constant
	      the-constant))))
	

(define (%get-constant-itself name)
   (let* ((special-constant-function (hashtable-get *special-constants* name)))
      (if special-constant-function
	  ;;the special constants aren't constant at all.  instead we call
	  ;;their function to get their current value.
	  (special-constant-function) 
	  ;;normal constants are first looked up case-insensitively
	  (let* ((lname (string-downcase name))
		 (the-constant (or (hashtable-get *persistent-constant-table* name)
				   (hashtable-get *persistent-constant-table* lname)
				   ;;lookup the case-sensitive constant first
				   (hashtable-get *constant-table* name)
				   ;;now lookup the case-insensitive version
				   (hashtable-get *constant-table* lname))))
	     (if the-constant
		 (if (%constant-case-insensitive? the-constant)
		     the-constant
		     ;;if the constant is case-sensitive, make sure we've got the right case
		     (if (string=? name (%constant-name the-constant))
			 the-constant
			 %constant-not-defined%))
		 %constant-not-defined%)))))

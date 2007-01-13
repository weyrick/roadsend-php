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
(module php-gtk-signals
   (load (php-macros "../../../php-macros.scm"))
   (load (php-gtk-macros "php-gtk-macros.sch"))
;   (library "common")
   (import (gtk-binding "cigloo/gtk.scm")
	   (gtk-signals "cigloo/signals.scm"))
   (library php-runtime)
   (import (php-gtk-common-lib "php-gtk-common.scm")
	    )
   (export
    (init-php-gtk-signals)
    (phpgtk-callback-closure function data pass-object?)
    ))

(define (init-php-gtk-signals)
   1)


;   ((disconnect :c-name gtk_signal_disconnect) (handler_id :gtk-type guint))



;   ((connect :return-type guint :c-name gtk_signal_connect) (name :gtk-type const-gchar*) (func :gtk-type GtkSignalFunc) (func_data :gtk-type gpointer))
(defmethod gtkobject (connect signal funcname #!rest data)
   (connect-impl (maybe-unbox $this)
		 (maybe-unbox signal)
		 (maybe-unbox funcname)
		 (map maybe-unbox data)
		 #f))

;(defmethod-XXX gtkobject (connect_after) TRUE)
;   ((connect_after :return-type guint :c-name gtk_signal_connect_after) (name :gtk-type const-gchar*) (func :gtk-type GtkSignalFunc) (func_data :gtk-type gpointer))
(defmethod gtkobject (connect_after signal funcname #!rest data)
   (connect-impl (maybe-unbox $this)
		 (maybe-unbox signal)
		 (maybe-unbox funcname)
		 (map maybe-unbox data)
		 #t))

;   ((connect_object :return-type guint :c-name gtk_signal_connect_object) (name :gtk-type const-gchar*) (func :gtk-type GtkSignalFunc) (slot_object :gtk-type GtkObject*))
(defmethod gtkobject (connect_object signal function #!rest data)
   (connect-object-impl (maybe-unbox $this)
			(maybe-unbox signal)
			(maybe-unbox function)
			(map maybe-unbox data)
			#f))


;   ((connect_object_after :return-type guint :c-name gtk_signal_connect_object_after) (name :gtk-type const-gchar*) (func :gtk-type GtkSignalFunc) (slot_object :gtk-type GtkObject*))
(defmethod gtkobject (connect_object_after signal function #!rest data)
   (connect-object-impl (maybe-unbox $this)
			(maybe-unbox signal)
			(maybe-unbox function)
			(map maybe-unbox data)
			#t))

(define (connect-impl $this signal function data after?)
   (debug-trace 3 "file " *PHP-FILE* " line " *PHP-LINE* " connecting an non-object, the function is " (mkstr function) " php-hash? says " (php-hash? function))
   (let ((signal (mkstr signal)))
      (gtk-signal-connect (GTK_OBJECT (gtk-object $this))
			  signal
			  (phpgtk-callback-closure function data #t)
; 			  (if (php-hash? funcname)
; 			      ;; erm... okay, so this really needs to be factored out, get outfitted with appropriate errors, etc.
; 			      ;; plus, I could put it in a separate file, instead of here in the monster.
; 			      (let* ((object-and-method (php-hash->list funcname))
; 				     (object (car object-and-method))
; 				     (method-name (mkstr (cadr object-and-method))))
; 				 (if (null? data)
; 				     (lambda args
; 					(debug-trace 3 "connect-impl, funcname is array, data is null, args:" args " signal: " signal)
; 					(apply call-php-method object method-name (map convert-to-php-type args)))
; 				     (lambda args
; 					(debug-trace 3 "connect-impl, funcname is array, data is not null, args:" args " signal: " signal
; 						     ", and the initialization says: " (hashtable? (php-object-custom-properties (car data))))
; 					(apply call-php-method object method-name (append (map convert-to-php-type args) data)))))
; 			      (if (null? data)
; 				  (lambda args
; 				     (debug-trace 3 "connect-impl, data is null, args:" args " signal: " signal)
; 				     (apply php-funcall (mkstr funcname) (map convert-to-php-type args)))
; 				  (lambda args
; 				     (debug-trace 3 "connect-impl, data is not null, args:" args " signal: " signal
; 						  ", and the initialization says: " (hashtable? (php-object-custom-properties (car data))))
; 				     (apply php-funcall (mkstr funcname) (append (map convert-to-php-type args) data)))))
			  after?)
      TRUE))


(define (connect-object-impl $this signal function data after?)
   (let ((signal (mkstr signal)))
      (debug-trace 3 "file " *PHP-FILE* " line " *PHP-LINE* " connecting an object, the function is " (mkstr function) " php-hash? says " (php-hash? function))
      (gtk-signal-connect (GTK_OBJECT (gtk-object $this))
			  signal
			  (phpgtk-callback-closure function data #f)
; 			  (if (php-hash? function)
; 			      (let* ((object-and-method (php-hash->list function))
; 				     (object (car object-and-method))
; 				     (method-name (mkstr (cadr object-and-method))))
; 				 (if (php-object? object)
; 				     (lambda args
; 					(debug-trace 3 "connect-object-impl A" args)
; 					(apply call-php-method object method-name data))
; 				     ;XXX wtf? mkstr object!?
; 				     (let ((object (mkstr object)))
; 					(lambda args
; 					   (debug-trace 3 "connect-object-impl B" args)
; 					   (apply call-static-php-method object method-name data)))))
; 			      (let ((function (mkstr function)))
; 				 (if (null? data)
; 				     (lambda args
; 					(debug-trace 3 "connect-object-impl C" args)
; 					(php-funcall function (map convert-to-php-type args)))
; 				     (lambda args
; 					(debug-trace 3 "connect-object-impl D" args)
; 					(apply php-funcall function data)))))
			  after?)
      TRUE))

(define-macro (my-try form handler)
   `(if (getenv "BIGLOOSTACKDEPTH")
	,form
       (try ,form ,handler)))

;; it looks like the utility of pass-object? is to suppress passing
;; the object.  The php-gtk marshaller (php_gtk_callback_marshal)
;; passes the object if it gets one, unless pass-object? is specified
;; and false.  If it doesn't get an object, it doesn't pass it,
;; regardless of what pass-object? is set to.
(define (phpgtk-callback-closure function data pass-object?)
   (let ((connected-line *PHP-LINE*)
	 (connected-file *PHP-FILE*))
      ;; we've basically got three copies of the same code below, in a
      ;; fit of premature optimization.
      (if (php-hash? function)
	  (let ((object (php-hash-lookup function 0))
		(method (mkstr (php-hash-lookup function 1))))
	     (if (php-object? object)
		 ;; the callback is a regular method call
		 (lambda (obj . rest)
		    (debug-trace 2 "calling method " method " arguments " obj ", " rest ", data: " data )
		    (my-try (apply call-php-method object method
				(append (map convert-to-php-type
					     (if (and obj pass-object?)
						 (cons obj rest)
						 rest))
					data))
			 (lambda (e p m o)
			    (php-warning "Unable to call callback " (php-object-class object) "->" method "() specified in "
					 connected-file " on line " connected-line ": " m)
			    (e FALSE))))
		 ;; the callback is a static method call
		 (lambda (obj . rest)
		    (my-try (apply call-static-php-method (mkstr object) NULL method
				(append (map convert-to-php-type
					     (if (and obj pass-object?)
						 (cons obj rest)
						 rest))
					data))
			 (lambda (e p m o)
			    (php-warning "Unable to call callback " (php-object-class object) "::" method "() specified in "
					 connected-file " on line " connected-line ": " m)
			    (e FALSE))))))
	  ;; the callback is a regular function call
	  (let ((function (mkstr function)))
	     (lambda (obj . rest)
		(my-try (apply php-funcall function
			    (append (map convert-to-php-type
					 (if (and obj pass-object?)
					     (cons obj rest)
					     rest))
				    data))
		     (lambda (e p m o)
			(php-warning "Unable to call callback " function "() specified in "
				     connected-file " on line " connected-line ": " m)
			(e FALSE))))))))

			   
; 			   (if pass-object?
; 			       (
; 				(lambda args
; 				   (let ((args (if pass-object? args (cdr args))))
; 				      (try
; 				       (if (php-object? object)
; 					   (apply call-php-method object method
; 						  (append (map convert-to-php-type args)
; 							  data))
; 					   (apply call-static-php-method (mkstr object) method
; 						  (append (map convert-to-php-type args)
; 							  data)))
;  				       (lambda (e p m o)
;  					  (php-warning "Unable to call callback " (php-object-class object) "->" method "() specified in "
;  						       connected-file " on line " connected-line ": " m)
;  					  (e FALSE))))))
; 			       (let ((function (mkstr function)))
; 				  (lambda args
; 				     (let ((args (if pass-object? args (cdr args))))
; 					(try
; 					 (apply php-funcall function 
; 						(append (map convert-to-php-type args) data))
; 					 (lambda (e p m o)
; 					    (php-warning "Unable to call callback " function "() specified in "
; 							 connected-file " on line " connected-line ": " m)
; 					    (e FALSE)))))))))

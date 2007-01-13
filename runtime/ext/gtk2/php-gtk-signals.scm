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
   (library "php-runtime")
   (import (php-gtk-common-lib "php-gtk-common.scm")
	    )
   (export
    (init-php-gtk-signals)
    (phpgtk-callback-closure function data pass-object? simple?)
    ))

(define (init-php-gtk-signals)
   1)


;   ((disconnect :c-name gtk_signal_disconnect) (handler_id :gtk-type guint))


;; /* }}} */
;; /* {{{ GObject::connect */
;; static PHP_METHOD(GObject, connect)
;; {
;; 	phpg_signal_connect_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, PHPG_CONNECT_NORMAL, FALSE);
;; }
;; /* }}} */
;; /* {{{ GObject::connect_after */
;; static PHP_METHOD(GObject, connect_after)
;; {
;; 	phpg_signal_connect_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, PHPG_CONNECT_NORMAL, TRUE);
;; }
;; /* }}} */
;; /* {{{ GObject::connect_simple */
;; static PHP_METHOD(GObject, connect_simple)
;; {
;; 	phpg_signal_connect_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, PHPG_CONNECT_SIMPLE, FALSE);
;; }
;; /* }}} */
;; /* {{{ GObject::connect_simple_after */
;; static PHP_METHOD(GObject, connect_simple_after)
;; {
;; 	phpg_signal_connect_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, PHPG_CONNECT_SIMPLE, TRUE);
;; }
;; /* }}} */
;; /* {{{ GObject::connect_object */
;; static PHP_METHOD(GObject, connect_object)
;; {
;;     phpg_warn_deprecated("use connect() or connect_simple()" TSRMLS_CC);
;; 	phpg_signal_connect_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, PHPG_CONNECT_OBJECT, FALSE);
;; }
;; /* }}} */
;; /* {{{ GObject::connect_object_after */
;; static PHP_METHOD(GObject, connect_object_after)
;; {
;;     phpg_warn_deprecated("use connect_after() or connect_simple_after()" TSRMLS_CC);
;; 	phpg_signal_connect_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, PHPG_CONNECT_OBJECT, TRUE);
;; }
;; /* }}} */


;   ((connect :return-type guint :c-name gtk_signal_connect) (name :gtk-type const-gchar*) (func :gtk-type GtkSignalFunc) (func_data :gtk-type gpointer))
(defmethod gtkobject (connect signal funcname #!rest data)
   (connect-impl (maybe-unbox $this)
		 (maybe-unbox signal)
		 (maybe-unbox funcname)
		 (map maybe-unbox data)
		 object?: #f
                 simple?: #f
                 after?: #f))

(defmethod gtkobject (connect_simple signal funcname #!rest data)
   (connect-impl (maybe-unbox $this)
		 (maybe-unbox signal)
		 (maybe-unbox funcname)
		 (map maybe-unbox data)
		 object?: #f
                 simple?: #t
                 after?: #f))

;(defmethod-XXX gtkobject (connect_after) TRUE)
;   ((connect_after :return-type guint :c-name gtk_signal_connect_after) (name :gtk-type const-gchar*) (func :gtk-type GtkSignalFunc) (func_data :gtk-type gpointer))
(defmethod gtkobject (connect_after signal funcname #!rest data)
   (connect-impl (maybe-unbox $this)
		 (maybe-unbox signal)
		 (maybe-unbox funcname)
		 (map maybe-unbox data)
                 object?: #f
                 simple?: #f
		 after?: #t))

(defmethod gtkobject (connect_simple_after signal funcname #!rest data)
   (connect-impl (maybe-unbox $this)
		 (maybe-unbox signal)
		 (maybe-unbox funcname)
		 (map maybe-unbox data)
                 object?: #f
		 simple?: #t
                 after?: #t))

;   ((connect_object :return-type guint :c-name gtk_signal_connect_object) (name :gtk-type const-gchar*) (func :gtk-type GtkSignalFunc) (slot_object :gtk-type GtkObject*))
(defmethod gtkobject (connect_object signal function #!rest data)
   (connect-impl (maybe-unbox $this)
                 (maybe-unbox signal)
                 (maybe-unbox function)
                 (map maybe-unbox data)
                 object?: #t
                 after?: #f
                 simple?: #f))


;   ((connect_object_after :return-type guint :c-name gtk_signal_connect_object_after) (name :gtk-type const-gchar*) (func :gtk-type GtkSignalFunc) (slot_object :gtk-type GtkObject*))
(defmethod gtkobject (connect_object_after signal function #!rest data)
   (connect-impl (maybe-unbox $this)
                 (maybe-unbox signal)
                 (maybe-unbox function)
                 (map maybe-unbox data)
                 object?: #t
                 after?: #t
                 simple?: #f))

(define (connect-impl $this signal function data #!key object? after? simple?)
   (debug-trace 3 "file " *PHP-FILE* " line " *PHP-LINE* " connecting a non-object, the function is " (mkstr function) " php-hash? says " (php-hash? function))
   (let ((signal (mkstr signal)))
      (gtk-signal-connect (GTK_OBJECT (gtk-object $this))
			  signal
			  (phpgtk-callback-closure function data
                                                   (not object?) simple?)
			  after?)
      TRUE))


;; (define (connect-object-impl $this signal function data after? simple?)
;;    (let ((signal (mkstr signal)))
;;       (debug-trace 3 "file " *PHP-FILE* " line " *PHP-LINE* " connecting an object, the function is " (mkstr function) " php-hash? says " (php-hash? function))
;;       (gtk-signal-connect (GTK_OBJECT (gtk-object $this))
;; 			  signal
;; 			  (phpgtk-callback-closure function data #f simple?)
;; 			  after?)
;;       TRUE))

(define-macro (my-try form handler)
   `(if (getenv "BIGLOOSTACKDEPTH")
	,form
       (try ,form ,handler)))

;; it looks like the utility of pass-object? is to suppress passing
;; the object.  The php-gtk marshaller (php_gtk_callback_marshal)
;; passes the object if it gets one, unless pass-object? is specified
;; and false.  If it doesn't get an object, it doesn't pass it,
;; regardless of what pass-object? is set to.
;;
;; simple? is handled in the marshaller in php-gtk, but we handle it
;; here.  it just means the arguments aren't used, so no need to pass
;; them.  if we handled it in the marshaller, we could skip
;; marshalling them too.
(define (phpgtk-callback-closure function data pass-object? simple?)
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
		    (my-try (if simple?
                                (call-php-method object method)
                                (apply call-php-method object method
                                       (append (map convert-to-php-type
                                                    (if (and obj pass-object?)
                                                        (cons obj rest)
                                                        rest))
                                               data)))
			 (lambda (e p m o)
			    (php-warning "Unable to call callback " (php-object-class object) "->" method "() specified in "
					 connected-file " on line " connected-line ": " m)
			    (e FALSE))))
		 ;; the callback is a static method call
		 (lambda (obj . rest)
		    (my-try (if simple?
                                (call-static-php-method (mkstr object) NULL method)
                                (apply call-static-php-method (mkstr object) NULL method
                                       (append (map convert-to-php-type
                                                    (if (and obj pass-object?)
                                                        (cons obj rest)
                                                        rest))
                                               data)))
			 (lambda (e p m o)
			    (php-warning "Unable to call callback " (php-object-class object) "::" method "() specified in "
					 connected-file " on line " connected-line ": " m)
			    (e FALSE))))))
	  ;; the callback is a regular function call
	  (let ((function (mkstr function)))
	     (lambda (obj . rest)
		(my-try (if simple?
                            (php-funcall function)
                            (apply php-funcall function
                                   (append (map convert-to-php-type
                                                (if (and obj pass-object?)
                                                    (cons obj rest)
                                                    rest))
                                           data)))
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

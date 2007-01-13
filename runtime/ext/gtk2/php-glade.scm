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
(module php-glade-lib
   (load (php-macros "../../../php-macros.scm"))
   (load (php-gtk-macros "php-gtk-macros.sch"))
   (library "php-runtime")
   (import (gtk-binding "cigloo/gtk.scm")
	   (gtk-signals "cigloo/signals.scm")
	   (glade-binding "cigloo/glade.scm")
	   (php-gtk-common-lib "php-gtk-common.scm")
	   (define-classes "define-classes.scm")
	   (php-gtk-signals "php-gtk-signals.scm"))
   (export (init-php-glade-lib)
	   (glade-connect-one handler-name::gchar*
			      obj::GtkObject*
			      signal-name::string
			      signal-data::gchar*
			      connect-object::GtkObject*
			      after::gboolean
			      callback-data::obj))
   (extern
    (export glade-connect-one "glade_connect_one")))

(define (init-php-glade-lib)
;   (glade_init)
   1)


; static function_entry php_libglade_functions[] = {
; 	{"xml_new_from_memory",	PHP_FN(glade_xml_new_from_memory),	NULL},
; 	{"get_widget_name",	PHP_FN(glade_get_widget_name),	NULL},
; 	{"get_widget_long_name",	PHP_FN(glade_get_widget_long_name),	NULL},
; 	{"get_widget_tree",	PHP_FN(glade_get_widget_tree),	NULL},
; 	{NULL, NULL, NULL}
; };

(def-static-methods libglade glade
   ((get_widget_name :return-type const-gchar* :c-name glade_get_widget_name) (widget :gtk-type GtkWidget*))
   ((get_widget_long_name :return-type const-gchar* :c-name glade_get_widget_long_name) (widget :gtk-type GtkWidget*))
   ((get_widget_tree :return-type GladeXML* :c-name glade_get_widget_tree) (widget :gtk-type GtkWidget*))
   )

; (def-static-method libglade (glade_xml_new_from_memory buffer size root domain)
;    (let ((buffer (mkstr buffer))
; 	 (size (mkfixnum size))
; 	 (root (mkstr root))
; 	 (domain (mkstr domain)))
;       ;;; php-gtk copies this object, ("separates" it), but I don't understand why
;       (gtk-object-wrapper-new #f (glade_xml_new_from_memory buffer size root domain))))


; static function_entry php_glade_xml_functions[] = {
; 	{"GladeXML",	PHP_FN(glade_xml_new_with_domain),	NULL},
; 	{"gladexml",	PHP_FN(glade_xml_new_with_domain),	NULL},
; 	{"get_type",	PHP_FN(glade_xml_get_type),	NULL},
; 	{"construct",	PHP_FN(glade_xml_construct),	NULL},
; 	{"signal_connect",	PHP_FN(glade_xml_signal_connect),	NULL},
; 	{"signal_autoconnect",	PHP_FN(glade_xml_signal_autoconnect),	NULL},
; 	{"get_widget",	PHP_FN(glade_xml_get_widget),	NULL},
; 	{"get_widget_by_long_name",	PHP_FN(glade_xml_get_widget_by_long_name),	NULL},
; 	{"relative_file",	PHP_FN(glade_xml_relative_file),	NULL},
; 	{"signal_connect_object",	PHP_FN(glade_xml_signal_connect_object),	NULL},
; 	{"signal_autoconnect_object",	PHP_FN(glade_xml_signal_autoconnect_object),	NULL},
; 	{NULL, NULL, NULL}
; };


(def-pgtk-methods GladeXML glade_xml
   ((relative_file :return-type gchar*) (filename :gtk-type const-gchar*))
   ((get_widget_by_long_name :return-type GtkWidget*) (longname :gtk-type const-char*))
   ((get_widget_prefix :return-type GList*) (name :gtk-type const-char*))
;   ((get_widget :return-type GtkWidget*) (name :gtk-type const-char*))
;   (signal_autoconnect_full (func :gtk-type GladeXMLConnectFunc) (user_data :gtk-type gpointer))
;   (signal_connect_full (handler_name :gtk-type const-gchar*) (func :gtk-type GladeXMLConnectFunc) (user_data :gtk-type gpointer))
;   (signal_autoconnect)
;   (signal_connect_data (handlername :gtk-type const-char*) (func :gtk-type GtkSignalFunc) (user_data :gtk-type gpointer))
;   (signal_connect (handlername :gtk-type const-char*) (func :gtk-type GtkSignalFunc))
   ((construct :return-type gboolean) (fname :gtk-type const-char*) (root :gtk-type const-char*) (domain :gtk-type const-char*))
   )

;; just took this out to debug it
(defmethod GladeXML (get_widget name)
    (let (($this::GladeXML*
            (if (php-null? (maybe-unbox $this))
		(begin
		   (debug-trace 1 "null gladexml")
		   (pragma::GladeXML* "NULL"))
              (GLADE_XML
                (gtk-object/safe 'GladeXML $this return))))
          (name::string (mkstr name)))
       (let ((retval (glade_xml_get_widget $this name)))
	  (debug-trace 3  "retval is: " retval)
      (gtk-object-wrapper-new
        'GtkWidget
	retval)
;         (pragma::GtkWidget*
;           "glade_xml_get_widget($1, $2)"
;           $this
;           name)
	)))

; (defmethod GladeXML (GladeXML filename #!optional root domain)
;    (debug-trace 3 "new gladexml filename " (mkstr filename) " root " root " domain " domain)
;    (let ((filename (mkstr filename))
; 	 (root ;(if root
; 		;   (mkstr root)
; 	  (pragma::gchar* "NULL") ) ;)
; 	 (domain ;(if domain
; 		  ;   (mkstr domain)
; 		     (pragma::gchar* "NULL") ;)
; 		     ))
;       (gtk-object-init! $this
; 			(glade_xml_new_with_domain filename root domain))))


(define (glade-connect-one handler-name::gchar*
			   obj::GtkObject*
			   signal-name::string
			   signal-data::gchar*
			   connect-object::GtkObject*
			   after::gboolean
			   callback-data::obj)
   (let ((callback (car callback-data))
	 (pass-object? (cadr callback-data))
	 (data (caddr callback-data)))
      (if (php-hash? callback)
	  (debug-trace 2 "connecting " (php-hash-lookup callback 0) "->" (php-hash-lookup callback 1) " via glade to " signal-name " on object " obj)
	  (debug-trace 2 "connecting " callback " via glade to "  signal-name " on object " obj))
      (unless (foreign-null? connect-object)
	 (debug-trace 2 "the connect-object wasn't null in glade-object-connect-one")
	 (set! pass-object? #t)
	 (set! data (cons (gtk-object-wrapper-new #f connect-object)
			  data)))

      (gtk-signal-connect (GTK_OBJECT obj)
			  signal-name
			  (phpgtk-callback-closure callback
						   data
						   pass-object?
                                                   #f)
			  after)))

; static void glade_connect_one(const gchar *handler_name, GtkObject *obj, const
; 							  gchar *signal_name, const gchar *signal_data,
; 							  GtkObject *connect_object, gboolean after,
; 							  zval *callback_data)
; {
; 	zval **callback = NULL, **extra = NULL, **pass_object = NULL;
; 	zval **callback_filename = NULL, **callback_lineno = NULL;
; 	zval *object;
; 	TSRMLS_FETCH();

; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 0, (void **)&callback);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 1, (void **)&extra);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 2, (void **)&pass_object);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 3, (void **)&callback_filename);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 4, (void **)&callback_lineno);

; 	if (connect_object) {
; 		zval *temp;

; 		Z_LVAL_PP(pass_object) = 0;
; 		object = php_gtk_new(connect_object);
; 		MAKE_STD_ZVAL(temp);
; 		array_init(temp);
; 		add_next_index_zval(temp, object);
; 		php_array_merge(Z_ARRVAL_P(temp), Z_ARRVAL_PP(extra), 0 TSRMLS_CC);
; 		REPLACE_ZVAL_VALUE(extra, temp, 0);
; 	}

; 	gtk_signal_connect_full(obj, signal_name, NULL,
; 							(GtkCallbackMarshal)php_gtk_callback_marshal,
; 							callback_data, php_gtk_destroy_notify, FALSE, after);
; }

(define (glade-signal-connect-impl $this handler-name callback pass-object? data)
   ;; we make a list of the info for making the callback closure and
   ;; pass that so we can delay actually making the closure until we
   ;; can see if glade wants us to "connect object" or not.  We don't
   ;; have to worry about the GC munching the list because
   ;; glade_connect_one will be called right away, so the list still
   ;; has dynamic extent.   
   (glade_xml_signal_connect_full (GLADE_XML (gtk-object $this))
				  handler-name ;; I don't think handler-name is used... ?!
				  (pragma::GladeXMLConnectFunc "glade_connect_one")
				  (pragma::gpointer "$1" (list callback pass-object? data)))
   NULL)

; static void glade_signal_connect_impl(INTERNAL_FUNCTION_PARAMETERS, int pass_object)
; {
; 	char *handler_name = NULL;
; 	zval *callback = NULL;
; 	zval *extra;
; 	zval *data;
; 	char *callback_filename;
; 	uint callback_lineno;

; 	NOT_STATIC_METHOD();

; 	if (ZEND_NUM_ARGS() < 2) {
; 		php_error(E_WARNING, "%s() requires at least 2 arguments, %d given",
; 				  get_active_function_name(TSRMLS_C), ZEND_NUM_ARGS());
; 		return;
; 	}

; 	if (!php_gtk_parse_args(2, "sV", &handler_name, &callback))
; 		return;

; 	callback_filename = zend_get_executed_filename(TSRMLS_C);
; 	callback_lineno = zend_get_executed_lineno(TSRMLS_C);
; 	extra = php_gtk_func_args_as_hash(ZEND_NUM_ARGS(), 2, ZEND_NUM_ARGS());
; 	data = php_gtk_build_value("(VNisi)", callback, extra, pass_object, callback_filename, callback_lineno);
; 	glade_xml_signal_connect_full(GLADE_XML(PHP_GTK_GET(this_ptr)), handler_name,
; 								  (GladeXMLConnectFunc)glade_connect_one, data);
; 	RETURN_NULL();
; }

(defmethod GladeXML (signal_connect handler-name callback #!rest rest)
   (glade-signal-connect-impl $this
			      (maybe-unbox handler-name)
			      (maybe-unbox callback)
			      #t
			      (map maybe-unbox rest)))

; PHP_FUNCTION(glade_xml_signal_connect)
; {
; 	glade_signal_connect_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, 1);
; }



(defmethod GladeXML (signal_connect_object handler-name callback #!rest rest)
   (glade-signal-connect-impl $this
			      (maybe-unbox handler-name)
			      (maybe-unbox callback)
			      #f
			      (map maybe-unbox rest)))

; PHP_FUNCTION(glade_xml_signal_connect_object)
; {
; 	glade_signal_connect_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, 0);
; }



; typedef struct _php_gtk_autoconnect_data {
; 	zend_bool pass_object;
; 	zval *map;
; } php_gtk_autoconnect_data;


; static void glade_connect_auto(const gchar *handler_name, GtkObject *obj,
; 							   const gchar *signal_name, const gchar *signal_data,
; 							   GtkObject *connect_object, gboolean after,
; 							   php_gtk_autoconnect_data *ac_data)
; {
; 	zval **callback_data = NULL, *map = ac_data->map;
; 	zval **callback_ptr = NULL, *extra = NULL, *params = NULL;
; 	zval *callback, *data, *object = NULL;
; 	int pass_object = ac_data->pass_object;
; 	char *callback_filename;
; 	uint callback_lineno;
; 	TSRMLS_FETCH();

; 	if (map && zend_hash_find(Z_ARRVAL_P(map), (char *)handler_name, strlen(handler_name) + 1, (void **)&callback_data) == SUCCESS) {
; 		if (Z_TYPE_PP(callback_data) != IS_ARRAY ||
; 			zend_hash_index_find(Z_ARRVAL_PP(callback_data), 0, (void **)&callback_ptr) == FAILURE) {
; 			php_error(E_WARNING, "%s() is supplied with invalid callback structure for handler '%s'", get_active_function_name(TSRMLS_C), handler_name);
; 			return; 
; 		}
; 		zval_add_ref(callback_ptr);
; 		callback = *callback_ptr;
; 		zend_hash_index_del(Z_ARRVAL_PP(callback_data), 0);
; 		extra = *callback_data;
; 	} else {
; 		MAKE_STD_ZVAL(callback);
; 		ZVAL_STRING(callback, (char *)handler_name, 1);
; 	}

; 	if (!zend_is_callable(callback, 0, NULL)) {
; 		php_error(E_WARNING, "%s() is unable to autoconnect callback for handler '%s'",
; 				  get_active_function_name(TSRMLS_C), handler_name);
; 		return;
; 	}
	
; 	MAKE_STD_ZVAL(params);
; 	array_init(params);

; 	if (connect_object) {
; 		pass_object = 0;
; 		object = php_gtk_new(connect_object);
; 		add_next_index_zval(params, object);
; 	}
	
; 	if (extra)
; 		php_array_merge(Z_ARRVAL_P(params), Z_ARRVAL_P(extra), 0 TSRMLS_CC);

; 	callback_filename = zend_get_executed_filename(TSRMLS_C);
; 	callback_lineno = zend_get_executed_lineno(TSRMLS_C);
; 	data = php_gtk_build_value("(NNisi)", callback, params, pass_object,
; 							   callback_filename, callback_lineno);
; 	gtk_signal_connect_full(obj, signal_name, NULL,
; 							(GtkCallbackMarshal)php_gtk_callback_marshal,
; 							data, php_gtk_destroy_notify, FALSE, after);
; }

; static void glade_signal_autoconnect_impl(INTERNAL_FUNCTION_PARAMETERS, int pass_object)
; {
; 	zval *map = NULL;
; 	php_gtk_autoconnect_data *ac_data;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "|a", &map))
; 		return;

; 	ac_data = (php_gtk_autoconnect_data *)emalloc(sizeof(php_gtk_autoconnect_data));
; 	ac_data->map = map;
; 	ac_data->pass_object = pass_object;
; 	glade_xml_signal_autoconnect_full(GLADE_XML(PHP_GTK_GET(this_ptr)),
; 									  (GladeXMLConnectFunc)glade_connect_auto, ac_data);
; }

; PHP_FUNCTION(glade_xml_signal_autoconnect)
; {
; 	glade_signal_autoconnect_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, 1);
; }


; PHP_FUNCTION(glade_xml_signal_autoconnect_object)
; {
; 	glade_signal_autoconnect_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, 0);
; }

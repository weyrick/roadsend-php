(module gtk-signals
   (library php-runtime)
   (import (gtk-binding "cigloo/gtk.scm"))
   (export
    (reference obj)
    (dereference obj)
    (gtk-signal-connect obj::GtkObject* signal::bstring func::procedure #!optional after)
    (phpgtk-destroy-notify::obj data::procedure)
    (phpgtk-closure-invalidate::obj data::procedure closure::GClosure*)
;    (phpgtk-signal-marshall::obj obj::GtkObject* data::procedure n_args::guint args::GtkArg*)
    (phpgtk-closure-marshall::obj closure::GClosure*
                                  retval-ptr::GValue*
                                  n-args::guint
                                  param-values::GValue*
                                  invocation-hint::gpointer
                                  marshal-data::procedure)
    (phpgtk-generic-callback callback::procedure)
    (gtk-idle-add func::procedure #!optional priority)
    (gtk-timeout-add interval func::procedure)
    (gtk-quit-add main-level func::procedure))
   (extern
    (macro GTK_PRIORITY_DEFAULT::int "GTK_PRIORITY_DEFAULT")
    (export phpgtk-destroy-notify "phpgtk_destroy_notify")
    (export phpgtk-closure-invalidate "phpgtk_closure_invalidate")
    (export phpgtk-closure-marshall "phpgtk_closure_marshall")
    (export phpgtk-generic-callback "phpgtk_generic_callback") ))

;;; we need to keep scheme data from being garbage collected
(define *scheme-references* (make-grasstable))

(define (reference obj)
   (let ((r (grasstable-get *scheme-references* obj)))
      (debug-trace 3 "adding reference to object: " obj)
      (if r
	  (grasstable-put! *scheme-references* obj (+ r 1))
	  (grasstable-put! *scheme-references* obj 1))))

(define (dereference obj)
   (let ((r (grasstable-get *scheme-references* obj)))
      (if r
	  (if (zero? r)
	      (begin
		 (debug-trace 3 "deleting last reference to object: " obj)		 
		 (grasstable-remove! *scheme-references* obj))
	      (begin
		 (debug-trace 3 "deleting reference from object: " obj)
		 (grasstable-put! *scheme-references* obj (- r 1))))
	  (error 'dereference "object was not referenced" obj))))


;;;; signals

(define (gtk-signal-connect obj::GtkObject* signal::bstring callback::procedure
                            #!optional after)
   (reference callback)
   (let ((detail::GQuark (pragma::GQuark "0"))
         (signal-id::guint 0))
      (if (not (g_signal_parse_name signal
                                    (G_OBJECT_TYPE (pragma::GObject* "$1" obj))
                                    (pragma::guint* "&$1" signal-id)
                                    (pragma::GQuark* "&$1" detail)
                                    (gtk_true)))
          (php-warning "unknown signal name '" signal "'")
          ;; returns the handler-id
          (g_signal_connect_closure_by_id (pragma::void* "$1" obj) signal-id detail
                                          (phpgtk-gclosure-new callback)
                                          (if after (gtk_true) (gtk_false))))))
;; (gtk_signal_connect_full obj
;; 			    signal
;; 			    ;; we don't let gtk call the signal function directly
;; 			    (pragma::*void->void "(GtkSignalFunc)NULL")
;; 			    ;; instead, we have our marshaller do it
;; 			    (pragma::*GtkObject*,gpointer,guint,GtkArg*->void
;; 			     "phpgtk_signal_marshall")
;; 			    ;; we pass the actual callback as the `data' arg
;; 			    (pragma::void* "$1" func)
;; 			    ;; the `destroy notify' hook
;; 			    (pragma::*gpointer->void
;; 			     "phpgtk_destroy_notify")
;; 			    ;; whether this is an `object signal'
;; 			    0
;; 			    (if after (gtk_true) (gtk_false)))
;;    )


(define (phpgtk-gclosure-new::GClosure* callback::procedure)
   (reference callback)
   (let ((closure::GClosure*
          (g_closure_new_simple (pragma::int "sizeof(GClosure)")
                                (pragma::void* "$1" callback))))
      (g_closure_set_marshal closure
                             (pragma::GClosureMarshal "phpgtk_closure_marshall"))
      ;; maybe it's better to use a finalize notifier?  not sure.
      (g_closure_add_invalidate_notifier closure
                                         (pragma::void* "NULL")
                                         (pragma::GClosureNotify "phpgtk_closure_invalidate"))
      closure))


(define (phpgtk-closure-marshall::obj closure::GClosure*
                                      retval-ptr::GValue*
                                      n-args::guint
                                      param-values::GValue*
                                      invocation-hint::gpointer
                                      marshal-data::procedure) ;actually a gpointer
;;          obj::GtkObject*
;;                                       data::procedure 
;;                                       n_args::guint
;;                                       args::GtkArg*)
   (debug-trace 3 "phpgtk-closure-marshall called " (pragma::procedure "$1->data" closure))
   ;; call the callback
   (let ((retval (apply (pragma::procedure "$1->data" closure) (gvalues->list param-values n-args))))
      ;; return the return value, unless no return value is wanted
      ;; (indicated by a NULL pointer)
      (when (pragma::bool "$1" retval-ptr)
         (unless (php-value->gvalue retval retval-ptr #t)
            (php-warning "Could not convert return value of signal callback "
                         ;; XXX need some way to grab the callback name here
                         " to "
                         (g_type_name (G_VALUE_TYPE retval-ptr)))))))

(define (php-value->gvalue value gvalue::GValue* utf8?)
   (let ((val-type::GType (G_TYPE_FUNDAMENTAL (G_VALUE_TYPE gvalue))))
      (cond
         ((or (= val-type G_TYPE_NONE)
              (= val-type G_TYPE_INVALID))
          #t)
         ((= val-type G_TYPE_BOOLEAN)
          (g_value_set_boolean gvalue (if (convert-to-boolean value)
                                          (gtk_true)
                                          (gtk_false)))
          #t)
         (else
          (php-warning "Unsupported type in php-value->gvalue: " (g_type_name val-type))))))


;; 	 (let* ((last-arg (pragma::GtkArg* "&($1[$2])" args n_args))
;; 		(ret-type (pragma::GtkFundamentalType "GTK_FUNDAMENTAL_TYPE($1->type)"
;; 						     last-arg)))
;; 	    (cond 
;; 	       ((or (= ret-type GTK_TYPE_NONE)
;; 		    (= ret-type GTK_TYPE_INVALID))
;; 		(unspecified))
	       
;; 	       ((= ret-type GTK_TYPE_BOOL)
;; 		(debug-trace 3 "phpgtk-signal-marshall: boolean return value")
;; 		(pragma "(*GTK_RETLOC_BOOL(*$1) = $2)"
;; 			last-arg (if (convert-to-boolean retval) (gtk_true) (gtk_false)))
;; 		(unspecified))
	       
;; 	       (else (fprint (current-error-port) "unsupported return type " ret-type)))
;; 	    ))))


(define (gtk-object-adjust-type obj;; ::GtkObject*
				#!optional
				the-type)
   (let* ((the-type (or the-type (pragma::GtkType "GTK_OBJECT_TYPE($1)" obj))))
;       (fprint (current-error-port) "type: " the-type)
;       (fprint (current-error-port) "type-name: "  (gtk_type_name the-type))
      (pragma::obj #"cobj_to_foreign($1, $2)"
		   (string->symbol (string-append "bs-_" (gtk_type_name the-type) "*"))
		   obj)))

(define (phpgtk-destroy-notify::obj data::procedure) ;actually a gpointer
   (debug-trace 3 "phpgtk-destroy-notify called")
   ;; (dereference data)
   )

(define (phpgtk-closure-invalidate::obj data::procedure ;actually a gpointer
                                        closure::GClosure*)
   (debug-trace 3 "phpgtk-closure-invalidate called")
   ;; (dereference data)
   )

(define (gvalues->list values::GValue* n-values)
   (let loop ((i::int (- n-values 1))
              (acc '()))
      (if (<fx i 0)
          acc
          (loop (-fx i 1)
                (cons (let* ((val::GValue* (pragma::GValue* "$1 + $2" values i))
                             (val-type ;(pragma::GType "G_TYPE_FUNDAMENTAL(G_VALUE_TYPE($1))"
                                                      (G_TYPE_FUNDAMENTAL (G_VALUE_TYPE val))));)
                         (cond
                            ((or (= val-type G_TYPE_INVALID)
                                 (= val-type G_TYPE_NONE))
                             NULL)
			    ((= val-type G_TYPE_CHAR)
                             (g_value_get_char val))
			    
			    ((= val-type G_TYPE_BOOLEAN)
                             (g_value_get_boolean val))
			    
			    ((or (= val-type G_TYPE_INT)
				 (= val-type G_TYPE_ENUM))
                             (g_value_get_int val))
			    
			    ((= val-type G_TYPE_FLAGS)
                             (g_value_get_flags val))
			    
			    ((= val-type G_TYPE_UINT)
			     (g_value_get_uint val))
			    
			    ((= val-type G_TYPE_LONG)
                             (g_value_get_long val))
			    
			    ((= val-type G_TYPE_ULONG)
			     (g_value_get_ulong val))
			    
			    ((= val-type G_TYPE_FLOAT)
			     (g_value_get_float val))
			    
			    ((= val-type G_TYPE_DOUBLE)
			     (g_value_get_double val))
			    
			    ((= val-type G_TYPE_STRING)
			     (g_value_get_string val))
			    
			    ((= val-type G_TYPE_OBJECT)
                             ;			     (fprint (current-error-port) "it's an object")
			     (gtk-object-adjust-type
			      (g_value_get_object val)))
			    
			    ((= val-type G_TYPE_BOXED)
                             ;; could be:
                             ;; - a G_TYPE_PHP_VALUE ??
                             ;; - a G_TYPE_VALUE_ARRAY
                             ;; - something for which there's a custom ->phpval (rectangle, tree_path)
                             ;; otherwise:
                             (gboxed-new (G_VALUE_TYPE val) val #f #f))

			    (else
			     (error 'gvalues->list "value type unsupported" (cons (gtk_type_name val-type)
                                                                                  val-type)))))
                         acc)))))


(define (gboxed-new type::GType value copy? utf8?)
;   (print (g_type_name type)))
   (cond
      ((= type GDK_TYPE_EVENT)
       (pragma::GdkEvent* "g_value_get_boxed($1)" value))
      (else
       (error 'gvalues->list "boxed value type unsupported" (cons (g_type_name type) type)))))
;       ((= val-type GDK_TYPE_WINDOW)
;        (pragma::GdkWindow* "g_value_get_boxed($1)" val))
;       ((= val-type GDK_TYPE_COLOR)
;        (pragma::GdkColor* "g_value_get_boxed($1)" val))
;       ((= val-type GDK_TYPE_VISUAL)
;        (pragma::GdkVisual* "g_value_get_boxed($1)" val))
;       ((= val-type GDK_TYPE_FONT)
;        (pragma::GdkFont* "g_value_get_boxed($1)" val))
;       ((= val-type GDK_TYPE_DRAG_CONTEXT)
;        (pragma::GdkDragContext* "g_value_get_boxed($1)" val))
;       ;; 				((= val-type G_TYPE_ACCEL_GROUP)
;       ;; 				 (pragma::GtkAccelGroup* "g_value_get_boxed($1)" val))
;       ;; 				((= val-type G_TYPE_STYLE)
;       ;; 				 (pragma::GtkStyle* "g_value_get_boxed($1)" val))
;       ;; 				((= val-type G_TYPE_SELECTION_DATA)
;       ;; 				 (pragma::GtkSelectionData* "g_value_get_boxed($1)" val))
;       ;; 				((= val-type G_TYPE_CTREE_NODE)
;       ;; 				 (pragma::GtkCTreeNode* "g_value_get_boxed($1)" val))
;       (else
;        (error 'gvalues->list "boxed value type unsupported" (cons (gtk_type_name val-type)
;                                                                   val-type))))
;   ))

;; (define (gtk-args->list args::GtkArg* n_args)
;;    (let loop ((i::int (- n_args 1))
;; 	      (accu '()))
;;       (if (<fx i 0)
;; 	  (begin ;(fprint (current-error-port) "w00t: " accu)
;; 		 accu)
;; 	  (loop (-fx i 1)
;; 		(cons (let* ((argtype (pragma::GtkType "$1[$2].type" args i))
;; 			     (fundamental-type
;; 			      (pragma::GtkFundamentalType "GTK_FUNDAMENTAL_TYPE($1)"
;; 							  argtype)))
;; ; 			 (fprint (current-error-port) "the type name: " (gtk_type_name argtype)
;; ; 				 "value: " argtype ", value of macro: " GDK_TYPE_EVENT
;; ; 				 (eq? GDK_TYPE_EVENT argtype))
;; 			 (cond
;; 			    ((= fundamental-type GTK_TYPE_CHAR)
;; 			     (pragma::char "GTK_VALUE_CHAR($1[$2])" args i))
			    
;; 			    ((= fundamental-type GTK_TYPE_BOOL)
;; 			     (pragma::bool "GTK_VALUE_BOOL($1[$2])" args i))
			    
;; 			    ((or (= fundamental-type GTK_TYPE_INT)
;; 				 (= fundamental-type GTK_TYPE_ENUM))
;; 			     (pragma::int "GTK_VALUE_INT($1[$2])" args i))
			    
;; 			    ((= fundamental-type GTK_TYPE_FLAGS)
;; 			     (pragma::uint "GTK_VALUE_FLAGS($1[$2])" args i))
			    
;; 			    ((= fundamental-type GTK_TYPE_UINT)
;; 			     (pragma::uint "GTK_VALUE_UINT($1[$2])" args i))
			    
;; 			    ((= fundamental-type GTK_TYPE_LONG)
;; 			     (pragma::long "GTK_VALUE_LONG($1[$2])" args i))
			    
;; 			    ((= fundamental-type GTK_TYPE_ULONG)
;; 			     (pragma::ulong "GTK_VALUE_ULONG($1[$2])" args i))
			    
;; 			    ((= fundamental-type GTK_TYPE_FLOAT)
;; 			     (pragma::float "GTK_VALUE_FLOAT($1[$2])" args i))
			    
;; 			    ((= fundamental-type GTK_TYPE_DOUBLE)
;; 			     (pragma::double "GTK_VALUE_DOUBLE($1[$2])" args i))
			    
;; 			    ((= fundamental-type GTK_TYPE_STRING)
;; 			     (pragma::string "GTK_VALUE_STRING($1[$2])" args i))
			    
;; 			    ((= fundamental-type GTK_TYPE_OBJECT)
;; ;			     (fprint (current-error-port) "it's an object")
;; 			     (gtk-object-adjust-type
;; 			      (pragma::GtkObject* "GTK_VALUE_OBJECT($1[$2])" args i)))
			    
;; 			    ((= fundamental-type GTK_TYPE_BOXED)
;; ;			     (fprint (current-error-port) "it's boxed " argtype)
;; 			     (cond
;; 				((= argtype GDK_TYPE_EVENT)
;; 				 (pragma::GdkEvent* "GTK_VALUE_BOXED($1[$2])" args i))
;; 				((= argtype GDK_TYPE_WINDOW)
;; 				 (pragma::GdkWindow* "GTK_VALUE_BOXED($1[$2])" args i))
;; 				((= argtype GDK_TYPE_COLOR)
;; 				 (pragma::GdkColor* "GTK_VALUE_BOXED($1[$2])" args i))
;; 				((= argtype GDK_TYPE_VISUAL)
;; 				 (pragma::GdkVisual* "GTK_VALUE_BOXED($1[$2])" args i))
;; 				((= argtype GDK_TYPE_FONT)
;; 				 (pragma::GdkFont* "GTK_VALUE_BOXED($1[$2])" args i))
;; 				((= argtype GDK_TYPE_DRAG_CONTEXT)
;; 				 (pragma::GdkDragContext* "GTK_VALUE_BOXED($1[$2])" args i))
;; 				((= argtype GTK_TYPE_ACCEL_GROUP)
;; 				 (pragma::GtkAccelGroup* "GTK_VALUE_BOXED($1[$2])" args i))
;; 				((= argtype GTK_TYPE_STYLE)
;; 				 (pragma::GtkStyle* "GTK_VALUE_BOXED($1[$2])" args i))
;; 				((= argtype GTK_TYPE_SELECTION_DATA)
;; 				 (pragma::GtkSelectionData* "GTK_VALUE_BOXED($1[$2])" args i))
;; 				((= argtype GTK_TYPE_CTREE_NODE)
;; 				 (pragma::GtkCTreeNode* "GTK_VALUE_BOXED($1[$2])" args i))
;; 				(else
;; 				 (error 'gtk-args->list "boxed arg type unsupported" (cons (gtk_type_name argtype)
;; 											   argtype)))))
;; 			    (else
;; 			     (error 'gtk-args->list "arg type unsupported" (cons (gtk_type_name argtype)
;; 										 fundamental-type)))))
;; 		      accu)))))


;;;; other callbacks

(define (phpgtk-generic-callback callback::procedure)
   ;   (debug-trace 3 "gtk-callback-marshal called! ")
   (callback))

(define (gtk-idle-add func::procedure #!optional (priority GTK_PRIORITY_DEFAULT))
   (reference func)
   (gtk_idle_add_full priority
		      (pragma::GtkFunction "phpgtk_generic_callback")
		      (pragma::GtkCallbackMarshal "NULL")
		      (pragma::gpointer "$1" func) 
		      (pragma::GtkDestroyNotify "phpgtk_destroy_notify")))

(define (gtk-timeout-add interval func::procedure)
   (reference func)
   (gtk_timeout_add_full interval
			 (pragma::GtkFunction "phpgtk_generic_callback")
			 (pragma::GtkCallbackMarshal "NULL")
			 (pragma::gpointer "$1" func) 
			 (pragma::GtkDestroyNotify "phpgtk_destroy_notify")))

(define (gtk-quit-add main-level func::procedure)
   (reference func)
   (gtk_quit_add_full main-level
		      (pragma::GtkFunction "phpgtk_generic_callback")
		      (pragma::GtkCallbackMarshal "NULL")
		      (pragma::gpointer "$1" func) 
		      (pragma::GtkDestroyNotify "phpgtk_destroy_notify")))


(module gtk-signals
   (library php-runtime)
   (import (gtk-binding "cigloo/gtk.scm"))
   (export
    (reference obj)
    (dereference obj)
    (gtk-signal-connect obj::GtkObject* signal::bstring func::procedure #!optional after)
    (phpgtk-destroy-notify::obj data::procedure)
    (phpgtk-signal-marshall::obj obj::GtkObject* data::procedure n_args::guint args::GtkArg*)
    (phpgtk-generic-callback callback::procedure)
    (gtk-idle-add func::procedure #!optional (priority GTK_PRIORITY_DEFAULT))
;    (gtk-idle-add func::procedure #!optional priority)
    (gtk-timeout-add interval func::procedure)
    (gtk-quit-add main-level func::procedure))
   (extern
    (macro GTK_PRIORITY_DEFAULT::int "GTK_PRIORITY_DEFAULT")
    (export phpgtk-destroy-notify "phpgtk_destroy_notify")
    (export phpgtk-signal-marshall "phpgtk_signal_marshall")
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

(define (gtk-signal-connect obj::GtkObject* signal::bstring func::procedure #!optional after)
   (reference func)
   (gtk_signal_connect_full obj
			    signal
			    ;; we don't let gtk call the signal function directly
			    (pragma::*->void "(GtkSignalFunc)NULL")
			    ;; instead, we have our marshaller do it
			    (pragma::*GtkObject*,gpointer,guint,GtkArg*->void
			     "phpgtk_signal_marshall")
			    ;; we pass the actual callback as the `data' arg
			    (pragma::void* "$1" func)
			    ;; the `destroy notify' hook
			    (pragma::*gpointer->void
			     "phpgtk_destroy_notify")
			    ;; whether this is an `object signal'
			    0
			    (if after (gtk_true) (gtk_false))))

(define (phpgtk-signal-marshall::obj obj::GtkObject*
				     data::procedure ;actually a gpointer
				     n_args::guint
				     args::GtkArg*)
   (debug-trace 3 "phpgtk-signal-marshall called")
   ;; call the callback
   (let ((retval (apply data
 			;; according to the php-gtk source, obj can
			;; sometimes be null.  I haven't seen it yet
			;; though, afaik.
			(if (foreign-null? obj)
			    #f
			    (gtk-object-adjust-type obj))			
;			obj
			(gtk-args->list args n_args))))
      ;;return the return value
      (when (pragma::bool "$1" args)
	 (let* ((last-arg (pragma::GtkArg* "&($1[$2])" args n_args))
		(ret-type (pragma::GtkFundamentalType "GTK_FUNDAMENTAL_TYPE($1->type)"
						     last-arg)))
	    (cond 
	       ((or (= ret-type GTK_TYPE_NONE)
		    (= ret-type GTK_TYPE_INVALID))
		(unspecified))
	       
	       ((= ret-type GTK_TYPE_BOOL)
		(debug-trace 3 "phpgtk-signal-marshall: boolean return value")
		(pragma "(*GTK_RETLOC_BOOL(*$1) = $2)"
			last-arg (if (convert-to-boolean retval) (gtk_true) (gtk_false)))
		(unspecified))
	       
	       (else (fprint (current-error-port) "unsupported return type " ret-type)))
	    ))))


(define (gtk-object-adjust-type obj::GtkObject*
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
   (dereference data)
   )


(define (gtk-args->list args::GtkArg* n_args)
   (let loop ((i::int (- n_args 1))
	      (accu '()))
      (if (<fx i 0)
	  (begin ;(fprint (current-error-port) "w00t: " accu)
		 accu)
	  (loop (-fx i 1)
		(cons (let* ((argtype (pragma::GtkType "$1[$2].type" args i))
			     (fundamental-type
			      (pragma::GtkFundamentalType "GTK_FUNDAMENTAL_TYPE($1)"
							  argtype)))
; 			 (fprint (current-error-port) "the type name: " (gtk_type_name argtype)
; 				 "value: " argtype ", value of macro: " GTK_TYPE_GDK_EVENT
; 				 (eq? GTK_TYPE_GDK_EVENT argtype))
			 (cond
			    ((= fundamental-type GTK_TYPE_CHAR)
			     (pragma::char "GTK_VALUE_CHAR($1[$2])" args i))
			    
			    ((= fundamental-type GTK_TYPE_BOOL)
			     (pragma::bool "GTK_VALUE_BOOL($1[$2])" args i))
			    
			    ((or (= fundamental-type GTK_TYPE_INT)
				 (= fundamental-type GTK_TYPE_ENUM))
			     (pragma::int "GTK_VALUE_INT($1[$2])" args i))
			    
			    ((= fundamental-type GTK_TYPE_FLAGS)
			     (pragma::uint "GTK_VALUE_FLAGS($1[$2])" args i))
			    
			    ((= fundamental-type GTK_TYPE_UINT)
			     (pragma::uint "GTK_VALUE_UINT($1[$2])" args i))
			    
			    ((= fundamental-type GTK_TYPE_LONG)
			     (pragma::long "GTK_VALUE_LONG($1[$2])" args i))
			    
			    ((= fundamental-type GTK_TYPE_ULONG)
			     (pragma::ulong "GTK_VALUE_ULONG($1[$2])" args i))
			    
			    ((= fundamental-type GTK_TYPE_FLOAT)
			     (pragma::float "GTK_VALUE_FLOAT($1[$2])" args i))
			    
			    ((= fundamental-type GTK_TYPE_DOUBLE)
			     (pragma::double "GTK_VALUE_DOUBLE($1[$2])" args i))
			    
			    ((= fundamental-type GTK_TYPE_STRING)
			     (pragma::string "GTK_VALUE_STRING($1[$2])" args i))
			    
			    ((= fundamental-type GTK_TYPE_OBJECT)
;			     (fprint (current-error-port) "it's an object")
			     (gtk-object-adjust-type
			      (pragma::GtkObject* "GTK_VALUE_OBJECT($1[$2])" args i)))
			    
			    ((= fundamental-type GTK_TYPE_BOXED)
;			     (fprint (current-error-port) "it's boxed " argtype)
			     (cond
				((= argtype GTK_TYPE_GDK_EVENT)
				 (pragma::GdkEvent* "GTK_VALUE_BOXED($1[$2])" args i))
				((= argtype GTK_TYPE_GDK_WINDOW)
				 (pragma::GdkWindow* "GTK_VALUE_BOXED($1[$2])" args i))
				((= argtype GTK_TYPE_GDK_COLOR)
				 (pragma::GdkColor* "GTK_VALUE_BOXED($1[$2])" args i))
				((= argtype GTK_TYPE_GDK_VISUAL)
				 (pragma::GdkVisual* "GTK_VALUE_BOXED($1[$2])" args i))
				((= argtype GTK_TYPE_GDK_FONT)
				 (pragma::GdkFont* "GTK_VALUE_BOXED($1[$2])" args i))
				((= argtype GTK_TYPE_GDK_DRAG_CONTEXT)
				 (pragma::GdkDragContext* "GTK_VALUE_BOXED($1[$2])" args i))
				((= argtype GTK_TYPE_ACCEL_GROUP)
				 (pragma::GtkAccelGroup* "GTK_VALUE_BOXED($1[$2])" args i))
				((= argtype GTK_TYPE_STYLE)
				 (pragma::GtkStyle* "GTK_VALUE_BOXED($1[$2])" args i))
				((= argtype GTK_TYPE_SELECTION_DATA)
				 (pragma::GtkSelectionData* "GTK_VALUE_BOXED($1[$2])" args i))
				((= argtype GTK_TYPE_CTREE_NODE)
				 (pragma::GtkCTreeNode* "GTK_VALUE_BOXED($1[$2])" args i))
				(else
				 (error 'gtk-args->list "boxed arg type unsupported" (cons (gtk_type_name argtype)
											   argtype)))))
			    (else
			     (error 'gtk-args->list "arg type unsupported" (cons (gtk_type_name argtype)
										 fundamental-type)))))
		      accu)))))


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


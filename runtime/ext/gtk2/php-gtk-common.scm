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
(module php-gtk-common-lib
;   (include "../phpoo-extension.sch")

   (load (php-macros "../../../php-macros.scm"))
   (load (php-gtk-macros "php-gtk-macros.sch"))
;   (import (gtk-foreign-types "gtk-foreign-types.scm"))
;   (import (gtk-binding "cigloo/gtk.scm"))
   (import (gtk-binding "cigloo/gtk.scm"))
;   (import (gtkscintilla-binding "cigloo/gtkscintilla.scm"))
   (import (glade-binding "cigloo/glade.scm"))
   (import (gtk-signals "cigloo/signals.scm"))
;   (library "common")
;   (library "bgtk")
   (library php-runtime)
;;    (import (gtk-enums-lib "gtk-enums.scm"))
;;    (import (gdk-enums-lib "gdk-enums.scm"))
   (import (php-gdk-lib "php-gdk.scm"))
   (export
    (init-php-gtk-common-lib)   
    (gtk-object php-obj)
    (gtk-object/safe type php-obj fail)
    (gtk-object-set! php-obj gtk-obj)
    (gtk-object-init! php-obj gtk-obj)
    (gtk-wrapper-new type::symbol gtk-obj)
    (gtk-object-wrapper-new type gtk-obj)
    (gtk-enum-value enum-type php-value)
    (gtk-flag-value flag-type php-value)

;    (gtk-window php-obj)
;    (gtk-window-set! php-obj gtk-obj)
    (gtk-boxed-alloc type php-obj)
    (convert-to-php-type obj)
;    (convert-to-scheme-type typename obj)
    (phpgtk-wrapper-destroy-notify::obj php-obj::obj))
   (extern
    (export phpgtk-wrapper-destroy-notify "phpgtk_wrapper_destroy_notify"))
   )

;;;
;;; Module Init
;;; ===========

(define (init-php-gtk-common-lib)
   1)

(define (gtk-object/safe type php-obj fail)
   (set! php-obj (maybe-unbox php-obj))
   (if (php-object-is-a php-obj type)
       (gtk-object php-obj)
       (begin
	  (php-warning "expecting a " type ", got " (if (php-object? php-obj)
							(php-object-class php-obj)
							(if (php-null? php-obj)
							    "NULL"
							    php-obj)))
	  (fail 0))))

(define (gtk-object php-obj)
   (set! php-obj (maybe-unbox php-obj))
   (let ((props (php-object-custom-properties php-obj)))
      (if (hashtable? props)
	  (let ((obj (hashtable-get props 'gtkobject)))
	     (if (and (foreign? obj)
		      (not (foreign-null? obj)))
		 (begin
		    (debug-trace 3 "gtk-object: php class: " (php-object-class php-obj) ", foreign-type: " obj)
		    obj)
		 (begin
		    (debug-trace 3 "gtk-object: Wrapped object missing in wrapper: " php-obj "(found: " obj ")")
		    NULL)))
	  (begin
	     (debug-trace 3 "custom properties didn't get setup for object " php-obj)
	     NULL))))

(define +gtk-wrapper-key+ "php_gtk::wrapper")
(define *counter* 1)

(define *other-gtk-wrappers* (make-php-hash))


(define (get-custom-props php-obj)
   (let ((props (php-object-custom-properties php-obj)))
      ;;lazily initialize the custom properties
      ;;XXX this is not where this ultimately belongs, it's only so I can commit something that semi-works tonight!
      (unless (hashtable? props)
	 (php-object-custom-properties-set! php-obj (make-hashtable))
	 (set! props (php-object-custom-properties php-obj)))
      props))

(define (gtk-object-set! php-obj gtk-obj)
   (when (foreign-null? gtk-obj)
      (error 'gtk-object-set! "attempt to set a null gtk-obj" gtk-obj))
   (set! php-obj (maybe-unbox php-obj))
   (debug-trace 3 "gtk-object-dammit-set! php-obj's class: " (php-object-class php-obj) ", gtk-obj: " gtk-obj)
   (let ((props (get-custom-props php-obj)))
      (hashtable-put! props 'gtkobject gtk-obj)
      (if (php-object-is-a php-obj 'GtkObject) ;(subtype-of-GtkObject*? gtk-obj)
       (begin
	  (pragma "gtk_object_set_data_full(FOREIGN_TO_COBJ($1), $2, $3, phpgtk_wrapper_destroy_notify)"
		  gtk-obj +gtk-wrapper-key+ php-obj)
	  (reference php-obj))
       ;; to be correct, this needs finalizers and weak references.  Otherwise it leaks, and
       ;; could get out of sync.
       (begin
	  (php-hash-insert! *other-gtk-wrappers* (gtkobj-hashnumber gtk-obj) php-obj)))
      ;; this counter business... not sure what it's good for yet, but php-gtk does it
      (php-object-property-set! php-obj "0" (convert-to-number *counter*))
      (set! *counter* (+ *counter* 1))))


(define (phpgtk-wrapper-destroy-notify::obj php-obj::obj)
   (debug-trace 3 "phpgtk-wrapper-destroy-notify called")
   (let ((props (get-custom-props php-obj)))
      (hashtable-remove! props 'gtkobject)
      (dereference php-obj)))
       

(define (gtk-object-init! php-obj gtk-obj)
   (debug-trace 3 "gtk-object-init! php: " php-obj ", gtk: " gtk-obj)
   [assert (gtk-obj) (subtype-of-GtkObject*? gtk-obj)]
   (cond
      ((foreign-null? gtk-obj)
       ;; this special failure value will cause a NULL to be returned
       ;; from make-php-object.
       (php-warning "Failed to create a " (php-object-class php-obj) " object.")
       +constructor-failed+)
      (else
       ;;add our reference to the object, so it won't be freed until we're done with it
       (debug-trace 3 "line0")
       (let ((gtk-obj (GTK_OBJECT gtk-obj)))
	  (debug-trace 3 "line1")
	  (gtk_object_ref gtk-obj)
	  (debug-trace 3 "line2")
	  ;;remove the floating reference that the object came with
	  (gtk_object_sink gtk-obj)
	  (debug-trace 3 "line3")
	  (gtk-object-set! php-obj gtk-obj)))))


(define (gtk-wrapper-new type::symbol gtk-obj)
   ;create wrappers for things that gtk's reflection doesn't cover
   (if (foreign-null? gtk-obj)
       (begin
	  (debug-trace 3 "foreign object was null")
	  NULL)
       (begin
	  (debug-trace 3 "gtk-wrapper-new type: " type " gtk-obj: " gtk-obj " hashnumber: " (gtkobj-hashnumber gtk-obj) " survey says: " (php-hash-lookup *other-gtk-wrappers* (gtkobj-hashnumber gtk-obj)))
	  (if (convert-to-boolean (php-hash-lookup *other-gtk-wrappers* (gtkobj-hashnumber gtk-obj)))
	      ;;there's a problem that this shit isn't being finalized out of the hashtable
	      ;;so we give back stale stuff, e.g. for events
	      (php-hash-lookup *other-gtk-wrappers* (gtkobj-hashnumber gtk-obj))
	      (let ((s (construct-php-object-sans-constructor type)))
		 (php-object-custom-properties-set! s (make-hashtable))
		 (case (symbol-downcase type)
		    ((gdkcolor) (let ((c::GdkColor* gtk-obj))
				   (gtk-object-set! s (pragma::GdkColor* "gdk_color_copy($1)" c))))
		    ((gdkevent) (let ((c::GdkEvent* gtk-obj))
				   (debug-trace 3 "about to call gdk-event-new")
				   (set! s (gdk-event-new c))
				   (debug-trace 3 "called gdk-event-new")))
		    (else (gtk-object-set! s gtk-obj)))
		 s)))))


(define (gtk-object-wrapper-new type gtk-obj)
   ;;create wrappers for objects, uses gtk's reflection to figure out the right type
   (if (foreign-null? gtk-obj)
       (begin
	  (debug-trace 3 "foreign object was null")
	  NULL)
       (begin
	  (debug-trace 3 "wasn't null: " gtk-obj)
	  (let ((wrapper (pragma::obj
			  "gtk_object_get_data(FOREIGN_TO_COBJ($1), $2)" gtk-obj +gtk-wrapper-key+)));(php-hash-lookup *other-gtk-wrappers* (gtkobj-hashnumber gtk-obj))))
	     (if (pragma::bool "$1 != 0" wrapper) ;(convert-to-boolean wrapper)
		 (begin
		    (debug-trace 3 "found a wrapper: php class: " (php-object-class wrapper) ", foreign-type: " gtk-obj)
		    wrapper)
		 (let* ((gtk-obj::GtkObject* (GTK_OBJECT gtk-obj))

			;; php-gtk uses:
; 	while ((ce = g_hash_table_lookup(php_gtk_class_hash, gtk_type_name(type))) == NULL)
; 		type = gtk_type_parent(type);
			
			(gtk-type (string->symbol (pragma::string "gtk_type_name(GTK_OBJECT_TYPE($1))" gtk-obj)))
;			(scheme-type (studly-to-dashes gtk-type))
			(scheme-type (symbol-append 'bs-_ gtk-type '*))
			(gtk-obj (my-coerce scheme-type gtk-obj)))
		    (debug-trace 3 "gtk-object-wrapper-new gtk-type: " gtk-type ", gtk-obj: " gtk-obj)
		    (let ((wrapper (construct-php-object-sans-constructor gtk-type)))
		       (gtk-object-set! wrapper gtk-obj)
		       ;; very important -- new wrapper means new reference
		       (gtk_object_ref (GTK_OBJECT gtk-obj))
		       wrapper)))))))


(define (gtk-boxed-alloc type php-obj)
   (set! php-obj (maybe-unbox php-obj))
   (case (string->symbol (string-downcase (mkstr type)))
      ((gdkrectangle)
       (let ((c::GdkRectangle* (pragma::GdkRectangle* "GC_MALLOC(sizeof(GdkRectangle))")))
	  (if (php-gdk-rectangle-get php-obj c)
	      c
	      (php-error "error creating GdkRectangle from object " php-obj))))
      (else
       (php-error "gtk-boxed-alloc can't yet handle type : " type))))




; 	  `(,(symbol-append name ':: (studly-to-dashes canon-type))
; 	    (if (php-null? (maybe-unbox ,name))
; 		(,(symbol-append 'pragma ':: (studly-to-dashes canon-type)) "NULL")
; 		(let (,(symbol-append 'wibble ':: (studly-to-dashes canon-type))
; 		      (,(symbol-append 'pragma ':: (studly-to-dashes canon-type))
; 		       ,(string-append "GC_MALLOC(sizeof(" (symbol->string canon-type)"))")))
; 		   (,(symbol-append 'php- (studly-to-dashes canon-type) '-get) ,name wibble)
; 		   wibble))))

(define (convert-to-php-type obj)
;   (print  "trying to convert " obj " to php type")
   (let ((retval
	  (cond
	     ((GdkEvent*? obj)
	      (let ((c::GdkEvent* obj)) (gdk-event-new c)))
	     ((subtype-of-GtkObject*? obj)
	      (gtk-object-wrapper-new #f obj))
	     ((GdkDragContext*? obj)
	      (gtk-wrapper-new 'GdkDragContext obj))
	     ((GtkSelectionData*? obj)
	      (gtk-wrapper-new 'GtkSelectionData obj))
	     ((number? obj)
	      (convert-to-number obj))
	     (else (debug-trace 3 "didn't know what type to select")
		   obj))))
      (unless (valid-php-type? retval)
	 (php-warning "unable to convert value " (with-output-to-string (lambda () (display-circle retval)))
		      " to valid PHP type."))
      retval))

; ;	  (let ((wrapper (gtk-object-get-data gtk-obj :key +gtk-wrapper-key+)))
; 	     (debug-trace 3 "not sure what the false value is: " wrapper)
; 	     (if wrapper
; 		 wrapper
; 		 (let ((s (construct-php-object-sans-constructor type)))
; 		    (php-object-custom-properties-set! s (make-hashtable))
; 		    (gtk-object-set! s gtk-obj)
; 		    s))))))

; (define (gtk-window php-obj)
;    (unless (equal? php-obj NULL)
;       (php-object-property (maybe-unbox php-obj) "window")))

; (define (gtk-window-set! php-obj gtk-obj)
;    (unless (equal? php-obj NULL)
;       (php-object-property-set! (maybe-unbox php-obj) "window" (maybe-unbox gtk-obj))))

;;;
;;; PCC-GTK Functions and Classes
;;; =============================


(define (gtkobj-hashnumber o)
   (debug-trace 3 "asdfasdfasdf")
   (let ((c::cobj o))
      (debug-trace 3 "bsdfasdfasdf")
      (pragma::elong "(long)$1" c)))

; (define (foo ipad_x ipad_y)
;    (gtk-button-box-set-child-ipadding-default (mkfixnum (maybe-unbox ipad_x))
; 					      (mkfixnum (maybe-unbox ipad_y))))


(define +too-many+ 20)
; (define (gtk-obj->php-class obj)
;    ;;this might not hold water, because the name correspondence might be weak, 
;    ;;but basically we're trying to lookup a php class definition with the same
;    ;;name as the gtk type
;    (let* ((obj::GtkObject* (pragma::GtkObject* "GTK_OBJECT(FOREIGN_TO_COBJ($1))" obj))
; 	  (type::int
; 	   (pragma::int "GTK_OBJECT_TYPE($1)" obj)))
;       (let loop ((i 0)
; 		 (type::int type))
; 	 (if (> i +too-many+)
; 	     ;;this is preferable to an infinite loop, in case that could happen
; 	     (error 'gtk-obj->php-class "unknown gtk type: "
; 		    (pragma::string "gtk_type_name(GTK_OBJECT_TYPE($1))" obj))
; 	     (let ((type-name (pragma::string "gtk_type_name($1)" type)))
; 		(debug-trace 3 "type-name is " type-name)
; 		(if (php-class-exists? type-name)
; 		    ;;success!
; 		    type-name
; 		    ;;if the class doesn't exist, try the parent type
; 		    (loop (+ i 1)
; 			  (pragma::int "gtk_type_parent($1)" type))))))))




;;;crud
(define (studly-to-underscores str) 
   (set! str (symbol->string str))
   (string->symbol
    (with-output-to-string
       (lambda ()
	  (let ((first-char? #t)
		(prev-was-caps? #t))
	     (let loop ((chars (string->list str)))
		(unless (null? chars)
		   (let ((char (car chars)))
		      (if first-char?
			  (begin (set! first-char? #f)
				 (display (char-downcase char))
				 (loop (cdr chars)))
			  (begin (if (char-upper-case? char)
				     (if prev-was-caps?
					 (display (char-downcase char))
					 (begin (set! prev-was-caps? #t)
						(display* #\_ (char-downcase char))))
				     (begin (set! prev-was-caps? #f)
					    (display char)))
				 (loop (cdr chars))))))))))))

(define (studly-to-dashes str) 
   (string->symbol (pregexp-replace "\*$" (symbol->string (underscores-to-dashes (studly-to-underscores str))) "")))

(define (underscores-to-dashes str) 
   (set! str (symbol->string str))
   (string->symbol
    (pregexp-replace* "_" str "-")))



(define (subtype-of-GtkObject*? obj)
   ;;doesn't this suck?
   (or
    (GtkObject*? obj)
;    (GtkStyle*? obj)
    (GtkWidget*? obj)
    (GtkMisc*? obj)
    (GtkLabel*? obj)
    (GtkAccelLabel*? obj)
    (GtkTipsQuery*? obj)
    (GtkArrow*? obj)
    (GtkImage*? obj)
    (GtkPixmap*? obj)
    (GtkContainer*? obj)
    (GtkBin*? obj)
    (GtkAlignment*? obj)
    (GtkFrame*? obj)
    (GtkAspectFrame*? obj)
    (GtkButton*? obj)
    (GtkToggleButton*? obj)
    (GtkCheckButton*? obj)
    (GtkRadioButton*? obj)
    (GtkOptionMenu*? obj)
    (GtkItem*? obj)
    (GtkMenuItem*? obj)
    (GtkCheckMenuItem*? obj)
    (GtkRadioMenuItem*? obj)
    (GtkTearoffMenuItem*? obj)
    (GtkListItem*? obj)
;    (GtkTreeItem*? obj)
    (GtkWindow*? obj)
    (GtkColorSelectionDialog*? obj)
    (GtkDialog*? obj)
    (GtkInputDialog*? obj)
    (GtkFileSelection*? obj)
    (GtkFontSelectionDialog*? obj)
    (GtkPlug*? obj)
    (GtkEventBox*? obj)
    (GtkHandleBox*? obj)
    (GtkScrolledWindow*? obj)
    (GtkViewport*? obj)
    (GtkBox*? obj)
    (GtkButtonBox*? obj)
    (GtkHButtonBox*? obj)
    (GtkVButtonBox*? obj)
    (GtkVBox*? obj)
    (GtkColorSelection*? obj)
    (GtkGammaCurve*? obj)
    (GtkHBox*? obj)
    (GtkCombo*? obj)
    (GtkStatusbar*? obj)
    (GtkCList*? obj)
    (GtkCTree*? obj)
    (GtkFixed*? obj)
    (GtkNotebook*? obj)
    (GtkFontSelection*? obj)
    (GtkPaned*? obj)
    (GtkHPaned*? obj)
    (GtkVPaned*? obj)
    (GtkLayout*? obj)
    (GtkList*? obj)
    (GtkMenuShell*? obj)
    (GtkMenu*? obj)
    (GtkMenuBar*? obj)
;    (GtkPacker*? obj)
    (GtkSocket*? obj)
    (GtkTable*? obj)
    (GtkToolbar*? obj)
;    (GtkTree*? obj)
    (GtkCalendar*? obj)
    (GtkDrawingArea*? obj)
    (GtkCurve*? obj)
    (GtkEditable*? obj)
    (GtkEntry*? obj)
    (GtkSpinButton*? obj)
;    (GtkText*? obj)
    (GtkRuler*? obj)
    (GtkHRuler*? obj)
    (GtkVRuler*? obj)
    (GtkRange*? obj)
    (GtkScale*? obj)
    (GtkHScale*? obj)
    (GtkVScale*? obj)
    (GtkScrollbar*? obj)
    (GtkHScrollbar*? obj)
    (GtkVScrollbar*? obj)
    (GtkSeparator*? obj)
    (GtkHSeparator*? obj)
    (GtkVSeparator*? obj)
;    (GtkInvisible*? obj)
    (GtkPreview*? obj)
    (GtkProgress*? obj)
    (GtkProgressBar*? obj)
;    (GtkData*? obj)
    (GtkAdjustment*? obj)
    (GtkTooltips*? obj)
    (GtkItemFactory*? obj)
;    (GtkScintilla*? obj)
    (GladeXML*? obj)))

(define (gtk-enum-value enum-type php-value)
   ;;; eventually, we can call gtk_type_enum_find_value here
   (set! php-value (maybe-unbox php-value))
   (cond
      ((or (fixnum? php-value)
	   (php-number? php-value))
       (mkfixnum php-value))
      (else
       (php-warning "Invalid value for enum of type " enum-type ": " php-value)
       0)))
       

(define (gtk-flag-value flag-type php-value)
   ;;; eventually, this should call gtk_type_flags_find_value in case
   ;;; of strings.  XXX also, I guess it would be nice if it verified
   ;;; that the flag is in range for the type.
   (set! php-value (maybe-unbox php-value))
   ;; hrnf... did you notice that you're writing that /everywhere?/
   (let ((one-flag-value
	  (lambda (flag)
	     (cond
		((or (fixnum? php-value)
		     (php-number? php-value)) (mkfixnum php-value))
		(else
		 (php-warning "Invalid value for flag of type " flag-type ": " php-value)
		 0)))))
      (if (php-hash? php-value)
	  (let ((result 0))
	     (php-hash-for-each php-value
		(lambda (k v)
		   (set! result (bit-or (one-flag-value v)
					result))))
	     result)
	  (one-flag-value php-value))))



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
(module php-gtk-style-lib
;   (include "../phpoo-extension.sch")
   (load (php-macros "../../../php-macros.scm"))
   (load (php-gtk-macros "php-gtk-macros.sch"))
;   (library "common")
   (import (gtk-binding "cigloo/gtk.scm"))
;   (library "bgtk")
   (library php-runtime)
   (import (php-gtk-common-lib "php-gtk-common.scm"))
   (export
    (init-php-gtk-style-lib)
    ))

(define (init-php-gtk-style-lib)
   1)

;;;
;;; GtkStyle
;;; ========

(def-ext-class (GtkStyle pcc-gtk)
   (lambda (obj prop ref? k)
      (let ((wrapped-obj (gtk-object obj)))
	 (if (not (and (foreign? wrapped-obj) (not (foreign-null? wrapped-obj))))
	     (k)
	     (let ((prop (string->symbol (mkstr prop)))
		   (props (php-object-custom-properties obj))
		   (this::GtkStyle* wrapped-obj))
		(case prop
		   ((black) (gtk-wrapper-new 'GdkColor
					     (pragma::GdkColor* "&($1->black)" this)))
		   ((white) (gtk-wrapper-new 'GdkColor
					     (pragma::GdkColor* "&($1->white)" this)))
		   ((font) (gtk-wrapper-new 'GdkFont
					    (pragma::GdkFont* "$1->font" this)))
		   ((black_gc) (gtk-wrapper-new 'GdkGC
						(pragma::GdkGC* "$1->black_gc" this)))
		   ((white_gc) (gtk-wrapper-new 'GdkGC
						(pragma::GdkGC* "$1->white_gc" this)))
		   ((colormap) (if (foreign-null? (pragma::GdkColormap* "$1->colormap" this))
				   NULL
				   (gtk-wrapper-new 'GdkColormap
						    (pragma::GdkColormap* "$1->colormap" this))))
		   ((fg) (make-custom-color-array (pragma::GdkColor* "$1->fg" this)))
		   ((bg) (make-custom-color-array (pragma::GdkColor* "$1->bg" this)))
		   ((light) (make-custom-color-array (pragma::GdkColor* "$1->light" this)))
		   ((dark) (make-custom-color-array (pragma::GdkColor* "$1->dark" this)))
		   ((mid) (make-custom-color-array (pragma::GdkColor* "$1->mid" this)))
		   ((text) (make-custom-color-array (pragma::GdkColor* "$1->text" this)))
		   ((base) (make-custom-color-array (pragma::GdkColor* "$1->base" this)))
		   ((fg_gc) (make-custom-gc-array (pragma::GdkGC* "$1->fg_gc" this)))
		   ((bg_gc) (make-custom-gc-array (pragma::GdkGC* "$1->bg_gc" this)))
		   ((light_gc) (make-custom-gc-array (pragma::GdkGC* "$1->light_gc" this)))
		   ((dark_gc) (make-custom-gc-array (pragma::GdkGC* "$1->dark_gc" this)))
		   ((mid_gc) (make-custom-gc-array (pragma::GdkGC* "$1->mid_gc" this)))
		   ((text_gc) (make-custom-gc-array (pragma::GdkGC* "$1->text_gc" this)))
		   ((base_gc) (make-custom-gc-array (pragma::GdkGC* "$1->base_gc" this)))
		   ((bg_pixmap) (make-custom-pixmap-array (pragma::GdkPixmap* "$1->bg_pixmap" this)))
		   (else (k)))))))
      (lambda (obj prop ref? value k)
	 (let ((wrapped-obj (gtk-object obj)))
	    (if (not (and (foreign? wrapped-obj) (not (foreign-null? wrapped-obj))))
		(k)
		(let ((prop (string->symbol (mkstr prop)))
		      (props (php-object-custom-properties obj))
		      (value (maybe-unbox value))
		      (this::GtkStyle* wrapped-obj))
		   (case prop
		      ((black) (if (php-object-is-a value 'GdkColor)
				   (let ((c::GdkColor* (gtk-object value)))
				      (pragma "$1->black = *$2" this c)
				      NULL)
				   (php-warning "black should be a GdkColor")))
		      ((white) (if (php-object-is-a value 'GdkColor)
				   (let ((c::GdkColor* (gtk-object value)))
				      (pragma "$1->white = *$2" this c)
				      NULL)
				   (php-warning "white should be a GdkColor")))
		      ((font) (if (php-object-is-a value 'GdkFont)
				  (let ((f::GdkFont* (gtk-object value)))
				     (pragma "{if ($1->font) {gdk_font_unref($1->font);} $1->font = gdk_font_ref($2);}"
					     this f)
				     NULL)
				  (php-warning "font should be a GdkFont")))
		      ((black_gc) (if (php-object-is-a value 'GdkGC)
				      (let ((f::GdkGC* (gtk-object value)))
					 (pragma "{if ($1->font) {gdk_gc_unref($1->black_gc);} $1->black_gc = gdk_gc_ref($2);}"
						 this f)
					 NULL)
				      (php-warning "black_gc should be a GdkGC")))
		      ((white_gc) (if (php-object-is-a value 'GdkGC)
				      (let ((f::GdkGC* (gtk-object value)))
					 (pragma "{if ($1->font) {gdk_gc_unref($1->white_gc);} $1->white_gc = gdk_gc_ref($2);}"
						 this f)
					 NULL)
				      (php-warning "white_gc should be a GdkGC")))
		      
		      ; 	       ((colormap) (if (foreign-null? (pragma::GdkColormap* "$1->colormap"))
		      ; 			       NULL
		      ; 			       (gtk-wrapper-new 'GdkColormap
		      ; 						(pragma::GdkColormap* "$1->colormap"))))
		      ; 	       ((fg) (make-custom-color-array (pragma::GdkColor* "$1->fg")))
		      ; 	       ((bg) (make-custom-color-array (pragma::GdkColor* "$1->bg")))
		      ; 	       ((light) (make-custom-color-array (pragma::GdkColor* "$1->light")))
		      ; 	       ((dark) (make-custom-color-array (pragma::GdkColor* "$1->dark")))
		      ; 	       ((mid) (make-custom-color-array (pragma::GdkColor* "$1->mid")))
		      ; 	       ((text) (make-custom-color-array (pragma::GdkColor* "$1->text")))
		      ; 	       ((base) (make-custom-color-array (pragma::GdkColor* "$1->base")))
		      ; 	       ((fg_gc) (make-custom-gc-array (pragma::GdkColor* "$1->fg_gc")))
		      ; 	       ((bg_gc) (make-custom-gc-array (pragma::GdkColor* "$1->bg_gc")))
		      ; 	       ((light_gc) (make-custom-gc-array (pragma::GdkColor* "$1->light_gc")))
		      ; 	       ((dark_gc) (make-custom-gc-array (pragma::GdkColor* "$1->dark_gc")))
		      ; 	       ((mid_gc) (make-custom-gc-array (pragma::GdkColor* "$1->mid_gc")))
		      ; 	       ((text_gc) (make-custom-gc-array (pragma::GdkColor* "$1->text_gc")))
		      ; 	       ((base_gc) (make-custom-gc-array (pragma::GdkColor* "$1->base_gc")))
		      ; 	       ((bg_pixmap) (make-custom-pixmap-array (pragma::GdkColor* "$1->bg_pixmap")))
		      (else (k)))))))
      (lambda (a) a))


(define (make-custom-color-array color)
   (make-custom-hash
    ;; read-single
    (lambda (key context) 
       (debug-trace 3  "trying to read-single a color array, key " key ", context " context))
    ;; write-single
    (lambda (key value context)
       (debug-trace 3  "trying to write-single a color array, key " key ", value " value ", context " context)
       (set! value (maybe-unbox value))
       (if (not (and (php-number? key) (onum-long? key)))
	   (php-warning "custom GdkColor arrays can only be indexed by integers")
	   (if (not (php-object-is-a value 'GdkColor))
	       (php-warning "can only assign a GdkColor")
	       (let ((c::GdkColor* color)
		     (new-c::GdkColor* (gtk-object value))
		     (key::int (mkfixnum key)))
		  (if (or (< key 0) (> key 4))
		      (php-warning "style index " key " out of range (0 to 4)")
		      (begin
			 (pragma "$1[$2] = *$3" c key new-c)
			 NULL)) ))))
    ;; read-entire
    (lambda (context) 
       (debug-trace 3  "trying to read-entire a color array, context " context))
    color))


(define (make-custom-gc-array gc)
   (make-custom-hash
    ;; read-single
    (lambda (key context)
       (debug-trace 3  "trying to read-single a gc array, key " key ", context " context)
;       (print "key is: " key)
       (if (not (and (php-number? key) (onum-long? key)))
	   (php-warning "custom GdkGC arrays can only be indexed by integers ")
	   (let ((c::GdkGC* gc)
		 (key::int (mkfixnum key)))
	      (if (or (< key 0) (> key 4))
		  (php-warning "style index " key " out of range (0 to 4)")
		  (gtk-wrapper-new 'gdkgc (pragma::GdkGC* "((GdkGC**)$1)[$2]" c key) )) )))
    ;; write-single
    (lambda (key value context)
       (debug-trace 3  "trying to write-single a gc array, key " key ", value " value ", context " context))
    ;; read-entire
    (lambda (context) 
       (debug-trace 3  "trying to read-entire a gc array, context " context))
    gc))

(define (make-custom-pixmap-array pixmap)
   (make-custom-hash
    ;; read-single
    (lambda (key context) 
       (debug-trace 3  "trying to read-single a gc array, key " key ", context " context))
    ;; write-single
    (lambda (key value context)
       (debug-trace 3  "trying to write-single a gc array, key " key ", value " value ", context " context))
    ;; read-entire
    (lambda (context) 
       (debug-trace 3  "trying to read-entire a gc array, context " context))
    pixmap))
	


(def-pgtk-methods GtkStyle gtk_style
   (apply_default_background (window :gtk-type GdkWindow*) (set_bg :gtk-type gboolean) (state_type :gtk-type GtkStateType) (area :gtk-type GdkRectangle*) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   (set_background (window :gtk-type GdkWindow*) (state_type :gtk-type GtkStateType))
   (unref)
   ((ref :return-type GtkStyle*))
   (detach)
   ((attach :return-type GtkStyle*) (window :gtk-type GdkWindow*))
   ((copy :return-type GtkStyle*))
   )

;;; GtkStyle->GtkStyle
(defmethod GtkStyle (GtkStyle)
   (gtk-object-set! $this (gtk_style_new)))


; ;;; GtkStyle->ref
; (defmethod GtkStyle (ref)
;    (let ((ret (gtk-style-ref (gtk-object $this))))
;       (convert-to-php-type 'gtkstyle ret)))

; ;;; GtkStyle->unref
; (defmethod GtkStyle (unref)
;    (let ((ret (gtk-style-unref (gtk-object $this))))
;       (convert-to-php-type 'void ret)))

; ;;; GtkStyle->attach
; (defmethod GtkStyle (attach window)
;    (set! window (convert-to-scheme-type 'gdkwindow window))
;    (let ((ret (gtk-style-attach (gtk-object $this) window)))
;       (convert-to-php-type 'gtkstyle ret)))

; (def-property-getter (gtk-style-custom-lookup obj prop ref? k) GtkStyle
   
;    (xalign gfloat)
;    (yalign gfloat)
;    (xpad guint16)
;    (ypad guint16)
;    )
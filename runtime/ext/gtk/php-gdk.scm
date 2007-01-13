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
(module php-gdk-lib
;   (include "../phpoo-extension.sch")
   (load (php-macros "../../../php-macros.scm"))
   (load (php-gtk-macros "php-gtk-macros.sch"))
;   (import (gtk-foreign-types "gtk-foreign-types.scm"))
;   (library "common")
   (import (gtk-binding "cigloo/gtk.scm"))
;   (library "bgtk")
   (library php-runtime)
   (import (php-gtk-common-lib "php-gtk-common.scm"))
   (import (gdk-enums-lib "gdk-enums.scm"))
   (export
    (init-php-gdk-lib)
    (gdk-event-new event)
    (php-gdk-rectangle-get wrapper wrecktangle)
    (php-gdk-atom-get php-gdk-atom)
    (php-gdk-atom-new atom)
    ))
	  
;;;
;;; Module Init
;;; ===========

(define (init-php-gdk-lib)
   1)

;;;
;;; GDK Functions and Classes
;;; =========================

;;
;; GDK static methods
;; ==================

(defclass Gdk); pcc-gtk))

(def-static-methods Gdk gdk
   ((gdk_get_display :return-type gchar* :c-name gdk_get_display))
   (input_remove (tag :gtk-type gint))
   ((gdk_pointer_grab :return-type gint :c-name gdk_pointer_grab) (window :gtk-type GdkWindow*) (owner_events :gtk-type gint) (event_mask :gtk-type GdkEventMask) (confine_to :gtk-type GdkWindow* :null-ok #t) (cursor :gtk-type GdkCursor* :null-ok #t) (time :gtk-type guint32))
   ((gdk_pointer_ungrab :c-name gdk_pointer_ungrab) (time :gtk-type guint32))
   ((gdk_keyboard_grab :return-type gint :c-name gdk_keyboard_grab) (window :gtk-type GdkWindow*) (owner_events :gtk-type gboolean) (time :gtk-type guint32))
   ((gdk_keyboard_ungrab :c-name gdk_keyboard_ungrab) (time :gtk-type guint32))
   ((pointer_is_grabbed :return-type gboolean))
   ((screen_width :return-type gint))
   ((screen_height :return-type gint))
   ((screen_width_mm :return-type gint))
   ((screen_height_mm :return-type gint))
   (flush)
   (beep)
   ((visual_get_system :return-type GdkVisual*))
   ((visual_get_best :return-type GdkVisual*))
   ((visual_get_best_with_depth :return-type GdkVisual*) (depth :gtk-type gint))
   ((visual_get_best_with_type :return-type GdkVisual*) (visual_type :gtk-type GdkVisualType))
   ((visual_get_best_with_both :return-type GdkVisual*) (depth :gtk-type gint) (visual_type :gtk-type GdkVisualType))
   ((gdk_drag_status :c-name gdk_drag_status) (context :gtk-type GdkDragContext*) (action :gtk-type GdkDragAction) (time :gtk-type guint32))
   ((cursor_new :return-type GdkCursor*) (cursor_type :gtk-type GdkCursorType))
   ((cursor_new_from_pixmap :return-type GdkCursor*) (source :gtk-type GdkPixmap*) (mask :gtk-type GdkBitmap*) (fg :gtk-type GdkColor*) (bg :gtk-type GdkColor*) (x :gtk-type gint) (y :gtk-type gint))
   ((pixmap_new :return-type GdkPixmap*) (window :gtk-type GdkWindow*) (width :gtk-type gint) (height :gtk-type gint) (depth :gtk-type gint))
;   ((pixmap_create_from_xpm :return-type GdkPixmap*) (window :gtk-type GdkWindow*) (mask :gtk-type GdkBitmap**) (transparent_color :gtk-type GdkColor*) (filename :gtk-type const-gchar*))
   ((pixmap_colormap_create_from_xpm :return-type GdkPixmap*) (window :gtk-type GdkWindow*) (colormap :gtk-type GdkColormap*) (mask :gtk-type GdkBitmap**) (transparent_color :gtk-type GdkColor*) (filename :gtk-type const-gchar*))
;   ((pixmap_create_from_xpm_d :return-type GdkPixmap*) (window :gtk-type GdkWindow*) (mask :gtk-type GdkBitmap**) (transparent_color :gtk-type GdkColor*) (data :gtk-type gchar**))
   ((pixmap_colormap_create_from_xpm_d :return-type GdkPixmap*) (window :gtk-type GdkWindow*) (colormap :gtk-type GdkColormap*) (mask :gtk-type GdkBitmap**) (transparent_color :gtk-type GdkColor*) (data :gtk-type gchar**))
   ((colormap_new :return-type GdkColormap*) (visual :gtk-type GdkVisual*) (allocate :gtk-type gboolean))
   ((colormap_get_system :return-type GdkColormap*))
   ((colormap_get_system_size :return-type gint))
   ((gdk_color_parse :return-type gboolean :c-name gdk_color_parse) (spec :gtk-type const-gchar*) (color :gtk-type GdkColor*))
   ((font_load :return-type GdkFont*) (font_name :gtk-type const-gchar*))
   ((fontset_load :return-type GdkFont*) (fontset_name :gtk-type const-gchar*))
   (draw_point (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint))
   (draw_line (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (x1 :gtk-type gint) (y1 :gtk-type gint) (x2 :gtk-type gint) (y2 :gtk-type gint))
   (draw_rectangle (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (filled :gtk-type gint) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   (draw_arc (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (filled :gtk-type gint) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint) (angle1 :gtk-type gint) (angle2 :gtk-type gint))
   (draw_polygon (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (filled :gtk-type gint) (points :gtk-type GdkPoint*) (npoints :gtk-type gint))
   (draw_string (drawable :gtk-type GdkDrawable*) (font :gtk-type GdkFont*) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (string :gtk-type const-gchar*))
   (draw_text (drawable :gtk-type GdkDrawable*) (font :gtk-type GdkFont*) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (text :gtk-type const-gchar*) (text_length :gtk-type gint))
   (draw_text_wc (drawable :gtk-type GdkDrawable*) (font :gtk-type GdkFont*) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (text :gtk-type const-GdkWChar*) (text_length :gtk-type gint))
   (draw_pixmap (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (src :gtk-type GdkDrawable*) (xsrc :gtk-type gint) (ysrc :gtk-type gint) (xdest :gtk-type gint) (ydest :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   (draw_image (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (image :gtk-type GdkImage*) (xsrc :gtk-type gint) (ysrc :gtk-type gint) (xdest :gtk-type gint) (ydest :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   (draw_points (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (points :gtk-type GdkPoint*) (npoints :gtk-type gint))
   (draw_segments (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (segs :gtk-type GdkSegment*) (nsegs :gtk-type gint))
   (draw_lines (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (points :gtk-type GdkPoint*) (npoints :gtk-type gint))
   ((atom_intern :return-type GdkAtom) (atom_name :gtk-type const-gchar*) (only_if_exists :gtk-type gint :default FALSE))
   (threads_enter)
   (threads_leave)
   ((rgb_xpixel_from_rgb :return-type gulong) (rgb :gtk-type guint32))
   (rgb_gc_set_foreground (gc :gtk-type GdkGC*) (rgb :gtk-type guint32))
   (rgb_gc_set_background (gc :gtk-type GdkGC*) (rgb :gtk-type guint32))
   (draw_rgb_image (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint) (dith :gtk-type GdkRgbDither) (rgb_buf :gtk-type guchar*) (rowstride :gtk-type gint))
   (draw_rgb_image_dithalign (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint) (dith :gtk-type GdkRgbDither) (rgb_buf :gtk-type guchar*) (rowstride :gtk-type gint) (xdith :gtk-type gint) (ydith :gtk-type gint))
   (draw_rgb_32_image (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint) (dith :gtk-type GdkRgbDither) (buf :gtk-type guchar*) (rowstride :gtk-type gint))
   (draw_gray_image (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint) (dith :gtk-type GdkRgbDither) (buf :gtk-type guchar*) (rowstride :gtk-type gint))
   ((rgb_get_cmap :return-type GdkColormap*))
   ((rgb_get_visual :return-type GdkVisual*))
   )


(def-static-method gdk (pixmap_create_from_xpm window transparent-color filename)
   ;; return an array with indices starting at 0 of the pixmap and the mask
   (let ((new-gdkpixmap (construct-php-object-sans-constructor 'gdkpixmap))
	 (new-gdkbitmap (construct-php-object-sans-constructor 'gdkbitmap))
	 (retval (make-php-hash)))
      (multiple-value-bind (gdk-pixmap mask)
	 (gdk-pixmap-create-from-xpm (gtk-object window) (mkstr filename))
	 (debug-trace 3 "pixmap_create_from_xpm: pixmap is " gdk-pixmap
		      " bitmap is " mask)
	 (gtk-object-set! new-gdkpixmap gdk-pixmap)
	 (gtk-object-set! new-gdkbitmap mask)
	 (php-hash-insert! retval :next new-gdkpixmap)
	 (php-hash-insert! retval :next new-gdkbitmap)
	 retval)))

(def-static-method gdk (pixmap_create_from_xpm_d window transparent-color data)
   (debug-trace 3 "pixmap_create_from_xpm_d: window is " window)
   ;; return an array with indices starting at 0 of the pixmap and the mask
   (let ((new-gdkpixmap (construct-php-object-sans-constructor 'gdkpixmap))
	 (new-gdkbitmap (construct-php-object-sans-constructor 'gdkbitmap))
	 (retval (make-php-hash)))
      (multiple-value-bind (gdk-pixmap mask) 
	 (gdk-pixmap-create-from-xpm (gtk-object window)
				     (php-hash->list (maybe-unbox data)))

	 (debug-trace 3 "pixmap_create_from_xpm_d: pixmap is " gdk-pixmap
		      " bitmap is " mask)
	 (gtk-object-set! new-gdkpixmap gdk-pixmap)
	 (gtk-object-set! new-gdkbitmap mask)
	 (php-hash-insert! retval :next new-gdkpixmap)
	 (php-hash-insert! retval :next new-gdkbitmap)
	 retval)))


(define (gdk-pixmap-create-from-xpm::GdkPixmap*
	 gdk-window::GdkWindow*
	 data)
;	 #!key
;	 transparent
;	 colormap)
   ;; We use gdk_pixmap_colormap_* because it takes all the options,
   ;; and just pass NULL for ones we don't want.  Data can be a list
   ;; of strings or single string. If it's a single string, it's used
   ;; as a filename.
   (let* ((transparent::GdkColor* ;(or transparent
				      (pragma::GdkColor* "NULL"));)
;	  (gdk-window::GdkWindow* w);(gtk-widget-window w))
	  (mask::GdkBitmap* (pragma::GdkBitmap* "NULL"))
	  (colormap::GdkColormap* ;(or colormap
				   (pragma::GdkColormap* "NULL"));)
				   
	  (pixmap::GdkPixmap*
	   (cond
	      ((pair? data)
	       ;; data is a list of strings -- the actual pixmap data
	       (let ((cdata::string* (string-list->string* data)))
		  (pragma::GdkPixmap*
		   "gdk_pixmap_colormap_create_from_xpm_d ($1, $2, &$3, $4, $5)"
		   gdk-window colormap mask transparent cdata)))
	      ((string? data)
	       ;; data is a filename
	       (let ((filename::string data))
		  (pragma::GdkPixmap*

		   "gdk_pixmap_colormap_create_from_xpm ($1, $2, &$3, $4, $5)"
		   gdk-window colormap mask transparent filename)))
	      (else
	       (error 'gdk-pixmap-create-from-xpm
		      "invalid data argument: must be filename or list of strings"
		      data)))))
      (when (pragma::bool "$1 == NULL" pixmap)
	 (error 'gdk-pixmap-create-from-xpm
		"cannot create pixmap from data" data))
      (values pixmap mask)))

 

;;
;; GdkAtom
;; =======


(defclass GdkAtom); pcc-gtk))

(define (php-gdk-atom-new atom)
   (debug-trace 3 "creating a gdk atom " atom)
   (let ((atom::GdkAtom atom)
	 (php-gdk-atom (construct-php-object-sans-constructor 'gdkatom)))
      (php-object-property-set! php-gdk-atom "atom" (convert-to-number atom))
      (let ((name::string (gdk_atom_name atom)))
	 (if (pragma::bool "$1" name)
	     (php-object-property-set! php-gdk-atom "string" name)
	     (php-object-property-set! php-gdk-atom "string" NULL)))
      php-gdk-atom))

(define (php-gdk-atom-get php-gdk-atom)
   (pragma::GdkAtom "$1" (onum->elong (php-object-property php-gdk-atom "atom"))))

;;; no methods

;;
;; GdkBitmap
;; =========

(defclass GdkBitmap); pcc-gtk))

(defmethod-XXX gdkbitmap (extents) TRUE)
(defmethod-XXX gdkbitmap (lock) TRUE)
(defmethod-XXX gdkbitmap (height) TRUE)
(defmethod-XXX gdkbitmap (width) TRUE)

;;
;; GdkColor
;; ========

(defclass GdkColor)

(defmethod gdkcolor (gdkcolor name-or-red #!optional green blue)
   (if green
       (gtk-object-set! $this (gdk-color-new (mkfixnum name-or-red)
					     (mkfixnum green)
					     (mkfixnum blue)))
       (let ((c (gdk-color-new 0 0 0)))
          (if (zero? (gdk_color_parse (mkstr name-or-red) c))
              (begin
                 (php-warning "could not parse color spec '" (mkstr name-or-red) "'")
                 +constructor-failed+)
              (gtk-object-set! $this c)))))


;;
;; GdkColormap
;; ===========

(defclass GdkColormap); pcc-gtk))

(defmethod-XXX gdkcolormap (size) TRUE)
(defmethod-XXX gdkcolormap (alloc) TRUE)

;;
;; GdkCursor
;; =========

(def-ext-class GdkCursor
   gdk-cursor-custom-lookup
   (lambda (obj prop ref? value k) (k))
   (lambda (a) a))

;;; XXX broken in the switch from bgtk
(def-property-getter (gdk-cursor-custom-lookup obj prop ref? k) GdkCursor
   (type :impl (convert-to-integer (let ((this::GdkCursor* (gtk-object obj)))
				      (pragma::int "$1->type" this))))
   (name :impl
	 (let ((this::GdkCursor* (gtk-object obj)))
	    (let loop ((vals::GtkEnumValue* (pragma::GtkEnumValue* "gtk_type_enum_get_values(GTK_TYPE_GDK_CURSOR_TYPE)")))
	       (if (pragma::bool "($1->value_name != NULL && $1->value != (unsigned)$2->type)" vals this)
		   ;;this is horrible, isn't it :)
		   ;;if you change the ++$1 to a $1++, it won't work anymore...
		   (loop (pragma::GtkEnumValue* "++$1" vals))
		   (if (pragma::bool "$1->value_nick" vals)
		       (pragma::string "$1->value_nick" vals)
		       "*unknown*"))))))

;;; no methods

;;
;; GdkDragContext
;; ==============

(defclass GdkDragContext
   (protocol (make-container '()))
   (is_source (make-container '()))
   (source_window (make-container '()))
   (dest_window (make-container '()))
   (targets (make-container '()))
   (actions (make-container '()))
   (suggested_action (make-container '()))
   (action (make-container '()))
   (start_time (make-container '())))

;;; no methods

;;
;; GdkEvent
;; ========

;it's lowercase in php-gtk
(defclass gdkevent); pcc-gtk))
;;; XXX figure out the event stuff, what properties etc.


(define *event-initializers* #f)

(define (gdk-event-new event)
   (debug-trace 3 "gdk-event-new event: " event)
   (let ((event::GdkEvent* event))
      (let ((event-type
	     (convert-to-integer
	      (pragma::int "$1->type" event))))
	 (debug-trace 3 "gdk-event-new event type: " (mkstr event-type))
	 (let ((php-gdk-event (construct-php-object-sans-constructor 'gdkevent)))
	    (gtk-object-set! php-gdk-event event)
	    (php-object-property-set! php-gdk-event "type" event-type)
	    (php-object-property-set!
	      php-gdk-event "window"
	      (if (pragma::bool "$1->any.window" event)
		  (gtk-wrapper-new 'gdkwindow
				   (pragma::GdkWindow* "$1->any.window" event))
		  NULL))
	    (php-object-property-set! php-gdk-event "send_event"
				      (pragma::bool "$1->any.send_event" event))
	    (ensure-event-initializers)
	    (let ((initializer (hashtable-get *event-initializers* (mkfixnum event-type))))
	       (unless (procedure? initializer)
		  (php-error "Unknown event type" event-type))
	       (initializer php-gdk-event event))
	    php-gdk-event))))

(define (ensure-event-initializers)
   (unless *event-initializers*
      (set! *event-initializers* (make-hashtable))
      (let ((register-initializer
	     (lambda (proc . types)
		(for-each (lambda (t)
			     (hashtable-put! *event-initializers* (mkfixnum t) proc))
			  types))))
	 ;; GDK_NOTHING
	 ;; GDK_DELETE
	 ;; GDK_DESTROY
	 (register-initializer (lambda (wrapper event) #t)
			       GDK_NOTHING GDK_DELETE GDK_DESTROY)
	 ;; GDK_EXPOSE
	 (register-initializer
	  (lambda (wrapper event)
	     (let ((event::GdkEvent* event))
		(php-object-property-set! wrapper "area"
					  (php-gdk-rectangle-new
					   (pragma::GdkRectangle* "&($1->expose.area)"
								  event)))
		(php-object-property-set! wrapper "count"
					  (convert-to-integer
					   (pragma::int "$1->expose.count" event)))))
	  GDK_EXPOSE)

	 ;; GDK_MOTION_NOTIFY
	 (register-initializer
	  (lambda (wrapper event)
	     (let ((event::GdkEvent* event))
		(php-object-property-set! wrapper "time"
					  (elong->onum
					   (pragma::elong "$1->motion.time" event)))
		(php-object-property-set! wrapper "x"
					  (convert-to-float
					   (pragma::double "$1->motion.x" event)))
		(php-object-property-set! wrapper "y"
					  (convert-to-float
					   (pragma::double "$1->motion.y" event)))
		(php-object-property-set! wrapper "pressure"
					  (convert-to-float
					   (pragma::double "$1->motion.pressure" event)))
		(php-object-property-set! wrapper "xtilt"
					  (convert-to-float
					   (pragma::double "$1->motion.xtilt" event)))
		(php-object-property-set! wrapper "ytilt"
					  (convert-to-float
					   (pragma::double "$1->motion.ytilt" event)))
		(php-object-property-set! wrapper "state"
					  (convert-to-integer
					   (pragma::int "$1->motion.state" event)))
		(php-object-property-set! wrapper "is_hint"
					  (convert-to-boolean
					   (pragma::bool "$1->motion.is_hint" event)))
		(php-object-property-set! wrapper "source"
					  (convert-to-integer
					   (pragma::int "$1->motion.source" event)))
		(php-object-property-set! wrapper "deviceid"
					  (convert-to-integer
					   (pragma::int "$1->motion.deviceid" event)))
		(php-object-property-set! wrapper "x_root"
					  (convert-to-float
					   (pragma::double "$1->motion.x_root" event)))
		(php-object-property-set! wrapper "y_root"
					  (convert-to-float
					   (pragma::double "$1->motion.y_root" event)))))
	  GDK_MOTION_NOTIFY)

	 ;; GDK_BUTTON_PRESS
	 ;; GDK_2BUTTON_PRESS
	 ;; GDK_3BUTTON_PRESS
	 ;; GDK_BUTTON_RELEASE
	 (register-initializer
	  (lambda (wrapper event)
	     (let ((event::GdkEvent* event))
		(php-object-property-set! wrapper "time"
					  (elong->onum
					   (pragma::elong "$1->button.time" event)))
		(php-object-property-set! wrapper "x"
					  (convert-to-float
					   (pragma::double "$1->button.x" event)))
		(php-object-property-set! wrapper "y"
					  (convert-to-float
					   (pragma::double "$1->button.y" event)))
		(php-object-property-set! wrapper "pressure"
					  (convert-to-float
					   (pragma::double "$1->button.pressure" event)))
		(php-object-property-set! wrapper "xtilt"
					  (convert-to-float
					   (pragma::double "$1->button.xtilt" event)))
		(php-object-property-set! wrapper "ytilt"
					  (convert-to-float
					   (pragma::double "$1->button.ytilt" event)))
		(php-object-property-set! wrapper "state"
					  (convert-to-integer
					   (pragma::int "$1->button.state" event)))
		(php-object-property-set! wrapper "button"
					  (convert-to-integer
					   (pragma::int "$1->button.button" event)))
		(php-object-property-set! wrapper "source"
					  (convert-to-integer
					   (pragma::int "$1->button.source" event)))
		(php-object-property-set! wrapper "deviceid"
					  (convert-to-integer
					   (pragma::int "$1->button.deviceid" event)))
		(php-object-property-set! wrapper "x_root"
					  (convert-to-float
					   (pragma::double "$1->button.x_root" event)))
		(php-object-property-set! wrapper "y_root"
					  (convert-to-float
					   (pragma::double "$1->button.y_root" event)))))
	  GDK_BUTTON_PRESS
	  GDK_2BUTTON_PRESS
	  GDK_3BUTTON_PRESS
	  GDK_BUTTON_RELEASE)

	 ;; GDK_KEY_PRESS
	 ;; GDK_KEY_RELEASE
	 (register-initializer
	  (lambda (wrapper event)
	     (let ((event::GdkEvent* event))
		(php-object-property-set! wrapper "time"
					  (elong->onum
					   (pragma::elong "$1->key.time" event)))
		(php-object-property-set! wrapper "state"
					  (convert-to-integer
					   (pragma::int "$1->key.state" event)))
		(php-object-property-set! wrapper "keyval"
					  (convert-to-integer
					   (pragma::int "$1->key.keyval" event)))
		(php-object-property-set!
		 wrapper "string"
		 ;;XXX verify that string_to_bstring_len is allocating a fresh string
		 (pragma::bstring "string_to_bstring_len($1->key.string, $1->key.length)"
				  event))))
	  GDK_KEY_PRESS
	  GDK_KEY_RELEASE)

	 ;; GDK_ENTER_NOTIFY:
	 ;; GDK_LEAVE_NOTIFY:
	 (register-initializer
	  (lambda (wrapper event)
	     (let ((event::GdkEvent* event))
		(php-object-property-set! wrapper "time"
					  (elong->onum
					   (pragma::elong "$1->crossing.time" event)))
		(php-object-property-set! wrapper "x"
					  (convert-to-float
					   (pragma::double "$1->crossing.x" event)))
		(php-object-property-set! wrapper "y"
					  (convert-to-float
					   (pragma::double "$1->crossing.y" event)))
		(php-object-property-set! wrapper "x_root"
					  (convert-to-float
					   (pragma::double "$1->crossing.x_root" event)))
		(php-object-property-set! wrapper "y_root"
					  (convert-to-float
					   (pragma::double "$1->crossing.y_root" event)))
		(php-object-property-set! wrapper "mode"
					  (convert-to-integer
					   (pragma::int "$1->crossing.mode" event)))
		(php-object-property-set! wrapper "detail"
					  (convert-to-integer
					   (pragma::int "$1->crossing.detail" event)))
		(php-object-property-set! wrapper "focus"
					  (convert-to-boolean
					   (pragma::bool "$1->crossing.focus" event)))
		(php-object-property-set! wrapper "state"
					  (convert-to-integer
					   (pragma::int "$1->crossing.state" event)))))

	  GDK_ENTER_NOTIFY
	  GDK_LEAVE_NOTIFY)

	 ;; GDK_FOCUS_CHANGE
	 (register-initializer
	  (lambda (wrapper event)
	     (let ((event::GdkEvent* event))
		(php-object-property-set! wrapper "in"
					  (convert-to-boolean
					   (pragma::bool "$1->focus_change.in" event)))))

	  GDK_FOCUS_CHANGE)

	 ;; GDK_CONFIGURE
	 (register-initializer
	  (lambda (wrapper event)
	     (let ((event::GdkEvent* event))
		(php-object-property-set! wrapper "x"
					  (convert-to-float
					   (pragma::double "$1->configure.x" event)))
		(php-object-property-set! wrapper "y"
					  (convert-to-float
					   (pragma::double "$1->configure.y" event)))
		(php-object-property-set! wrapper "width"
					  (convert-to-float
					   (pragma::double "$1->configure.width" event)))
		(php-object-property-set! wrapper "height"
					  (convert-to-float
					   (pragma::double "$1->configure.height" event)))))

	  GDK_CONFIGURE)


	 ;; GDK_MAP
	 ;; GDK_UNMAP
	 (register-initializer (lambda (wrapper event) #t) GDK_MAP GDK_UNMAP)

	 ;; GDK_PROPERTY_NOTIFY
	 (register-initializer
	  (lambda (wrapper event)
	     (let ((event::GdkEvent* event))
		(php-object-property-set! wrapper "atom"
					  (gtk-wrapper-new
					   'gdkatom
					   (pragma::GdkAtom* "$1->property.atom" event)))
		(php-object-property-set! wrapper "time"
					  (elong->onum
					   (pragma::elong "$1->property.time" event)))
		(php-object-property-set! wrapper "state"
					  (convert-to-integer
					   (pragma::int "$1->property.state" event)))))

	  GDK_PROPERTY_NOTIFY)

	 ;; GDK_SELECTION_CLEAR
	 ;; GDK_SELECTION_REQUEST
	 ;; GDK_SELECTION_NOTIFY
	 (register-initializer
	  (lambda (wrapper event)
	     (let ((event::GdkEvent* event))
		(php-object-property-set! wrapper "selection"
					  (gtk-wrapper-new
					   'gdkatom
					   (pragma::GdkAtom* "$1->selection.selection" event)))
		(php-object-property-set! wrapper "target"
					  (gtk-wrapper-new
					   'gdkatom
					   (pragma::GdkAtom* "$1->selection.target" event)))
		(php-object-property-set! wrapper "property"
					  (gtk-wrapper-new
					   'gdkatom
					   (pragma::GdkAtom* "$1->selection.property" event)))
		(php-object-property-set! wrapper "requestor"
					  (convert-to-integer
					   (pragma::int "$1->selection.requestor" event)))
		(php-object-property-set! wrapper "time"
					  (elong->onum
					   (pragma::elong "$1->selection.time" event)))))

	  GDK_SELECTION_CLEAR
	  GDK_SELECTION_REQUEST
	  GDK_SELECTION_NOTIFY)

	 ;; GDK_PROXIMITY_IN
	 ;; GDK_PROXIMITY_OUT
	 (register-initializer
	  (lambda (wrapper event)
	     (let ((event::GdkEvent* event))		
		(php-object-property-set! wrapper "time"
					  (elong->onum
					   (pragma::elong "$1->proximity.time" event)))
		(php-object-property-set! wrapper "source"
					  (convert-to-integer
					   (pragma::int "$1->proximity.source" event)))
		(php-object-property-set! wrapper "deviceid"
					  (convert-to-integer
					   (pragma::int "$1->proximity.deviceid" event)))))
	  GDK_PROXIMITY_IN
	  GDK_PROXIMITY_OUT)

	 ;; GDK_DRAG_ENTER
	 ;; GDK_DRAG_LEAVE
	 ;; GDK_DRAG_MOTION
	 ;; GDK_DRAG_STATUS
	 ;; GDK_DROP_START
	 ;; GDK_DROP_FINISHED
	 (register-initializer
	  (lambda (wrapper event)
	     (let ((event::GdkEvent* event))
		(php-object-property-set! wrapper "context"
					  (gtk-wrapper-new
					   'gdkdragcontext
					   (pragma::GdkAtom* "$1->dnd.context" event)))
		(php-object-property-set! wrapper "time"
					  (elong->onum
					   (pragma::elong "$1->dnd.time" event)))
		(php-object-property-set! wrapper "x_root"
					  (convert-to-float
					   (pragma::double "$1->dnd.x_root" event)))
		(php-object-property-set! wrapper "y_root"
					  (convert-to-float
					   (pragma::double "$1->dnd.y_root" event)))))
	  
	  GDK_DRAG_ENTER
	  GDK_DRAG_LEAVE
	  GDK_DRAG_MOTION
	  GDK_DRAG_STATUS
	  GDK_DROP_START
	  GDK_DROP_FINISHED)

	 ;; GDK_CLIENT_EVENT
	 (register-initializer
	  (lambda (wrapper event)
	     (let ((event::GdkEvent* event))
		(php-object-property-set! wrapper "message_type"
					  (gtk-wrapper-new
					   'gdkatom
					   (pragma::GdkAtom* "$1->client.message_type" event)))
		(php-object-property-set! wrapper "data_format"
					  (convert-to-integer
					   (pragma::int "$1->client.data_format" event)))
		(php-object-property-set!
		 wrapper "data"
		 ;;XXX verify that string_to_bstring_len is allocating a fresh string
		 ;;XXX I don't know why it's "20".  I got it from php_gtk+_types.c
		 (pragma::bstring "string_to_bstring_len($1->client.data.b, 20)"
				  event))))
	  GDK_CLIENT_EVENT)

	 ;; GDK_VISIBILITY_NOTIFY
	 (register-initializer
	  (lambda (wrapper event)
	     (let ((event::GdkEvent*  event))
		(php-object-property-set! wrapper "state"
					  (convert-to-integer
					   (pragma::int "$1->visibility.state" event)))))
	  GDK_VISIBILITY_NOTIFY)

	 ;; GDK_NO_EXPOSE
	 (register-initializer (lambda (wrapper event) #t) GDK_MAP GDK_UNMAP))))
	 


	 

;;; no methods, yet

;;
;; GdkFont
;; =======

; (defclass (pcc-gdkfont pcc-gtk)
;    (name ""))

(defclass GdkFont ;pcc-gdkfont)
   (type (make-container '()))
   (ascent (make-container '()))
   (descent (make-container '())))

(defmethod-XXX gdkfont (extents) TRUE)
(defmethod-XXX gdkfont (measure) TRUE)
(defmethod-XXX gdkfont (height) TRUE)
(defmethod-XXX gdkfont (width) TRUE)

;;
;; GdkGC
;; =====

(defclass GdkGC) ; pcc-gtk)
;    (foreground (make-container '()))
;    (background (make-container '()))
;    (font (make-container '()))
;    (function (make-container '()))
;    (fill (make-container '()))
;    (tile (make-container '()))
;    (stipple (make-container '()))
;    (clip_mask (make-container '()))
;    (subwindow_mode (make-container '()))
;    (ts_x_origin (make-container '()))
;    (ts_y_origin (make-container '()))
;    (clip_x_origin (make-container '()))
;    (clip_y_origin (make-container '()))
;    (graphics_exposures (make-container '()))
;    (line_width (make-container '()))
;    (line_style (make-container '()))
;    (cap_style (make-container '()))
;    (join_style (make-container '())))

(defmethod-XXX gdkgc (set_dashes) TRUE)
   
;;
;; GdkPixmap
;; =========

(defclass GdkPixmap); pcc-gtk))

(defmethod gdkpixmap (gdkpixmap window width height #!optional (depth -1))
   (let ((window::GdkWindow* (gtk-object window))
	 (width::int (mkfixnum width))
	 (height::int (mkfixnum height))
	 (depth::int (mkfixnum depth)))
      (let ((pixmap (pragma::GdkPixmap* "gdk_pixmap_new($1, $2, $3, $4)"
					window width height depth)))
	 (gtk-object-set! $this pixmap))))


; (defmethod-XXX gdkpixmap (new_gc)
; ;   (new-gc $this)
;    TRUE)

; (defmethod-XXX gdkpixmap (property_get)
;    TRUE)

; (defmethod-XXX gdkpixmap (property_change)
;    TRUE)

; (defmethod-XXX gdkpixmap (property_delete)
;    TRUE)

;;
;; GdkVisual
;; =========

(defclass GdkVisual)
;    (type (make-container '()))
;    (depth (make-container '()))
;    (byte_order (make-container '()))
;    (colormap_size (make-container '()))
;    (bits_per_rgb (make-container '()))
;    (red_mask (make-container '()))
;    (red_shift (make-container '()))
;    (red_prec (make-container '()))
;    (green_mask (make-container '()))
;    (green_shift (make-container '()))
;    (green_prec (make-container '()))
;    (blue_mask (make-container '()))
;    (blue_shift (make-container '()))
;    (blue_prec (make-container '())))
   
;;; no methods

;;
;; GdkWindow
;; =========

(def-ext-class GdkWindow
   gdk-window-custom-lookup
   (lambda (obj prop ref? value k) (k))
   (lambda (a) a))

(def-property-getter (gdk-window-custom-lookup obj prop ref? k) GdkWindow
   (width :impl
	  (let ((x::int (pragma::int "0"))
		(this::GdkWindow* (gtk-object obj)))
	     (pragma "gdk_window_get_size($1, &$2, NULL)" this x)
	     (convert-to-integer x)))
   (height :impl (let ((y::int (pragma::int "0"))
		       (this::GdkWindow* (gtk-object obj)))
		    (pragma "gdk_window_get_size($1, NULL, &$2)" this y)
		    (convert-to-integer y))))
   ;XXX there are more of these...
   
(def-pgtk-methods GdkWindow gdk_window
   (raise)
   (lower)
   ;get_pointer has out params
   (set_cursor (cursor :gtk-type GdkCursor* :default NULL))
   ;new_gc is hairy
   ;property_get is hairy
   ;property_change is hairy
   ;property_delete is hairy
   (set_icon (icon_window :gtk-type GdkWindow*) (pixmap :gtk-type GdkPixmap*) (mask :gtk-type GdkBitmap*))
   (copy_area (gc :gtk-type GdkGC*) (x :gtk-type int) (y :gtk-type int) (src_window :gtk-type GdkDrawable*)
	      (src_x :gtk-type int) (src_y :gtk-type int) (width :gtk-type int) (height :gtk-type int)))

(defmethod gdkwindow (get_pointer)
   (let ((x::int (pragma::int "0"))
	 (y::int (pragma::int "0"))
	 (mask::int (pragma::int "0"))
	 (this::GdkWindow* (gtk-object $this)))
      (pragma "gdk_window_get_pointer($1, &$2, &$3, (GdkModifierType*)&$4)"
	      this x y mask)
      (list->php-hash (list (convert-to-integer x)
			    (convert-to-integer y)
			    (convert-to-integer mask)))))
   
;(defmethod gdkwindow (raise)
;   (gdk_window_raise (gtk-object $this)))

; (def-pgtk-methods GdkColor gdk_color
;    ((equal :return-type gboolean) (colorb :gtk-type const-GdkColor*))
;    ((hash :return-type guint) (colorb :gtk-type const-GdkColor*))
;    (free)
;    ((copy :return-type GdkColor*))
;    )

; (def-pgtk-methods GdkWindow gdk_window
;    (set_icon_name (name :gtk-type const-gchar*))
;    (set_icon (icon_window :gtk-type GdkWindow*) (pixmap :gtk-type GdkPixmap*) (mask :gtk-type GdkBitmap*))
;    )

; (def-pgtk-methods GdkAtom gdk_atom
;    ((name :return-type gchar*))
;    )

; (def-pgtk-methods GdkColormap gdk_colormap
;    ((get_visual :return-type GdkVisual*))
;    (free_colors (colors :gtk-type GdkColor*) (ncolors :gtk-type gint))
;    ((alloc_color :return-type gboolean) (color :gtk-type GdkColor*) (writeable :gtk-type gboolean) (best_match :gtk-type gboolean))
;    ((alloc_colors :return-type gint) (colors :gtk-type GdkColor*) (ncolors :gtk-type gint) (writeable :gtk-type gboolean) (best_match :gtk-type gboolean) (success :gtk-type gboolean*))
;    (change (ncolors :gtk-type gint))
;    (unref)
;    ((ref :return-type GdkColormap*))
;    )
(defclass GdkRectangle; pcc-gtk)
   x
   y
   width
   height)

(defmethod GdkRectangle (GdkRectangle x y width height)
   (php-object-property-set! $this "x" x)
   (php-object-property-set! $this "y" y)
   (php-object-property-set! $this "width" width)
   (php-object-property-set! $this "height" height))


(define (php-gdk-rectangle-get wrapper wrecktangle)
   ;; actually, this should somehow prevent things that want the
   ;; rectangle from continuing if they don't get one see the usage in
   ;; gen_gtk.c
   (let ((wrecktangle::GdkRectangle* wrecktangle)
	 (x::int (mkfixnum (php-object-property wrapper "x")))
	 (y::int (mkfixnum (php-object-property wrapper "y")))
	 (width::int (mkfixnum (php-object-property wrapper "width")))
	 (height::int (mkfixnum (php-object-property wrapper "height"))))
      (if (foreign-null? wrecktangle)
	  #f
	  (begin
	     (pragma "$1->x = $2" wrecktangle x)
	     (pragma "$1->y = $2" wrecktangle y)
	     (pragma "$1->width = $2" wrecktangle width)
	     (pragma "$1->height = $2" wrecktangle height)
	     #t))))
   

;;rectangle..  also see gtkallocation in custom-properties.scm
(define (php-gdk-rectangle-new obj::GdkRectangle*)
   (let ((obj::GdkRectangle* obj))
      (if (foreign-null? obj)
	  NULL
	  (let ((o (construct-php-object-sans-constructor 'GdkRectangle)))
	     (php-object-property-set! o "x" (convert-to-integer
					     (pragma::int "$1->x" obj)))
	     (php-object-property-set! o "y" (convert-to-integer
					     (pragma::int "$1->y" obj)))
	     (php-object-property-set! o "width" (convert-to-integer
					     (pragma::int "$1->width" obj)))
	     (php-object-property-set! o "height" (convert-to-integer
					     (pragma::int "$1->height" obj)))
	     o))))
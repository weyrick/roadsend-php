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

(def-static-methods Gdk gdk
   ((gdk_add_client_message_filter :return-type none :c-name gdk_add_client_message_filter) (message_type :gtk-type GdkAtom) (func :gtk-type GdkFilterFunc) (data :gtk-type gpointer))
   ((atom_intern :return-type GdkAtom) (atom_name :gtk-type gchar*) (only_if_exists :gtk-type gboolean))
   ((beep :return-type none))
   ((bitmap_create_from_data :return-type GdkBitmap*) (drawable :gtk-type GdkDrawable*) (data :gtk-type const-guchar*) (width :gtk-type gint) (height :gtk-type gint))
   ((gdk_color_new :return-type gdk_color_new :c-name GdkColor))
   ((colormap_get_system_size :return-type gint))
   ((gdk_colormap_get_type :return-type GType :c-name gdk_colormap_get_type))
   ((gdk_colormap_new :return-type gdk_colormap_new :c-name GdkColormap) (visual :gtk-type GdkVisual*) (allocate :gtk-type gboolean))
   ((cursor_new :return-type gdk_cursor_new :c-name GdkCursor) (cursor_type :gtk-type GdkCursorType))
   ((cursor_new_for_display :return-type gdk_cursor_new_for_display :c-name GdkCursor) (display :gtk-type GdkDisplay*) (cursor_type :gtk-type GdkCursorType))
   ((cursor_new_from_pixbuf :return-type gdk_cursor_new_from_pixbuf :c-name GdkCursor) (display :gtk-type GdkDisplay*) (source :gtk-type GdkPixbuf*) (x :gtk-type gint) (y :gtk-type gint))
   ((cursor_new_from_pixmap :return-type gdk_cursor_new_from_pixmap :c-name GdkCursor) (source :gtk-type GdkPixmap*) (mask :gtk-type GdkPixmap*) (fg :gtk-type GdkColor*) (bg :gtk-type GdkColor*) (x :gtk-type gint) (y :gtk-type gint))
   ((device_free_history :return-type none) (events :gtk-type GdkTimeCoord**) (n_events :gtk-type gint))
   ((device_get_core_pointer :return-type GdkDevice*))
   ((device_get_type :return-type GType))
   ((devices_list :return-type GList*))
   ((display_get_default :return-type GdkDisplay*))
   ((gdk_display_get_type :return-type GType :c-name gdk_display_get_type))
   ((display_manager_get :return-type GdkDisplayManager*))
   ((gdk_display_manager_get_type :return-type GType :c-name gdk_display_manager_get_type))
   ((gdk_display_open :return-type gdk_display_open :c-name GdkDisplay) (display_name :gtk-type const-gchar*))
   ((display_open_default_libgtk_only :return-type GdkDisplay*))
   ((drag_context_get_type :return-type GType))
   ((drag_context_new :return-type gdk_drag_context_new :c-name GdkDragContext))
   ((drag_get_protocol :return-type guint32) (xid :gtk-type guint32) (protocol :gtk-type GdkDragProtocol*))
   ((drag_get_protocol_for_display :return-type guint32) (display :gtk-type GdkDisplay*) (xid :gtk-type guint32) (protocol :gtk-type GdkDragProtocol*))
   ((gdk_draw_layout_line_with_colors :return-type none :c-name gdk_draw_layout_line_with_colors) (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (line :gtk-type PangoLayoutLine*) (foreground :gtk-type GdkColor*) (background :gtk-type GdkColor*))
   ((gdk_draw_layout_with_colors :return-type none :c-name gdk_draw_layout_with_colors) (drawable :gtk-type GdkDrawable*) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (layout :gtk-type PangoLayout*) (foreground :gtk-type GdkColor*) (background :gtk-type GdkColor*))
   ((gdk_drawable_get_type :return-type GType :c-name gdk_drawable_get_type))
   ((event_get :return-type GdkEvent*))
   ((event_get_graphics_expose :return-type GdkEvent*) (window :gtk-type GdkWindow*))
   ((gdk_event_get_type :return-type GType :c-name gdk_event_get_type))
   ((gdk_event_handler_set :return-type none :c-name gdk_event_handler_set) (func :gtk-type GdkEventFunc) (data :gtk-type gpointer) (notify :gtk-type GDestroyNotify))
   ((event_new :return-type gdk_event_new :c-name GdkEvent) (type :gtk-type GdkEventType))
   ((event_peek :return-type GdkEvent*))
   ((events_pending :return-type gboolean))
   ((flush :return-type none))
   ((font_from_description :return-type GdkFont*) (font_desc :gtk-type PangoFontDescription*))
   ((font_from_description_for_display :return-type GdkFont*) (display :gtk-type GdkDisplay*) (font_desc :gtk-type PangoFontDescription*))
   ((font_load :return-type gdk_font_load :c-name GdkFont) (font_name :gtk-type const-gchar*))
   ((font_load_for_display :return-type GdkFont*) (display :gtk-type GdkDisplay*) (font_name :gtk-type const-gchar*))
   ((fontset_load :return-type GdkFont*) (fontset_name :gtk-type const-gchar*))
   ((fontset_load_for_display :return-type GdkFont*) (display :gtk-type GdkDisplay*) (fontset_name :gtk-type const-gchar*))
   ((gdk_gc_get_type :return-type GType :c-name gdk_gc_get_type))
   ((gc_new :return-type gdk_gc_new :c-name GdkGC) (drawable :gtk-type GdkDrawable*))
   ((gc_new :return-type GdkGC* :c-name gdk_gc_new2) (drawable :gtk-type GdkDrawable*))
   ((get_default_root_window :return-type GdkWindow*))
   ((get_show_events :return-type gboolean))
   ((gdk_image_get_type :return-type GType :c-name gdk_image_get_type))
   ((gdk_image_new :return-type gdk_image_new :c-name GdkImage) (type :gtk-type GdkImageType) (visual :gtk-type GdkVisual*) (width :gtk-type gint) (height :gtk-type gint))
   ((keyboard_grab :return-type GdkGrabStatus) (window :gtk-type GdkWindow*) (owner_events :gtk-type gboolean) (time :gtk-type guint32))
   ((keyboard_ungrab :return-type none) (time :gtk-type guint32))
   ((keymap_get_default :return-type GdkKeymap*))
   ((keymap_get_for_display :return-type GdkKeymap*) (display :gtk-type GdkDisplay*))
   ((gdk_keymap_get_type :return-type GType :c-name gdk_keymap_get_type))
   ((keyval_convert_case :return-type none) (symbol :gtk-type guint) (lower :gtk-type guint*) (upper :gtk-type guint*))
   ((keyval_from_name :return-type guint) (keyval_name :gtk-type const-gchar*))
   ((keyval_is_lower :return-type gboolean) (keyval :gtk-type guint))
   ((keyval_is_upper :return-type gboolean) (keyval :gtk-type guint))
   ((keyval_name :return-type gchar*) (keyval :gtk-type guint))
   ((keyval_to_lower :return-type guint) (keyval :gtk-type guint))
   ((keyval_to_unicode :return-type guint32) (keyval :gtk-type guint))
   ((keyval_to_upper :return-type guint) (keyval :gtk-type guint))
   ((list_visuals :return-type GList*))
   ((gdk_pixbuf_animation_get_type :return-type GType :c-name gdk_pixbuf_animation_get_type))
   ((pixbuf_animation_iter_get_type :return-type GType))
   ((gdk_pixbuf_animation_new_from_file :return-type gdk_pixbuf_animation_new_from_file :c-name GdkPixbufAnimation) (filename :gtk-type const-char*) (error :gtk-type GError**))
   ((pixbuf_get_file_info :return-type GdkPixbufFormat*) (width :gtk-type gint*) (height :gtk-type gint*))
   ((pixbuf_get_formats :return-type GSList*))
   ((gdk_pixbuf_loader_get_type :return-type GType :c-name gdk_pixbuf_loader_get_type))
   ((gdk_pixbuf_loader_new :return-type GdkPixbufLoader* :c-name gdk_pixbuf_loader_new))
   ((pixbuf_loader_new_with_mime_type :return-type GdkPixbufLoader*) (mime_type :gtk-type const-char*) (error :gtk-type GError**))
   ((gdk_pixbuf_loader_new_with_type :return-type gdk_pixbuf_loader_new_with_type :c-name GdkPixbufLoader) (image_type :gtk-type const-char*) (error :gtk-type GError**))
   ((gdk_pixbuf_new :return-type gdk_pixbuf_new :c-name GdkPixbuf) (colorspace :gtk-type GdkColorspace) (has_alpha :gtk-type gboolean) (bits_per_sample :gtk-type int) (width :gtk-type int) (height :gtk-type int))
   ((pixbuf_new_from_array :return-type gdk_pixbuf_new_from_array :c-name GdkPixbuf) (array :gtk-type PyArrayObject*) (colorspace :gtk-type GdkColorspace) (bits_per_sample :gtk-type int))
   ((pixbuf_new_from_data :return-type gdk_pixbuf_new_from_data :c-name GdkPixbuf) (data :gtk-type const-guchar*) (colorspace :gtk-type GdkColorspace) (has_alpha :gtk-type gboolean) (bits_per_sample :gtk-type int) (width :gtk-type int) (height :gtk-type int) (rowstride :gtk-type int) (destroy_fn :gtk-type GdkPixbufDestroyNotify) (destroy_fn_data :gtk-type gpointer))
   ((pixbuf_new_from_file :return-type gdk_pixbuf_new_from_file :c-name GdkPixbuf) (filename :gtk-type const-char*) (error :gtk-type GError**))
   ((pixbuf_new_from_file_at_size :return-type gdk_pixbuf_new_from_file_at_size :c-name GdkPixbuf) (filename :gtk-type const-char*) (width :gtk-type int) (height :gtk-type int) (error :gtk-type GError**))
   ((pixbuf_new_from_inline :return-type gdk_pixbuf_new_from_inline :c-name GdkPixbuf) (data_length :gtk-type gint) (data :gtk-type const-guchar*) (copy_pixels :gtk-type gboolean) (error :gtk-type GError**))
   ((pixbuf_new_from_xpm_data :return-type gdk_pixbuf_new_from_xpm_data :c-name GdkPixbuf) (data :gtk-type const-char**))
   ((pixmap_colormap_create_from_xpm :return-type GdkPixmap*) (drawable :gtk-type GdkDrawable*) (colormap :gtk-type GdkColormap*) (mask :gtk-type GdkBitmap**) (transparent_color :gtk-type GdkColor*) (filename :gtk-type const-gchar*))
   ((pixmap_colormap_create_from_xpm_d :return-type GdkPixmap*) (drawable :gtk-type GdkDrawable*) (colormap :gtk-type GdkColormap*) (mask :gtk-type GdkBitmap**) (transparent_color :gtk-type GdkColor*) (data :gtk-type gchar**))
   ((pixmap_create_from_data :return-type GdkPixmap*) (drawable :gtk-type GdkDrawable*) (data :gtk-type const-guchar*) (width :gtk-type gint) (height :gtk-type gint) (depth :gtk-type gint) (fg :gtk-type GdkColor*) (bg :gtk-type GdkColor*))
   ((pixmap_create_from_xpm :return-type GdkPixmap*) (drawable :gtk-type GdkDrawable*) (mask :gtk-type GdkBitmap**) (transparent_color :gtk-type GdkColor*) (filename :gtk-type const-gchar*))
   ((pixmap_create_from_xpm_d :return-type GdkPixmap*) (drawable :gtk-type GdkDrawable*) (mask :gtk-type GdkBitmap**) (transparent_color :gtk-type GdkColor*) (data :gtk-type gchar**))
   ((pixmap_foreign_new :return-type #t) (anid :gtk-type GdkNativeWindow))
   ((pixmap_foreign_new_for_display :return-type #t) (display :gtk-type GdkDisplay*) (anid :gtk-type GdkNativeWindow))
   ((gdk_pixmap_get_type :return-type GType :c-name gdk_pixmap_get_type))
   ((pixmap_lookup :return-type GdkPixmap*) (anid :gtk-type GdkNativeWindow))
   ((pixmap_lookup_for_display :return-type GdkPixmap*) (display :gtk-type GdkDisplay*) (anid :gtk-type GdkNativeWindow))
   ((gdk_pixmap_new :return-type gdk_pixmap_new :c-name GdkPixmap) (drawable :gtk-type GdkDrawable*) (width :gtk-type gint) (height :gtk-type gint) (depth :gtk-type gint))
   ((pointer_grab :return-type GdkGrabStatus) (window :gtk-type GdkWindow*) (owner_events :gtk-type gboolean) (event_mask :gtk-type GdkEventMask) (confine_to :gtk-type GdkWindow*) (cursor :gtk-type GdkCursor*) (time :gtk-type guint32))
   ((pointer_is_grabbed :return-type gboolean))
   ((pointer_ungrab :return-type none) (time :gtk-type guint32))
   ((query_depths :return-type none) (depths :gtk-type gint**) (count :gtk-type gint*))
   ((query_visual_types :return-type none) (visual_types :gtk-type GdkVisualType**) (count :gtk-type gint*))
   ((gdk_rectangle_new :return-type gdk_rectangle_new :c-name GdkRectangle))
   ((rgb_cmap_new :return-type GdkRgbCmap*) (colors :gtk-type guint32*) (n_colors :gtk-type gint))
   ((rgb_ditherable :return-type gboolean))
   ((rgb_gc_set_background :return-type none) (gc :gtk-type GdkGC*) (rgb :gtk-type guint32))
   ((rgb_gc_set_foreground :return-type none) (gc :gtk-type GdkGC*) (rgb :gtk-type guint32))
   ((rgb_get_cmap :return-type GdkColormap*))
   ((rgb_get_colormap :return-type GdkColormap*))
   ((rgb_get_visual :return-type GdkVisual*))
   ((rgb_set_install :return-type none) (install :gtk-type gboolean))
   ((rgb_set_min_colors :return-type none) (min_colors :gtk-type gint))
   ((rgb_set_verbose :return-type none) (verbose :gtk-type gboolean))
   ((rgb_xpixel_from_rgb :return-type gulong) (rgb :gtk-type guint32))
   ((screen_get_default :return-type GdkScreen*))
   ((gdk_screen_get_type :return-type GType :c-name gdk_screen_get_type))
   ((screen_height :return-type gint))
   ((screen_height_mm :return-type gint))
   ((screen_width :return-type gint))
   ((screen_width_mm :return-type gint))
   ((selection_owner_get :return-type GdkWindow*) (selection :gtk-type GdkAtom))
   ((selection_owner_get_for_display :return-type GdkWindow*) (display :gtk-type GdkDisplay*) (selection :gtk-type GdkAtom))
   ((selection_owner_set :return-type gboolean) (owner :gtk-type GdkWindow*) (selection :gtk-type GdkAtom) (time :gtk-type guint32) (send_event :gtk-type gboolean))
   ((selection_owner_set_for_display :return-type gboolean) (display :gtk-type GdkDisplay*) (owner :gtk-type GdkWindow*) (selection :gtk-type GdkAtom) (time :gtk-type guint32) (send_event :gtk-type gboolean))
   ((selection_send_notify :return-type none) (requestor :gtk-type guint32) (selection :gtk-type GdkAtom) (target :gtk-type GdkAtom) (property :gtk-type GdkAtom) (time :gtk-type guint32))
   ((selection_send_notify_for_display :return-type none) (display :gtk-type GdkDisplay*) (requestor :gtk-type guint32) (selection :gtk-type GdkAtom) (target :gtk-type GdkAtom) (property :gtk-type GdkAtom) (time :gtk-type guint32))
   ((set_double_click_time :return-type none) (msec :gtk-type guint))
   ((gdk_set_pointer_hooks :return-type GdkPointerHooks* :c-name gdk_set_pointer_hooks) (new_hooks :gtk-type const-GdkPointerHooks*))
   ((set_show_events :return-type none) (show_events :gtk-type gboolean))
   ((set_sm_client_id :return-type none) (sm_client_id :gtk-type const-gchar*))
   ((setting_get :return-type gboolean) (name :gtk-type const-gchar*) (value :gtk-type GValue*))
   ((threads_enter :return-type none))
   ((threads_init :return-type none))
   ((threads_leave :return-type none))
   ((unicode_to_keyval :return-type guint) (wc :gtk-type guint32))
   ((visual_get_best :return-type GdkVisual*))
   ((visual_get_best_depth :return-type gint))
   ((visual_get_best_type :return-type GdkVisualType))
   ((visual_get_best_with_both :return-type gdk_visual_get_best_with_both :c-name GdkVisual) (depth :gtk-type gint) (visual_type :gtk-type GdkVisualType))
   ((visual_get_best_with_depth :return-type GdkVisual*) (depth :gtk-type gint))
   ((visual_get_best_with_type :return-type GdkVisual*) (visual_type :gtk-type GdkVisualType))
   ((visual_get_system :return-type GdkVisual*))
   ((gdk_window_constrain_size :return-type none :c-name gdk_window_constrain_size) (geometry :gtk-type GdkGeometry*) (flags :gtk-type guint) (width :gtk-type gint) (height :gtk-type gint) (new_width :gtk-type gint*) (new_height :gtk-type gint*))
   ((window_foreign_new :return-type #t) (anid :gtk-type GdkNativeWindow))
   ((window_foreign_new_for_display :return-type #t) (display :gtk-type GdkDisplay*) (anid :gtk-type GdkNativeWindow))
   ((window_lookup :return-type GdkWindow*) (anid :gtk-type GdkNativeWindow))
   ((window_lookup_for_display :return-type GdkWindow*) (display :gtk-type GdkDisplay*) (anid :gtk-type GdkNativeWindow))
   ((new :return-type gdk_window_new :c-name GdkWindow) (parent :gtk-type GdkWindow*) (attributes :gtk-type GdkWindowAttr*) (attributes_mask :gtk-type gint))
   ((gdk_window_object_get_type :return-type GType :c-name gdk_window_object_get_type))
   ((window_process_all_updates :return-type none))
   ((gdk_window_set_debug_updates :return-type none :c-name gdk_window_set_debug_updates) (setting :gtk-type gboolean))
   )


; (def-static-method gdk (pixmap_create_from_xpm window transparent-color filename)
;    ;; return an array with indices starting at 0 of the pixmap and the mask
;    (let ((new-gdkpixmap (construct-php-object-sans-constructor 'gdkpixmap))
; 	 (new-gdkbitmap (construct-php-object-sans-constructor 'gdkbitmap))
; 	 (retval (make-php-hash)))
;       (multiple-value-bind (gdk-pixmap mask)
; 	 (gdk-pixmap-create-from-xpm (gtk-object window) (mkstr filename))
; 	 (debug-trace 3 "pixmap_create_from_xpm: pixmap is " gdk-pixmap
; 		      " bitmap is " mask)
; 	 (gtk-object-set! new-gdkpixmap gdk-pixmap)
; 	 (gtk-object-set! new-gdkbitmap mask)
; 	 (php-hash-insert! retval :next new-gdkpixmap)
; 	 (php-hash-insert! retval :next new-gdkbitmap)
; 	 retval)))

; (def-static-method gdk (pixmap_create_from_xpm_d window transparent-color data)
;    (debug-trace 3 "pixmap_create_from_xpm_d: window is " window)
;    ;; return an array with indices starting at 0 of the pixmap and the mask
;    (let ((new-gdkpixmap (construct-php-object-sans-constructor 'gdkpixmap))
; 	 (new-gdkbitmap (construct-php-object-sans-constructor 'gdkbitmap))
; 	 (retval (make-php-hash)))
;       (multiple-value-bind (gdk-pixmap mask) 
; 	 (gdk-pixmap-create-from-xpm (gtk-object window)
; 				     (php-hash->list (maybe-unbox data)))

; 	 (debug-trace 3 "pixmap_create_from_xpm_d: pixmap is " gdk-pixmap
; 		      " bitmap is " mask)
; 	 (gtk-object-set! new-gdkpixmap gdk-pixmap)
; 	 (gtk-object-set! new-gdkbitmap mask)
; 	 (php-hash-insert! retval :next new-gdkpixmap)
; 	 (php-hash-insert! retval :next new-gdkbitmap)
; 	 retval)))


; (define (gdk-pixmap-create-from-xpm::GdkPixmap*
; 	 gdk-window::GdkWindow*
; 	 data
; 	 #!key
; 	 transparent
; 	 colormap)
;    ;; We use gdk_pixmap_colormap_* because it takes all the options,
;    ;; and just pass NULL for ones we don't want.  Data can be a list
;    ;; of strings or single string. If it's a single string, it's used
;    ;; as a filename.
;    (let* ((transparent::GdkColor* (or transparent
; 				      (pragma::GdkColor* "NULL")))
; ;	  (gdk-window::GdkWindow* w);(gtk-widget-window w))
; 	  (mask::GdkBitmap* (pragma::GdkBitmap* "NULL"))
; 	  (colormap::GdkColormap* (or colormap (pragma::GdkColormap* "NULL")))
; 	  (pixmap::GdkPixmap*
; 	   (cond
; 	      ((pair? data)
; 	       ;; data is a list of strings -- the actual pixmap data
; 	       (let ((cdata::string* (string-list->string* data)))
; 		  (pragma::GdkPixmap*
; 		   "gdk_pixmap_colormap_create_from_xpm_d ($1, $2, &$3, $4, $5)"
; 		   gdk-window colormap mask transparent cdata)))
; 	      ((string? data)
; 	       ;; data is a filename
; 	       (let ((filename::string data))
; 		  (pragma::GdkPixmap*

; 		   "gdk_pixmap_colormap_create_from_xpm ($1, $2, &$3, $4, $5)"
; 		   gdk-window colormap mask transparent filename)))
; 	      (else
; 	       (error 'gdk-pixmap-create-from-xpm
; 		      "invalid data argument: must be filename or list of strings"
; 		      data)))))
;       (when (pragma::bool "$1 == NULL" pixmap)
; 	 (error 'gdk-pixmap-create-from-xpm
; 		"cannot create pixmap from data" data))
;       (values pixmap mask)))

 

; ;;
; ;; GdkAtom
; ;; =======


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

; ;;; no methods

; ;;
; ;; GdkBitmap
; ;; =========

; (defclass GdkBitmap); pcc-gtk))

; (defmethod-XXX gdkbitmap (extents) TRUE)
; (defmethod-XXX gdkbitmap (lock) TRUE)
; (defmethod-XXX gdkbitmap (height) TRUE)
; (defmethod-XXX gdkbitmap (width) TRUE)

; ;;
; ;; GdkColor
; ;; ========

; (defclass GdkColor)

; (defmethod gdkcolor (gdkcolor name-or-red #!optional green blue)
;    (if green
;        (gtk-object-set! $this (gdk-color-new (mkfixnum name-or-red)
; 					     (mkfixnum green)
; 					     (mkfixnum blue)))
;        (let ((c (gdk-color-new 0 0 0)))
;           (if (zero? (gdk_color_parse (mkstr name-or-red) c))
;               (begin
;                  (php-warning "could not parse color spec '" (mkstr name-or-red) "'")
;                  +constructor-failed+)
;               (gtk-object-set! $this c)))))


; ;;
; ;; GdkColormap
; ;; ===========

; (defclass GdkColormap); pcc-gtk))

; (defmethod-XXX gdkcolormap (size) TRUE)
; (defmethod-XXX gdkcolormap (alloc) TRUE)

; ;;
; ;; GdkCursor
; ;; =========

; (def-ext-class GdkCursor
;    gdk-cursor-custom-lookup
;    (lambda (obj prop ref? value k) (k))
;    (lambda (a) a))

; ;;; XXX broken in the switch from bgtk
; (def-property-getter (gdk-cursor-custom-lookup obj prop ref? k) GdkCursor
;    (type :impl (convert-to-integer (let ((this::GdkCursor* (gtk-object obj)))
; 				      (pragma::int "$1->type" this))))
;    (name :impl
; 	 (let ((this::GdkCursor* (gtk-object obj)))
; 	    (let loop ((vals::GtkEnumValue* (pragma::GtkEnumValue* "gtk_type_enum_get_values(GTK_TYPE_GDK_CURSOR_TYPE)")))
; 	       (if (pragma::bool "($1->value_name != NULL && $1->value != (unsigned)$2->type)" vals this)
; 		   ;;this is horrible, isn't it :)
; 		   ;;if you change the ++$1 to a $1++, it won't work anymore...
; 		   (loop (pragma::GtkEnumValue* "++$1" vals))
; 		   (if (pragma::bool "$1->value_nick" vals)
; 		       (pragma::string "$1->value_nick" vals)
; 		       "*unknown*"))))))

; ;;; no methods

; ;;
; ;; GdkDragContext
; ;; ==============

; (defclass GdkDragContext
;    (protocol (make-container '()))
;    (is_source (make-container '()))
;    (source_window (make-container '()))
;    (dest_window (make-container '()))
;    (targets (make-container '()))
;    (actions (make-container '()))
;    (suggested_action (make-container '()))
;    (action (make-container '()))
;    (start_time (make-container '())))

; ;;; no methods

; ;;
; ;; GdkEvent
; ;; ========

; ;it's lowercase in php-gtk
; (defclass gdkevent); pcc-gtk))
; ;;; XXX figure out the event stuff, what properties etc.
(defclass GdkEvent)

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
; 		(php-object-property-set! wrapper "pressure"
; 					  (convert-to-float
; 					   (pragma::double "$1->motion.pressure" event)))
; 		(php-object-property-set! wrapper "xtilt"
; 					  (convert-to-float
; 					   (pragma::double "$1->motion.xtilt" event)))
; 		(php-object-property-set! wrapper "ytilt"
; 					  (convert-to-float
; 					   (pragma::double "$1->motion.ytilt" event)))
		(php-object-property-set! wrapper "state"
					  (convert-to-integer
					   (pragma::int "$1->motion.state" event)))
		(php-object-property-set! wrapper "is_hint"
					  (convert-to-boolean
					   (pragma::bool "$1->motion.is_hint" event)))
; 		(php-object-property-set! wrapper "source"
; 					  (convert-to-integer
; 					   (pragma::int "$1->motion.source" event)))
; 		(php-object-property-set! wrapper "deviceid"
; 					  (convert-to-integer
; 					   (pragma::int "$1->motion.deviceid" event)))
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
; 		(php-object-property-set! wrapper "pressure"
; 					  (convert-to-float
; 					   (pragma::double "$1->button.pressure" event)))
; 		(php-object-property-set! wrapper "xtilt"
; 					  (convert-to-float
; 					   (pragma::double "$1->button.xtilt" event)))
; 		(php-object-property-set! wrapper "ytilt"
; 					  (convert-to-float
; 					   (pragma::double "$1->button.ytilt" event)))
		(php-object-property-set! wrapper "state"
					  (convert-to-integer
					   (pragma::int "$1->button.state" event)))
		(php-object-property-set! wrapper "button"
					  (convert-to-integer
					   (pragma::int "$1->button.button" event)))
; 		(php-object-property-set! wrapper "source"
; 					  (convert-to-integer
; 					   (pragma::int "$1->button.source" event)))
; 		(php-object-property-set! wrapper "deviceid"
; 					  (convert-to-integer
; 					   (pragma::int "$1->button.deviceid" event)))
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
		; (php-object-property-set! wrapper "source"
; 					  (convert-to-integer
; 					   (pragma::int "$1->proximity.source" event)))
		; (php-object-property-set! wrapper "deviceid"
; 					  (convert-to-integer
; 					   (pragma::int "$1->proximity.deviceid" event)))
                ))
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
	 


	 

; ;;; no methods, yet

; ;;
; ;; GdkFont
; ;; =======

; ; (defclass (pcc-gdkfont pcc-gtk)
; ;    (name ""))

; (defclass GdkFont ;pcc-gdkfont)
;    (type (make-container '()))
;    (ascent (make-container '()))
;    (descent (make-container '())))

; (defmethod-XXX gdkfont (extents) TRUE)
; (defmethod-XXX gdkfont (measure) TRUE)
; (defmethod-XXX gdkfont (height) TRUE)
; (defmethod-XXX gdkfont (width) TRUE)

; ;;
; ;; GdkGC
; ;; =====

(defclass GdkGC) ; pcc-gtk)
; ;    (foreground (make-container '()))
; ;    (background (make-container '()))
; ;    (font (make-container '()))
; ;    (function (make-container '()))
; ;    (fill (make-container '()))
; ;    (tile (make-container '()))
; ;    (stipple (make-container '()))
; ;    (clip_mask (make-container '()))
; ;    (subwindow_mode (make-container '()))
; ;    (ts_x_origin (make-container '()))
; ;    (ts_y_origin (make-container '()))
; ;    (clip_x_origin (make-container '()))
; ;    (clip_y_origin (make-container '()))
; ;    (graphics_exposures (make-container '()))
; ;    (line_width (make-container '()))
; ;    (line_style (make-container '()))
; ;    (cap_style (make-container '()))
; ;    (join_style (make-container '())))

; (defmethod-XXX gdkgc (set_dashes) TRUE)



(defclass GdkDrawable)

(def-pgtk-methods GdkDrawable gdk_drawable
   ((image_get :return-type GdkImage* :c-name gdk_image_get) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   ((new_gc :return-type GdkGC* :c-name gdk_gc_new_with_values) (values :gtk-type GdkGCValues*) (values_mask :gtk-type GdkGCValuesMask))
   (unref)
   (set_data (key :gtk-type const-gchar*) (data :gtk-type gpointer) (destroy_func :gtk-type GDestroyNotify))
   (set_colormap (colormap :gtk-type GdkColormap*))
   ((ref :return-type GdkDrawable*))
   ((get_visual :return-type GdkVisual*))
   ((get_visible_region :return-type GdkRegion*))
   (get_size (width :gtk-type gint*) (height :gtk-type gint*))
   ((get_screen :return-type GdkScreen*))
   ((get_image :return-type GdkImage*) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   ((get_display :return-type GdkDisplay*))
   ((get_depth :return-type gint))
   ((get_data :return-type gpointer) (key :gtk-type const-gchar*))
   ((get_colormap :return-type GdkColormap*))
   ((get_clip_region :return-type GdkRegion*))
   ((draw_text_wc :c-name gdk_draw_text_wc) (font :gtk-type GdkFont*) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (text :gtk-type const-GdkWChar*) (text_length :gtk-type gint))
   ((draw_text :c-name gdk_draw_text) (font :gtk-type GdkFont*) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (text :gtk-type const-gchar*) (text_length :gtk-type gint))
   ((draw_string :c-name gdk_draw_string) (font :gtk-type GdkFont*) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (string :gtk-type const-gchar*))
   ((draw_segments :c-name gdk_draw_segments) (gc :gtk-type GdkGC*) (segs :gtk-type GdkSegment*) (nsegs :gtk-type gint))
   ((draw_rgb_image_dithalign :c-name gdk_draw_rgb_image_dithalign) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint) (dith :gtk-type GdkRgbDither) (rgb_buf :gtk-type guchar*) (rowstride :gtk-type gint) (xdith :gtk-type gint) (ydith :gtk-type gint))
   ((draw_rgb_image :c-name gdk_draw_rgb_image) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint) (dith :gtk-type GdkRgbDither) (rgb_buf :gtk-type guchar*) (rowstride :gtk-type gint))
   ((draw_rgb_32_image :c-name gdk_draw_rgb_32_image) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint) (dith :gtk-type GdkRgbDither) (buf :gtk-type guchar*) (rowstride :gtk-type gint))
   ((draw_rectangle :c-name gdk_draw_rectangle) (gc :gtk-type GdkGC*) (filled :gtk-type gboolean) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   ((draw_polygon :c-name gdk_draw_polygon) (gc :gtk-type GdkGC*) (filled :gtk-type gboolean) (points :gtk-type GdkPoint*) (npoints :gtk-type gint))
   ((draw_points :c-name gdk_draw_points) (gc :gtk-type GdkGC*) (points :gtk-type GdkPoint*) (npoints :gtk-type gint))
   ((draw_point :c-name gdk_draw_point) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint))
   ((draw_pixbuf :c-name gdk_draw_pixbuf) (gc :gtk-type GdkGC*) (pixbuf :gtk-type GdkPixbuf*) (src_x :gtk-type gint) (src_y :gtk-type gint) (dest_x :gtk-type gint) (dest_y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint) (dither :gtk-type GdkRgbDither) (x_dither :gtk-type gint) (y_dither :gtk-type gint))
   ((draw_lines :c-name gdk_draw_lines) (gc :gtk-type GdkGC*) (points :gtk-type GdkPoint*) (npoints :gtk-type gint))
   ((draw_line :c-name gdk_draw_line) (gc :gtk-type GdkGC*) (x1 :gtk-type gint) (y1 :gtk-type gint) (x2 :gtk-type gint) (y2 :gtk-type gint))
   ((draw_layout_line :c-name gdk_draw_layout_line) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (line :gtk-type PangoLayoutLine*))
   ((draw_layout :c-name gdk_draw_layout) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (layout :gtk-type PangoLayout*))
   ((draw_indexed_image :c-name gdk_draw_indexed_image) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint) (dith :gtk-type GdkRgbDither) (buf :gtk-type guchar*) (rowstride :gtk-type gint) (cmap :gtk-type GdkRgbCmap*))
   ((draw_image :c-name gdk_draw_image) (gc :gtk-type GdkGC*) (image :gtk-type GdkImage*) (xsrc :gtk-type gint) (ysrc :gtk-type gint) (xdest :gtk-type gint) (ydest :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   ((draw_gray_image :c-name gdk_draw_gray_image) (gc :gtk-type GdkGC*) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint) (dith :gtk-type GdkRgbDither) (buf :gtk-type guchar*) (rowstride :gtk-type gint))
   ((draw_glyphs :c-name gdk_draw_glyphs) (gc :gtk-type GdkGC*) (font :gtk-type PangoFont*) (x :gtk-type gint) (y :gtk-type gint) (glyphs :gtk-type PangoGlyphString*))
   ((draw_drawable :c-name gdk_draw_drawable) (gc :gtk-type GdkGC*) (src :gtk-type GdkDrawable*) (xsrc :gtk-type gint) (ysrc :gtk-type gint) (xdest :gtk-type gint) (ydest :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   ((draw_arc :c-name gdk_draw_arc) (gc :gtk-type GdkGC*) (filled :gtk-type gboolean) (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint) (angle1 :gtk-type gint) (angle2 :gtk-type gint))
   )

; ;;
; ;; GdkPixmap
; ;; =========

(defclass (GdkPixmap GdkDrawable)); pcc-gtk))

(defmethod gdkpixmap (gdkpixmap window width height #!optional (depth -1))
   (let ((window::GdkWindow* (gtk-object window))
	 (width::int (mkfixnum width))
	 (height::int (mkfixnum height))
	 (depth::int (mkfixnum depth)))
      (let ((pixmap (pragma::GdkPixmap* "gdk_pixmap_new($1, $2, $3, $4)"
					window width height depth)))
	 (gtk-object-set! $this pixmap))))


; ; (defmethod-XXX gdkpixmap (new_gc)
; ; ;   (new-gc $this)
; ;    TRUE)

; ; (defmethod-XXX gdkpixmap (property_get)
; ;    TRUE)

; ; (defmethod-XXX gdkpixmap (property_change)
; ;    TRUE)

; ; (defmethod-XXX gdkpixmap (property_delete)
; ;    TRUE)

; ;;
; ;; GdkVisual
; ;; =========

; (defclass GdkVisual)
; ;    (type (make-container '()))
; ;    (depth (make-container '()))
; ;    (byte_order (make-container '()))
; ;    (colormap_size (make-container '()))
; ;    (bits_per_rgb (make-container '()))
; ;    (red_mask (make-container '()))
; ;    (red_shift (make-container '()))
; ;    (red_prec (make-container '()))
; ;    (green_mask (make-container '()))
; ;    (green_shift (make-container '()))
; ;    (green_prec (make-container '()))
; ;    (blue_mask (make-container '()))
; ;    (blue_shift (make-container '()))
; ;    (blue_prec (make-container '())))
   
; ;;; no methods

; ;;
; ;; GdkWindow
; ;; =========

(def-ext-class (GdkWindow GdkDrawable)
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


(def-pgtk-methods GdkWindow gdk_window
   (withdraw)
   (unstick)
   (unmaximize)
   (unfullscreen)
   (thaw_updates)
   (stick)
   (show)
   (shape_combine_mask (shape_mask :gtk-type GdkBitmap*) (offset_x :gtk-type gint) (offset_y :gtk-type gint))
   (set_user_data (user_data :gtk-type gpointer))
   (set_type_hint (hint :gtk-type GdkWindowTypeHint))
   (set_transient_for (leader :gtk-type GdkWindow*))
   (set_title (title :gtk-type const-gchar*))
   ((set_static_gravities :return-type gboolean) (use_static :gtk-type gboolean))
   (set_skip_taskbar_hint (modal :gtk-type gboolean))
   (set_skip_pager_hint (modal :gtk-type gboolean))
   (set_role (role :gtk-type const-gchar*))
   (set_override_redirect (override_redirect :gtk-type gboolean))
   (set_modal_hint (modal :gtk-type gboolean))
   (set_keep_below (setting :gtk-type gboolean))
   (set_keep_above (setting :gtk-type gboolean))
   (set_icon_name (name :gtk-type const-gchar*))
   (set_icon_list (pixbufs :gtk-type GList*))
   (set_icon (icon_window :gtk-type GdkWindow*) (pixmap :gtk-type GdkPixmap*) (mask :gtk-type GdkBitmap*))
   (set_hints (x :gtk-type gint) (y :gtk-type gint) (min_width :gtk-type gint) (min_height :gtk-type gint) (max_width :gtk-type gint) (max_height :gtk-type gint) (flags :gtk-type gint))
   (set_group (leader :gtk-type GdkWindow*))
   (set_geometry_hints (geometry :gtk-type GdkGeometry*) (flags :gtk-type GdkWindowHints))
   (set_functions (functions :gtk-type GdkWMFunction))
   (set_focus_on_map (focus_on_map :gtk-type gboolean))
   (set_events (event_mask :gtk-type GdkEventMask))
   (set_decorations (decorations :gtk-type GdkWMDecoration))
   (set_cursor (cursor :gtk-type GdkCursor*))
   (set_child_shapes)
   (set_background (color :gtk-type GdkColor*))
   (set_back_pixmap (pixmap :gtk-type GdkPixmap*) (parent_relative :gtk-type gboolean))
   (set_accept_focus (accept_focus :gtk-type gboolean))
   (scroll (dx :gtk-type gint) (dy :gtk-type gint))
   (resize (width :gtk-type gint) (height :gtk-type gint))
   (reparent (new_parent :gtk-type GdkWindow*) (x :gtk-type gint) (y :gtk-type gint))
   (remove_filter (function :gtk-type GdkFilterFunc) (data :gtk-type gpointer))
   (register_dnd)
   (raise)
   (process_updates (update_children :gtk-type gboolean))
   ((peek_children :return-type GList*))
   (move_resize (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   (move (x :gtk-type gint) (y :gtk-type gint))
   (merge_child_shapes)
   (maximize)
   (lower)
   ((is_visible :return-type gboolean))
   ((is_viewable :return-type gboolean))
   (invalidate_region (region :gtk-type GdkRegion*) (invalidate_children :gtk-type gboolean))
   (invalidate_rect (rect :gtk-type GdkRectangle*) (invalidate_children :gtk-type gboolean))
   (invalidate_maybe_recurse (region :gtk-type GdkRegion*) (*child_func :gtk-type gboolean))
   (iconify)
   (hide)
   ((get_window_type :return-type GdkWindowType))
   (get_user_data (user_data :gtk-type gpointer*))
   ((get_update_area :return-type GdkRegion*))
   ((get_toplevels :return-type GList*))
   ((get_toplevel :return-type GdkWindow*))
   ((get_state :return-type GdkWindowState))
   (get_root_origin (x :gtk-type gint*) (y :gtk-type gint*))
   (get_position (x :gtk-type gint*) (y :gtk-type gint*))
   ((get_pointer :return-type GdkWindow*) (x :gtk-type gint*) (y :gtk-type gint*) (mask :gtk-type GdkModifierType*))
   ((get_parent :return-type GdkWindow*))
   ((get_origin :return-type gint) (x :gtk-type gint*) (y :gtk-type gint*))
   (get_internal_paint_info (real_drawable :gtk-type GdkDrawable**) (x_offset :gtk-type gint*) (y_offset :gtk-type gint*))
   ((get_group :return-type GdkWindow*))
   (get_geometry (x :gtk-type gint*) (y :gtk-type gint*) (width :gtk-type gint*) (height :gtk-type gint*) (depth :gtk-type gint*))
   (get_frame_extents (rect :gtk-type GdkRectangle*))
   ((get_events :return-type GdkEventMask))
   ((get_deskrelative_origin :return-type gboolean) (x :gtk-type gint*) (y :gtk-type gint*))
   ((get_decorations :return-type gboolean) (decorations :gtk-type GdkWMDecoration*))
   ((get_children :return-type GList*))
   (fullscreen)
   (freeze_updates)
   (focus (timestamp :gtk-type guint32))
   (end_paint)
   (enable_synchronized_configure)
   (destroy)
   (deiconify)
   (configure_finished)
   (clear_area_e (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   (clear_area (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   (clear)
   (begin_resize_drag (edge :gtk-type GdkWindowEdge) (button :gtk-type gint) (root_x :gtk-type gint) (root_y :gtk-type gint) (timestamp :gtk-type guint32))
   (begin_paint_region (region :gtk-type GdkRegion*))
   (begin_paint_rect (rectangle :gtk-type GdkRectangle*))
   (begin_move_drag (button :gtk-type gint) (root_x :gtk-type gint) (root_y :gtk-type gint) (timestamp :gtk-type guint32))
;   ((at_pointer :return-type GdkWindow*) (win_x :gtk-type gint*) (win_y :gtk-type gint*))
   (add_filter (function :gtk-type GdkFilterFunc) (data :gtk-type gpointer))
   ((selection_property_get :return-type gboolean :c-name gdk_selection_property_get) (data :gtk-type guchar**) (prop_type :gtk-type GdkAtom*) (prop_format :gtk-type gint*))
   ((selection_convert :c-name gdk_selection_convert) (selection :gtk-type GdkAtom) (target :gtk-type GdkAtom) (time :gtk-type guint32))
   ((property_get :return-type gboolean :c-name gdk_property_get) (property :gtk-type GdkAtom) (type :gtk-type GdkAtom) (offset :gtk-type gulong) (length :gtk-type gulong) (pdelete :gtk-type gint) (actual_property_type :gtk-type GdkAtom*) (actual_format :gtk-type gint*) (actual_length :gtk-type gint*) (data :gtk-type guchar**))
   ((property_delete :c-name gdk_property_delete) (property :gtk-type GdkAtom))
   ((property_change :c-name gdk_property_change) (property :gtk-type GdkAtom) (type :gtk-type GdkAtom) (format :gtk-type gint) (mode :gtk-type GdkPropMode) (data :gtk-type const-guchar*) (nelements :gtk-type gint))
   ((input_set_extension_events :c-name gdk_input_set_extension_events) (mask :gtk-type gint) (mode :gtk-type GdkExtensionMode))
   ((drag_begin :return-type GdkDragContext* :c-name gdk_drag_begin) (targets :gtk-type GList*))
   (withdraw)
   (unstick)
   (unmaximize)
   (unfullscreen)
   (thaw_updates)
   (stick)
   (show)
   (shape_combine_mask (shape_mask :gtk-type GdkBitmap*) (offset_x :gtk-type gint) (offset_y :gtk-type gint))
   (set_user_data (user_data :gtk-type gpointer))
   (set_type_hint (hint :gtk-type GdkWindowTypeHint))
   (set_transient_for (leader :gtk-type GdkWindow*))
   (set_title (title :gtk-type const-gchar*))
   ((set_static_gravities :return-type gboolean) (use_static :gtk-type gboolean))
   (set_skip_taskbar_hint (modal :gtk-type gboolean))
   (set_skip_pager_hint (modal :gtk-type gboolean))
   (set_role (role :gtk-type const-gchar*))
   (set_override_redirect (override_redirect :gtk-type gboolean))
   (set_modal_hint (modal :gtk-type gboolean))
   (set_keep_below (setting :gtk-type gboolean))
   (set_keep_above (setting :gtk-type gboolean))
   (set_icon_name (name :gtk-type const-gchar*))
   (set_icon_list (pixbufs :gtk-type GList*))
   (set_icon (icon_window :gtk-type GdkWindow*) (pixmap :gtk-type GdkPixmap*) (mask :gtk-type GdkBitmap*))
   (set_hints (x :gtk-type gint) (y :gtk-type gint) (min_width :gtk-type gint) (min_height :gtk-type gint) (max_width :gtk-type gint) (max_height :gtk-type gint) (flags :gtk-type gint))
   (set_group (leader :gtk-type GdkWindow*))
   (set_geometry_hints (geometry :gtk-type GdkGeometry*) (flags :gtk-type GdkWindowHints))
   (set_functions (functions :gtk-type GdkWMFunction))
   (set_focus_on_map (focus_on_map :gtk-type gboolean))
   (set_events (event_mask :gtk-type GdkEventMask))
   (set_decorations (decorations :gtk-type GdkWMDecoration))
   (set_cursor (cursor :gtk-type GdkCursor*))
   (set_child_shapes)
   (set_background (color :gtk-type GdkColor*))
   (set_back_pixmap (pixmap :gtk-type GdkPixmap*) (parent_relative :gtk-type gboolean))
   (set_accept_focus (accept_focus :gtk-type gboolean))
   (scroll (dx :gtk-type gint) (dy :gtk-type gint))
   (resize (width :gtk-type gint) (height :gtk-type gint))
   (reparent (new_parent :gtk-type GdkWindow*) (x :gtk-type gint) (y :gtk-type gint))
   (remove_filter (function :gtk-type GdkFilterFunc) (data :gtk-type gpointer))
   (register_dnd)
   (raise)
   (process_updates (update_children :gtk-type gboolean))
   ((peek_children :return-type GList*))
   (move_resize (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   (move (x :gtk-type gint) (y :gtk-type gint))
   (merge_child_shapes)
   (maximize)
   (lower)
   ((is_visible :return-type gboolean))
   ((is_viewable :return-type gboolean))
   (invalidate_region (region :gtk-type GdkRegion*) (invalidate_children :gtk-type gboolean))
   (invalidate_rect (rect :gtk-type GdkRectangle*) (invalidate_children :gtk-type gboolean))
   (invalidate_maybe_recurse (region :gtk-type GdkRegion*) (*child_func :gtk-type gboolean))
   (iconify)
   (hide)
   ((get_window_type :return-type GdkWindowType))
   (get_user_data (user_data :gtk-type gpointer*))
   ((get_update_area :return-type GdkRegion*))
   ((get_toplevels :return-type GList*))
   ((get_toplevel :return-type GdkWindow*))
   ((get_state :return-type GdkWindowState))
   (get_root_origin (x :gtk-type gint*) (y :gtk-type gint*))
   (get_position (x :gtk-type gint*) (y :gtk-type gint*))
   ((get_pointer :return-type GdkWindow*) (x :gtk-type gint*) (y :gtk-type gint*) (mask :gtk-type GdkModifierType*))
   ((get_parent :return-type GdkWindow*))
   ((get_origin :return-type gint) (x :gtk-type gint*) (y :gtk-type gint*))
   (get_internal_paint_info (real_drawable :gtk-type GdkDrawable**) (x_offset :gtk-type gint*) (y_offset :gtk-type gint*))
   ((get_group :return-type GdkWindow*))
   (get_geometry (x :gtk-type gint*) (y :gtk-type gint*) (width :gtk-type gint*) (height :gtk-type gint*) (depth :gtk-type gint*))
   (get_frame_extents (rect :gtk-type GdkRectangle*))
   ((get_events :return-type GdkEventMask))
   ((get_deskrelative_origin :return-type gboolean) (x :gtk-type gint*) (y :gtk-type gint*))
   ((get_decorations :return-type gboolean) (decorations :gtk-type GdkWMDecoration*))
   ((get_children :return-type GList*))
   (fullscreen)
   (freeze_updates)
   (focus (timestamp :gtk-type guint32))
   (end_paint)
   (enable_synchronized_configure)
   (destroy)
   (deiconify)
   (configure_finished)
   (clear_area_e (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   (clear_area (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   (clear)
   (begin_resize_drag (edge :gtk-type GdkWindowEdge) (button :gtk-type gint) (root_x :gtk-type gint) (root_y :gtk-type gint) (timestamp :gtk-type guint32))
   (begin_paint_region (region :gtk-type GdkRegion*))
   (begin_paint_rect (rectangle :gtk-type GdkRectangle*))
   (begin_move_drag (button :gtk-type gint) (root_x :gtk-type gint) (root_y :gtk-type gint) (timestamp :gtk-type guint32))
;   ((at_pointer :return-type GdkWindow*) (win_x :gtk-type gint*) (win_y :gtk-type gint*))
   (add_filter (function :gtk-type GdkFilterFunc) (data :gtk-type gpointer))
   ((selection_property_get :return-type gboolean :c-name gdk_selection_property_get) (data :gtk-type guchar**) (prop_type :gtk-type GdkAtom*) (prop_format :gtk-type gint*))
   ((selection_convert :c-name gdk_selection_convert) (selection :gtk-type GdkAtom) (target :gtk-type GdkAtom) (time :gtk-type guint32))
   ((property_get :return-type gboolean :c-name gdk_property_get) (property :gtk-type GdkAtom) (type :gtk-type GdkAtom) (offset :gtk-type gulong) (length :gtk-type gulong) (pdelete :gtk-type gint) (actual_property_type :gtk-type GdkAtom*) (actual_format :gtk-type gint*) (actual_length :gtk-type gint*) (data :gtk-type guchar**))
   ((property_delete :c-name gdk_property_delete) (property :gtk-type GdkAtom))
   ((property_change :c-name gdk_property_change) (property :gtk-type GdkAtom) (type :gtk-type GdkAtom) (format :gtk-type gint) (mode :gtk-type GdkPropMode) (data :gtk-type const-guchar*) (nelements :gtk-type gint))
   ((input_set_extension_events :c-name gdk_input_set_extension_events) (mask :gtk-type gint) (mode :gtk-type GdkExtensionMode))
   ((drag_begin :return-type GdkDragContext* :c-name gdk_drag_begin) (targets :gtk-type GList*))
   )

   ;XXX there are more of these...
   
; (def-pgtk-methods GdkWindow gdk_window
;    (raise)
;    (lower)
;    ;get_pointer has out params
;    (set_cursor (cursor :gtk-type GdkCursor* :default NULL))
;    ;new_gc is hairy
;    ;property_get is hairy
;    ;property_change is hairy
;    ;property_delete is hairy
;    (set_icon (icon_window :gtk-type GdkWindow*) (pixmap :gtk-type GdkPixmap*) (mask :gtk-type GdkBitmap*))
;    (copy_area (gc :gtk-type GdkGC*) (x :gtk-type int) (y :gtk-type int) (src_window :gtk-type GdkDrawable*)
; 	      (src_x :gtk-type int) (src_y :gtk-type int) (width :gtk-type int) (height :gtk-type int)))

; (defmethod gdkwindow (get_pointer)
;    (let ((x::int (pragma::int "0"))
; 	 (y::int (pragma::int "0"))
; 	 (mask::int (pragma::int "0"))
; 	 (this::GdkWindow* (gtk-object $this)))
;       (pragma "gdk_window_get_pointer($1, &$2, &$3, (GdkModifierType*)&$4)"
; 	      this x y mask)
;       (list->php-hash (list (convert-to-integer x)
; 			    (convert-to-integer y)
; 			    (convert-to-integer mask)))))
   
; ;(defmethod gdkwindow (raise)
; ;   (gdk_window_raise (gtk-object $this)))

; ; (def-pgtk-methods GdkColor gdk_color
; ;    ((equal :return-type gboolean) (colorb :gtk-type const-GdkColor*))
; ;    ((hash :return-type guint) (colorb :gtk-type const-GdkColor*))
; ;    (free)
; ;    ((copy :return-type GdkColor*))
; ;    )

; ; (def-pgtk-methods GdkWindow gdk_window
; ;    (set_icon_name (name :gtk-type const-gchar*))
; ;    (set_icon (icon_window :gtk-type GdkWindow*) (pixmap :gtk-type GdkPixmap*) (mask :gtk-type GdkBitmap*))
; ;    )

; ; (def-pgtk-methods GdkAtom gdk_atom
; ;    ((name :return-type gchar*))
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

(defmethod GdkRectangle (__construct x y width height)
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

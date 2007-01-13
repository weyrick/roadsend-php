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
(module php-gtk-lib
;   (include "../phpoo-extension.sch")
   (load (php-macros "../../../php-macros.scm"))
   (load (php-gtk-macros "php-gtk-macros.sch"))
;   (library "common")
;   (library "bgtk")
   (import (gtk-binding "cigloo/gtk.scm")
	   (gtk-signals "cigloo/signals.scm"))
   (library php-runtime)
   (import ;(gtk-foreign-types "gtk-foreign-types.scm")
	   (php-gtk-common-lib "php-gtk-common.scm")
	   (gtk-enums-lib "gtk-enums.scm")
	   (gdk-enums-lib "gdk-enums.scm")
	   (php-gdk-lib "php-gdk.scm")
	   (php-gtk-style-lib "gtk-style.scm")
	   (php-gtk-static-lib "gtk-static.scm")
;	   (php-gtk-custom-properties "custom-properties.scm")
	   (php-gtkscintilla-lib "php-gtkscintilla.scm")
	   (define-classes "define-classes.scm")
	   (php-gtk-overrides "php-gtk-overrides.scm")
	   (php-gtk-signals "php-gtk-signals.scm")
	   (php-glade-lib "php-glade.scm"))
   (export
    (init-php-gtk-lib)
    (php-gtk-ctree-node-new obj)
    ))
	  
;;;
;;; Module Init
;;; ===========

(define (init-php-gtk-lib)
   (init-define-classes)
   (init-gdk-enums-lib)
   (init-gtk-enums-lib)
   (init-php-gtk-common-lib)
   (init-php-gdk-lib)
   (init-php-gtk-style-lib)
   (init-php-gtk-static-lib)
   (init-php-gtk-overrides)
   (init-php-gtkscintilla-lib)
   (init-php-gtk-signals)
   (init-php-glade-lib)
   1)

;;; Register the GTK extension.  Without this, static linking doesn't
;;; work.
(register-extension "gtk" "1.0.0"
                    "php-gtk" (cond-expand 
                               (PCC_MINGW '("-lgtk" "-lgdk" "-lgmodule-2.0" "-lglib-2.0" 
                                            "-lgtkscintilla" "-lglade" "-lxml2" 
                                            "-lgw32c" "-lole32" "-luuid" "-lstdc++"))
                               (else '("-lgtk" "-lgdk" "-lgmodule" "-lglib" "-lgtkscintilla" "-lglade"
                                       "-L/usr/X11R6/lib" "-lX11" "-lstdc++" "-lpthread" "-lXext" "-lxml2"
                                       "-lz" "-lXi"))))

;;;
;;; GTK Functions and Classes
;;; =========================


;;;
;;; GtkAccelGroup
;;; =============


;;; GtkAccelGroup->GtkAccelGroup
(defmethod GtkAccelGroup (GtkAccelGroup)
   ;;; !!! an AccelGroup is not an object!
   (gtk-object-set! $this (gtk_accel_group_new)))

(def-pgtk-methods GtkAccelGroup gtk_accel_group
;   (remove (accel_key :gtk-type guint) (accel_mods :gtk-type GdkModifierType) (object :gtk-type GtkObject*))
;   (add (accel_key :gtk-type guint) (accel_mods :gtk-type GdkModifierType) (accel_flags :gtk-type GtkAccelFlags) (object :gtk-type GtkObject*) (accel_signal :gtk-type const-gchar*))
;   (unlock_entry (accel_key :gtk-type guint) (accel_mods :gtk-type GdkModifierType))
;   (lock_entry (accel_key :gtk-type guint) (accel_mods :gtk-type GdkModifierType))
;   ((get_entry :return-type GtkAccelEntry*) (accel_key :gtk-type guint) (accel_mods :gtk-type GdkModifierType))
;   (detach (object :gtk-type GtkObject*))
;   (attach (object :gtk-type GtkObject*))
;   ((activate :return-type gboolean) (accel_key :gtk-type guint) (accel_mods :gtk-type GdkModifierType))
;   (unlock)
;   (lock)
;   (unref)
;   ((ref :return-type GtkAccelGroup*))
   )


;;
;; GtkObject
;; =========


;;; no constructor

;;these are from the "extra" defs
(def-pgtk-methods GtkObject gtk_object
   ((unset_flags :c-name GTK_OBJECT_UNSET_FLAGS) (flags :gtk-type guint))
   ((set_flags :c-name GTK_OBJECT_SET_FLAGS) (flags :gtk-type guint))
   ((flags :return-type guint :c-name GTK_OBJECT_FLAGS))
   )

(def-pgtk-methods GtkObject gtk_object
   ((signal_handlers_destroy :c-name gtk_signal_handlers_destroy))
   ((emit :c-name gtk_signal_emit) (signal_id :gtk-type guint))
   ((signal_handler_pending_by_id :return-type gint :c-name gtk_signal_handler_pending_by_id) (handler_id :gtk-type guint) (may_be_blocked :gtk-type gboolean))
   ((signal_handler_pending :return-type guint :c-name gtk_signal_handler_pending) (signal_id :gtk-type guint) (may_be_blocked :gtk-type gboolean))
   ((signal_handler_unblock :c-name gtk_signal_handler_unblock) (handler_id :gtk-type guint))
   ((signal_handler_block :c-name gtk_signal_handler_block) (handler_id :gtk-type guint))
;   ((disconnect :c-name gtk_signal_disconnect) (handler_id :gtk-type guint))
;   ((connect_object_after :return-type guint :c-name gtk_signal_connect_object_after) (name :gtk-type const-gchar*) (func :gtk-type GtkSignalFunc) (slot_object :gtk-type GtkObject*))
;   ((connect_object :return-type guint :c-name gtk_signal_connect_object) (name :gtk-type const-gchar*) (func :gtk-type GtkSignalFunc) (slot_object :gtk-type GtkObject*))
;   ((connect_after :return-type guint :c-name gtk_signal_connect_after) (name :gtk-type const-gchar*) (func :gtk-type GtkSignalFunc) (func_data :gtk-type gpointer))
;   ((connect :return-type guint :c-name gtk_signal_connect) (name :gtk-type const-gchar*) (func :gtk-type GtkSignalFunc) (func_data :gtk-type gpointer))
   ((emit_stop_by_name :c-name gtk_signal_emit_stop_by_name) (name :gtk-type const-gchar*))
   ((emit_stop :c-name gtk_signal_emit_stop) (signal_id :gtk-type guint))
;   (arg_get (arg :gtk-type GtkArg*) (info :gtk-type GtkArgInfo*))
;   (arg_set (arg :gtk-type GtkArg*) (info :gtk-type GtkArgInfo*))
;   (remove_no_notify_by_id (key_id :gtk-type GQuark))
;   (remove_data_by_id (data_id :gtk-type GQuark))
;   ((get_data_by_id :return-type gpointer) (data_id :gtk-type GQuark))
;   (set_data_by_id_full (data_id :gtk-type GQuark) (data :gtk-type gpointer) (destroy :gtk-type GtkDestroyNotify))
;   (set_data_by_id (data_id :gtk-type GQuark) (data :gtk-type gpointer))
;   ((get_user_data :return-type gpointer))
;   (set_user_data (data :gtk-type gpointer))
   (remove_no_notify (key :gtk-type const-gchar*))
;   ((get_data :return-type gpointer) (key :gtk-type const-gchar*))
   (remove_data (key :gtk-type const-gchar*))
;   (set_data_full (key :gtk-type const-gchar*) (data :gtk-type gpointer) (destroy :gtk-type GtkDestroyNotify))
;   (set_data (key :gtk-type const-gchar*) (data :gtk-type gpointer))
   (setv (n_args :gtk-type guint) (args :gtk-type GtkArg*))
   ((set_arg :c-name gtk_object_set) (first_arg_name :gtk-type const-gchar*))
   ((get_arg :c-name gtk_object_get) (first_arg_name :gtk-type const-gchar*))
;   (getv (n_args :gtk-type guint) (args :gtk-type GtkArg*))
   (destroy)
;   (weakunref (notify :gtk-type GtkDestroyNotify) (data :gtk-type gpointer))
;   (weakref (notify :gtk-type GtkDestroyNotify) (data :gtk-type gpointer))
   (unref)
   (ref)
   (sink)
   (constructed)
   (default_construct)
   )

;;;
;;; GtkWidget
;;; =========


;    (lambda (props)
;       props))

(def-pgtk-methods GtkWidget gtk_widget
   (class_path (path_length :gtk-type guint*) (path :gtk-type gchar**) (path_reversed :gtk-type gchar**))
   (path (path_length :gtk-type guint*) (path :gtk-type gchar**) (path_reversed :gtk-type gchar**))
;   (reset_shapes)
   (shape_combine_mask (shape_mask :gtk-type GdkBitmap*) (offset_x :gtk-type gint) (offset_y :gtk-type gint))
   (reset_rc_styles)
   ((get_composite_name :return-type gchar*))
   (set_composite_name (name :gtk-type const-gchar*))
   (modify_style (style :gtk-type GtkRcStyle*))
   (restore_default_style)
   ((get_style :return-type GtkStyle*))
   (ensure_style)
   (set_rc_style)
   (set_style (style :gtk-type GtkStyle*))
   ((hide_on_delete :return-type gint))
   ((is_ancestor :return-type gint) (ancestor :gtk-type GtkWidget*))
   (get_pointer (x :gtk-type gint*) (y :gtk-type gint*))
   ((get_events :return-type gint))
   (set_visual (visual :gtk-type GdkVisual*))
   (set_colormap (colormap :gtk-type GdkColormap*))
   ((get_visual :return-type GdkVisual*))
   ((get_colormap :return-type GdkColormap*))
   ((get_ancestor :return-type GtkWidget*) (widget_type :gtk-type GtkType))
   ((get_toplevel :return-type GtkWidget*))
   ((get_extension_events :return-type GdkExtensionMode))
   (set_extension_events (mode :gtk-type GdkExtensionMode))
   (add_events (events :gtk-type gint))
   (set_events (events :gtk-type gint))
   (set_usize (width :gtk-type gint) (height :gtk-type gint))
   (set_uposition (x :gtk-type gint) (y :gtk-type gint))
   ((get_parent_window :return-type GdkWindow*))
   (set_parent_window (parent_window :gtk-type GdkWindow*))
   (set_parent (parent :gtk-type GtkWidget*))
   (set_app_paintable (app_paintable :gtk-type gboolean))
   (set_sensitive (sensitive :gtk-type gboolean))
   (set_state (state :gtk-type GtkStateType))
   ((get_name :return-type gchar*))
   (set_name (name :gtk-type const-gchar*))
   (grab_default)
   (grab_focus)
   ((intersect :return-type gint) (area :gtk-type GdkRectangle*) (intersection :gtk-type GdkRectangle*))
   (popup (x :gtk-type gint) (y :gtk-type gint))
   (reparent (new_parent :gtk-type GtkWidget*))
   ((set_scroll_adjustments :return-type gboolean) (hadjustment :gtk-type GtkAdjustment*) (vadjustment :gtk-type GtkAdjustment*))
   ((activate :return-type gboolean))
   ((event :return-type gint) (event :gtk-type GdkEvent*))
   ((accelerators_locked :return-type gboolean))
   (unlock_accelerators)
   (lock_accelerators)
   ((accelerator_signal :return-type guint) (accel_group :gtk-type GtkAccelGroup*) (accel_key :gtk-type guint) (accel_mods :gtk-type guint))
   (remove_accelerators (accel_signal :gtk-type const-gchar*) (visible_only :gtk-type gboolean))
   (remove_accelerator (accel_group :gtk-type GtkAccelGroup*) (accel_key :gtk-type guint) (accel_mods :gtk-type guint))
   (add_accelerator (accel_signal :gtk-type const-gchar*) (accel_group :gtk-type GtkAccelGroup*) (accel_key :gtk-type guint) (accel_mods :gtk-type guint) (accel_flags :gtk-type GtkAccelFlags))
   (get_child_requisition (requisition :gtk-type GtkRequisition*))
   (size_allocate (allocation :gtk-type GtkAllocation*))
   (size_request (requisition :gtk-type GtkRequisition*))
   (draw_default)
   (draw_focus)
   (draw (area :gtk-type GdkRectangle* :default NULL)) 
   (queue_resize)
   (queue_clear_area (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   (queue_clear)
   (queue_draw_area (x :gtk-type gint) (y :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   (queue_draw)
   (unrealize)
   (realize)
   (unmap)
   (map)
   (hide_all)
   (show_all)
   (hide)
   (show_now)
   (show)
   (unparent)
;   (setv (nargs :gtk-type guint) (args :gtk-type GtkArg*))
;   (set (first_arg_name :gtk-type const-gchar*))
;   (getv (nargs :gtk-type guint) (args :gtk-type GtkArg*))
;   (get (arg :gtk-type GtkArg*))
   (destroyed (widget_pointer :gtk-type GtkWidget**))
   (destroy)
   (unref)
   (ref)
;   ((selection_property_notify :return-type gint :c-name gtk_selection_property_notify) (event :gtk-type GdkEventProperty*))
;   ((selection_notify :return-type gint :c-name gtk_selection_notify) (event :gtk-type GdkEventSelection*))
;   ((selection_request :return-type gint :c-name gtk_selection_request) (event :gtk-type GdkEventSelection*))
   ((selection_clear :return-type gint :c-name gtk_selection_clear) (event :gtk-type GdkEventSelection*))
   ((selection_remove_all :c-name gtk_selection_remove_all))
   ((selection_convert :return-type gint :c-name gtk_selection_convert) (selection :gtk-type GdkAtom) (target :gtk-type GdkAtom) (time :gtk-type guint32))
   ((selection_add_targets :c-name gtk_selection_add_targets) (selection :gtk-type GdkAtom) (targets :gtk-type const-GtkTargetEntry*) (ntargets :gtk-type guint))
   ((selection_add_target :c-name gtk_selection_add_target) (selection :gtk-type GdkAtom) (target :gtk-type GdkAtom) (info :gtk-type guint))
   ((selection_owner_set :return-type gint :c-name gtk_selection_owner_set) (selection :gtk-type GdkAtom) (time :gtk-type guint32))
;   ((drag_begin :return-type GdkDragContext* :c-name gtk_drag_begin) (targets :gtk-type GtkTargetList*) (actions :gtk-type GdkDragAction) (button :gtk-type gint) (event :gtk-type GdkEvent*))
   ((drag_source_set_icon :c-name gtk_drag_source_set_icon) (colormap :gtk-type GdkColormap*) (pixmap :gtk-type GdkPixmap*) (mask :gtk-type GdkBitmap*))
   ((drag_source_unset :c-name gtk_drag_source_unset))
;   ((drag_source_set :c-name gtk_drag_source_set) (start_button_mask :gtk-type GdkModifierType) (targets :gtk-type const-GtkTargetEntry*) (n_targets :gtk-type gint) (actions :gtk-type GdkDragAction))
   ((drag_dest_unset :c-name gtk_drag_dest_unset))
   ((drag_dest_set_proxy :c-name gtk_drag_dest_set_proxy) (proxy_window :gtk-type GdkWindow*) (protocol :gtk-type GdkDragProtocol) (use_coordinates :gtk-type gboolean))
;   ((drag_dest_set :c-name gtk_drag_dest_set) (flags :gtk-type GtkDestDefaults) (targets :gtk-type const-GtkTargetEntry*) (n_targets :gtk-type gint) (actions :gtk-type GdkDragAction))
   ((drag_unhighlight :c-name gtk_drag_unhighlight))
   ((drag_highlight :c-name gtk_drag_highlight))
   )



;;
;; GtkData
;; =======

;;;
;;; GtkWidget
;;; =========

;;; no constructor

;;
;; GtkItemFactory
;; ==============


(def-pgtk-methods GtkItemFactory gtk_item_factory
;   (create_items_ac (n_entries :gtk-type guint) (entries :gtk-type GtkItemFactoryEntry*) (callback_data :gtk-type gpointer) (callback_type :gtk-type guint))
;   (set_translate_func (func :gtk-type GtkTranslateFunc) (data :gtk-type gpointer) (notify :gtk-type GtkDestroyNotify))
;   ((popup_data :return-type gpointer))
;   (popup_with_data (popup_data :gtk-type gpointer) (destroy :gtk-type GtkDestroyNotify) (x :gtk-type guint) (y :gtk-type guint) (mouse_button :gtk-type guint) (time :gtk-type guint32))
   (popup (x :gtk-type guint) (y :gtk-type guint) (mouse_button :gtk-type guint) (time :gtk-type guint32))
;   (delete_entries (n_entries :gtk-type guint) (entries :gtk-type GtkItemFactoryEntry*))
;   (delete_entry (entry :gtk-type GtkItemFactoryEntry*))
   (delete_item (path :gtk-type const-gchar*))
   (create_items (n_entries :gtk-type guint) (entries :gtk-type GtkItemFactoryEntry*) (callback_data :gtk-type gpointer))
;   (create_item (entry :gtk-type GtkItemFactoryEntry*) (callback_data :gtk-type gpointer) (callback_type :gtk-type guint))
   ((get_item_by_action :return-type GtkWidget*) (action :gtk-type guint))
   ((get_widget_by_action :return-type GtkWidget*) (action :gtk-type guint))
   ((get_widget :return-type GtkWidget*) (path :gtk-type const-gchar*))
   ((get_item :return-type GtkWidget*) (path :gtk-type const-gchar*))
   (construct (container_type :gtk-type GtkType) (path :gtk-type const-gchar*) (accel_group :gtk-type GtkAccelGroup*))
   )

;;; constructor requires that I figure out container_type stuff, which doesn't look
;;; like it'll go quickly

;;;
;;; GtkContainer
;;; ============


(def-pgtk-methods GtkContainer gtk_container
;   (dequeue_resize_handler)
;   ((child_composite_name :return-type gchar*) (child :gtk-type GtkWidget*))
;   (forall (callback :gtk-type GtkCallback) (callback_data :gtk-type gpointer))
;   (arg_get (child :gtk-type GtkWidget*) (arg :gtk-type GtkArg*) (info :gtk-type GtkArgInfo*))
;   (arg_set (child :gtk-type GtkWidget*) (arg :gtk-type GtkArg*) (info :gtk-type GtkArgInfo*))
;   (clear_resize_widgets)
;   (queue_resize)
;   (child_set (child :gtk-type GtkWidget*) (first_arg_name :gtk-type const-gchar*))
;   (addv (widget :gtk-type GtkWidget*) (n_args :gtk-type guint) (args :gtk-type GtkArg*))
;   (add_with_args (widget :gtk-type GtkWidget*) (first_arg_name :gtk-type const-gchar*))
;   (child_setv (child :gtk-type GtkWidget*) (n_args :gtk-type guint) (args :gtk-type GtkArg*))
;   (child_getv (child :gtk-type GtkWidget*) (n_args :gtk-type guint) (args :gtk-type GtkArg*))
   ((child_type :return-type GtkType))
   (resize_children)
   (unregister_toplevel)
   (register_toplevel)
   (set_focus_hadjustment (adjustment :gtk-type GtkAdjustment*))
   (set_focus_vadjustment (adjustment :gtk-type GtkAdjustment*))
   (set_focus_child (child :gtk-type GtkWidget*))
   (set_reallocate_redraws (needs_redraws :gtk-type gboolean))
   ((focus :return-type gint) (direction :gtk-type GtkDirectionType))
;   ((children :return-type GList*))
;   (foreach_full (callback :gtk-type GtkCallback) (marshal :gtk-type GtkCallbackMarshal) (callback_data :gtk-type gpointer) (notify :gtk-type GtkDestroyNotify))
;   (foreach (callback :gtk-type GtkCallback) (callback_data :gtk-type gpointer))
   (check_resize)
   (set_resize_mode (resize_mode :gtk-type GtkResizeMode))
   (remove (widget :gtk-type GtkWidget*))
   (add (widget :gtk-type GtkWidget*))
   (set_border_width (border_width :gtk-type guint))
   )

;;
;; GtkBin
;; ======



;;; no constructor

;;;
;;; GtkButton
;;; =========
(defmethod GtkButton (GtkButton #!optional label)
   (gtk-object-init! $this
		     (if label
			 (gtk_button_new_with_label (convert-to-utf8 label))
			 (gtk_button_new))))


(def-pgtk-methods GtkButton gtk_button
   ((get_relief :return-type GtkReliefStyle))
   (set_relief (newstyle :gtk-type GtkReliefStyle))
   (leave)
   (enter)
   (clicked)
   (released)
   (pressed)
   )

;;
;; GtkCalendar
;; ===========



(defmethod gtkcalendar (gtkcalendar)
   (gtk-object-init! $this (gtk_calendar_new)))

(def-pgtk-methods GtkCalendar gtk_calendar
   (thaw)
   (freeze)
;   (get_date (year :gtk-type guint*) (month :gtk-type guint*) (day :gtk-type guint*))
   (display_options (flags :gtk-type GtkCalendarDisplayOptions))
   (clear_marks)
   ((unmark_day :return-type gint) (day :gtk-type guint))
   ((mark_day :return-type gint) (day :gtk-type guint))
   (select_day (day :gtk-type guint))
   ((select_month :return-type gint) (month :gtk-type guint) (year :gtk-type guint))
   )



(def-pgtk-methods GtkDrawingArea gtk_drawing_area
   (size (width :gtk-type gint) (height :gtk-type gint))
   )

(defmethod gtkdrawingarea (gtkdrawingarea)
   (gtk-object-init! $this (gtk_drawing_area_new)))


;;
;; GtkEditable
;; ===========


;;; no constructor

(def-pgtk-methods GtkEditable gtk_editable
   (set_editable (is_editable :gtk-type gboolean))
   ((get_position :return-type gint))
   (set_position (position :gtk-type gint))
   (changed)
   (delete_selection)
   (claim_selection (claim :gtk-type gboolean) (time :gtk-type guint32))
   (paste_clipboard)
   (copy_clipboard)
   (cut_clipboard)
   ((get_chars :return-type gchar*) (start_pos :gtk-type gint) (end_pos :gtk-type gint))
   (delete_text (start_pos :gtk-type gint) (end_pos :gtk-type gint))
;   (insert_text (new_text :gtk-type const-gchar*) (new_text_length :gtk-type gint) (position :gtk-type gint*))
   (select_region (start :gtk-type gint) (end :gtk-type gint))
   )

;;
;; GtkMisc
;; =======



(def-pgtk-methods GtkMisc gtk_misc
   (set_padding (xpad :gtk-type gint) (ypad :gtk-type gint))
   (set_alignment (xalign :gtk-type gfloat) (yalign :gtk-type gfloat))
   )

;;
;; GtkPixmap
;; =========


(defmethod gtkpixmap (gtkpixmap pixmap mask)
   (gtk-object-init! $this (gtk_pixmap_new
			    ;; a gdkpixmap
			    (gtk-object pixmap)
			    ;; and a gdkbitmap ... these need to be typechecked
			    (gtk-object mask))))

(def-pgtk-methods GtkPixmap gtk_pixmap
   (set_build_insensitive (build :gtk-type guint))
   (get (val :gtk-type GdkPixmap**) (mask :gtk-type GdkBitmap**))
   (set (val :gtk-type GdkPixmap*) (mask :gtk-type GdkBitmap*))
   )

;;
;; GtkPreview
;; ==========
 

(def-pgtk-methods GtkPreview gtk_preview
   (set_dither (dither :gtk-type GdkRgbDither))
   (set_expand (expand :gtk-type gboolean))
   (draw_row (data :gtk-type guchar*) (x :gtk-type gint) (y :gtk-type gint) (w :gtk-type gint))
   (put (window :gtk-type GdkWindow*) (gc :gtk-type GdkGC*) (srcx :gtk-type gint) (srcy :gtk-type gint) (destx :gtk-type gint) (desty :gtk-type gint) (width :gtk-type gint) (height :gtk-type gint))
   (size (width :gtk-type gint) (height :gtk-type gint))
   )

(defmethod gtkpreview (gtkpreview type)
   (gtk-object-init! $this (mkfixnum type)))
;    (let ((type::int (mkfixnum type)))
;       (gtk-object-init! $this
; 		       (pragma::GtkPreview* "gtk_preview_new($1)" type))))


;;;
;;; GtkProgress
;;; ===========


;;; no constructor

(def-pgtk-methods GtkProgress gtk_progress
   ((get_percentage_from_value :return-type gfloat) (value :gtk-type gfloat))
   ((get_current_percentage :return-type gfloat))
   ((get_text_from_value :return-type gchar*) (value :gtk-type gfloat))
   ((get_current_text :return-type gchar*))
   (set_activity_mode (activity_mode :gtk-type gboolean))
   ((get_value :return-type gfloat))
   (set_value (value :gtk-type gfloat))
   (set_percentage (percentage :gtk-type gfloat))
   (configure (value :gtk-type gfloat) (min :gtk-type gfloat) (max :gtk-type gfloat))
   (set_adjustment (adjustment :gtk-type GtkAdjustment*))
   (set_format_string (format :gtk-type const-gchar*))
   (set_text_alignment (x_align :gtk-type gfloat) (y_align :gtk-type gfloat))
   (set_show_text (show_text :gtk-type gboolean))
   )


;;
;; GtkRange
;; ========


;;; no constructor

(def-pgtk-methods GtkRange gtk_range
   (default_vmotion (xdelta :gtk-type gint) (ydelta :gtk-type gint))
   (default_hmotion (xdelta :gtk-type gint) (ydelta :gtk-type gint))
;   ((default_vtrough_click :return-type gint) (x :gtk-type gint) (y :gtk-type gint) (jump_perc :gtk-type gfloat*))
;   ((default_htrough_click :return-type gint) (x :gtk-type gint) (y :gtk-type gint) (jump_perc :gtk-type gfloat*))
   (default_vslider_update)
   (default_hslider_update)
;   ((trough_click :return-type gint) (x :gtk-type gint) (y :gtk-type gint) (jump_perc :gtk-type gfloat*))
   (slider_update)
   (draw_step_back)
   (draw_step_forw)
   (draw_slider)
   (draw_trough)
   (clear_background)
   (draw_background)
   (set_adjustment (adjustment :gtk-type GtkAdjustment*))
   (set_update_policy (policy :gtk-type GtkUpdateType))
   ((get_adjustment :return-type GtkAdjustment*))
   )

;;;
;;; GtkRuler
;;; ========


;;; no constructor

(def-pgtk-methods GtkRuler gtk_ruler
   (draw_pos)
   (draw_ticks)
   (set_range (lower :gtk-type gfloat) (upper :gtk-type gfloat) (position :gtk-type gfloat) (max_size :gtk-type gfloat))
   (set_metric (metric :gtk-type GtkMetricType))
   )


;;
;; GtkSeparator
;; ============


;;; no constructor

;;
;; GtkStatusbar
;; ============


(def-pgtk-methods GtkStatusbar gtk_statusbar
   (remove (context_id :gtk-type guint) (message_id :gtk-type guint))
   (pop (context_id :gtk-type guint))
   ((push :return-type guint) (context_id :gtk-type guint) (text :gtk-type const-gchar*))
   ((get_context_id :return-type guint) (context_description :gtk-type const-gchar*))
   )

(defmethod gtkstatusbar (gtkstatusbar)   
   (gtk-object-init! $this (gtk_statusbar_new)))

;;
;; GtkArrow
;; ========




(def-pgtk-methods GtkArrow gtk_arrow
   (set (arrow_type :gtk-type GtkArrowType) (shadow_type :gtk-type GtkShadowType))
   )

(defmethod GtkArrow (gtkarrow arrow_type shadow_type)
   (gtk-object-init! $this
		     (gtk_arrow_new
		      (gtk-enum-value 'GtkArrowType arrow_type)
		      (gtk-enum-value 'GtkShadowType shadow_type))))
   
;;
;; GtkImage
;; ========

;;; not implemented in bigloo-lib OR php-gtk

(def-pgtk-methods GtkImage gtk_image
   (get (val :gtk-type GdkImage**) (mask :gtk-type GdkBitmap**))
   (set (val :gtk-type GdkImage*) (mask :gtk-type GdkBitmap*))
   )

;;
;; GtkLabel
;; ========


(def-pgtk-methods GtkLabel gtk_label
   ((parse_uline :return-type guint) (string :gtk-type const-gchar*))
;   (get (str :gtk-type gchar**))
   (set_line_wrap (wrap :gtk-type gboolean))
   (set_pattern (pattern :gtk-type const-gchar* :default NULL))
   (set_justify (jtype :gtk-type GtkJustification))
   (set_text (str :gtk-type const-gchar*))
   )

(defmethod GtkLabel (gtklabel #!optional text)
   (gtk-object-init! $this (gtk_label_new
			    (if text
				(mkstr text)
				(pragma::gchar* "NULL")))))




;;
;; GtkBox
;; ======



(def-pgtk-methods GtkBox gtk_box
   (set_child_packing (child :gtk-type GtkWidget*) (expand :gtk-type gboolean) (fill :gtk-type gboolean) (padding :gtk-type guint) (pack_type :gtk-type GtkPackType))
;   (query_child_packing (child :gtk-type GtkWidget*) (expand :gtk-type gboolean*) (fill :gtk-type gboolean*) (padding :gtk-type guint*) (pack_type :gtk-type GtkPackType*))
   (reorder_child (child :gtk-type GtkWidget*) (position :gtk-type gint))
   (set_spacing (spacing :gtk-type gint))
   (set_homogeneous (homogeneous :gtk-type gboolean))
   (pack_end_defaults (widget :gtk-type GtkWidget*))
   (pack_start_defaults (widget :gtk-type GtkWidget*))
   (pack_end (child :gtk-type GtkWidget*) (expand :gtk-type gboolean :default TRUE) (fill :gtk-type gboolean :default TRUE) (padding :gtk-type guint :default 0))
   (pack_start (child :gtk-type GtkWidget*) (expand :gtk-type gboolean :default TRUE) (fill :gtk-type gboolean :default TRUE) (padding :gtk-type guint :default 0))
   )


;;
;; GtkCList
;; ========


;    (lambda (props)
;       props))

(def-pgtk-methods GtkCList gtk_clist
   (set_auto_sort (auto_sort :gtk-type gboolean))
   (sort)
   (set_sort_type (sort_type :gtk-type GtkSortType))
   (set_sort_column (column :gtk-type gint))
   (set_compare_func (cmp_func :gtk-type GtkCListCompareFunc))
   (row_move (source_row :gtk-type gint) (dest_row :gtk-type gint))
   (swap_rows (row1 :gtk-type gint) (row2 :gtk-type gint))
   (unselect_all)
   (select_all)
;   ((get_selection_info :return-type gint) (x :gtk-type gint) (y :gtk-type gint) (row :gtk-type gint*) (column :gtk-type gint*))
   (clear)
   (undo_selection)
   (unselect_row (row :gtk-type gint) (column :gtk-type gint))
   (select_row (row :gtk-type gint) (column :gtk-type gint))
;   ((find_row_from_data :return-type gint) (data :gtk-type gpointer))
;   ((get_row_data :return-type gpointer) (row :gtk-type gint))
;   (set_row_data_full (row :gtk-type gint) (data :gtk-type gpointer) (destroy :gtk-type GtkDestroyNotify))
   (set_row_data (row :gtk-type gint) (data :gtk-type gpointer))
   (remove (row :gtk-type gint))
;   ((insert :return-type gint) (row :gtk-type gint) (text :gtk-type gchar**))
;   ((append :return-type gint) (text :gtk-type gchar**))
   ((prepend :return-type gint) (text :gtk-type gchar**))
   ((get_selectable :return-type gboolean) (row :gtk-type gint))
   (set_selectable (row :gtk-type gint) (selectable :gtk-type gboolean))
   (set_shift (row :gtk-type gint) (column :gtk-type gint) (vertical :gtk-type gint) (horizontal :gtk-type gint))
   ((get_row_style :return-type GtkStyle*) (row :gtk-type gint))
   (set_row_style (row :gtk-type gint) (style :gtk-type GtkStyle* :null-ok #t))
   ((get_cell_style :return-type GtkStyle*) (row :gtk-type gint) (column :gtk-type gint))
   (set_cell_style (row :gtk-type gint) (column :gtk-type gint) (style :gtk-type GtkStyle*))
   (set_background (row :gtk-type gint) (color :gtk-type GdkColor*))
   (set_foreground (row :gtk-type gint) (color :gtk-type GdkColor*))
;   ((get_pixtext :return-type gint) (row :gtk-type gint) (column :gtk-type gint) (text :gtk-type gchar**) (spacing :gtk-type guint8*) (pixmap :gtk-type GdkPixmap**) (mask :gtk-type GdkBitmap**))
   (set_pixtext (row :gtk-type gint) (column :gtk-type gint) (text :gtk-type const-gchar*) (spacing :gtk-type guint8) (pixmap :gtk-type GdkPixmap*) (mask :gtk-type GdkBitmap*))
;   ((get_pixmap :return-type gint) (row :gtk-type gint) (column :gtk-type gint) (pixmap :gtk-type GdkPixmap**) (mask :gtk-type GdkBitmap**))
   (set_pixmap (row :gtk-type gint) (column :gtk-type gint) (pixmap :gtk-type GdkPixmap*) (mask :gtk-type GdkBitmap* :null-ok #t))
;   ((get_text :return-type gint) (row :gtk-type gint) (column :gtk-type gint) (text :gtk-type gchar**))
   (set_text (row :gtk-type gint) (column :gtk-type gint) (text :gtk-type const-gchar*))
   ((get_cell_type :return-type GtkCellType) (row :gtk-type gint) (column :gtk-type gint))
   ((row_is_visible :return-type GtkVisibility) (row :gtk-type gint))
   (moveto (row :gtk-type gint) (column :gtk-type gint) (row_align :gtk-type gfloat) (col_align :gtk-type gfloat))
   (set_row_height (height :gtk-type guint))
   (set_column_max_width (column :gtk-type gint) (max_width :gtk-type gint))
   (set_column_min_width (column :gtk-type gint) (min_width :gtk-type gint))
   (set_column_width (column :gtk-type gint) (width :gtk-type gint))
   ((optimal_column_width :return-type gint) (column :gtk-type gint))
   ((columns_autosize :return-type gint))
   (set_column_auto_resize (column :gtk-type gint) (auto_resize :gtk-type gboolean))
   (set_column_resizeable (column :gtk-type gint) (resizeable :gtk-type gboolean))
   (set_column_visibility (column :gtk-type gint) (visible :gtk-type gboolean))
   (set_column_justification (column :gtk-type gint) (justification :gtk-type GtkJustification))
   ((get_column_widget :return-type GtkWidget*) (column :gtk-type gint))
   (set_column_widget (column :gtk-type gint) (widget :gtk-type GtkWidget*))
   ((get_column_title :return-type gchar*) (column :gtk-type gint))
   (set_column_title (column :gtk-type gint) (title :gtk-type const-gchar*))
   (column_titles_passive)
   (column_titles_active)
   (column_title_passive (column :gtk-type gint))
   (column_title_active (column :gtk-type gint))
   (column_titles_hide)
   (column_titles_show)
   (thaw)
   (freeze)
   (set_button_actions (button :gtk-type guint) (button_actions :gtk-type guint8))
   (set_use_drag_icons (use_icons :gtk-type gboolean))
   (set_reorderable (reorderable :gtk-type gboolean))
   (set_selection_mode (mode :gtk-type GtkSelectionMode))
   (set_shadow_type (type :gtk-type GtkShadowType))
   ((get_vadjustment :return-type GtkAdjustment*))
   ((get_hadjustment :return-type GtkAdjustment*))
   (set_vadjustment (adjustment :gtk-type GtkAdjustment*))
   (set_hadjustment (adjustment :gtk-type GtkAdjustment*))
;   (construct (columns :gtk-type gint) (titles :gtk-type gchar**))
   )

(defmethod gtkclist (gtkclist columns titles)
   (set! titles (maybe-unbox titles))
   (set! columns (mkfixnum columns))
   (cond
      ((<= columns 0)
       (php-warning "Number of columns must be > 0.")
       +constructor-failed+)
      ((php-hash? titles)
       (if (< (php-hash-size titles) columns)
	   (begin
	      (php-warning "The array of titles is not long enough.")
	      +constructor-failed+)
	   (let ((titles (map mkstr (php-hash->list titles))))
	      (gtk-object-init! $this
				(gtk_clist_new_with_titles columns
							   (string-list->string*
							    (map convert-to-utf8 titles)))))))
      (else
       (gtk_clist_new columns))))




;; GtkCListRow
;; ===========


(define (php-gtk-clist-row-new obj::GtkCListRow*)
   (if (foreign-null? obj)
       NULL
       (let ((new-obj (construct-php-object-sans-constructor 'gtkclistrow)))
	  ;;XXX not sure that this is right
	  ;;seems like php-gtk doesn't add a reference to the gtkclistrow
;	  (gtk-object-init! new-obj obj)
	  (gtk-object-set! new-obj obj)
	  new-obj)))


;; GtkCTreeNode
;; ===========


(define (php-gtk-ctree-node-new obj)
   (if (foreign-null? obj)
       (begin
	  (php-warning "null ctreenode")
	  NULL)
       (let ((new-obj (construct-php-object-sans-constructor 'gtkctreenode)))
	  (let ((obj::GtkCTreeNode* obj))
	  ;;XXX not sure that this is right
	  ;;seems like php-gtk doesn't add a reference to the gtkctreenode
;	  (gtk-object-init! new-obj obj)
	     (gtk-object-set! new-obj obj)
	     new-obj))))




;; GtkFixed
;; ========





(def-pgtk-methods GtkFixed gtk_fixed
   (move (widget :gtk-type GtkWidget*) (x :gtk-type gint16) (y :gtk-type gint16))
   (put (widget :gtk-type GtkWidget*) (x :gtk-type gint16) (y :gtk-type gint16))
   )

(defmethod gtkfixed (gtkfixed)
   (gtk-object-init! $this (gtk_fixed_new)))

;;
;; GtkLayout
;; =========



(def-pgtk-methods GtkLayout gtk_layout
   (thaw)
   (freeze)
   (set_vadjustment (adjustment :gtk-type GtkAdjustment*))
   (set_hadjustment (adjustment :gtk-type GtkAdjustment*))
   ((get_vadjustment :return-type GtkAdjustment*))
   ((get_hadjustment :return-type GtkAdjustment*))
   (set_size (width :gtk-type guint) (height :gtk-type guint))
   (move (widget :gtk-type GtkWidget*) (x :gtk-type gint) (y :gtk-type gint))
   (put (widget :gtk-type GtkWidget*) (x :gtk-type gint) (y :gtk-type gint))
   )

(defmethod gtklayout (gtklayout #!optional hadj vadj)
   (gtk-object-init! $this (gtk_layout_new
			    (get-adjustment hadj)
			    (get-adjustment vadj))))


;;
;; GtkList
;; =======



(defmethod gtklist (gtklist)
   (gtk-object-init! $this (gtk_list_new)))

(def-pgtk-methods GtkList gtk_list
   (end_drag_selection)
   (undo_selection)
   (toggle_row (item :gtk-type GtkWidget*))
   (toggle_focus_row)
   (toggle_add_mode)
   (scroll_vertical (scroll_type :gtk-type GtkScrollType) (position :gtk-type gfloat))
   (scroll_horizontal (scroll_type :gtk-type GtkScrollType) (position :gtk-type gfloat))
   (unselect_all)
   (select_all)
   (end_selection)
   (start_selection)
   (extend_selection (scroll_type :gtk-type GtkScrollType) (position :gtk-type gfloat) (auto_start_selection :gtk-type gboolean))
   (set_selection_mode (mode :gtk-type GtkSelectionMode))
   ((child_position :return-type gint) (child :gtk-type GtkWidget*))
   (unselect_child (child :gtk-type GtkWidget*))
   (select_child (child :gtk-type GtkWidget*))
   (unselect_item (item :gtk-type gint))
   (select_item (item :gtk-type gint))
   (clear_items (start :gtk-type gint) (end :gtk-type gint))
; (not in php-gtk)  (remove_items_no_unref (items :gtk-type GList*))
;   (remove_items (items :gtk-type GList*))
;   (prepend_items (items :gtk-type GList*))
;   (append_items (items :gtk-type GList*))
;   (insert_items (items :gtk-type GList*) (position :gtk-type gint))
   )

;;
;; GtkMenuShell
;; ============


(def-pgtk-methods GtkMenuShell gtk_menu_shell
   (activate_item (menu_item :gtk-type GtkWidget*) (force_deactivate :gtk-type gboolean))
   (deselect)
   (select_item (menu_item :gtk-type GtkWidget*))
   (deactivate)
   (insert (child :gtk-type GtkWidget*) (position :gtk-type gint))
   (prepend (child :gtk-type GtkWidget*))
   (append (child :gtk-type GtkWidget*))
   )

;;
;; GtkNotebook
;; ===========



(def-pgtk-methods GtkNotebook gtk_notebook
   (reorder_child (child :gtk-type GtkWidget*) (position :gtk-type gint))
   (set_tab_label_packing (child :gtk-type GtkWidget*) (expand :gtk-type gboolean) (fill :gtk-type gboolean) (pack_type :gtk-type GtkPackType))
   (query_tab_label_packing (child :gtk-type GtkWidget*) (expand :gtk-type gboolean*) (fill :gtk-type gboolean*) (pack_type :gtk-type GtkPackType*))
   (set_menu_label_text (child :gtk-type GtkWidget*) (menu_text :gtk-type const-gchar*))
   (set_menu_label (child :gtk-type GtkWidget*) (menu_label :gtk-type GtkWidget*))
   ((get_menu_label :return-type GtkWidget*) (child :gtk-type GtkWidget*))
   (set_tab_label_text (child :gtk-type GtkWidget*) (tab_text :gtk-type const-gchar*))
   (set_tab_label (child :gtk-type GtkWidget*) (tab_label :gtk-type GtkWidget*))
   ((get_tab_label :return-type GtkWidget*) (child :gtk-type GtkWidget*))
   (popup_disable)
   (popup_enable)
   (set_scrollable (scrollable :gtk-type gboolean))
   (set_tab_vborder (tab_vborder :gtk-type guint))
   (set_tab_hborder (tab_hborder :gtk-type guint))
   (set_tab_border (border_width :gtk-type guint))
   (set_homogeneous_tabs (homogeneous :gtk-type gboolean))
   (set_tab_pos (pos :gtk-type GtkPositionType))
   (set_show_tabs (show_tabs :gtk-type gboolean))
   (set_show_border (show_border :gtk-type gboolean))
   (prev_page)
   (next_page)
   (set_page (page_num :gtk-type gint))
   ((page_num :return-type gint) (child :gtk-type GtkWidget*))
   ((get_nth_page :return-type GtkWidget*) (page_num :gtk-type gint))
   ((get_current_page :return-type gint))
   (remove_page (page_num :gtk-type gint))
   (insert_page_menu (child :gtk-type GtkWidget*) (tab_label :gtk-type GtkWidget*) (menu_label :gtk-type GtkWidget*) (position :gtk-type gint))
   (insert_page (child :gtk-type GtkWidget*) (tab_label :gtk-type GtkWidget*) (position :gtk-type gint))
   (prepend_page_menu (child :gtk-type GtkWidget*) (tab_label :gtk-type GtkWidget*) (menu_label :gtk-type GtkWidget*))
   (prepend_page (child :gtk-type GtkWidget*) (tab_label :gtk-type GtkWidget*))
   (append_page_menu (child :gtk-type GtkWidget*) (tab_label :gtk-type GtkWidget*) (menu_label :gtk-type GtkWidget*))
   (append_page (child :gtk-type GtkWidget*) (tab_label :gtk-type GtkWidget*))
   )

(defmethod gtknotebook (gtknotebook)
   (gtk-object-init! $this (gtk_notebook_new)))

;;
;; GtkPacker
;; =========


;;; XXX constructor exists in php-gtk but is not implemented by bigloo-lib

(def-pgtk-methods GtkPacker gtk_packer
   (set_default_ipad (i_pad_x :gtk-type guint) (i_pad_y :gtk-type guint))
   (set_default_pad (pad_x :gtk-type guint) (pad_y :gtk-type guint))
   (set_default_border_width (border :gtk-type guint))
   (set_spacing (spacing :gtk-type guint))
   (reorder_child (child :gtk-type GtkWidget*) (position :gtk-type gint))
   (set_child_packing (child :gtk-type GtkWidget*) (side :gtk-type GtkSideType) (anchor :gtk-type GtkAnchorType) (options :gtk-type GtkPackerOptions) (border_width :gtk-type guint :default 0) (pad_x :gtk-type guint :default 0) (pad_y :gtk-type guint :default 0) (i_pad_x :gtk-type guint :default 0) (i_pad_y :gtk-type guint :default 0))
   (add (child :gtk-type GtkWidget*) (side :gtk-type GtkSideType) (anchor :gtk-type GtkAnchorType) (options :gtk-type GtkPackerOptions) (border_width :gtk-type guint :default 0) (pad_x :gtk-type guint :default 0) (pad_y :gtk-type guint :default 0) (i_pad_x :gtk-type guint :default 0) (i_pad_y :gtk-type guint :default 0))
   (add_defaults (child :gtk-type GtkWidget*) (side :gtk-type GtkSideType) (anchor :gtk-type GtkAnchorType) (options :gtk-type GtkPackerOptions))
   )

;;
;; GtkPaned
;; ========



(def-pgtk-methods GtkPaned gtk_paned
   (set_gutter_size (size :gtk-type guint16))
   (set_handle_size (size :gtk-type guint16))
   (set_position (position :gtk-type gint))
   (pack2 (child :gtk-type GtkWidget*) (resize :gtk-type gboolean :default TRUE) (shrink :gtk-type gboolean :default TRUE))
   (pack1 (child :gtk-type GtkWidget*) (resize :gtk-type gboolean :default FALSE) (shrink :gtk-type gboolean :default TRUE))
   (add2 (child :gtk-type GtkWidget*))
   (add1 (child :gtk-type GtkWidget*))
   )

;;
;; GtkSocket
;; =========


(def-pgtk-methods GtkSocket gtk_socket
   (steal (wid :gtk-type guint32))
   )

;;
;; GtkTable
;; ========




(defmethod GtkTable (GtkTable #!optional (rows 1) (columns 1) (homogeneous? FALSE))
   (gtk-object-init! $this
		     (gtk_table_new (mkfixnum rows)
				    (mkfixnum columns)
				    (if (convert-to-boolean homogeneous?)
					1
					0))))

(def-pgtk-methods GtkTable gtk_table
   (set_homogeneous (homogeneous :gtk-type gboolean))
   (set_col_spacings (spacing :gtk-type guint))
   (set_row_spacings (spacing :gtk-type guint))
   (set_col_spacing (column :gtk-type guint) (spacing :gtk-type guint))
   (set_row_spacing (row :gtk-type guint) (spacing :gtk-type guint))
   (attach_defaults (widget :gtk-type GtkWidget*) (left_attach :gtk-type guint) (right_attach :gtk-type guint) (top_attach :gtk-type guint) (bottom_attach :gtk-type guint))
   (attach (widget :gtk-type GtkWidget*) (left_attach :gtk-type guint) (right_attach :gtk-type guint) (top_attach :gtk-type guint) (bottom_attach :gtk-type guint) (xoptions :gtk-type GtkAttachOptions :default (bitwise-or GTK_EXPAND GTK_FILL)) (yoptions :gtk-type GtkAttachOptions :default (bitwise-or GTK_EXPAND GTK_FILL)) (xpadding :gtk-type guint :default 0) (ypadding :gtk-type guint :default 0))
   (resize (rows :gtk-type guint) (columns :gtk-type guint))
   )

;;
;; GtkToolbar
;; ==========




(defmethod gtktoolbar (gtktoolbar orientation style)
   (gtk-object-init! $this
		     (gtk_toolbar_new
		      (gtk-enum-value 'GtkOrientation orientation)
		      (gtk-enum-value 'GtkToolbarStyle style))))

(def-pgtk-methods GtkToolbar gtk_toolbar
   ((get_button_relief :return-type GtkReliefStyle))
   (set_button_relief (relief :gtk-type GtkReliefStyle))
   (set_tooltips (enable :gtk-type gint))
   (set_space_style (space_style :gtk-type GtkToolbarSpaceStyle))
   (set_space_size (space_size :gtk-type gint))
   (set_style (style :gtk-type GtkToolbarStyle))
   (set_orientation (orientation :gtk-type GtkOrientation))
   (insert_widget (widget :gtk-type GtkWidget*) (tooltip_text :gtk-type const-char*) (tooltip_private_text :gtk-type const-char*) (position :gtk-type gint))
   (prepend_widget (widget :gtk-type GtkWidget*) (tooltip_text :gtk-type const-char*) (tooltip_private_text :gtk-type const-char*))
   (append_widget (widget :gtk-type GtkWidget*) (tooltip_text :gtk-type const-char*) (tooltip_private_text :gtk-type const-char*))
   ((insert_element :return-type GtkWidget*) (type :gtk-type GtkToolbarChildType) (widget :gtk-type GtkWidget*) (text :gtk-type const-char*) (tooltip_text :gtk-type const-char*) (tooltip_private_text :gtk-type const-char*) (icon :gtk-type GtkWidget*) (callback :gtk-type GtkSignalFunc) (user_data :gtk-type gpointer) (position :gtk-type gint))
   ((prepend_element :return-type GtkWidget*) (type :gtk-type GtkToolbarChildType) (widget :gtk-type GtkWidget*) (text :gtk-type const-char*) (tooltip_text :gtk-type const-char*) (tooltip_private_text :gtk-type const-char*) (icon :gtk-type GtkWidget*) (callback :gtk-type GtkSignalFunc) (user_data :gtk-type gpointer))
   ((append_element :return-type GtkWidget*) (type :gtk-type GtkToolbarChildType) (widget :gtk-type GtkWidget*) (text :gtk-type const-char*) (tooltip_text :gtk-type const-char*) (tooltip_private_text :gtk-type const-char*) (icon :gtk-type GtkWidget*) (callback :gtk-type GtkSignalFunc) (user_data :gtk-type gpointer))
   (insert_space (position :gtk-type gint))
   (prepend_space)
   (append_space)
;   ((insert_item :return-type GtkWidget*) (text :gtk-type const-char*) (tooltip_text :gtk-type const-char*) (tooltip_private_text :gtk-type const-char*) (icon :gtk-type GtkWidget*) (callback :gtk-type GtkSignalFunc) (user_data :gtk-type gpointer) (position :gtk-type gint))
;   ((prepend_item :return-type GtkWidget*) (text :gtk-type const-char*) (tooltip_text :gtk-type const-char*) (tooltip_private_text :gtk-type const-char*) (icon :gtk-type GtkWidget*) (callback :gtk-type GtkSignalFunc) (user_data :gtk-type gpointer))
;   ((append_item :return-type GtkWidget*) (text :gtk-type const-char*) (tooltip_text :gtk-type const-char*) (tooltip_private_text :gtk-type const-char*) (icon :gtk-type GtkWidget*) (callback :gtk-type GtkSignalFunc) (user_data :gtk-type gpointer))
   )

;;;
;;; GtkTree
;;; =======


;;; GtkTree->GtkTree
(defmethod GtkTree (GtkTree)
   (gtk-object-init! $this (gtk_tree_new)))


(def-pgtk-methods GtkTree gtk_tree
   (remove_item (child :gtk-type GtkWidget*))
   (set_view_lines (flag :gtk-type guint))
   (set_view_mode (mode :gtk-type GtkTreeViewMode))
   (set_selection_mode (mode :gtk-type GtkSelectionMode))
   ((child_position :return-type gint) (child :gtk-type GtkWidget*))
   (unselect_child (tree_item :gtk-type GtkWidget*))
   (select_child (tree_item :gtk-type GtkWidget*))
   (unselect_item (item :gtk-type gint))
   (select_item (item :gtk-type gint))
   (clear_items (start :gtk-type gint) (end :gtk-type gint))
   (remove_items (items :gtk-type GList*))
   (insert (tree_item :gtk-type GtkWidget*) (position :gtk-type gint))
   (prepend (tree_item :gtk-type GtkWidget*))
   (append (tree_item :gtk-type GtkWidget*))
   )

;;
;; GtkAlignment
;; ============


(def-pgtk-methods GtkAlignment gtk_alignment
   (set (xalign :gtk-type gfloat) (yalign :gtk-type gfloat) (xscale :gtk-type gfloat) (yscale :gtk-type gfloat))
   )

(defmethod gtkalignment (gtkalignment xalign yalign xscale yscale)
   (gtk-object-init! $this (gtk_alignment_new (onum->float (convert-to-number (maybe-unbox xalign)))
					     (onum->float (convert-to-number (maybe-unbox yalign)))
					     (onum->float (convert-to-number (maybe-unbox xscale)))
					     (onum->float (convert-to-number (maybe-unbox yscale))))))

;;
;; GtkEventBox
;; ===========


(defmethod gtkeventbox (gtkeventbox)
   (gtk-object-init! $this (gtk_event_box_new)))


;;
;; GtkFrame
;; ========


(defmethod gtkframe (gtkframe #!optional label)
   (gtk-object-init! $this
		        (if label
			    (gtk_frame_new (mkstr label))
			    (gtk_frame_new (pragma::gchar* "NULL")))))

(def-pgtk-methods GtkFrame gtk_frame
   (set_shadow_type (type :gtk-type GtkShadowType))
   (set_label_align (xalign :gtk-type gfloat) (yalign :gtk-type gfloat))
   (set_label (label :gtk-type const-gchar* :null-ok #t))
   )

;;
;; GtkHandleBox
;; ============


(defmethod gtkhandlebox (gtkhandlebox)
   (gtk-object-init! $this (gtk_handle_box_new)))

(def-pgtk-methods GtkHandleBox gtk_handle_box
   (set_snap_edge (edge :gtk-type GtkPositionType))
   (set_handle_position (position :gtk-type GtkPositionType))
   (set_shadow_type (type :gtk-type GtkShadowType))
   )

;;
;; GtkInvisible
;; ============



      
;;
;; GtkItem
;; =======


(def-pgtk-methods GtkItem gtk_item
   (toggle)
   (deselect)
   (select)
   )


;;; no constructor

;;
;; GtkScrolledWindow
;; =================


(defmethod gtkscrolledwindow (gtkscrolledwindow #!optional hadj vadj)
   (gtk-object-init! $this
		     (gtk_scrolled_window_new
		      (get-adjustment hadj)
		      (get-adjustment vadj))))

(def-pgtk-methods GtkScrolledWindow gtk_scrolled_window
   (add_with_viewport (child :gtk-type GtkWidget*))
   (set_placement (window_placement :gtk-type GtkCornerType))
   (set_policy (hscrollbar_policy :gtk-type GtkPolicyType) (vscrollbar_policy :gtk-type GtkPolicyType))
   ((get_vadjustment :return-type GtkAdjustment*))
   ((get_hadjustment :return-type GtkAdjustment*))
   (set_vadjustment (hadjustment :gtk-type GtkAdjustment*))
   (set_hadjustment (hadjustment :gtk-type GtkAdjustment*))
   )

;;
;; GtkViewport
;; ===========


(def-pgtk-methods GtkViewport gtk_viewport
   (set_shadow_type (type :gtk-type GtkShadowType))
   (set_vadjustment (adjustment :gtk-type GtkAdjustment*))
   (set_hadjustment (adjustment :gtk-type GtkAdjustment*))
   ((get_vadjustment :return-type GtkAdjustment*))
   ((get_hadjustment :return-type GtkAdjustment*))
   )

(defmethod gtkviewport (gtkviewport #!optional hadj vadj)
   (gtk-object-init! $this
		     (gtk_viewport_new (get-adjustment hadj)
				       (get-adjustment vadj))))

;;
;; GtkWindow
;; =========

(def-pgtk-methods GtkWindow gtk_window
;   (reposition (x :gtk-type gint) (y :gtk-type gint))
;   (add_embedded_xid (xid :gtk-type guint))
;   (remove_embedded_xid (xid :gtk-type guint))
   (set_default (defaultw :gtk-type GtkWidget*))
   (set_focus (focus :gtk-type GtkWidget*))
   (set_modal (modal :gtk-type gboolean))
   (set_default_size (width :gtk-type gint) (height :gtk-type gint))
   (set_geometry_hints (geometry_widget :gtk-type GtkWidget*) (geometry :gtk-type GdkGeometry*) (geom_mask :gtk-type GdkWindowHints))
   (set_transient_for (parent :gtk-type GtkWindow*))
   ((activate_default :return-type gint))
   ((activate_focus :return-type gint))
   (set_position (position :gtk-type GtkWindowPosition))
   (remove_accel_group (accel_group :gtk-type GtkAccelGroup*))
   (add_accel_group (accel_group :gtk-type GtkAccelGroup*))
   (set_policy (allow_shrink :gtk-type gint) (allow_grow :gtk-type gint) (auto_shrink :gtk-type gint))
   (set_wmclass (wmclass_name :gtk-type const-gchar*) (wmclass_class :gtk-type const-gchar*))
   (set_title (title :gtk-type const-gchar*))
   )

(defmethod GtkWindow (GtkWindow #!optional (type GTK_WINDOW_TOPLEVEL))
   (gtk-object-init! $this (gtk_window_new (gtk-enum-value 'GtkWindowType type))))


;;
;; GtkAdjustment
;; =============



(def-pgtk-methods GtkAdjustment gtk_adjustment
   (set_value (value :gtk-type gfloat))
   (clamp_page (lower :gtk-type gfloat) (upper :gtk-type gfloat))
   (value_changed)
   (changed)
   )

(defmethod gtkadjustment (gtkadjustment value lower upper step-increment page-increment page-size)
   (gtk-object-init! $this
		    (gtk_adjustment_new (onum->float (convert-to-number (maybe-unbox value)))
					(onum->float (convert-to-number (maybe-unbox lower)))
					(onum->float (convert-to-number (maybe-unbox upper)))
					(onum->float (convert-to-number (maybe-unbox step-increment)))
					(onum->float (convert-to-number (maybe-unbox page-increment)))
					(onum->float (convert-to-number (maybe-unbox page-size))))))

;;
;; GtkTooltips
;; ===========


(defmethod GtkTooltips (GtkTooltips)
   (gtk-object-init! $this (gtk_tooltips_new)))

(def-pgtk-methods GtkTooltips gtk_tooltips
   (force_window)
   (set_colors (background :gtk-type GdkColor*) (foreground :gtk-type GdkColor*))
   (set_tip (widget :gtk-type GtkWidget*) (tip_text :gtk-type const-gchar*) (tip_private :gtk-type const-gchar* :default ""))
   (set_delay (delay :gtk-type guint))
   (disable)
   (enable)
   )

;;
;; GtkButtonBox
;; ============



;;; no constructor

(def-pgtk-methods GtkButtonBox gtk_button_box
   (set_child_ipadding (ipad_x :gtk-type gint) (ipad_y :gtk-type gint))
   (set_child_size (min_width :gtk-type gint) (min_height :gtk-type gint))
   (set_layout (layout_style :gtk-type GtkButtonBoxStyle))
   (set_spacing (spacing :gtk-type gint))
   (get_child_ipadding (ipad_x :gtk-type gint*) (ipad_y :gtk-type gint*))
   (get_child_size (min_width :gtk-type gint*) (min_height :gtk-type gint*))
   ((get_layout :return-type GtkButtonBoxStyle))
   ((get_spacing :return-type gint))
   )

;;
;; GtkHBox
;; =======


(defmethod gtkhbox (gtkhbox #!optional (homogenous FALSE) (spacing 0))
   (gtk-object-init! $this (gtk_hbox_new
			    (if (convert-to-boolean homogenous)
				1
				0)
			    (mkfixnum spacing))))


;;
;; GtkVBox
;; =======


(defmethod gtkvbox (gtkvbox #!optional (homogenous FALSE) (spacing 0))
   (gtk-object-init! $this (gtk_vbox_new
			    (if (convert-to-boolean homogenous)
				1
				0)
			    (mkfixnum spacing))))

;;
;; GtkListItem
;; ===========


(def-pgtk-methods GtkListItem gtk_list_item
   (deselect)
   (select)
   )

(defmethod gtklistitem (gtklistitem label)
   (gtk-object-init! $this
		     (gtk_list_item_new_with_label
		      (if label
			  (convert-to-utf8 label)
			  (pragma::gchar* "NULL")))))


;;
;; GtkMenuItem
;; ===========


(def-pgtk-methods GtkMenuItem gtk_menu_item
   (right_justify)
   (activate)
   (deselect)
   (select)
   (configure (show_toggle_indicator :gtk-type gint) (show_submenu_indicator :gtk-type gint))
   (set_placement (placement :gtk-type GtkSubmenuPlacement))
   (remove_submenu)
   (set_submenu (submenu :gtk-type GtkWidget*))
   )

(defmethod gtkmenuitem (gtkmenuitem #!optional label)
   (gtk-object-init! $this (if label
			      (gtk_menu_item_new_with_label (convert-to-utf8 label))
			      (gtk_menu_item_new))))


;;
;; GtkTreeItem
;; ===========

(defmethod GtkTreeItem (GtkTreeItem #!optional label)
   (gtk-object-init! $this (if label
			       (gtk_tree_item_new_with_label (convert-to-utf8 label))
			       (gtk_tree_item_new))))

(def-pgtk-methods GtkTreeItem gtk_tree_item
   (collapse)
   (expand)
   (deselect)
   (select)
   (remove_subtree)
   (set_subtree (subtree :gtk-type GtkWidget*))
   )

;;; php-gtk documentation not clear on what args the constructor takes

;;
;; GtkColorSelectionDialog
;; =======================




(defmethod gtkcolorselectiondialog (gtkcolorselectiondialog title)
   (gtk-object-init! $this (gtk_color_selection_dialog_new (mkstr title))))

;;
;; GtkDialog
;; =========



(defmethod gtkdialog (gtkdialog)
   (gtk-object-init! $this (gtk_dialog_new)))


;;
;; GtkFileSelection
;; ================



(defmethod gtkfileselection (gtkfileselection #!optional title)
   (gtk-object-init! $this
		     (gtk_file_selection_new
		      (if title
			  (mkstr title)
			  (pragma::gchar* "NULL")))))


(def-pgtk-methods GtkFileSelection gtk_file_selection
   (hide_fileop_buttons)
   (show_fileop_buttons)
   (complete (pattern :gtk-type const-gchar*))
   ((get_filename :return-type gchar*))
   (set_filename (filename :gtk-type const-gchar*))
   )

;;
;; GtkFontSelectionDialog
;; ======================



(defmethod gtkfontselectiondialog (gtkfontselectiondialog title)
   (gtk-object-init! $this (gtk_font_selection_dialog_new (mkstr title))))


(def-pgtk-methods GtkFontSelectionDialog gtk_font_selection_dialog
   (set_preview_text (text :gtk-type const-gchar*))
   ((get_preview_text :return-type gchar*))
   (set_filter (filter_type :gtk-type GtkFontFilterType) (font_type :gtk-type GtkFontType) (foundries :gtk-type gchar**) (weights :gtk-type gchar**) (slants :gtk-type gchar**) (setwidths :gtk-type gchar**) (spacings :gtk-type gchar**) (charsets :gtk-type gchar**))
   ((set_font_name :return-type gboolean) (fontname :gtk-type const-gchar*))
   ((get_font :return-type GdkFont*))
   ((get_font_name :return-type gchar*))
   )


;;
;; GtkPlug
;; =======


(def-pgtk-methods GtkPlug gtk_plug
   ;;weird.. this looks like a constructor
   (construct (socket_id :gtk-type guint32))
   )

(defmethod gtkplug (gtkplug socket_id)
   (gtk-object-init! $this (gtk_plug_new (mkfixnum socket_id))))


;;
;; GtkInputDialog
;; ==============



(defmethod gtkinputdialog (gtkinputdialog)
   (gtk-object-init! $this (gtk_input_dialog_new)))

;;
;; GtkAspectFrame
;; ==============


(def-pgtk-methods GtkAspectFrame gtk_aspect_frame
   (set (xalign :gtk-type gfloat) (yalign :gtk-type gfloat) (ratio :gtk-type gfloat) (obey_child :gtk-type gboolean))
   )

(defmethod gtkaspectframe (gtkaspectframe #!optional (label "") (xalign 0.5) (yalign 0.5) (ratio 1.0) (obey_child TRUE))
   (gtk-object-init! $this (gtk_aspect_frame_new (mkstr label)
						(onum->float (convert-to-number (maybe-unbox xalign)))
						(onum->float (convert-to-number (maybe-unbox yalign)))
						(onum->float (convert-to-number (maybe-unbox ratio)))
						(if (equal? (maybe-unbox obey_child) TRUE)
						    1
						    0))))

;;
;; GtkAccelLabel
;; =============


(defmethod gtkaccellabel (gtkaccellabel string)
   (gtk-object-init! $this (gtk_accel_label_new (mkstr string))))


(def-pgtk-methods GtkAccelLabel gtk_accel_label
   ((refetch :return-type gboolean))
   (set_accel_widget (accel_widget :gtk-type GtkWidget*))
   ((get_accel_width :return-type guint))
   )

;;
;; GtkTipsQuery
;; ============


(defmethod gtktipsquery (gtktipsquery)
   (gtk-object-init! $this (gtk_tips_query_new)))

(def-pgtk-methods GtkTipsQuery gtk_tips_query
   (set_labels (label_inactive :gtk-type const-gchar*) (label_no_tip :gtk-type const-gchar*))
   (set_caller (caller :gtk-type GtkWidget*))
   (stop_query)
   (start_query)
   )

;;;
;;; GtkEntry
;;; ========




;;; GtkEntry->GtkEntry
(defmethod GtkEntry (GtkEntry)
   (gtk-object-init! $this (gtk_entry_new)))

(def-pgtk-methods GtkEntry gtk_entry
   (set_max_length (max :gtk-type guint16))
   (set_editable (editable :gtk-type gboolean))
   (set_visibility (visible :gtk-type gboolean))
   (select_region (start :gtk-type gint) (end :gtk-type gint))
   ((get_text :return-type static_string))
   (set_position (position :gtk-type gint))
   (prepend_text (text :gtk-type const-gchar*))
   (append_text (text :gtk-type const-gchar*))
   (set_text (text :gtk-type const-gchar*))
   )

;;
;; GtkText
;; =======




(def-pgtk-methods GtkText gtk_text
   ((forward_delete :return-type gint) (nchars :gtk-type guint))
   ((backward_delete :return-type gint) (nchars :gtk-type guint))
   (insert (font :gtk-type GdkFont* :null-ok #t) (fore :gtk-type GdkColor* :null-ok #t) (back :gtk-type GdkColor* :null-ok #t) (chars :gtk-type const-char*) (length :gtk-type gint :default -1))
   (thaw)
   (freeze)
   ((get_length :return-type guint))
   ((get_point :return-type guint))
   (set_point (index :gtk-type guint))
   (set_adjustments (hadj :gtk-type GtkAdjustment*) (vadj :gtk-type GtkAdjustment*))
   (set_line_wrap (line_wrap :gtk-type gint))
   (set_word_wrap (word_wrap :gtk-type gint))
   (set_editable (editable :gtk-type gboolean))
   )

(defmethod gtktext (gtktext #!optional hadj vadj)
   (gtk-object-init! $this
		     (gtk_text_new 
		      (get-adjustment hadj)
		      (get-adjustment vadj))))

;;
;; GtkOptionMenu
;; =============


(defmethod gtkoptionmenu (gtkoptionmenu)
   (gtk-object-init! $this (gtk_option_menu_new)))


(def-pgtk-methods GtkOptionMenu gtk_option_menu
   (set_history (index :gtk-type guint))
   (remove_menu)
   (set_menu (menu :gtk-type GtkWidget*))
   ((get_menu :return-type GtkWidget*))
   )

			  
;;
;; GtkToggleButton
;; ===============



(defmethod gtktogglebutton (gtktogglebutton #!optional label)
   (debug-trace 3 "gtktogglebutton constructor called, line " *PHP-LINE* ", label: " label)
   (gtk-object-init! $this
		     (if label
			 (gtk_toggle_button_new_with_label (convert-to-utf8 label))
			 (gtk_toggle_button_new))))

(def-pgtk-methods GtkToggleButton gtk_toggle_button
   (toggled)
   ((get_active :return-type gboolean))
   (set_active (is_active :gtk-type gboolean))
   (set_mode (draw_indicator :gtk-type gboolean))
   )

;;;
;;; GtkScale
;;; ========


;;; no constructor

(def-pgtk-methods GtkScale gtk_scale
   (draw_value)
   ((get_value_width :return-type gint))
   (set_value_pos (pos :gtk-type GtkPositionType))
   (set_draw_value (draw_value :gtk-type gboolean))
   (set_digits (digits :gtk-type gint))
   )


;;
;; GtkScrollbar
;; ============


;;
;; GtkCheckButton
;; ==============


(defmethod gtkcheckbutton (gtkcheckbutton #!optional label)
   (debug-trace 3 "gtkcheckbutton constructor called, line " *PHP-LINE* ", label: " label)
   (gtk-object-init! $this
		     (if label
			 (gtk_check_button_new_with_label (convert-to-utf8 label))
			 (gtk_check_button_new))))
;    (debug-trace 3 "in gtkcheckbutton constructor, the custom properties got "
; 		(if (php-object-custom-properties $this)
; 		    "set"
; 		    "not set"))
   


;;
;; GtkCheckMenuItem
;; ================



(defmethod gtkcheckmenuitem (gtkcheckmenuitem #!optional label)
   (gtk-object-init! $this
		     (if label
			 (gtk_check_menu_item_new_with_label (convert-to-utf8 label))
			 (gtk_check_menu_item_new))))


(def-pgtk-methods GtkCheckMenuItem gtk_check_menu_item
   (toggled)
   (set_show_toggle (always :gtk-type gboolean))
   (set_active (is_active :gtk-type gboolean))
   )
;;
;; GtkColorSelection
;; =================



(def-pgtk-methods GtkColorSelection gtk_color_selection
;   (get_color (color :gtk-type gdouble*))
;   (set_color (color :gtk-type gdouble*))
   (set_opacity (use_opacity :gtk-type gint))
   (set_update_policy (policy :gtk-type GtkUpdateType))
   )

(defmethod gtkcolorselection (gtkcolorselection)
   (gtk-object-init! $this (gtk_color_selection_new)))



;;;
;;; GtkCombo
;;; ========



;;; GtkCombo->GtkCombo
(defmethod GtkCombo (GtkCombo)
   (gtk-object-init! $this (gtk_combo_new)))

(def-pgtk-methods GtkCombo gtk_combo
   (disable_activate)
;   (set_popdown_strings (strings :gtk-type GList*))
   (set_item_string (item :gtk-type GtkItem*) (item_value :gtk-type const-gchar*))
   (set_case_sensitive (val :gtk-type gint))
   (set_use_arrows_always (val :gtk-type gint))
   (set_use_arrows (val :gtk-type gint))
   (set_value_in_list (val :gtk-type gint) (ok_if_empty :gtk-type gint))
   )


	     

;;;
;;; GtkCTree
;;; ========

;;; GtkCTree->GtkCTree
; (defmethod GtkCTree (GtkCTree tree-column arg titles)
;    (let ((tree-column (mkfixnum tree-column))
; 	 (arg (mkfixnum arg))
; 	 (titles (map mkstr (php-hash->list (maybe-unbox titles)))))
;       (gtk-object-init! $this (apply gtk-ctree-new arg titles))))

(defmethod GtkCTree (GtkCTree columns tree-column #!optional titles)
   (let ((columns::int (mkfixnum columns))
	 (tree-column::int (mkfixnum tree-column))
	 (titles (maybe-unbox titles)))
      (unless (> columns 0)
	 (php-warning "number of columns must be > 0")
	 (return +constructor-failed+))
      (if titles
	  (begin
	     (when (< (php-hash-size titles) columns)
		 (php-warning "the array of titles is not long enough")
		 (return +constructor-failed+))
	     (gtk-object-init! $this
			       (gtk_ctree_new_with_titles columns tree-column
							  ;(php-hash->string* titles)
							  (string-list->string* (map convert-to-utf8 (php-hash->list titles))))))
	  (gtk-object-init! $this
			    (gtk_ctree_new columns tree-column)))))


(def-pgtk-methods GtkCTree gtk_ctree
   (sort_recursive (node :gtk-type GtkCTreeNode* :default NULL :null-ok #t))
   (sort_node (node :gtk-type GtkCTreeNode*))
   (set_drag_compare_func (cmp_func :gtk-type GtkCTreeCompareDragFunc))
   (set_expander_style (expander_style :gtk-type GtkCTreeExpanderStyle))
   (set_line_style (line_style :gtk-type GtkCTreeLineStyle))
   (set_show_stub (show_stub :gtk-type gboolean))
   (set_spacing (spacing :gtk-type gint))
   (set_indent (indent :gtk-type gint))
   ((node_is_visible :return-type GtkVisibility) (node :gtk-type GtkCTreeNode*))
   (node_moveto (node :gtk-type GtkCTreeNode*) (column :gtk-type gint) (row_align :gtk-type gfloat) (col_align :gtk-type gfloat))
;   ((node_get_row_data :return-type gpointer) (node :gtk-type GtkCTreeNode*))
;    (node_set_row_data_full (node :gtk-type GtkCTreeNode*) (data :gtk-type gpointer) (destroy :gtk-type GtkDestroyNotify))
;    (node_set_row_data (node :gtk-type GtkCTreeNode*) (data :gtk-type gpointer))
   (node_set_background (node :gtk-type GtkCTreeNode*) (color :gtk-type GdkColor*))
   (node_set_foreground (node :gtk-type GtkCTreeNode*) (color :gtk-type GdkColor*))
   ((node_get_cell_style :return-type GtkStyle*) (node :gtk-type GtkCTreeNode*) (column :gtk-type gint))
   (node_set_cell_style (node :gtk-type GtkCTreeNode*) (column :gtk-type gint) (style :gtk-type GtkStyle*))
   ((node_get_row_style :return-type GtkStyle*) (node :gtk-type GtkCTreeNode*))
   (node_set_row_style (node :gtk-type GtkCTreeNode*) (style :gtk-type GtkStyle*))
   ((get_node_info :return-type gint) (node :gtk-type GtkCTreeNode*) (text :gtk-type gchar**) (spacing :gtk-type guint8*) (pixmap_closed :gtk-type GdkPixmap**) (mask_closed :gtk-type GdkBitmap**) (pixmap_opened :gtk-type GdkPixmap**) (mask_opened :gtk-type GdkBitmap**) (is_leaf :gtk-type gboolean*) (expanded :gtk-type gboolean*))
   ((node_get_pixtext :return-type gint) (node :gtk-type GtkCTreeNode*) (column :gtk-type gint) (text :gtk-type gchar**) (spacing :gtk-type guint8*) (pixmap :gtk-type GdkPixmap**) (mask :gtk-type GdkBitmap**))
   ((node_get_pixmap :return-type gint) (node :gtk-type GtkCTreeNode*) (column :gtk-type gint) (pixmap :gtk-type GdkPixmap**) (mask :gtk-type GdkBitmap**))
;   ((node_get_text :return-type gint) (node :gtk-type GtkCTreeNode*) (column :gtk-type gint) (text :gtk-type gchar**))
   ((node_get_cell_type :return-type GtkCellType) (node :gtk-type GtkCTreeNode*) (column :gtk-type gint))
   ((node_get_selectable :return-type gboolean) (node :gtk-type GtkCTreeNode*))
   (node_set_selectable (node :gtk-type GtkCTreeNode*) (selectable :gtk-type gboolean))
   (node_set_shift (node :gtk-type GtkCTreeNode*) (column :gtk-type gint) (vertical :gtk-type gint) (horizontal :gtk-type gint))
   (set_node_info (node :gtk-type GtkCTreeNode*) (text :gtk-type const-gchar*) (spacing :gtk-type guint8) (pixmap_closed :gtk-type GdkPixmap* :null-ok #t) (mask_closed :gtk-type GdkBitmap* :null-ok #t) (pixmap_opened :gtk-type GdkPixmap*  :null-ok #t) (mask_opened :gtk-type GdkBitmap* :null-ok #t) (is_leaf :gtk-type gboolean) (expanded :gtk-type gboolean))
   (node_set_pixtext (node :gtk-type GtkCTreeNode*) (column :gtk-type gint) (text :gtk-type const-gchar*) (spacing :gtk-type guint8) (pixmap :gtk-type GdkPixmap*) (mask :gtk-type GdkBitmap*))
   (node_set_pixmap (node :gtk-type GtkCTreeNode*) (column :gtk-type gint) (pixmap :gtk-type GdkPixmap*) (mask :gtk-type GdkBitmap* :null-ok #t))
   (node_set_text (node :gtk-type GtkCTreeNode*) (column :gtk-type gint) (text :gtk-type const-gchar*))
   (unselect_recursive (node :gtk-type GtkCTreeNode* :default NULL :null-ok #t))
   (unselect (node :gtk-type GtkCTreeNode*))
   (select_recursive (node :gtk-type GtkCTreeNode* :default NULL :null-ok #t))
   (select (node :gtk-type GtkCTreeNode*))
   (toggle_expansion_recursive (node :gtk-type GtkCTreeNode*))
   (toggle_expansion (node :gtk-type GtkCTreeNode*))
   (collapse_to_depth (node :gtk-type GtkCTreeNode*) (depth :gtk-type gint))
   (collapse_recursive (node :gtk-type GtkCTreeNode* :default NULL :null-ok #t))
   (collapse (node :gtk-type GtkCTreeNode*))
   (expand_to_depth (node :gtk-type GtkCTreeNode*) (depth :gtk-type gint))
   (expand_recursive (node :gtk-type GtkCTreeNode* :default NULL :null-ok #t))
   (expand (node :gtk-type GtkCTreeNode*))
   (move (node :gtk-type GtkCTreeNode*) (new_parent :gtk-type GtkCTreeNode* :null-ok #t) (new_sibling :gtk-type GtkCTreeNode* :null-ok #t))
   ((is_hot_spot :return-type gboolean) (x :gtk-type gint) (y :gtk-type gint))
   ((find_all_by_row_data_custom :return-type GList*) (node :gtk-type GtkCTreeNode*) (data :gtk-type gpointer) (func :gtk-type GCompareFunc))
   ((find_by_row_data_custom :return-type GtkCTreeNode*) (node :gtk-type GtkCTreeNode*) (data :gtk-type gpointer) (func :gtk-type GCompareFunc))
   ((find_all_by_row_data :return-type GList*) (node :gtk-type GtkCTreeNode*) (data :gtk-type gpointer))
   ((find_by_row_data :return-type GtkCTreeNode*) (node :gtk-type GtkCTreeNode*) (data :gtk-type gpointer))
   ((is_ancestor :return-type gboolean) (node :gtk-type GtkCTreeNode*) (child :gtk-type GtkCTreeNode*))
   ((find :return-type gboolean) (node :gtk-type GtkCTreeNode*) (child :gtk-type GtkCTreeNode*))
   ((node_nth :return-type GtkCTreeNode*) (row :gtk-type guint))
;   ((find_node_ptr :return-type GtkCTreeNode*) (ctree_row :gtk-type GtkCTreeRow*))
   ((last :return-type GtkCTreeNode*) (node :gtk-type GtkCTreeNode*))
   ((is_viewable :return-type gboolean) (node :gtk-type GtkCTreeNode*))
;   (pre_recursive_to_depth (node :gtk-type GtkCTreeNode*) (depth :gtk-type gint) (func :gtk-type GtkCTreeFunc) (data :gtk-type gpointer))
;   (pre_recursive (node :gtk-type GtkCTreeNode*) (func :gtk-type GtkCTreeFunc) (data :gtk-type gpointer))
;   (post_recursive_to_depth (node :gtk-type GtkCTreeNode*) (depth :gtk-type gint) (func :gtk-type GtkCTreeFunc) (data :gtk-type gpointer))
;   (post_recursive (node :gtk-type GtkCTreeNode*) (func :gtk-type GtkCTreeFunc) (data :gtk-type gpointer))
;   ((export_to_gnode :return-type GNode*) (parent :gtk-type GNode*) (sibling :gtk-type GNode*) (node :gtk-type GtkCTreeNode*) (func :gtk-type GtkCTreeGNodeFunc) (data :gtk-type gpointer))
   ((insert_gnode :return-type GtkCTreeNode*) (parent :gtk-type GtkCTreeNode*) (sibling :gtk-type GtkCTreeNode*) (gnode :gtk-type GNode*) (func :gtk-type GtkCTreeGNodeFunc) (data :gtk-type gpointer))
   (remove_node (node :gtk-type GtkCTreeNode*))
;   ((insert_node :return-type GtkCTreeNode*) (parent :gtk-type GtkCTreeNode* :null-ok #t) (sibling :gtk-type GtkCTreeNode* :null-ok #t) (text :gtk-type gchar**) (spacing :gtk-type guint8) (pixmap_closed :gtk-type GdkPixmap*) (mask_closed :gtk-type GdkBitmap*) (pixmap_opened :gtk-type GdkPixmap*) (mask_opened :gtk-type GdkBitmap*) (is_leaf :gtk-type gboolean) (expanded :gtk-type gboolean))
;   (construct (columns :gtk-type gint) (tree_column :gtk-type gint) (titles :gtk-type gchar**))
   )




;;
;; GtkCurve
;; ========


(def-pgtk-methods GtkCurve gtk_curve
   (set_curve_type (type :gtk-type GtkCurveType))
   (set_vector (veclen :gtk-type int) (() :gtk-type gfloat))
   (get_vector (veclen :gtk-type int) (() :gtk-type gfloat))
   (set_range (min_x :gtk-type gfloat) (max_x :gtk-type gfloat) (min_y :gtk-type gfloat) (max_y :gtk-type gfloat))
   (set_gamma (gamma :gtk-type gfloat))
   (reset)
   )

(defmethod gtkcurve (gtkcurve)
   (gtk-object-init! $this (gtk_curve_new))
   TRUE)


;;
;; GtkFontSelection
;; ================


(def-pgtk-methods GtkFontSelection gtk_font_selection
   (set_preview_text (text :gtk-type const-gchar*))
   ((get_preview_text :return-type gchar*))
   (set_filter (filter_type :gtk-type GtkFontFilterType) (font_type :gtk-type GtkFontType) (foundries :gtk-type gchar**) (weights :gtk-type gchar**) (slants :gtk-type gchar**) (setwidths :gtk-type gchar**) (spacings :gtk-type gchar**) (charsets :gtk-type gchar**))
   ((set_font_name :return-type gboolean) (fontname :gtk-type const-gchar*))
   ((get_font :return-type GdkFont*))
   ((get_font_name :return-type gchar*))
   )


;;; XXX constructor exists in php-gtk but is not implemented by bigloo-lib

;;
;; GtkGammaCurve
;; =============



(defmethod gtkgammacurve (gtkgammacurve)
   (gtk-object-init! $this (gtk_gamma_curve_new)))


;;
;; GtkHButtonBox
;; =============


(defmethod gtkhbuttonbox (gtkhbuttonbox)
   (gtk-object-init! $this (gtk_hbutton_box_new)))

;;
;; GtkHPaned
;; =========


(defmethod gtkhpaned (gtkhpaned)
   (gtk-object-init! $this (gtk_hpaned_new)))

;;
;; GtkHRuler
;; =========


(defmethod gtkhruler (gtkhruler)
   (gtk-object-init! $this (gtk_hruler_new)))

;;
;; GtkHScale
;; =========


(defmethod gtkhscale (gtkhscale #!optional adj)
   (gtk-object-init! $this (gtk_hscale_new (get-adjustment adj))))

;;
;; GtkHScrollbar
;; =============


(defmethod gtkhscrollbar (gtkhscrollbar #!optional adj)
   (gtk-object-init! $this (gtk_hscrollbar_new (get-adjustment adj))))

;;
;; GtkHSeparator
;; =============


(defmethod gtkhseparator (gtkhseparator)
   (gtk-object-init! $this (gtk_hseparator_new))
   TRUE)

;;
;; GtkMenu
;; =======


(defmethod gtkmenu (gtkmenu)
   (gtk-object-init! $this (gtk_menu_new)))

(def-pgtk-methods GtkMenu gtk_menu
   (reorder_child (child :gtk-type GtkWidget*) (position :gtk-type gint))
   (set_title (title :gtk-type const-gchar*))
   (set_tearoff_state (torn_off :gtk-type gboolean))
   ((get_attach_widget :return-type GtkWidget*))
   (detach)
;   (attach_to_widget (attach_widget :gtk-type GtkWidget*) (detacher :gtk-type GtkMenuDetachFunc))
   ((ensure_uline_accel_group :return-type GtkAccelGroup*))
   ((get_uline_accel_group :return-type GtkAccelGroup*))
   ((get_accel_group :return-type GtkAccelGroup*))
   (set_accel_group (accel_group :gtk-type GtkAccelGroup*))
   (set_active (index :gtk-type guint))
   ((get_active :return-type GtkWidget*))
   (popdown)
   (reposition)
   (popup (parent_menu_shell :gtk-type GtkWidget*) (parent_menu_item :gtk-type GtkWidget*) (func :gtk-type GtkMenuPositionFunc) (data :gtk-type gpointer) (button :gtk-type guint) (activate_time :gtk-type guint32))
   (insert (child :gtk-type GtkWidget*) (position :gtk-type gint))
   (prepend (child :gtk-type GtkWidget*))
   (append (child :gtk-type GtkWidget*))
   )

;;
;; GtkMenuBar
;; ==========


(defmethod gtkmenubar (gtkmenubar)
   (gtk-object-init! $this (gtk_menu_bar_new)))

(def-pgtk-methods GtkMenuBar gtk_menu_bar
   (set_shadow_type (type :gtk-type GtkShadowType))
   (insert (child :gtk-type GtkWidget*) (position :gtk-type gint))
   (prepend (child :gtk-type GtkWidget*))
   (append (child :gtk-type GtkWidget*))
   )

;;;
;;; GtkProgressBar
;;; ==============


;;; GtkProgressBar->GtkProgressBar
(defmethod GtkProgressBar (GtkProgressBar #!optional adj)
   (gtk-object-init! $this (gtk_progress_bar_new_with_adjustment
			    (get-adjustment adj))))


(def-pgtk-methods GtkProgressBar gtk_progress_bar
;   (update (percentage :gtk-type gfloat))
   (set_orientation (orientation :gtk-type GtkProgressBarOrientation))
   (set_activity_blocks (blocks :gtk-type guint))
   (set_activity_step (step :gtk-type guint))
   (set_discrete_blocks (blocks :gtk-type guint))
   (set_bar_style (style :gtk-type GtkProgressBarStyle))
   )


;;
;; GtkRadioButton
;; ==============


(def-pgtk-methods GtkRadioButton gtk_radio_button
   (set_group (group :gtk-type GSList*))
   ((group :return-type GSList*))
   )

(defmethod gtkradiobutton (gtkradiobutton #!optional group label)
   (set! group (maybe-unbox group))
   (let ((group
	  ;;; maybe we can put this kind of thing into a function or
	  ;;; macro someplace?
	  (cond
	     ((or (not group) (php-null? group))
	      (pragma::GtkRadioButton* "NULL"))
	     ((and (php-object? group)
		   (php-object-is-a group 'GtkRadioButton))
	      (GTK_RADIO_BUTTON (gtk-object group)))
	     (else
	      (php-warning group " is not a GtkRadioButton.")
	      (pragma::GtkRadioButton* "NULL")))))
      (gtk-object-init! $this
			(if label
			    (gtk_radio_button_new_with_label (GtkRadioButton*-group group)
							     (convert-to-utf8 label))
			    (gtk_radio_button_new (GtkRadioButton*-group group))))))

;;
;; GtkRadioMenuItem
;; ================


(def-pgtk-methods GtkRadioMenuItem gtk_radio_menu_item
   (set_group (group :gtk-type GSList*))
   ((group :return-type GSList*))
   )


(defmethod gtkradiomenuitem (gtkradiomenuitem group label)
   (set! group (maybe-unbox group))
   (let ((group
	  ;; XXX tsk. copied code.
	  (cond
	     ((or (not group) (php-null? group))
	      (pragma::GtkRadioMenuItem* "NULL"))
	     ((and (php-object? group)
		   (php-object-is-a group 'GtkRadioMenuItem))
	      (GTK_RADIO_BUTTON (gtk-object group)))
	     (else
	      (php-warning group " is not a GtkRadioMenuItem.")
	      (pragma::GtkRadioMenuItem* "NULL")))))
      (gtk-object-init! $this 
			(if label
			    (gtk_radio_menu_item_new_with_label
			     (GtkRadioMenuItem*-group group) (convert-to-utf8 label))
			    (gtk_radio_menu_item_new (GtkRadioMenuItem*-group group))))))


;;
;; GtkSpinButton
;; =============


(def-pgtk-methods GtkSpinButton gtk_spin_button
   (update)
   (set_snap_to_ticks (snap_to_ticks :gtk-type gboolean))
   (set_shadow_type (shadow_type :gtk-type GtkShadowType))
   (set_wrap (wrap :gtk-type gboolean))
   (spin (direction :gtk-type GtkSpinType) (increment :gtk-type gfloat))
   (set_numeric (numeric :gtk-type gboolean))
   (set_update_policy (policy :gtk-type GtkSpinButtonUpdatePolicy))
   (set_value (value :gtk-type gfloat))
   ((get_value_as_int :return-type gint))
   ((get_value_as_float :return-type gfloat))
   (set_digits (digits :gtk-type guint))
   ((get_adjustment :return-type GtkAdjustment*))
   (set_adjustment (adjustment :gtk-type GtkAdjustment*))
   (configure (adjustment :gtk-type GtkAdjustment*) (climb_rate :gtk-type gfloat) (digits :gtk-type guint))
   )

(defmethod gtkspinbutton (gtkspinbutton #!optional adjustment (climb-rate 0.0) (digits 0))
   (gtk-object-init! $this
		     (gtk_spin_button_new (get-adjustment adjustment)
					  (onum->float (convert-to-number climb-rate))
					  (onum->int (convert-to-number digits)))))


;;
;; GtkTearoffMenuItem
;; ==================


(defmethod gtktearoffmenuitem (gtktearoffmenuitem)
   (gtk-object-init! $this (gtk_tearoff_menu_item_new)))


;;
;; GtkVButtonBox
;; =============


(defmethod gtkvbuttonbox (gtkvbuttonbox)
   (gtk-object-init! $this (gtk_vbutton_box_new)))

;;
;; GtkVPaned
;; =========


(defmethod gtkvpaned (gtkvpaned)
   (gtk-object-init! $this (gtk_vpaned_new))
   TRUE)

;;
;; GtkVRuler
;; =========


(defmethod gtkvruler (gtkvruler)
   (gtk-object-init! $this (gtk_vruler_new)))

;;
;; GtkVScale
;; =========


(defmethod gtkvscale (gtkvscale #!optional adjustment)
   (gtk-object-init! $this
		     (gtk_vscale_new (get-adjustment adjustment))))

;;
;; GtkVScrollbar
;; =============


(defmethod gtkvscrollbar (gtkvscrollbar #!optional adjustment)
   (gtk-object-init! $this 
		     (gtk_vscrollbar_new (get-adjustment adjustment))))

;;
;; GtkVSeparator
;; =============


(defmethod gtkvseparator (gtkvseparator)
   (gtk-object-init! $this (gtk_vseparator_new)))


;;
;; GtkAllocation (a struct)
;; =============

(defmethod gtkallocation (gtkallocation x y width height)
   (php-object-property-set! $this 'x x)
   (php-object-property-set! $this 'y y)
   (php-object-property-set! $this 'width width)
   (php-object-property-set! $this 'height height))


;;
;; GtkObjectClass
;; ==============

(def-pgtk-methods GtkObjectClass gtk_object_class
   (add_signals (signals :gtk-type guint*) (nsignals :gtk-type guint))
   ((user_signal_newv :return-type guint) (name :gtk-type const-gchar*) (signal_flags :gtk-type GtkSignalRunType) (marshaller :gtk-type GtkSignalMarshaller) (return_val :gtk-type GtkType) (nparams :gtk-type guint) (params :gtk-type GtkType*))
   ((user_signal_new :return-type guint) (name :gtk-type const-gchar*) (signal_flags :gtk-type GtkSignalRunType) (marshaller :gtk-type GtkSignalMarshaller) (return_val :gtk-type GtkType) (nparams :gtk-type guint))
   )

;;
;; GtkType
;; =======


(def-pgtk-methods GtkType gtk_type
   ((query :return-type GtkTypeQuery*))
   ((get_varargs_type :return-type GtkType))
   (set_varargs_type (varargs_type :gtk-type GtkType))
   ((flags_find_value :return-type GtkFlagValue*) (value_name :gtk-type const-gchar*))
   ((enum_find_value :return-type GtkEnumValue*) (value_name :gtk-type const-gchar*))
   ((flags_get_values :return-type GtkFlagValue*))
   ((enum_get_values :return-type GtkEnumValue*))
   ((is_a :return-type gboolean) (is_a_type :gtk-type GtkType))
   (describe_tree (show_size :gtk-type gboolean))
   (describe_heritage)
   (free (mem :gtk-type gpointer))
   ((new :return-type gpointer))
   ((children_types :return-type GList*))
   ((parent_class :return-type gpointer))
   ((class :return-type gpointer))
   ((parent :return-type GtkType))
   (set_chunk_alloc (n_chunks :gtk-type guint))
   ((unique :return-type GtkType) (type_info :gtk-type const-GtkTypeInfo*))
   )

;;
;; GtkSelectionData
;; ================

(def-pgtk-methods GtkSelectionData gtk_selection_data
   (free)
   ((copy :return-type GtkSelectionData*))
;   (set (type :gtk-type GdkAtom) (format :gtk-type gint) (data :gtk-type const-guchar*) (length :gtk-type gint))
   )

;;
;; GtkTargetList
;; =============

(def-pgtk-methods GtkTargetList gtk_target_list
   ((find :return-type gboolean) (target :gtk-type GdkAtom) (info :gtk-type guint*))
   (remove (target :gtk-type GdkAtom))
   (add_table (targets :gtk-type const-GtkTargetEntry*) (ntargets :gtk-type guint))
   (add (target :gtk-type GdkAtom) (flags :gtk-type guint) (info :gtk-type guint))
   (unref)
   (ref)
   )




;;; casts

;;we can't use any of the foreign types defined in bgtk in our
;;export clauses, or else this would be in php-gtk-common.scm

(define (php-hash->string*::string* ar)
   (string-list->string*
    (map mkstr (php-hash->list (maybe-unbox ar)))))


(define (get-adjustment::GtkAdjustment* foo)
   (set! foo (maybe-unbox foo))
   (if (and foo (php-object-is-a foo 'gtkadjustment))
       (GTK_ADJUSTMENT (gtk-object foo))
       (pragma::GtkAdjustment* "NULL")))

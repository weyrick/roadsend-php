(module php-gtk-custom-properties
   (load (php-gtk-macros "php-gtk-macros.sch"))
   (import
    (php-gtk-common-lib "php-gtk-common.scm")
    (php-gdk-lib "php-gdk.scm"))
;   (library "common")
;   (library "bgtk")
   (import (gtk-binding "cigloo/gtk.scm"))
   (library php-runtime)
   (export
    (gtk-adjustment-custom-lookup obj prop ref? k)
    (gtk-widget-custom-lookup obj prop ref? k)
    (gtk-misc-custom-lookup obj prop ref? k)
    (gtk-arrow-custom-lookup obj prop ref? k)
    (gtk-editable-custom-lookup obj prop ref? k)
    (gtk-text-custom-lookup obj prop ref? k)
    (gtk-toolbar-custom-lookup obj prop ref? k)
    (gtk-table-custom-lookup obj prop ref? k)
    (gtk-paned-custom-lookup obj prop ref? k)
    (gtk-notebook-custom-lookup obj prop ref? k)
    (gtk-list-custom-lookup obj prop ref? k)
    (gtk-layout-custom-lookup obj prop ref? k)
    (gtk-fixed-custom-lookup obj prop ref? k)
    (gtk-bin-custom-lookup obj prop ref? k)
    (gtk-tree-item-custom-lookup obj prop ref? k)
    (gtk-check-menu-item-custom-lookup obj prop ref? k)
    (gtk-handle-box-custom-lookup obj prop ref? k)
    (gtk-toggle-button-custom-lookup obj prop ref? k)
    (gtk-box-custom-lookup obj prop ref? k)
    (gtk-gamma-curve-custom-lookup obj prop ref? k)
    (gtk-combo-custom-lookup obj prop ref? k)
    (gtk-clist-custom-lookup obj prop ref? k)
    (gtk-ctree-custom-lookup obj prop ref? k)
    (gtk-calendar-custom-lookup obj prop ref? k)
    (gtk-font-selection-dialog-custom-lookup obj prop ref? k)
    (gtk-file-selection-custom-lookup obj prop ref? k)
    (gtk-dialog-custom-lookup obj prop ref? k)
    (gtk-input-dialog-custom-lookup obj prop ref? k)
    (gtk-color-selection-dialog-custom-lookup obj prop ref? k)
    (gtk-box-child-custom-lookup obj prop ref? k)
    (gtk-selection-data-custom-lookup obj prop ref? k)
    (php-gtk-custom-set obj prop ref? value k)
    (php-gtk-custom-copy props)))


(define (php-gtk-custom-set obj prop ref? value k)
   (k))

(define (php-gtk-custom-copy props)
   props)

(def-property-getter (gtk-adjustment-custom-lookup obj prop ref? k) GtkAdjustment
   (value gfloat)
   (lower gfloat)
   (upper gfloat)
   (step_increment gfloat)
   (page_increment gfloat)
   (page_size gfloat)
   )

; static void gtk_selection_data_get_property(zval *return_value, zval *object, zend_llist_element **element, int *result)
; {
; 	GtkSelectionData *data = PHP_GTK_SELECTION_DATA_GET(object);
; 	char *prop_name = Z_STRVAL(((zend_overloaded_element *)(*element)->data)->element);

; 	*result = SUCCESS;

; 	if (!strcmp(prop_name, "selection")) {
; 		*return_value = *php_gdk_atom_new(data->selection);
; 		return;
; 	} else if (!strcmp(prop_name, "target")) {
; 		*return_value = *php_gdk_atom_new(data->target);
; 		return;
; 	} else if (!strcmp(prop_name, "type")) {
; 		*return_value = *php_gdk_atom_new(data->type);
; 		return;
; 	} else if (!strcmp(prop_name, "format")) {
; 		RETURN_LONG(data->format);
; 	} else if (!strcmp(prop_name, "length")) {
; 		RETURN_LONG(data->length);
; 	} else if (!strcmp(prop_name, "data") && data->length > -1) {
; 		RETURN_STRINGL(data->data, data->length, 1);
; 	}

; 	*result = FAILURE;
; }
(def-property-getter (gtk-selection-data-custom-lookup obj prop ref? k) GtkSelectionData
   (selection GdkAtom)
   (target GdkAtom)
   (type GdkAtom)
   (format gint)
   (length gint)
   (data :impl (if (> (pragma::int "$1->length" this) -1)
		   (pragma::bstring "string_to_bstring_len($1->data, $1->length)" this)
		   (k))))

(def-property-getter (gtk-widget-custom-lookup obj prop ref? k) GtkWidget
   (style GtkStyle*)
   (window GdkWindow*)

   (allocation :impl (php-gtk-allocation-new
		      ;;note -- this is a struct, not an object! see the ampersand?
		      (pragma::GtkAllocation* "&GTK_WIDGET($1)->allocation" this)))
    
   (state guint)
   (parent :impl (gtk-object-wrapper-new #f (pragma::GtkObject* "GTK_WIDGET($1)->parent" this)))
   )

(def-property-getter (gtk-misc-custom-lookup obj prop ref? k) GtkMisc
   (xalign gfloat)
   (yalign gfloat)
   (xpad guint16)
   (ypad guint16)
   )

(def-property-getter (gtk-arrow-custom-lookup obj prop ref? k) GtkArrow
   (arrow_type gint16)
   (shadow_type gint16)
   )

(def-property-getter (gtk-editable-custom-lookup obj prop ref? k) GtkEditable
   (selection_start_pos guint)
   (selection_end_pos guint)
   (has_selection gboolean)
   )

(def-property-getter (gtk-text-custom-lookup obj prop ref? k) GtkText
   (hadj GtkAdjustment*)
   (vadj GtkAdjustment*)
   )

(def-property-getter (gtk-toolbar-custom-lookup obj prop ref? k) GtkToolbar
   (orientation GtkOrientation)
   (style GtkToolbarStyle)
   (space_size gint)
   (space_style GtkToolbarSpaceStyle)
   )

(def-property-getter (gtk-table-custom-lookup obj prop ref? k) GtkTable
   (children GList*)
   (nrows guint16)
   (ncols guint16)
   (column_spacing guint16)
   (row_spacing guint16)
   (homogeneous guint)
   )

(def-property-getter (gtk-paned-custom-lookup obj prop ref? k) GtkPaned
   (child1 GtkWidget*)
   (child2 GtkWidget*)
   (handle_size guint16)
;;not on win32
;   (gutter_size guint16)
   (child1_resize gboolean)
   (child1_shrink gboolean)
   (child2_resize gboolean)
   (child2_shrink gboolean)
   )

(def-property-getter (gtk-notebook-custom-lookup obj prop ref? k) GtkNotebook
   (tab_pos GtkPositionType)
   )

(def-property-getter (gtk-list-custom-lookup obj prop ref? k) GtkList
   (selection GList*)
   )

(def-property-getter (gtk-layout-custom-lookup obj prop ref? k) GtkLayout
   (bin_window GdkWindow*)
   )

(def-property-getter (gtk-fixed-custom-lookup obj prop ref? k) GtkFixed
   (children GList*)
   )

(def-property-getter (gtk-bin-custom-lookup obj prop ref? k) GtkBin
   (child GtkWidget*)
   )

(def-property-getter (gtk-tree-item-custom-lookup obj prop ref? k) GtkTreeItem
   (subtree GtkWidget*)
   )

(def-property-getter (gtk-check-menu-item-custom-lookup obj prop ref? k) GtkCheckMenuItem
   (active gboolean)
   )

(def-property-getter (gtk-handle-box-custom-lookup obj prop ref? k) GtkHandleBox
   (shadow_type GtkShadowType)
   (handle_position GtkPositionType)
   (snap_edge gint)
   (child_detached gboolean)
   )

(def-property-getter (gtk-toggle-button-custom-lookup obj prop ref? k) GtkToggleButton
   (draw_indicator gboolean)
   )

(def-property-getter (gtk-box-custom-lookup obj prop ref? k) GtkBox
   (children :impl (make-custom-hash glist-hash-read-single
				     glist-hash-write-single
				     glist-hash-read-entire
				     (make-glist-hash-context (GtkBox*-children this)
							      'bs-_GtkBoxChild*
							      (lambda (c) (gtk-wrapper-new 'GtkBoxChild c)))))
   (spacing gint16)
   (homogeneous gboolean)
   )

(def-property-getter (gtk-gamma-curve-custom-lookup obj prop ref? k) GtkGammaCurve
   (table GtkWidget*)
   (curve GtkWidget*)
   (gamma gfloat)
   (gamma_dialog GtkWidget*)
   (gamma_text GtkWidget*)
   )

(def-property-getter (gtk-combo-custom-lookup obj prop ref? k) GtkCombo
   (entry GtkWidget*)
   (list GtkWidget*)
   )

(def-property-getter (gtk-clist-custom-lookup obj prop ref? k) GtkCList
   (focus_row gint)
   (rows gint)
   (sort_column gint)
   (sort_type GtkSortType)
   (selection :impl (make-custom-hash glist-hash-read-single
				      glist-hash-write-single
				      glist-hash-read-entire
				      (make-glist-hash-context (GtkCList*-selection this)
							       'int
							       convert-to-integer)))
   (selection_mode GtkSelectionMode)
   (row_list :impl (make-custom-hash glist-hash-read-single
				     glist-hash-write-single
				     glist-hash-read-entire
				     (make-glist-hash-context (GtkCList*-row_list this)
							      'bs-_GtkCListRow*
							      ;php-gtk-clist-row-new
							      (lambda (c) (gtk-wrapper-new 'gtkclistrow c))))))

(def-property-getter (gtk-ctree-custom-lookup obj prop ref? k) GtkCTree
   (tree_indent gint)
   (tree_spacing gint)
   (tree_column gint)
   (line_style GtkCTreeLineStyle)
   (expander_style GtkCTreeExpanderStyle)
   (clist :impl (gtk-object-wrapper-new 'gtkclist (pragma::GtkCList* "GTK_CLIST($1)" this)))
   (selection :impl (make-custom-hash glist-hash-read-single
				      glist-hash-write-single
				      glist-hash-read-entire
				      (make-glist-hash-context (GtkCList*-selection (GtkCTree*-clist this))
							       'bs-_GtkCTreeNode*
							       ;php-gtk-clist-row-new
							       (lambda (c) (gtk-wrapper-new 'gtkctreenode c)))))
   (row_list :impl (make-custom-hash glist-hash-read-single
				     glist-hash-write-single
				     glist-hash-read-entire
				     (make-glist-hash-context (GtkCList*-row_list (GtkCTree*-clist this))
							      'bs-_GtkCTreeNode*
							      ;php-gtk-clist-row-new
							      (lambda (c) (gtk-wrapper-new 'gtkctreenode c))))))

(def-property-getter (gtk-calendar-custom-lookup obj prop ref? k) GtkCalendar
   (month gint)
   (year gint)
   (selected_day gint)
   (num_marked_dates gint)
;    (marked_date gint*)
   
; %% {{{ GtkCalendar
; %%
; getprop GtkCalendar marked_date
; 	GtkCalendar *cal = GTK_CALENDAR(PHP_GTK_GET(object));
; 	zend_overloaded_element *property;
; 	zend_llist_element *next = (*element)->next;
; 	int prop_index;

; 	if (next) {
; 		property = (zend_overloaded_element *)next->data;
; 		if (Z_TYPE_P(property) == OE_IS_ARRAY && Z_TYPE(property->element) == IS_LONG) {
; 			*element = next;
; 			prop_index = Z_LVAL(property->element);
; 			if (prop_index > 0 && prop_index < 31)
; 				ZVAL_LONG(return_value, cal->marked_date[prop_index]);
; 		}
; 	} else {
; 		int i;

; 		array_init(return_value);
; 		for (i = 0; i < 31; i++)
; 			add_next_index_long(return_value, cal->marked_date[i]);
; 	}
; %%

   )

(def-property-getter (gtk-font-selection-dialog-custom-lookup obj prop ref? k) GtkFontSelectionDialog
   (fontsel GtkWidget*)
   (main_vbox GtkWidget*)
   (action_area GtkWidget*)
   (ok_button GtkWidget*)
   (apply_button GtkWidget*)
   (cancel_button GtkWidget*)
   )

(def-property-getter (gtk-file-selection-custom-lookup obj prop ref? k) GtkFileSelection
   (dir_list GtkWidget*)
   (file_list GtkWidget*)
   (selection_entry GtkWidget*)
   (selection_text GtkWidget*)
   (main_vbox GtkWidget*)
   (ok_button GtkWidget*)
   (cancel_button GtkWidget*)
   (action_area GtkWidget*)
   )

(def-property-getter (gtk-dialog-custom-lookup obj prop ref? k) GtkDialog
   (vbox GtkWidget*)
   (action_area GtkWidget*)
   )

(def-property-getter (gtk-input-dialog-custom-lookup obj prop ref? k) GtkInputDialog
   (close_button GtkWidget*)
   (save_button GtkWidget*)
   )



(def-property-getter (gtk-color-selection-dialog-custom-lookup obj prop ref? k) GtkColorSelectionDialog
   (colorsel GtkWidget*)
   (main_vbox GtkWidget*)
   (ok_button GtkWidget*)
   (cancel_button GtkWidget*)
   (help_button GtkWidget*)
   )

;; wasn't in the defs
(def-property-getter (gtk-box-child-custom-lookup obj prop ref? k) GtkBoxChild
   (widget GtkWidget*)
   (padding guint16)
   (expand guint)
   (fill guint)
   (pack guint))


;this function converts a gtk allocation into a php allocation
(define (php-gtk-allocation-new obj::GtkAllocation*)
   (let ((obj::GtkAllocation* obj))
      (if (foreign-null? obj)
	  NULL
	  (let ((o (construct-php-object-sans-constructor 'GtkAllocation)))
	     (php-object-property-set! o 'x (convert-to-integer
					     (pragma::int "$1->x" obj)))
	     (php-object-property-set! o 'y (convert-to-integer
					     (pragma::int "$1->y" obj)))
	     (php-object-property-set! o 'width (convert-to-integer
					     (pragma::int "$1->width" obj)))
	     (php-object-property-set! o 'height (convert-to-integer
					     (pragma::int "$1->height" obj)))
	     o))))

;this function converts a php allocation into a gtk allocation
(define (php-gtk-allocation-get wrapper obj::GtkAllocation*)
   (if (not (php-object-is-a wrapper 'GtkAllocation))
       (begin
	  (php-warning "Not a GtkAllocation: " wrapper)
	  #f)
       (let ((obj::GtkAllocation* obj))
	  (if (foreign-null? obj)
	      #f
	      (let ((x::int (mkfixnum (php-object-property wrapper 'x)))
		    (y::int (mkfixnum (php-object-property wrapper 'y)))
		    (width::int (mkfixnum (php-object-property wrapper 'width)))
		    (height::int (mkfixnum (php-object-property wrapper 'height))))
		 (pragma "$1->x = $2" obj x)
		 (pragma "$1->y = $2" obj y)
		 (pragma "$1->width = $2" obj width)
		 (pragma "$1->height = $2" obj height)
		 #t)))))






;;; the magical glist hashes
(define-struct %glist-hash-context
   glist
   type
   convert-to-php-type)

(define (make-glist-hash-context glist::GList* type::symbol convert-to-php-type::procedure)
   (%glist-hash-context glist type convert-to-php-type))


;;these are custom hashtables which are really glists under the covers
;;used for overridden properties, e.g. gtkclist->selection
(define (glist-hash-read-single key context)
   (let ((glist (%glist-hash-context-glist context))
	 (type (%glist-hash-context-type context))
	 (phpize (%glist-hash-context-convert-to-php-type context)))
      (debug-trace 3 "glist-hash-read-single, type " type)

      (set! key (maybe-unbox key))
      (if (not (onum-long? key))
	  (begin
	     (php-warning "cannot access overloaded property with non-integral key")
	     NULL)
	  (let ((i 0)
		(stop (mkfixnum key)))
	     (bind-exit (return)
		(glist-foreach glist type
			       (lambda (el)
				  (if (= i stop)
				      (return (phpize el))
				      (set! i (+ i 1)))))
		NULL)))))

(define (glist-hash-write-single key value convert-to-php-type)
   (php-warning "writing to overloaded arrays is not supported"))

(define (glist-hash-read-entire context)
   (let ((glist (%glist-hash-context-glist context))
	 (type (%glist-hash-context-type context))
	 (phpize (%glist-hash-context-convert-to-php-type context))
	 (new-hash (make-php-hash)))
      (debug-trace 3 "glist-hash-read-entire, type " type)
	 
      (glist-foreach glist type
		     (lambda (el)
			(php-hash-insert! new-hash :next (phpize el))))
      new-hash))







; getprop GtkCList selection
; 	GList *tmp;
; 	GList *selection = GTK_CLIST(PHP_GTK_GET(object))->selection;
; 	zend_overloaded_element *property;
; 	zend_llist_element *next = (*element)->next;
; 	int prop_index;

; 	if (next) {
; 		int i = 0;
; 		property = (zend_overloaded_element *)next->data;
; 		if (Z_TYPE_P(property) == OE_IS_ARRAY && Z_TYPE(property->element) == IS_LONG) {
; 			*element = next;
; 			prop_index = Z_LVAL(property->element);
; 			for (tmp = selection, i = 0; tmp; tmp = tmp->next, i++) {
; 				if (i == prop_index) {
; 					RETURN_LONG(GPOINTER_TO_INT(tmp->data));
; 				}
; 			}
; 		}
; 	} else {
; 		array_init(return_value);
; 		for (tmp = selection; tmp; tmp = tmp->next)
; 			add_next_index_long(return_value, GPOINTER_TO_INT(tmp->data));
; 	}
; %%
; getprop GtkCList row_list
; 	GList *tmp;
; 	GList *row_list = GTK_CLIST(PHP_GTK_GET(object))->row_list;
; 	zend_overloaded_element *property;
; 	zend_llist_element *next = (*element)->next;
; 	int prop_index;

; 	if (next) {
; 		int i = 0;
; 		property = (zend_overloaded_element *)next->data;
; 		if (Z_TYPE_P(property) == OE_IS_ARRAY && Z_TYPE(property->element) == IS_LONG) {
; 			*element = next;
; 			prop_index = Z_LVAL(property->element);
; 			for (tmp = row_list, i = 0; tmp; tmp = tmp->next, i++) {
; 				if (i == prop_index) {
; 					*return_value = *php_gtk_clist_row_new((GtkCListRow *)tmp->data);
; 					return;
; 				}
; 			}
; 		}
; 	} else {
; 		array_init(return_value);
; 		for (tmp = row_list; tmp; tmp = tmp->next) {
; 			add_next_index_zval(return_value, php_gtk_clist_row_new((GtkCListRow *)tmp->data));
; 		}
; 	}
; %% }}}

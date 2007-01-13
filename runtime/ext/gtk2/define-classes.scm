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
(module define-classes
   (load (php-macros "../../../php-macros.scm"))
   (load (php-gtk-macros "php-gtk-macros.sch"))
   (import (gtk-binding "cigloo/gtk.scm")
	   (php-gtk-common-lib "php-gtk-common.scm")
	   (php-gtk-custom-properties "custom-properties.scm"))
   
   (export (init-define-classes)))

(define (init-define-classes)
   1)

;; The pcc-gtk class is for internal class properties and methods
;; common to all classes in pcc-gtk. All toplevel classes should
;; subclass pcc-gtk.

(defclass pcc-gtk)

(defclass (GtkAccelGroup pcc-gtk))
(defclass (GtkObject pcc-gtk))
(defclass (GtkData gtkobject))
(defclass (GtkItemFactory gtkobject))

(def-ext-class (GtkWidget gtkobject)
   gtk-widget-custom-lookup
;    (lambda (obj prop ref? k)
;       (let ((prop (string->symbol (mkstr prop)))
; 	    (props (php-object-custom-properties obj))
; 	    (this::gtk-object (gtk-object obj)))
; 	 (case prop
; 	    ((style) (gtk-wrapper-new 'GtkStyle
; 				      (begin0 (pragma::gtk-style "GTK_WIDGET($1)->style" this)
; 					      (debug-trace 3 "just called it"))))
; 		      ;'GtkStyle
; ;				      (gtk-widget-style (gtk-object obj))
; 	    ((window) (gtk-wrapper-new 'GdkWindow
; 				       (pragma::gdk-window "GTK_WIDGET($1)->window" this)))
; 	    ((allocation) (php-gtk-allocation-new
; 					   ;;note -- this is a struct, not an object! see the ampersand?
; 			   (pragma::gtk-allocation "&GTK_WIDGET($1)->allocation" this)))
; 	    ((state) (convert-to-integer (pragma::int "GTK_WIDGET($1)->state" this)))
; 	    ((parent) (gtk-wrapper-new #f (pragma::gtk-object "GTK_WIDGET($1)->parent" this)))
; 	    (else (k)))))
   php-gtk-custom-set
;    (lambda (obj prop ref? value k)
;       (case prop
; 	 (else (k))))
   php-gtk-custom-copy)

(defclass (GtkContainer GtkWidget))

(def-ext-class (GtkBin GtkContainer)
   gtk-bin-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)

(defclass (GtkButton GtkBin))
(defclass (GtkDrawingArea GtkWidget)); #f #f #f)
(defclass (GtkEditable GtkWidget))

(def-ext-class (GtkMisc GtkWidget)
   gtk-misc-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)

(defclass (GtkPixmap gtkmisc))
(defclass (GtkPreview GtkWidget))
(defclass (GtkProgress GtkWidget))
(defclass (GtkRange GtkWidget))
(defclass (GtkRuler GtkWidget))
(defclass (GtkSeparator GtkWidget))
(defclass (GtkStatusBar GtkWidget))
(defclass (GtkImage gtkmisc))
(defclass (GtkLabel gtkmisc))
(defclass (GtkMenuShell GtkContainer))
(defclass (GtkPacker GtkContainer))
(defclass (GtkSocket GtkContainer))
(defclass (GtkTree GtkContainer))
(defclass (GtkAlignment gtkbin))
(defclass (GtkEventBox gtkbin))
(defclass (GtkFrame gtkbin))
(defclass (GtkInvisible gtkbin))
(defclass (GtkItem gtkbin))
(defclass (GtkScrolledWindow gtkbin))
(defclass (GtkViewport gtkbin))
(defclass (GtkWindow gtkbin))

(defclass (GtkTooltips gtkdata))

(def-ext-class (GtkBox GtkContainer)
   gtk-box-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)


(defclass (GtkButtonBox gtkbox))
(defclass (GtkHBox gtkbox))
(defclass (GtkVBox gtkbox))
(defclass (GtkListItem gtkitem))
(defclass (GtkMenuItem gtkitem))

(def-ext-class (GtkColorSelectionDialog gtkwindow)
   gtk-color-selection-dialog-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)


(defclass (GtkPlug gtkwindow))


(defclass (GtkAspectFrame gtkframe))
(defclass (GtkAccelLabel gtklabel))
(defclass (GtkTipsQuery gtklabel))
(defclass (GtkOptionMenu GtkButton))
(defclass (GtkScale gtkrange))
(defclass (GtkScrollbar gtkrange))

(def-ext-class (GtkToggleButton GtkButton)
   gtk-toggle-button-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)

(defclass (GtkCheckButton gtktogglebutton)); #f #f #f)
(defclass (GtkCurve gtkdrawingarea))

(def-ext-class (GtkNotebook GtkContainer)
   gtk-notebook-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)

(defclass (GtkFontSelection gtknotebook))
(defclass (GtkHButtonBox gtkbuttonbox))

(def-ext-class (GtkPaned GtkContainer)
   gtk-paned-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)

(defclass (GtkHPaned gtkpaned))
(defclass (GtkHRuler GtkRuler))
(defclass (GtkHScale gtkscale))
(defclass (GtkHScrollbar gtkscrollbar))
(defclass (GtkHSeparator gtkseparator))
(defclass (GtkMenu gtkmenushell))
(defclass (GtkMenuBar gtkmenushell))
(defclass (GtkProgressBar GtkProgress))
(defclass (GtkRadioButton gtkcheckbutton))

(def-ext-class (GtkCheckMenuItem gtkmenuitem)
   gtk-check-menu-item-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)

(defclass (GtkRadioMenuItem gtkcheckmenuitem))

(defclass (GtkEntry gtkeditable))
;;    gtk-editable-custom-lookup
;;    php-gtk-custom-set
;;    php-gtk-custom-copy)

(defclass (GtkSpinButton gtkentry))
(defclass (GtkTearoffMenuItem gtkmenuitem))
(defclass (GtkVButtonBox gtkbuttonbox))
(defclass (GtkVPaned gtkpaned))
(defclass (GtkVRuler GtkRuler))
(defclass (GtkVScale gtkscale))
(defclass (GtkVScrollbar gtkscrollbar))
(defclass (GtkVSeparator gtkseparator))

(defclass (GtkAllocation pcc-gtk)
   x y width height)

(defclass GtkObjectClass)
(defclass GtkType)

(def-ext-class GtkSelectionData
   gtk-selection-data-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)





(def-ext-class (GtkCalendar GtkWidget)
   gtk-calendar-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)




(def-ext-class (GtkArrow gtkmisc)
   gtk-arrow-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)





(def-ext-class (GtkCList GtkContainer)
   gtk-clist-custom-lookup
;    (lambda (obj prop ref? k)
;       (let ((prop (string->symbol (mkstr prop)))
; 	    (props (php-object-custom-properties obj))
; 	    (this::gtk-clist (gtk-object obj)))
; 	 (case prop
; 	    ((focus_row) (convert-to-integer (pragma::int "GTK_CLIST($1)->focus_row" this)))
; 	    ((rows) (convert-to-integer (pragma::int "GTK_CLIST($1)->rows" this)))
; 	    ((sort_column) (convert-to-integer (pragma::int "GTK_CLIST($1)->sort_column" this)))
; 	    ((sort_type) (convert-to-integer (pragma::int "GTK_CLIST($1)->sort_type" this)))
; 	    ((selection) (make-custom-hash glist-hash-read-single
; 					   glist-hash-write-single
; 					   glist-hash-read-entire
; 					   (make-glist-hash-context (gtk-clist-selection this)
; 								    'int
; 								    convert-to-integer)))
; 	    ((selection_mode) (convert-to-integer (pragma::int "GTK_CLIST($1)->selection_mode" this)))
; 	    ((row_list) (make-custom-hash glist-hash-read-single
; 					  glist-hash-write-single
; 					  glist-hash-read-entire
; 					  (make-glist-hash-context (gtk-clist-row-list this)
; 								   'gtk-clist-row
; 								   ;php-gtk-clist-row-new
; 								   (lambda (c) (gtk-wrapper-new 'gtkclistrow c)))))
; 	    (else (k)))))
   php-gtk-custom-set
;    (lambda (obj prop ref? value k)
;       (case prop
; 	 (else (k))))
   php-gtk-custom-copy)


(def-ext-class GtkCListRow
   (lambda (obj prop ref? k)
      (let ((prop (string->symbol (mkstr prop)))
	    (props (php-object-custom-properties obj))
	    (this::GtkCListRow* (gtk-object obj)))
	 (case prop
	    ((state) (convert-to-integer (pragma::int "$1->state" this)))
	    ;;colors
; 	    ((foreground) (convert-to-integer (pragma::int "$1->state" this)))
; 	    ((background) (convert-to-integer (pragma::int "$1->state" this)))
	    ((style) (gtk-wrapper-new 'gtkstyle (pragma::GtkStyle* "$1->style" this)))
	    ((fg_set) (convert-to-boolean (pragma::bool "$1->fg_set" this)))
	    ((bg_set) (convert-to-boolean (pragma::bool "$1->bg_set" this)))
	    ((selectable) (convert-to-boolean (pragma::bool "$1->selectable" this)))
	    (else (k)))))
   (lambda (obj prop ref? value k)
      (case prop
	 (else (k))))
   (lambda (props)
      props))




(def-ext-class GtkCTreeNode
   (lambda (obj prop ref? k)
      (let ((prop (string->symbol (mkstr prop)))
	    (props (php-object-custom-properties obj))
	    (this::GtkCTreeNode* (gtk-object obj)))
	 (case prop
	    ((parent) (gtk-wrapper-new 'gtkctreenode (pragma::GtkCTreeNode* "GTK_CTREE_ROW($1)->parent" this)))
	    ((sibling) (gtk-wrapper-new 'gtkctreenode (pragma::GtkCTreeNode* "GTK_CTREE_ROW($1)->sibling" this)))

	    ;missing stuff in bgtk
; 	    ((children) (make-custom-hash glist-hash-read-single
; 					  glist-hash-write-single
; 					  glist-hash-read-entire
; 					  (make-glist-hash-context (gtk-ctree-node-children this)
; 								   'gtk-ctree-node
; 								   ;php-gtk-clist-row-new
; 								   (lambda (c) (gtk-wrapper-new 'gtkctreenode c)))))

	    ((pixmap_closed) (let ((p::GdkPixmap* (pragma::GdkPixmap* "GTK_CTREE_ROW($1)->pixmap_closed" this)))
				(if (foreign-null? p)
				    NULL
				    (gtk-wrapper-new 'gdkpixmap p))))
	    ((pixmap_opened) (let ((p::GdkPixmap* (pragma::GdkPixmap* "GTK_CTREE_ROW($1)->pixmap_opened" this)))
				(if (foreign-null? p)
				    NULL
				    (gtk-wrapper-new 'gdkpixmap p))))
	    ((mask_closed) (let ((p::GdkBitmap* (pragma::GdkBitmap* "GTK_CTREE_ROW($1)->mask_closed" this)))
				(if (foreign-null? p)
				    NULL
				    (gtk-wrapper-new 'gdkbitmap p))))
	    ((mask_opened) (let ((p::GdkBitmap* (pragma::GdkBitmap* "GTK_CTREE_ROW($1)->mask_opened" this)))
				(if (foreign-null? p)
				    NULL
				    (gtk-wrapper-new 'gdkbitmap p))))
	    ((level) (convert-to-boolean (pragma::bool "GTK_CTREE_ROW($1)->level" this)))
	    ((is_leaf) (convert-to-boolean (pragma::bool "GTK_CTREE_ROW($1)->is_leaf" this)))
	    ((expanded) (convert-to-boolean (pragma::bool "GTK_CTREE_ROW($1)->expanded" this)))
	    ((row) (gtk-wrapper-new 'gtkclistrow this))


	    (else (k)))))
   (lambda (obj prop ref? value k)
      (case prop
	 (else (k))))
   (lambda (props)
      props))


(def-ext-class (GtkFixed GtkContainer)
   gtk-fixed-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)

(def-ext-class (GtkLayout GtkContainer)
   gtk-layout-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)

(def-ext-class (GtkList GtkContainer)
   gtk-list-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)








(def-ext-class (GtkTable GtkContainer)
   gtk-table-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)

(def-ext-class (GtkToolbar GtkContainer)
   gtk-toolbar-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)


(def-ext-class (GtkHandleBox gtkbin)
   gtk-handle-box-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)


(def-ext-class (GtkAdjustment gtkdata)
   gtk-adjustment-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)



; (def-ext-class (GtkTreeItem gtkitem)
;    gtk-tree-item-custom-lookup
;    php-gtk-custom-set
;    php-gtk-custom-copy)

(def-ext-class (GtkDialog gtkwindow)
   gtk-dialog-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)


(def-ext-class (GtkFileSelection gtkwindow)
   gtk-file-selection-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)


(def-ext-class (GtkFontSelectionDialog gtkwindow)
   gtk-font-selection-dialog-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)

(def-ext-class (GtkInputDialog gtkdialog)
   gtk-input-dialog-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)





; (def-ext-class (GtkText gtkeditable)
;    gtk-text-custom-lookup
;    php-gtk-custom-set
;    php-gtk-custom-copy)






(defclass (GtkColorSelection gtkvbox))

(def-ext-class (GtkCombo gtkhbox)
   gtk-combo-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)


(def-ext-class (GtkCTree gtkclist)
   gtk-ctree-custom-lookup
;    (lambda (obj prop ref? k)
;       (let ((prop (string->symbol (mkstr prop)))
; 	    (props (php-object-custom-properties obj))
; 	    (this::gtk-ctree (gtk-object obj)))
; 	 (case prop
; 	    ((tree_indent) (convert-to-integer (pragma::int "GTK_CTREE($1)->tree_indent" this)))
; 	    ((tree_spacing) (convert-to-integer (pragma::int "GTK_CTREE($1)->tree_spacing" this)))
; 	    ((tree_column) (convert-to-integer (pragma::int "GTK_CTREE($1)->tree_column" this)))
; 	    ((line_style) (convert-to-integer (pragma::int "GTK_CTREE($1)->line_style" this)))
; 	    ((expander_style) (convert-to-integer (pragma::int "GTK_CTREE($1)->expander_style" this)))
; 	    ((clist) (gtk-wrapper-new 'gtkclist this))
; ; 	    ((selection) (make-custom-hash glist-hash-read-single
; ; 					   glist-hash-write-single
; ; 					   glist-hash-read-entire
; ; 					   (make-glist-hash-context (gtk-clist-selection this)
; ; 								    'int
; ; 								    convert-to-integer)))
; ; 	    ((selection_mode) (convert-to-integer (pragma::int "GTK_CLIST($1)->selection_mode" this)))

; 	    ;this is strange because the selection is longs on the clist
; 	    ((selection) (make-custom-hash glist-hash-read-single
; 					   glist-hash-write-single
; 					   glist-hash-read-entire
; 					   (make-glist-hash-context (gtk-clist-selection this)
; 								    'gtk-ctree-node
; 								    ;php-gtk-clist-row-new
; 								    (lambda (c) (gtk-wrapper-new 'gtkctreenode c)))))
; 	    ((row_list) (make-custom-hash glist-hash-read-single
; 					  glist-hash-write-single
; 					  glist-hash-read-entire
; 					  (make-glist-hash-context (gtk-clist-row-list this)
; 								   'gtk-ctree-node
; 								   ;php-gtk-clist-row-new
; 								   (lambda (c) (gtk-wrapper-new 'gtkctreenode c)))))
; 	    (else (k)))))
   php-gtk-custom-set
;    (lambda (obj prop ref? value k)
;       (case prop
; 	 (else (k))))
   php-gtk-custom-copy)



(def-ext-class (GtkGammaCurve gtkvbox)
   gtk-gamma-curve-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)



(defclass (GtkScintilla GtkFrame))


;;; this one is funky because it didn't come from the .defs files
(def-ext-class (GtkBoxChild pcc-gtk)
   gtk-box-child-custom-lookup
   php-gtk-custom-set
   php-gtk-custom-copy)



(defclass (libglade pcc-gtk))
(defclass (GladeXML GtkData))

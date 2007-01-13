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
(module gtk-enums-lib
;   (include "../../php-runtime.sch")
   (load (php-macros "../../../php-macros.scm"))
   (load (php-gtk-macros "php-gtk-macros.sch"))
   (extern (include "gtk/gtk.h"))
   (library php-runtime)
   (import (define-classes "define-classes.scm"))
   (export
    (init-gtk-enums-lib)))

;;;
;;; Module Init
;;; ===========

(define (init-gtk-enums-lib)
   (init-define-classes)
   1)


;; this (defclass (Gtk pcc-gtk)) became this, in order to get the
;; class-constants defined at the right time:
(add-startup-function-for-extension
 "gtk2"
 (lambda ()
    (define-extended-php-class 'Gtk 'pcc-gtk #f #f (lambda (a) a))

;;;
;;; Gtk Enums and Flags
;;; ===================


    (define-enum AnchorType
       (in-module "Gtk")
       (c-name "GtkAnchorType")
       (gtype-id "GTK_TYPE_ANCHOR_TYPE")
       (values
        '("center" "GTK_ANCHOR_CENTER")
        '("north" "GTK_ANCHOR_NORTH")
        '("north-west" "GTK_ANCHOR_NORTH_WEST")
        '("north-east" "GTK_ANCHOR_NORTH_EAST")
        '("south" "GTK_ANCHOR_SOUTH")
        '("south-west" "GTK_ANCHOR_SOUTH_WEST")
        '("south-east" "GTK_ANCHOR_SOUTH_EAST")
        '("west" "GTK_ANCHOR_WEST")
        '("east" "GTK_ANCHOR_EAST")
        '("n" "GTK_ANCHOR_N")
        '("nw" "GTK_ANCHOR_NW")
        '("ne" "GTK_ANCHOR_NE")
        '("s" "GTK_ANCHOR_S")
        '("sw" "GTK_ANCHOR_SW")
        '("se" "GTK_ANCHOR_SE")
        '("w" "GTK_ANCHOR_W")
        '("e" "GTK_ANCHOR_E")))

    (define-enum ArrowType
       (in-module "Gtk")
       (c-name "GtkArrowType")
       (gtype-id "GTK_TYPE_ARROW_TYPE")
       (values
        '("up" "GTK_ARROW_UP")
        '("down" "GTK_ARROW_DOWN")
        '("left" "GTK_ARROW_LEFT")
        '("right" "GTK_ARROW_RIGHT")))

    (define-enum ButtonBoxStyle
       (in-module "Gtk")
       (c-name "GtkButtonBoxStyle")
       (gtype-id "GTK_TYPE_BUTTON_BOX_STYLE")
       (values
        '("default-style" "GTK_BUTTONBOX_DEFAULT_STYLE")
        '("spread" "GTK_BUTTONBOX_SPREAD")
        '("edge" "GTK_BUTTONBOX_EDGE")
        '("start" "GTK_BUTTONBOX_START")
        '("end" "GTK_BUTTONBOX_END")))

    (define-enum ButtonsType
       (in-module "Gtk")
       (c-name "GtkButtonsType")
       (gtype-id "GTK_TYPE_BUTTONS_TYPE")
       (values
        '("none" "GTK_BUTTONS_NONE")
        '("ok" "GTK_BUTTONS_OK")
        '("close" "GTK_BUTTONS_CLOSE")
        '("cancel" "GTK_BUTTONS_CANCEL")
        '("yes-no" "GTK_BUTTONS_YES_NO")
        '("ok-cancel" "GTK_BUTTONS_OK_CANCEL")))

    (define-enum CellRendererMode
       (in-module "Gtk")
       (c-name "GtkCellRendererMode")
       (gtype-id "GTK_TYPE_CELL_RENDERER_MODE")
       (values
        '("inert" "GTK_CELL_RENDERER_MODE_INERT")
        '("activatable"
          "GTK_CELL_RENDERER_MODE_ACTIVATABLE")
        '("editable" "GTK_CELL_RENDERER_MODE_EDITABLE")))

    (define-enum CellType
       (in-module "Gtk")
       (c-name "GtkCellType")
       (gtype-id "GTK_TYPE_CELL_TYPE")
       (values
        '("empty" "GTK_CELL_EMPTY")
        '("text" "GTK_CELL_TEXT")
        '("pixmap" "GTK_CELL_PIXMAP")
        '("pixtext" "GTK_CELL_PIXTEXT")
        '("widget" "GTK_CELL_WIDGET")))

    (define-enum CListDragPos
       (in-module "Gtk")
       (c-name "GtkCListDragPos")
       (gtype-id "GTK_TYPE_CLIST_DRAG_POS")
       (values
        '("none" "GTK_CLIST_DRAG_NONE")
        '("before" "GTK_CLIST_DRAG_BEFORE")
        '("into" "GTK_CLIST_DRAG_INTO")
        '("after" "GTK_CLIST_DRAG_AFTER")))

    (define-enum CornerType
       (in-module "Gtk")
       (c-name "GtkCornerType")
       (gtype-id "GTK_TYPE_CORNER_TYPE")
       (values
        '("top-left" "GTK_CORNER_TOP_LEFT")
        '("bottom-left" "GTK_CORNER_BOTTOM_LEFT")
        '("top-right" "GTK_CORNER_TOP_RIGHT")
        '("bottom-right" "GTK_CORNER_BOTTOM_RIGHT")))

    (define-enum CTreeExpanderStyle
       (in-module "Gtk")
       (c-name "GtkCTreeExpanderStyle")
       (gtype-id "GTK_TYPE_CTREE_EXPANDER_STYLE")
       (values
        '("none" "GTK_CTREE_EXPANDER_NONE")
        '("square" "GTK_CTREE_EXPANDER_SQUARE")
        '("triangle" "GTK_CTREE_EXPANDER_TRIANGLE")
        '("circular" "GTK_CTREE_EXPANDER_CIRCULAR")))

    (define-enum CTreeExpansionType
       (in-module "Gtk")
       (c-name "GtkCTreeExpansionType")
       (gtype-id "GTK_TYPE_CTREE_EXPANSION_TYPE")
       (values
        '("expand" "GTK_CTREE_EXPANSION_EXPAND")
        '("expand-recursive"
          "GTK_CTREE_EXPANSION_EXPAND_RECURSIVE")
        '("collapse" "GTK_CTREE_EXPANSION_COLLAPSE")
        '("collapse-recursive"
          "GTK_CTREE_EXPANSION_COLLAPSE_RECURSIVE")
        '("toggle" "GTK_CTREE_EXPANSION_TOGGLE")
        '("toggle-recursive"
          "GTK_CTREE_EXPANSION_TOGGLE_RECURSIVE")))

    (define-enum CTreeLineStyle
       (in-module "Gtk")
       (c-name "GtkCTreeLineStyle")
       (gtype-id "GTK_TYPE_CTREE_LINE_STYLE")
       (values
        '("none" "GTK_CTREE_LINES_NONE")
        '("solid" "GTK_CTREE_LINES_SOLID")
        '("dotted" "GTK_CTREE_LINES_DOTTED")
        '("tabbed" "GTK_CTREE_LINES_TABBED")))

    (define-enum CTreePos
       (in-module "Gtk")
       (c-name "GtkCTreePos")
       (gtype-id "GTK_TYPE_CTREE_POS")
       (values
        '("before" "GTK_CTREE_POS_BEFORE")
        '("as-child" "GTK_CTREE_POS_AS_CHILD")
        '("after" "GTK_CTREE_POS_AFTER")))

    (define-enum CurveType
       (in-module "Gtk")
       (c-name "GtkCurveType")
       (gtype-id "GTK_TYPE_CURVE_TYPE")
       (values
        '("linear" "GTK_CURVE_TYPE_LINEAR")
        '("spline" "GTK_CURVE_TYPE_SPLINE")
        '("free" "GTK_CURVE_TYPE_FREE")))

    (define-enum DeleteType
       (in-module "Gtk")
       (c-name "GtkDeleteType")
       (gtype-id "GTK_TYPE_DELETE_TYPE")
       (values
        '("chars" "GTK_DELETE_CHARS")
        '("word-ends" "GTK_DELETE_WORD_ENDS")
        '("words" "GTK_DELETE_WORDS")
        '("display-lines" "GTK_DELETE_DISPLAY_LINES")
        '("display-line-ends"
          "GTK_DELETE_DISPLAY_LINE_ENDS")
        '("paragraph-ends" "GTK_DELETE_PARAGRAPH_ENDS")
        '("paragraphs" "GTK_DELETE_PARAGRAPHS")
        '("whitespace" "GTK_DELETE_WHITESPACE")))

    (define-enum DirectionType
       (in-module "Gtk")
       (c-name "GtkDirectionType")
       (gtype-id "GTK_TYPE_DIRECTION_TYPE")
       (values
        '("tab-forward" "GTK_DIR_TAB_FORWARD")
        '("tab-backward" "GTK_DIR_TAB_BACKWARD")
        '("up" "GTK_DIR_UP")
        '("down" "GTK_DIR_DOWN")
        '("left" "GTK_DIR_LEFT")
        '("right" "GTK_DIR_RIGHT")))

    (define-enum ExpanderStyle
       (in-module "Gtk")
       (c-name "GtkExpanderStyle")
       (gtype-id "GTK_TYPE_EXPANDER_STYLE")
       (values
        '("collapsed" "GTK_EXPANDER_COLLAPSED")
        '("semi-collapsed" "GTK_EXPANDER_SEMI_COLLAPSED")
        '("semi-expanded" "GTK_EXPANDER_SEMI_EXPANDED")
        '("expanded" "GTK_EXPANDER_EXPANDED")))

    (define-enum FileChooserAction
       (in-module "Gtk")
       (c-name "GtkFileChooserAction")
       (gtype-id "GTK_TYPE_FILE_CHOOSER_ACTION")
       (values
        '("open" "GTK_FILE_CHOOSER_ACTION_OPEN")
        '("save" "GTK_FILE_CHOOSER_ACTION_SAVE")
        '("select-folder"
          "GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER")
        '("create-folder"
          "GTK_FILE_CHOOSER_ACTION_CREATE_FOLDER")))

    (define-enum FileChooserError
       (in-module "Gtk")
       (c-name "GtkFileChooserError")
       (gtype-id "GTK_TYPE_FILE_CHOOSER_ERROR")
       (values
        '("nonexistent"
          "GTK_FILE_CHOOSER_ERROR_NONEXISTENT")
        '("bad-filename"
          "GTK_FILE_CHOOSER_ERROR_BAD_FILENAME")))

    (define-enum IconSize
       (in-module "Gtk")
       (c-name "GtkIconSize")
       (gtype-id "GTK_TYPE_ICON_SIZE")
       (values
        '("invalid" "GTK_ICON_SIZE_INVALID")
        '("menu" "GTK_ICON_SIZE_MENU")
        '("small-toolbar" "GTK_ICON_SIZE_SMALL_TOOLBAR")
        '("large-toolbar" "GTK_ICON_SIZE_LARGE_TOOLBAR")
        '("button" "GTK_ICON_SIZE_BUTTON")
        '("dnd" "GTK_ICON_SIZE_DND")
        '("dialog" "GTK_ICON_SIZE_DIALOG")))

    (define-enum IconThemeError
       (in-module "Gtk")
       (c-name "GtkIconThemeError")
       (gtype-id "GTK_TYPE_ICON_THEME_ERROR")
       (values
        '("not-found" "GTK_ICON_THEME_NOT_FOUND")
        '("failed" "GTK_ICON_THEME_FAILED")))

    (define-enum ImageType
       (in-module "Gtk")
       (c-name "GtkImageType")
       (gtype-id "GTK_TYPE_IMAGE_TYPE")
       (values
        '("empty" "GTK_IMAGE_EMPTY")
        '("pixmap" "GTK_IMAGE_PIXMAP")
        '("image" "GTK_IMAGE_IMAGE")
        '("pixbuf" "GTK_IMAGE_PIXBUF")
        '("stock" "GTK_IMAGE_STOCK")
        '("icon-set" "GTK_IMAGE_ICON_SET")
        '("animation" "GTK_IMAGE_ANIMATION")))

    (define-enum IMPreeditStyle
       (in-module "Gtk")
       (c-name "GtkIMPreeditStyle")
       (gtype-id "GTK_TYPE_IM_PREEDIT_STYLE")
       (values
        '("nothing" "GTK_IM_PREEDIT_NOTHING")
        '("callback" "GTK_IM_PREEDIT_CALLBACK")
        '("none" "GTK_IM_PREEDIT_NONE")))

    (define-enum IMStatusStyle
       (in-module "Gtk")
       (c-name "GtkIMStatusStyle")
       (gtype-id "GTK_TYPE_IM_STATUS_STYLE")
       (values
        '("nothing" "GTK_IM_STATUS_NOTHING")
        '("callback" "GTK_IM_STATUS_CALLBACK")))

    (define-enum Justification
       (in-module "Gtk")
       (c-name "GtkJustification")
       (gtype-id "GTK_TYPE_JUSTIFICATION")
       (values
        '("left" "GTK_JUSTIFY_LEFT")
        '("right" "GTK_JUSTIFY_RIGHT")
        '("center" "GTK_JUSTIFY_CENTER")
        '("fill" "GTK_JUSTIFY_FILL")))

    (define-enum MatchType
       (in-module "Gtk")
       (c-name "GtkMatchType")
       (gtype-id "GTK_TYPE_MATCH_TYPE")
       (values
        '("all" "GTK_MATCH_ALL")
        '("all-tail" "GTK_MATCH_ALL_TAIL")
        '("head" "GTK_MATCH_HEAD")
        '("tail" "GTK_MATCH_TAIL")
        '("exact" "GTK_MATCH_EXACT")
        '("last" "GTK_MATCH_LAST")))

    (define-enum MenuDirectionType
       (in-module "Gtk")
       (c-name "GtkMenuDirectionType")
       (gtype-id "GTK_TYPE_MENU_DIRECTION_TYPE")
       (values
        '("parent" "GTK_MENU_DIR_PARENT")
        '("child" "GTK_MENU_DIR_CHILD")
        '("next" "GTK_MENU_DIR_NEXT")
        '("prev" "GTK_MENU_DIR_PREV")))

    (define-enum MessageType
       (in-module "Gtk")
       (c-name "GtkMessageType")
       (gtype-id "GTK_TYPE_MESSAGE_TYPE")
       (values
        '("info" "GTK_MESSAGE_INFO")
        '("warning" "GTK_MESSAGE_WARNING")
        '("question" "GTK_MESSAGE_QUESTION")
        '("error" "GTK_MESSAGE_ERROR")))

    (define-enum MetricType
       (in-module "Gtk")
       (c-name "GtkMetricType")
       (gtype-id "GTK_TYPE_METRIC_TYPE")
       (values
        '("pixels" "GTK_PIXELS")
        '("inches" "GTK_INCHES")
        '("centimeters" "GTK_CENTIMETERS")))

    (define-enum MovementStep
       (in-module "Gtk")
       (c-name "GtkMovementStep")
       (gtype-id "GTK_TYPE_MOVEMENT_STEP")
       (values
        '("logical-positions"
          "GTK_MOVEMENT_LOGICAL_POSITIONS")
        '("visual-positions"
          "GTK_MOVEMENT_VISUAL_POSITIONS")
        '("words" "GTK_MOVEMENT_WORDS")
        '("display-lines" "GTK_MOVEMENT_DISPLAY_LINES")
        '("display-line-ends"
          "GTK_MOVEMENT_DISPLAY_LINE_ENDS")
        '("paragraphs" "GTK_MOVEMENT_PARAGRAPHS")
        '("paragraph-ends" "GTK_MOVEMENT_PARAGRAPH_ENDS")
        '("pages" "GTK_MOVEMENT_PAGES")
        '("buffer-ends" "GTK_MOVEMENT_BUFFER_ENDS")
        '("horizontal-pages"
          "GTK_MOVEMENT_HORIZONTAL_PAGES")))

    (define-enum NotebookTab
       (in-module "Gtk")
       (c-name "GtkNotebookTab")
       (gtype-id "GTK_TYPE_NOTEBOOK_TAB")
       (values
        '("first" "GTK_NOTEBOOK_TAB_FIRST")
        '("last" "GTK_NOTEBOOK_TAB_LAST")))

    (define-enum Orientation
       (in-module "Gtk")
       (c-name "GtkOrientation")
       (gtype-id "GTK_TYPE_ORIENTATION")
       (values
        '("horizontal" "GTK_ORIENTATION_HORIZONTAL")
        '("vertical" "GTK_ORIENTATION_VERTICAL")))

    (define-enum PackType
       (in-module "Gtk")
       (c-name "GtkPackType")
       (gtype-id "GTK_TYPE_PACK_TYPE")
       (values
        '("start" "GTK_PACK_START")
        '("end" "GTK_PACK_END")))

    (define-enum PathPriorityType
       (in-module "Gtk")
       (c-name "GtkPathPriorityType")
       (gtype-id "GTK_TYPE_PATH_PRIORITY_TYPE")
       (values
        '("lowest" "GTK_PATH_PRIO_LOWEST")
        '("gtk" "GTK_PATH_PRIO_GTK")
        '("application" "GTK_PATH_PRIO_APPLICATION")
        '("theme" "GTK_PATH_PRIO_THEME")
        '("rc" "GTK_PATH_PRIO_RC")
        '("highest" "GTK_PATH_PRIO_HIGHEST")))

    (define-enum PathType
       (in-module "Gtk")
       (c-name "GtkPathType")
       (gtype-id "GTK_TYPE_PATH_TYPE")
       (values
        '("widget" "GTK_PATH_WIDGET")
        '("widget-class" "GTK_PATH_WIDGET_CLASS")
        '("class" "GTK_PATH_CLASS")))

    (define-enum PolicyType
       (in-module "Gtk")
       (c-name "GtkPolicyType")
       (gtype-id "GTK_TYPE_POLICY_TYPE")
       (values
        '("always" "GTK_POLICY_ALWAYS")
        '("automatic" "GTK_POLICY_AUTOMATIC")
        '("never" "GTK_POLICY_NEVER")))

    (define-enum PositionType
       (in-module "Gtk")
       (c-name "GtkPositionType")
       (gtype-id "GTK_TYPE_POSITION_TYPE")
       (values
        '("left" "GTK_POS_LEFT")
        '("right" "GTK_POS_RIGHT")
        '("top" "GTK_POS_TOP")
        '("bottom" "GTK_POS_BOTTOM")))

    (define-enum PreviewType
       (in-module "Gtk")
       (c-name "GtkPreviewType")
       (gtype-id "GTK_TYPE_PREVIEW_TYPE")
       (values
        '("color" "GTK_PREVIEW_COLOR")
        '("grayscale" "GTK_PREVIEW_GRAYSCALE")))

    (define-enum ProgressBarOrientation
       (in-module "Gtk")
       (c-name "GtkProgressBarOrientation")
       (gtype-id "GTK_TYPE_PROGRESS_BAR_ORIENTATION")
       (values
        '("left-to-right" "GTK_PROGRESS_LEFT_TO_RIGHT")
        '("right-to-left" "GTK_PROGRESS_RIGHT_TO_LEFT")
        '("bottom-to-top" "GTK_PROGRESS_BOTTOM_TO_TOP")
        '("top-to-bottom" "GTK_PROGRESS_TOP_TO_BOTTOM")))

    (define-enum ProgressBarStyle
       (in-module "Gtk")
       (c-name "GtkProgressBarStyle")
       (gtype-id "GTK_TYPE_PROGRESS_BAR_STYLE")
       (values
        '("continuous" "GTK_PROGRESS_CONTINUOUS")
        '("discrete" "GTK_PROGRESS_DISCRETE")))

    (define-enum RcTokenType
       (in-module "Gtk")
       (c-name "GtkRcTokenType")
       (gtype-id "GTK_TYPE_RC_TOKEN_TYPE")
       (values
        '("invalid" "GTK_RC_TOKEN_INVALID")
        '("include" "GTK_RC_TOKEN_INCLUDE")
        '("normal" "GTK_RC_TOKEN_NORMAL")
        '("active" "GTK_RC_TOKEN_ACTIVE")
        '("prelight" "GTK_RC_TOKEN_PRELIGHT")
        '("selected" "GTK_RC_TOKEN_SELECTED")
        '("insensitive" "GTK_RC_TOKEN_INSENSITIVE")
        '("fg" "GTK_RC_TOKEN_FG")
        '("bg" "GTK_RC_TOKEN_BG")
        '("text" "GTK_RC_TOKEN_TEXT")
        '("base" "GTK_RC_TOKEN_BASE")
        '("xthickness" "GTK_RC_TOKEN_XTHICKNESS")
        '("ythickness" "GTK_RC_TOKEN_YTHICKNESS")
        '("font" "GTK_RC_TOKEN_FONT")
        '("fontset" "GTK_RC_TOKEN_FONTSET")
        '("font-name" "GTK_RC_TOKEN_FONT_NAME")
        '("bg-pixmap" "GTK_RC_TOKEN_BG_PIXMAP")
        '("pixmap-path" "GTK_RC_TOKEN_PIXMAP_PATH")
        '("style" "GTK_RC_TOKEN_STYLE")
        '("binding" "GTK_RC_TOKEN_BINDING")
        '("bind" "GTK_RC_TOKEN_BIND")
        '("widget" "GTK_RC_TOKEN_WIDGET")
        '("widget-class" "GTK_RC_TOKEN_WIDGET_CLASS")
        '("class" "GTK_RC_TOKEN_CLASS")
        '("lowest" "GTK_RC_TOKEN_LOWEST")
        '("gtk" "GTK_RC_TOKEN_GTK")
        '("application" "GTK_RC_TOKEN_APPLICATION")
        '("theme" "GTK_RC_TOKEN_THEME")
        '("rc" "GTK_RC_TOKEN_RC")
        '("highest" "GTK_RC_TOKEN_HIGHEST")
        '("engine" "GTK_RC_TOKEN_ENGINE")
        '("module-path" "GTK_RC_TOKEN_MODULE_PATH")
        '("im-module-path" "GTK_RC_TOKEN_IM_MODULE_PATH")
        '("im-module-file" "GTK_RC_TOKEN_IM_MODULE_FILE")
        '("stock" "GTK_RC_TOKEN_STOCK")
        '("ltr" "GTK_RC_TOKEN_LTR")
        '("rtl" "GTK_RC_TOKEN_RTL")
        '("last" "GTK_RC_TOKEN_LAST")))

    (define-enum ReliefStyle
       (in-module "Gtk")
       (c-name "GtkReliefStyle")
       (gtype-id "GTK_TYPE_RELIEF_STYLE")
       (values
        '("normal" "GTK_RELIEF_NORMAL")
        '("half" "GTK_RELIEF_HALF")
        '("none" "GTK_RELIEF_NONE")))

    (define-enum ResizeMode
       (in-module "Gtk")
       (c-name "GtkResizeMode")
       (gtype-id "GTK_TYPE_RESIZE_MODE")
       (values
        '("parent" "GTK_RESIZE_PARENT")
        '("queue" "GTK_RESIZE_QUEUE")
        '("immediate" "GTK_RESIZE_IMMEDIATE")))

    (define-enum ResponseType
       (in-module "Gtk")
       (c-name "GtkResponseType")
       (gtype-id "GTK_TYPE_RESPONSE_TYPE")
       (values
        '("none" "GTK_RESPONSE_NONE")
        '("reject" "GTK_RESPONSE_REJECT")
        '("accept" "GTK_RESPONSE_ACCEPT")
        '("delete-event" "GTK_RESPONSE_DELETE_EVENT")
        '("ok" "GTK_RESPONSE_OK")
        '("cancel" "GTK_RESPONSE_CANCEL")
        '("close" "GTK_RESPONSE_CLOSE")
        '("yes" "GTK_RESPONSE_YES")
        '("no" "GTK_RESPONSE_NO")
        '("apply" "GTK_RESPONSE_APPLY")
        '("help" "GTK_RESPONSE_HELP")))

    (define-enum ScrollStep
       (in-module "Gtk")
       (c-name "GtkScrollStep")
       (gtype-id "GTK_TYPE_SCROLL_STEP")
       (values
        '("steps" "GTK_SCROLL_STEPS")
        '("pages" "GTK_SCROLL_PAGES")
        '("ends" "GTK_SCROLL_ENDS")
        '("horizontal-steps"
          "GTK_SCROLL_HORIZONTAL_STEPS")
        '("horizontal-pages"
          "GTK_SCROLL_HORIZONTAL_PAGES")
        '("horizontal-ends" "GTK_SCROLL_HORIZONTAL_ENDS")))

    (define-enum ScrollType
       (in-module "Gtk")
       (c-name "GtkScrollType")
       (gtype-id "GTK_TYPE_SCROLL_TYPE")
       (values
        '("none" "GTK_SCROLL_NONE")
        '("jump" "GTK_SCROLL_JUMP")
        '("step-backward" "GTK_SCROLL_STEP_BACKWARD")
        '("step-forward" "GTK_SCROLL_STEP_FORWARD")
        '("page-backward" "GTK_SCROLL_PAGE_BACKWARD")
        '("page-forward" "GTK_SCROLL_PAGE_FORWARD")
        '("step-up" "GTK_SCROLL_STEP_UP")
        '("step-down" "GTK_SCROLL_STEP_DOWN")
        '("page-up" "GTK_SCROLL_PAGE_UP")
        '("page-down" "GTK_SCROLL_PAGE_DOWN")
        '("step-left" "GTK_SCROLL_STEP_LEFT")
        '("step-right" "GTK_SCROLL_STEP_RIGHT")
        '("page-left" "GTK_SCROLL_PAGE_LEFT")
        '("page-right" "GTK_SCROLL_PAGE_RIGHT")
        '("start" "GTK_SCROLL_START")
        '("end" "GTK_SCROLL_END")))

    (define-enum SelectionMode
       (in-module "Gtk")
       (c-name "GtkSelectionMode")
       (gtype-id "GTK_TYPE_SELECTION_MODE")
       (values
        '("none" "GTK_SELECTION_NONE")
        '("single" "GTK_SELECTION_SINGLE")
        '("browse" "GTK_SELECTION_BROWSE")
        '("multiple" "GTK_SELECTION_MULTIPLE")
        '("extended" "GTK_SELECTION_EXTENDED")))

    (define-enum ShadowType
       (in-module "Gtk")
       (c-name "GtkShadowType")
       (gtype-id "GTK_TYPE_SHADOW_TYPE")
       (values
        '("none" "GTK_SHADOW_NONE")
        '("in" "GTK_SHADOW_IN")
        '("out" "GTK_SHADOW_OUT")
        '("etched-in" "GTK_SHADOW_ETCHED_IN")
        '("etched-out" "GTK_SHADOW_ETCHED_OUT")))

    (define-enum SideType
       (in-module "Gtk")
       (c-name "GtkSideType")
       (gtype-id "GTK_TYPE_SIDE_TYPE")
       (values
        '("top" "GTK_SIDE_TOP")
        '("bottom" "GTK_SIDE_BOTTOM")
        '("left" "GTK_SIDE_LEFT")
        '("right" "GTK_SIDE_RIGHT")))

    (define-enum SizeGroupMode
       (in-module "Gtk")
       (c-name "GtkSizeGroupMode")
       (gtype-id "GTK_TYPE_SIZE_GROUP_MODE")
       (values
        '("none" "GTK_SIZE_GROUP_NONE")
        '("horizontal" "GTK_SIZE_GROUP_HORIZONTAL")
        '("vertical" "GTK_SIZE_GROUP_VERTICAL")
        '("both" "GTK_SIZE_GROUP_BOTH")))

    (define-enum SortType
       (in-module "Gtk")
       (c-name "GtkSortType")
       (gtype-id "GTK_TYPE_SORT_TYPE")
       (values
        '("ascending" "GTK_SORT_ASCENDING")
        '("descending" "GTK_SORT_DESCENDING")))

    (define-enum SpinButtonUpdatePolicy
       (in-module "Gtk")
       (c-name "GtkSpinButtonUpdatePolicy")
       (gtype-id "GTK_TYPE_SPIN_BUTTON_UPDATE_POLICY")
       (values
        '("always" "GTK_UPDATE_ALWAYS")
        '("if-valid" "GTK_UPDATE_IF_VALID")))

    (define-enum SpinType
       (in-module "Gtk")
       (c-name "GtkSpinType")
       (gtype-id "GTK_TYPE_SPIN_TYPE")
       (values
        '("step-forward" "GTK_SPIN_STEP_FORWARD")
        '("step-backward" "GTK_SPIN_STEP_BACKWARD")
        '("page-forward" "GTK_SPIN_PAGE_FORWARD")
        '("page-backward" "GTK_SPIN_PAGE_BACKWARD")
        '("home" "GTK_SPIN_HOME")
        '("end" "GTK_SPIN_END")
        '("user-defined" "GTK_SPIN_USER_DEFINED")))

    (define-enum StateType
       (in-module "Gtk")
       (c-name "GtkStateType")
       (gtype-id "GTK_TYPE_STATE_TYPE")
       (values
        '("normal" "GTK_STATE_NORMAL")
        '("active" "GTK_STATE_ACTIVE")
        '("prelight" "GTK_STATE_PRELIGHT")
        '("selected" "GTK_STATE_SELECTED")
        '("insensitive" "GTK_STATE_INSENSITIVE")))

    (define-enum SubmenuDirection
       (in-module "Gtk")
       (c-name "GtkSubmenuDirection")
       (gtype-id "GTK_TYPE_SUBMENU_DIRECTION")
       (values
        '("left" "GTK_DIRECTION_LEFT")
        '("right" "GTK_DIRECTION_RIGHT")))

    (define-enum SubmenuPlacement
       (in-module "Gtk")
       (c-name "GtkSubmenuPlacement")
       (gtype-id "GTK_TYPE_SUBMENU_PLACEMENT")
       (values
        '("top-bottom" "GTK_TOP_BOTTOM")
        '("left-right" "GTK_LEFT_RIGHT")))

    (define-enum TextDirection
       (in-module "Gtk")
       (c-name "GtkTextDirection")
       (gtype-id "GTK_TYPE_TEXT_DIRECTION")
       (values
        '("none" "GTK_TEXT_DIR_NONE")
        '("ltr" "GTK_TEXT_DIR_LTR")
        '("rtl" "GTK_TEXT_DIR_RTL")))

    (define-enum TextWindowType
       (in-module "Gtk")
       (c-name "GtkTextWindowType")
       (gtype-id "GTK_TYPE_TEXT_WINDOW_TYPE")
       (values
        '("private" "GTK_TEXT_WINDOW_PRIVATE")
        '("widget" "GTK_TEXT_WINDOW_WIDGET")
        '("text" "GTK_TEXT_WINDOW_TEXT")
        '("left" "GTK_TEXT_WINDOW_LEFT")
        '("right" "GTK_TEXT_WINDOW_RIGHT")
        '("top" "GTK_TEXT_WINDOW_TOP")
        '("bottom" "GTK_TEXT_WINDOW_BOTTOM")))

    (define-enum ToolbarChildType
       (in-module "Gtk")
       (c-name "GtkToolbarChildType")
       (gtype-id "GTK_TYPE_TOOLBAR_CHILD_TYPE")
       (values
        '("space" "GTK_TOOLBAR_CHILD_SPACE")
        '("button" "GTK_TOOLBAR_CHILD_BUTTON")
        '("togglebutton" "GTK_TOOLBAR_CHILD_TOGGLEBUTTON")
        '("radiobutton" "GTK_TOOLBAR_CHILD_RADIOBUTTON")
        '("widget" "GTK_TOOLBAR_CHILD_WIDGET")))

    (define-enum ToolbarSpaceStyle
       (in-module "Gtk")
       (c-name "GtkToolbarSpaceStyle")
       (gtype-id "GTK_TYPE_TOOLBAR_SPACE_STYLE")
       (values
        '("empty" "GTK_TOOLBAR_SPACE_EMPTY")
        '("line" "GTK_TOOLBAR_SPACE_LINE")))

    (define-enum ToolbarStyle
       (in-module "Gtk")
       (c-name "GtkToolbarStyle")
       (gtype-id "GTK_TYPE_TOOLBAR_STYLE")
       (values
        '("icons" "GTK_TOOLBAR_ICONS")
        '("text" "GTK_TOOLBAR_TEXT")
        '("both" "GTK_TOOLBAR_BOTH")
        '("both-horiz" "GTK_TOOLBAR_BOTH_HORIZ")))

    (define-enum TreeViewColumnSizing
       (in-module "Gtk")
       (c-name "GtkTreeViewColumnSizing")
       (gtype-id "GTK_TYPE_TREE_VIEW_COLUMN_SIZING")
       (values
        '("grow-only" "GTK_TREE_VIEW_COLUMN_GROW_ONLY")
        '("autosize" "GTK_TREE_VIEW_COLUMN_AUTOSIZE")
        '("fixed" "GTK_TREE_VIEW_COLUMN_FIXED")))

    (define-enum TreeViewDropPosition
       (in-module "Gtk")
       (c-name "GtkTreeViewDropPosition")
       (gtype-id "GTK_TYPE_TREE_VIEW_DROP_POSITION")
       (values
        '("before" "GTK_TREE_VIEW_DROP_BEFORE")
        '("after" "GTK_TREE_VIEW_DROP_AFTER")
        '("into-or-before"
          "GTK_TREE_VIEW_DROP_INTO_OR_BEFORE")
        '("into-or-after"
          "GTK_TREE_VIEW_DROP_INTO_OR_AFTER")))

    ;; (define-enum TreeViewMode
    ;;   (in-module "Gtk")
    ;;   (c-name "GtkTreeViewMode")
    ;;   (gtype-id "GTK_TYPE_TREE_VIEW_MODE")
    ;;   (values
    ;;     '("line" "GTK_TREE_VIEW_LINE")
    ;;     '("item" "GTK_TREE_VIEW_ITEM")))

    (define-enum UpdateType
       (in-module "Gtk")
       (c-name "GtkUpdateType")
       (gtype-id "GTK_TYPE_UPDATE_TYPE")
       (values
        '("continuous" "GTK_UPDATE_CONTINUOUS")
        '("discontinuous" "GTK_UPDATE_DISCONTINUOUS")
        '("delayed" "GTK_UPDATE_DELAYED")))

    (define-enum Visibility
       (in-module "Gtk")
       (c-name "GtkVisibility")
       (gtype-id "GTK_TYPE_VISIBILITY")
       (values
        '("none" "GTK_VISIBILITY_NONE")
        '("partial" "GTK_VISIBILITY_PARTIAL")
        '("full" "GTK_VISIBILITY_FULL")))

    (define-enum WidgetHelpType
       (in-module "Gtk")
       (c-name "GtkWidgetHelpType")
       (gtype-id "GTK_TYPE_WIDGET_HELP_TYPE")
       (values
        '("tooltip" "GTK_WIDGET_HELP_TOOLTIP")
        '("whats-this" "GTK_WIDGET_HELP_WHATS_THIS")))

    (define-enum WindowPosition
       (in-module "Gtk")
       (c-name "GtkWindowPosition")
       (gtype-id "GTK_TYPE_WINDOW_POSITION")
       (values
        '("none" "GTK_WIN_POS_NONE")
        '("center" "GTK_WIN_POS_CENTER")
        '("mouse" "GTK_WIN_POS_MOUSE")
        '("center-always" "GTK_WIN_POS_CENTER_ALWAYS")
        '("center-on-parent"
          "GTK_WIN_POS_CENTER_ON_PARENT")))

    (define-enum WindowType
       (in-module "Gtk")
       (c-name "GtkWindowType")
       (gtype-id "GTK_TYPE_WINDOW_TYPE")
       (values
        '("toplevel" "GTK_WINDOW_TOPLEVEL")
        '("popup" "GTK_WINDOW_POPUP")))

    (define-enum WrapMode
       (in-module "Gtk")
       (c-name "GtkWrapMode")
       (gtype-id "GTK_TYPE_WRAP_MODE")
       (values
        '("none" "GTK_WRAP_NONE")
        '("char" "GTK_WRAP_CHAR")
        '("word" "GTK_WRAP_WORD")
        '("word_char" "GTK_WRAP_WORD_CHAR")))

    (define-flags AccelFlags
       (in-module "Gtk")
       (c-name "GtkAccelFlags")
       (gtype-id "GTK_TYPE_ACCEL_FLAGS")
       (values
        '("visible" "GTK_ACCEL_VISIBLE")
        ;;     '("signal-visible" "GTK_ACCEL_SIGNAL_VISIBLE")
        '("locked" "GTK_ACCEL_LOCKED")
        '("mask" "GTK_ACCEL_MASK")))

    (define-flags ArgFlags
       (in-module "Gtk")
       (c-name "GtkArgFlags")
       (gtype-id "GTK_TYPE_ARG_FLAGS")
       (values
        '("readable" "GTK_ARG_READABLE")
        '("writable" "GTK_ARG_WRITABLE")
        '("construct" "GTK_ARG_CONSTRUCT")
        '("construct-only" "GTK_ARG_CONSTRUCT_ONLY")
        '("child-arg" "GTK_ARG_CHILD_ARG")))

    (define-flags AttachOptions
       (in-module "Gtk")
       (c-name "GtkAttachOptions")
       (gtype-id "GTK_TYPE_ATTACH_OPTIONS")
       (values
        '("expand" "GTK_EXPAND")
        '("shrink" "GTK_SHRINK")
        '("fill" "GTK_FILL")))

    (define-flags ButtonAction
       (in-module "Gtk")
       (c-name "GtkButtonAction")
       (gtype-id "GTK_TYPE_BUTTON_ACTION")
       (values
        '("ignored" "GTK_BUTTON_IGNORED")
        '("selects" "GTK_BUTTON_SELECTS")
        '("drags" "GTK_BUTTON_DRAGS")
        '("expands" "GTK_BUTTON_EXPANDS")))

    (define-flags CalendarDisplayOptions
       (in-module "Gtk")
       (c-name "GtkCalendarDisplayOptions")
       (gtype-id "GTK_TYPE_CALENDAR_DISPLAY_OPTIONS")
       (values
        '("show-heading" "GTK_CALENDAR_SHOW_HEADING")
        '("show-day-names" "GTK_CALENDAR_SHOW_DAY_NAMES")
        '("no-month-change"
          "GTK_CALENDAR_NO_MONTH_CHANGE")
        '("show-week-numbers"
          "GTK_CALENDAR_SHOW_WEEK_NUMBERS")
        '("week-start-monday"
          "GTK_CALENDAR_WEEK_START_MONDAY")))

    (define-flags CellRendererState
       (in-module "Gtk")
       (c-name "GtkCellRendererState")
       (gtype-id "GTK_TYPE_CELL_RENDERER_STATE")
       (values
        '("selected" "GTK_CELL_RENDERER_SELECTED")
        '("prelit" "GTK_CELL_RENDERER_PRELIT")
        '("insensitive" "GTK_CELL_RENDERER_INSENSITIVE")
        '("sorted" "GTK_CELL_RENDERER_SORTED")
        '("focused" "GTK_CELL_RENDERER_FOCUSED")))

    (define-flags DebugFlag
       (in-module "Gtk")
       (c-name "GtkDebugFlag")
       (gtype-id "GTK_TYPE_DEBUG_FLAG")
       (values
        '("misc" "GTK_DEBUG_MISC")
        '("plugsocket" "GTK_DEBUG_PLUGSOCKET")
        '("text" "GTK_DEBUG_TEXT")
        '("tree" "GTK_DEBUG_TREE")
        '("updates" "GTK_DEBUG_UPDATES")
        '("keybindings" "GTK_DEBUG_KEYBINDINGS")
        '("multihead" "GTK_DEBUG_MULTIHEAD")))

    (define-flags DestDefaults
       (in-module "Gtk")
       (c-name "GtkDestDefaults")
       (gtype-id "GTK_TYPE_DEST_DEFAULTS")
       (values
        '("motion" "GTK_DEST_DEFAULT_MOTION")
        '("highlight" "GTK_DEST_DEFAULT_HIGHLIGHT")
        '("drop" "GTK_DEST_DEFAULT_DROP")
        '("all" "GTK_DEST_DEFAULT_ALL")))

    (define-flags DialogFlags
       (in-module "Gtk")
       (c-name "GtkDialogFlags")
       (gtype-id "GTK_TYPE_DIALOG_FLAGS")
       (values
        '("modal" "GTK_DIALOG_MODAL")
        '("destroy-with-parent"
          "GTK_DIALOG_DESTROY_WITH_PARENT")
        '("no-separator" "GTK_DIALOG_NO_SEPARATOR")))

    (define-flags FileFilterFlags
       (in-module "Gtk")
       (c-name "GtkFileFilterFlags")
       (gtype-id "GTK_TYPE_FILE_FILTER_FLAGS")
       (values
        '("filename" "GTK_FILE_FILTER_FILENAME")
        '("uri" "GTK_FILE_FILTER_URI")
        '("display-name" "GTK_FILE_FILTER_DISPLAY_NAME")
        '("mime-type" "GTK_FILE_FILTER_MIME_TYPE")))

    (define-flags IconLookupFlags
       (in-module "Gtk")
       (c-name "GtkIconLookupFlags")
       (gtype-id "GTK_TYPE_ICON_LOOKUP_FLAGS")
       (values
        '("no-svg" "GTK_ICON_LOOKUP_NO_SVG")
        '("force-svg" "GTK_ICON_LOOKUP_FORCE_SVG")
        '("use-builtin" "GTK_ICON_LOOKUP_USE_BUILTIN")))

    (define-flags ObjectFlags
       (in-module "Gtk")
       (c-name "GtkObjectFlags")
       (gtype-id "GTK_TYPE_OBJECT_FLAGS")
       (values
        '("in-destruction" "GTK_IN_DESTRUCTION")
        '("floating" "GTK_FLOATING")
        '("reserved-1" "GTK_RESERVED_1")
        '("reserved-2" "GTK_RESERVED_2")))

    ;; (define-flags PrivateFlags
    ;;   (in-module "Gtk")
    ;;   (c-name "GtkPrivateFlags")
    ;;   (gtype-id "GTK_TYPE_PRIVATE_FLAGS")
    ;;   (values
    ;;     '("user-style" "PRIVATE_GTK_USER_STYLE")
    ;;     '("resize-pending" "PRIVATE_GTK_RESIZE_PENDING")
    ;;     '("leave-pending" "PRIVATE_GTK_LEAVE_PENDING")
    ;;     '("has-shape-mask" "PRIVATE_GTK_HAS_SHAPE_MASK")
    ;;     '("in-reparent" "PRIVATE_GTK_IN_REPARENT")
    ;;     '("direction-set" "PRIVATE_GTK_DIRECTION_SET")
    ;;     '("direction-ltr" "PRIVATE_GTK_DIRECTION_LTR")
    ;;     '("anchored" "PRIVATE_GTK_ANCHORED")
    ;;     '("child-visible" "PRIVATE_GTK_CHILD_VISIBLE")
    ;;     '("redraw-on-alloc" "PRIVATE_GTK_REDRAW_ON_ALLOC")
    ;;     '("alloc-needed" "PRIVATE_GTK_ALLOC_NEEDED")
    ;;     '("request-needed" "PRIVATE_GTK_REQUEST_NEEDED")))

    (define-flags RcFlags
       (in-module "Gtk")
       (c-name "GtkRcFlags")
       (gtype-id "GTK_TYPE_RC_FLAGS")
       (values
        '("fg" "GTK_RC_FG")
        '("bg" "GTK_RC_BG")
        '("text" "GTK_RC_TEXT")
        '("base" "GTK_RC_BASE")))

    (define-flags TargetFlags
       (in-module "Gtk")
       (c-name "GtkTargetFlags")
       (gtype-id "GTK_TYPE_TARGET_FLAGS")
       (values
        '("app" "GTK_TARGET_SAME_APP")
        '("widget" "GTK_TARGET_SAME_WIDGET")))

    (define-flags TextSearchFlags
       (in-module "Gtk")
       (c-name "GtkTextSearchFlags")
       (gtype-id "GTK_TYPE_TEXT_SEARCH_FLAGS")
       (values
        '("visible-only" "GTK_TEXT_SEARCH_VISIBLE_ONLY")
        '("text-only" "GTK_TEXT_SEARCH_TEXT_ONLY")))

    (define-flags TreeModelFlags
       (in-module "Gtk")
       (c-name "GtkTreeModelFlags")
       (gtype-id "GTK_TYPE_TREE_MODEL_FLAGS")
       (values
        '("iters-persist" "GTK_TREE_MODEL_ITERS_PERSIST")
        '("list-only" "GTK_TREE_MODEL_LIST_ONLY")))

    (define-flags UIManagerItemType
       (in-module "Gtk")
       (c-name "GtkUIManagerItemType")
       (gtype-id "GTK_TYPE_UI_MANAGER_ITEM_TYPE")
       (values
        '("auto" "GTK_UI_MANAGER_AUTO")
        '("menubar" "GTK_UI_MANAGER_MENUBAR")
        '("menu" "GTK_UI_MANAGER_MENU")
        '("toolbar" "GTK_UI_MANAGER_TOOLBAR")
        '("placeholder" "GTK_UI_MANAGER_PLACEHOLDER")
        '("popup" "GTK_UI_MANAGER_POPUP")
        '("menuitem" "GTK_UI_MANAGER_MENUITEM")
        '("toolitem" "GTK_UI_MANAGER_TOOLITEM")
        '("separator" "GTK_UI_MANAGER_SEPARATOR")
        '("accelerator" "GTK_UI_MANAGER_ACCELERATOR")))

    (define-flags WidgetFlags
       (in-module "Gtk")
       (c-name "GtkWidgetFlags")
       (gtype-id "GTK_TYPE_WIDGET_FLAGS")
       (values
        '("toplevel" "GTK_TOPLEVEL")
        '("no-window" "GTK_NO_WINDOW")
        '("realized" "GTK_REALIZED")
        '("mapped" "GTK_MAPPED")
        '("visible" "GTK_VISIBLE")
        '("sensitive" "GTK_SENSITIVE")
        '("parent-sensitive" "GTK_PARENT_SENSITIVE")
        '("can-focus" "GTK_CAN_FOCUS")
        '("has-focus" "GTK_HAS_FOCUS")
        '("can-default" "GTK_CAN_DEFAULT")
        '("has-default" "GTK_HAS_DEFAULT")
        '("has-grab" "GTK_HAS_GRAB")
        '("rc-style" "GTK_RC_STYLE")
        '("composite-child" "GTK_COMPOSITE_CHILD")
        '("no-reparent" "GTK_NO_REPARENT")
        '("app-paintable" "GTK_APP_PAINTABLE")
        '("receives-default" "GTK_RECEIVES_DEFAULT")
        '("double-buffered" "GTK_DOUBLE_BUFFERED")
        '("no-show-all" "GTK_NO_SHOW_ALL")))
    ))
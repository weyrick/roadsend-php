(module gtk-enums-lib
;   (include "../../php-runtime.sch")
   (load (php-macros "../../../php-macros.scm"))
   (load (php-gtk-macros "php-gtk-macros.sch"))
   (extern (include "gtk/gtk.h"))
   (library php-runtime)
;   (library "common")
   (export
    (init-gtk-enums-lib)
    ;;;;; GTK enums/flags ;;;;;
    ;; GtkAccelFlags
;    ;(translate-GtkAccelFlags x)
;     GTK_ACCEL_VISIBLE
;     GTK_ACCEL_SIGNAL_VISIBLE
;     GTK_ACCEL_LOCKED
;     GTK_ACCEL_MASK
;     ;; GtkAnchorType
;     ;(translate-GtkAnchorType x)
;     GTK_ANCHOR_CENTER
;     GTK_ANCHOR_NORTH
;     GTK_ANCHOR_NORTH_WEST
;     GTK_ANCHOR_NORTH_EAST
;     GTK_ANCHOR_SOUTH
;     GTK_ANCHOR_SOUTH_WEST
;     GTK_ANCHOR_SOUTH_EAST
;     GTK_ANCHOR_WEST
;     GTK_ANCHOR_EAST
;     GTK_ANCHOR_N
;     GTK_ANCHOR_NW
;     GTK_ANCHOR_NE
;     GTK_ANCHOR_S
;     GTK_ANCHOR_SW
;     GTK_ANCHOR_SE
;     GTK_ANCHOR_W
;     GTK_ANCHOR_E
;     ;; GtkArrowType
;     ;(translate-GtkArrowType x)
;     GTK_ARROW_UP
;     GTK_ARROW_DOWN
;     GTK_ARROW_LEFT
;     GTK_ARROW_RIGHT
;     ;; GtkAttachOptions
; ;    ;(translate-GtkAttachOptions x)
;     GTK_EXPAND
;     GTK_SHRINK
;     GTK_FILL
;     ;; GtkButtonAction
;     ;(translate-GtkButtonAction x)
;     GTK_BUTTON_IGNORED
;     GTK_BUTTON_SELECTS
;     GTK_BUTTON_DRAGS
;     GTK_BUTTON_EXPANDS
;     ;; GtkButtonBoxStyle
;     ;(translate-GtkButtonBoxStyle x)
;     GTK_BUTTONBOX_DEFAULT_STYLE
;     GTK_BUTTONBOX_SPREAD
;     GTK_BUTTONBOX_EDGE
;     GTK_BUTTONBOX_START
;     GTK_BUTTONBOX_END
;     ;; GtkCalendarDisplayOptions
; ;    ;(translate-GtkCalendarDisplayOptions x)
;     GTK_CALENDAR_SHOW_HEADING
;     GTK_CALENDAR_SHOW_DAY_NAMES
;     GTK_CALENDAR_NO_MONTH_CHANGE
;     GTK_CALENDAR_SHOW_WEEK_NUMBERS
;     GTK_CALENDAR_WEEK_START_MONDAY
;     ;; GtkCellType
;     ;(translate-GtkCellType x)
;     GTK_CELL_EMPTY
;     GTK_CELL_TEXT
;     GTK_CELL_PIXMAP
;     GTK_CELL_PIXTEXT
;     GTK_CELL_WIDGET
;     ;; GtkCornerType
;     ;(translate-GtkCornerType x)
;     GTK_CORNER_TOP_LEFT
;     GTK_CORNER_BOTTOM_LEFT
;     GTK_CORNER_TOP_RIGHT
;     GTK_CORNER_BOTTOM_RIGHT
;     ;; GtkCTreeExpanderStyle
;     ;(translate-GtkCTreeExpanderStyle x)
;     GTK_CTREE_EXPANDER_NONE
;     GTK_CTREE_EXPANDER_SQUARE
;     GTK_CTREE_EXPANDER_TRIANGLE
;     GTK_CTREE_EXPANDER_CIRCULAR
;     ;; GtkCTreeExpansionType
;     ;(translate-GtkCTreeExpansionType x)
;     GTK_CTREE_EXPANSION_EXPAND
;     GTK_CTREE_EXPANSION_EXPAND_RECURSIVE
;     GTK_CTREE_EXPANSION_COLLAPSE
;     GTK_CTREE_EXPANSION_COLLAPSE_RECURSIVE
;     GTK_CTREE_EXPANSION_TOGGLE
;     GTK_CTREE_EXPANSION_TOGGLE_RECURSIVE
;     ;; GtkCTreeLineStyle
;     ;(translate-GtkCTreeLineStyle x)
;     GTK_CTREE_LINES_NONE
;     GTK_CTREE_LINES_SOLID
;     GTK_CTREE_LINES_DOTTED
;     GTK_CTREE_LINES_TABBED
;     ;; GtkCurveType
;     ;(translate-GtkCurveType x)
;     GTK_CURVE_TYPE_LINEAR
;     GTK_CURVE_TYPE_SPLINE
;     GTK_CURVE_TYPE_FREE
;     ;; GtkDestDefaults
;     ;(translate-GtkDestDefaults x)
;     GTK_DEST_DEFAULT_MOTION
;     GTK_DEST_DEFAULT_HIGHLIGHT
;     GTK_DEST_DEFAULT_DROP
;     GTK_DEST_DEFAULT_ALL
;     ;; GtkDirectionType
;     ;(translate-GtkDirectionType x)
;     GTK_DIR_TAB_FORWARD
;     GTK_DIR_TAB_BACKWARD
;     GTK_DIR_UP
;     GTK_DIR_DOWN
;     GTK_DIR_LEFT
;     GTK_DIR_RIGHT
;     ;; GtkFontFilterType
;     ;(translate-GtkFontFilterType x)
;     GTK_FONT_FILTER_BASE
;     GTK_FONT_FILTER_USER
;     ;; GtkFontType
;     ;(translate-GtkFontType x)
;     GTK_FONT_BITMAP
;     GTK_FONT_SCALABLE
;     GTK_FONT_SCALABLE_BITMAP
;     GTK_FONT_ALL
;     ;; GtkJustification
;     ;(translate-GtkJustification x)
;     GTK_JUSTIFY_LEFT
;     GTK_JUSTIFY_RIGHT
;     GTK_JUSTIFY_CENTER
;     GTK_JUSTIFY_FILL
;     ;; GtkObjectFlags
; ;    ;(translate-GtkObjectFlags x)
;     GTK_DESTROYED
;     GTK_FLOATING
;     GTK_CONNECTED
;     GTK_CONSTRUCTED
;     ;; GtkOrientation
;     ;(translate-GtkOrientation x)
;     GTK_ORIENTATION_HORIZONTAL
;     GTK_ORIENTATION_VERTICAL
;     ;; GtkPackerOptions
;     ;(translate-GtkPackerOptions x)
;     GTK_PACK_EXPAND
;     GTK_FILL_X
;     GTK_FILL_Y
;     ;; GtkPackType
;     ;(translate-GtkPackType x)
;     GTK_PACK_START
;     GTK_PACK_END
;     ;; GtkPolicyType
;     ;(translate-GtkPolicyType x)
;     GTK_POLICY_ALWAYS
;     GTK_POLICY_AUTOMATIC
;     GTK_POLICY_NEVER
;     ;; GtkPositionType
;     ;(translate-GtkPositionType x)
;     GTK_POS_LEFT
;     GTK_POS_RIGHT
;     GTK_POS_TOP
;     GTK_POS_BOTTOM
;     ;; GtkPreviewType
;     ;(translate-GtkPreviewType x)
;     GTK_PREVIEW_COLOR
;     GTK_PREVIEW_GRAYSCALE
;     ;; GtkProgressBarOrientation
;     ;(translate-GtkProgressBarOrientation x)
;     GTK_PROGRESS_LEFT_TO_RIGHT
;     GTK_PROGRESS_RIGHT_TO_LEFT
;     GTK_PROGRESS_BOTTOM_TO_TOP
;     GTK_PROGRESS_TOP_TO_BOTTOM
;     ;; GtkProgressBarStyle
;     ;(translate-GtkProgressBarStyle x)
;     GTK_PROGRESS_CONTINUOUS
;     GTK_PROGRESS_DISCRETE
;     ;; GtkReliefStyle
;     ;(translate-GtkReliefStyle x)
;     GTK_RELIEF_NORMAL
;     GTK_RELIEF_HALF
;     GTK_RELIEF_NONE
;     ;; GtkResizeMode
;     ;(translate-GtkResizeMode x)
;     GTK_RESIZE_PARENT
;     GTK_RESIZE_QUEUE
;     GTK_RESIZE_IMMEDIATE
;     ;; GtkScrollType
;     ;(translate-GtkScrollType x)
;     GTK_SCROLL_NONE
;     GTK_SCROLL_STEP_BACKWARD
;     GTK_SCROLL_STEP_FORWARD
;     GTK_SCROLL_PAGE_BACKWARD
;     GTK_SCROLL_PAGE_FORWARD
;     GTK_SCROLL_JUMP
;     ;; GtkSelectionMode
;     ;(translate-GtkSelectionMode x)
;     GTK_SELECTION_SINGLE
;     GTK_SELECTION_BROWSE
;     GTK_SELECTION_MULTIPLE
;     GTK_SELECTION_EXTENDED
;     ;; GtkShadowType
;     ;(translate-GtkShadowType x)
;     GTK_SHADOW_NONE
;     GTK_SHADOW_IN
;     GTK_SHADOW_OUT
;     GTK_SHADOW_ETCHED_IN
;     GTK_SHADOW_ETCHED_OUT
;     ;; GtkSideType
;     ;(translate-GtkSideType x)
;     GTK_SIDE_TOP
;     GTK_SIDE_BOTTOM
;     GTK_SIDE_LEFT
;     GTK_SIDE_RIGHT
;     ;; GtkSortType
;     ;(translate-GtkSortType x)
;     GTK_SORT_ASCENDING
;     GTK_SORT_DESCENDING
;     ;; GtkSpinButtonUpdatePolicy
;     ;(translate-GtkSpinButtonUpdatePolicy x)
;     GTK_UPDATE_ALWAYS
;     GTK_UPDATE_IF_VALID
;     ;; GtkSpinType
;     ;(translate-GtkSpinType x)
;     GTK_SPIN_STEP_FORWARD
;     GTK_SPIN_STEP_BACKWARD
;     GTK_SPIN_PAGE_FORWARD
;     GTK_SPIN_PAGE_BACKWARD
;     GTK_SPIN_HOME
;     GTK_SPIN_END
;     GTK_SPIN_USER_DEFINED
;     ;; GtkStateType
;     ;(translate-GtkStateType x)
;     GTK_STATE_NORMAL
;     GTK_STATE_ACTIVE
;     GTK_STATE_PRELIGHT
;     GTK_STATE_SELECTED
;     GTK_STATE_INSENSITIVE
;     ;; GtkSubmenuPlacement
;     ;(translate-GtkSubmenuPlacement x)
;     GTK_TOP_BOTTOM
;     GTK_LEFT_RIGHT
;     ;; GtkToolbarChildType
;     ;(translate-GtkToolbarChildType x)
;     GTK_TOOLBAR_CHILD_SPACE
;     GTK_TOOLBAR_CHILD_BUTTON
;     GTK_TOOLBAR_CHILD_TOGGLEBUTTON
;     GTK_TOOLBAR_CHILD_RADIOBUTTON
;     GTK_TOOLBAR_CHILD_WIDGET
;     ;; GtkToolbarSpaceStyle
;     ;(translate-GtkToolbarSpaceStyle x)
;     GTK_TOOLBAR_SPACE_EMPTY
;     GTK_TOOLBAR_SPACE_LINE
;     ;; GtkToolbarStyle
;     ;(translate-GtkToolbarStyle x)
;     GTK_TOOLBAR_ICONS
;     GTK_TOOLBAR_TEXT
;     GTK_TOOLBAR_BOTH
;     ;; GtkTreeViewMode
;     ;(translate-GtkTreeViewMode x)
;     GTK_TREE_VIEW_LINE
;     GTK_TREE_VIEW_ITEM
;     ;; GtkUpdateType
;     ;(translate-GtkUpdateType x)
;     GTK_UPDATE_CONTINUOUS
;     GTK_UPDATE_DISCONTINUOUS
;     GTK_UPDATE_DELAYED
;     ;; GtkVisibility
;     ;(translate-GtkVisibility x)
;     GTK_VISIBILITY_NONE
;     GTK_VISIBILITY_PARTIAL
;     GTK_VISIBILITY_FULL
;     ;; GtkWidgetFlags
; ;    ;(translate-GtkWidgetFlags x)
;     GTK_TOPLEVEL
;     GTK_NO_WINDOW
;     GTK_REALIZED
;     GTK_MAPPED
;     GTK_VISIBLE
;     GTK_SENSITIVE
;     GTK_PARENT_SENSITIVE
;     GTK_CAN_FOCUS
;     GTK_HAS_FOCUS
;     GTK_CAN_DEFAULT
;     GTK_HAS_DEFAULT
;     GTK_HAS_GRAB
;     GTK_RC_STYLE
;     GTK_COMPOSITE_CHILD
;     GTK_NO_REPARENT
;     GTK_APP_PAINTABLE
;     GTK_RECEIVES_DEFAULT
;     ;; GtkWindowPosition
;     ;(translate-GtkWindowPosition x)
;     GTK_WIN_POS_NONE
;     GTK_WIN_POS_CENTER
;     GTK_WIN_POS_MOUSE
;     GTK_WIN_POS_CENTER_ALWAYS
;     ;; GtkWindowType
;     ;(translate-GtkWindowType x)
;     GTK_WINDOW_TOPLEVEL
;     GTK_WINDOW_DIALOG
;     GTK_WINDOW_POPUP
    ))

;;;
;;; Module Init
;;; ===========

(define (init-gtk-enums-lib)
   1)

;;;
;;; Gtk Enums and Flags
;;; ===================

(defflags GtkAccelFlags
   (visible GTK_ACCEL_VISIBLE)
   (signal-visible GTK_ACCEL_SIGNAL_VISIBLE)
   (locked GTK_ACCEL_LOCKED)
   ;; XXX GTK_ACCEL_MASK not implemented in bigloo-lib
   (mask GTK_ACCEL_MASK))

;; XXX GtkAnchorType not implemented at all in bigloo-lib
(defenum GtkAnchorType
   (center GTK_ANCHOR_CENTER)
   (north GTK_ANCHOR_NORTH)
   (north-west GTK_ANCHOR_NORTH_WEST)
   (north-east GTK_ANCHOR_NORTH_EAST)
   (south GTK_ANCHOR_SOUTH)
   (south-west GTK_ANCHOR_SOUTH_WEST)
   (south-east GTK_ANCHOR_SOUTH_EAST)
   (west GTK_ANCHOR_WEST)
   (east GTK_ANCHOR_EAST)
   (n GTK_ANCHOR_N)
   (nw GTK_ANCHOR_NW)
   (ne GTK_ANCHOR_NE)
   (s GTK_ANCHOR_S)
   (sw GTK_ANCHOR_SW)
   (se GTK_ANCHOR_SE)
   (w GTK_ANCHOR_W)
   (e GTK_ANCHOR_E))

(defenum GtkArrowType
   (up GTK_ARROW_UP)
   (down GTK_ARROW_DOWN)
   (left GTK_ARROW_LEFT)
   (right GTK_ARROW_RIGHT))

(defflags GtkAttachOptions
   (expand GTK_EXPAND)
   (shrink GTK_SHRINK)
   (fill GTK_FILL))

;; XXX GtkButtonAction not implemented by bigloo-lib at all
(defenum GtkButtonAction
   (ignored GTK_BUTTON_IGNORED)
   (selects GTK_BUTTON_SELECTS)
   (drags GTK_BUTTON_DRAGS)
   (expands GTK_BUTTON_EXPANDS))

(defenum GtkButtonBoxStyle
   (default-style GTK_BUTTONBOX_DEFAULT_STYLE)
   (spread GTK_BUTTONBOX_SPREAD)
   (edge GTK_BUTTONBOX_EDGE)
   (start GTK_BUTTONBOX_START)
   (end GTK_BUTTONBOX_END))

;; XXX GtkCalendarDisplayOptions not implemented by bigloo-lib at all
(defflags GtkCalendarDisplayOptions
   (show-heading GTK_CALENDAR_SHOW_HEADING)
   (show-day-names GTK_CALENDAR_SHOW_DAY_NAMES)
   (no-month-change GTK_CALENDAR_NO_MONTH_CHANGE)
   (show-week-numbers GTK_CALENDAR_SHOW_WEEK_NUMBERS)
   (week-start-monday GTK_CALENDAR_WEEK_START_MONDAY))

(defenum GtkCellType
   (empty GTK_CELL_EMPTY)
   (text GTK_CELL_TEXT)
   (pixmap GTK_CELL_PIXMAP)
   (pixtext GTK_CELL_PIXTEXT)
   (widget GTK_CELL_WIDGET))

;; XXX GtkCornerType not implemented by bigloo-lib at all
(defenum GtkCornerType
   (top-left GTK_CORNER_TOP_LEFT)
   (bottom-left GTK_CORNER_BOTTOM_LEFT)
   (top-right GTK_CORNER_TOP_RIGHT)
   (bottom-right GTK_CORNER_BOTTOM_RIGHT))

(defenum GtkCTreeExpanderStyle
   (none GTK_CTREE_EXPANDER_NONE)
   (square GTK_CTREE_EXPANDER_SQUARE)
   (triangle GTK_CTREE_EXPANDER_TRIANGLE)
   (circular GTK_CTREE_EXPANDER_CIRCULAR))

;; XXX GtkCTreeExpansionType not implemented by bigloo at all
(defenum GtkCTreeExpansionType
   (expand GTK_CTREE_EXPANSION_EXPAND)
   (expand-recursive GTK_CTREE_EXPANSION_EXPAND_RECURSIVE)
   (collapse GTK_CTREE_EXPANSION_COLLAPSE)
   (recursive GTK_CTREE_EXPANSION_COLLAPSE_RECURSIVE)
   (toggle GTK_CTREE_EXPANSION_TOGGLE)
   (toggle-recursive GTK_CTREE_EXPANSION_TOGGLE_RECURSIVE))

(defenum GtkCTreeLineStyle
   (none GTK_CTREE_LINES_NONE)
   (solid GTK_CTREE_LINES_SOLID)
   (dotted GTK_CTREE_LINES_DOTTED)
   (tabbed GTK_CTREE_LINES_TABBED))

(defenum GtkCurveType
   (linear GTK_CURVE_TYPE_LINEAR)
   (spline GTK_CURVE_TYPE_SPLINE)
   (free GTK_CURVE_TYPE_FREE))

(defenum GtkDestDefaults
   (motion GTK_DEST_DEFAULT_MOTION)
   (highlight GTK_DEST_DEFAULT_HIGHLIGHT)
   (drop GTK_DEST_DEFAULT_DROP)
   (all GTK_DEST_DEFAULT_ALL))

(defenum GtkDirectionType
   (tab-forward GTK_DIR_TAB_FORWARD)
   (tab-backward GTK_DIR_TAB_BACKWARD)
   (up GTK_DIR_UP)
   (down GTK_DIR_DOWN)
   (left GTK_DIR_LEFT)
   (right GTK_DIR_RIGHT))

;; XXX GtkFontFilterType not implemented by bigloo-lib at all
(defenum GtkFontFilterType
   (base GTK_FONT_FILTER_BASE)
   (user GTK_FONT_FILTER_USER))

;; XXX GtkFontType not implemented by bigloo-lib at all
(defenum GtkFontType
   (bitmap GTK_FONT_BITMAP)
   (scalable GTK_FONT_SCALABLE)
   (scalable-bitmap GTK_FONT_SCALABLE_BITMAP)
   (all GTK_FONT_ALL))

(defenum GtkJustification
   (left GTK_JUSTIFY_LEFT)
   (right GTK_JUSTIFY_RIGHT)
   (center GTK_JUSTIFY_CENTER)
   (fill GTK_JUSTIFY_FILL))

;; XXX GtkObjectFlags not implemented by bigloo-lib at all
(defflags GtkObjectFlags
   (destroyed GTK_DESTROYED)
   (floating GTK_FLOATING)
   (connected GTK_CONNECTED)
   (constructed GTK_CONSTRUCTED))

(defenum GtkOrientation
   (horizontal GTK_ORIENTATION_HORIZONTAL)
   (vertical GTK_ORIENTATION_VERTICAL))

;; XXX GtkPackerOptions not implemented by bigloo-lib at all
(defenum GtkPackerOptions
   (pack-expand GTK_PACK_EXPAND)
   (fill-x GTK_FILL_X)
   (Fill-y GTK_FILL_Y))

(defenum GtkPackType
   (start GTK_PACK_START)
   (end GTK_PACK_END))

(defenum GtkPolicyType
   (always GTK_POLICY_ALWAYS)
   (automatic GTK_POLICY_AUTOMATIC)
   (never GTK_POLICY_NEVER))

(defenum GtkPositionType
   (left GTK_POS_LEFT)
   (right GTK_POS_RIGHT)
   (top GTK_POS_TOP)
   (bottom GTK_POS_BOTTOM))

(defenum GtkPreviewType
   (color GTK_PREVIEW_COLOR)
   (grayscale GTK_PREVIEW_GRAYSCALE))

;; XXX GtkProgressBarOrientation not implemented by bigloo-lib at all
(defenum GtkProgressBarOrientation
   (left-to-right GTK_PROGRESS_LEFT_TO_RIGHT)
   (right-to-left GTK_PROGRESS_RIGHT_TO_LEFT)
   (bottom-to-top GTK_PROGRESS_BOTTOM_TO_TOP)
   (top-to-bottom GTK_PROGRESS_TOP_TO_BOTTOM))

;; XXX GtkProgressBarStyle not implemented by bigloo-lib at all
(defenum GtkProgressBarStyle
   (continuous GTK_PROGRESS_CONTINUOUS)
   (discrete GTK_PROGRESS_DISCRETE))

(defenum GtkReliefStyle
   (normal GTK_RELIEF_NORMAL)
   (half GTK_RELIEF_HALF)
   (none GTK_RELIEF_NONE))

;; XXX GtkResizeMode not implemented by bigloo-lib at all
(defenum GtkResizeMode
   (parent GTK_RESIZE_PARENT)
   (queue GTK_RESIZE_QUEUE)
   (immediate GTK_RESIZE_IMMEDIATE))

(defenum GtkScrollType
   (none GTK_SCROLL_NONE)
   (step-backward GTK_SCROLL_STEP_BACKWARD)
   (step-forward GTK_SCROLL_STEP_FORWARD)
   (page-backward GTK_SCROLL_PAGE_BACKWARD)
   (page-forward GTK_SCROLL_PAGE_FORWARD)
   ;; XXX GTK_SCROLL_JUMP not implemented by bigloo-lib
   (jump GTK_SCROLL_JUMP))

(defenum GtkSelectionMode
   (single GTK_SELECTION_SINGLE)
   (browse GTK_SELECTION_BROWSE)
   (multiple GTK_SELECTION_MULTIPLE)
   (extended GTK_SELECTION_EXTENDED))

(defenum GtkShadowType
   (none GTK_SHADOW_NONE)
   (in GTK_SHADOW_IN)
   (out GTK_SHADOW_OUT)
   (etched-in GTK_SHADOW_ETCHED_IN)
   (etched-out GTK_SHADOW_ETCHED_OUT))

;; XXX GtkSideType not implemented by bigloo-lib at all
(defenum GtkSideType
   (top GTK_SIDE_TOP)
   (bottom GTK_SIDE_BOTTOM)
   (left GTK_SIDE_LEFT)
   (right GTK_SIDE_RIGHT))

(defenum GtkSortType
   (ascending GTK_SORT_ASCENDING)
   (descending GTK_SORT_DESCENDING))

(defenum GtkSpinButtonUpdatePolicy
   (always GTK_UPDATE_ALWAYS)
   (if-valid GTK_UPDATE_IF_VALID))

(defenum GtkSpinType
   (step-forward GTK_SPIN_STEP_FORWARD)
   (step-backward GTK_SPIN_STEP_BACKWARD)
   (page-forward GTK_SPIN_PAGE_FORWARD)
   (page-backward GTK_SPIN_PAGE_BACKWARD)
   (home GTK_SPIN_HOME)
   (end GTK_SPIN_END)
   (user-defined GTK_SPIN_USER_DEFINED))

(defenum GtkStateType
   (normal GTK_STATE_NORMAL)
   (active GTK_STATE_ACTIVE)
   (prelight GTK_STATE_PRELIGHT)
   (selected GTK_STATE_SELECTED)
   (insensitive GTK_STATE_INSENSITIVE))

(defenum GtkSubmenuPlacement
   (top-bottom GTK_TOP_BOTTOM)
   (left-right GTK_LEFT_RIGHT))

(defenum GtkToolbarChildType
   (space GTK_TOOLBAR_CHILD_SPACE)
   (button GTK_TOOLBAR_CHILD_BUTTON)
   (toggle-button GTK_TOOLBAR_CHILD_TOGGLEBUTTON)
   (radio-button GTK_TOOLBAR_CHILD_RADIOBUTTON)
   (widget GTK_TOOLBAR_CHILD_WIDGET))

(defenum GtkToolbarSpaceStyle
   (empty GTK_TOOLBAR_SPACE_EMPTY)
   (line GTK_TOOLBAR_SPACE_LINE))

(defenum GtkToolbarStyle
   (icons GTK_TOOLBAR_ICONS)
   (text GTK_TOOLBAR_TEXT)
   (both GTK_TOOLBAR_BOTH))

(defenum GtkTreeViewMode
   (line GTK_TREE_VIEW_LINE)
   (item GTK_TREE_VIEW_ITEM))

(defenum GtkUpdateType
   (continuous GTK_UPDATE_CONTINUOUS)
   (discontinuous GTK_UPDATE_DISCONTINUOUS)
   (delayed GTK_UPDATE_DELAYED))

(defenum GtkVisibility
   (none GTK_VISIBILITY_NONE)
   (partial GTK_VISIBILITY_PARTIAL)
   (full GTK_VISIBILITY_FULL))

(defflags GtkWidgetFlags
   (toplevel GTK_TOPLEVEL)
   (no-window GTK_NO_WINDOW)
   (realized GTK_REALIZED)
   (mapped GTK_MAPPED)
   (visible GTK_VISIBLE)
   (sensitive GTK_SENSITIVE)
   (parent-sensitive GTK_PARENT_SENSITIVE)
   (can-focus GTK_CAN_FOCUS)
   (has-focus GTK_HAS_FOCUS)
   (can-default GTK_CAN_DEFAULT)
   (has-default GTK_HAS_DEFAULT)
   (has-grab GTK_HAS_GRAB)
   (rc-style GTK_RC_STYLE)
   (composite-child GTK_COMPOSITE_CHILD)
   (no-reparent GTK_NO_REPARENT)
   (app-paintable GTK_APP_PAINTABLE)
   (receives-default GTK_RECEIVES_DEFAULT))

(defenum GtkWindowPosition
   (none GTK_WIN_POS_NONE)
   (center GTK_WIN_POS_CENTER)
   (mouse GTK_WIN_POS_MOUSE)
   ;; XXX GTK_WIN_POS_CENTER_ALWAYS not implemented by bigloo-lib
   (center-always GTK_WIN_POS_CENTER_ALWAYS))

(defenum GtkWindowType
   (toplevel GTK_WINDOW_TOPLEVEL)
   (dialog GTK_WINDOW_DIALOG)
   (popup GTK_WINDOW_POPUP))


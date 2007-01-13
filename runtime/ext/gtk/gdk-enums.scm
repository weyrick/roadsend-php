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
(module gdk-enums-lib
   (load (php-macros "../../../php-macros.scm"))
   (load (php-gtk-macros "php-gtk-macros.sch"))
   (extern (include "gtk/gtk.h"))
;   (include "../phpoo-extension.sch")
;   (include "php-gtk-macros.sch")
   (library php-runtime)
;   (library "common")
   (export
    (init-gdk-enums-lib)
    ;;;;; GDK enums/flags ;;;;;
    ;; GdkCapStyle
    ;(translate-GdkCapStyle x)
;     GDK_CAP_NOT_LAST
;     GDK_CAP_BUTT
;     GDK_CAP_ROUND
;     GDK_CAP_PROJECTING
;     ;; GdkCursorType
;     ;(translate-GdkCursorType x)
;     GDK_LAST_CURSOR
;     GDK_CURSOR_IS_PIXMAP
;     GDK_NUM_GLYPHS
;     GDK_X_CURSOR
;     GDK_ARROW
;     GDK_BASED_ARROW_DOWN
;     GDK_BASED_ARROW_UP
;     GDK_BOAT
;     GDK_BOGOSITY
;     GDK_BOTTOM_LEFT_CORNER
;     GDK_BOTTOM_RIGHT_CORNER
;     GDK_BOTTOM_SIDE
;     GDK_BOTTOM_TEE
;     GDK_BOX_SPIRAL
;     GDK_CENTER_PTR
;     GDK_CIRCLE
;     GDK_CLOCK
;     GDK_COFFEE_MUG
;     GDK_CROSS
;     GDK_CROSS_REVERSE
;     GDK_CROSSHAIR
;     GDK_DIAMOND_CROSS
;     GDK_DOT
;     GDK_DOTBOX
;     GDK_DOUBLE_ARROW
;     GDK_DRAFT_LARGE
;     GDK_DRAFT_SMALL
;     GDK_DRAPED_BOX
;     GDK_EXCHANGE
;     GDK_FLEUR
;     GDK_GOBBLER
;     GDK_GUMBY
;     GDK_HAND1
;     GDK_HAND2
;     GDK_HEART
;     GDK_ICON
;     GDK_IRON_CROSS
;     GDK_LEFT_PTR
;     GDK_LEFT_SIDE
;     GDK_LEFT_TEE
;     GDK_LEFTBUTTON
;     GDK_LL_ANGLE
;     GDK_LR_ANGLE
;     GDK_MAN
;     GDK_MIDDLEBUTTON
;     GDK_MOUSE
;     GDK_PENCIL
;     GDK_PIRATE
;     GDK_PLUS
;     GDK_QUESTION_ARROW
;     GDK_RIGHT_PTR
;     GDK_RIGHT_SIDE
;     GDK_RIGHT_TEE
;     GDK_RIGHTBUTTON
;     GDK_RTL_LOGO
;     GDK_SAILBOAT
;     GDK_SB_DOWN_ARROW
;     GDK_SB_H_DOUBLE_ARROW
;     GDK_SB_LEFT_ARROW
;     GDK_SB_RIGHT_ARROW
;     GDK_SB_UP_ARROW
;     GDK_SB_V_DOUBLE_ARROW
;     GDK_SHUTTLE
;     GDK_SIZING
;     GDK_SPIDER
;     GDK_SPRAYCAN
;     GDK_STAR
;     GDK_TARGET
;     GDK_TCROSS
;     GDK_TOP_LEFT_ARROW
;     GDK_TOP_LEFT_CORNER
;     GDK_TOP_RIGHT_CORNER
;     GDK_TOP_SIDE
;     GDK_TOP_TEE
;     GDK_TREK
;     GDK_UL_ANGLE
;     GDK_UMBRELLA
;     GDK_UR_ANGLE
;     GDK_WATCH
;     GDK_XTERM
;     ;; GdkDragAction
; ;    ;(translate-GdkDragAction x)
;     GDK_ACTION_DEFAULT
;     GDK_ACTION_COPY
;     GDK_ACTION_MOVE
;     GDK_ACTION_LINK
;     GDK_ACTION_PRIVATE
;     GDK_ACTION_ASK
;     ;; GdkEventMask
; ;    ;(translate-GdkEventMask x)
;     GDK_EXPOSURE_MASK
;     GDK_POINTER_MOTION_MASK
;     GDK_POINTER_MOTION_HINT_MASK
;     GDK_BUTTON_MOTION_MASK
;     GDK_BUTTON1_MOTION_MASK
;     GDK_BUTTON2_MOTION_MASK
;     GDK_BUTTON3_MOTION_MASK
;     GDK_BUTTON_PRESS_MASK
;     GDK_BUTTON_RELEASE_MASK
;     GDK_KEY_PRESS_MASK
;     GDK_KEY_RELEASE_MASK
;     GDK_ENTER_NOTIFY_MASK
;     GDK_LEAVE_NOTIFY_MASK
;     GDK_FOCUS_CHANGE_MASK
;     GDK_STRUCTURE_MASK
;     GDK_PROPERTY_CHANGE_MASK
;     GDK_VISIBILITY_NOTIFY_MASK
;     GDK_PROXIMITY_IN_MASK
;     GDK_PROXIMITY_OUT_MASK
;     GDK_SUBSTRUCTURE_MASK
;     GDK_ALL_EVENTS_MASK
;     ;; GdkEventType *** NOTE! starts from -1 according to php-gtk docs
;     ;(translate-GdkEventType x)
;     GDK_NOTHING
;     GDK_DELETE
;     GDK_DESTROY
;     GDK_EXPOSE
;     GDK_MOTION_NOTIFY
;     GDK_BUTTON_PRESS
;     GDK_2BUTTON_PRESS
;     GDK_3BUTTON_PRESS
;     GDK_BUTTON_RELEASE
;     GDK_KEY_PRESS
;     GDK_KEY_RELEASE
;     GDK_ENTER_NOTIFY
;     GDK_LEAVE_NOTIFY
;     GDK_FOCUS_CHANGE
;     GDK_CONFIGURE
;     GDK_MAP
;     GDK_UNMAP
;     GDK_PROPERTY_NOTIFY
;     GDK_SELECTION_CLEAR
;     GDK_SELECTION_REQUEST
;     GDK_SELECTION_NOTIFY
;     GDK_PROXIMITY_IN
;     GDK_PROXIMITY_OUT
;     GDK_DRAG_ENTER
;     GDK_DRAG_LEAVE
;     GDK_DRAG_MOTION
;     GDK_DRAG_STATUS
;     GDK_DROP_START
;     GDK_DROP_FINISHED
;     GDK_CLIENT_EVENT
;     GDK_VISIBILITY_NOTIFY
;     GDK_NO_EXPOSE
;     ;; GdkFill
;     ;(translate-GdkFill x)
;     GDK_SOLID
;     GDK_TILED
;     GDK_STIPPLED
;     GDK_OPAQUE_STIPPLED
;     ;; GdkFontType
;     ;(translate-GdkFontType x)
;     GDK_FONT_FONT
;     GDK_FONT_FONTSET
;     ;; GdkFunction
;     ;(translate-GdkFunction x)
;     GDK_COPY
;     GDK_INVERT
;     GDK_XOR
;     GDK_CLEAR
;     GDK_AND
;     GDK_AND_REVERSE
;     GDK_AND_INVERT
;     GDK_NOOP
;     GDK_OR
;     GDK_EQUIV
;     GDK_OR_REVERSE
;     GDK_COPY_INVERT
;     GDK_OR_INVERT
;     GDK_NAND
;     GDK_SET
;     ;; GdkInputCondition
; ;    ;(translate-GdkInputCondition x)
;     GDK_INPUT_READ
;     GDK_INPUT_WRITE
;     GDK_INPUT_EXCEPTION
;     ;; GdkJoinStyle
;     ;(translate-GdkJoinStyle x)
;     GDK_JOIN_MITER
;     GDK_JOIN_ROUND
;     GDK_JOIN_BEVEL
;     ;; GdkLineStyle
;     ;(translate-GdkLineStyle x)
;     GDK_LINE_SOLID
;     GDK_LINE_ON_OFF_DASH
;     GDK_LINE_DOUBLE_DASH
;     ;; GdkModifierType
; ;    ;(translate-GdkModifierType x)
;     GDK_SHIFT_MASK
;     GDK_LOCK_MASK
;     GDK_CONTROL_MASK
;     GDK_MOD1_MASK
;     GDK_MOD2_MASK
;     GDK_MOD3_MASK
;     GDK_MOD4_MASK
;     GDK_MOD5_MASK
;     GDK_BUTTON1_MASK
;     GDK_BUTTON2_MASK
;     GDK_BUTTON3_MASK
;     GDK_BUTTON4_MASK
;     GDK_BUTTON5_MASK
;     GDK_RELEASE_MASK
;     GDK_MODIFIER_MASK
;     ;; GdkRgbDither
;     ;(translate-GdkRgbDither x)
;     GDK_RGB_DITHER_NONE
;     GDK_RGB_DITHER_NORMAL
;     GDK_RGB_DITHER_MAX
;     ;; GdkSubwindowMode
;     ;(translate-GdkSubwindowMode x)
;     GDK_CLIP_BY_CHILDREN
;     GDK_INCLUDE_INFERIORS
;     ;; GdkVisualType
;     ;(translate-GdkVisualType x)
;     GDK_VISUAL_STATIC_GRAY
;     GDK_VISUAL_GRAYSCALE
;     GDK_VISUAL_STATIC_COLOR
;     GDK_VISUAL_PSEUDO_COLOR
;     GDK_VISUAL_TRUE_COLOR
;     GDK_VISUAL_DIRECT_COLOR
    ))

;;;
;;; Module Init
;;; ===========

(define (init-gdk-enums-lib)
   1)

;;;
;;; Gdk Enums and Flags
;;; ===================

(defenum GdkCapStyle
   (not-last GDK_CAP_NOT_LAST)
   (butt GDK_CAP_BUTT)
   (round GDK_CAP_ROUND)
   (projecting GDK_CAP_PROJECTING))


;; NOTE: php-gtk only define GDK_CURSOR_IS_PIXMAP for some reason, but I'm implementing
;; all the rest anyway because they're in bigloo-lib's binding already
(defenum GdkCursorType
   (last-cursor GDK_LAST_CURSOR)
   (cursor-is-pixmap GDK_CURSOR_IS_PIXMAP)
   (num-glyphs GDK_NUM_GLYPHS)
   (x-cursor GDK_X_CURSOR)
   (arrow GDK_ARROW)
   (based-arrow-down GDK_BASED_ARROW_DOWN)
   (based-arrow-up GDK_BASED_ARROW_UP)
   (boat GDK_BOAT)
   (bogosity GDK_BOGOSITY)
   (bottom-left-corner GDK_BOTTOM_LEFT_CORNER)
   (bottom-right-corner GDK_BOTTOM_RIGHT_CORNER)
   (bottom-side GDK_BOTTOM_SIDE)
   (bottom-tee GDK_BOTTOM_TEE)
   (box-spiral GDK_BOX_SPIRAL)
   (center-ptr GDK_CENTER_PTR)
   (circle GDK_CIRCLE)
   (clock GDK_CLOCK)
   (coffee-mug GDK_COFFEE_MUG)
   (cross GDK_CROSS)
   (cross-reverse GDK_CROSS_REVERSE)
   (crosshair GDK_CROSSHAIR)
   (diamond-cross GDK_DIAMOND_CROSS)
   (dot GDK_DOT)
   (dotbox GDK_DOTBOX)
   (double-arrow GDK_DOUBLE_ARROW)
   (draft-large GDK_DRAFT_LARGE)
   (draft-small GDK_DRAFT_SMALL)
   (draped-box GDK_DRAPED_BOX)
   (exchange GDK_EXCHANGE)
   (fleur GDK_FLEUR)
   (gobbler GDK_GOBBLER)
   (gumby GDK_GUMBY)
   (hand1 GDK_HAND1)
   (hand2 GDK_HAND2)
   (heart GDK_HEART)
   (icon GDK_ICON)
   (iron-cross GDK_IRON_CROSS)
   (left-ptr GDK_LEFT_PTR)
   (left-side GDK_LEFT_SIDE)
   (left-tee GDK_LEFT_TEE)
   (leftbutton GDK_LEFTBUTTON)
   (ll-angle GDK_LL_ANGLE)
   (lr-angle GDK_LR_ANGLE)
   (man GDK_MAN)
   (middlebutton GDK_MIDDLEBUTTON)
   (mouse GDK_MOUSE)
   (pencil GDK_PENCIL)
   (pirate GDK_PIRATE)
   (plus GDK_PLUS)
   (question-arrow GDK_QUESTION_ARROW)
   (right-ptr GDK_RIGHT_PTR)
   (right-side GDK_RIGHT_SIDE)
   (right-tee GDK_RIGHT_TEE)
   (rightbutton GDK_RIGHTBUTTON)
   (rtl-logo GDK_RTL_LOGO)
   (sailboat GDK_SAILBOAT)
   (sb-down-arrow GDK_SB_DOWN_ARROW)
   (sb-h-double-arrow GDK_SB_H_DOUBLE_ARROW)
   (sb-left-arrow GDK_SB_LEFT_ARROW)
   (sb-right-arrow GDK_SB_RIGHT_ARROW)
   (sb-up-arrow GDK_SB_UP_ARROW)
   (sb-v-double-arrow GDK_SB_V_DOUBLE_ARROW)
   (shuttle GDK_SHUTTLE)
   (sizing GDK_SIZING)
   (spider GDK_SPIDER)
   (spraycan GDK_SPRAYCAN)
   (star GDK_STAR)
   (target GDK_TARGET)
   (tcross GDK_TCROSS)
   (top-left-arrow GDK_TOP_LEFT_ARROW)
   (top-left-corner GDK_TOP_LEFT_CORNER)
   (top-right-corner GDK_TOP_RIGHT_CORNER)
   (top-side GDK_TOP_SIDE)
   (top-tee GDK_TOP_TEE)
   (trek GDK_TREK)
   (ul-angle GDK_UL_ANGLE)
   (umbrella GDK_UMBRELLA)
   (ur-angle GDK_UR_ANGLE)
   (watch GDK_WATCH)
   (xterm GDK_XTERM))

(defflags GdkDragAction
   (default GDK_ACTION_DEFAULT)
   (copy GDK_ACTION_COPY)
   (move GDK_ACTION_MOVE)
   (link GDK_ACTION_LINK)
   (private GDK_ACTION_PRIVATE)
   (ask GDK_ACTION_ASK))

(defflags GdkEventMask
  (exposure GDK_EXPOSURE_MASK)
  (pointer-motion GDK_POINTER_MOTION_MASK)
  (pointer-motion-hint GDK_POINTER_MOTION_HINT_MASK)
  (button-motion GDK_BUTTON_MOTION_MASK)
  (button1-motion GDK_BUTTON1_MOTION_MASK)
  (button2-motion GDK_BUTTON2_MOTION_MASK)
  (button3-motion GDK_BUTTON3_MOTION_MASK)
  (button-press GDK_BUTTON_PRESS_MASK)
  (button-release GDK_BUTTON_RELEASE_MASK)
  (key-press GDK_KEY_PRESS_MASK)
  (key-release GDK_KEY_RELEASE_MASK)
  (enter-notify GDK_ENTER_NOTIFY_MASK)
  (leave-notify GDK_LEAVE_NOTIFY_MASK)
  (focus-change GDK_FOCUS_CHANGE_MASK)
  (structure GDK_STRUCTURE_MASK)
  (property-change GDK_PROPERTY_CHANGE_MASK)
  (visibility-notify GDK_VISIBILITY_NOTIFY_MASK)
  (proximity-in GDK_PROXIMITY_IN_MASK)
  (proximity-out GDK_PROXIMITY_OUT_MASK)
  (substructure GDK_SUBSTRUCTURE_MASK)
  (all-events GDK_ALL_EVENTS_MASK))

;; *** NOTE! starts from -1 according to php-gtk docs
(defenum GdkEventType
   (nothing GDK_NOTHING)
   (delete GDK_DELETE)
   (destroy GDK_DESTROY)
   (expose GDK_EXPOSE)
   (motion-notify GDK_MOTION_NOTIFY)
   (button-press GDK_BUTTON_PRESS)
   (2button-press GDK_2BUTTON_PRESS)
   (3button-press GDK_3BUTTON_PRESS)
   (button-release GDK_BUTTON_RELEASE)
   (key-press GDK_KEY_PRESS)
   (key-release GDK_KEY_RELEASE)
   (enter-notify GDK_ENTER_NOTIFY)
   (leave-notify GDK_LEAVE_NOTIFY)
   (focus-change GDK_FOCUS_CHANGE)
   (configure GDK_CONFIGURE)
   (map GDK_MAP)
   (unmap GDK_UNMAP)
   (property-notify GDK_PROPERTY_NOTIFY)
   (selection-clear GDK_SELECTION_CLEAR)
   (selection-request GDK_SELECTION_REQUEST)
   (selection-notify GDK_SELECTION_NOTIFY)
   (proximity-in GDK_PROXIMITY_IN)
   (proximity-out GDK_PROXIMITY_OUT)
   (drag-enter GDK_DRAG_ENTER)
   (drag-leave GDK_DRAG_LEAVE)
   (drag-motion GDK_DRAG_MOTION)
   (drag-status GDK_DRAG_STATUS)
   (drop-start GDK_DROP_START)
   (drop-finished GDK_DROP_FINISHED)
   (client-event GDK_CLIENT_EVENT)
   (visibility-notify GDK_VISIBILITY_NOTIFY)
   (no-expose GDK_NO_EXPOSE))

(defenum GdkFill
   (solid GDK_SOLID)
   (tiled GDK_TILED)
   (stippled GDK_STIPPLED)
   (opaque-stippled GDK_OPAQUE_STIPPLED))

(defenum GdkFontType
   ;; XXX these are not implemented in bigloo-lib
   (font GDK_FONT_FONT)
   (fontset GDK_FONT_FONTSET))

(defenum GdkFunction
   (copy GDK_COPY)
   (invert GDK_INVERT)
   (xor GDK_XOR)
   ;; XXX these are not implemented in bigloo-lib
   (clear GDK_CLEAR)
   (and GDK_AND)
   (and-reverse GDK_AND_REVERSE)
   (and-invert GDK_AND_INVERT)
   (noop GDK_NOOP)
   (or GDK_OR)
   (equiv GDK_EQUIV)
   (or-reverse GDK_OR_REVERSE)
   (copy-invert GDK_COPY_INVERT)
   (or-invert GDK_OR_INVERT)
   (nand GDK_NAND)
   (set GDK_SET))

(defflags GdkInputCondition
   (read GDK_INPUT_READ)
   (write GDK_INPUT_WRITE)
   (exception GDK_INPUT_EXCEPTION))

(defenum GdkJoinStyle
   (miter GDK_JOIN_MITER)
   (round GDK_JOIN_ROUND)
   (bevel GDK_JOIN_BEVEL))

(defenum GdkLineStyle
   (solid GDK_LINE_SOLID)
   (on-off-dash GDK_LINE_ON_OFF_DASH)
   (double-dash GDK_LINE_DOUBLE_DASH))

(defflags GdkModifierType
  (shift GDK_SHIFT_MASK)
  (lock GDK_LOCK_MASK)
  (control GDK_CONTROL_MASK)
  (mod1 GDK_MOD1_MASK)
  (mod2 GDK_MOD2_MASK)
  (mod3 GDK_MOD3_MASK)
  (mod4 GDK_MOD4_MASK)
  (mod5 GDK_MOD5_MASK)
  (button1 GDK_BUTTON1_MASK)
  (button2 GDK_BUTTON2_MASK)
  (button3 GDK_BUTTON3_MASK)
  (button4 GDK_BUTTON4_MASK)
  (button5 GDK_BUTTON5_MASK)
  ;; XXX these last 2 are not implemented by bigloo-lib
  (release GDK_RELEASE_MASK)
  (modifier GDK_MODIFIER_MASK))

(defenum GdkRgbDither
   ;; XXX none of these are implemented by bigloo-lib
   (none GDK_RGB_DITHER_NONE)
   (normal GDK_RGB_DITHER_NORMAL)
   (max GDK_RGB_DITHER_MAX))

(defenum GdkSubwindowMode
   (clip-by-children GDK_CLIP_BY_CHILDREN)
   (include-inferiors GDK_INCLUDE_INFERIORS))

(defenum GdkVisualType
   (static-gray GDK_VISUAL_STATIC_GRAY)
   (grayscale GDK_VISUAL_GRAYSCALE)
   (static-color GDK_VISUAL_STATIC_COLOR)
   (pseudo-color GDK_VISUAL_PSEUDO_COLOR)
   (true-color GDK_VISUAL_TRUE_COLOR)
   (direct-color GDK_VISUAL_DIRECT_COLOR))


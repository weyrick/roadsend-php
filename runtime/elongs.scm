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
(module elong-lib
   (extern  
;     (infix macro c-elong<?::bool (::elong ::elong) "<")
;     (infix macro c-elong>?::bool (::elong ::elong) ">")
;     (infix macro c-elong<=?::bool (::elong ::elong) "<=")
;     (infix macro c-elong>=?::bool (::elong ::elong) ">=")
;     (infix macro c-elong-add::elong (::elong ::elong) "+")
;     (infix macro c-elong-mul::elong (::elong ::elong) "*")
;     (infix macro c-elong-sub::elong (::elong ::elong) "-")
;     (infix macro c-elong-div::elong (::elong ::elong) "/")
    )
   (export
    (elong->ustring::string s1::elong)
    (inline epositive?::bool ::elong)
    (inline enegative?::bool ::elong)
;     (inline +elong::elong ::elong ::elong)
;     (inline *elong::elong ::elong ::elong)
;     (inline /elong::elong ::elong ::elong)
;     (inline -elong::elong ::elong ::elong)
;     (inline <elong::bool ::elong ::elong)
;     (inline >elong::bool ::elong ::elong)
;     (inline <=elong::bool ::elong ::elong)
;     (inline >=elong::bool ::elong ::elong)
    )
;    (pragma
;     (<elong side-effect-free no-cfa-top nesting)
;     (>elong side-effect-free no-cfa-top nesting)
;     (<=elong side-effect-free no-cfa-top nesting)
;     (>=elong side-effect-free no-cfa-top nesting)
;     (+elong side-effect-free no-cfa-top nesting)
;     (-elong side-effect-free no-cfa-top nesting)
;     (*elong side-effect-free no-cfa-top nesting)
;     (/elong side-effect-free no-cfa-top nesting))
   )

;*---------------------------------------------------------------------*/
;*    elong->ustring                                                   */
;*---------------------------------------------------------------------*/
(define (elong->ustring s1)
   (let ((buf (make-string 15)))
      (pragma "snprintf($1, 15, \"%u\", $2)" ($bstring->string buf) s1)
      buf))

;*---------------------------------------------------------------------*/
;*    epositive ...                                                    */
;*---------------------------------------------------------------------*/
(define-inline (epositive? s1)
   (>elong s1 0))

;*---------------------------------------------------------------------*/
;*    enegative ...                                                    */
;*---------------------------------------------------------------------*/
(define-inline (enegative? s1)
   (<elong s1 0))

;*---------------------------------------------------------------------*/
;*    <elong ...                                                       */
;*---------------------------------------------------------------------*/
; (define-inline (<elong s1 s2)
;    (c-elong<? s1 s2))

; ;*---------------------------------------------------------------------*/
; ;*    >elong ...                                                       */
; ;*---------------------------------------------------------------------*/
; (define-inline (>elong s1 s2)
;    (c-elong>? s1 s2))

; ;*---------------------------------------------------------------------*/
; ;*    <=elong ...                                                      */
; ;*---------------------------------------------------------------------*/
; (define-inline (<=elong s1 s2)
;    (c-elong<=? s1 s2))

; ;*---------------------------------------------------------------------*/
; ;*    >=elong ...                                                      */
; ;*---------------------------------------------------------------------*/
; (define-inline (>=elong s1 s2)
;    (c-elong>=? s1 s2))

; ;*---------------------------------------------------------------------*/
; ;*    +elong ...                                                       */
; ;*---------------------------------------------------------------------*/
; (define-inline (+elong s1 s2)
;    (c-elong-add s1 s2))

; ;*---------------------------------------------------------------------*/
; ;*    *elong ...                                                       */
; ;*---------------------------------------------------------------------*/
; (define-inline (*elong s1 s2)
;    (c-elong-mul s1 s2))

; ;*---------------------------------------------------------------------*/
; ;*    -elong ...                                                       */
; ;*---------------------------------------------------------------------*/
; (define-inline (-elong s1 s2)
;    (c-elong-sub s1 s2))

; ;*---------------------------------------------------------------------*/
; ;*    /elong ...                                                       */
; ;*---------------------------------------------------------------------*/
; (define-inline (/elong s1 s2)
;    (c-elong-div s1 s2))


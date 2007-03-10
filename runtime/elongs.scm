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
   (export
    (elong->ustring::string s1::elong)
    (inline epositive?::bool ::elong)
    (inline enegative?::bool ::elong)
    )
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


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

(module xml-additional-c-bindings
   (include "../phpoo-extension.sch")
   (include "xml.sch")
;   (library common)
   (import (xml-c-bindings "c-bindings.scm"))
   (type (subtype xmlChar* "xmlChar*" (cobj))
	 (coerce cobj xmlChar* () (cobj->xmlChar*))
	 (coerce xmlChar* cobj () (xmlChar*->cobj))
	 (coerce xmlChar* string () (xmlChar*->string))	 
	 (coerce
	  xmlChar*
	  bool
	  ()
	  ((lambda (x) (pragma::bool "$1 != NULL" x))))
	 (subtype bxmlChar* "obj_t" (obj))
	 (coerce obj bxmlChar* () ())
	 (coerce bxmlChar* obj () ())
	 (coerce
	  bxmlChar*
	  xmlChar*
	  (xmlChar*?)
	  (bxmlChar*->xmlChar*))
	 (coerce
	  xmlChar*
	  obj
	  ()
	  ((lambda
		 (result)
	      (pragma::bxmlChar*
	       "cobj_to_foreign($1, $2)"
	       'xmlChar*
	       result)))))
   (foreign
    (macro xmlChar*
	   cobj->xmlChar*
	   (cobj)
	   "(xmlChar*)")
    (macro cobj xmlChar*->cobj (xmlChar*) "(long)")
    (macro string xmlChar*->string (xmlChar*) "(char*)")
    (macro xmlChar*
	   bxmlChar*->xmlChar*
	   (foreign)
	   "(xmlChar*)FOREIGN_TO_COBJ"))
   (extern
    (type xmlChar** (pointer xmlChar*) "xmlChar **")
    (type xmlEntityPtr (opaque) "xmlEntityPtr")

    (xmlstring->bstring::bstring (str::xmlChar*) "xmlstring_to_bstring")
    (xmlstring->bstring/len::bstring (str::xmlChar* len::int) "xmlstring_to_bstring_len")

    (include "libxml/parser.h")
    (include "scm-xml.h")
    (export get-entity "get_entity")
    (export ext-entity-handler "ext_entity_handler")
    (export notation-handler "notation_handler")
    (export unparsed-entity-handler "unparsed_entity_handler")
    (export char-handler "char_handler")
    (export pi-handler "pi_handler")
    (export comment-handler "comment_handler")
    (export start-element-handler "start_element_handler")
    (export end-element-handler "end_element_handler"))
   (export
    (start-element-handler udata::void* name::xmlChar* atts::xmlChar**)
    (end-element-handler udata::void* name::xmlChar*)
    (get-entity::xmlEntityPtr udata::void* name::xmlChar*)
    (ext-entity-handler udata::void* name::xmlChar* type::int sysid::xmlChar* pubid::xmlChar* content::xmlChar*)
    (notation-handler udata::void* notation::xmlChar* sysid::xmlChar* pubid::xmlChar*)
    (unparsed-entity-handler udata::void* name::xmlChar* sysid::xmlChar* pubid::xmlChar* notation::xmlChar*)
    (char-handler udata::void* cdata::xmlChar* datalen::int)
    (pi-handler udata::void* target::xmlChar* data::xmlChar*)
    (comment-handler udata::void* comment::xmlChar*)
    (xmlChar*?::bool o::obj) ))



; call a custom php handler
(define (call-handler s-udata which-handler . args)
   (let ((php-handler (hashtable-get (xml-res-handlers s-udata) which-handler))
	 (cb-obj (container-value (xml-res-cb-obj s-udata))))
      (when php-handler
	 ; if php-handler is an array, first element is object, second is method name
	 (if (php-hash? php-handler)
	     (begin
		(set! cb-obj (container-value (php-hash-lookup-ref php-handler #f 0)))
		(set! php-handler (php-hash-lookup php-handler 1))))
	 (if (eqv? cb-obj 'unset)
	     (apply php-funcall php-handler s-udata args)
	     (apply call-php-method cb-obj php-handler s-udata args)))))


(define (start-element-handler udata::void* name::xmlChar* atts::xmlChar**)
   (let ((s-udata (pragma::struct "$1" udata))
 	 (php-atts 'unset)
 	 (case-fold #f)
 	 (cf-name (xmlstring->bstring name)))
      ; level item is used by parse_into_struct
      (xml-res-level-set! s-udata (+ (xml-res-level s-udata) 1))
      ; check for case fold
      (if (php-= (hashtable-get (xml-res-options s-udata) 'case-fold) 1)
 	  (begin
 	     (set! case-fold #t)
 	     (set! cf-name (string-upcase cf-name)))
 	  (set! case-fold #f))
      ; get attributes. if there are none, we'll have a blank array
      (set! php-atts (get-attributes atts case-fold))
      ; if called from parse_into_struct...
      (if (xml-res-in-struct s-udata)
 	  ; in struct
 	  (let ((new-tag (make-php-hash))
 		(new-idx (php-hash-size (container-value (xml-res-struct-vals s-udata)))))
 	     (xml-res-last-open-set! s-udata #t)
 	     (php-hash-insert! new-tag "tag" cf-name)
 	     (php-hash-insert! new-tag "type" "open")
 	     (php-hash-insert! new-tag "level" (xml-res-level s-udata))
 	     (if (> (php-hash-size php-atts) 0)
 		 (php-hash-insert! new-tag "attributes" php-atts))
 	     (add-tag-index (xml-res-struct-index s-udata) cf-name new-idx)
 	     ; we need to save this tag so we can add a value to it if it's a closed tag
 	     (xml-res-cur-cdata-set! s-udata new-tag)
 	     (php-hash-insert! (container-value (xml-res-struct-vals s-udata)) new-idx new-tag)))
      ; always try custom php handler
      (call-handler s-udata 'start-handler cf-name php-atts)))

(define (end-element-handler udata::void* name::xmlChar*)
   (let ((s-udata (pragma::struct "$1" udata))
	 (cf-name (xmlstring->bstring name)))
      ; check for case fold
      (when (php-= (hashtable-get (xml-res-options s-udata) 'case-fold) 1)
	 (set! cf-name (string-upcase cf-name)))
      ; if called from parse_intro_struct...
      (if (xml-res-in-struct s-udata)
	  (begin
	     ; in struct
	     (if (xml-res-last-open s-udata)
		 ; complete tag
		 (php-hash-insert! (xml-res-cur-cdata s-udata) "type" "complete")
		 ; incomplete tag
		 (let ((new-tag (make-php-hash))
		       (new-idx (php-hash-size (container-value (xml-res-struct-vals s-udata)))))
		    (php-hash-insert! new-tag "tag" cf-name)
		    (php-hash-insert! new-tag "type" "close")
		    (php-hash-insert! new-tag "level" (xml-res-level s-udata))
		    (add-tag-index (xml-res-struct-index s-udata) cf-name new-idx)
		    (php-hash-insert! (container-value (xml-res-struct-vals s-udata)) new-idx new-tag)))
	     ; no longer open
	     (xml-res-last-open-set! s-udata #f)))
      ; always try custom handler
      (call-handler s-udata 'end-handler cf-name)
      ; level item is used by parse_into_struct
      (xml-res-level-set! s-udata (- (xml-res-level s-udata) 1))))

(define (char-handler udata::void* cdata::xmlChar* datalen::int)
   (let ((s-udata (pragma::struct "$1" udata))
	 (not-all-white #t)
	 ; cdata is not null terminated
	 (data (xmlstring->bstring/len cdata datalen)))
      ; if skip white is in effect, don't allow all whitespace char data
      (when (and (eqv? (hashtable-get (xml-res-options s-udata) 'skip-white) 1)
		 (pregexp-match "^[\\t\\s\\n]+$" data))
	 (set! not-all-white #f))
      ; if called from parse_intro_struct...
      (if (and (xml-res-in-struct s-udata)
	       not-all-white)
	  (if (xml-res-last-open s-udata)
	      ; already in a tag
	      (let ((new-val "")
		    (cur-val (php-hash-lookup (xml-res-cur-cdata s-udata) "value")))
		 (if (string? cur-val)
		     ; already exists, append
		     (set! new-val (string-append cur-val data))
		     ; doesn't exist yet
		     (set! new-val data))
		 (php-hash-insert! (xml-res-cur-cdata s-udata) "value" new-val))		 
	      ; not in tag
	      (let ((new-tag (make-php-hash)))
		 ; FIXME not sure how to trigger this, or what goes in 'tag' entry (most recent tag?)
		 (php-hash-insert! new-tag "tag" "")
		 (php-hash-insert! new-tag "type" "cdata")
		 (php-hash-insert! new-tag "value" data)		 
		 (php-hash-insert! new-tag "level" (xml-res-level s-udata))
		 (php-hash-insert! (container-value (xml-res-struct-vals s-udata)) :next new-tag))))
      ; always try php handler
      (call-handler s-udata 'cdata-handler data)))

; this needs to return NULL
(define (get-entity::xmlEntityPtr udata::void* name::xmlChar*)
; NOTE this code commented out is compatible with php5-b1
;    (let ((s-udata (pragma::struct "$1" udata)))
;       (call-handler s-udata 'default-handler
; 		      (string-append "&" (xmlstring->bstring name) ";"))))
   (pragma::xmlEntityPtr "NULL"))

(define (ext-entity-handler udata::void* name::xmlChar* type::int sysid::xmlChar* pubid::xmlChar* content::xmlChar*)
   (let ((s-udata (pragma::struct "$1" udata)))
      (call-handler s-udata 'ext-entity-handler
		    (xmlstring->bstring name)
		    ""
		    (xmlstring->bstring sysid)
		    (xmlstring->bstring pubid))))   

(define (notation-handler udata::void* notation::xmlChar* sysid::xmlChar* pubid::xmlChar*)
   (let ((s-udata (pragma::struct "$1" udata)))
      (call-handler s-udata 'notation-handler
		      (xmlstring->bstring notation)
		      ""
		      (xmlstring->bstring sysid)
		      (xmlstring->bstring pubid))))   

(define (unparsed-entity-handler udata::void* name::xmlChar* sysid::xmlChar* pubid::xmlChar* notation::xmlChar*)
   (let ((s-udata (pragma::struct "$1" udata)))
      (call-handler s-udata 'unparsed-entity-handler
		    (xmlstring->bstring name)
		    ""
		    (xmlstring->bstring sysid)
		    (xmlstring->bstring pubid)
		    (xmlstring->bstring notation))))   

(define (pi-handler udata::void* target::xmlChar* data::xmlChar*)
   (let ((s-udata (pragma::struct "$1" udata)))
      (call-handler s-udata 'pi-handler
		    (xmlstring->bstring target)
		    (xmlstring->bstring data))))

(define (comment-handler udata::void* comment::xmlChar*)
   (let ((s-udata (pragma::struct "$1" udata)))
      (call-handler s-udata 'default-handler
		    ; note in php5-b1, the comment starts with <-- not <!--, their bug? 
		    (string-append "<!--" (xmlstring->bstring comment) "-->"))))

(define (xmlChar*?::bool o::obj)
  (and (foreign? o) (eq? (foreign-id o) 'xmlChar*)))

; pull attributes from a start element, build a php hash
(define (get-attributes atts::xmlChar** case-fold)
   (if (pragma::bool "$1 != NULL" atts)
      (let loop ((count 0)
		 (a-hash (make-php-hash)))
	 (let ((attname::xmlChar* (pragma::xmlChar* "$1[$2]" atts count)))
	    (if (pragma::bool "$1 == NULL" attname)
		a-hash
		(let ((cf-name (xmlstring->bstring attname)))
		   (when case-fold
		       (set! cf-name (string-upcase cf-name)))
		   (php-hash-insert! a-hash cf-name (get-attrval-if-avail atts (+fx 1 count))) 
		   (loop (+fx 2 count) a-hash)))))
      (make-php-hash)))

; used to build index array for parse_into_struct
(define (add-tag-index p-hash tagname new-idx)
   (when (and (not (eqv? p-hash 'unset))
	      (php-hash? (container-value p-hash)))
      (let ((tag (php-hash-lookup (container-value p-hash) tagname)))
	 (if (php-hash? tag)
	     (begin
		(php-hash-insert! tag :next new-idx)
		(php-hash-insert! (container-value p-hash) tagname tag))
	     (let ((first-tag (make-php-hash)))
		(php-hash-insert! first-tag :next new-idx)
		(php-hash-insert! (container-value p-hash) tagname first-tag))))))

; pull attribute values from a start element, if there are any
(define (get-attrval-if-avail atts::xmlChar** num::long)
   (let ((attval::xmlChar* (pragma::xmlChar* "$1[$2]" atts num)))
      (if (pragma::bool "$1 == NULL" attval)
	  ""
	  (xmlstring->bstring attval))))



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
(module php-xml
   (include "../phpoo-extension.sch")
   (include "xml.sch")
;   (library common)
   (library profiler)
   (import (xml-c-bindings "c-bindings.scm")
	   (xml-additional-c-bindings "xml-additional-c-bindings.scm"))
   ; this code was mostly stolen from cgen output
   

   
   ; exports
   (export
    XML_OPTION_SKIP_WHITE
    XML_OPTION_SKIP_TAGSTART
    XML_OPTION_TARGET_ENCODING
    XML_OPTION_CASE_FOLDING
    XML_ERROR_EXTERNAL_ENTITY_HANDLING
    XML_ERROR_UNCLOSED_CDATA_SECTION
    XML_ERROR_INCORRECT_ENCODING
    XML_ERROR_UNKNOWN_ENCODING
    XML_ERROR_MISPLACED_XML_PI
    XML_ERROR_ATTRIBUTE_EXTERNAL_ENTITY_REF
    XML_ERROR_BINARY_ENTITY_REF
    XML_ERROR_BAD_CHAR_REF
    XML_ERROR_ASYNC_ENTITY
    XML_ERROR_RECURSIVE_ENTITY_REF
    XML_ERROR_UNDEFINED_ENTITY
    XML_ERROR_PARAM_ENTITY_REF
    XML_ERROR_JUNK_AFTER_DOC_ELEMENT
    XML_ERROR_DUPLICATE_ATTRIBUTE
    XML_ERROR_TAG_MISMATCH
    XML_ERROR_PARTIAL_CHAR
    XML_ERROR_UNCLOSED_TOKEN
    XML_ERROR_INVALID_TOKEN
    XML_ERROR_NO_ELEMENTS
    XML_ERROR_SYNTAX
    XML_ERROR_NO_MEMORY
    XML_ERROR_NONE
    
    init-php-xml-lib
    ; php builtins
    (xml_error_string code)
    (xml_get_current_line_number parser)
    (xml_get_current_column_number parser)
    (xml_get_current_byte_index parser)
    (xml_get_error_code parser)
    (xml_parse parser data is-final)
    (xml_parser_create encoding)
    (xml_parser_free parser)
    (xml_set_object parser php-object)
    (xml_set_character_data_handler parser handler)
    (xml_set_default_handler parser handler)
    (xml_set_external_entity_ref_handler parser handler)
    (xml_set_notation_decl_handler parser handler)
    (xml_set_processing_instruction_handler parser handler)
    (xml_set_unparsed_entity_decl_handler parser handler)
    (xml_parse_into_struct parser data values index)
    (xml_parser_set_option parser option value)
    (xml_parser_get_option parser option)
    (xml_set_element_handler parser start-handler end-handler)
    (utf8_encode str)
    (utf8_decode str))
   ;
   )




;
; MISC
;



; magical init routine
(define (init-php-xml-lib)
   1)

; register the extension
(register-extension "xml" "1.0.0"
                    "php-xml" '("-lxml2")) ;"-copt -Lc:/msys/1.0/local/lib -lxml2"))
;weird mingw path stuff

;
; CONSTANTS
;
; these error constants aren't currently used (expat?)
(defconstant XML_ERROR_NONE 1)
(defconstant XML_ERROR_NO_MEMORY 2)
(defconstant XML_ERROR_SYNTAX 3)
(defconstant XML_ERROR_NO_ELEMENTS 4)
(defconstant XML_ERROR_INVALID_TOKEN 5)
(defconstant XML_ERROR_UNCLOSED_TOKEN 6)
(defconstant XML_ERROR_PARTIAL_CHAR 7)
(defconstant XML_ERROR_TAG_MISMATCH 8)
(defconstant XML_ERROR_DUPLICATE_ATTRIBUTE 9)
(defconstant XML_ERROR_JUNK_AFTER_DOC_ELEMENT 10)
(defconstant XML_ERROR_PARAM_ENTITY_REF 11)
(defconstant XML_ERROR_UNDEFINED_ENTITY 12)
(defconstant XML_ERROR_RECURSIVE_ENTITY_REF 13)
(defconstant XML_ERROR_ASYNC_ENTITY 14)
(defconstant XML_ERROR_BAD_CHAR_REF 15)
(defconstant XML_ERROR_BINARY_ENTITY_REF 16)
(defconstant XML_ERROR_ATTRIBUTE_EXTERNAL_ENTITY_REF 17)
(defconstant XML_ERROR_MISPLACED_XML_PI 18)
(defconstant XML_ERROR_UNKNOWN_ENCODING 19)
(defconstant XML_ERROR_INCORRECT_ENCODING 20)
(defconstant XML_ERROR_UNCLOSED_CDATA_SECTION 21)
(defconstant XML_ERROR_EXTERNAL_ENTITY_HANDLING 22)

; options
(defconstant XML_OPTION_CASE_FOLDING 23)
(defconstant XML_OPTION_TARGET_ENCODING 24)
(defconstant XML_OPTION_SKIP_TAGSTART 25)
(defconstant XML_OPTION_SKIP_WHITE 26)
   
;
; BUILTINS
;

; xml_error_string -- get XML parser error string
(defbuiltin (xml_error_string code)
   (if (php-> code (vector-length *xml-errors*))
       (php-warning (format "invalid xml error code ~a" code))
       (vector-ref *xml-errors* (mkfixnum code))))

; xml_get_current_byte_index -- get current byte index for an XML parser
(defbuiltin (xml_get_current_byte_index parser)
   (let ((ctxt (clean-ctxt parser)))
      (if ctxt
	  (pragma::int "((xmlParserCtxtPtr)FOREIGN_TO_COBJ($1))->input->consumed" ctxt)
	  #f)))

; xml_get_current_column_number --  Get current column number for an XML parser
(defbuiltin (xml_get_current_column_number parser)
   (let ((ctxt (clean-ctxt parser)))
      (if ctxt
	  (pragma::int "((xmlParserCtxtPtr)FOREIGN_TO_COBJ($1))->input->col" ctxt)
	  #f)))

; xml_get_current_line_number -- get current line number for an XML parser
(defbuiltin (xml_get_current_line_number parser)
   (let ((ctxt (clean-ctxt parser)))
      (if ctxt
	  (pragma::int "((xmlParserCtxtPtr)FOREIGN_TO_COBJ($1))->input->line" ctxt)
	  #f)))

; xml_get_error_code -- get XML parser error code
(defbuiltin (xml_get_error_code parser)
   (let ((ctxt (clean-ctxt parser)))
      (if ctxt
	  (pragma::int "((xmlParserCtxtPtr)FOREIGN_TO_COBJ($1))->errNo" ctxt)
	  #f)))

; xml_parse -- start parsing an XML document
(defbuiltin (xml_parse parser data (is-final 'unset))
   (when (not (boolean? is-final))
      (set! is-final #f))
   (let ((sdata (mkstr data)))
      (if (valid-parser? parser)
	  (let ((ret (xml-parse-chunk (xml-res-parser parser)
				      sdata
 				      (string-length sdata)
				      (if is-final 1 0))))
	     (= ret 0))
	  #f)))
   
; xml_parser_create -- create an XML parser
(defbuiltin (xml_parser_create (encoding "ISO-8859-1"))
   (new-xml-resource encoding))

; xml_parser_free -- Free an XML parser
(defbuiltin (xml_parser_free parser)
   (let ((ctxt (clean-ctxt parser)))
      (if ctxt
	  (begin
	     (xml-res-open?-set! parser #f)
	     (xml-free-parser-ctxt ctxt))	  
	  #f)))

; xml_set_character_data_handler -- set up character data handler
(defbuiltin (xml_set_character_data_handler parser handler)
   (if (valid-parser? parser)
       (begin
	  (hashtable-put! (xml-res-handlers parser) 'cdata-handler handler)
	  #t)
       #f))

; xml_set_default_handler -- set up default handler
(defbuiltin (xml_set_default_handler parser handler)
   (if (valid-parser? parser)
       (begin
	  (hashtable-put! (xml-res-handlers parser) 'default-handler handler)
	  #t)
       #f))

; xml_set_element_handler -- set up start and end element handlers
(defbuiltin (xml_set_element_handler parser start-handler end-handler)
   (if (valid-parser? parser)
      (begin
	 (hashtable-put! (xml-res-handlers parser) 'start-handler start-handler)
	 (hashtable-put! (xml-res-handlers parser) 'end-handler end-handler)
	 #t)
      #f))

; xml_set_external_entity_ref_handler -- set up external entity reference handler
(defbuiltin (xml_set_external_entity_ref_handler parser handler)
   (if (valid-parser? parser)
       (begin
	  (hashtable-put! (xml-res-handlers parser) 'ext-entity-handler handler)
	  #t)
       #f))

; xml_set_notation_decl_handler -- set up notation declaration handler
(defbuiltin (xml_set_notation_decl_handler parser handler)
   (if (valid-parser? parser)
       (begin
	  (hashtable-put! (xml-res-handlers parser) 'notation-handler handler)
	  #t)
       #f))

; xml_set_processing_instruction_handler --  Set up processing instruction (PI) handler
(defbuiltin (xml_set_processing_instruction_handler parser handler)
   (if (valid-parser? parser)
       (begin
	  (hashtable-put! (xml-res-handlers parser) 'pi-handler handler)
	  #t)
       #f))

; xml_set_unparsed_entity_decl_handler --  Set up unparsed entity declaration handler
(defbuiltin (xml_set_unparsed_entity_decl_handler parser handler)
   (if (valid-parser? parser)
       (begin
	  (hashtable-put! (xml-res-handlers parser) 'unparsed-entity-handler handler)
	  #t)
       #f))

; xml_parse_into_struct -- Parse XML data into an array structure
(defbuiltin (xml_parse_into_struct parser data (ref . values) ((ref . index) 'unset))
   (let ((sdata (mkstr data)))
;      (print "ok sdata is " sdata)
      (if (valid-parser? parser)
	  (begin
	     ; set in struct stuff
	     (xml-res-in-struct-set! parser #t)
	     (container-value-set! values (make-php-hash))
	     (when (not (eqv? index 'unset))
		(container-value-set! index (make-php-hash))) 
	     (xml-res-struct-vals-set! parser values)
	     (xml-res-struct-index-set! parser index)
	     ; parse data, callbacks handle array population
	     (xml-parse-chunk (xml-res-parser parser)
			      sdata
			      (string-length sdata)
			      1))
	  #f)))

; xml_parser_get_option -- get options from an XML parser
(defbuiltin (xml_parser_get_option parser option)
   (if (valid-parser? parser)
       (cond ((php-= option XML_OPTION_CASE_FOLDING) (hashtable-get (xml-res-options parser) 'case-fold))
	     ((php-= option XML_OPTION_SKIP_WHITE) (hashtable-get (xml-res-options parser) 'skip-white))
	     ((php-= option XML_OPTION_SKIP_TAGSTART) (hashtable-get (xml-res-options parser) 'skip-tagstart))
	     ((php-= option XML_OPTION_TARGET_ENCODING) (xml-res-encoding parser))
	     (else (php-warning "Unknown option")))  
       #f))

; xml_parser_set_option -- set options in an XML parser
(defbuiltin (xml_parser_set_option parser option value)
   (if (valid-parser? parser)
       (cond ((php-= option XML_OPTION_CASE_FOLDING) (hashtable-put! (xml-res-options parser) 'case-fold value))
	     ((php-= option XML_OPTION_SKIP_WHITE) (hashtable-put! (xml-res-options parser) 'skip-white value))
	     ((php-= option XML_OPTION_SKIP_TAGSTART) (hashtable-put! (xml-res-options parser) 'skip-tagstart value))
	     ((php-= option XML_OPTION_TARGET_ENCODING) (xml-res-encoding-set! parser value))
	     (else (php-warning "Unknown option")))  
       #f))

; xml_set_object -- Use XML Parser within an object
(defbuiltin (xml_set_object parser (ref . php-object))
   (if (valid-parser? parser)
       (begin
	  (xml-res-cb-obj-set! parser php-object)
	  #t)
       #f))
   

; xml_set_start_namespace_decl_handler --  Set up character data handler
; xml_set_end_namespace_decl_handler --  Set up character data handler
; xml_parser_create_ns --  Create an XML parser


; utf8_decode --  Converts a string with ISO-8859-1 characters encoded with UTF-8 to single-byte ISO-8859-1.
(defbuiltin (utf8_decode str)
   (let* ((instr (mkstr str))
	  (isize (string-length instr))
	  (osize (+ isize 1))
	  (outstr (make-string osize))
	  (insize (make-int* 1))
	  (outsize (make-int* 1))
	  ; XXX compensate for 2.4.x/2.6.x versions
	  (success (lambda (rval)
		     (cond-expand
		      (PCC_MINGW
		       (= rval 0))
		      (else
		       (> rval 0))))))
      (int*-set! outsize 0 osize)
      (int*-set! insize 0 isize)
      (let ((retval (utf8-decode outstr outsize instr insize)))
	 (if (success retval)
	     (substring outstr 0 (int*-ref outsize 0))
	     #f))))

; utf8_encode -- encodes an ISO-8859-1 string to UTF-8
(defbuiltin (utf8_encode str)
   (let* ((instr (mkstr str))
	  (isize (string-length instr))
	  (osize (+ (* isize 4) 1))
	  (outstr (make-string osize))
	  (insize (make-int* 1))
	  (outsize (make-int* 1))
	  ; XXX compensate for 2.4.x/2.6.x versions
	  (success (lambda (rval)
		     (cond-expand
		      (PCC_MINGW
		       (= rval 0))
		      (else
		       (> rval 0))))))
      (int*-set! outsize 0 osize)
      (int*-set! insize 0 isize)
      (let ((retval (utf8-encode outstr outsize instr insize)))
	 (if (success retval)
	     (substring outstr 0 (int*-ref outsize 0))
	     #f))))

;
; IMPLEMENTATION
;

; type check for a ctxt ptr
(define (clean-ctxt parser)
   (if (and (xml-res? parser)
	    (xml-res-open? parser))
       (let ((xml-p-ctxt (xml-res-parser parser)))
	  (if (xml-parser-ctxt-ptr? xml-p-ctxt)
	      xml-p-ctxt
	      #f))
       #f))

(define (valid-parser? parser)
   (if (and (xml-res? parser)
	    (xml-res-open? parser))
       #t
       (php-warning "not a valid XML parser resource")))

; create a new xml resource with parser
(define (new-xml-resource encoding)
   (let* ((new-xml-res (xml-res-resource 'unset ; parser
					 (make-hashtable) ; handlers
					 (make-hashtable) ; options
					 encoding         ; encoding
					 (make-container 'unset) ; callback object
					 0      ; level
					 #f     ; in-struct
					 'unset ; values array
					 'unset ; index array
					 #f     ; last open
					 'unset ; current cdata
					 #t     ; open?
					 ))
	  (ctxt::xml-parser-ctxt-ptr (xml-create-push-parser-ctxt
				      new-xml-res
				      ""
				      0
				      "")))
      (if ctxt ; makes use of cgen'd bool coerce, checking != NULL
	  (begin
	     (xml-res-parser-set! new-xml-res ctxt)
	     (hashtable-put! (xml-res-options new-xml-res) 'case-fold 1)
	     new-xml-res)
	  #f)))


; create new parser context
; hard coded to set callbacks to our scheme functions
(define (xml-create-push-parser-ctxt::xml-parser-ctxt-ptr
	 arg2::struct
	 arg3::string
	 arg4::int
	 arg5::string)
   (pragma::xml-parser-ctxt-ptr "xmlCreatePushParserCtxt(scmHandlerPtr, (void*)$1, $2, $3, $4)"
				arg2
				arg3
				arg4
				arg5))


;;;;;;;;;;;;;;;;;;

; libxml error strings
; vector that corresponds to get_error_code call
(define *xml-errors*
   (vector
    "No error" 
    "Internal error" 
    "No memory" 
    "XML_ERR_DOCUMENT_START" 
    "Empty document" 
    "XML_ERR_DOCUMENT_END" 
    "Invalid hexadecimal character reference" 
    "Invalid decimal character reference" 
    "Invalid character reference" 
    "Invalid character" 
    "XML_ERR_CHARREF_AT_EOF" 
    "XML_ERR_CHARREF_IN_PROLOG" 
    "XML_ERR_CHARREF_IN_EPILOG" 
    "XML_ERR_CHARREF_IN_DTD" 
    "XML_ERR_ENTITYREF_AT_EOF" 
    "XML_ERR_ENTITYREF_IN_PROLOG" 
    "XML_ERR_ENTITYREF_IN_EPILOG" 
    "XML_ERR_ENTITYREF_IN_DTD" 
    "XML_ERR_PEREF_AT_EOF" 
    "XML_ERR_PEREF_IN_PROLOG" 
    "XML_ERR_PEREF_IN_EPILOG" 
    "XML_ERR_PEREF_IN_INT_SUBSET" 
    "XML_ERR_ENTITYREF_NO_NAME" 
    "XML_ERR_ENTITYREF_SEMICOL_MISSING" 
    "XML_ERR_PEREF_NO_NAME" 
    "XML_ERR_PEREF_SEMICOL_MISSING" 
    "Undeclared entity error" 
    "Undeclared entity warning" 
    "Unparsed Entity" 
    "XML_ERR_ENTITY_IS_EXTERNAL" 
    "XML_ERR_ENTITY_IS_PARAMETER" 
    "Unknown encoding" 
    "Unsupported encoding" 
    "XML_ERR_STRING_NOT_STARTED" 
    "XML_ERR_STRING_NOT_CLOSED" 
    "Namespace declaration error" 
    "XML_ERR_ENTITY_NOT_STARTED" 
    "XML_ERR_ENTITY_NOT_FINISHED" 
    "XML_ERR_LT_IN_ATTRIBUTE" 
    "XML_ERR_ATTRIBUTE_NOT_STARTED" 
    "XML_ERR_ATTRIBUTE_NOT_FINISHED" 
    "XML_ERR_ATTRIBUTE_WITHOUT_VALUE" 
    "XML_ERR_ATTRIBUTE_REDEFINED" 
    "XML_ERR_LITERAL_NOT_STARTED" 
    "XML_ERR_LITERAL_NOT_FINISHED"
    ; commented out as per php5-b1
    ; "XML_ERR_COMMENT_NOT_STARTED" 
    "XML_ERR_COMMENT_NOT_FINISHED" 
    "XML_ERR_PI_NOT_STARTED" 
    "XML_ERR_PI_NOT_FINISHED" 
    "XML_ERR_NOTATION_NOT_STARTED" 
    "XML_ERR_NOTATION_NOT_FINISHED" 
    "XML_ERR_ATTLIST_NOT_STARTED" 
    "XML_ERR_ATTLIST_NOT_FINISHED" 
    "XML_ERR_MIXED_NOT_STARTED" 
    "XML_ERR_MIXED_NOT_FINISHED" 
    "XML_ERR_ELEMCONTENT_NOT_STARTED" 
    "XML_ERR_ELEMCONTENT_NOT_FINISHED" 
    "XML_ERR_XMLDECL_NOT_STARTED" 
    "XML_ERR_XMLDECL_NOT_FINISHED" 
    "XML_ERR_CONDSEC_NOT_STARTED" 
    "XML_ERR_CONDSEC_NOT_FINISHED" 
    "XML_ERR_EXT_SUBSET_NOT_FINISHED" 
    "XML_ERR_DOCTYPE_NOT_FINISHED" 
    "XML_ERR_MISPLACED_CDATA_END" 
    "XML_ERR_CDATA_NOT_FINISHED" 
    "XML_ERR_RESERVED_XML_NAME" 
    "XML_ERR_SPACE_REQUIRED" 
    "XML_ERR_SEPARATOR_REQUIRED" 
    "XML_ERR_NMTOKEN_REQUIRED" 
    "XML_ERR_NAME_REQUIRED" 
    "XML_ERR_PCDATA_REQUIRED" 
    "XML_ERR_URI_REQUIRED"
    "XML_ERR_PUBID_REQUIRED" 
    "XML_ERR_LT_REQUIRED" 
    "XML_ERR_GT_REQUIRED" 
    "XML_ERR_LTSLASH_REQUIRED" 
    "XML_ERR_EQUAL_REQUIRED" 
    "mismatched tag" 
    "XML_ERR_TAG_NOT_FINISHED" 
    "XML_ERR_STANDALONE_VALUE" 
    "XML_ERR_ENCODING_NAME" 
    "XML_ERR_HYPHEN_IN_COMMENT" 
    "Invalid encoding" 
    "XML_ERR_EXT_ENTITY_STANDALONE" 
    "XML_ERR_CONDSEC_INVALID" 
    "XML_ERR_VALUE_REQUIRED" 
    "XML_ERR_NOT_WELL_BALANCED" 
    "XML_ERR_EXTRA_CONTENT" 
    "XML_ERR_ENTITY_CHAR_ERROR" 
    "XML_ERR_ENTITY_PE_INTERNAL" 
    "XML_ERR_ENTITY_LOOP" 
    "XML_ERR_ENTITY_BOUNDARY" 
    "Invalid URI" 
    "XML_ERR_URI_FRAGMENT" 
    "XML_WAR_CATALOG_PI" 
    "XML_ERR_NO_DTD"))

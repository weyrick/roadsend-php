;; Created by cgen from (c-bindings.defs). Do not edit!
(module
  xml-c-bindings
  (extern
    (include #"libxml/parser.h")
    (type int* (pointer int) #"int*"))
  (export *null*)
  (type (subtype
          xml-parser-ctxt-ptr
          #"xmlParserCtxtPtr"
          (cobj))
        (coerce
          cobj
          xml-parser-ctxt-ptr
          ()
          (cobj->xml-parser-ctxt-ptr))
        (coerce
          xml-parser-ctxt-ptr
          cobj
          ()
          (xml-parser-ctxt-ptr->cobj))
        (coerce
          xml-parser-ctxt-ptr
          bool
          ()
          ((lambda (x) (pragma::bool #"$1 != NULL" x))))
        (subtype bxml-parser-ctxt-ptr #"obj_t" (obj))
        (coerce obj bxml-parser-ctxt-ptr () ())
        (coerce bxml-parser-ctxt-ptr obj () ())
        (coerce
          bxml-parser-ctxt-ptr
          xml-parser-ctxt-ptr
          (xml-parser-ctxt-ptr?)
          (bxml-parser-ctxt-ptr->xml-parser-ctxt-ptr))
        (coerce
          xml-parser-ctxt-ptr
          obj
          ()
          ((lambda (result)
              (pragma::bxml-parser-ctxt-ptr
                #"cobj_to_foreign($1, $2)"
                'xml-parser-ctxt-ptr
                result)))))
  (foreign
    (macro xml-parser-ctxt-ptr
           cobj->xml-parser-ctxt-ptr
           (cobj)
           #"(xmlParserCtxtPtr)")
    (macro cobj
           xml-parser-ctxt-ptr->cobj
           (xml-parser-ctxt-ptr)
           #"(long)")
    (macro xml-parser-ctxt-ptr
           bxml-parser-ctxt-ptr->xml-parser-ctxt-ptr
           (foreign)
           #"(xmlParserCtxtPtr)FOREIGN_TO_COBJ"))
  (export (xml-parser-ctxt-ptr?::bool o::obj))
  (export
    (xml-parse-chunk::int
      arg1001::xml-parser-ctxt-ptr
      arg1002::string
      arg1003::int
      arg1004::int))
  (export
    (xml-free-parser-ctxt
      arg1005::xml-parser-ctxt-ptr))
  (export
    (utf8-encode::int
      arg1006::string
      arg1007::int*
      arg1008::string
      arg1009::int*))
  (export
    (utf8-decode::int
      arg1010::string
      arg1011::int*
      arg1012::string
      arg1013::int*)))

(define *null* (pragma::void* #"NULL"))

(define (xml-parser-ctxt-ptr?::bool o::obj)
  (and (foreign? o)
       (eq? (foreign-id o) 'xml-parser-ctxt-ptr)))


(define (xml-parse-chunk::int
         arg1001::xml-parser-ctxt-ptr
         arg1002::string
         arg1003::int
         arg1004::int)
  (let ((arg1001::xml-parser-ctxt-ptr arg1001)
        (arg1002::string arg1002)
        (arg1003::int arg1003)
        (arg1004::int arg1004))
    (pragma::int
      #"xmlParseChunk($1, $2, $3, $4)"
      arg1001
      arg1002
      arg1003
      arg1004)))


(define (xml-free-parser-ctxt
         arg1005::xml-parser-ctxt-ptr)
  (let ((arg1005::xml-parser-ctxt-ptr arg1005))
    (pragma #"xmlFreeParserCtxt($1)" arg1005)
    #unspecified))


(define (utf8-encode::int
         arg1006::string
         arg1007::int*
         arg1008::string
         arg1009::int*)
  (let ((arg1006::string arg1006)
        (arg1007::int* arg1007)
        (arg1008::string arg1008)
        (arg1009::int* arg1009))
    (pragma::int
      #"isolat1ToUTF8($1, $2, $3, $4)"
      arg1006
      arg1007
      arg1008
      arg1009)))


(define (utf8-decode::int
         arg1010::string
         arg1011::int*
         arg1012::string
         arg1013::int*)
  (let ((arg1010::string arg1010)
        (arg1011::int* arg1011)
        (arg1012::string arg1012)
        (arg1013::int* arg1013))
    (pragma::int
      #"UTF8Toisolat1($1, $2, $3, $4)"
      arg1010
      arg1011
      arg1012
      arg1013)))


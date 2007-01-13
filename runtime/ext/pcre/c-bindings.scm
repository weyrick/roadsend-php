;; Created by cgen from (c-bindings.defs). Do not edit!
(module
  pcre-c-bindings
  (export
    *null-pcre*
    *null-pcre-extra*
    (inline null-pcre?::bool row::pcre*)
    (inline
      null-pcre-extra?::bool
      mysql::pcre-extra*))
  (extern
    (include #"pcre.h")
    (include #"php-pcre.h")
    (type pcre* (opaque) #"pcre *")
    (type pcre-extra* (opaque) #"pcre_extra *")
    (type const-string string #"const char *")
    (type const-string*
          (pointer string)
          #"const char **")
    (type const-string**
          (pointer const-string*)
          #"const char ***")
    (type int* (pointer int) #"int *")
    (type const-uchar*
          (pointer uchar)
          #"const unsigned char *"))
  (type (subtype pcre-options #"int" (cobj))
        (coerce
          cobj
          pcre-options
          ()
          (cobj->pcre-options))
        (coerce pcre-options cobj () ())
        (subtype bpcre-options #"obj_t" (obj))
        (coerce obj bpcre-options (pcre-options?) ())
        (coerce bpcre-options obj () ())
        (coerce bpcre-options bool () ((lambda (x) #t)))
        (coerce
          bpcre-options
          pcre-options
          ()
          (bpcre-options->pcre-options))
        (coerce
          pcre-options
          bpcre-options
          ()
          (pcre-options->bpcre-options))
        (coerce
          pair
          pcre-options
          ()
          (bpcre-options->pcre-options))
        (coerce
          pcre-options
          pair
          ()
          (pcre-options->bpcre-options))
        (coerce
          pair-nil
          pcre-options
          ()
          (bpcre-options->pcre-options))
        (coerce bool pcre-options () ((lambda (x) 0)))
        (coerce
          pcre-options
          pair-nil
          ()
          (pcre-options->bpcre-options)))
  (foreign
    (macro pcre-options
           cobj->pcre-options
           (cobj)
           #"(int)"))
  (export
    (pcre-options?::bool o::obj)
    (bpcre-options->pcre-options::pcre-options
      o::obj)
    (pcre-options->bpcre-options::bpcre-options
      o::pcre-options))
  (type (subtype pcre-errors #"int" (cobj))
        (coerce cobj pcre-errors () (cobj->pcre-errors))
        (coerce pcre-errors cobj () ())
        (subtype bpcre-errors #"obj_t" (obj))
        (coerce obj bpcre-errors (pcre-errors?) ())
        (coerce bpcre-errors obj () ())
        (coerce bpcre-errors bool () ((lambda (x) #t)))
        (coerce
          bpcre-errors
          pcre-errors
          ()
          (bpcre-errors->pcre-errors))
        (coerce
          pcre-errors
          bpcre-errors
          ()
          (pcre-errors->bpcre-errors))
        (coerce
          pair
          pcre-errors
          ()
          (bpcre-errors->pcre-errors))
        (coerce
          pcre-errors
          pair
          ()
          (pcre-errors->bpcre-errors))
        (coerce
          pair-nil
          pcre-errors
          ()
          (bpcre-errors->pcre-errors))
        (coerce bool pcre-errors () ((lambda (x) 0)))
        (coerce
          pcre-errors
          pair-nil
          ()
          (pcre-errors->bpcre-errors)))
  (foreign
    (macro pcre-errors
           cobj->pcre-errors
           (cobj)
           #"(int)"))
  (export
    (pcre-errors?::bool o::obj)
    (bpcre-errors->pcre-errors::pcre-errors o::obj)
    (pcre-errors->bpcre-errors::bpcre-errors
      o::pcre-errors))
  (type (subtype pcre-info-flags #"int" (cobj))
        (coerce
          cobj
          pcre-info-flags
          ()
          (cobj->pcre-info-flags))
        (coerce pcre-info-flags cobj () ())
        (subtype bpcre-info-flags #"obj_t" (obj))
        (coerce
          obj
          bpcre-info-flags
          (pcre-info-flags?)
          ())
        (coerce bpcre-info-flags obj () ())
        (coerce
          bpcre-info-flags
          bool
          ()
          ((lambda (x) #t)))
        (coerce
          bpcre-info-flags
          pcre-info-flags
          ()
          (bpcre-info-flags->pcre-info-flags))
        (coerce
          pcre-info-flags
          bpcre-info-flags
          ()
          (pcre-info-flags->bpcre-info-flags))
        (coerce
          pair
          pcre-info-flags
          ()
          (bpcre-info-flags->pcre-info-flags))
        (coerce
          pcre-info-flags
          pair
          ()
          (pcre-info-flags->bpcre-info-flags))
        (coerce
          pair-nil
          pcre-info-flags
          ()
          (bpcre-info-flags->pcre-info-flags))
        (coerce bool pcre-info-flags () ((lambda (x) 0)))
        (coerce
          pcre-info-flags
          pair-nil
          ()
          (pcre-info-flags->bpcre-info-flags)))
  (foreign
    (macro pcre-info-flags
           cobj->pcre-info-flags
           (cobj)
           #"(int)"))
  (export
    (pcre-info-flags?::bool o::obj)
    (bpcre-info-flags->pcre-info-flags::pcre-info-flags
      o::obj)
    (pcre-info-flags->bpcre-info-flags::bpcre-info-flags
      o::pcre-info-flags))
  (export (pcc-pcre-setup))
  (export
    (pcre-compile::pcre*
      arg1001::const-string
      arg1002::pcre-options
      arg1003::const-string*
      arg1004::int*
      arg1005::const-uchar*))
  (export
    (pcre-exec::int
      arg1006::pcre*
      arg1007::pcre-extra*
      arg1008::const-string
      arg1009::int
      arg1010::int
      arg1011::pcre-options
      arg1012::int*
      arg1013::int))
  (export
    (pcre-get-substring::int
      arg1014::const-string
      arg1015::int*
      arg1016::int
      arg1017::int
      arg1018::const-string*))
  (export
    (pcre-fullinfo::int
      arg1019::pcre*
      arg1020::pcre-extra*
      arg1021::pcre-info-flags
      arg1022::int*))
  (export
    (pcre-study::pcre-extra*
      arg1023::pcre*
      arg1024::int
      arg1025::const-string*)))

(define *null-pcre*
  (pragma::pcre* #"((pcre*)NULL)"))


(define *null-pcre-extra*
  (pragma::pcre-extra* #"((pcre_extra*)NULL)"))


(define-inline (null-pcre?::bool pcre*::pcre*)
  (pragma::bool #"($1 == (pcre*)0L)" pcre*))


(define-inline (null-pcre-extra?::bool pcre-extra*::pcre-extra*)
  (pragma::bool
    #"($1 == (pcre_extra*)0L)"
    pcre-extra*))


(define (bpcre-options->pcre-options::pcre-options
         o::obj)
  (let ((res::int 0))
    (for-each
      (lambda (o)
         (case o
           ((caseless)
            (set! res
              (bit-or res (pragma::int #"PCRE_CASELESS"))))
           ((multi-line)
            (set! res
              (bit-or res (pragma::int #"PCRE_MULTILINE"))))
           ((dot-all)
            (set! res
              (bit-or res (pragma::int #"PCRE_DOTALL"))))
           ((extended)
            (set! res
              (bit-or res (pragma::int #"PCRE_EXTENDED"))))
           ((anchored)
            (set! res
              (bit-or res (pragma::int #"PCRE_ANCHORED"))))
           ((dollar-end-only)
            (set! res
              (bit-or res (pragma::int #"PCRE_DOLLAR_ENDONLY"))))
           ((extra)
            (set! res
              (bit-or res (pragma::int #"PCRE_EXTRA"))))
           ((not-bol)
            (set! res
              (bit-or res (pragma::int #"PCRE_NOTBOL"))))
           ((not-eol)
            (set! res
              (bit-or res (pragma::int #"PCRE_NOTEOL"))))
           ((ungreedy)
            (set! res
              (bit-or res (pragma::int #"PCRE_UNGREEDY"))))
           ((not-empty)
            (set! res
              (bit-or res (pragma::int #"PCRE_NOTEMPTY"))))
           ((utf8)
            (set! res
              (bit-or res (pragma::int #"PCRE_UTF8"))))
           (else
            (error #"bpcre-options->pcre-options"
                   #"invalid argument, must be one of (caseless multi-line dot-all extended anchored dollar-end-only extra not-bol not-eol ungreedy not-empty utf8): "
                   o))))
      o)
    (let ((res::int res))
      (pragma::pcre-options #"$1" res))))


(define (pcre-options->bpcre-options::bpcre-options
         o::pcre-options)
  (let ((res '()))
    (when (pragma::bool
            #"($1 & PCRE_CASELESS) == PCRE_CASELESS"
            o)
          (set! res (cons 'caseless res)))
    (when (pragma::bool
            #"($1 & PCRE_MULTILINE) == PCRE_MULTILINE"
            o)
          (set! res (cons 'multi-line res)))
    (when (pragma::bool
            #"($1 & PCRE_DOTALL) == PCRE_DOTALL"
            o)
          (set! res (cons 'dot-all res)))
    (when (pragma::bool
            #"($1 & PCRE_EXTENDED) == PCRE_EXTENDED"
            o)
          (set! res (cons 'extended res)))
    (when (pragma::bool
            #"($1 & PCRE_ANCHORED) == PCRE_ANCHORED"
            o)
          (set! res (cons 'anchored res)))
    (when (pragma::bool
            #"($1 & PCRE_DOLLAR_ENDONLY) == PCRE_DOLLAR_ENDONLY"
            o)
          (set! res (cons 'dollar-end-only res)))
    (when (pragma::bool
            #"($1 & PCRE_EXTRA) == PCRE_EXTRA"
            o)
          (set! res (cons 'extra res)))
    (when (pragma::bool
            #"($1 & PCRE_NOTBOL) == PCRE_NOTBOL"
            o)
          (set! res (cons 'not-bol res)))
    (when (pragma::bool
            #"($1 & PCRE_NOTEOL) == PCRE_NOTEOL"
            o)
          (set! res (cons 'not-eol res)))
    (when (pragma::bool
            #"($1 & PCRE_UNGREEDY) == PCRE_UNGREEDY"
            o)
          (set! res (cons 'ungreedy res)))
    (when (pragma::bool
            #"($1 & PCRE_NOTEMPTY) == PCRE_NOTEMPTY"
            o)
          (set! res (cons 'not-empty res)))
    (when (pragma::bool #"($1 & PCRE_UTF8) == PCRE_UTF8" o)
          (set! res (cons 'utf8 res)))
    res))


(define (pcre-options?::bool o::obj)
  (and (list? o)
       (null? (lset-difference
                eq?
                o
                '(caseless
                   multi-line
                   dot-all
                   extended
                   anchored
                   dollar-end-only
                   extra
                   not-bol
                   not-eol
                   ungreedy
                   not-empty
                   utf8)))))


(define (bpcre-errors->pcre-errors::pcre-errors o::obj)
  (let ((res::int 0))
    (for-each
      (lambda (o)
         (case o
           ((no-match)
            (set! res
              (bit-or res (pragma::int #"PCRE_ERROR_NOMATCH"))))
           ((null)
            (set! res
              (bit-or res (pragma::int #"PCRE_ERROR_NULL"))))
           ((bad-option)
            (set! res
              (bit-or
                res
                (pragma::int #"PCRE_ERROR_BADOPTION"))))
           ((bad-magic)
            (set! res
              (bit-or res (pragma::int #"PCRE_ERROR_BADMAGIC"))))
           ((unknown-node)
            (set! res
              (bit-or
                res
                (pragma::int #"PCRE_ERROR_UNKNOWN_NODE"))))
           ((no-memory)
            (set! res
              (bit-or res (pragma::int #"PCRE_ERROR_NOMEMORY"))))
           ((no-substring)
            (set! res
              (bit-or
                res
                (pragma::int #"PCRE_ERROR_NOSUBSTRING"))))
           (else
            (error #"bpcre-errors->pcre-errors"
                   #"invalid argument, must be one of (no-match null bad-option bad-magic unknown-node no-memory no-substring): "
                   o))))
      o)
    (let ((res::int res))
      (pragma::pcre-errors #"$1" res))))


(define (pcre-errors->bpcre-errors::bpcre-errors
         o::pcre-errors)
  (let ((res '()))
    (when (pragma::bool
            #"($1 & PCRE_ERROR_NOMATCH) == PCRE_ERROR_NOMATCH"
            o)
          (set! res (cons 'no-match res)))
    (when (pragma::bool
            #"($1 & PCRE_ERROR_NULL) == PCRE_ERROR_NULL"
            o)
          (set! res (cons 'null res)))
    (when (pragma::bool
            #"($1 & PCRE_ERROR_BADOPTION) == PCRE_ERROR_BADOPTION"
            o)
          (set! res (cons 'bad-option res)))
    (when (pragma::bool
            #"($1 & PCRE_ERROR_BADMAGIC) == PCRE_ERROR_BADMAGIC"
            o)
          (set! res (cons 'bad-magic res)))
    (when (pragma::bool
            #"($1 & PCRE_ERROR_UNKNOWN_NODE) == PCRE_ERROR_UNKNOWN_NODE"
            o)
          (set! res (cons 'unknown-node res)))
    (when (pragma::bool
            #"($1 & PCRE_ERROR_NOMEMORY) == PCRE_ERROR_NOMEMORY"
            o)
          (set! res (cons 'no-memory res)))
    (when (pragma::bool
            #"($1 & PCRE_ERROR_NOSUBSTRING) == PCRE_ERROR_NOSUBSTRING"
            o)
          (set! res (cons 'no-substring res)))
    res))


(define (pcre-errors?::bool o::obj)
  (and (list? o)
       (null? (lset-difference
                eq?
                o
                '(no-match
                   null
                   bad-option
                   bad-magic
                   unknown-node
                   no-memory
                   no-substring)))))


(define (bpcre-info-flags->pcre-info-flags::pcre-info-flags
         o::obj)
  (let ((res::int 0))
    (for-each
      (lambda (o)
         (case o
           ((options)
            (set! res
              (bit-or res (pragma::int #"PCRE_INFO_OPTIONS"))))
           ((size)
            (set! res
              (bit-or res (pragma::int #"PCRE_INFO_SIZE"))))
           ((capture-count)
            (set! res
              (bit-or
                res
                (pragma::int #"PCRE_INFO_CAPTURECOUNT"))))
           ((backref-max)
            (set! res
              (bit-or
                res
                (pragma::int #"PCRE_INFO_BACKREFMAX"))))
           ((first-char)
            (set! res
              (bit-or res (pragma::int #"PCRE_INFO_FIRSTCHAR"))))
           ((first-table)
            (set! res
              (bit-or
                res
                (pragma::int #"PCRE_INFO_FIRSTTABLE"))))
           ((last-literal)
            (set! res
              (bit-or
                res
                (pragma::int #"PCRE_INFO_LASTLITERAL"))))
           (else
            (error #"bpcre-info-flags->pcre-info-flags"
                   #"invalid argument, must be one of (options size capture-count backref-max first-char first-table last-literal): "
                   o))))
      o)
    (let ((res::int res))
      (pragma::pcre-info-flags #"$1" res))))


(define (pcre-info-flags->bpcre-info-flags::bpcre-info-flags
         o::pcre-info-flags)
  (let ((res '()))
    (when (pragma::bool
            #"($1 & PCRE_INFO_OPTIONS) == PCRE_INFO_OPTIONS"
            o)
          (set! res (cons 'options res)))
    (when (pragma::bool
            #"($1 & PCRE_INFO_SIZE) == PCRE_INFO_SIZE"
            o)
          (set! res (cons 'size res)))
    (when (pragma::bool
            #"($1 & PCRE_INFO_CAPTURECOUNT) == PCRE_INFO_CAPTURECOUNT"
            o)
          (set! res (cons 'capture-count res)))
    (when (pragma::bool
            #"($1 & PCRE_INFO_BACKREFMAX) == PCRE_INFO_BACKREFMAX"
            o)
          (set! res (cons 'backref-max res)))
    (when (pragma::bool
            #"($1 & PCRE_INFO_FIRSTCHAR) == PCRE_INFO_FIRSTCHAR"
            o)
          (set! res (cons 'first-char res)))
    (when (pragma::bool
            #"($1 & PCRE_INFO_FIRSTTABLE) == PCRE_INFO_FIRSTTABLE"
            o)
          (set! res (cons 'first-table res)))
    (when (pragma::bool
            #"($1 & PCRE_INFO_LASTLITERAL) == PCRE_INFO_LASTLITERAL"
            o)
          (set! res (cons 'last-literal res)))
    res))


(define (pcre-info-flags?::bool o::obj)
  (and (list? o)
       (null? (lset-difference
                eq?
                o
                '(options
                   size
                   capture-count
                   backref-max
                   first-char
                   first-table
                   last-literal)))))


(define (pcc-pcre-setup)
  (let ()
    (pragma #"pcc_pcre_setup()")
    #unspecified))


(define (pcre-compile::pcre*
         arg1001::const-string
         arg1002::pcre-options
         arg1003::const-string*
         arg1004::int*
         arg1005::const-uchar*)
  (let ((arg1001::const-string arg1001)
        (arg1002::pcre-options arg1002)
        (arg1003::const-string* arg1003)
        (arg1004::int* arg1004)
        (arg1005::const-uchar* arg1005))
    (pragma::pcre*
      #"pcre_compile($1, $2, $3, $4, $5)"
      arg1001
      arg1002
      arg1003
      arg1004
      arg1005)))


(define (pcre-exec::int
         arg1006::pcre*
         arg1007::pcre-extra*
         arg1008::const-string
         arg1009::int
         arg1010::int
         arg1011::pcre-options
         arg1012::int*
         arg1013::int)
  (let ((arg1006::pcre* arg1006)
        (arg1007::pcre-extra* arg1007)
        (arg1008::const-string arg1008)
        (arg1009::int arg1009)
        (arg1010::int arg1010)
        (arg1011::pcre-options arg1011)
        (arg1012::int* arg1012)
        (arg1013::int arg1013))
    (pragma::int
      #"pcre_exec($1, $2, $3, $4, $5, $6, $7, $8)"
      arg1006
      arg1007
      arg1008
      arg1009
      arg1010
      arg1011
      arg1012
      arg1013)))


(define (pcre-get-substring::int
         arg1014::const-string
         arg1015::int*
         arg1016::int
         arg1017::int
         arg1018::const-string*)
  (let ((arg1014::const-string arg1014)
        (arg1015::int* arg1015)
        (arg1016::int arg1016)
        (arg1017::int arg1017)
        (arg1018::const-string* arg1018))
    (pragma::int
      #"pcre_get_substring($1, $2, $3, $4, $5)"
      arg1014
      arg1015
      arg1016
      arg1017
      arg1018)))


(define (pcre-fullinfo::int
         arg1019::pcre*
         arg1020::pcre-extra*
         arg1021::pcre-info-flags
         arg1022::int*)
  (let ((arg1019::pcre* arg1019)
        (arg1020::pcre-extra* arg1020)
        (arg1021::pcre-info-flags arg1021)
        (arg1022::int* arg1022))
    (pragma::int
      #"pcre_fullinfo($1, $2, $3, $4)"
      arg1019
      arg1020
      arg1021
      arg1022)))


(define (pcre-study::pcre-extra*
         arg1023::pcre*
         arg1024::int
         arg1025::const-string*)
  (let ((arg1023::pcre* arg1023)
        (arg1024::int arg1024)
        (arg1025::const-string* arg1025))
    (pragma::pcre-extra*
      #"pcre_study($1, $2, $3)"
      arg1023
      arg1024
      arg1025)))


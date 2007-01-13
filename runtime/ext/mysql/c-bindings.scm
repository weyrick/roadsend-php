;; Created by cgen from (c-bindings.defs). Do not edit!
(module
  mysql-c-bindings
  (export
    *null-mysql*
    (inline null-row?::bool row::mysql-row)
    (inline null-mysql?::bool mysql::mysql)
    (inline null-result?::bool res::mysql-res)
    (inline null-field?::bool field::mysql-field))
  (extern
    (include #"windows-mysql.h")
    (include #"mysql.h")
    (type mysql-field-offset
          uint
          #"MYSQL_FIELD_OFFSET")
    (type mysql-row-offset
          (opaque)
          #"MYSQL_ROW_OFFSET")
    (type my-bool char #"my_bool")
    (type const-string string #"const char *")
    (type my-ulonglong llong #"my_ulonglong")
    (type ulong-ptr
          (pointer ulong)
          #"unsigned long *")
    (type mysql-row (pointer string) #"MYSQL_ROW")
    (macro is-pri-key?::int
           (n::field-flags)
           #"IS_PRI_KEY")
    (macro is-not-null?::int
           (n::field-flags)
           #"IS_NOT_NULL")
    (macro is-blob?::int (n::field-flags) #"IS_BLOB")
    (macro is-num?::int (t::field-type) #"IS_NUM")
    (macro is-num-field?::int
           (f::mysql-field)
           #"IS_NUM_FIELD"))
  (type (coerce
          mysql-row
          bool
          ()
          ((lambda (x)
              (pragma::bool #"($1 != (MYSQL_ROW)0L)" x)))))
  (type (subtype mysql #"MYSQL*" (cobj))
        (coerce cobj mysql () (cobj->mysql))
        (coerce mysql cobj () (mysql->cobj))
        (coerce
          mysql
          bool
          ()
          ((lambda (x) (pragma::bool #"$1 != NULL" x))))
        (subtype bmysql #"obj_t" (obj))
        (coerce obj bmysql () ())
        (coerce bmysql obj () ())
        (coerce bmysql mysql (mysql?) (bmysql->mysql))
        (coerce
          mysql
          obj
          ()
          ((lambda (result)
              (pragma::bmysql
                #"cobj_to_foreign($1, $2)"
                'mysql
                result)))))
  (foreign
    (macro mysql cobj->mysql (cobj) #"(MYSQL*)")
    (macro cobj mysql->cobj (mysql) #"(long)")
    (macro mysql
           bmysql->mysql
           (foreign)
           #"(MYSQL*)FOREIGN_TO_COBJ"))
  (export (mysql?::bool o::obj))
  (type (subtype mysql-res #"MYSQL_RES*" (cobj))
        (coerce cobj mysql-res () (cobj->mysql-res))
        (coerce mysql-res cobj () (mysql-res->cobj))
        (coerce
          mysql-res
          bool
          ()
          ((lambda (x) (pragma::bool #"$1 != NULL" x))))
        (subtype bmysql-res #"obj_t" (obj))
        (coerce obj bmysql-res () ())
        (coerce bmysql-res obj () ())
        (coerce
          bmysql-res
          mysql-res
          (mysql-res?)
          (bmysql-res->mysql-res))
        (coerce
          mysql-res
          obj
          ()
          ((lambda (result)
              (pragma::bmysql-res
                #"cobj_to_foreign($1, $2)"
                'mysql-res
                result)))))
  (foreign
    (macro mysql-res
           cobj->mysql-res
           (cobj)
           #"(MYSQL_RES*)")
    (macro cobj
           mysql-res->cobj
           (mysql-res)
           #"(long)")
    (macro mysql-res
           bmysql-res->mysql-res
           (foreign)
           #"(MYSQL_RES*)FOREIGN_TO_COBJ"))
  (export (mysql-res?::bool o::obj))
  (export
    (mysql-field-name::string o::mysql-field))
  (export
    (mysql-field-table::string o::mysql-field))
  (export (mysql-field-def::string o::mysql-field))
  (export
    (mysql-field-type::field-type o::mysql-field))
  (export
    (mysql-field-length::uint o::mysql-field))
  (export
    (mysql-field-max-length::uint o::mysql-field))
  (export
    (mysql-field-flags::field-flags o::mysql-field))
  (export
    (mysql-field-decimals::uint o::mysql-field))
  (type (subtype mysql-field #"MYSQL_FIELD*" (cobj))
        (coerce cobj mysql-field () (cobj->mysql-field))
        (coerce mysql-field cobj () (mysql-field->cobj))
        (coerce
          mysql-field
          bool
          ()
          ((lambda (x) (pragma::bool #"$1 != NULL" x))))
        (subtype bmysql-field #"obj_t" (obj))
        (coerce obj bmysql-field () ())
        (coerce bmysql-field obj () ())
        (coerce
          bmysql-field
          mysql-field
          (mysql-field?)
          (bmysql-field->mysql-field))
        (coerce
          mysql-field
          obj
          ()
          ((lambda (result)
              (pragma::bmysql-field
                #"cobj_to_foreign($1, $2)"
                'mysql-field
                result)))))
  (foreign
    (macro mysql-field
           cobj->mysql-field
           (cobj)
           #"(MYSQL_FIELD*)")
    (macro cobj
           mysql-field->cobj
           (mysql-field)
           #"(long)")
    (macro mysql-field
           bmysql-field->mysql-field
           (foreign)
           #"(MYSQL_FIELD*)FOREIGN_TO_COBJ"))
  (export (mysql-field?::bool o::obj))
  (type (subtype
          field-type
          #"enum enum_field_types"
          (cobj))
        (coerce cobj field-type () (cobj->field-type))
        (coerce long field-type () (cobj->field-type))
        (coerce short field-type () (cobj->field-type))
        (coerce field-type cobj () ())
        (subtype bfield-type #"obj_t" (obj))
        (coerce obj bfield-type (field-type?) ())
        (coerce bfield-type obj () ())
        (coerce bfield-type bool () ((lambda (x) #t)))
        (coerce
          bfield-type
          field-type
          ()
          (bfield-type->field-type))
        (coerce
          field-type
          bfield-type
          ()
          (field-type->bfield-type))
        (coerce
          symbol
          field-type
          ()
          (bfield-type->field-type))
        (coerce
          field-type
          symbol
          ()
          (field-type->bfield-type)))
  (foreign
    (macro field-type
           cobj->field-type
           (cobj)
           #"(enum enum_field_types)"))
  (export
    (field-type?::bool o::obj)
    (field-type->bfield-type::bfield-type
      o::field-type)
    (bfield-type->field-type::field-type o::obj))
  (type (subtype
          mysql-option
          #"enum mysql_option"
          (cobj))
        (coerce
          cobj
          mysql-option
          ()
          (cobj->mysql-option))
        (coerce
          long
          mysql-option
          ()
          (cobj->mysql-option))
        (coerce
          short
          mysql-option
          ()
          (cobj->mysql-option))
        (coerce mysql-option cobj () ())
        (subtype bmysql-option #"obj_t" (obj))
        (coerce obj bmysql-option (mysql-option?) ())
        (coerce bmysql-option obj () ())
        (coerce bmysql-option bool () ((lambda (x) #t)))
        (coerce
          bmysql-option
          mysql-option
          ()
          (bmysql-option->mysql-option))
        (coerce
          mysql-option
          bmysql-option
          ()
          (mysql-option->bmysql-option))
        (coerce
          symbol
          mysql-option
          ()
          (bmysql-option->mysql-option))
        (coerce
          mysql-option
          symbol
          ()
          (mysql-option->bmysql-option)))
  (foreign
    (macro mysql-option
           cobj->mysql-option
           (cobj)
           #"(enum mysql_option)"))
  (export
    (mysql-option?::bool o::obj)
    (mysql-option->bmysql-option::bmysql-option
      o::mysql-option)
    (bmysql-option->mysql-option::mysql-option
      o::obj))
  (type (subtype field-flags #"uint" (cobj))
        (coerce cobj field-flags () (cobj->field-flags))
        (coerce field-flags cobj () ())
        (subtype bfield-flags #"obj_t" (obj))
        (coerce obj bfield-flags (field-flags?) ())
        (coerce bfield-flags obj () ())
        (coerce bfield-flags bool () ((lambda (x) #t)))
        (coerce
          bfield-flags
          field-flags
          ()
          (bfield-flags->field-flags))
        (coerce
          field-flags
          bfield-flags
          ()
          (field-flags->bfield-flags))
        (coerce
          pair
          field-flags
          ()
          (bfield-flags->field-flags))
        (coerce
          field-flags
          pair
          ()
          (field-flags->bfield-flags))
        (coerce
          pair-nil
          field-flags
          ()
          (bfield-flags->field-flags))
        (coerce bool field-flags () ((lambda (x) 0)))
        (coerce
          field-flags
          pair-nil
          ()
          (field-flags->bfield-flags)))
  (foreign
    (macro field-flags
           cobj->field-flags
           (cobj)
           #"(uint)"))
  (export
    (field-flags?::bool o::obj)
    (bfield-flags->field-flags::field-flags o::obj)
    (field-flags->bfield-flags::bfield-flags
      o::field-flags))
  (export
    (mysql-affected-rows::my-ulonglong
      arg1001::mysql))
  (export (mysql-close arg1002::mysql))
  (export
    (mysql-change-user::my-bool
      arg1003::mysql
      user::const-string
      password::const-string
      db::const-string))
  (export
    (mysql-character-set-name::const-string
      arg1004::mysql))
  (export
    (mysql-data-seek
      result::mysql-res
      offset::my-ulonglong))
  (export (mysql-debug debug::string))
  (export
    (mysql-dump-debug-info::int arg1005::mysql))
  (export (mysql-eof::my-bool result::mysql-res))
  (export (mysql-errno::int arg1006::mysql))
  (export (mysql-error::string arg1007::mysql))
  (export
    (mysql-real-escape-string::int
      arg1008::mysql
      to::string
      from::const-string
      length::uint))
  (export
    (mysql-escape-string::int
      to::string
      from::const-string
      length::uint))
  (export
    (mysql-fetch-field::mysql-field
      result::mysql-res))
  (export
    (mysql-fetch-fields::mysql-field
      result::mysql-res))
  (export
    (mysql-fetch-field-direct::mysql-field
      result::mysql-res
      fieldnr::uint))
  (export
    (mysql-fetch-lengths::ulong-ptr
      result::mysql-res))
  (export
    (mysql-fetch-row::mysql-row result::mysql-res))
  (export (mysql-field-count::uint arg1009::mysql))
  (export
    (mysql-field-seek::mysql-field-offset
      result::mysql-res
      offset::mysql-field-offset))
  (export
    (mysql-field-tell::mysql-field-offset
      result::mysql-res))
  (export (mysql-free-result arg1010::mysql-res))
  (export (mysql-get-client-info::string))
  (export
    (mysql-get-host-info::string arg1011::mysql))
  (export
    (mysql-get-proto-info::uint arg1012::mysql))
  (export
    (mysql-get-server-info::string arg1013::mysql))
  (export (mysql-info::string arg1014::mysql))
  (export (mysql-init::mysql arg1015::mysql))
  (export
    (mysql-insert-id::my-ulonglong arg1016::mysql))
  (export
    (mysql-kill::int arg1017::mysql pid::ulong))
  (export
    (mysql-list-dbs::mysql-res
      arg1018::mysql
      wild::const-string))
  (export
    (mysql-list-fields::mysql-res
      arg1019::mysql
      table::const-string
      wild::const-string))
  (export
    (mysql-list-processes::mysql-res arg1020::mysql))
  (export
    (mysql-list-tables::mysql-res
      arg1021::mysql
      arg1022::const-string))
  (export
    (mysql-num-fields::uint result::mysql-res))
  (export
    (mysql-num-rows::my-ulonglong result::mysql-res))
  (export
    (mysql-options::int
      arg1023::mysql
      options::mysql-option
      args::const-string))
  (export (mysql-ping::int arg1024::mysql))
  (export
    (mysql-query::int
      arg1025::mysql
      query::const-string))
  (export
    (mysql-real-connect::mysql
      arg1026::mysql
      host::const-string
      user::const-string
      passwd::const-string
      db::const-string
      port::uint
      unix-socket::const-string
      client-flag::uint))
  (export
    (mysql-real-query::int
      arg1027::mysql
      query::const-string
      length::uint))
  (export (mysql-reload::int arg1028::mysql))
  (export
    (mysql-row-seek::mysql-row-offset
      result::mysql-res
      offset::mysql-row-offset))
  (export
    (mysql-row-tell::mysql-row-offset
      result::mysql-res))
  (export
    (mysql-select-db::int
      arg1029::mysql
      arg1030::const-string))
  (export (mysql-stat::string arg1031::mysql))
  (export
    (mysql-store-result::mysql-res arg1032::mysql))
  (export (mysql-thread-id::ulong arg1033::mysql))
  (export
    (mysql-use-result::mysql-res arg1034::mysql)))

(define *null-mysql*
  (pragma::mysql #"((MYSQL*)NULL)"))


(define-inline (null-row?::bool row::mysql-row)
  (pragma::bool #"($1 == (MYSQL_ROW*)0L)" row))


(define-inline (null-mysql?::bool mysql::mysql)
  (pragma::bool #"($1 == (MYSQL*)0L)" mysql))


(define-inline (null-result?::bool res::mysql-res)
  (pragma::bool #"($1 == (MYSQL_RES*)0L)" res))


(define-inline (null-field?::bool field::mysql-field)
  (pragma::bool #"($1 == (MYSQL_FIELD*)0L)" field))


(define (mysql?::bool o::obj)
  (and (foreign? o) (eq? (foreign-id o) 'mysql)))


(define (mysql-res?::bool o::obj)
  (and (foreign? o)
       (eq? (foreign-id o) 'mysql-res)))


(define (mysql-field-name::string o::mysql-field)
  (let ((result (pragma::string #"$1->name" o)))
    result))


(define (mysql-field-table::string o::mysql-field)
  (let ((result (pragma::string #"$1->table" o)))
    result))


(define (mysql-field-def::string o::mysql-field)
  (let ((result (pragma::string #"$1->def" o)))
    result))


(define (mysql-field-type::field-type o::mysql-field)
  (let ((result (pragma::field-type #"$1->type" o)))
    result))


(define (mysql-field-length::uint o::mysql-field)
  (let ((result (pragma::uint #"$1->length" o)))
    result))


(define (mysql-field-max-length::uint o::mysql-field)
  (let ((result (pragma::uint #"$1->max_length" o)))
    result))


(define (mysql-field-flags::field-flags o::mysql-field)
  (let ((result (pragma::field-flags #"$1->flags" o)))
    result))


(define (mysql-field-decimals::uint o::mysql-field)
  (let ((result (pragma::uint #"$1->decimals" o)))
    result))


(define (mysql-field?::bool o::obj)
  (and (foreign? o)
       (eq? (foreign-id o) 'mysql-field)))


(define (bfield-type->field-type::field-type o::obj)
  (case o
    ((decimal)
     (pragma::field-type #"FIELD_TYPE_DECIMAL"))
    ((tinyint)
     (pragma::field-type #"FIELD_TYPE_TINY"))
    ((smallint)
     (pragma::field-type #"FIELD_TYPE_SHORT"))
    ((integer)
     (pragma::field-type #"FIELD_TYPE_LONG"))
    ((float)
     (pragma::field-type #"FIELD_TYPE_FLOAT"))
    ((double)
     (pragma::field-type #"FIELD_TYPE_DOUBLE"))
    ((null) (pragma::field-type #"FIELD_TYPE_NULL"))
    ((timestamp)
     (pragma::field-type #"FIELD_TYPE_TIMESTAMP"))
    ((bigint)
     (pragma::field-type #"FIELD_TYPE_LONGLONG"))
    ((mediumint)
     (pragma::field-type #"FIELD_TYPE_INT24"))
    ((date) (pragma::field-type #"FIELD_TYPE_DATE"))
    ((time) (pragma::field-type #"FIELD_TYPE_TIME"))
    ((datetime)
     (pragma::field-type #"FIELD_TYPE_DATETIME"))
    ((year) (pragma::field-type #"FIELD_TYPE_YEAR"))
    ((newdate)
     (pragma::field-type #"FIELD_TYPE_NEWDATE"))
    ((enum) (pragma::field-type #"FIELD_TYPE_ENUM"))
    ((set) (pragma::field-type #"FIELD_TYPE_SET"))
    ((tinyblob)
     (pragma::field-type #"FIELD_TYPE_TINY_BLOB"))
    ((mediumblob)
     (pragma::field-type #"FIELD_TYPE_MEDIUM_BLOB"))
    ((longblob)
     (pragma::field-type #"FIELD_TYPE_LONG_BLOB"))
    ((blob) (pragma::field-type #"FIELD_TYPE_BLOB"))
    ((varstring)
     (pragma::field-type #"FIELD_TYPE_VAR_STRING"))
    ((varchar)
     (pragma::field-type #"FIELD_TYPE_STRING"))
    (else
     (error #"bfield-type->field-type"
            #"invalid argument, must be integer or one of (decimal tinyint smallint integer float double null timestamp bigint mediumint date time datetime year newdate enum set tinyblob mediumblob longblob blob varstring varchar): "
            o))))


(define (field-type->bfield-type::bfield-type
         o::field-type)
  (let ((res (pragma #"BUNSPEC")))
    (pragma
      #"switch($1) { case FIELD_TYPE_STRING: $2 = $25; break;\ncase FIELD_TYPE_VAR_STRING: $2 = $24; break;\ncase FIELD_TYPE_BLOB: $2 = $23; break;\ncase FIELD_TYPE_LONG_BLOB: $2 = $22; break;\ncase FIELD_TYPE_MEDIUM_BLOB: $2 = $21; break;\ncase FIELD_TYPE_TINY_BLOB: $2 = $20; break;\ncase FIELD_TYPE_SET: $2 = $19; break;\ncase FIELD_TYPE_ENUM: $2 = $18; break;\ncase FIELD_TYPE_NEWDATE: $2 = $17; break;\ncase FIELD_TYPE_YEAR: $2 = $16; break;\ncase FIELD_TYPE_DATETIME: $2 = $15; break;\ncase FIELD_TYPE_TIME: $2 = $14; break;\ncase FIELD_TYPE_DATE: $2 = $13; break;\ncase FIELD_TYPE_INT24: $2 = $12; break;\ncase FIELD_TYPE_LONGLONG: $2 = $11; break;\ncase FIELD_TYPE_TIMESTAMP: $2 = $10; break;\ncase FIELD_TYPE_NULL: $2 = $9; break;\ncase FIELD_TYPE_DOUBLE: $2 = $8; break;\ncase FIELD_TYPE_FLOAT: $2 = $7; break;\ncase FIELD_TYPE_LONG: $2 = $6; break;\ncase FIELD_TYPE_SHORT: $2 = $5; break;\ncase FIELD_TYPE_TINY: $2 = $4; break;\ncase FIELD_TYPE_DECIMAL: $2 = $3; break;\ndefault: $2 = BINT($1);}"
      o
      res
      'decimal
      'tinyint
      'smallint
      'integer
      'float
      'double
      'null
      'timestamp
      'bigint
      'mediumint
      'date
      'time
      'datetime
      'year
      'newdate
      'enum
      'set
      'tinyblob
      'mediumblob
      'longblob
      'blob
      'varstring
      'varchar)
    (pragma::bfield-type #"$1" res)))


(define (field-type?::bool o::obj)
  (memq o
        '(decimal
           tinyint
           smallint
           integer
           float
           double
           null
           timestamp
           bigint
           mediumint
           date
           time
           datetime
           year
           newdate
           enum
           set
           tinyblob
           mediumblob
           longblob
           blob
           varstring
           varchar)))


(define (bmysql-option->mysql-option::mysql-option
         o::obj)
  (case o
    ((connect-timeout)
     (pragma::mysql-option
       #"MYSQL_OPT_CONNECT_TIMEOUT"))
    ((compress)
     (pragma::mysql-option #"MYSQL_OPT_COMPRESS"))
    ((named-pipe)
     (pragma::mysql-option #"MYSQL_OPT_NAMED_PIPE"))
    ((init-command)
     (pragma::mysql-option #"MYSQL_INIT_COMMAND"))
    ((read-default-file)
     (pragma::mysql-option #"MYSQL_READ_DEFAULT_FILE"))
    ((read-default-group)
     (pragma::mysql-option
       #"MYSQL_READ_DEFAULT_GROUP"))
    ((set-charset-dir)
     (pragma::mysql-option #"MYSQL_SET_CHARSET_DIR"))
    ((set-charset-name)
     (pragma::mysql-option #"MYSQL_SET_CHARSET_NAME"))
    ((local-infile)
     (pragma::mysql-option #"MYSQL_OPT_LOCAL_INFILE"))
    (else
     (error #"bmysql-option->mysql-option"
            #"invalid argument, must be integer or one of (connect-timeout compress named-pipe init-command read-default-file read-default-group set-charset-dir set-charset-name local-infile): "
            o))))


(define (mysql-option->bmysql-option::bmysql-option
         o::mysql-option)
  (let ((res (pragma #"BUNSPEC")))
    (pragma
      #"switch($1) { case MYSQL_OPT_LOCAL_INFILE: $2 = $11; break;\ncase MYSQL_SET_CHARSET_NAME: $2 = $10; break;\ncase MYSQL_SET_CHARSET_DIR: $2 = $9; break;\ncase MYSQL_READ_DEFAULT_GROUP: $2 = $8; break;\ncase MYSQL_READ_DEFAULT_FILE: $2 = $7; break;\ncase MYSQL_INIT_COMMAND: $2 = $6; break;\ncase MYSQL_OPT_NAMED_PIPE: $2 = $5; break;\ncase MYSQL_OPT_COMPRESS: $2 = $4; break;\ncase MYSQL_OPT_CONNECT_TIMEOUT: $2 = $3; break;\ndefault: $2 = BINT($1);}"
      o
      res
      'connect-timeout
      'compress
      'named-pipe
      'init-command
      'read-default-file
      'read-default-group
      'set-charset-dir
      'set-charset-name
      'local-infile)
    (pragma::bmysql-option #"$1" res)))


(define (mysql-option?::bool o::obj)
  (memq o
        '(connect-timeout
           compress
           named-pipe
           init-command
           read-default-file
           read-default-group
           set-charset-dir
           set-charset-name
           local-infile)))


(define (bfield-flags->field-flags::field-flags o::obj)
  (let ((res::int 0))
    (for-each
      (lambda (o)
         (case o
           ((not-null)
            (set! res
              (bit-or res (pragma::int #"NOT_NULL_FLAG"))))
           ((primary-key)
            (set! res
              (bit-or res (pragma::int #"PRI_KEY_FLAG"))))
           ((unique-key)
            (set! res
              (bit-or res (pragma::int #"UNIQUE_KEY_FLAG"))))
           ((multiple-key)
            (set! res
              (bit-or res (pragma::int #"MULTIPLE_KEY_FLAG"))))
           ((unsigned)
            (set! res
              (bit-or res (pragma::int #"UNSIGNED_FLAG"))))
           ((zero-fill)
            (set! res
              (bit-or res (pragma::int #"ZEROFILL_FLAG"))))
           ((binary)
            (set! res
              (bit-or res (pragma::int #"BINARY_FLAG"))))
           ((auto-increment)
            (set! res
              (bit-or res (pragma::int #"AUTO_INCREMENT_FLAG"))))
           ((enum)
            (set! res
              (bit-or res (pragma::int #"ENUM_FLAG"))))
           ((blob)
            (set! res
              (bit-or res (pragma::int #"BLOB_FLAG"))))
           ((timestamp)
            (set! res
              (bit-or res (pragma::int #"TIMESTAMP_FLAG"))))
           (else
            (error #"bfield-flags->field-flags"
                   #"invalid argument, must be one of (not-null primary-key unique-key multiple-key unsigned zero-fill binary auto-increment enum blob timestamp): "
                   o))))
      o)
    (let ((res::int res))
      (pragma::field-flags #"$1" res))))


(define (field-flags->bfield-flags::bfield-flags
         o::field-flags)
  (let ((res '()))
    (when (pragma::bool
            #"($1 & NOT_NULL_FLAG) == NOT_NULL_FLAG"
            o)
          (set! res (cons 'not-null res)))
    (when (pragma::bool
            #"($1 & PRI_KEY_FLAG) == PRI_KEY_FLAG"
            o)
          (set! res (cons 'primary-key res)))
    (when (pragma::bool
            #"($1 & UNIQUE_KEY_FLAG) == UNIQUE_KEY_FLAG"
            o)
          (set! res (cons 'unique-key res)))
    (when (pragma::bool
            #"($1 & MULTIPLE_KEY_FLAG) == MULTIPLE_KEY_FLAG"
            o)
          (set! res (cons 'multiple-key res)))
    (when (pragma::bool
            #"($1 & UNSIGNED_FLAG) == UNSIGNED_FLAG"
            o)
          (set! res (cons 'unsigned res)))
    (when (pragma::bool
            #"($1 & ZEROFILL_FLAG) == ZEROFILL_FLAG"
            o)
          (set! res (cons 'zero-fill res)))
    (when (pragma::bool
            #"($1 & BINARY_FLAG) == BINARY_FLAG"
            o)
          (set! res (cons 'binary res)))
    (when (pragma::bool
            #"($1 & AUTO_INCREMENT_FLAG) == AUTO_INCREMENT_FLAG"
            o)
          (set! res (cons 'auto-increment res)))
    (when (pragma::bool #"($1 & ENUM_FLAG) == ENUM_FLAG" o)
          (set! res (cons 'enum res)))
    (when (pragma::bool #"($1 & BLOB_FLAG) == BLOB_FLAG" o)
          (set! res (cons 'blob res)))
    (when (pragma::bool
            #"($1 & TIMESTAMP_FLAG) == TIMESTAMP_FLAG"
            o)
          (set! res (cons 'timestamp res)))
    res))


(define (field-flags?::bool o::obj)
  (and (list? o)
       (null? (lset-difference
                eq?
                o
                '(not-null
                   primary-key
                   unique-key
                   multiple-key
                   unsigned
                   zero-fill
                   binary
                   auto-increment
                   enum
                   blob
                   timestamp)))))


(define (mysql-affected-rows::my-ulonglong
         arg1001::mysql)
  (let ((arg1001::mysql arg1001))
    (pragma::my-ulonglong
      #"mysql_affected_rows($1)"
      arg1001)))


(define (mysql-close arg1002::mysql)
  (let ((arg1002::mysql arg1002))
    (pragma #"mysql_close($1)" arg1002)
    #unspecified))


(define (mysql-change-user::my-bool
         arg1003::mysql
         user::const-string
         password::const-string
         db::const-string)
  (let ((arg1003::mysql arg1003)
        (user::const-string user)
        (password::const-string password)
        (db::const-string db))
    (pragma::my-bool
      #"mysql_change_user($1, $2, $3, $4)"
      arg1003
      user
      password
      db)))


(define (mysql-character-set-name::const-string
         arg1004::mysql)
  (let ((arg1004::mysql arg1004))
    (pragma::const-string
      #"mysql_character_set_name($1)"
      arg1004)))


(define (mysql-data-seek
         result::mysql-res
         offset::my-ulonglong)
  (let ((result::mysql-res result)
        (offset::my-ulonglong offset))
    (pragma #"mysql_data_seek($1, $2)" result offset)
    #unspecified))


(define (mysql-debug debug::string)
  (let ((debug::string debug))
    (pragma #"mysql_debug($1)" debug)
    #unspecified))


(define (mysql-dump-debug-info::int arg1005::mysql)
  (let ((arg1005::mysql arg1005))
    (pragma::int
      #"mysql_dump_debug_info($1)"
      arg1005)))


(define (mysql-eof::my-bool result::mysql-res)
  (let ((result::mysql-res result))
    (pragma::my-bool #"mysql_eof($1)" result)))


(define (mysql-errno::int arg1006::mysql)
  (let ((arg1006::mysql arg1006))
    (pragma::int #"mysql_errno($1)" arg1006)))


(define (mysql-error::string arg1007::mysql)
  (let ((arg1007::mysql arg1007))
    (pragma::string #"mysql_error($1)" arg1007)))


(define (mysql-real-escape-string::int
         arg1008::mysql
         to::string
         from::const-string
         length::uint)
  (let ((arg1008::mysql arg1008)
        (to::string to)
        (from::const-string from)
        (length::uint length))
    (pragma::int
      #"mysql_real_escape_string($1, $2, $3, $4)"
      arg1008
      to
      from
      length)))


(define (mysql-escape-string::int
         to::string
         from::const-string
         length::uint)
  (let ((to::string to)
        (from::const-string from)
        (length::uint length))
    (pragma::int
      #"mysql_escape_string($1, $2, $3)"
      to
      from
      length)))


(define (mysql-fetch-field::mysql-field
         result::mysql-res)
  (let ((result::mysql-res result))
    (pragma::mysql-field
      #"mysql_fetch_field($1)"
      result)))


(define (mysql-fetch-fields::mysql-field
         result::mysql-res)
  (let ((result::mysql-res result))
    (pragma::mysql-field
      #"mysql_fetch_fields($1)"
      result)))


(define (mysql-fetch-field-direct::mysql-field
         result::mysql-res
         fieldnr::uint)
  (let ((result::mysql-res result)
        (fieldnr::uint fieldnr))
    (pragma::mysql-field
      #"mysql_fetch_field_direct($1, $2)"
      result
      fieldnr)))


(define (mysql-fetch-lengths::ulong-ptr
         result::mysql-res)
  (let ((result::mysql-res result))
    (pragma::ulong-ptr
      #"mysql_fetch_lengths($1)"
      result)))


(define (mysql-fetch-row::mysql-row result::mysql-res)
  (let ((result::mysql-res result))
    (pragma::mysql-row #"mysql_fetch_row($1)" result)))


(define (mysql-field-count::uint arg1009::mysql)
  (let ((arg1009::mysql arg1009))
    (pragma::uint #"mysql_field_count($1)" arg1009)))


(define (mysql-field-seek::mysql-field-offset
         result::mysql-res
         offset::mysql-field-offset)
  (let ((result::mysql-res result)
        (offset::mysql-field-offset offset))
    (pragma::mysql-field-offset
      #"mysql_field_seek($1, $2)"
      result
      offset)))


(define (mysql-field-tell::mysql-field-offset
         result::mysql-res)
  (let ((result::mysql-res result))
    (pragma::mysql-field-offset
      #"mysql_field_tell($1)"
      result)))


(define (mysql-free-result arg1010::mysql-res)
  (let ((arg1010::mysql-res arg1010))
    (pragma #"mysql_free_result($1)" arg1010)
    #unspecified))


(define (mysql-get-client-info::string)
  (let ()
    (pragma::string #"mysql_get_client_info()")))


(define (mysql-get-host-info::string arg1011::mysql)
  (let ((arg1011::mysql arg1011))
    (pragma::string
      #"mysql_get_host_info($1)"
      arg1011)))


(define (mysql-get-proto-info::uint arg1012::mysql)
  (let ((arg1012::mysql arg1012))
    (pragma::uint
      #"mysql_get_proto_info($1)"
      arg1012)))


(define (mysql-get-server-info::string arg1013::mysql)
  (let ((arg1013::mysql arg1013))
    (pragma::string
      #"mysql_get_server_info($1)"
      arg1013)))


(define (mysql-info::string arg1014::mysql)
  (let ((arg1014::mysql arg1014))
    (pragma::string #"mysql_info($1)" arg1014)))


(define (mysql-init::mysql arg1015::mysql)
  (let ((arg1015::mysql arg1015))
    (pragma::mysql #"mysql_init($1)" arg1015)))


(define (mysql-insert-id::my-ulonglong arg1016::mysql)
  (let ((arg1016::mysql arg1016))
    (pragma::my-ulonglong
      #"mysql_insert_id($1)"
      arg1016)))


(define (mysql-kill::int arg1017::mysql pid::ulong)
  (let ((arg1017::mysql arg1017) (pid::ulong pid))
    (pragma::int #"mysql_kill($1, $2)" arg1017 pid)))


(define (mysql-list-dbs::mysql-res
         arg1018::mysql
         wild::const-string)
  (let ((arg1018::mysql arg1018)
        (wild::const-string wild))
    (pragma::mysql-res
      #"mysql_list_dbs($1, $2)"
      arg1018
      wild)))


(define (mysql-list-fields::mysql-res
         arg1019::mysql
         table::const-string
         wild::const-string)
  (let ((arg1019::mysql arg1019)
        (table::const-string table)
        (wild::const-string wild))
    (pragma::mysql-res
      #"mysql_list_fields($1, $2, $3)"
      arg1019
      table
      wild)))


(define (mysql-list-processes::mysql-res arg1020::mysql)
  (let ((arg1020::mysql arg1020))
    (pragma::mysql-res
      #"mysql_list_processes($1)"
      arg1020)))


(define (mysql-list-tables::mysql-res
         arg1021::mysql
         arg1022::const-string)
  (let ((arg1021::mysql arg1021)
        (arg1022::const-string arg1022))
    (pragma::mysql-res
      #"mysql_list_tables($1, $2)"
      arg1021
      arg1022)))


(define (mysql-num-fields::uint result::mysql-res)
  (let ((result::mysql-res result))
    (pragma::uint #"mysql_num_fields($1)" result)))


(define (mysql-num-rows::my-ulonglong result::mysql-res)
  (let ((result::mysql-res result))
    (pragma::my-ulonglong
      #"mysql_num_rows($1)"
      result)))


(define (mysql-options::int
         arg1023::mysql
         options::mysql-option
         args::const-string)
  (let ((arg1023::mysql arg1023)
        (options::mysql-option options)
        (args::const-string args))
    (pragma::int
      #"mysql_options($1, $2, $3)"
      arg1023
      options
      args)))


(define (mysql-ping::int arg1024::mysql)
  (let ((arg1024::mysql arg1024))
    (pragma::int #"mysql_ping($1)" arg1024)))


(define (mysql-query::int
         arg1025::mysql
         query::const-string)
  (let ((arg1025::mysql arg1025)
        (query::const-string query))
    (pragma::int
      #"mysql_query($1, $2)"
      arg1025
      query)))


(define (mysql-real-connect::mysql
         arg1026::mysql
         host::const-string
         user::const-string
         passwd::const-string
         db::const-string
         port::uint
         unix-socket::const-string
         client-flag::uint)
  (let ((arg1026::mysql arg1026)
        (host::const-string host)
        (user::const-string user)
        (passwd::const-string passwd)
        (db::const-string db)
        (port::uint port)
        (unix-socket::const-string unix-socket)
        (client-flag::uint client-flag))
    (pragma::mysql
      #"mysql_real_connect($1, $2, $3, $4, $5, $6, $7, $8)"
      arg1026
      host
      user
      passwd
      db
      port
      unix-socket
      client-flag)))


(define (mysql-real-query::int
         arg1027::mysql
         query::const-string
         length::uint)
  (let ((arg1027::mysql arg1027)
        (query::const-string query)
        (length::uint length))
    (pragma::int
      #"mysql_real_query($1, $2, $3)"
      arg1027
      query
      length)))


(define (mysql-reload::int arg1028::mysql)
  (let ((arg1028::mysql arg1028))
    (pragma::int #"mysql_reload($1)" arg1028)))


(define (mysql-row-seek::mysql-row-offset
         result::mysql-res
         offset::mysql-row-offset)
  (let ((result::mysql-res result)
        (offset::mysql-row-offset offset))
    (pragma::mysql-row-offset
      #"mysql_row_seek($1, $2)"
      result
      offset)))


(define (mysql-row-tell::mysql-row-offset
         result::mysql-res)
  (let ((result::mysql-res result))
    (pragma::mysql-row-offset
      #"mysql_row_tell($1)"
      result)))


(define (mysql-select-db::int
         arg1029::mysql
         arg1030::const-string)
  (let ((arg1029::mysql arg1029)
        (arg1030::const-string arg1030))
    (pragma::int
      #"mysql_select_db($1, $2)"
      arg1029
      arg1030)))


(define (mysql-stat::string arg1031::mysql)
  (let ((arg1031::mysql arg1031))
    (pragma::string #"mysql_stat($1)" arg1031)))


(define (mysql-store-result::mysql-res arg1032::mysql)
  (let ((arg1032::mysql arg1032))
    (pragma::mysql-res
      #"mysql_store_result($1)"
      arg1032)))


(define (mysql-thread-id::ulong arg1033::mysql)
  (let ((arg1033::mysql arg1033))
    (pragma::ulong #"mysql_thread_id($1)" arg1033)))


(define (mysql-use-result::mysql-res arg1034::mysql)
  (let ((arg1034::mysql arg1034))
    (pragma::mysql-res
      #"mysql_use_result($1)"
      arg1034)))


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

(module php-odbc-lib
   (include "../phpoo-extension.sch")
   (library profiler)
   (import (odbc-c-bindings "odbc-bindings.scm"))
   (export

   ODBC_TYPE
   ODBC_BINMODE_PASSTHRU
   ODBC_BINMODE_RETURN
   ODBC_BINMODE_CONVERT
   SQL_CUR_USE_IF_NEEDED
   SQL_CUR_USE_ODBC     
   SQL_CUR_USE_DRIVER   
   SQL_CUR_DEFAULT      
   SQL_ODBC_CURSORS    
   SQL_CONCURRENCY 
   SQL_CONCUR_READ_ONLY
   SQL_CONCUR_LOCK 
   SQL_CONCUR_ROWVER
   SQL_CONCUR_VALUES
   SQL_CURSOR_TYPE 
   SQL_CURSOR_FORWARD_ONLY
   SQL_CURSOR_KEYSET_DRIVEN
   SQL_CURSOR_DYNAMIC 
   SQL_CURSOR_STATIC 
   SQL_KEYSET_SIZE
   SQL_FETCH_FIRST
   SQL_FETCH_NEXT
   SQL_CHAR
   SQL_VARCHAR
   SQL_LONGVARCHAR
   SQL_DECIMAL 
   SQL_NUMERIC 
   SQL_BIT 
   SQL_TINYINT
   SQL_SMALLINT 
   SQL_INTEGER 
   SQL_BIGINT 
   SQL_REAL 
   SQL_FLOAT 
   SQL_DOUBLE 
   SQL_BINARY 
   SQL_VARBINARY 
   SQL_LONGVARBINARY 
   SQL_DATE
   SQL_TIME 
   SQL_TIMESTAMP 
   SQL_TYPE_DATE 
   SQL_TYPE_TIME 
   SQL_TYPE_TIMESTAMP 
   SQL_BEST_ROWID 
   SQL_ROWVER 
   SQL_SCOPE_CURROW 
   SQL_SCOPE_TRANSACTION
   SQL_SCOPE_SESSION 
   SQL_NO_NULLS 
   SQL_NULLABLE
   
   (init-php-odbc-lib)

   (odbc_autocommit id onoff)
   (odbc_binmode result val)
   (odbc_columnprivileges id qualifier owner table column)
   (odbc_columns id qualifier owner table column)
   (odbc_commit id)
   (odbc_connect dsn user password cursor-type)
   (odbc_close id)
   (odbc_close_all)
   (odbc_cursor result)
   (odbc_data_source id ftype)
   (odbc_error id)   
   (odbc_errormsg id)
   (odbc_exec id query flags)
   (odbc_execute result params)
   (odbc_fetch_array result row)
   (odbc_fetch_into result array row)
   (odbc_fetch_object result row)   
   (odbc_fetch_row result row)
   (odbc_field_len result col)
   (odbc_field_name result col)
   (odbc_field_num result colname)   
   (odbc_field_scale result col)
   (odbc_field_type result col)
   (odbc_foreignkeys id qualifier owner table fk-qualifier fk-owner fk-table)
   (odbc_free_result result)
   (odbc_gettypeinfo id type)
   (odbc_longreadlen result val)
   (odbc_num_fields result)
   (odbc_num_rows result)
   (odbc_prepare id query)
   (odbc_primarykeys id qualifier owner table)   
   (odbc_result result col)
   (odbc_rollback id)
   (odbc_specialcolumns id type qualifier owner table scope nullable)   
   (odbc_statistics id qualifier owner table-name unique accuracy)   
   (odbc_tableprivileges id qualifier owner name)
   (odbc_tables id qualifier owner name types)

    ))

(define (init-php-odbc-lib)
   1)

; register the extension
(register-extension "odbc" "1.0.0" "php-odbc")

(defresource odbc-link "odbc link"
   env        ; handle to odbc environment
   dbc        ; handle to connection (hdbc)
   last-error ; string containing last error message that occured
   last-state ; string containing last SQL state
   state
   active-result)

(define (make-new-odbc-link)
   (odbc-link-resource SQL_NULL_HENV
		       SQL_NULL_HDBC
		       ""
		       ""
		       'dead
		       #f))

(defresource odbc-result "odbc result"
   stmt       ; handle to statement (hstmt)
   my-link    ; our odbc-link
   sql
   num-cols
   cols       ; vector of result-val structure below
   bin-mode
   lrl        ; long read length
   num-fetched
   num-params 
   fetch-abs? ; can we fetch absolute?
   freed?)

(define (active-result? result)
   (and (odbc-result? result)
	(not (odbc-result-freed? result))))

(define *default-bin-mode* #f)
(define *default-lrl* #f)
(define (new-odbc-result link)
   (let ((new-result (odbc-result-resource SQL_NULL_HSTMT
					   link
					   ""
					   0
					   #f
					   1
					   4096
					   0
					   0
					   #f
					   #f)))
      (odbc-result-bin-mode-set! new-result (or *default-bin-mode*
						(get-ini-entry "odbc.defaultbinmode")))
      (odbc-result-lrl-set! new-result (or *default-lrl*
					   (get-ini-entry "odbc.defaultlrl")))
      new-result))

(define *odbc-result-counter* 0)
(define (make-new-odbc-result link)
   (when (> *odbc-result-counter* 255) ; ARB
;      (debug-trace 3 "forcing cleanup of odbc results")
      (gc-force-finalization (lambda () (<= *odbc-result-counter* 255))))
   (let ((result (new-odbc-result link)))
      (set! *odbc-result-counter* (+ *odbc-result-counter* 1))
      (register-finalizer! result (lambda (result)
				     (unless (odbc-result-freed? result)
					; odbc-free-result will lower the counter
					(odbc-free-result result))))
      result))

(define (odbc-free-result result)
;   (debug-trace 3 "cleaning odbc result")
   ; free handle
   (SQLFreeHandle SQL_HANDLE_STMT (odbc-result-stmt result))
   (odbc-result-freed?-set! result #t)
   (set! *odbc-result-counter* (- *odbc-result-counter* 1)))

(define-struct bind-param (val "") (len 0))

(default-ini-entry "odbc.max_links"      -1)
(default-ini-entry "odbc.defaultbinmode" 1)
(default-ini-entry "odbc.defaultlrl"     4096)

(define *odbc-last-error* "")
(define *odbc-last-state* "")

; these are only used internally, not in PHP land

; handle types
(define SQL_HANDLE_ENV        (pragma::SQLSMALLINT "SQL_HANDLE_ENV"))
(define SQL_HANDLE_DBC        (pragma::SQLSMALLINT "SQL_HANDLE_DBC"))
(define SQL_HANDLE_STMT       (pragma::SQLSMALLINT "SQL_HANDLE_STMT"))

; null handles
(define SQL_NULL_HANDLE       (pragma::SQLHANDLE   "SQL_NULL_HANDLE"))
(define SQL_NULL_HDBC         (pragma::SQLHANDLE   "SQL_NULL_HDBC"))
(define SQL_NULL_HENV         (pragma::SQLHANDLE   "SQL_NULL_HENV"))
(define SQL_NULL_HSTMT        (pragma::SQLHANDLE   "SQL_NULL_HSTMT"))

; return values
(define SQL_ERROR             (pragma::SQLRETURN   "SQL_ERROR"))
(define SQL_SUCCESS           (pragma::SQLRETURN   "SQL_SUCCESS"))
(define SQL_SUCCESS_WITH_INFO (pragma::SQLRETURN   "SQL_SUCCESS_WITH_INFO"))
(define SQL_NO_DATA_FOUND     (pragma::SQLRETURN   "SQL_NO_DATA_FOUND"))

(define SQL_NULL_DATA         (pragma::SQLINTEGER  "SQL_NULL_DATA"))

; function options
(define SQL_NTS                (pragma::SQLSMALLINT  "SQL_NTS"))
(define SQL_C_CHAR             (pragma::SQLSMALLINT  "SQL_C_CHAR"))
(define SQL_C_BINARY           (pragma::SQLSMALLINT  "SQL_C_BINARY"))
(define SQL_ATTR_ODBC_VERSION  (pragma::SQLINTEGER   "SQL_ATTR_ODBC_VERSION"))
(define SQL_OV_ODBC3           (pragma::SQLPOINTER   "(void *)SQL_OV_ODBC3"))
(define SQL_CLOSE              (pragma::SQLUSMALLINT "SQL_CLOSE"))
(define SQL_RESET_PARAMS       (pragma::SQLUSMALLINT "SQL_RESET_PARAMS"))
(define SQL_FETCH_DIRECTION    (pragma::SQLUSMALLINT "SQL_FETCH_DIRECTION"))
(define SQL_FD_FETCH_ABSOLUTE  (pragma::SQLUINTEGER  "SQL_FD_FETCH_ABSOLUTE"))
(define SQL_FETCH_ABSOLUTE     (pragma::SQLUSMALLINT "SQL_FETCH_ABSOLUTE"))
(define SQL_DESC_NAME          (pragma::SQLUSMALLINT "SQL_DESC_NAME"))
(define SQL_DESC_TYPE          (pragma::SQLUSMALLINT "SQL_DESC_TYPE"))
(define SQL_DESC_DISPLAY_SIZE  (pragma::SQLUSMALLINT "SQL_DESC_DISPLAY_SIZE"))

(define (bstring->sqlstring str)
   (pragma::SQLCHAR* "(SQLCHAR*)$1" ($bstring->string str)))

(define (fixnum->sqlinteger num)
   (pragma::SQLINTEGER "(SQLINTEGER)$1" (mkfixnum num)))

(define (fixnum->sqluinteger num)
   (pragma::SQLUINTEGER "(SQLUINTEGER)$1" (mkfixnum num)))

(define (unpassed? var)
   (eqv? var 'unpassed))

(define (passed? var)
   (not (unpassed? var)))


;;;Exit Function

;cleanup function to close any remaining open connections
(register-exit-function!
  (lambda (status)
     (odbc_close_all)
     status))
 
;Ensure that we have a link, or throw an error.  The benefactor is the
;function to name in the error.  The link is the name of the variable
;that should contain the link.  It will only be changed if it's eqv to
;'unpassed.
(define (ensure-link benefactor link)
;    (when (eqv? link 'unpassed)
;       (let ((last-link (fetch-last-link)))
;  	 (if last-link
;  	     (set! link last-link)
;  	     (set! link (establish-default-link)))))
   (if (odbc-link? link)
       link
       (begin
 	  ; remember kids, this might return if *disable-errors* was true!
 	  (php-warning (format "~a(): supplied argument is not a valid ODBC link resource" benefactor)))))


(define (odbc-error env-handle::SQLHANDLE dbc-handle::SQLHANDLE stmt-handle::SQLHANDLE)
   (let ((htype '())
	 (hand '()))
      (cond ((pragma::bool "($1 == SQL_NULL_HANDLE) && ($2 == SQL_NULL_HANDLE)" dbc-handle stmt-handle)
	     (begin
		(set! htype SQL_HANDLE_ENV)
		(set! hand env-handle)))
	    ((pragma::bool "($1 == SQL_NULL_HANDLE)" stmt-handle)
	     (begin
		(set! htype SQL_HANDLE_DBC)
		(set! hand dbc-handle)))
	    (else
	     (begin
		(set! htype SQL_HANDLE_STMT)
		(set! hand stmt-handle))))
      (let* ((epair (get-odbc-errormsg hand htype))
	     (msg (if (pair? epair) (car epair) #f))
	     (state (if (pair? epair) (cdr epair) #f)))
;	 (print (format "epair is ~a" epair))
	 (if msg
	     (begin
		(set! *odbc-last-error* msg)
		(set! *odbc-last-state* state)
		epair)
	     #f))))

; functions with only a link call this on error
(define (odbc-do-link-error php-func sql-func link)
   (let* ((epair (odbc-error (odbc-link-env link)
			     (odbc-link-dbc link)
			     SQL_NULL_HSTMT))
	  (msg (if (pair? epair) (car epair) #f))
	  (state (if (pair? epair) (cdr epair) #f)))
;	 (print (format "epair is ~a" epair))      
      (when msg
	 (odbc-link-last-error-set! link msg)
	 (odbc-link-last-state-set! link state)
	 (php-warning (format "~a(): SQL error: ~a, SQL state is ~a in ~a" php-func msg state sql-func)))
      #f))

; functions with a result call this on error
(define (odbc-do-stmt-error php-func sql-func result)   
   (let* ((link (odbc-result-my-link result))
	  (epair (odbc-error (odbc-link-env link)
			     (odbc-link-dbc link)			   
			     (odbc-result-stmt result)))
	  (msg (if (pair? epair) (car epair) #f))
	  (state (if (pair? epair) (cdr epair) #f)))
;	 (print (format "epair is ~a" epair))            
      (when msg
	 (odbc-link-last-error-set! link msg)
	 (odbc-link-last-state-set! link state)
	 (php-warning (format "~a(): SQL error: ~a, SQL state is ~a in ~a" php-func msg state sql-func)))
      #f))

(define (alloc-odbc-handle env-handle::SQLHANDLE dbc-handle::SQLHANDLE new-handle::SQLHANDLE handle-type::SQLSMALLINT)
   (let ((retval (SQLAllocHandle handle-type
				 (if (pragma::bool "($1 == SQL_NULL_HANDLE)" dbc-handle)
				     env-handle
				     dbc-handle)
				 (pragma::SQLHANDLE* "&$1" new-handle))))
      (if (or (= retval SQL_SUCCESS)
	      (= retval SQL_SUCCESS_WITH_INFO))
	  new-handle
	  (begin
	     (debug-trace 1 (format "SQLAllocHandle failed: ~a" retval))
	     (odbc-error env-handle dbc-handle SQL_NULL_HSTMT)
	     #f))))

; make an actual db connection call, returning result of SQLConnect
; or SQLDriverConnect (no error handling here)
(define (make-odbc-connection dbc dsn user password)
   (if (pregexp-match ";" dsn)
       (let ((buf (make-string 1024))
	     (dbuflen 0)
	     (rdsn (mkstr dsn)))
	  (SQLDriverConnect dbc
			    (pragma::SQLHWND "NULL")
			    (bstring->sqlstring rdsn)
			    (pragma::SQLSMALLINT "$1" (string-length rdsn))
			    (bstring->sqlstring buf)
			    (pragma::SQLSMALLINT "1023")
			    (pragma::SQLSMALLINT* "&$1" dbuflen)
			    (pragma::SQLUSMALLINT "SQL_DRIVER_NOPROMPT")))
       ; normal connect       
       (SQLConnect dbc
		   (bstring->sqlstring (mkstr dsn))
		   SQL_NTS
		   (bstring->sqlstring (mkstr user))
		   SQL_NTS
		   (bstring->sqlstring (mkstr password))
		   SQL_NTS)))

(define (dump-result-val func n rval::result-val*)
   (pragma "fprintf(stderr, \"result-val [%s]: col #%d %s has a val at: %x (%s) len at %x (%d)\\n\", $1, $2, $3->name, $4->val, $5->val, &$6->len, $7->len);"
	   ($bstring->string func)
	   (mkfixnum n)
	   rval
	   rval
	   rval
	   rval
	   rval))

(define (dump-results func result)
   (let loop ((n 0))
      (when (< n (odbc-result-num-cols result))
	 (dump-result-val func n (vector-ref (odbc-result-cols result) n))
	 (loop (+ n 1)))))

(define *col-name-size* 64)
(define (bind-result-cols caller result)
   (bind-exit (return)
   ; bind columns for a result resource
   (odbc-result-cols-set! result (make-vector (odbc-result-num-cols result)))
   (let loop ((n 0))
      (when (< n (odbc-result-num-cols result))
	 (let ((new-col (result-val* "" 0 "" 0))
	       (name (make-string *col-name-size*))
	       (name-len::SDWORD 0)
	       (type::SDWORD 0))
	    ; name
	    (SQLColAttribute (odbc-result-stmt result)
			     (pragma::SQLUSMALLINT "$1" (+ n 1)) ; col #, 1 based
			     SQL_DESC_NAME
			     (pragma::SQLPOINTER "$1" (bstring->sqlstring name))
			     (pragma::SQLSMALLINT "$1" *col-name-size*)
			     (pragma::SQLSMALLINT* "&$1" name-len)
			     (pragma::SQLPOINTER "NULL"))
	    (result-val*-name-set! new-col (substring name 0 name-len))
	    ; type
	    (SQLColAttribute (odbc-result-stmt result)
			     (pragma::SQLUSMALLINT "$1" (+ n 1)) ; col #, 1 based
			     SQL_DESC_TYPE
			     (pragma::SQLPOINTER "NULL")
			     0
			     (pragma::SQLSMALLINT* "NULL")			     
			     (pragma::SQLPOINTER "&$1" type)
			     )
	    (result-val*-coltype-set! new-col type)
	    ;
	    (debug-trace 5 (mkstr "adding col #" n ", name [" (result-val*-name new-col) "] ("
				  (mkfixnum name-len) "), type: " (mkfixnum type)))
	    ;
	    ; bind, if not binary/long
	    (if (long-col-type? type)
		(begin
;		   (debug-trace 5 "skipping bind of long data column " n)
		   (result-val*-val-set! new-col (pragma::string "NULL"))
;		   (dump-result-val "bind-results-col 1" n new-col)
		   )
	       ; need display size first
		(let ((displaysize::SDWORD 0))
		   (SQLColAttribute (odbc-result-stmt result)
				   (pragma::SQLUSMALLINT "$1" (+ n 1)) ; col #, 1 based
				   SQL_DESC_DISPLAY_SIZE
				   (pragma::SQLPOINTER "NULL")
				   0
				   (pragma::SQLSMALLINT* "NULL")
				   (pragma::SQLPOINTER "&$1" displaysize))
;		   (debug-trace 5 "raw displaysize from SQLColAttribute: " displaysize)
		  (when (> displaysize (odbc-result-lrl result))
		     (set! displaysize (odbc-result-lrl result)))
		  (result-val*-val-set! new-col ($bstring->string (make-string (+ displaysize 1))))
; 		  (SQLBindCol (odbc-result-stmt result)
; 			      (pragma::SQLUSMALLINT "$1" (+ n 1)) ; col #, 1 based
; 			      SQL_C_CHAR
; 			      (pragma::SQLPOINTER "$1" (result-val*-val new-col))
; 			      (pragma::SQLINTEGER "$1" (+ displaysize 1))
; 			      (pragma::SQLINTEGER* "&$1->len" new-col))
; 		  (pragma "fprintf(stderr, \"SQLBindCol(%s, %d, SQL_C_CHAR, (SQLPOINTER)%x, %d, %x);\\n\",$1,$2,$3->val,CINT($4),&$5->len)"
; 			  (bstring->string (format "~a" (odbc-result-stmt result)))
; 			  (+ n 1)
; 			  new-col
; 			  (+ displaysize 1)
; 			  new-col)
		  (let ((retval (pragma::SQLRETURN "SQLBindCol(FOREIGN_TO_COBJ($1), $2, SQL_C_CHAR, (SQLPOINTER)$3->val, CINT($4), &$5->len);"
						   (odbc-result-stmt result)
						   (+ n 1)
						   new-col
						   (+ displaysize 1)
						   new-col)))
		     (unless (= retval SQL_SUCCESS)
			(odbc-do-stmt-error caller
					    "SQLBindCol"
					    result)
			(return #f)))
;		  (dump-result-val "bind-results-col 2" n new-col)
		  ))
	    ; add to result resource
	    (vector-set! (odbc-result-cols result) n new-col)
	    (loop (+ n 1)))))
   #t))

; get a column number by it's name
(define (find-col result col-name::string)
   (let loop ((n 0))
      (if (< n (odbc-result-num-cols result))
	  (let ((rval (vector-ref (odbc-result-cols result) n)))
	     (if (string=? (result-val*-name rval) col-name)
		 n
		 (loop (+ n 1))))
	  ; not found
	  #f)))

(define (long-col-type? coltype)
   (or (= coltype SQL_LONGVARBINARY)
       (= coltype SQL_LONGVARCHAR)))

(define (bin-col-type? coltype)
   (or (= coltype SQL_BINARY)
       (= coltype SQL_VARBINARY)
       (= coltype SQL_LONGVARBINARY)))

(define (long-or-bin-col-type? coltype)
   (or (long-col-type? coltype)
       (bin-col-type? coltype)))

; passed a odbc-result and result-val, it pulls data
; with SQLGetData, up to long read len
; n should be 0 based!
(define (get-long-data caller n result)
   (bind-exit (return)
      (let ((rval (vector-ref (odbc-result-cols result) n))
	    (newlen::SQLINTEGER 0)
	    (data '()))
	 ;	 
;	 (dump-result-val "get-long-data" n rval)
	 ;
	 (if (> (odbc-result-lrl result) 0)
	     (begin
;		(debug-trace 0 "get-long-data for col " n ", size of buffer is " (+ (odbc-result-lrl result) 1))
		(set! data (make-string (+ (odbc-result-lrl result) 1)))
; 		(let ((retval (pragma::SQLRETURN "SQLGetData(FOREIGN_TO_COBJ($1), CINT($2), $3, $4, CINT($5), &$6)"
; 						 (odbc-result-stmt result)
; 						 (+ n 1)
; 						 (if (bin-col-type? (result-val*-coltype rval))
; 						     SQL_C_BINARY
; 						     SQL_C_CHAR)
; 						 (bstring->sqlstring data)
; 						 (+ (odbc-result-lrl result) 1)
; 						 newlen)))
		(let ((retval (SQLGetData (odbc-result-stmt result)
					  (pragma::SQLUSMALLINT "CINT($1)" (+ n 1)) ; col #, 1 based
					  (if (bin-col-type? (result-val*-coltype rval))
					      SQL_C_BINARY
					      SQL_C_CHAR)
					  (pragma::SQLPOINTER "$1" (bstring->sqlstring data))
					  (pragma::SQLINTEGER "CINT($1)" (+ (odbc-result-lrl result) 1))
					  (pragma::SQLINTEGER* "&$1" newlen))))
		   (result-val*-len-set! rval newlen)
		   (when (= retval SQL_ERROR)
		      (odbc-do-stmt-error caller "SQLGetData" result)
		      (return #f))
		   (if (= (result-val*-len rval) SQL_NULL_DATA)
		       (set! data NULL)
		       (set! data (substring data 0 (result-val*-len rval))))))
	     (set! data ""))
	 data)))

(define (bad-result-resource)
   (php-warning "supplied argument is not a valid ODBC result resource")
   NULL)

;;;Link Cache
(define *link-cache* (make-hashtable))

(define (suitably-odd-key server username password cursor)
   (mkstr server "<@~@>" username "<@~@>" password "<@~@>" cursor))

(define (store-link server username password cursor link)
   (hashtable-put! *link-cache*
		   (suitably-odd-key server username password cursor)
		   link))

(define (fetch-link server username password cursor)
   (let* ((key (suitably-odd-key server username password cursor))
	  (link (hashtable-get *link-cache* key)))
      (if (and link (eqv? (odbc-link-state link) 'dead))
	  (begin
	     (hashtable-remove! *link-cache* key)
	     #f)
	  link)))

(define (remove-link link)
;without the server/username/password/cursor, we can't
;easily lookup the link, so just set its state to
;dead, and pay for it on the other end.
   (odbc-link-state-set! link 'dead))


;;;; API

; odbc_autocommit -- Toggle autocommit behaviour
(defbuiltin (odbc_autocommit id (onoff 'unpassed))
   (let ((rid (ensure-link 'odbc_autocommit id)))
      (if rid
	  (begin
	     (if (unpassed? onoff)
		 ; get current auto commit status
		 (let* ((status::SQLUINTEGER 0)
			(retval (SQLGetConnectAttr (odbc-link-dbc id)
						   (pragma::SQLINTEGER "SQL_ATTR_AUTOCOMMIT")
						   (pragma::SQLPOINTER "&$1" status)
						   0
						   (pragma::SQLINTEGER* "NULL"))))
		    (if (or (= retval SQL_SUCCESS)
			    (= retval SQL_SUCCESS_WITH_INFO))
			(convert-to-number status)
			(begin
			   (odbc-do-link-error "odbc_autocommit" "SQLGetConnectOption" id)
			   #f)))
		 ; set auto commit status
		 (let ((retval (SQLSetConnectAttr (odbc-link-dbc id)
						  (pragma::SQLINTEGER "SQL_ATTR_AUTOCOMMIT")
						  (if (convert-to-boolean onoff)
						      (pragma::SQLPOINTER "SQL_AUTOCOMMIT_ON")
						      (pragma::SQLPOINTER "SQL_AUTOCOMMIT_OFF"))
						  0)))
		    (if (or (= retval SQL_SUCCESS)
			    (= retval SQL_SUCCESS_WITH_INFO))
			#t
			(begin
			   (odbc-do-link-error "odbc_autocommit" "SQLSetConnectOption" id)
			   #f)))))
	  #f)))
	     

; odbc_binmode -- Handling of binary column data
(defbuiltin (odbc_binmode result val)
   (if (active-result? result)
       (odbc-result-bin-mode-set! result val)
       (set! *default-bin-mode* val)))

; odbc_close_all -- Close all ODBC connections
(defbuiltin (odbc_close_all)
   (hashtable-for-each *link-cache*
		       (lambda (k v)
			  (odbc_close v))))
   
; odbc_close -- Close an ODBC connection
(defbuiltin (odbc_close id)
   (let ((rid (ensure-link 'odbc_close id)))
      (if rid
	  (begin
	     (when (eqv? (odbc-link-state id) 'active)
		(let ((retval (SQLDisconnect (odbc-link-dbc id))))
		   (when (= retval SQL_ERROR)
		      (SQLTransact SQL_NULL_HENV
				   (odbc-link-dbc id)
				   (pragma::SQLUSMALLINT "SQL_ROLLBACK"))
		      (SQLDisconnect (odbc-link-dbc id))))
		(SQLFreeHandle SQL_HANDLE_DBC (odbc-link-dbc id))
		(SQLFreeHandle SQL_HANDLE_ENV (odbc-link-env id))
		(odbc-link-state-set! id 'dead))
	     NULL)
	  #f)))

; odbc_columnprivileges --  Returns a result identifier that can be used
;                           to fetch a list of columns and associated privileges
(defbuiltin (odbc_columnprivileges id qualifier owner table column)
   (let ((rid (ensure-link 'odbc_columnprivileges id)))
      (if rid
	  (bind-exit (return)
	     (let ((new-result (make-new-odbc-result id))
		   (new-stmt SQL_NULL_HSTMT))
		(set! new-stmt (alloc-odbc-handle (odbc-link-env rid) (odbc-link-dbc rid) new-stmt SQL_HANDLE_STMT))
		(when (eqv? new-stmt #f)
		   (odbc-free-result new-result)
		   (return #f))
		(odbc-result-stmt-set! new-result new-stmt)
		(let* ((nts? (lambda (v)
				(if (> (string-length (mkstr v)) 0)
				    (pragma::SQLSMALLINT "SQL_NTS")
				    (pragma::SQLSMALLINT "0"))))
		       (retval (SQLColumnPrivileges new-stmt
						    (bstring->sqlstring (mkstr qualifier))
						    (nts? qualifier)
						    (bstring->sqlstring (mkstr owner))
						    (nts? owner)
						    (bstring->sqlstring (mkstr table))
						    (nts? table)
						    (bstring->sqlstring (mkstr column))
						    (nts? column))))
		   (if (not (= retval SQL_ERROR))
		       (let ((n-cols::SQLSMALLINT 0))
			  (SQLNumResultCols new-stmt (pragma::SQLSMALLINT* "&$1" n-cols))
			  (odbc-result-num-cols-set! new-result n-cols)
			  (when (>= n-cols 0)
			     (let ((retval (bind-result-cols "odbc_columnprivileges" new-result)))
				(unless retval
				   (odbc-do-stmt-error "odbc_columnprivileges" "SQLBindCol" new-result)
				   (odbc-free-result new-result)
				   (return #f))))
			  new-result)
		       (begin
			  (odbc-do-stmt-error "odbc_columnprivileges" "SQLColumnPrivileges" new-result)
			  (odbc-free-result new-result)
			  #f)))))
	  #f)))

; odbc_columns --  Lists the column names in specified tables
(defbuiltin (odbc_columns id qualifier owner table column)
   (let ((rid (ensure-link 'odbc_columns id)))
      (if rid
	  (bind-exit (return)
	     (let ((new-result (make-new-odbc-result id))
		   (new-stmt SQL_NULL_HSTMT))
		(set! new-stmt (alloc-odbc-handle (odbc-link-env rid) (odbc-link-dbc rid) new-stmt SQL_HANDLE_STMT))
		(when (eqv? new-stmt #f)
		   (odbc-free-result new-result)		   
		   (return #f))
		(odbc-result-stmt-set! new-result new-stmt)
		(let ((retval (SQLColumns new-stmt
					  (bstring->sqlstring (mkstr qualifier))
					  (string-length (mkstr qualifier))
					  (bstring->sqlstring (mkstr owner))
					  (string-length (mkstr owner))
					  (bstring->sqlstring (mkstr table))
					  (string-length (mkstr table))
					  (bstring->sqlstring (mkstr column))
					  (string-length (mkstr column)))))
		   (if (not (= retval SQL_ERROR))
		       (let ((n-cols::SQLSMALLINT 0))
			  (SQLNumResultCols new-stmt (pragma::SQLSMALLINT* "&$1" n-cols))
			  (odbc-result-num-cols-set! new-result n-cols)
			  (when (>= n-cols 0)
			     (let ((retval (bind-result-cols "odbc_columns" new-result)))
				(unless retval
				   (odbc-do-stmt-error "odbc_columns" "SQLBindCol" new-result)
				   (odbc-free-result new-result)
				   (return #f))))
			  new-result)
		       (begin
			  (odbc-do-stmt-error "odbc_columns" "SQLColumns" new-result)
			  (odbc-free-result new-result)		  
			  #f)))))
	  #f)))

; odbc_commit -- Commit an ODBC transaction
(defbuiltin (odbc_commit id)
   (let ((rid (ensure-link 'odbc_commit id)))
      (if rid
	  (let ((retval (SQLTransact SQL_NULL_HENV
				     (odbc-link-dbc id)
				     (pragma::SQLUSMALLINT "SQL_COMMIT"))))
	     (if (or (= retval SQL_SUCCESS)
		     (= retval SQL_SUCCESS_WITH_INFO))
		 #t
		 (begin
		    (odbc-do-link-error "odbc_commit" "SQLTransact" id)
		    #f)))
	  #f)))

; odbc_connect -- Connect to a datasource
(defbuiltin (odbc_connect dsn user password (cursor-type SQL_CUR_DEFAULT))
   (bind-exit (return)
      ; correct cursor type?
      (unless (or (eqv? cursor-type SQL_CUR_DEFAULT)
		  (eqv? cursor-type SQL_CUR_USE_DRIVER)
		  (eqv? cursor-type SQL_CUR_USE_ODBC)
		  (eqv? cursor-type SQL_CUR_USE_IF_NEEDED))
	 (php-warning "Invalid cursor type")
	 (return #f))
      ; do we have it cached?
      (let ((cached-link (fetch-link dsn user password cursor-type)))
	 (when cached-link
	    (debug-trace 3 (format "Using cached ODBC connection ~a/~a/~a" dsn user cursor-type))	    
	     (return cached-link)))
      ; too many links?
      (let ((max-links (get-ini-entry "odbc.max_links")))
	 (when (and max-links
		    (>= (mkfixnum max-links) (hashtable-size *link-cache*)))
	    (php-warning (format "too many open ODBC connections (~a)" (hashtable-size *link-cache*)))
	    (return #f)))
      ; new link
      (debug-trace 3 (format "Opening new ODBC connection: ~a/~a/~a" dsn user cursor-type))
      (let* ((new-link (make-new-odbc-link))
	     (new-env SQL_NULL_HENV)
	     (new-dbc SQL_NULL_HDBC))
	 ; environment handle
	 (set! new-env (alloc-odbc-handle SQL_NULL_HANDLE SQL_NULL_HANDLE new-env SQL_HANDLE_ENV))
	 (when (eqv? new-env #f)
	    (return #f))
	 (odbc-link-env-set! new-link new-env)
	 ; ODBC v3
	 (SQLSetEnvAttr new-env SQL_ATTR_ODBC_VERSION SQL_OV_ODBC3 0)
	 ; dbc handle
	 (set! new-dbc (alloc-odbc-handle new-env SQL_NULL_HANDLE new-dbc SQL_HANDLE_DBC))
	 (when (eqv? new-dbc #f)
	    (SQLFreeHandle SQL_HANDLE_ENV new-env)
	    (return #f))
	 (odbc-link-dbc-set! new-link new-dbc)	 
	 ; if we're not using the default cursor...
	 (unless (eqv? cursor-type SQL_CUR_DEFAULT)
	    (let ((retval (SQLSetConnectAttr new-dbc
					     (pragma::SQLINTEGER "SQL_ATTR_ODBC_CURSORS")
					     (pragma::SQLPOINTER "$1" (fixnum->sqluinteger cursor-type))
					     0)))
	       (unless (= retval SQL_SUCCESS)
; 		  (let ((err (odbc-error "SQLSetConnectAttr" new-env new-dbc SQL_NULL_HSTMT)))
; 		      (when err
; 			 (php-warning err)))
		  (odbc-do-link-error "odbc_connect" "SQLSetConnectAttr" new-link)
		  (SQLFreeHandle SQL_HANDLE_DBC new-dbc)
		  (SQLFreeHandle SQL_HANDLE_ENV new-env)
		  (return #f))))
	 ; go for connect
	 (let ((retval (make-odbc-connection new-dbc dsn user password)))
	    (if (= retval SQL_SUCCESS)
		; successful connect
		(begin
		   (odbc-link-state-set! new-link 'active)
		   (store-link dsn user password cursor-type new-link)
		   new-link)
		; unsuccessful connect
		(begin
		   ; pull the connect error into global last error msg
; 		   (let ((err (odbc-error "SQLConnect" new-env new-dbc SQL_NULL_HSTMT)))
; 		      (when err
; 			 (php-warning err)))
		   (odbc-do-link-error "odbc_connect" "SQLConnect" new-link)
		   (SQLFreeHandle SQL_HANDLE_DBC new-dbc)
		   (SQLFreeHandle SQL_HANDLE_ENV new-env)
		   #f))))))

; odbc_cursor -- Get cursorname
(defbuiltin (odbc_cursor result)
   (if (active-result? result)
       (bind-exit (return)
	  (let* ((max-len::SWORD 0)
		 (ig::SWORD 0)
		 (cname '())
		 (retval (SQLGetInfo (odbc-link-dbc (odbc-result-my-link result))
				     (pragma::SQLUSMALLINT "SQL_MAX_CURSOR_NAME_LEN")
				     (pragma::SQLPOINTER "&$1" max-len)
				     (pragma::SQLSMALLINT "sizeof($1)" max-len)
				     (pragma::SQLSMALLINT* "&$1" ig))))
	     (unless (or (= retval SQL_SUCCESS)
			 (= retval SQL_SUCCESS_WITH_INFO)
			 (<= max-len 0))
		(return #f))
	     (set! cname (make-string (+ max-len 1)))
	     (let ((retval2 (SQLGetCursorName (odbc-result-stmt result)
					     (bstring->sqlstring cname)
					     max-len
					     (pragma::SQLSMALLINT* "&$1" ig))))
		(if (or (= retval2 SQL_SUCCESS)
			(= retval2 SQL_SUCCESS_WITH_INFO))
		    (substring cname 0 ig)
		    #f))))
       (bad-result-resource)))

; odbc_data_source -- Returns information about a current connection
(defbuiltin (odbc_data_source id ftype)
   (let ((rid (ensure-link 'odbc_data id)))
      (set! ftype (fixnum->sqluinteger ftype))
      (if rid
	  (if (or (= ftype SQL_FETCH_NEXT)
		  (= ftype SQL_FETCH_FIRST))
	      (let* ((result-array (make-php-hash))
		     (server-name (make-string 100))
		     (server-desc (make-string 200))
		     (name-len::SQLSMALLINT 0)
		     (desc-len::SQLSMALLINT 0)
		     (retval (SQLDataSources (odbc-link-env id)
					     ftype
					     (bstring->sqlstring server-name)
					     (pragma::SQLSMALLINT "100")
					     (pragma::SQLSMALLINT* "&$1" name-len)
					     (bstring->sqlstring server-desc)
					     (pragma::SQLSMALLINT "200")
					     (pragma::SQLSMALLINT* "&$1" desc-len))))
		 (if (= retval SQL_SUCCESS)
		     (if (and (> name-len 0)
			      (> desc-len 0))
			 (begin
			    (php-hash-insert! result-array "server" (substring server-name 0 name-len))
			    (php-hash-insert! result-array "description" (substring server-desc 0 desc-len))
			    result-array)
			 #f)
		     (begin
			(odbc-do-link-error "odbc_data_source" "SQLDataSources" id)
			#f)))
	      ;
	      (php-warning "Invalid fetch type"))
	  #f)))

; odbc_do -- Synonym for odbc_exec()
(defalias odbc_do odbc_exec)
   
; odbc_error -- Get the last error code
(defbuiltin (odbc_error (id 'unpassed))
   (if (unpassed? id)
       *odbc-last-state*
       (let ((rid (ensure-link 'odbc_error id)))
	  (if rid
	      (odbc-link-last-state id)
	      #f))))

; odbc_errormsg -- Get the last error message
(defbuiltin (odbc_errormsg (id 'unpassed))
   (if (unpassed? id)
       *odbc-last-error*
       (let ((rid (ensure-link 'odbc_errormsg id)))
	  (if rid
	      (odbc-link-last-error id)
	      #f))))

; odbc_exec -- Prepare and execute a SQL statement
(defbuiltin (odbc_exec id query (flags 'unpassed))
   (bind-exit (return)
      (let ((rid (ensure-link 'odbc_exec id)))
	 (if rid
	     (let ((new-result (make-new-odbc-result id))
		   (new-stmt SQL_NULL_HSTMT))
		(set! new-stmt (alloc-odbc-handle (odbc-link-env rid) (odbc-link-dbc rid) new-stmt SQL_HANDLE_STMT))
		(when (eqv? new-stmt #f)
		   (odbc-free-result new-result)
		   (return #f))
		(odbc-result-stmt-set! new-result new-stmt)
		; will we allow absolute fetching?
		(let* ((opts::SDWORD 0)
		       (retval (SQLGetInfo (odbc-link-dbc rid)
					   SQL_FETCH_DIRECTION
					   (pragma::SQLPOINTER "&$1" opts)
					   (pragma::SQLSMALLINT "sizeof($1)" opts)
					   (pragma::SQLSMALLINT* "NULL"))))
		   (when (= retval SQL_SUCCESS)
		      ; if we can fetch absolute, try to set a dynamic cursor
		      (odbc-result-fetch-abs?-set! new-result (> (bit-and opts SQL_FD_FETCH_ABSOLUTE) 0))
		      (when (odbc-result-fetch-abs? new-result)
			 (let ((retval2 (SQLSetStmtOption (odbc-result-stmt new-result)
							  ; these are php constants, and are php typed (elongs)
							  ; so we get at them directly
							  (pragma::SQLUINTEGER "SQL_CURSOR_TYPE")
							  (pragma::SQLUINTEGER "SQL_CURSOR_DYNAMIC"))))
			    (when (= retval2 SQL_ERROR)
			       (odbc-do-stmt-error "odbc_exec" "SQLSetStmtOption" new-result)
			       (odbc-free-result new-result)
			       #f)))))
		; execute
		(let ((retval (SQLExecDirect new-stmt
					     (bstring->sqlstring (mkstr query))
					     SQL_NTS)))
		   (if (or (= retval SQL_SUCCESS)
			   (= retval SQL_SUCCESS_WITH_INFO)
			   (= retval SQL_NO_DATA_FOUND))
		       ; Good query, bind columns if necessary and return new result resource
		       (let ((n-cols::SQLSMALLINT 0))
			  (SQLNumResultCols new-stmt (pragma::SQLSMALLINT* "&$1" n-cols))
			  (odbc-result-sql-set! new-result query)
			  (odbc-result-num-cols-set! new-result n-cols)
			  (when (>= n-cols 0)
			     (let ((retval (bind-result-cols "odbc_exec" new-result)))
				(unless retval
				   (odbc-do-stmt-error "odbc_exec" "SQLBindCol" new-result)
				   (odbc-free-result new-result)
				   (return #f))))
			  new-result)
		       ; bad SQLExecDirect call
		       (begin
			  (odbc-do-stmt-error "odbc_exec" "SQLExecDirect" new-result)
			  (odbc-free-result new-result)			  
			  #f))))
	     ; bad resource
	     #f))))

; odbc_execute -- Execute a prepared statement
(defbuiltin (odbc_execute result (params 'unpassed))
   (if (active-result? result)
       (bind-exit (return)

	  ; make sure if they passed something, it's an array
	  (when (and (not (unpassed? params))
		     (not (php-hash? params)))	     
	     (php-warning "not an array")
	     (return #f))

	  ; if the prepared statement had params, we require an array
	  (when (and (unpassed? params)
		     (> (odbc-result-num-params result) 0))
	     (php-warning "The statement requires parameters which were not passed.")
	     (return #f))

	  (let ((final-ret-val #f))

	     ; params
	     (when (> (odbc-result-num-params result) 0)
		; needs to have the right amount
		(unless (= (odbc-result-num-params result) (php-hash-size params))
		   (php-warning (format "Not enough parameters (~a should be ~a)"
					(php-hash-size params)
					(odbc-result-num-params result)))
		   (return #f))

		(php-hash-reset params)
		
		; finally, bind params
		(let loop ((p 1))
		   (when (<= p (odbc-result-num-params result))
		      (let* ((bparam (bind-param "" 0))
			     (sqltype::SWORD 0)
			     (precision::UDWORD 0)
			     (scale::SWORD 0)
			     (nullable::SWORD 0)
			     (ctype::SWORD 0))

			 (SQLDescribeParam (odbc-result-stmt result)
					   (pragma::SQLUSMALLINT "$1" p)
					   (pragma::SQLSMALLINT* "&$1" sqltype)
					   (pragma::SQLUINTEGER* "&$1" precision)
					   (pragma::SQLSMALLINT* "&$1" scale)
					   (pragma::SQLSMALLINT* "&$1" nullable))

			 (if (bin-col-type? sqltype)
			     (set! ctype SQL_C_BINARY)
			     (set! ctype SQL_C_CHAR))
			 
			 (bind-param-val-set! bparam (pragma::SQLPOINTER "$1"
									 (bstring->sqlstring
									  (mkstr (php-hash-current-value params)))))
			 (bind-param-len-set! bparam (pragma::SQLINTEGER "$1"
									 (string-length 
									  (mkstr (php-hash-current-value params)))))
			 
			 (SQLBindParameter (odbc-result-stmt result)
					   (pragma::SQLUSMALLINT "$1" p)
					   (pragma::SQLSMALLINT "SQL_PARAM_INPUT")
					   ctype
					   sqltype
					   precision
					   scale
					   (bind-param-val bparam)
					   (pragma::SQLINTEGER "0")
					   (pragma::SQLINTEGER* "&$1" (bind-param-len bparam)))

			 (php-hash-advance params)
			 (loop (+ 1 p))))))

	     (let ((retval (SQLFreeStmt (odbc-result-stmt result) SQL_CLOSE)))
		(when (= retval SQL_ERROR)
		   (odbc-do-stmt-error "odbc_execute" "SQLFreeStmt" result)
		   (return #f)))
	     
	     (let ((retval (SQLExecute (odbc-result-stmt result))))
		(cond ((or (= retval SQL_NO_DATA_FOUND)
			   (= retval SQL_SUCCESS_WITH_INFO))
		       (begin
			  (odbc-do-stmt-error "odbc_execute" "SQLExecute" result)
			  (set! final-ret-val #t)))
		      ((= retval SQL_SUCCESS) (set! final-ret-val #t))
		      (else
		       (odbc-do-stmt-error "odbc_execute" "SQLExecute" result)
		       (set! final-ret-val #f))))

	     (when (> (odbc-result-num-params result) 0)	     
		(SQLFreeStmt (odbc-result-stmt result) SQL_RESET_PARAMS))

	     (when (= (odbc-result-num-cols result) 0)
		(let ((n-cols::SQLSMALLINT 0))
		   (SQLNumResultCols (odbc-result-stmt result) (pragma::SQLSMALLINT* "&$1" n-cols))
		   (odbc-result-num-cols-set! result n-cols)
		   (when (>= n-cols 0)
		      (let ((retval (bind-result-cols "odbc_execute" result)))
			 (unless retval
			    (odbc-do-stmt-error "odbc_execute" "SQLBindCol" result)
			    (return #f))))))
	     
	     final-ret-val))
       ; bad resource param
       (bad-result-resource)))

; odbc_fetch_array -- Fetch a result row as an associative array
(defbuiltin (odbc_fetch_array result (row 'unpassed))
   (odbc-fetch-hash result row 'array))

; odbc_fetch_object -- Fetch a result row as an object
(defbuiltin (odbc_fetch_object result (row 'unpassed))
   (odbc-fetch-hash result row 'object))

; this is used for fetch hashes and objects
(define (odbc-fetch-hash result row ftype)
   (if (active-result? result)
       (bind-exit (return)
	  ;
;	  (dump-results "odbc-fetch-hash1" result)
	  ;
	  (if (= (odbc-result-num-cols result) 0)
	      (php-warning "No tuples available on this result")
	      (let ((retval (odbc_fetch_row result row)))
		 (unless retval
		    (return #f))
		 ;
;		 (dump-results "odbc-fetch-hash2" result)
		 ;
;	      (let ((retval (SQLFetch (odbc-result-stmt result))))
;		 (unless (or (= retval SQL_SUCCESS)
;			     (= retval SQL_SUCCESS_WITH_INFO))
;		    (return #f))
		 ; copy results from previously bound columns
		 (let ((result-array (make-php-hash)))
;		    (odbc-result-num-fetched-set! result (+ (odbc-result-num-fetched result) 1))
		    (let loop ((n 0))
		       (when (< n (odbc-result-num-cols result))
			  (let ((rval (vector-ref (odbc-result-cols result) n)))
			     ;
;			     (dump-result-val "odbc_fetch_array" n rval)
			     ;
			     (if (long-or-bin-col-type? (result-val*-coltype rval))
				 (let ((data (get-long-data (if (eqv? ftype 'array')
								"odbc_fetch_array"
								"odbc_fetch_object")
							    n result)))
				    (if data
					; handle long/binary data
					(php-hash-insert! result-array
							  (result-val*-name rval)
							  data)
					; bad
					(return #f)))
				 ; normal
				 (php-hash-insert! result-array
						   (result-val*-name rval)
						   (if (or (= (result-val*-len rval) SQL_NULL_DATA)
							   (not (= (string-length (result-val*-val rval))
								   (result-val*-len rval))))
						       NULL
						       (substring (result-val*-val rval) 0 (result-val*-len rval))
						       ))))
			  (loop (+ n 1))))
		    (if (eqv? ftype 'array)
			result-array
			(convert-to-object result-array)
			)))))
       (bad-result-resource)))

; odbc_fetch_into -- Fetch one result row into array
(defbuiltin (odbc_fetch_into result (ref . array) (row 'unpassed))
   (if (active-result? result)
       (bind-exit (return)
	  (if (= (odbc-result-num-cols result) 0)
	      (php-warning "No tuples available on this result")
	      (let ((retval (odbc_fetch_row result row)))
		 (unless retval
		    (return #f))
		 ; copy results from previously bound columns
		 (unless (php-hash? (container-value array))
		    (container-value-set! array (make-php-hash)))		 
		 (let loop ((n 0))
		    (when (< n (odbc-result-num-cols result))
		       (let ((rval (vector-ref (odbc-result-cols result) n)))
			  (if (long-or-bin-col-type? (result-val*-coltype rval))
			      (let ((data (get-long-data "odbc_fetch_into" n result)))
				 (if data
				     ; handle long/binary data
				     (php-hash-insert! (container-value array)	
						       (convert-to-number n)					       
						       data)
				     ; bad
				     (return #f)))
			      ; normal
			      (php-hash-insert! (container-value array)
						(convert-to-number n)
						(if (= (result-val*-len rval) SQL_NULL_DATA)
						    NULL
						    (substring (result-val*-val rval)
							       0
							       (result-val*-len rval))
						    ))))						
		       (loop (+ n 1))))
		 (convert-to-number (odbc-result-num-cols result)))))
       (bad-result-resource)))

; odbc_fetch_row -- Fetch a row
(defbuiltin (odbc_fetch_row result (row 'unpassed))
   (if (active-result? result)
       (bind-exit (return)
	  (if (= (odbc-result-num-cols result) 0)
	      (php-warning "No tuples available on this result")
	      (if (not (odbc-result-fetch-abs? result))
		  ; use SQLFetch, always get next row
		  (let ((retval (SQLFetch (odbc-result-stmt result))))
		     (if (or (= retval SQL_SUCCESS)
			     (= retval SQL_SUCCESS_WITH_INFO))
			 (begin
			    (odbc-result-num-fetched-set! result (+ (odbc-result-num-fetched result) 1))
			    #t)
			 ; bad fetch or no more
			 #f))
 		  ; use SQLExtendedFetch, possibly get a specific row
		  (let* ((f-row (if (unpassed? row) 1 row))
			 (f-type (if (unpassed? row)
				     (pragma::SQLUSMALLINT "SQL_FETCH_NEXT")
				     SQL_FETCH_ABSOLUTE))
			 (c-row::SQLUINTEGER 0)
			 (r-status::SQLUSMALLINT 0)
			 (retval (SQLExtendedFetch (odbc-result-stmt result)
						   f-type
						   (pragma::SQLROWOFFSET "$1" (fixnum->sqlinteger f-row))
						   (pragma::SQLUINTEGER* "&$1" c-row)
						   (pragma::SQLUSMALLINT* "&$1" r-status))))
		     (if (or (= retval SQL_SUCCESS)
			     (= retval SQL_SUCCESS_WITH_INFO))
			 (begin
			    (if (unpassed? row)
				(odbc-result-num-fetched-set! result (+ (odbc-result-num-fetched result) 1))
				(odbc-result-num-fetched-set! result f-row))
			    #t)
			 ; bad fetch or no more
			 #f)))))
;			 (let ((msg (odbc-error "SQLExtendedFetch"
;						SQL_NULL_HENV SQL_NULL_HDBC (odbc-result-stmt result))))
;			    (php-warning msg)))))))
       (bad-result-resource)))

; odbc_field_len -- Get the length (precision) of a field
(defbuiltin (odbc_field_len result col)
   (bind-exit (return)
      (set! col (mkfixnum (convert-to-number col)))
      (if (active-result? result)
	  (begin
	     (when (= (odbc-result-num-cols result) 0)
		(php-warning "No tuples available on this result")
		(return #f))
	     (when (> col (odbc-result-num-cols result))
		(php-warning "Field index larger than available fields")
		(return #f))
	     (when (< col 0)
		(php-warning "Field indexes start at 1")
		(return #f))
	     (let* ((len::SQLINTEGER 0)
		    (retval (SQLColAttribute (odbc-result-stmt result)
					     (pragma::SQLUSMALLINT "CINT($1)" col) ; col #, 1 based
					     (pragma::SQLUSMALLINT "SQL_COLUMN_PRECISION")
					     (pragma::SQLPOINTER "NULL")
					     (pragma::SQLSMALLINT "0")
					     (pragma::SQLSMALLINT* "NULL")
					     (pragma::SQLPOINTER "&$1" len))))
		(convert-to-number len)))
	  (bad-result-resource))))

; odbc_field_name -- Get the columnname
(defbuiltin (odbc_field_name result col)
   (bind-exit (return)
      (set! col (mkfixnum (convert-to-number col)))
      (if (active-result? result)
	  (begin
	     (when (= (odbc-result-num-cols result) 0)
		(php-warning "No tuples available on this result")
		(return #f))
	     (when (> col (odbc-result-num-cols result))
		(php-warning "Field index larger than available fields")
		(return #f))
	     (when (< col 0)
		(php-warning "Field indexes start at 1")
		(return #f))
	     (let ((rval (vector-ref (odbc-result-cols result) (- col 1))))
		(result-val*-name rval)))
	  (bad-result-resource))))

; odbc_field_num -- Return column number
(defbuiltin (odbc_field_num result colname)
   (if (active-result? result)
       (let ((col (find-col result (mkstr colname))))
	  (if col
	      (php-+ col 1)
	      #f))
       (bad-result-resource)))

; odbc_field_precision -- Synonym for odbc_field_len()
(defalias odbc_field_precision odbc_field_len)

; odbc_field_scale -- Get the scale of a field
(defbuiltin (odbc_field_scale result col)
   (bind-exit (return)
      (set! col (mkfixnum (convert-to-number col)))
      (if (active-result? result)
	  (begin
	     (when (= (odbc-result-num-cols result) 0)
		(php-warning "No tuples available on this result")
		(return #f))
	     (when (> col (odbc-result-num-cols result))
		(php-warning "Field index larger than available fields")
		(return #f))
	     (when (< col 0)
		(php-warning "Field indexes start at 1")
		(return #f))
	     (let* ((len::SDWORD 0)
		    (retval (SQLColAttribute (odbc-result-stmt result)
					     (pragma::SQLUSMALLINT "CINT($1)" col) ; col #, 1 based
					     (pragma::SQLUSMALLINT "SQL_COLUMN_SCALE")
					     (pragma::SQLPOINTER "NULL")
					     (pragma::SQLSMALLINT "0")
					     (pragma::SQLSMALLINT* "NULL")
					     (pragma::SQLPOINTER "&$1" len))))
		(convert-to-number len)))
	  (bad-result-resource))))

; odbc_field_type -- Datatype of a field
(defbuiltin (odbc_field_type result col)
   (bind-exit (return)
      (set! col (mkfixnum (convert-to-number col)))
      (if (active-result? result)
	  (begin
	     (when (= (odbc-result-num-cols result) 0)
		(php-warning "No tuples available on this result")
		(return #f))
	     (when (> col (odbc-result-num-cols result))
		(php-warning "Field index larger than available fields")
		(return #f))
	     (when (< col 0)
		(php-warning "Field indexes start at 1")
		(return #f))
	     (let* ((len::SQLSMALLINT 0)
		    (buf (make-string 32))
		    (retval (SQLColAttribute (odbc-result-stmt result)
					     (pragma::SQLUSMALLINT "CINT($1)" col) ; col #, 1 based
					     (pragma::SQLUSMALLINT "SQL_COLUMN_TYPE_NAME")
					     (pragma::SQLPOINTER "$1" (bstring->sqlstring buf))
					     (pragma::SQLSMALLINT "31")
					     (pragma::SQLSMALLINT* "&$1" len)
					     (pragma::SQLPOINTER "NULL"))))
		(substring buf 0 len)))
	  (bad-result-resource))))

; odbc_foreignkeys --  Returns a list of foreign keys in the specified table or a
;                      list of foreign keys in other tables that refer to the primary key in the specified table
(defbuiltin (odbc_foreignkeys id qualifier owner table fk-qualifier fk-owner fk-table)
   (let ((rid (ensure-link 'odbc_foreignkeys id)))
      (if rid
	  (bind-exit (return)
	     (let ((new-result (make-new-odbc-result id))
		   (new-stmt SQL_NULL_HSTMT))
		(set! new-stmt (alloc-odbc-handle (odbc-link-env rid) (odbc-link-dbc rid) new-stmt SQL_HANDLE_STMT))
		(when (eqv? new-stmt #f)
		   (odbc-free-result new-result)
		   (return #f))
		(odbc-result-stmt-set! new-result new-stmt)
		(let* ((nts? (lambda (v)
				(if (> (string-length (mkstr v)) 0)
				    (pragma::SQLSMALLINT "SQL_NTS")
				    (pragma::SQLSMALLINT "0"))))
		       (donull? (lambda (v)
				   (let ((rv (mkstr v)))
				      (if (> (string-length rv) 0)
					  (bstring->sqlstring rv)
					  (pragma::SQLCHAR* "NULL")))))
		       (retval (SQLForeignKeys new-stmt
					      (donull? qualifier)
					      (nts? qualifier)
					      (donull? owner)
					      (nts? owner)
					      (donull? table)
					      (nts? table)
					      (donull? fk-qualifier)
					      (nts? fk-qualifier)
					      (donull? fk-owner)
					      (nts? fk-owner)
					      (donull? fk-table)
					      (nts? fk-table))))
		   (if (not (= retval SQL_ERROR))
		       (let ((n-cols::SQLSMALLINT 0))
			  (SQLNumResultCols new-stmt (pragma::SQLSMALLINT* "&$1" n-cols))
			  (odbc-result-num-cols-set! new-result n-cols)
			  (when (>= n-cols 0)
			     (let ((retval (bind-result-cols "odbc_foreignkeys" new-result)))
				(unless retval
				   (odbc-do-stmt-error "odbc_foreignkeys" "SQLBindCol" new-result)
				   (odbc-free-result new-result)
				   (return #f))))
			  new-result)
		       (begin
			  (odbc-do-stmt-error "odbc_foreignkeys" "SQLForeignKeys" new-result)
			  (odbc-free-result new-result)			  
			  #f)))))
	  #f)))


; odbc_free_result -- Free resources associated with a result
(defbuiltin (odbc_free_result result)
   (if (active-result? result)
       (begin
	  (odbc-free-result result)
	  #t)
       (bad-result-resource)))

; odbc_gettypeinfo --  Returns a result identifier containing information about
;                      data types supported by the data source
(defbuiltin (odbc_gettypeinfo id (type 'unpassed))
   (let ((rid (ensure-link 'odbc_gettypeinfo id)))
      (if rid
	  (bind-exit (return)
	     (let ((new-result (make-new-odbc-result id))
		   (new-stmt SQL_NULL_HSTMT))
		(set! new-stmt (alloc-odbc-handle (odbc-link-env rid) (odbc-link-dbc rid) new-stmt SQL_HANDLE_STMT))
		(when (eqv? new-stmt #f)
		   (odbc-free-result new-result)
		   (return #f))
		(odbc-result-stmt-set! new-result new-stmt)
		(let ((retval (SQLGetTypeInfo new-stmt
					      (if (passed? type)
						  (pragma::SQLSMALLINT "$1" (mkfixnum type))
						  (pragma::SQLSMALLINT "SQL_ALL_TYPES")))))
		   (if (not (= retval SQL_ERROR))
		       (let ((n-cols::SQLSMALLINT 0))
			  (SQLNumResultCols new-stmt (pragma::SQLSMALLINT* "&$1" n-cols))
			  (odbc-result-num-cols-set! new-result n-cols)
			  (when (>= n-cols 0)
			     (let ((retval (bind-result-cols "odbc_gettypeinfo" new-result)))
				(unless retval
				   (odbc-do-stmt-error "odbc_gettypeinfo" "SQLBindCol" new-result)
				   (odbc-free-result new-result)
				   (return #f))))
			  new-result)
		       (begin
			  (odbc-do-stmt-error "odbc_gettypeinfo" "SQLGetTypeInfo" new-result)
			  (odbc-free-result new-result)			  
			  #f)))))
	  #f)))

; odbc_longreadlen -- Handling of LONG columns
(defbuiltin (odbc_longreadlen result val)
   (if (active-result? result)
       (odbc-result-lrl-set! result (convert-to-number val))
       (set! *default-lrl* (convert-to-number val))))

; odbc_next_result --  Checks if multiple results are available
; XXX is this necessary??

; odbc_num_fields -- Number of columns in a result
(defbuiltin (odbc_num_fields result)
   (if (active-result? result)
       (convert-to-number (odbc-result-num-cols result))
       #f))
       
; odbc_num_rows -- Number of rows in a result
(defbuiltin (odbc_num_rows result)
   (if (active-result? result)
       (let ((n-rows::SQLINTEGER 0))
	  (SQLRowCount (odbc-result-stmt result) (pragma::SQLINTEGER* "&$1" n-rows))
	  (convert-to-number n-rows))
       (bad-result-resource)))

; odbc_pconnect -- Open a persistent database connection
(defalias odbc_pconnect odbc_connect)

; odbc_prepare -- Prepares a statement for execution
(defbuiltin (odbc_prepare id query)
   (bind-exit (return)
      (let ((rid (ensure-link 'odbc_prepare id)))
	 (if rid
	     (let ((new-result (make-new-odbc-result id))
		   (new-stmt SQL_NULL_HSTMT))
		(set! new-stmt (alloc-odbc-handle (odbc-link-env rid) (odbc-link-dbc rid) new-stmt SQL_HANDLE_STMT))
		(when (eqv? new-stmt #f)
		   (odbc-free-result new-result)
		   (return #f))
		(odbc-result-stmt-set! new-result new-stmt)
		; will we allow absolute fetching?
		(let* ((opts::SDWORD 0)
		       (retval (SQLGetInfo (odbc-link-dbc rid)
					   SQL_FETCH_DIRECTION
					   (pragma::SQLPOINTER "&$1" opts)
					   (pragma::SQLSMALLINT "sizeof($1)" opts)
					   (pragma::SQLSMALLINT* "NULL"))))
		   (when (= retval SQL_SUCCESS)
		      ; if we can fetch absolute, try to set a dynamic cursor
		      (odbc-result-fetch-abs?-set! new-result (> (bit-and opts SQL_FD_FETCH_ABSOLUTE) 0))
		      (when (odbc-result-fetch-abs? new-result)
			 (let ((retval2 (SQLSetStmtOption (odbc-result-stmt new-result)
							  ; these are php constants, and are php typed (elongs)
							  ; so we get at them directly
							  (pragma::SQLUINTEGER "SQL_CURSOR_TYPE")
							  (pragma::SQLUINTEGER "SQL_CURSOR_DYNAMIC"))))
			    (when (= retval2 SQL_ERROR)
			       (odbc-do-stmt-error "odbc_prepare" "SQLSetStmtOption" new-result)
			       (odbc-free-result new-result)
			       #f)))))
		; prepare
		(let ((retval (SQLPrepare new-stmt
					  (bstring->sqlstring (mkstr query))
					  SQL_NTS)))
		   (if (= retval SQL_SUCCESS)
		       ; Good query, bind columns if necessary and return new result resource
		       (let ((n-cols::SQLSMALLINT 0)
			     (n-params::SQLSMALLINT 0))
			  (SQLNumResultCols new-stmt (pragma::SQLSMALLINT* "&$1" n-cols))
			  (SQLNumParams new-stmt (pragma::SQLSMALLINT* "&$1" n-params))
			  (odbc-result-sql-set! new-result query)
			  (odbc-result-num-cols-set! new-result n-cols)
			  (odbc-result-num-params-set! new-result n-params)
			  (when (>= n-cols 0)
			     (let ((retval (bind-result-cols "odbc_prepare" new-result)))
				(unless retval
				   (odbc-do-stmt-error "odbc_prepare" "SQLBindCol" new-result)
				   (odbc-free-result new-result)
				   (return #f))))
			  new-result)
		       ; bad SQLPrepare call
		       (begin
			  (odbc-do-stmt-error "odbc_prepare" "SQLPrepare" new-result)
			  (odbc-free-result new-result)			  
			  #f))))
	     ; bad resource
	     #f))))
   
; odbc_primarykeys --  Returns a result identifier that can be used to fetch the
;                      column names that comprise the primary key for a table
(defbuiltin (odbc_primarykeys id qualifier owner table)
   (let ((rid (ensure-link 'odbc_primarykeys id)))
      (if rid
	  (bind-exit (return)
	     (let ((new-result (make-new-odbc-result id))
		   (new-stmt SQL_NULL_HSTMT))
		(set! new-stmt (alloc-odbc-handle (odbc-link-env rid) (odbc-link-dbc rid) new-stmt SQL_HANDLE_STMT))
		(when (eqv? new-stmt #f)
		   (odbc-free-result new-result)
		   (return #f))
		(odbc-result-stmt-set! new-result new-stmt)
		(let* ((nts? (lambda (v)
				(if (> (string-length (mkstr v)) 0)
				    (pragma::SQLSMALLINT "SQL_NTS")
				    (pragma::SQLSMALLINT "0"))))
		       (donull? (lambda (v)
				   (let ((rv (mkstr v)))
				      (if (> (string-length rv) 0)
					  (bstring->sqlstring rv)
					  (pragma::SQLCHAR* "NULL")))))
		       (retval (SQLPrimaryKeys new-stmt
					      (donull? qualifier)
					      (nts? qualifier)
					      (donull? owner)
					      (nts? owner)
					      (donull? table)
					      (nts? table))))
		   (if (not (= retval SQL_ERROR))
		       (let ((n-cols::SQLSMALLINT 0))
			  (SQLNumResultCols new-stmt (pragma::SQLSMALLINT* "&$1" n-cols))
			  (odbc-result-num-cols-set! new-result n-cols)
			  (when (>= n-cols 0)
			     (let ((retval (bind-result-cols "odbc_primarykeys" new-result)))
				(unless retval
				   (odbc-do-stmt-error "odbc_primarykeys" "SQLBindCol" new-result)
				   (odbc-free-result new-result)
				   (return #f))))
			  new-result)
		       (begin
			  (odbc-do-stmt-error "odbc_primarykeys" "SQLPrimaryKeys" new-result)
			  (odbc-free-result new-result)			  
			  #f)))))
	  #f)))


; odbc_procedurecolumns --  Retrieve information about parameters to procedures
; odbc_procedures --  Get the list of procedures stored in a specific data source
; odbc_result_all -- Print result as HTML table

; odbc_result -- Get result data
(defbuiltin (odbc_result result col)
   (if (active-result? result)
       (bind-exit (return)
	  ; auto fetch if they haven't
	  (when (= (odbc-result-num-fetched result) 0)
 	     (unless (odbc_fetch_row result 'unpassed)
 		(return #f)))
	  ; figure out column to retrieve, which may be a number or string
	  (if (string? col)
	      (let ((c (find-col result (mkstr col))))
		 (unless c
		    (php-warning (format "Field ~a not found" (mkstr col)))
		    (return #f))
		 (set! col c))
	      (begin
		 ; our vector is 0 based
		 (set! col (- (mkfixnum col) 1))
		 (when (or (>= col (odbc-result-num-cols result))
			   (< col 0))
		    (php-warning "Invalid field index")
		    (return #f))))
	  ; get it
	  (let ((rval (vector-ref (odbc-result-cols result) col)))
	     ;
	     ;
;	     (debug-trace 5 "getting data for col " col)
;	     (dump-result-val "odbc_result" col rval)
	     ;
	     ;
	     (if (long-or-bin-col-type? (result-val*-coltype rval))
		 (let ((data (get-long-data "odbc_result" col result)))
		    (if data
			data
			(return #f)))
		 ; non long/binary
		 (if (= (result-val*-len rval) SQL_NULL_DATA)
		     NULL
		     (if (= (result-val*-len rval) SQL_NULL_DATA)
			 NULL
			 (substring (result-val*-val rval)
				    0
				    (result-val*-len rval))
			 )))))
       (bad-result-resource)))

; odbc_rollback -- Rollback a transaction
(defbuiltin (odbc_rollback id)
   (let ((rid (ensure-link 'odbc_rollback id)))
      (if rid
	  (let ((retval (SQLTransact SQL_NULL_HENV
				     (odbc-link-dbc id)
				     (pragma::SQLUSMALLINT "SQL_ROLLBACK"))))
	     (if (or (= retval SQL_SUCCESS)
		     (= retval SQL_SUCCESS_WITH_INFO))
		 #t
		 (begin
		    (odbc-do-link-error "odbc_rollback" "SQLTransact" id)
		    #f)))
	  #f)))

; odbc_setoption --  Adjust ODBC settings

; odbc_specialcolumns --  Returns either the optimal set of columns that uniquely
;  identifies a row in the table or columns that are automatically updated when any
;  value in the row is updated by a transaction
(defbuiltin (odbc_specialcolumns id type qualifier owner table scope nullable)
   (let ((rid (ensure-link 'odbc_specialcolumns id)))
      (if rid
	  (bind-exit (return)
	     (let ((new-result (make-new-odbc-result id))
		   (new-stmt SQL_NULL_HSTMT))
		(set! new-stmt (alloc-odbc-handle (odbc-link-env rid) (odbc-link-dbc rid) new-stmt SQL_HANDLE_STMT))
		(when (eqv? new-stmt #f)
		   (return #f))
		(odbc-result-stmt-set! new-result new-stmt)
		(let* ((nts? (lambda (v)
				(if (> (string-length (mkstr v)) 0)
				    (pragma::SQLSMALLINT "SQL_NTS")
				    (pragma::SQLSMALLINT "0"))))
		       (donull? (lambda (v)
				   (let ((rv (mkstr v)))
				      (if (> (string-length rv) 0)
					  (bstring->sqlstring rv)
					  (pragma::SQLCHAR* "NULL")))))
		       (retval (SQLSpecialColumns new-stmt
					      (pragma::SQLUSMALLINT "CINT($1)" (mkfixnum type))						  
					      (donull? qualifier)
					      (nts? qualifier)
					      (donull? owner)
					      (nts? owner)
					      (donull? table)
					      (nts? table)
					      (pragma::SQLUSMALLINT "CINT($1)" (mkfixnum scope))
					      (pragma::SQLUSMALLINT "CINT($1)" (mkfixnum nullable)))))
		   (if (not (= retval SQL_ERROR))
		       (let ((n-cols::SQLSMALLINT 0))
			  (SQLNumResultCols new-stmt (pragma::SQLSMALLINT* "&$1" n-cols))
			  (odbc-result-num-cols-set! new-result n-cols)
			  (when (>= n-cols 0)
			     (let ((retval (bind-result-cols "odbc_specialcolumns" new-result)))
				(unless retval
				   (odbc-do-stmt-error "odbc_specialcolumns" "SQLBindCol" new-result)
				   (odbc-free-result new-result)
				   (return #f))))
			  new-result)
		       (begin
			  (odbc-do-stmt-error "odbc_specialcolumns" "SQLSpecialColumns" new-result)
			  (odbc-free-result new-result)
			  #f)))))
	  #f)))

; odbc_statistics -- Retrieve statistics about a table
(defbuiltin (odbc_statistics id qualifier owner table-name unique accuracy)
   (let ((rid (ensure-link 'odbc_statistics id)))
      (if rid
	  (bind-exit (return)
	     (let ((new-result (make-new-odbc-result id))
		   (new-stmt SQL_NULL_HSTMT))
		(set! new-stmt (alloc-odbc-handle (odbc-link-env rid) (odbc-link-dbc rid) new-stmt SQL_HANDLE_STMT))
		(when (eqv? new-stmt #f)
		   (return #f))
		(odbc-result-stmt-set! new-result new-stmt)
		(let* ((nts? (lambda (v)
				(if (> (string-length (mkstr v)) 0)
				    (pragma::SQLSMALLINT "SQL_NTS")
				    (pragma::SQLSMALLINT "0"))))
		       (donull? (lambda (v)
				   (let ((rv (mkstr v)))
				      (if (> (string-length rv) 0)
					  (bstring->sqlstring rv)
					  (pragma::SQLCHAR* "NULL")))))
		       (retval (SQLStatistics new-stmt
					      (donull? qualifier)
					      (nts? qualifier)
					      (donull? owner)
					      (nts? owner)
					      (donull? table-name)
					      (nts? table-name)
					      (pragma::SQLUSMALLINT "CINT($1)" (mkfixnum unique))
					      (pragma::SQLUSMALLINT "CINT($1)" (mkfixnum accuracy)))))
		   (if (not (= retval SQL_ERROR))
		       (let ((n-cols::SQLSMALLINT 0))
			  (SQLNumResultCols new-stmt (pragma::SQLSMALLINT* "&$1" n-cols))
			  (odbc-result-num-cols-set! new-result n-cols)
			  (when (>= n-cols 0)
			     (let ((retval (bind-result-cols "odbc_statistics" new-result)))
				(unless retval
				   (odbc-do-stmt-error "odbc_statistics" "SQLBindCol" new-result)
				   (odbc-free-result new-result)				   
				   (return #f))))
			  new-result)
		       (begin
			  (odbc-do-stmt-error "odbc_statistics" "SQLStatistics" new-result)
			  (odbc-free-result new-result)
			  #f)))))
	  #f)))

; odbc_tableprivileges --  Lists tables and the privileges associated with each table
(defbuiltin (odbc_tableprivileges id qualifier owner name)
   (let ((rid (ensure-link 'odbc_tableprivileges id)))
      (if rid
	  (bind-exit (return)
	     (let ((new-result (make-new-odbc-result id))
		   (new-stmt SQL_NULL_HSTMT))
		(set! new-stmt (alloc-odbc-handle (odbc-link-env rid) (odbc-link-dbc rid) new-stmt SQL_HANDLE_STMT))
		(when (eqv? new-stmt #f)
		   (return #f))
		(odbc-result-stmt-set! new-result new-stmt)
		(let* ((nts? (lambda (v)
				(if (> (string-length (mkstr v)) 0)
				    (pragma::SQLSMALLINT "SQL_NTS")
				    (pragma::SQLSMALLINT "0"))))
		       (donull? (lambda (v)
				   (let ((rv (mkstr v)))
				      (if (> (string-length rv) 0)
					  (bstring->sqlstring rv)
					  (pragma::SQLCHAR* "NULL")))))
		       (retval (SQLTablePrivileges new-stmt
					      (donull? qualifier)
					      (nts? qualifier)
					      (donull? owner)
					      (nts? owner)
					      (donull? name)
					      (nts? name))))
		   (if (not (= retval SQL_ERROR))
		       (let ((n-cols::SQLSMALLINT 0))
			  (SQLNumResultCols new-stmt (pragma::SQLSMALLINT* "&$1" n-cols))
			  (odbc-result-num-cols-set! new-result n-cols)
			  (when (>= n-cols 0)
			     (let ((retval (bind-result-cols "odbc_tableprivileges" new-result)))
				(unless retval
				   (odbc-do-stmt-error "odbc_tableprivileges" "SQLBindCol" new-result)
				   (odbc-free-result new-result)				   
				   (return #f))))
			  new-result)
		       (begin
			  (odbc-do-stmt-error "odbc_tableprivileges" "SQLTablePrivileges" new-result)
			  (odbc-free-result new-result)
			  #f)))))
	  #f)))

; odbc_tables --  Get the list of table names stored in a specific data sourc
(defbuiltin (odbc_tables id (qualifier "") (owner "") (name "") (types ""))
   (let ((rid (ensure-link 'odbc_tables id)))
      (if rid
	  (bind-exit (return)
	     (let ((new-result (make-new-odbc-result id))
		   (new-stmt SQL_NULL_HSTMT))
		(set! new-stmt (alloc-odbc-handle (odbc-link-env rid) (odbc-link-dbc rid) new-stmt SQL_HANDLE_STMT))
		(when (eqv? new-stmt #f)
		   (return #f))
		(odbc-result-stmt-set! new-result new-stmt)
		(let* ((nts? (lambda (v)
				(if (> (string-length (mkstr v)) 0)
				    (pragma::SQLSMALLINT "SQL_NTS")
				    (pragma::SQLSMALLINT "0"))))
		       (donull? (lambda (v)
				   (let ((rv (mkstr v)))
				      (if (> (string-length rv) 0)
					  (bstring->sqlstring rv)
					  (pragma::SQLCHAR* "NULL")))))
		       (retval (SQLTables new-stmt
					      (donull? qualifier)
					      (nts? qualifier)
					      (donull? owner)
					      (nts? owner)
					      (donull? name)
					      (nts? name)
					      (donull? types)
					      (nts? types))))		   
		   (if (not (= retval SQL_ERROR))
		       (let ((n-cols::SQLSMALLINT 0))
			  (SQLNumResultCols new-stmt (pragma::SQLSMALLINT* "&$1" n-cols))
			  (odbc-result-num-cols-set! new-result n-cols)
			  (when (>= n-cols 0)
			     (let ((retval (bind-result-cols "odbc_tables" new-result)))
				(unless retval
				   (odbc-do-stmt-error "odbc_tables" "SQLBindCol" new-result)
				   (odbc-free-result new-result)				   
				   (return #f))))
			  new-result)
		       (begin
			  (odbc-do-stmt-error "odbc_tables" "SQLTables" new-result)
			  (odbc-free-result new-result)
			  #f)))))
	  #f)))

;;;; CONSTANTS

(defconstant ODBC_TYPE (cond-expand (PCC_MINGW "Win32")
				    (else
				     "unixODBC")))
(defconstant ODBC_BINMODE_PASSTHRU 0)
(defconstant ODBC_BINMODE_RETURN   1)
(defconstant ODBC_BINMODE_CONVERT  2)

(defconstant SQL_CUR_USE_IF_NEEDED (pragma::SQLUINTEGER "SQL_CUR_USE_IF_NEEDED"))
(defconstant SQL_CUR_USE_ODBC      (pragma::SQLUINTEGER "SQL_CUR_USE_ODBC"))
(defconstant SQL_CUR_USE_DRIVER    (pragma::SQLUINTEGER "SQL_CUR_USE_DRIVER"))
(defconstant SQL_CUR_DEFAULT       (pragma::SQLUINTEGER "SQL_CUR_DEFAULT"))

; odbc 3
(defconstant SQL_ODBC_CURSORS (pragma::SQLUINTEGER "SQL_ATTR_ODBC_CURSORS"))
(defconstant SQL_ATTR_ODBC_CURSORS (pragma::SQLUINTEGER "SQL_ATTR_ODBC_CURSORS"))

(defconstant SQL_CONCURRENCY (pragma::SQLUINTEGER "SQL_CONCURRENCY"))
(defconstant SQL_CONCUR_READ_ONLY (pragma::SQLUINTEGER "SQL_CONCUR_READ_ONLY"))
(defconstant SQL_CONCUR_LOCK (pragma::SQLUINTEGER "SQL_CONCUR_LOCK"))
(defconstant SQL_CONCUR_ROWVER (pragma::SQLUINTEGER "SQL_CONCUR_ROWVER"))
(defconstant SQL_CONCUR_VALUES (pragma::SQLUINTEGER "SQL_CONCUR_VALUES"))

(defconstant SQL_CURSOR_TYPE (pragma::SQLUINTEGER "SQL_CURSOR_TYPE"))
(defconstant SQL_CURSOR_FORWARD_ONLY (pragma::SQLUINTEGER "SQL_CURSOR_FORWARD_ONLY"))
(defconstant SQL_CURSOR_KEYSET_DRIVEN (pragma::SQLUINTEGER "SQL_CURSOR_KEYSET_DRIVEN"))
(defconstant SQL_CURSOR_DYNAMIC (pragma::SQLUINTEGER "SQL_CURSOR_DYNAMIC"))
(defconstant SQL_CURSOR_STATIC (pragma::SQLUINTEGER "SQL_CURSOR_STATIC"))

(defconstant SQL_KEYSET_SIZE (pragma::SQLUINTEGER "SQL_KEYSET_SIZE"))

(defconstant SQL_FETCH_FIRST (pragma::SQLUINTEGER "SQL_FETCH_FIRST"))
(defconstant SQL_FETCH_NEXT (pragma::SQLUINTEGER "SQL_FETCH_NEXT"))

(defconstant SQL_CHAR (pragma::SQLUINTEGER "SQL_CHAR"))
(defconstant SQL_VARCHAR (pragma::SQLUINTEGER "SQL_VARCHAR"))
(defconstant SQL_LONGVARCHAR (pragma::SQLUINTEGER "SQL_LONGVARCHAR"))
(defconstant SQL_DECIMAL (pragma::SQLUINTEGER "SQL_DECIMAL"))
(defconstant SQL_NUMERIC (pragma::SQLUINTEGER "SQL_NUMERIC"))
(defconstant SQL_BIT (pragma::SQLUINTEGER "SQL_BIT"))
(defconstant SQL_TINYINT (pragma::SQLUINTEGER "SQL_TINYINT"))
(defconstant SQL_SMALLINT (pragma::SQLUINTEGER "SQL_SMALLINT"))
(defconstant SQL_INTEGER (pragma::SQLUINTEGER "SQL_INTEGER"))
(defconstant SQL_BIGINT (pragma::SQLUINTEGER "SQL_BIGINT"))
(defconstant SQL_REAL (pragma::SQLUINTEGER "SQL_REAL"))
(defconstant SQL_FLOAT (pragma::SQLUINTEGER "SQL_FLOAT"))
(defconstant SQL_DOUBLE (pragma::SQLUINTEGER "SQL_DOUBLE"))
(defconstant SQL_BINARY (pragma::SQLUINTEGER "SQL_BINARY"))
(defconstant SQL_VARBINARY (pragma::SQLUINTEGER "SQL_VARBINARY"))
(defconstant SQL_LONGVARBINARY (pragma::SQLUINTEGER "SQL_LONGVARBINARY"))
(defconstant SQL_DATE (pragma::SQLUINTEGER "SQL_DATE"))
(defconstant SQL_TIME (pragma::SQLUINTEGER "SQL_TIME"))
(defconstant SQL_TIMESTAMP (pragma::SQLUINTEGER "SQL_TIMESTAMP"))
(defconstant SQL_TYPE_DATE (pragma::SQLUINTEGER "SQL_TYPE_DATE"))
(defconstant SQL_TYPE_TIME (pragma::SQLUINTEGER "SQL_TYPE_TIME"))
(defconstant SQL_TYPE_TIMESTAMP (pragma::SQLUINTEGER "SQL_TYPE_TIMESTAMP"))

(defconstant SQL_BEST_ROWID (pragma::SQLUINTEGER "SQL_BEST_ROWID"))
(defconstant SQL_ROWVER (pragma::SQLUINTEGER "SQL_ROWVER"))
(defconstant SQL_SCOPE_CURROW (pragma::SQLUINTEGER "SQL_SCOPE_CURROW"))
(defconstant SQL_SCOPE_TRANSACTION (pragma::SQLUINTEGER "SQL_SCOPE_TRANSACTION"))
(defconstant SQL_SCOPE_SESSION (pragma::SQLUINTEGER "SQL_SCOPE_SESSION"))
(defconstant SQL_NO_NULLS (pragma::SQLUINTEGER "SQL_NO_NULLS"))
(defconstant SQL_NULLABLE (pragma::SQLUINTEGER "SQL_NULLABLE"))

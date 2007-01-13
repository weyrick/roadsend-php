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

(module php-sqlite-lib
   (include "../phpoo-extension.sch")   
   (library profiler)
   (import (sqlite3-c-bindings "sqlite3-bindings.scm"))
   
   (extern
    ; this throws a warning since we define it in sqlite3-c-bindings too,
    ; but apparently it needs to be in both places because of the external
    ; decl we make here, and because it's use in sqlite3-bindings for several
    ; functions there as well
    (type sqlite3_context* (opaque) "sqlite3_context *")
    (type sqlite3_value* (opaque) "sqlite3_value *")
    (type sqlite3_value** (pointer sqlite3_value*) "sqlite3_value **")
    (export sqlite-generic-callback "pcc_generic_callback")
    (export sqlite-function-callback "pcc_function_callback")
    (export sqlite-aggregate-step "pcc_aggregate_step")
    (export sqlite-aggregate-finalize "pcc_aggregate_finalize"))
   
   (export
    (init-php-sqlite-lib)
    
    (sqlite-generic-callback context::sqlite3_context* num-args::int arglist::sqlite3_value**)
    (sqlite-function-callback context::sqlite3_context* num-args::int arglist::sqlite3_value**)
    (sqlite-aggregate-step context::sqlite3_context* num-args::int arglist::sqlite3_value**)
    (sqlite-aggregate-finalize context::sqlite3_context* num-args::int arglist::sqlite3_value**)
   
     ; PHP API
     (sqlite_array_query link query fetch-type decode-binary)
     (sqlite_busy_timeout link ms)
     (sqlite_changes link)
     (sqlite_open filename mode errmsg)
     (sqlite_close link)
     (sqlite_column result col decode-binary)
     (sqlite_create_aggregate link func-name step-callback finalize-callback num-args)
     (sqlite_create_function link func-name callback num-args)
     (sqlite_current result fetch-type decode-binary)     
     (sqlite_error_string link)
     (sqlite_escape_string str)
     (sqlite_exec link query errmsg)
     (sqlite_fetch_all result fetch-type decode-binary)
     (sqlite_fetch_array result fetch-type decode-binary)
     (sqlite_fetch_column_types table link fetch-type)
     (sqlite_fetch_object result class-name cstr-args decode-binary)
     (sqlite_fetch_single result decode-binary)
     (sqlite_field_name result col)     
     (sqlite_has_more result)
     (sqlite_has_prev result)
     (sqlite_key result)     
     (sqlite_last_error link)
     (sqlite_last_insert_rowid link)
     (sqlite_libencoding)
     (sqlite_libversion)
     (sqlite_next result)
     (sqlite_num_fields result)
     (sqlite_num_rows result)   
     (sqlite_prev result)
     (sqlite_query link query fetch-type errmsg)
     (sqlite_rewind result)
     (sqlite_seek result row)
     (sqlite_single_query link query only-first decode-binary)
     (sqlite_udf_decode_binary str)
     (sqlite_udf_encode_binary str)
     (sqlite_unbuffered_query link query fetch-type errmsg)
     
     SQLITE_ASSOC
     SQLITE_NUM
     SQLITE_BOTH

     SQLITE_VERSION
     SQLITE_VERSION_NUMBER
     SQLITE_OK             
     SQLITE_ERROR       
     SQLITE_INTERNAL      
     SQLITE_PERM          
     SQLITE_ABORT         
     SQLITE_BUSY          
     SQLITE_LOCKED        
     SQLITE_NOMEM         
     SQLITE_READONLY      
     SQLITE_INTERRUPT     
     SQLITE_IOERR         
     SQLITE_CORRUPT       
     SQLITE_NOTFOUND      
     SQLITE_FULL          
     SQLITE_CANTOPEN      
     SQLITE_PROTOCOL      
     SQLITE_EMPTY         
     SQLITE_SCHEMA        
     SQLITE_TOOBIG        
     SQLITE_CONSTRAINT    
     SQLITE_MISMATCH      
     SQLITE_MISUSE        
     SQLITE_NOLFS         
     SQLITE_AUTH          
     SQLITE_FORMAT        
     SQLITE_RANGE         
     SQLITE_NOTADB        
     SQLITE_ROW           
     SQLITE_DONE          
     SQLITE_COPY         
     
    ) 
   (eval    (export-all))   )



(define (init-php-sqlite-lib)
   1)

(define (unpassed? var)
   (eqv? var 'unpassed))

(define (passed? var)
   (not (unpassed? var)))

(default-ini-entry "sqlite.assoc_case" 0)

; register the extension
(register-extension "sqlite" "1.0.0"
                    "php-sqlite" '("-lsqlite3"))


(defresource sqlite-link "sqlite database"
   hnd
   state
   active-result)


(define (make-new-sqlite-link)
   (sqlite-link-resource #f
			 'dead
			 #f))

(defresource sqlite-result "sqlite result"
   stmt       ; handle to statement 
   my-link    ; our link
   fetch-type
   num-cols
   num-rows
   cur-row
   colnames
   data-table
   buffered?
   done?      ; sqlite3_step returned R_SQLITE_DONE
   freed?)

(define (active-result? result)
   (and (sqlite-result? result)
	(not (sqlite-result-freed? result))))

(define (new-sqlite-result link)
   (let ((new-result (sqlite-result-resource #f
					     link
					     SQLITE_BOTH
					     0   ; num cols
					     0   ; num rows
					     0   ; cur row
					     '() ; colnames
					     '() ; data table
					     #t  ; buffered
					     #f  ; done
					     #f))) ; freed
      new-result))

(define *sqlite-result-counter* 0)
(define (make-new-sqlite-result link)
   (when (> *sqlite-result-counter* 255) ; ARB
      (gc-force-finalization (lambda () (<= *sqlite-result-counter* 255))))
   (let ((result (new-sqlite-result link)))
      (set! *sqlite-result-counter* (+ *sqlite-result-counter* 1))
      (register-finalizer! result (lambda (result)
				     (unless (sqlite-result-freed? result)
					; sqlite-free-result will lower the counter
					(sqlite-free-result result))))
      result))

(define (sqlite-free-result result)
   (sqlite3_finalize (sqlite-result-stmt result))
   (sqlite-result-freed?-set! result #t)
   (set! *sqlite-result-counter* (- *sqlite-result-counter* 1)))

(define (ensure-link benefactor link)
   (if (and (sqlite-link? link)
	    (eqv? (sqlite-link-state link) 'active))
       link
       (begin
 	  ; remember kids, this might return if *disable-errors* was true!
 	  (php-warning (format "~a(): supplied argument is not a valid sqlite link resource" benefactor)))))

; this is returned from sqlite3_column_text which we use to pull results
(define (buchar->bstring str::uchar*)
   (if (pragma::bool "$1 == NULL" str)
       NULL
       (pragma::string "$1" str)))

; bind a result statement - get column names, number of rows, etc
; if it's a buffered query, get all the results too
(define (sqlite-bind-results result buf?)
   (bind-exit (return)
      ; buffered?
      (sqlite-result-buffered?-set! result buf?)
      ; num cols
      (sqlite-result-num-cols-set! result (sqlite3_column_count (sqlite-result-stmt result)))
      ; current row
      (sqlite-result-cur-row-set! result 0)
      ; column names
      (when (> (sqlite-result-num-cols result) 0)
	 (let ((colarray (make-vector (sqlite-result-num-cols result))))
	    (let loop ((n 0))
	       (when (< n (sqlite-result-num-cols result))
		  (vector-set! colarray n (sqlite3_column_name (sqlite-result-stmt result) n))
		  (loop (+ n 1))))
	    (sqlite-result-colnames-set! result colarray)))
      ; if buffered, get the results
      (if buf?
	 (let ((data (make-vector 16)))
	    (let row-loop ((r 0))
	       (let ((rval (sqlite3_step (sqlite-result-stmt result))))
		  (if (= rval R_SQLITE_ROW)
		      (let ((row-data (make-vector (sqlite-result-num-cols result))))			 
			 ; increase table size?
			 (when (> r (vector-length data))
			    ; XXX is this too expensive?
			    (set! data (copy-vector data (* (vector-length data) 2))))
			 ; get results for this row
			 (sqlite-pull-row! result row-data)
			 (vector-set! data r row-data)
			 ; on to next row
			 (row-loop (+ r 1)))
		      ;
		      ; not ROW
		      ;
		      (if (= rval R_SQLITE_DONE)
			  (sqlite-result-num-rows-set! result r)
			  ; some badness
			  (begin
			     (php-warning (sqlite3_errmsg (sqlite-link-hnd (sqlite-result-my-link result))))
			     (return #f))))))
	    (sqlite-result-done?-set! result #t)
	    (sqlite-result-data-table-set! result data)
	    #t)
	 ; unbuffered
	 ; make enough room in the data vector for one row at a time
	 (begin
	    (let ((data (make-vector 1))
		  (row-data (make-vector (sqlite-result-num-cols result))))
	       (let col-loop ((c 0))
		  (when (< c (sqlite-result-num-cols result))
		     (vector-set! row-data c #f)
		     (col-loop (+ c 1))))
	       ; empty columns for this row
	       (vector-set! data 0 row-data)
	       ; single row
	       (sqlite-result-data-table-set! result data)
	       ; get first row
	       (let ((retval (sqlite-next-unbuf-row result)))
		  (if retval
		      #t
		      ; no more rows, or error. setting cur-row to
		      ; num rows has the effect of ending the result set
		      (begin
			 (sqlite-result-cur-row-set! result 0)
			 (sqlite-result-num-rows-set! result 0)
			 #f))))))))

; loop through colums, pull current row from result into vector in row-data
(define (sqlite-pull-row! result row-data)
   (let col-loop ((c 0))
      (when (< c (sqlite-result-num-cols result))
	 (vector-set! row-data c (buchar->bstring
				  (sqlite3_column_text (sqlite-result-stmt result) c)))
	 (col-loop (+ c 1)))))

; pull the next row for unbuffered queries. may return #f if there
; was a problem
(define (sqlite-next-unbuf-row result)
   (let ((rval (sqlite3_step (sqlite-result-stmt result))))
      (if (= rval R_SQLITE_ROW)
	  (begin
	     ; get results for this row
	     (sqlite-pull-row! result (vector-ref (sqlite-result-data-table result) 0))
	     (sqlite-result-num-rows-set! result (+ (sqlite-result-num-rows result) 1))
	     #t)
	  ;
	  ; not ROW
	  ;
	  (begin
	     ; if it wasn't ROW, then we're always done
	     (sqlite-result-done?-set! result #t)
	     (if (= rval R_SQLITE_DONE)
		 ; natural end to result set
		 #f
		 ; some badness
		 (begin
		    (php-warning (sqlite3_errmsg (sqlite-link-hnd (sqlite-result-my-link result))))
		    #f))))))

(define (sqlite-fetch-array result fetch-type decode-binary? inc-row?)
   (let* ((rarr (make-php-hash))
	  (r (sqlite-result-cur-row result))
	  (ncols (sqlite-result-num-cols result))
	  (ftype (if (and (passed? fetch-type)
			  (or (php-= fetch-type SQLITE_NUM)
			      (php-= fetch-type SQLITE_ASSOC)
			      (php-= fetch-type SQLITE_BOTH)))
		     fetch-type
		     (sqlite-result-fetch-type result))))
      ; fill columns from current row
      (let cloop ((c 0))
	 (when (< c ncols)
	    (let ((col-name (vector-ref (sqlite-result-colnames result) c))
		  (row-arr (vector-ref (sqlite-result-data-table result) r))
		  (key-case (mkfixnum (get-ini-entry "sqlite.assoc_case")))
		  (val #f))
	       (set! val (vector-ref row-arr c))
	       (when (and decode-binary?
			  (string? val))
		  (set! val (sqlite-decode-binary val)))
	       (cond ((= key-case 1)
		      (string-upcase! col-name))
		     ((= key-case 2)
		      (string-downcase! col-name)))
	       (when (or (php-= ftype SQLITE_NUM)
			 (php-= ftype SQLITE_BOTH))
		  (php-hash-insert! rarr
				    ; col #
				    (convert-to-number c)
				    ; col val for this row
				    val))
	       (when (or (php-= ftype SQLITE_ASSOC)
			 (php-= ftype SQLITE_BOTH))
		  (php-hash-insert! rarr
				    ; col name
				    col-name
				    ; col val for this row
				    val))
	       (cloop (+ c 1)))))
      ; maybe increase current row
      (when inc-row?
	 (if (sqlite-result-buffered? result)
	     ; buffered, change index
	     (sqlite-result-cur-row-set! result (+ r 1))
	     ; unbuffered, pull next row if we can
	     (let ((retval (sqlite-next-unbuf-row result)))
		(unless retval
		   ; no more rows, or error. setting cur-row to
		   ; num rows has the effect of ending the result set
		   (sqlite-result-cur-row-set! result (sqlite-result-num-rows result))))))
      ; return filled array
      rarr))

(define (sqlite-fetch-column result col decode-binary?)
   (let ((r (sqlite-result-cur-row result))
	 (ncols (sqlite-result-num-cols result)))
      ; find specific column, which may be string or int
      (let cloop ((c 0))
	 (let ((col-name (vector-ref (sqlite-result-colnames result) c))
	       (row-arr (vector-ref (sqlite-result-data-table result) r)))
	    (if (or (and (string? col)
			 (string=? col-name col))
		    (and (number? col)
			 (= col c)))
		; found
		(vector-ref row-arr c)
		; not found, loop if more columns, else give up
		(if (< (+ c 1) ncols)
		    (cloop (+ c 1))
		    (php-warning (format "No such column: ~a" col))))))))


(define (is-bin-str? str)
   (if (> (string-length str) 0)
       (or (char=? (string-ref str 0) #a001)
	   (string-contains str (string #a000)))
       #f))
   
(define (is-encoded-str? str)
   (if (> (string-length str) 0)   
       (char=? (string-ref str 0) #a001)
       #f))

(define (sqlite-encode-binary str)
   (if (> (string-length str) 0)
       (if (is-bin-str? str)
	   ; formula is ( ((str-len/254)+1) * 257 ) + 3
	   (let ((ret (make-string (mkfixnum (ceiling (+ (* (+ (/ (string-length str) 254) 1) 257) 3))))))
	      (string-set! ret 0 #a001)
	      (let ((enclen (sqlite_encode_binary (pragma::uchar* "$1" ($bstring->string str))
						  (string-length str)
						  (pragma::uchar* "$1+1" ($bstring->string ret)))))
		 (substring ret 0 (+ enclen 1))))
	   str)
       ""))
   
(define (sqlite-decode-binary str)
   (if (> (string-length str) 0)   
       (if (is-encoded-str? str)
	   (let* ((ret (make-string (string-length str)))
		  (enclen (sqlite_decode_binary (pragma::uchar* "$1+1" ($bstring->string str))
						(pragma::uchar* "$1" ($bstring->string ret)))))
	      (substring ret 0 enclen))
	   str)
       ""))


(define (sqlite-query link query fetch-type errmsg buffered?)
   (let* ((newstmt (pragma::sqlite3_stmt* "NULL"))
	  (sql     (mkstr query))
	  (sqlTail (pragma::string* "&$1" ($bstring->string sql)))
	  ;
	  ; XXX sql is not UTF8 as per docs
	  ;
	  (result (sqlite3_prepare (sqlite-link-hnd link)
				   sql
				   (string-length sql)
				   (pragma::sqlite3_stmt** "&$1" newstmt)
				   sqlTail)))
      ;
      ; XXX this ignores sqlTail and only runs the first query
      ;     php runs all the queries, but only if they don't use a result, or something
      ;     
      ;     sqlite_exec always runs all queries
      ;
      (if (= result R_SQLITE_OK)
	  (let ((new-result (make-new-sqlite-result link)))
	     (sqlite-result-stmt-set! new-result newstmt)
	     (sqlite-result-fetch-type-set! new-result fetch-type)
	     (sqlite-bind-results new-result buffered?)
	     new-result)
; 	     (let ((retval (sqlite-bind-results new-result buffered?)))
; 		(if retval
; 		    new-result
; 		    ; badness
; 		    (begin
; 		       (sqlite3_finalize newstmt)
; 		       #f))))
	  ; failed prepare
	  (begin
	     (when (passed? errmsg)
		(container-value-set! errmsg (sqlite3_errmsg (sqlite-link-hnd link))))
	     ; ??
	     ;(sqlite3_finalize newstmt)			   
	     #f))))   

; returns valid PHP value based on the type of argument
; that sqlite says we have
(define (sqlite-get-udf-arg arg::sqlite3_value** n::int)
   (let* ((val-arg (pragma::sqlite3_value* "$1[$2]" arg n))
	  (val-type (sqlite3_value_type val-arg)))
      (cond ((eqv? val-type R_SQLITE_INTEGER)
	     (convert-to-integer (sqlite3_value_int val-arg)))
	    ((eqv? val-type R_SQLITE_FLOAT)
	     (convert-to-float (sqlite3_value_double val-arg)))
	    ((or (eqv? val-type R_SQLITE_TEXT)
		 (eqv? val-type R_SQLITE_BLOB))
	     (buchar->bstring (sqlite3_value_text val-arg)))
	    ((eqv? val-type R_SQLITE_NULL)
	     NULL))))

; run the actual php callback function and update result using provided context
; it will catch runtime errors and set the result to error accordingly
(define (run-php-sqlite-callback func args context::sqlite3_context*)
   (try
    (let ((retval (maybe-unbox (apply php-callback-call func args))))
       ; XXX this is great, but it actually doesn't matter currently since
       ; results are always pulled as strings. should we change that?
       (cond (; string
	      (string? retval) (sqlite3_result_text context
						    retval
						    (string-length retval)
						    R_SQLITE_TRANSIENT))
	     ; float
	     ((and (php-number? retval) (onum-float? retval))
	      (sqlite3_result_double context
				     (onum->float retval)))
	     ; int
	     ((and (php-number? retval) (onum-long? retval))
	      (sqlite3_result_int context
				  (mkfixnum retval)))
	     (else
	      (sqlite3_result_null context)))
       #t)
    ; function had a runtime error
    (lambda (e p m o)
       (sqlite3_result_error context m (string-length m))
       #f)))

; this is called from the "php" UDF we register when a connection is opened
(define (sqlite-generic-callback context::sqlite3_context* num-args::int arglist::sqlite3_value**)
   (let ((func-args (let loop ((n 0)
			       (alist '()))
		       (if (< n num-args)
			   (loop (+ n 1) (cons (sqlite-get-udf-arg arglist n) alist))
			   (reverse alist)))))
      (let ((sig (get-php-function-sig (mkstr (car func-args)))))
	 (if sig
	     (run-php-sqlite-callback (mkstr (car func-args)) (cdr func-args) context)
	     ; no function
	     (let ((errmsg (format "unable to call unknown function ~a" (car func-args))))
		(sqlite3_result_error context errmsg (string-length errmsg))
		#f)))))

; custom normal
(define (sqlite-function-callback context::sqlite3_context* num-args::int arglist::sqlite3_value**)
   (let ((func-name (pragma::string "(char*)sqlite3_user_data($1)" context))
	 (func-args (let loop ((n 0)
			       (alist '()))
		       (if (< n num-args)
			   (loop (+ n 1) (cons (sqlite-get-udf-arg arglist n) alist))
			   (reverse alist)))))
      (run-php-sqlite-callback func-name func-args context)))

; custom aggregate step
(define (sqlite-aggregate-step context::sqlite3_context* num-args::int arglist::sqlite3_value**)
   (let* ((udata (pragma::pair "(obj_t*)sqlite3_user_data($1)" context))
	  (func-name (car udata))
	  (uctxt (caddr udata))
	  (func-args (let loop ((n 0)
				(alist '()))
			(if (< n num-args)
			    (loop (+ n 1) (cons (sqlite-get-udf-arg arglist n) alist))
			    (reverse alist)))))
      (run-php-sqlite-callback func-name (cons uctxt func-args) context)))

; custom aggregate finalize
(define (sqlite-aggregate-finalize context::sqlite3_context* num-args::int arglist::sqlite3_value**)
   (let* ((udata (pragma::pair "(obj_t*)sqlite3_user_data($1)" context))
	  (func-name (cadr udata))
	  (uctxt (caddr udata)))
      (run-php-sqlite-callback func-name (list uctxt) context)))


;; FUNCTIONS

; sqlite_array_query -- Execute a query against a given database and returns an array
(defbuiltin (sqlite_array_query link query (fetch-type 'unpassed) (decode-binary #t))
   ; sigh. php allows a swapped order.
   (when (string? link)
      (let ((tq query))
	 (set! query link)
	 (set! link tq)))
   ; down to business
   (let ((rlink (ensure-link 'sqlite_array_query link)))
      (if rlink
	  (let* ((errmsg (make-container ""))
		 (ftype (if (passed? fetch-type)
			    fetch-type
			    SQLITE_BOTH))
		 (rh (sqlite_query link query ftype errmsg)))
	     (if rh
		 (let ((rarr (make-php-hash)))		       
		    (let rloop ((val (sqlite_fetch_array rh ftype decode-binary)))
		       (when val
			  (php-hash-insert! rarr :next val)
			  (rloop (sqlite_fetch_array rh ftype decode-binary))))
		    rarr)
		 #f))
	  #f)))

; sqlite_busy_timeout -- Set busy timeout duration, or disable busy handlers
(defbuiltin (sqlite_busy_timeout link ms)
   (let ((rlink (ensure-link 'sqlite_changes link)))
      (if rlink   
	  (sqlite3_busy_timeout (sqlite-link-hnd link) (mkfixnum ms))
	  #f)))

; sqlite_changes --  Returns the number of rows that were changed by the most recent SQL statement
(defbuiltin (sqlite_changes link)
   (let ((rlink (ensure-link 'sqlite_changes link)))
      (if rlink
	  (convert-to-number (sqlite3_changes (sqlite-link-hnd rlink)))
	  *zero*)))

; sqlite_close -- Closes an open SQLite database
(defbuiltin (sqlite_close link)
   (let ((rlink (ensure-link 'sqlite_close link)))
      (if rlink
	  (begin
	     (sqlite3_close (sqlite-link-hnd rlink))
	     (sqlite-link-state-set! rlink 'dead)
	     NULL)
	  #f)))

; sqlite_column -- Fetches a column from the current row of a result set
(defbuiltin (sqlite_column result col (decode-binary #t))
   (if (active-result? result)
       (sqlite-fetch-column result
			    (if (string? col)
				col
				(mkfixnum col))
			    (convert-to-boolean decode-binary))
       NULL))
   
; sqlite_create_aggregate -- Register an aggregating UDF for use in SQL statements
(defbuiltin (sqlite_create_aggregate link func-name step-callback finalize-callback (num-args -1))
   (let ((rlink (ensure-link 'sqlite_create_aggregate link)))
      (if rlink
	  (let ((sig1 (get-php-function-sig (mkstr step-callback)))
		(sig2 (get-php-function-sig (mkstr finalize-callback))))
	     (if (and sig1 sig2)
		 (let* ((udata (list step-callback finalize-callback (make-container NULL))) 
			(retval (sqlite_custom_aggregate (sqlite-link-hnd link)
							 ($bstring->string (mkstr func-name))
							 udata
							 (mkfixnum num-args)
							 )))
		    (if (= retval R_SQLITE_OK)
			#t
			(php-warning (sqlite3_errmsg (sqlite-link-hnd link)))))
		 (php-warning (format "~a or ~a is not a callable function"
				      (mkstr step-callback)
				      (mkstr finalize-callback)))))
	  #f)))

; sqlite_create_function --  Registers a "regular" User Defined Function for use in SQL statements
(defbuiltin (sqlite_create_function link func-name callback (num-args -1))
   (let ((rlink (ensure-link 'sqlite_create_function link)))
      (if rlink
	  (let ((sig (get-php-function-sig (mkstr callback))))
	     (if sig
		 (let ((retval (sqlite_custom_function (sqlite-link-hnd link)
						       ($bstring->string (mkstr func-name))
						       ($bstring->string (mkstr callback))
						       (mkfixnum num-args)
						       )))
		    (if (= retval R_SQLITE_OK)
			#t
			(php-warning (sqlite3_errmsg (sqlite-link-hnd link)))))
		 (php-warning (format "~a is not a callable function" (mkstr callback)))))
	  #f)))
	  
; sqlite_current -- Fetches the current row from a result set as an array
(defbuiltin (sqlite_current result (fetch-type 'unpassed) (decode-binary #t))
   (if (active-result? result)
       (if (>= (sqlite-result-cur-row result) (sqlite-result-num-rows result))
	   #f
	   (sqlite-fetch-array result fetch-type (convert-to-boolean decode-binary) #f))
       #f))

; sqlite_error_string -- Returns the textual description of an error code
(defbuiltin (sqlite_error_string link)
   (let ((rlink (ensure-link 'sqlite_error_string link)))
      (if rlink
	  (sqlite3_errmsg (sqlite-link-hnd rlink))
	  "")))

; sqlite_escape_string -- Escapes a string for use as a query parameter
(defbuiltin (sqlite_escape_string str)
   (if (is-bin-str? str)
       (sqlite-encode-binary str)
       (let ((qstr (sqlite3_mprintf "%q" str)))
	  ; we have to free this ourselves since sqlite mallocs it
	  (let ((rqstr (string-copy qstr)))
	     (sqlite3_free qstr)
	     rqstr))))

; sqlite_exec --  Executes a result-less query against a given database
(defbuiltin (sqlite_exec link query ((ref . errmsg) 'unpassed))
   ; sigh. php allows a swapped order.
   (when (string? link)
      (let ((tq query))
	 (set! query link)
	 (set! link tq)))
   ; down to business
   (let ((rlink (ensure-link 'sqlite_exec link)))
      (if rlink
	  ; we loop because there can be more than one query separated by ;
	  (let loop ((sql (mkstr query)))
	     (let* ((newstmt (pragma::sqlite3_stmt* "NULL"))
		    (sqlTail (pragma::string* "&$1" ($bstring->string sql)))
		    ;
		    ; XXX sql is not UTF8 as per docs
		    ;
		    (result (sqlite3_prepare (sqlite-link-hnd link)
					     sql
					     (string-length sql)
					     (pragma::sqlite3_stmt** "&$1" newstmt)
					     sqlTail)))
		(if (= result R_SQLITE_OK)
		    ; execute query
		    (let ((e-result (sqlite3_step newstmt)))
		       (if (= e-result R_SQLITE_DONE)
			   ; success, finalize and return
			   (begin
			      (sqlite3_finalize newstmt)
			      ; there may be more data in sqlTail if we had multiple statements
			      ;
			      ; XXX is this safe?? 
			      ;
			      (let ((leftover (pragma::string "*$1" sqlTail)))
				 (if (> (string-length leftover) 0)
				     (loop leftover)
				     #t)))
			   ; failure
			   (begin
			      (when (passed? errmsg)
				 (container-value-set! errmsg (sqlite3_errmsg (sqlite-link-hnd link))))
			      (sqlite3_finalize newstmt)			   
			      #f)))
		    ; failed prepare
		    (begin
		       (when (passed? errmsg)
			  (container-value-set! errmsg (sqlite3_errmsg (sqlite-link-hnd link))))
		       #f)))
	     ) ; loop
	  
	  ; bad link
	  #f)))

; sqlite_factory --  Opens a SQLite database and creates an object for it

; sqlite_fetch_all --  Fetches all rows from a result set as an array of arrays
(defbuiltin (sqlite_fetch_all result (fetch-type 'unpassed) (decode-binary #t))
   (if (active-result? result)
       (let ((rarr (make-php-hash))
	     (ftype (if (passed? fetch-type)
			fetch-type
			SQLITE_BOTH)))
	  (let rloop ((val (sqlite_fetch_array result ftype decode-binary)))
	     (when val
		(php-hash-insert! rarr :next val)
		(rloop (sqlite_fetch_array result ftype decode-binary))))
	  rarr)       
       #f))

; sqlite_fetch_array -- Fetches the next row from a result set as an array
(defbuiltin (sqlite_fetch_array result (fetch-type 'unpassed) (decode-binary #t))
   (if (active-result? result)
       (if (>= (sqlite-result-cur-row result) (sqlite-result-num-rows result))
	   #f
	   (sqlite-fetch-array result fetch-type (convert-to-boolean decode-binary) #t))
       #f))
   
; sqlite_fetch_column_types --  Return an array of column types from a particular table
(defbuiltin (sqlite_fetch_column_types table link (fetch-type 'unpassed))
   (let ((rlink (ensure-link 'sqlite_fetch_column_types link)))
      (if rlink
	  (let* ((rarr (make-php-hash))
		 (sql (sqlite_escape_string (mkstr "PRAGMA table_info(" table ")")))
		 (errmsg (make-container ""))
		 (ftype (if (passed? fetch-type)
			    fetch-type
			    SQLITE_ASSOC))	 
		 (rh (sqlite_query rlink sql ftype errmsg)))
	     (if rh
		 (begin
		    (let rloop ((val (sqlite_fetch_array rh SQLITE_ASSOC #f)))
		       (when val
			  (when (or (php-= ftype SQLITE_NUM)
				    (php-= ftype SQLITE_BOTH))
			     (php-hash-insert! rarr
					       ; col #
					       (php-hash-lookup val "cid")
					       ; type
					       (php-hash-lookup val "type")))
			  (when (or (php-= ftype SQLITE_ASSOC)
				    (php-= ftype SQLITE_BOTH))
			     (php-hash-insert! rarr
					       (php-hash-lookup val "name")
					       ; type
					       (php-hash-lookup val "type")))
			  (rloop (sqlite_fetch_array rh SQLITE_ASSOC #f))))
		    rarr)
		 #f))
	  #f)))

; sqlite_fetch_object --  Fetches the next row from a result set as an object
;
; XXX we ignore class-name and cstr-args and return a stdclass
;
(defbuiltin (sqlite_fetch_object result (class-name 'unpassed) (cstr-args 'unpassed) (decode-binary #t))
   (if (active-result? result)
       (if (>= (sqlite-result-cur-row result) (sqlite-result-num-rows result))
	   #f
	   (convert-to-object (sqlite-fetch-array result SQLITE_ASSOC (convert-to-boolean decode-binary) #t)))
       #f))

; sqlite_fetch_single -- Fetches the first column of a result set as a string
(defbuiltin (sqlite_fetch_single result (decode-binary #t))
   (if (active-result? result)
       (if (>= (sqlite-result-cur-row result) (sqlite-result-num-rows result))
	   #f
	   (let ((r (sqlite-fetch-array result SQLITE_NUM (convert-to-boolean decode-binary) #t)))
	      (php-hash-lookup r (convert-to-number 0))))
       #f))

; sqlite_fetch_string -- Alias of sqlite_fetch_single()
(defalias sqlite_fetch_string sqlite_fetch_single)

; sqlite_field_name -- Returns the name of a particular field
(defbuiltin (sqlite_field_name result col)
   (if (active-result? result)
       (let ((coln (mkfixnum col)))
	  (if (and (< coln (sqlite-result-num-cols result))
		   (>= coln 0))
	      (vector-ref (sqlite-result-colnames result) coln)
	      (php-warning (format "Column index out of range: ~a" coln))))
       NULL))
   
; sqlite_has_more -- Returns whether or not more rows are available
(defbuiltin (sqlite_has_more result)
   (if (active-result? result)
       (convert-to-boolean (< (sqlite-result-cur-row result) (sqlite-result-num-rows result)))
       #f))

; sqlite_has_prev -- Returns whether or not a previous row is available
(defbuiltin (sqlite_has_prev result)
   (if (active-result? result)
       (if (sqlite-result-buffered? result)
	   (convert-to-boolean (> (sqlite-result-cur-row result) 0))
	   (php-warning "Unavailable for use with unbuffered sqlite result set"))))

; sqlite_key -- returns the current row index of the buffered result set result
(defbuiltin (sqlite_key result)
   (if (active-result? result)
       (if (sqlite-result-buffered? result)
	   (convert-to-number (sqlite-result-cur-row result))
	   (php-warning "Unavailable get current row index with unbuffered sqlite result set"))))

; sqlite_last_error -- Returns the error code of the last error for a database
(defbuiltin (sqlite_last_error link)
   (let ((rlink (ensure-link 'sqlite_last_error link)))
      (if rlink
	  (convert-to-number (sqlite3_errcode (sqlite-link-hnd rlink)))
	  #f)))

; sqlite_last_insert_rowid -- Returns the rowid of the most recently inserted row
(defbuiltin (sqlite_last_insert_rowid link)
   (let ((rlink (ensure-link 'sqlite_last_insert_rowid link)))
      (if rlink
	  (convert-to-number (sqlite3_last_insert_rowid (sqlite-link-hnd link)))
	  #f)))

; sqlite_libencoding -- Returns the encoding of the linked SQLite library
(defbuiltin (sqlite_libencoding)
   ; sqlite3 is always UTF8
   "UTF-8")

; sqlite_libversion -- Returns the version of the linked SQLite library
(defbuiltin (sqlite_libversion)
   (pragma::string "sqlite3_version"))
   
; sqlite_next -- Seek to the next row number
(defbuiltin (sqlite_next result)
   (if (active-result? result)
       (begin
	  (when (and (not (sqlite-result-buffered? result))
		     (not (sqlite-result-done? result)))
	     (let ((retval (sqlite-next-unbuf-row result)))
		(unless retval 
		   (sqlite-result-cur-row-set! result (sqlite-result-num-rows result)))))
	  (if (>= (sqlite-result-cur-row result) (sqlite-result-num-rows result))
	      (php-warning "No more rows available")
	      (begin
		 (when (sqlite-result-buffered? result) 
		    (sqlite-result-cur-row-set! result (+ (sqlite-result-cur-row result) 1)))
		 #t)))
       #f))

; sqlite_num_fields -- Returns the number of fields in a result set
(defbuiltin (sqlite_num_fields result)
   (if (active-result? result)
       (convert-to-number (sqlite-result-num-cols result))
       #f))

; sqlite_num_rows -- Returns the number of rows in a buffered result set
(defbuiltin (sqlite_num_rows result)
   (if (active-result? result)
       (if (sqlite-result-buffered? result)
	   (convert-to-number (sqlite-result-num-rows result))
	   (php-warning "Unable to get row count with unbuffered sqlite result set"))))

; sqlite_popen --  Opens a persistent handle to an SQLite database and create the database if it does not exist
(defalias sqlite_popen sqlite_open)

; sqlite_open -- Opens a SQLite database and create the database if it does not exist
(defbuiltin (sqlite_open filename (mode 'unpassed) ((ref . errmsg) 'unpassed))
   (let* ((new-hnd (pragma::sqlite3* "NULL"))
	  (dbfile (mkstr filename))
	  (result (sqlite3_open dbfile
				(pragma::sqlite3** "&$1" new-hnd))))
      (if (= result R_SQLITE_OK)
	  (let ((new-link (make-new-sqlite-link)))
	     ; setup link resource
	     (sqlite-link-hnd-set! new-link new-hnd)
	     (sqlite-link-state-set! new-link 'active)
	     ; default timeout 1 minute
	     (sqlite3_busy_timeout new-hnd 60000) 
	     ; add generic function
	     (pragma "sqlite3_create_function($1, \"php\", -1, SQLITE_UTF8, NULL, pcc_generic_callback, NULL, NULL)"
		     new-hnd)
	     ; set file mode if passed
	     (when (and (passed? mode)
			(file-exists? dbfile))
		(pfl-chmod dbfile (mkfixnum mode)))
	     new-link)
	  (begin
	     (when (passed? errmsg)
		(container-value-set! errmsg (sqlite3_errmsg new-hnd)))
	     ; always have to free result
	     (sqlite3_close new-hnd)
	     #f))))

; sqlite_prev -- Seek to the previous row number of a result set
(defbuiltin (sqlite_prev result)
   (if (active-result? result)
       (if (sqlite-result-buffered? result)
	   (begin
	      (if (<= (sqlite-result-cur-row result) 0)
		  (php-warning "Already at first row")
		  (sqlite-result-cur-row-set! result (- (sqlite-result-cur-row result) 1))))
	   (php-warning "Unable to get previous row with unbuffered sqlite result set"))))

; sqlite_query --  Executes a query against a given database and returns a result handle
(defbuiltin (sqlite_query link query (fetch-type SQLITE_BOTH) ((ref . errmsg) 'unpassed))
   ; sigh. php allows a swapped order.
   (when (string? link)
      (let ((tq query))
	 (set! query link)
	 (set! link tq)))
   ; down to business
   (let ((rlink (ensure-link 'sqlite_query link)))
      (if rlink
	  (sqlite-query link query fetch-type errmsg #t)
	  #f)))
	  

; sqlite_rewind -- Seek to the first row number
(defbuiltin (sqlite_rewind result)
   (if (active-result? result)
       (if (sqlite-result-buffered? result)
	   (begin
	      (sqlite-result-cur-row-set! result 0)
	      #t)
	   (php-warning "Unable to rewind unbuffered sqlite result set"))))

; sqlite_seek -- Seek to a particular row number of a buffered result set
(defbuiltin (sqlite_seek result row)
   (if (active-result? result)
       (if (sqlite-result-buffered? result)
	   (let ((rrow (mkfixnum row)))
	      (if (and (< rrow (sqlite-result-num-rows result))
		       (>= rrow 0))
		  (sqlite-result-cur-row-set! result (mkfixnum rrow))
		  (php-warning "Requested row is out of range"))
	      #t)
	   (php-warning "Unable to seek with unbuffered sqlite result set"))))

; sqlite_single_query --  Executes a query and returns either an array for one single column or the value of the first row
(defbuiltin (sqlite_single_query link query (only-first #f) (decode-binary #t))
   ; sigh. php allows a swapped order.
   (when (string? link)
      (let ((tq query))
	 (set! query link)
	 (set! link tq)))
   ; down to business
   (let ((rlink (ensure-link 'sqlite_single_query link)))
      (if rlink
	  (let* ((errmsg (make-container ""))
		 (rh (sqlite_query link query SQLITE_NUM errmsg)))
	     (if rh
		 (let ((rarr (make-php-hash)))
		    (let rloop ((val (sqlite_fetch_single rh decode-binary)))
		       (when val
			  (php-hash-insert! rarr :next val)
			  (rloop (sqlite_fetch_single rh decode-binary))))
		    (if (and only-first
			     (= (php-hash-size rarr) 1))
			(php-hash-lookup rarr *zero*)
			rarr))
		 #f))
	  #f)))
   
; sqlite_udf_decode_binary -- Decode binary data passed as parameters to an UDF
(defbuiltin (sqlite_udf_decode_binary str)
   (sqlite-decode-binary str))
 
; sqlite_udf_encode_binary -- Encode binary data before returning it from an UDF
(defbuiltin (sqlite_udf_encode_binary str)
   (sqlite-encode-binary str))

; sqlite_unbuffered_query -- Execute a query that does not prefetch and buffer all data
(defbuiltin (sqlite_unbuffered_query link query (fetch-type SQLITE_BOTH) ((ref . errmsg) 'unpassed))
   ; sigh. php allows a swapped order.
   (when (string? link)
      (let ((tq query))
	 (set! query link)
	 (set! link tq)))
   ; down to business
   (let ((rlink (ensure-link 'sqlite_query link)))
      (if rlink
	  (sqlite-query link query fetch-type errmsg #f)
	  #f)))

; sqlite_valid -- Returns whether more rows are available
(defalias sqlite_valid sqlite_has_more)

;; constants

(defconstant SQLITE_ASSOC         1)
(defconstant SQLITE_NUM           2)
(defconstant SQLITE_BOTH          3)

(defconstant SQLITE_VERSION        R_SQLITE_VERSION)
(defconstant SQLITE_VERSION_NUMBER R_SQLITE_VERSION_NUMBER)
(defconstant SQLITE_OK             R_SQLITE_OK)
(defconstant SQLITE_ERROR          R_SQLITE_ERROR)
(defconstant SQLITE_INTERNAL       R_SQLITE_INTERNAL)
(defconstant SQLITE_PERM           R_SQLITE_PERM)
(defconstant SQLITE_ABORT          R_SQLITE_ABORT)
(defconstant SQLITE_BUSY           R_SQLITE_BUSY)
(defconstant SQLITE_LOCKED         R_SQLITE_LOCKED)
(defconstant SQLITE_NOMEM          R_SQLITE_NOMEM)
(defconstant SQLITE_READONLY       R_SQLITE_READONLY)
(defconstant SQLITE_INTERRUPT      R_SQLITE_INTERRUPT)
(defconstant SQLITE_IOERR          R_SQLITE_IOERR)
(defconstant SQLITE_CORRUPT        R_SQLITE_CORRUPT)
(defconstant SQLITE_NOTFOUND       R_SQLITE_NOTFOUND)
(defconstant SQLITE_FULL           R_SQLITE_FULL)
(defconstant SQLITE_CANTOPEN       R_SQLITE_CANTOPEN)
(defconstant SQLITE_PROTOCOL       R_SQLITE_PROTOCOL)
(defconstant SQLITE_EMPTY          R_SQLITE_EMPTY)
(defconstant SQLITE_SCHEMA         R_SQLITE_SCHEMA)
(defconstant SQLITE_TOOBIG         R_SQLITE_TOOBIG)
(defconstant SQLITE_CONSTRAINT     R_SQLITE_CONSTRAINT)
(defconstant SQLITE_MISMATCH       R_SQLITE_MISMATCH)
(defconstant SQLITE_MISUSE         R_SQLITE_MISUSE)
(defconstant SQLITE_NOLFS          R_SQLITE_NOLFS)
(defconstant SQLITE_AUTH           R_SQLITE_AUTH)
(defconstant SQLITE_FORMAT         R_SQLITE_FORMAT)
(defconstant SQLITE_RANGE          R_SQLITE_RANGE)
(defconstant SQLITE_NOTADB         R_SQLITE_NOTADB)
(defconstant SQLITE_ROW            R_SQLITE_ROW)
(defconstant SQLITE_DONE           R_SQLITE_DONE)
(defconstant SQLITE_COPY           R_SQLITE_COPY)

;; XXX these aren't in php?

; (defconstant "SQLITE_CREATE_INDEX" R_SQLITE_CREATE_INDEX)
; (defconstant "SQLITE_CREATE_TABLE" R_SQLITE_CREATE_TABLE)
; (defconstant "SQLITE_CREATE_TEMP_INDEX" R_SQLITE_CREATE_TEMP_INDEX)
; (defconstant "SQLITE_CREATE_TEMP_TABLE" R_SQLITE_CREATE_TEMP_TABLE)
; (defconstant "SQLITE_CREATE_TEMP_TRIGGER" R_SQLITE_CREATE_TEMP_TRIGGER)
; (defconstant "SQLITE_CREATE_TEMP_VIEW" R_SQLITE_CREATE_TEMP_VIEW)
; (defconstant "SQLITE_CREATE_TRIGGER" R_SQLITE_CREATE_TRIGGER)
; (defconstant "SQLITE_CREATE_VIEW" R_SQLITE_CREATE_VIEW)
; (defconstant R_SQLITE_DELETE"SQLITE_DELETE")
; (defconstant R_SQLITE_DROP_INDEX"SQLITE_DROP_INDEX")
; (defconstant R_SQLITE_DROP_TABLE"SQLITE_DROP_TABLE")
; (defconstant R_SQLITE_DROP_TEMP_INDEX"SQLITE_DROP_TEMP_INDEX")
; (defconstant R_SQLITE_DROP_TEMP_TABLE"SQLITE_DROP_TEMP_TABLE")
; (defconstant R_SQLITE_DROP_TEMP_TRIGGER"SQLITE_DROP_TEMP_TRIGGER")
; (defconstant R_SQLITE_DROP_TEMP_VIEW"SQLITE_DROP_TEMP_VIEW")
; (defconstant R_SQLITE_DROP_TRIGGER"SQLITE_DROP_TRIGGER")
; (defconstant R_SQLITE_DROP_VIEW"SQLITE_DROP_VIEW")
; (defconstant R_SQLITE_INSERT"SQLITE_INSERT")
; (defconstant R_SQLITE_PRAGMA"SQLITE_PRAGMA")
; (defconstant R_SQLITE_READ"SQLITE_READ")
; (defconstant R_SQLITE_SELECT"SQLITE_SELECT")
; (defconstant R_SQLITE_TRANSACTION"SQLITE_TRANSACTION")
; (defconstant R_SQLITE_UPDATE"SQLITE_UPDATE")
; (defconstant R_SQLITE_ATTACH"SQLITE_ATTACH")
; (defconstant R_SQLITE_DETACH"SQLITE_DETACH")
; (defconstant R_SQLITE_ALTER_TABLE"SQLITE_ALTER_TABLE")
; (defconstant R_SQLITE_REINDEX"SQLITE_REINDEX")
; (defconstant R_SQLITE_DENY"SQLITE_DENY")
; (defconstant R_SQLITE_IGNORE"SQLITE_IGNORE")
; (defconstant R_SQLITE_INTEGER"SQLITE_INTEGER")
; (defconstant R_SQLITE_FLOAT"SQLITE_FLOAT")
; (defconstant R_SQLITE_BLOB"SQLITE_BLOB")
; (defconstant R_SQLITE_NULL"SQLITE_NULL")
; (defconstant R_SQLITE_TEXT"SQLITE_TEXT")
; (defconstant R_SQLITE3_TEXT"SQLITE3_TEXT")
; (defconstant R_SQLITE_STATIC::int "SQLITE_STATIC")
; (defconstant R_SQLITE_TRANSIENT::int "SQLITE_TRANSIENT")
; (defconstant R_SQLITE_UTF8"SQLITE_UTF8")
; (defconstant R_SQLITE_UTF16LE"SQLITE_UTF16LE")
; (defconstant R_SQLITE_UTF16BE"SQLITE_UTF16BE")
; (defconstant R_SQLITE_UTF16"SQLITE_UTF16")
; (defconstant R_SQLITE_ANY"SQLITE_ANY")

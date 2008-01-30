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

(module php-mysql-lib
   (include "../phpoo-extension.sch")
   (library profiler)
   (import (mysql-c-bindings "c-bindings.scm"))
   (export
    MYSQL_ASSOC
    MYSQL_NUM 
    MYSQL_BOTH

    (init-php-mysql-lib)
    (php-mysql-affected-rows link)
    (php-mysql-change-user username password database link)
    (php-mysql-close link)
    (php-mysql-connect server username password new-link flags)
    (php-mysql-pconnect server username password flags)
;    (php-mysql-create-db name link) ; deprecated
    (php-mysql-data-seek result row-number)
    (mysql_db_query database-name query link)
;    (php-mysql-drop-db db-name link) ; deprecated
    (php-mysql-errno link)
    (php-mysql-error link)
    (php-mysql-escape-string str)
    (php-mysql-real-escape-string str link)
    (mysql_fetch_array result array-type)
    (mysql_fetch_assoc result)
    (php-mysql-fetch-field result offset)
    (php-mysql-fetch-lengths result)
    (mysql_fetch_object result array-type)
    (php-mysql-get-client-info)
    (php-mysql-get-server-info link)
    (php-mysql-get-host-info link)
    (php-mysql-get-proto-info link)
    (php-mysql-fetch-row result)
    (php-mysql-field-flags result offset)
    (php-mysql-field-name result offset)
    (php-mysql-field-len result offset)
    (php-mysql-field-seek result offset)
    (php-mysql-field-table result offset)
    (php-mysql-field-type result offset)
    (php-mysql-free-result result)
    (php-mysql-insert-id link)
    (php-mysql-list-dbs link)
    (php-mysql-list-fields db-name table-name link)
    (php-mysql-list-tables db-name link)
    (php-mysql-num-fields result)
    (php-mysql-num-rows result)    
    (php-mysql-query query link)
    (php-mysql-unbuffered-query query link)
    (php-mysql-result result row-num field)
    (php-mysql-select-db database-name link)
    ))

;;Notes
;
;most of the functions have aliases defined, because the names
;are so close to the names in c-bindings.defs, differing only in
;whether they use underscores or dashes.  
;
;instead of signalling an error, we conform to Zend dain bramage,
;and return true/false. (for the most part)
;
;the functions that just return '() are not yet implemented.  I'm
;also still confused about pconnect.  how's it different?


(define (init-php-mysql-lib)
   1)

; register the extension
(register-extension "mysql" "1.0.0" "php-mysql")

(define *null-string* 
   (pragma::string "((const char *)NULL)"))


(defresource mysql-link "mysql link"
   link
   state
   active-result)

(defresource mysql-result "mysql result"
   freed?
   result
   column-numbers
   column-names
   column-hashcodes)

(define *mysql-result-counter* 0)
(define (make-finalized-mysql-result result)
   (when (> *mysql-result-counter* 255) ; ARB
      (gc-force-finalization (lambda () (<= *mysql-result-counter* 255))))
   (let ((result (mysql-result-resource #f result #f #f #f)))
      (set! *mysql-result-counter* (+ *mysql-result-counter* 1))
      (register-finalizer! result (lambda (result)
                                     (unless (mysql-result-freed? result)
                                        (mysql-free-result (mysql-result-result result))
                                        ;(php-funcall 'mysql_free_result result)
                                        (set! *mysql-result-counter* (- *mysql-result-counter* 1)))))
      result))

;;;;Utilities

;;;ulonglong frobbing

;this sucks, hard.
(define (ulonglongify num)
   (flonum->llong (fixnum->flonum (mkfixnum num))))

;so does this.  you see, flonums are not exact.
(define (un-ulonglongify num)
   (flonum->fixnum (llong->flonum num)))


;;;Link Cache
(define *cache* (make-hashtable))
(define *last-link* #f)

(define (suitably-odd-key server username password)
   (mkstr server "<@~@>" username "<@~@>" password))

(define (store-link server username password link)
   (mysql-link-state-set! link 'alive)
   (set! *last-link* link)
   (hashtable-put! *cache*
		   (suitably-odd-key server username password)
		   link))

(define (fetch-link server username password)
   (let* ((key (suitably-odd-key server username password))
	  (link (hashtable-get *cache* key)))
      (if (and link (eqv? (mysql-link-state link) 'dead))
	  (begin
	     (hashtable-remove! *cache* key)
	     #f)
	  link)))

(define (fetch-last-link)
   (when (and *last-link*
	    (eqv? (mysql-link-state *last-link*) 'dead))
       (set! *last-link* #f))
   *last-link*)

(define (remove-link link)
;without the server/username/password, we can't
;easily lookup the link, so just set its state to
;dead, and pay for it on the other end.
   (mysql-link-state-set! link 'dead))


;;;Exit Function

;cleanup function to close any remaining open connections
(register-exit-function!
 (lambda (status)
    (hashtable-for-each *cache*
       (lambda (key link)
	  (unless (eqv? (mysql-link-state link) 'dead)
	     (mysql-close (mysql-link-link link)))))
    status))

 
;;;Default connection stuff

;For when there's no link passed, and no last link
(define (establish-default-link)
   (php-mysql-connect "localhost" *null-string* *null-string* *null-string* '()))

;Ensure that we have a link, or throw an error.  The benefactor is the
;function to name in the error.  The link is the name of the variable
;that should contain the link.  It will only be changed if it's eqv to
;'unpassed.
(define (ensure-link benefactor link)
   (when (eqv? link 'unpassed)
      (let ((last-link (fetch-last-link)))
	 (if last-link
	     (set! link last-link)
	     (set! link (establish-default-link)))))
   (if (mysql-link? link)
       link
       (begin
	  ; remember kids, this might return if *disable-errors* was true!
	  (php-warning (format "unable to establish link in ~a" benefactor)))))

;;;;The PHP functions


;Get number of affected rows in previous MySQL operation
(defalias mysql_affected_rows php-mysql-affected-rows)
(defbuiltin (php-mysql-affected-rows (link 'unpassed))
   (let ((rlink (ensure-link 'mysql_affected_rows link)))
      (if rlink
	 (convert-to-number
          (un-ulonglongify (mysql-affected-rows (mysql-link-link rlink))))
	 #f)))


;Change logged in user of the active connection
(defalias mysql_change_user php-mysql-change-user)
(defbuiltin (php-mysql-change-user username
				   password
				   (database '())
				   (link 'unpassed))
   (when (null? database) (set! database *null-string*))
   (let ((rlink (ensure-link 'mysql_change_user link)))
      (if rlink
	 (zero? (mysql-change-user (mysql-link-link rlink)
				   username password database))
	 #f)))

;Close MySQL connection
(defalias mysql_close php-mysql-close)
(defbuiltin (php-mysql-close (link 'unpassed))
   (let ((rlink (ensure-link 'mysql_close link)))
      (if (and rlink
	       (eqv? (mysql-link-state rlink) 'alive))
	  (begin
	     (unbuffered-query-check rlink)
	     (mysql-close (mysql-link-link rlink))
	     (remove-link rlink)
	     #t)
	  #f))) 


;Open a persistent connection to a MySQL server
;(defalias mysql_pconnect php-mysql-connect) ;XXX
(defalias mysql_pconnect php-mysql-connect)
(defbuiltin (php-mysql-pconnect (server "localhost")
			       (username '())
			       (password '())
			       (client-flags '()))
   (php-mysql-connect server username password #f client-flags))

;Open a connection to a MySQL Server
(defalias mysql_connect php-mysql-connect)
(defbuiltin (php-mysql-connect (server "localhost")
			       (username '())
			       (password '())
			       (new-link #f)
			       (client-flags '()))
   ;'false is because something somewhere doesn't like #f as a default value   
   ;check for a cached link
   (if (null? server)
       (set! server "localhost"))
   (if (null? username)
       (set! username #f))
   (if (null? password)
       (set! password #f))
   (let ((link (if (convert-to-boolean new-link)
		   #f
		   (fetch-link server username password)))
	 (socket (if (get-ini-entry 'mysql.default_socket)
		     (get-ini-entry 'mysql.default_socket)
		     *null-string*))
	 (real-server server)
	 (port 0))
      (if link
	  link
	  ;no cached link, make a new one
	  (let ((mysql (mysql-init *null-mysql*)))
	     ; check for :port or :/path/to/socket specification
	     (when (string-contains server ":")
		(let ((vals (string-split server ":")))
		   (set! real-server (car vals))
		   (if (numeric-string? (cadr vals))
		       (set! port (mkfixnum (cadr vals)))
		       (set! socket (cadr vals)))))
	     ;
	     (debug-trace 3 "Mysql: Opening fresh connection to " real-server "/" username
			  " - new-link: " new-link ", link: " link)
	     (set! link (mysql-real-connect mysql real-server (or username *null-string*) (or password *null-string*)
					    *null-string* port socket 0))
	     (if (null-mysql? link)		 
		 ;link was null. issue a php warning, and return false.
		 (begin
		    (php-warning
		     (format "failed to connect to db on ~A: ~A"
			     server (mysql-error mysql)))
		    #f)
		 ;cache and return a non-null link
		 (let ((link (mysql-link-resource link 'alive '())))
		    (store-link server username password link)
		    (mysql-link-active-result-set! link #f)
		    link))))))


;Create a MySQL database
;(defalias mysql_create_db php-mysql-create-db)
;(defbuiltin (php-mysql-create-db name (link 'unpassed))
;   (ensure-link 'mysql_create_db link)
;   (zero? (mysql-create-db (mysql-link-link link) name)))


;Move internal result pointer
(defalias mysql_data_seek php-mysql-data-seek)
(defbuiltin (php-mysql-data-seek result row-number)
   (if (not (mysql-result? result))
       (bad-mysql-result-resource)
       (begin
          (mysql-data-seek (mysql-result-result result) (ulonglongify row-number))
          #t))) ;mysql lib defines no retval


;Select database and run query on it
(defbuiltin (mysql_db_query database-name query (link 'unpassed))
   (php-mysql-select-db database-name link)
   (php-mysql-query query link))


;Drop (delete) a MySQL database
;(defalias mysql_drop_db php-mysql-drop-db)
;(defbuiltin (php-mysql-drop-db db-name (link 'unpassed))
;   (ensure-link 'mysql_drop_db link)
;   (zero? (mysql-drop-db (mysql-link-link link) db-name)))


;Returns the numerical value of the error message from previous MySQL operation
(defalias mysql_errno php-mysql-errno)
(defbuiltin (php-mysql-errno (link 'unpassed))
   (let ((rlink (ensure-link 'mysql_errno link)))
      (if rlink
	 (convert-to-number (mysql-errno (mysql-link-link rlink)))
	 #f)))

;Returns the text of the error message from previous MySQL operation
(defalias mysql_error php-mysql-error)
(defbuiltin (php-mysql-error (link 'unpassed))
   (let ((rlink (ensure-link 'mysql_error link)))
      (if rlink
	 (mysql-error (mysql-link-link rlink))
	 NULL)))

; mysql_get_client_info -- Get MySQL client info
(defalias mysql_get_client_info php-mysql-get-client-info)
(defbuiltin (php-mysql-get-client-info)
   (mysql-get-client-info))

; mysql_get_server_info -- Get MySQL server info
(defalias mysql_get_server_info php-mysql-get-server-info)
(defbuiltin (php-mysql-get-server-info (link 'unpassed))
   (let ((rlink (ensure-link 'mysql_get_server_info link)))
      (if rlink
	 (mysql-get-server-info (mysql-link-link rlink))
	 #f)))

; mysql_get_proto_info -- Get MySQL proto info
(defalias mysql_get_proto_info php-mysql-get-proto-info)
(defbuiltin (php-mysql-get-proto-info (link 'unpassed))
   (let ((rlink (ensure-link 'mysql_get_proto_info link)))
      (if rlink 
	 (mysql-get-proto-info (mysql-link-link rlink))
	 #f)))

; mysql_get_host_info -- Get MySQL host info
(defalias mysql_get_host_info php-mysql-get-host-info)
(defbuiltin (php-mysql-get-host-info (link 'unpassed))
   (let ((rlink (ensure-link 'mysql_get_host_info link)))
      (if rlink
	 (mysql-get-host-info (mysql-link-link rlink))
	 #f)))

;Escapes a string for use in a mysql-query.
(defalias mysql_escape_string php-mysql-escape-string)
(defbuiltin (php-mysql-escape-string str)
   (let* ((sstr (mkstr str))
	  (len (string-length sstr))
	  (new-str (make-string (+ 1 (* 2 len))))
	  (new-len (mysql-escape-string new-str sstr len)))
      ;scheme strings are not null-terminated, so chop it by hand
      (substring new-str 0 new-len)))

(defalias mysql_real_escape_string php-mysql-real-escape-string)
(defbuiltin (php-mysql-real-escape-string str (link 'unpassed))
   (let ((rlink (ensure-link 'mysql_real_escape_string link)))
      (if rlink
	 (let* ((sstr (mkstr str))
		(len (string-length sstr))
		(new-str (make-string (+ 1 (* 2 len))))
		(new-len (mysql-real-escape-string (mysql-link-link rlink) new-str sstr len)))
	    ;scheme strings are not null-terminated, so chop it by hand
	    (substring new-str 0 new-len))
	 #f)))

(defconstant MYSQL_ASSOC 0)
(defconstant MYSQL_NUM 1)
(defconstant MYSQL_BOTH 2)

;apply fun to either each name/val or each index/val or both pair
;return false if there are no pairs
(define (mysql-row-for-each result-resource num-fun assoc-fun)
   (let* ((result (mysql-result-result result-resource))
          (row (mysql-fetch-row result)))
      (if (null-row? row)
	  #f
	  (let ((num-fields (mysql-num-fields result))
                (init-column-names? (not (mysql-result-column-names result-resource)))
                (column-names #f)
                (column-numbers #f)
                (column-hashcodes #f))
             ;; all this column-mumble stuff is the lazy
             ;; initialization of the column names, which we store in
             ;; the result resource so that we can reuse them for the
             ;; next row.
             (when init-column-names?
                (mysql-result-column-names-set! result-resource (make-vector num-fields))
                (mysql-result-column-numbers-set! result-resource (make-vector num-fields))
                (mysql-result-column-hashcodes-set! result-resource (make-vector num-fields)))
             (set! column-names (mysql-result-column-names result-resource))
             (set! column-numbers (mysql-result-column-numbers result-resource))
             (set! column-hashcodes (mysql-result-column-hashcodes result-resource))
	     (field-seek result 0) 
	     (let loop ((i 0)
			(field (mysql-fetch-field result)))
		(when (< i num-fields)
                   (when init-column-names?
                      (vector-set! column-numbers i (int->onum i))
                      (let ((field-name (mysql-field-name field)))
                         (vector-set! column-names i field-name)
                         (vector-set! column-hashcodes i (precalculate-string-hashnumber field-name))))
		   (let ((field-val (mysql-row-ref row i)))
		      (when num-fun
			 (num-fun (vector-ref column-numbers i) field-val))
		      (when assoc-fun
			 (assoc-fun (vector-ref column-names i)
                                    (vector-ref column-hashcodes i)
                                    field-val)))
		   (loop (+ i 1) (mysql-fetch-field result))))
	     #t))))



;Fetch a result row as an object
(defbuiltin (mysql_fetch_object result (array-type MYSQL_ASSOC))
   (cond
      ((not (mysql-result? result))
       (bad-mysql-result-resource))
      (else
       ;; XXX since I'm not sure about objects with numeric
       ;; properties, we're going to just always do assoc, and
       ;; print a warning in the numeric case
       (unless (php-= array-type MYSQL_ASSOC)
          (warning 'mysql_fetch_object "Can't make an object with numeric keys" #f))
       (let ((props (make-php-hash)))
          (if (mysql-row-for-each result                                   
                                  #f
                                  (lambda (key hashnumber val)
                                     (php-hash-insert!/pre props key hashnumber val)))
              (make-php-object props)
              #f)))))

;Get a result row as an enumerated array
(defalias mysql_fetch_row php-mysql-fetch-row)
(defbuiltin (php-mysql-fetch-row result)
   (mysql_fetch_array result MYSQL_NUM))

;Fetch a result row as an associative array
(defbuiltin (mysql_fetch_assoc result)
   (mysql_fetch_array result MYSQL_ASSOC))

;Fetch a result row as an associative array, a numeric array, or both.
(defbuiltin (mysql_fetch_array result (array-type MYSQL_BOTH))
   (if (not (mysql-result? result))
       (bad-mysql-result-resource)
       (let ((array (make-php-hash)))
          (if (mysql-row-for-each result
                                  (if (or (php-= array-type MYSQL_NUM)
                                          (php-= array-type MYSQL_BOTH))
                                      (lambda (key val)
                                         (php-hash-insert! array key val))
                                      #f)
                                  (if (or (php-= array-type MYSQL_ASSOC)
                                          (php-= array-type MYSQL_BOTH))
                                      (lambda (key hashnumber val)
                                         (php-hash-insert!/pre array key hashnumber val))
                                      #f))
              array
              #f))))


;Get column information from a result and return as an object
(defalias mysql_fetch_field php-mysql-fetch-field)
(defbuiltin (php-mysql-fetch-field result (offset 'unpassed))
   (if (not (mysql-result? result))
       (bad-mysql-result-resource)
       (let ((result (mysql-result-result result)))
          (unless (eqv? offset 'unpassed)
             (field-seek result offset))
          (let ((field (mysql-fetch-field result)))
             (if (null-field? field)
                 #f
                 (let* ((flags (mysql-field-flags field))
                        (flag-set? (lambda (flag) (if (member flag flags) 1 0)))
                        (zero-or-one (lambda (val) (if (zero? val) *zero* *one*))))
                    (make-php-object
                     (let ((props (make-php-hash)))
                        (for-each (lambda (k-v)
                                     (php-hash-insert! props (car k-v) (cadr k-v)))
                                  `(("name" ,(mkstr (mysql-field-name field))) ;column name
                                    ("table" ,(mkstr (mysql-field-table field))) ;name of the table the column belongs to
                                    ("def" ,(mkstr (mysql-field-def field))) ;default value
                                    ("max_length" ,(convert-to-number (mysql-field-max-length field))) ;maximum length of the column
                                    ("not_null"  ,(zero-or-one (is-not-null? flags))) ;1 if the column cannot be NULL
                                    ("primary_key" ,(zero-or-one  (is-pri-key? flags))) ;1 if the column is a primary key
                                    ("multiple_key" ,(convert-to-number (flag-set? 'multiple-key))) ;1 if the column is a non-unique key
                                    ("unique_key" ,(convert-to-number (flag-set? 'unique-key))) ;1 if the column is a unique key 
                                    ("numeric" ,(zero-or-one (is-num? (mysql-field-type field)))) ;1 if the column is numeric
                                    ("blob" ,(zero-or-one (is-blob? flags))) ;1 if the column is a BLOB
                                    ("type" ,(php-field-type-name (mysql-field-type field))) ;the type of the column
                                    ("unsigned" ,(convert-to-number (flag-set? 'unsigned))) ;1 if the column is unsigned
                                    ("zerofill" ,(convert-to-number (flag-set? 'zero-fill)))))
                        props)))))))) ;1 if the column is zero-filled



(define (php-field-type-name field-type)
   (case field-type
      ((varstring varchar) "string")
      ((tinyint smallint mediumint integer bigint) "int")
      ((decimal float double) "real")
      ((timestamp) "timestamp")
      ((year) "year")
      ((date newdate) "datetime")
      ((time) "time")
      ((set) "set")
      ((enum) "enum")
      ((tinyblob blob mediumblob longblob) "blob")
      ((null) "null")
      ;;XXX missing geometry and newdate
      (else "unknown")))

;Get the length of each output in a result
(defbuiltin (php-mysql-fetch-lengths result)
   (if (not (mysql-result? result))
       (bad-mysql-result-resource)
       (let ((result (mysql-result-result result)))
          (let ((lengths-hash (make-php-hash))
                (row (mysql-fetch-row result)))
             (if (null-row? row)
                 #f
                 (let ((num-fields (mysql-num-fields result))
                       (lengths (mysql-fetch-lengths result)))
                    (dotimes (i num-fields)
                       (php-hash-insert! lengths-hash i
                                         (ulong-ptr-ref lengths i)))
                    lengths-hash))))))


;Return the flags associated with the specified field as a string
;divided by spaces
(defalias mysql_field_flags php-mysql-field-flags)
(defbuiltin (php-mysql-field-flags result offset)
   (if (not (mysql-result? result))
       (bad-mysql-result-resource)
       (let ((result (mysql-result-result result)))
          (field-seek result offset)
          (let ((field (mysql-fetch-field result)))
             (if (null-field? field)
                 #f
                 (let ((flags (mysql-field-flags field)))
                    ;	     (fprint (current-error-port) "flags: " flags) 
                    (let loop ((flag (gcar flags))
                               (flags (gcdr flags))
                               (string-flags '()))
                       (if (null? flag)
                           (apply string-append string-flags)
                           (loop (gcar flags)
                                 (gcdr flags)
                                 (cons (if (null? flags) "" " ")
                                       (cons (case flag
                                                ((not-null) "not_null")
                                                ((primary-key) "primary_key")
                                                ((unique-key) "unique_key")
                                                ((multiple-key) "multiple_key")
                                                ((blob) "blob")
                                                ((unsigned) "unsigned")
                                                ((zero-fill) "zerofill")
                                                ((binary) "binary")
                                                ((enum) "enum")
                                                ((auto-increment) "auto_increment")
                                                ((timestamp) "timestamp")
                                                (else "unknown_flag"))
                                             string-flags)))))))))))

	 

(define (get-field-field result offset getter)
   "If field exists, run the getter on it, else return #f"
   (if (not (mysql-result? result))
       (bad-mysql-result-resource)
       (let ((result (mysql-result-result result)))
          (if (field-seek result offset)
              (let ((field (mysql-fetch-field result)))
                 (if (null-field? field)
                     #f
                     (getter field)))
              #f))))
   

;Get the name of the specified field in a result
(defalias mysql_field_name php-mysql-field-name)
(defbuiltin (php-mysql-field-name result offset)
   (get-field-field result offset mysql-field-name))

;Returns the length of the specified field
(defalias mysql_field_len php-mysql-field-len)
(defbuiltin (php-mysql-field-len result offset)
   (get-field-field result offset mysql-field-length))


(define (field-seek result offset)
   "Seek to OFFSET field in RESULT, doing a bounds check."
   (if (or (php-< offset 0) (php->= offset (mysql-num-fields result)))
       (begin
	  (php-warning (format "Field offset ~A is not within valid range ~A to ~A")))
       (begin
	  (mysql-field-seek result (mkfixnum offset))
	  #t)))

;Set result pointer to a specified field offset
(defalias mysql_field_seek php-mysql-field-seek)
(defbuiltin (php-mysql-field-seek result offset)
   (if (not (mysql-result? result))
       (bad-mysql-result-resource)
       (field-seek (mysql-result-result result) offset)))
       
;Get name of the table the specified field is in
(defalias mysql_field_table php-mysql-field-table)
(defbuiltin (php-mysql-field-table result offset)
   (get-field-field result offset mysql-field-table))

;Get the type of the specified field in a result
(defalias mysql_field_type php-mysql-field-type)
(defbuiltin (php-mysql-field-type result offset)
   (let ((field-type (get-field-field result offset mysql-field-type)))
      (if field-type
	  (case field-type
	     ((varstring varchar) "string")
	     ((tinyint smallint integer bigint mediumint) "int")
	     ((decimal float double) "real")
	     ((timestamp) "timestamp")
	     ((year) "year")
	     ((date) "date")
	     ((time) "time")
	     ((datetime) "datetime")
	     ((tinyblob mediumblob longblob blob) "blob")
	     ((null) "null")
	     ((enum) "enum")
	     ((set) "set")
	     (else "unknown"))
	  #f)))


;Free result memory
(defalias mysql_free_result php-mysql-free-result)
(defbuiltin (php-mysql-free-result result)
   (if (not (mysql-result? result))
       (bad-mysql-result-resource)
       (begin
	  (unless (mysql-result-freed? result)
	     (mysql-free-result (mysql-result-result result))
	     (mysql-result-freed?-set! result #t)
	     (set! *mysql-result-counter* (- *mysql-result-counter* 1)))
          #t))) ;mysql-free-result returns void

;Get the id generated from the previous INSERT operation
(defalias mysql_insert_id php-mysql-insert-id)
(defbuiltin (php-mysql-insert-id (link 'unpassed))
   (let ((rlink (ensure-link 'mysql_insert_id link)))
      (if rlink 
	 (convert-to-number
          (un-ulonglongify (mysql-insert-id (mysql-link-link rlink))))
	 #f)))

;List databases available on a MySQL server
(defalias mysql_list_dbs php-mysql-list-dbs)
(defbuiltin (php-mysql-list-dbs (link 'unpassed))
   (let ((rlink (ensure-link 'mysql_list_dbs link)))
      (if rlink
	  (begin
	     (unbuffered-query-check rlink)
	     (let ((result (mysql-list-dbs (mysql-link-link rlink) *null-string*)))
		(if result
		    (make-finalized-mysql-result result)
		    (php-warning (format "Result was null -- ~A" (mysql-error (mysql-link-link rlink)))))))
	 #f)))

;List MySQL result fields
(defalias mysql_list_fields php-mysql-list-fields)
(defbuiltin (php-mysql-list-fields db-name table-name (link 'unpassed))
   (let ((rlink (ensure-link 'mysql_list_fields link)))
      (if rlink
	  (begin
	     (unbuffered-query-check rlink)
	     (set! link (mysql-link-link rlink))
	     (if (= 0 (mysql-select-db link db-name))
		 (let ((result (mysql-list-fields link table-name *null-string*)))
		    (if (null-result? result)
			(begin
			   (php-warning (format "null result: ~A"
						(mysql-error link)))
			   #f)
			(make-finalized-mysql-result result)))
		 (begin
		    (php-warning (format "unable to select db: ~A -- ~A"
					 db-name (mysql-error link)))
		    #f)))
	  #f)))

;List tables in a MySQL database
(defalias mysql_list_tables php-mysql-list-tables)
(defbuiltin (php-mysql-list-tables db-name (link 'unpassed))
   (let ((rlink (ensure-link 'mysql_list_tables link)))
      (if rlink
	  (begin
	     (unbuffered-query-check rlink)
	     (set! link (mysql-link-link rlink))
	     (if (zero? (mysql-select-db link (mkstr db-name)))
		 (let ((result (mysql-list-tables link *null-string*)))
		    (if (null-result? result)
			#f
			(make-finalized-mysql-result result)))
		 #f))
	  #f)))

;Get number of fields in result
(defalias mysql_num_fields php-mysql-num-fields)
(defbuiltin (php-mysql-num-fields result)
   (if (not (mysql-result? result))
       (bad-mysql-result-resource)
       (convert-to-number (mysql-num-fields (mysql-result-result result)))))
	     
;Get number of rows in result
(defalias mysql_num_rows php-mysql-num-rows)
(defbuiltin (php-mysql-num-rows result)
   ;here lurks a potential bug, in the conversion between
   ;llong and fixnum.
   (if (not (mysql-result? result))
       (bad-mysql-result-resource)
       (begin
          (convert-to-number
           (un-ulonglongify (mysql-num-rows (mysql-result-result result)))))))



;Send a MySQL query
(defalias mysql_query php-mysql-query)
(defbuiltin (php-mysql-query query (link 'unpassed))
   (let ((rlink (ensure-link 'mysql_query link)))
      (if rlink
	  (do-query (mkstr query) rlink #t)
	  #f)))

(define (do-query query rlink store)
   (unbuffered-query-check rlink)
   (let ((link (mysql-link-link rlink)))
      (if (= 0 (mysql-query link query))
	  (let ((result (if store
			    (mysql-store-result link)
			    (mysql-use-result link))))
	     (if (null-result? result)
                 ;; mysql-field-count will tell us if the query was
                 ;; really meant to return nothing or not.
                 (if (zero? (mysql-field-count link))
                     TRUE
                     (begin
                        (php-warning "Unable to save result set")
                        FALSE))
		 (let ((r (make-finalized-mysql-result result)))
		    (unless store
		       (mysql-link-active-result-set! rlink r))
		    r)))
	  (begin
             ;	     (php-warning (format "mysql_query: mysql-query returned null -- ~A" (mysql-error link)))
	     FALSE) )))


;Send an SQL query to MySQL, without fetching and buffering the result rows
(defalias mysql_unbuffered_query php-mysql-unbuffered-query)
(defbuiltin (php-mysql-unbuffered-query query (link 'unpassed))
   (let ((rlink (ensure-link 'mysql_unbuffered_query link)))
      (if rlink
	 (do-query query rlink #f)
	 #f)))



;Get result data
(defalias mysql_dbname php-mysql-result)
(defalias mysql_result php-mysql-result)
(defalias mysql_db_name php-mysql-result)
(defalias mysql_table_name php-mysql-result)
(defalias mysql_tablename php-mysql-result)
(defbuiltin (php-mysql-result result row-num (field 'unpassed))
;   (print " my arguments are " result ", " row-num ", " field)
   (if (not (mysql-result? result))
       (bad-mysql-result-resource)
       (let ((field-offset 0)
	     (srow-num (convert-to-integer row-num))
	     (num-rows (php-mysql-num-rows result)))
	  (if (not (and (php->= srow-num 0)
                        (php-< srow-num num-rows)))
              (php-warning (format "specified row doesn't exist in result set (~a/~a)" (mkfixnum srow-num) (mkfixnum num-rows)) )
	      (begin 
		 (mysql-data-seek (mysql-result-result result) (flonum->llong (onum->float (convert-to-float srow-num))))
		 (let ((row (mysql-fetch-row (mysql-result-result result))))
		    (if (null-row? row)
			(begin
			   (php-warning "specified row was null")
			   #f)			
			(let ((num-fields (mysql-num-fields (mysql-result-result result))))
			   ;(print "there are " num-fields " fields")
			   ; setup field-offset based on field
			   (unless (eqv? field 'unpassed)
			      (cond ((php-number? field) (set! field-offset field))
				    (else
				     (let ((sfield (mkstr field))
					   (res (mysql-result-result result)))

					(multiple-value-bind (table-name field-name)
					   (let ((dot-location (strchr sfield #\.)))
					      (if dot-location
						  (values (substring sfield 0 dot-location)
							  (substring sfield (+ dot-location 1) (string-length sfield)))
						  (values #f sfield)))
					   ; lookup by field name
					   (field-seek res 0)
					   (let loop ((i 0)
						      (field (mysql-fetch-field res)))					      
					      (if (< i num-fields)
						  (begin
						     ;(print "checking field " i " which is " (mysql-field-name field) " table: " (mysql-field-table field))
						     (if (and (or (not table-name) (string-ci=? table-name (mysql-field-table field)))
							      (string-ci=? field-name (mysql-field-name field)))
							 (set! field-offset i)
							 (loop (+ i 1) (mysql-fetch-field res))))
						  ; not found
						  (set! field-offset -1))))))))
			   ; always runs
			   ;(print "field offset is " field-offset)
			   (if (and (php->= field-offset 0)
				    (php-< field-offset num-fields))				    
			       (mysql-row-ref row (mkfixnum field-offset))
			       (begin
				  (php-warning "specified field doesn't exist in row")
				  #f))))))))))
			


(define (strchr string char)
   (let loop ((i 0))
      (if (< i (string-length string))
	  (if (char=? char (string-ref string i))
	      i
	      (loop (+ i 1)))
	  #f)))


;Select a MySQL database
(defalias mysql_select_db php-mysql-select-db)
(defbuiltin (php-mysql-select-db database-name (link 'unpassed))
   (let ((rlink (ensure-link 'mysql_select_db link)))
      (if rlink
	  (begin 
	     (unbuffered-query-check rlink)
	     (let ((retval (mysql-select-db (mysql-link-link rlink) (mkstr database-name))))
		(zero? retval)))
	 #f)))

(define (unbuffered-query-check link::struct)
   (let ((result (mysql-link-active-result link)))
      (if (not (mysql-result? result))
          #f
          (let ((r (mysql-result-result result)))
             (unless (pragma::bool "$1 != 0" (mysql-eof r))
                (php-notice "Function called without first fetching all rows from a previous unbuffered query")
                (let loop ()
                   (unless (null-row? (mysql-fetch-row r))
                      (loop)))
                (mysql-free-result r))
             (mysql-link-active-result-set! link #f)))))

(define (bad-mysql-result-resource)
   (php-warning "supplied argument is not a valid MySQL result resource")
   NULL)

;;;deprecated names
(defalias mysql                 mysql_db_query)
(defalias mysql_fieldname       php-mysql-field-name)
(defalias mysql_fieldtable      php-mysql-field-table)
(defalias mysql_fieldlen        php-mysql-field-len)
(defalias mysql_fieldtype       php-mysql-field-type)
(defalias mysql_fieldflags      php-mysql-field-flags)
(defalias mysql_selectdb        php-mysql-select-db)
;(defalias mysql_createdb        php-mysql-create-db)
;(defalias mysql_dropdb          php-mysql-drop-db)
(defalias mysql_freeresult      php-mysql-free-result)
(defalias mysql_numfields       php-mysql-num-fields)
(defalias mysql_numrows         php-mysql-num-rows)
(defalias mysql_listdbs         php-mysql-list-dbs)
(defalias mysql_listtables      php-mysql-list-tables)
(defalias mysql_listfields      php-mysql-list-fields)


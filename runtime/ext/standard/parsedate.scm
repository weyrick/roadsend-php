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

(module parsedate
   (import (php-time-lib "php-time.scm"))
   (export
    (super-date-parser date-string . xnow)) )
      

;hashtable for the time info
(define *tm* 'unset)


(define *tm-year-origin* 1900)
(define *epoch*		1970)


; (define (dump-tm* t)
;    (print "sec "
; 	  (tm*-sec t) ", min "
; 	  (tm*-min t) ", hour "
; 	  (tm*-hour t) ", mday "
; 	  (tm*-mday t) ", mon "
; 	  (tm*-mon t) ", year "
; 	  (tm*-year t) ", wday "
; 	  (tm*-wday t) ", yday "
; 	  (tm*-yday t) ", isdst "
; 	  (tm*-isdst t))
;    "")

; (define (dump-time_t t::time-t)
;    (pragma "printf(\"time_t dump: %d\n\", $1)" t)
;    "")

(define (super-date-parser date-string . now)
   (bind-exit (return)
      (let ((start-date (if (null? now)
			     (current-date)
			     (car now)))
	    (build-date 'unset))
	 (let ((year (date-year start-date))
	       (month (date-month start-date))
	       (day (date-day start-date))
	       (hour (date-hour start-date))
	       (minutes (date-minute start-date))
	       (seconds (date-second start-date))
	       (meridian 'mer24)
	       (day-ordinal 0)
	       (day-number 0)
	       (have-day 0)
	       (have-date 0)
	       (have-rel 0)
	       (have-time 0)
	       (have-zone 0)	       
	       (timezone 0)
	       (relday 0)
	       (relhour 0)
	       (relminutes 0)
	       (relmonth 0)
	       (relseconds 0)
	       (relyear 0))
	    (let ((date-grammar
		   (lalr-grammar
		      ;the tokens
		      (ago day day-unit dayzone dst hour-unit colon
		       comma slash id meridian minute-unit year-unit 
		       zone month month-unit sec-unit snumber unumber)
		      
		      ;the rules
		      (item
		       ((atime) (set! have-time (+ have-time 1)))
		       ((azone) (set! have-zone (+ have-zone 1)))
		       ((adate) (set! have-date (+ have-date 1)))
		       ((aday) (set! have-day (+ have-day 1)))
		       ((arel) (set! have-rel (+ have-rel 1)))
		       ((anumber) anumber))

		      (atime 
		       ((unumber meridian)
			(set! hour unumber)
			(set! minutes 0)
			(set! seconds 0)
			(set! meridian meridian))
		       ((unumber@hour1 colon unumber@minutes1 merid)
			(set! hour hour1)
			(set! minutes minutes1)
			(set! seconds 0)
			(set! meridian merid))
		       ((unumber@hour1 colon unumber@minutes1 snumber)
			(set! hour hour1)
			(set! minutes minutes1)
			(set! meridian 'mer24)
			(set! have-zone (+ have-zone 1))
			(set! timezone (if (< snumber 0)
					   (+ (modulo (- snumber) 100)
					      (* 60 (/ (- snumber) 100)))
					   (- (+ (modulo snumber 100)
						 (* 60 (/ snumber 100)))))))
		       ((unumber@hour1 colon unumber@minutes1 colon unumber@seconds1 merid)
			(set! hour hour1)
			(set! minutes minutes1)
			(set! seconds seconds1)
			(set! meridian merid))
		       ((unumber@hour1 colon unumber@minutes1 colon unumber@seconds1 snumber)
			;ISO 8601 format.  hh:mm:ss[+-][0-9]{2}([0-9]{2})?.  */
			(set! hour hour1)
			(set! minutes minutes1)
			(set! seconds seconds1)
			(set! meridian 'mer24)
			(set! have-zone (+ 1 have-zone))
			(if (or (<= snumber -100) (>= snumber 100))
			    (set! timezone (+ (modulo (- snumber) 100) (* 60 (/ (- snumber) 100))))
			    (set! timezone (* (- snumber) 60)))))

		      (azone
		       ((zone)
			(set! timezone zone))
		       ((dayzone)
			(set! timezone (- dayzone 60)))
		       ((zone dst)
			(set! timezone (- zone 60))))

		      (aday
		       ((day)
			(set! day-ordinal 1)
			(set! day-number day))
		       ((day comma)
			(set! day-ordinal 1)
			(set! day-number day))
		       ((unumber day)
			(set! day-ordinal unumber)
			(set! day-number day)))

		      (adate
		       ((unumber@month1 slash unumber@day1)
			(set! month month1)
			(set! day day1))
		       ((unumber@year1 slash unumber@month1 slash unumber@day1)
		       ; Interpret as YYYY/MM/DD if $1 >= 1000, otherwise as MM/DD/YY.
		       ; The goal in recognizing YYYY/MM/DD is solely to support legacy
		       ; machine-generated dates like those in an RCS log listing.  If
		       ; you want portability, use the ISO 8601 format.  */
			(if (> year1 1000)
			    (begin
			       (set! year year1)
			       (set! month month1)
			       (set! day day1))
			    (begin
			       (set! month year1)
			       (set! day month1)
			       (set! year day1))))
		       ((unumber snumber@month1 snumber@day1)
			; ISO 8601 format.  yyyy-mm-dd.  */
			(set! year unumber)
			(set! month (- month1))
			(set! day (- day1)))
		       ((unumber month@month1 snumber)
			; e.g. 17-JUN-1992.  */
			(set! day unumber)
			(set! month month1) 
			(set! year (- snumber)))
		       ((month@month1 unumber@day1 unumber@year1)
			(set! month month1)
			(set! day day1)
			(set! year year1))
		       ((month@month1 unumber)
			(set! month month1)
			(set! day unumber))
		       ((month@month1 unumber@day1 comma unumber@year1)
			(set! month month1)
			(set! day day1)
			(set! year year1))
		       ((unumber month@month1)
			(set! month month1)
			(set! day unumber))
		       ((unumber@day1 month@month1 unumber@year1)
			(set! day day1)
			(set! month month1)
			(set! year year1)))

		      (arel
		       ((relunit ago)
			(set! relseconds (- relseconds))
			(set! relminutes (- relminutes))
			(set! relhour (- relhour))
			(set! relday (- relday))
			(set! relmonth (- relmonth))
			(set! relyear (- relyear)))
		       ((relunit) '()))

		      (s-or-u
		       ((unumber) unumber)
		       ((snumber) snumber))
		      
		      (relunit
		       ((s-or-u year-unit)
			(set! relyear (+ relyear (* s-or-u year-unit))))
		       ((year-unit)
			(set! relyear (+ relyear year-unit)))
		       ((s-or-u month-unit)
			(set! relmonth (+ relmonth (* s-or-u month-unit))))
		       ((month-unit)
			(set! relmonth (+ relmonth month-unit)))
		       ((s-or-u day-unit)
			(set! relday (+ relday (* s-or-u day-unit))))
		       ((day-unit)
			(set! relday (+ relday day-unit)))
		       ((s-or-u hour-unit)
			(set! relhour (+ relhour (* s-or-u hour-unit))))
		       ((hour-unit)
			(set! relhour (+ relhour hour-unit)))
		       ((s-or-u minute-unit)
			(set! relminutes (+ relminutes (* s-or-u minute-unit))))
		       ((minute-unit)
			(set! relminutes (+ relminutes minute-unit)))
		       ((s-or-u sec-unit)
			(set! relseconds (+ relseconds (* s-or-u sec-unit))))
		       ((sec-unit)
			(set! relseconds (+ relseconds sec-unit))))

		      (anumber
		       ((unumber)
			(if (and (< 0 have-time) (< 0 have-date) (zero? have-rel))
			    (set! year unumber)
			    (if (> unumber 10000)
				(begin
				   (set! have-date (+ have-date 1))
				   (set! day (modulo unumber 100))
				   (set! month (modulo (/ unumber 100) 100))
				   (set! year (/ unumber 10000)))
				(begin
				   (set! have-time (+ have-time 1))
				   (if (< unumber 100)
				       (begin
					  (set! hour unumber)
					  (set! minutes 0))
				       (begin
					  (set! hour (/ unumber 100))
					  (set! minutes (modulo unumber 100))))
				   (set! seconds 0)
				   (set! meridian 'mer24))))))

		      (merid
		       (() 'mer24)
		       ((meridian) meridian)))))
	       ;take the read/lalrp out of the try to find out what the parse error is..
 	       (try
		(read/lalrp date-grammar *date-lexer*
			    (open-input-string date-string))
		(lambda (e p m o)
		   (return -1)))
	       (when (or (> have-time 1) (> have-zone 1)
			 (> have-date 1) (> have-day 1))
		  (return -3))
	       
; 	       (tm*-isdst-set! tm (tm*-isdst tmp-time))
; 	       (tm*-year-set! tm (+ (- (to-year year) *tm-year-origin*) relyear))
; 	       (tm*-mon-set! tm (+ (- month 1) relmonth))
; 	       (tm*-mday-set! tm (+ day relday))
	       
; 	       (print " day " day
; 		      " month " month
; 		      " second " seconds
; 		      " minutes " minutes
; 		      " year " year
; 		      " hour " hour
; 		      " timezone " timezone
; 		      " day-number " day-number
; 		      " day-ordinal " day-ordinal)
; 	       (print " relday " relday
; 		      " relmonth " relmonth
; 		      " relsecond " relseconds
; 		      " relminutes " relminutes
; 		      " relyear " relyear
; 		      " relhour " relhour)
; 	       (print " haveday " have-day
; 		      " havedate " have-date
; 		      " haverel " have-rel
; 		      " havetime " have-time
; 		      " havezone " have-zone)

	       (set! build-date (make-date 0
					   0
					   0
					   (+ day relday)
					   (+ month relmonth)
					   (+ (to-year year) relyear)))
	       ;(print "1 build date is " build-date)
	       (if (or (< 0 have-time)
		       (and (< 0 have-rel) (zero? have-date) (zero? have-day)))
		   (begin
		      (set! build-date (make-date
					   seconds
					   minutes
					   (to-hour hour meridian)
					   (date-day build-date)
					   (date-month build-date)
					   (date-year build-date))))
		   (begin
		      (set! build-date (make-date
					   0
					   0
					   0
					   (date-day build-date)
					   (date-month build-date)
					   (date-year build-date)))))
	       ;(print "2 build date is " build-date)
	       (set! build-date (make-date
					   (+ (date-second build-date) relseconds)
					   (+ (date-minute build-date) relminutes)
					   (+ (date-hour build-date) relhour)
					   (date-day build-date)
					   (date-month build-date)
					   (date-year build-date)))
	       ;(print "3 build date is " build-date)
	       
; 	       (tm*-hour-set! tm (+ (tm*-hour tm) relhour))
; 	       (tm*-min-set! tm (+ (tm*-min tm) relminutes))
; 	       (tm*-sec-set! tm (+ (tm*-sec tm) relseconds))
	       
	       ; Let mktime deduce tm_isdst if we have an absolute timestamp,
	       ; or if the relative timestamp mentions days, months, or years.  */
	       (when (or (< 0 have-date) (< 0 have-time) (< 0 relday)
			 (< 0 relmonth) (< 0 relyear))
		  (set! build-date (make-date (date-second build-date)
					      (date-minute build-date)
					      (date-hour build-date)
					      (date-day build-date)
					      (date-month build-date)
					      (date-year build-date)
					      ;; XXX This is a workaround for a bigloo bug. We should be
					      ;; able to just say (date-timezone (current-date)), but he
					      ;; does the adjustment incorrectly for timezones west of GMT.
					      ;; Until either Manuel changes it himself or accepts my patch
					      ;; it's easier to work around it here to avoid having to
					      ;; patch bigloo locally. --Nate 2004-06-07
					      (let ((tz (date-timezone (current-date))))
						 (if (< tz 0)
						     tz
						     (- tz)))
					      -1)))
	       ;(print "4 build date is " build-date)
		  ;(tm*-isdst-set! tm -1))
	       
;  	       (let ((saved-date (date-copy build-date)))
; 		  ;(set! start (mktime-tm tm))
; 		  (when (=second start (integer->second -1))
; 		  ; Guard against falsely reporting errors near the time_t boundaries
; 		  ; when parsing times in other time zones.  For example, if the min
; 		  ; time_t value is 1970-01-01 00:00:00 UTC and we are 8 hours ahead
; 		  ; of UTC, then the min localtime value is 1970-01-01 08:00:00; if
; 		  ; we apply mktime to 1970-01-01 00:00:00 we will get an error, so
; 		  ; we apply mktime to 1970-01-02 08:00:00 instead and adjust the time
; 		  ; zone by 24 hours to compensate.  This algorithm assumes that
; 		  ; there is no DST transition within a day of the time_t boundaries.  */
; 		     (when have-zone
; 			(set! tm saved-tm)
; 			(if (<= (tm*-year tm) (- *epoch* *tm-year-origin*))
; 			    (begin
; 			       (tm*-mday-set! tm (+ (tm*-mday tm) 1))
; 			       (set! timezone (- timezone (* 24 60))))
; 			    (begin
; 			       (tm*-mday-set! tm (- (tm*-mday tm) 1))
; 			       (set! timezone (+ timezone (* 24 60)))))
; 			(set! start (mktime-tm tm)))
; 		     (when (=second start (integer->second -1))
; 			(return -4)) ) )

	       (when (and (< 0 have-day) (< 0 have-date))
		  (set! build-date (make-date
					      (date-second build-date)
					      (date-minute build-date)
					      (date-hour build-date)
					      (+ (date-day build-date)
						 (modulo (+ (- day-number (date-wday build-date)) 7) 7)
						 (* 7 (- day-ordinal (if (< 0 day-ordinal) 1 0))))
					      (date-month build-date)
					      (date-year build-date)
					      ;; XXX This is a workaround for a bigloo bug. We should be
					      ;; able to just say (date-timezone (current-date)), but he
					      ;; does the adjustment incorrectly for timezones west of GMT.
					      ;; Until either Manuel changes it himself or accepts my patch
					      ;; it's easier to work around it here to avoid having to
					      ;; patch bigloo locally. --Nate 2004-06-07
					      (let ((tz (date-timezone (current-date))))
						 (if (< tz 0)
						     tz
						     (- tz)))
					      -1)))
	       ;(print "5 build date is " build-date)
; 		  (when (and (< 0 have-day) (< 0 have-date))
; 		     (tm*-mday-set! tm (+ (tm*-mday tm)
; 					  (modulo (+ (- day-number (tm*-wday tm)) 7) 7)
; 					  (* 7 (- day-ordinal (if (< 0 day-ordinal) 1 0)))))
; 		     (set! start (mktime-tm tm))
; 		     (when (= -1 start)
; 			(return -1)))

; 		  (when (< 0 have-zone)
; 		     (let ((gmt (gmmktime (date-hour build-date)
; 					  (date-minute build-date)
; 					  (date-second build-date)
; 					  (date-month build-date)
; 					  (date-day build-date)
; 					  (date-year build-date)
; 					  (date-is-dst build-date))))
; 			(let ((delta (+second (difftm tm gmt) (* timezone 60))))
; 			   (if (<second (+second start delta) start)
; 			       ; time_t overflow */
; 			       (when (<=second 0 delta)
; 				  (return -1))
; 			       ; time_t overflow */
; 			       (when (<second delta 0)
; 				  (return -1)))
; 			   (set! start (+second start delta)))))

; 	       (when (< 0 have-zone)
; 		  (let ((gmt (gmtime-tm start)))
; 		     (when (tm*-null? gmt)
; 			(return -1))
; 		     (let ((delta (+second (difftm tm gmt) (* timezone 60))))
; 			(if (<second (+second start delta) start)
; 			    ; time_t overflow */
; 			    (when (<=second 0 delta)
; 			       (return -1))
; 			    ; time_t overflow */
; 			    (when (<second delta 0)
; 			       (return -1)))
; 			(set! start (+second start delta)))))
	       (date->seconds build-date))))))
		  

	

(define *date-lexer*
   (let ((paren-depth 0))
      (regular-grammar ()
	 ((context 'parens (+ (out #\( #\))))
	  (ignore))
	 ((+ blank) (ignore))
	 ((: (+ digit) (? (: (in #\s #\n #\r #\t) (? (in #\t #\d #\h)))))
	  (cons 'unumber (the-fixnum)))
	 ((: (? (or #\+ #\-)) (+ digit)  (? (: (in #\s #\n #\r #\t) (? (in #\t #\d #\h)))))
	  (cons 'snumber (the-fixnum)))
	 ((+ (in alpha #\.))
	  (lookup-word (the-string)))
	 (":" 'colon)
	 ("," 'comma)
	 ("/" 'slash)
	 ((out #\()
	  (the-string))
	 ("("
	  (rgc-context 'parens)
	  (set! paren-depth (+ paren-depth 1))
	  (ignore))
	 ((context 'parens ")")
	  (set! paren-depth (- paren-depth 1))
	  (when (zero? paren-depth)
	     (rgc-context))
	  (ignore)))))

; Yield A - B, measured in seconds.  */
(define (difftm a b)
   (let ((ay (date-year a))
	 (by (date-year b)))
      (let ((days
	     ; difference in day of year */
	     (+ (- (date-year a) (date-year b))
		; + intervening leap days */
		(- (bit-rsh ay 2) (bit-rsh by 2))
		(- (- (/ ay 100) (/ by 100)))
		(- (bit-rsh (/ ay 100) 2) (bit-rsh (/ by 100) 2))
		; + difference in years * 365 */
		(* (- ay by) 365))))
	 (+ (* 60
	       (+ (* 60
		     (+ (* 24 days) (- (date-hour a) (date-hour b))))
		  (- (date-minute a) (date-minute b)))
	       (- (date-second a) (date-second b)))))))

; (define (copy-tm* tm)
;    (let ((new (make-tm*)))
;       (tm*-sec-set! new (tm*-sec tm))
;       (tm*-min-set! new (tm*-min tm))
;       (tm*-hour-set! new (tm*-hour tm))
;       (tm*-mday-set! new (tm*-mday tm))
;       (tm*-mon-set! new (tm*-mon tm))
;       (tm*-year-set! new (tm*-year tm))
;       (tm*-wday-set! new (tm*-wday tm))
;       (tm*-yday-set! new (tm*-yday tm))
;       (tm*-isdst-set! new (tm*-isdst tm))
;       new))

(define (lookup-word word)
   (let ((word (pregexp-replace* "\\." (string-downcase word) "")))
      (or (hashtable-get (meridians) word)
	  (hashtable-get (month-day-table) word)
	  (hashtable-get (timezone-table) word)
	  (if (string=? "dst" word) 'dst #f)
	  (hashtable-get (units-table) word)
	  (hashtable-get (units-table) (pregexp-replace "s$" word ""))
	  (hashtable-get (other-table) word)
	  (cons 'id word))))

(define-macro (def-lazy-table name . entries)
   "Make a function that lazily initializes and returns a hashtable."
   (let ((table (gensym 'table)))
      `(define ,name
	  (let ((,table 'unset))
	     (lambda ()
		(when (eqv? ,table 'unset)
		   (set! ,table (make-hashtable))
		   ,@(map
		      (lambda (entry)
			 `(hashtable-put! ,table ,(car entry)
					  (cons ,(cadr entry) ,(caddr entry))))
		      entries))
		,table)))))

(define (hour num)
   (* num 60))

;month and day table
(def-lazy-table month-day-table
   ("january"    'month  1)
   ("february"   'month  2)
   ("march"      'month  3)
   ("april"      'month  4)
   ("may"        'month  5)
   ("june"       'month  6)
   ("july"       'month  7)
   ("august"     'month  8)
   ("september"  'month  9)
   ("sept"       'month  9)
   ("october"    'month 10)
   ("november"   'month 11)
   ("december"   'month 12)
   ("sunday"         'day 0)
   ("monday"         'day 1)
   ("tuesday"        'day 2)
   ("tues"           'day 2)
   ("wednesday"      'day 3)
   ("wednes"         'day 3)
   ("thursday"       'day 4)
   ("thur"           'day 4)
   ("thurs"          'day 4)
   ("friday"         'day 5)
   ("saturday"       'day 6)
   ("jan"    'month  1)
   ("feb"   'month  2)
   ("mar"      'month  3)
   ("apr"      'month  4)
   ("may"        'month  5)
   ("jun"       'month  6)
   ("jul"       'month  7)
   ("aug"     'month  8)
   ("sep"  'month  9)
   ("sep"       'month  9)
   ("oct"    'month 10)
   ("nov"   'month 11)
   ("dec"   'month 12)
   ("sun"         'day 0)
   ("mon"         'day 1)
   ("tue"        'day 2)
   ("wed"      'day 3)
   ("thu"       'day 4)
   ("fri"         'day 5)
   ("sat"       'day 6) )

;time units table
(def-lazy-table units-table
   ("year"           'year-unit     1)
   ("month"          'month-unit    1)
   ("fortnight"      'day-unit      14)
   ("week"           'day-unit      7)
   ("day"            'day-unit      1)
   ("hour"           'hour-unit     1)
   ("minute"         'minute-unit   1)
   ("min"            'minute-unit   1)
   ("second"         'sec-unit      1)
   ("sec"            'sec-unit      1))

;assorted relative time words
(def-lazy-table other-table
   ("tomorrow"       'day-unit      1)
   ("yesterday"      'day-unit      -1)
   ("today"          'day-unit      0)
   ("now"            'day-unit      0)
   ("last"           'unumber       -1)
   ("this"           'minute-unit   0)
   ("next"           'unumber       2)
   ("first"          'unumber       1)
   ;("second"         'unumber       2) 
   ("third"          'unumber       3)
   ("fourth"         'unumber       4)
   ("fifth"          'unumber       5)
   ("sixth"          'unumber       6)
   ("seventh"        'unumber       7)
   ("eighth"         'unumber       8)
   ("ninth"          'unumber       9)
   ("tenth"          'unumber       10)
   ("eleventh"       'unumber       11)
   ("twelfth"        'unumber       12)
   ("ago"            'ago   1))


;timezones
(def-lazy-table timezone-table
   ("gmt"    'zone     (hour  0)) ; Greenwich Mean */
   ("ut"     'zone     (hour  0)) ; Universal (Coordinated) */
   ("utc"    'zone     (hour  0))
   ("wet"    'zone     (hour  0)) ; Western European */
   ("bst"    'dayzone  (hour  0)) ; British Summer */
   ("wat"    'zone     (hour  1)) ; West Africa */
   ("at"     'zone     (hour  2)) ; Azores */
   ; 		#if     0
   ; 		; For completeness.  BST is also British Summer and GST is
   ; 		* also Guam Standard. */
   ; 		("bst"    'zone     (hour  3)) ; Brazil Standard */
   ; 		("gst"    'zone     (hour  3)) ; Greenland Standard */
   ; 		#endif
   ; 		#if 0
   ; 		("nft"    'zone     (hour 3.5))        ; Newfoundland */
   ; 		("nst"    'zone     (hour 3.5))        ; Newfoundland Standard */
   ; 		("ndt"    'dayzone  (hour 3.5))        ; Newfoundland Daylight */
   ; 		#endif
   ("ast"    'zone     (hour  4)) ; Atlantic Standard */
   ("adt"    'dayzone  (hour  4)) ; Atlantic Daylight */
   ("est"    'zone     (hour  5)) ; Eastern Standard */
   ("edt"    'dayzone  (hour  5)) ; Eastern Daylight */
   ("cst"    'zone     (hour  6)) ; Central Standard */
   ("cdt"    'dayzone  (hour  6)) ; Central Daylight */
   ("mst"    'zone     (hour  7)) ; Mountain Standard */
   ("mdt"    'dayzone  (hour  7)) ; Mountain Daylight */
   ("pst"    'zone     (hour  8)) ; Pacific Standard */
   ("pdt"    'dayzone  (hour  8)) ; Pacific Daylight */
   ("yst"    'zone     (hour  9)) ; Yukon Standard */
   ("ydt"    'dayzone  (hour  9)) ; Yukon Daylight */
   ("hst"    'zone     (hour 10)) ; Hawaii Standard */
   ("hdt"    'dayzone  (hour 10)) ; Hawaii Daylight */
   ("cat"    'zone     (hour 10)) ; Central Alaska */
   ("akst"   'zone     (hour 10)) ; Alaska Standard */
   ("akdt"   'zone     (hour 10)) ; Alaska Daylight */
   ("ahst"   'zone     (hour 10)) ; Alaska-Hawaii Standard */
   ("nt"     'zone     (hour 11)) ; Nome */
   ("idlw"   'zone     (hour 12)) ; International Date Line West */
   ("cet"    'zone     (hour -1)) ; Central European */
   ("met"    'zone     (hour -1)) ; Middle European */
   ("mewt"   'zone     (hour -1)) ; Middle European Winter */
   ("mest"   'dayzone  (hour -1)) ; Middle European Summer */
   ("mesz"   'dayzone  (hour -1)) ; Middle European Summer */
   ("swt"    'zone     (hour -1)) ; Swedish Winter */
   ("sst"    'dayzone  (hour -1)) ; Swedish Summer */
   ("fwt"    'zone     (hour -1)) ; French Winter */
   ("fst"    'dayzone  (hour -1)) ; French Summer */
   ("eet"    'zone     (hour -2)) ; Eastern Europe USSR Zone 1 */
   ("bt"     'zone     (hour -3)) ; Baghdad USSR Zone 2 */
   ; 		#if 0
   ; 		("it"     'zone     (hour -3.5)); Iran */
   ; 		#endif
   ; 		("zp4"    'zone     (hour -4)) ; USSR Zone 3 */
   ; 		("zp5"    'zone     (hour -5)) ; USSR Zone 4 */
   ; 		#if 0
   ; 		("ist"    'zone     (hour -5.5)); Indian Standard */
   ; 		#endif
   ("zp6"    'zone     (hour -6)) ; USSR Zone 5 */
   ; 		#if     0
   ; 		; For completeness.  NST is also Newfoundland Standard and SST is
   ; 		* also Swedish Summer. */
   ; 		("nst"    'zone     (hour -6.5)); North Sumatra */
   ; 		("sst"    'zone     (hour -7)) ; South Sumatra USSR Zone 6 */
   ; 		#endif  ; 0 */
   ("wast"   'zone     (hour -7)) ; West Australian Standard */
   ("wadt"   'dayzone  (hour -7)) ; West Australian Daylight */
   ; 		#if 0
   ; 		("jt"     'zone     (hour -7.5)); Java (3pm in Cronusland!) */
   ; 		#endif
   ("cct"    'zone     (hour -8)) ; China Coast USSR Zone 7 */
   ("jst"    'zone     (hour -9)) ; Japan Standard USSR Zone 8 */
   ; 		#if 0
   ; 		("cast"   'zone     (hour -9.5)); Central Australian Standard */
   ; 		("cadt"   'dayzone  (hour -9.5)); Central Australian Daylight */
   ; 		#endif
   ("east"   'zone     (hour -10))        ; Eastern Australian Standard */
   ("eadt"   'dayzone  (hour -10))        ; Eastern Australian Daylight */
   ("gst"    'zone     (hour -10))        ; Guam Standard USSR Zone 9 */
   ("nzt"    'zone     (hour -12))        ; New Zealand */
   ("nzst"   'zone     (hour -12))        ; New Zealand Standard */
   ("nzdt"   'dayzone  (hour -12))        ; New Zealand Daylight */
   ("idle"   'zone     (hour -12)) )      ; International Date Line East */

;military timezones
(def-lazy-table military-table
   ("a"      'zone  (hour   1))
   ("b"      'zone  (hour   2))
   ("c"      'zone  (hour   3))
   ("d"      'zone  (hour   4))
   ("e"      'zone  (hour   5))
   ("f"      'zone  (hour   6))
   ("g"      'zone  (hour   7))
   ("h"      'zone  (hour   8))
   ("i"      'zone  (hour   9))
   ("k"      'zone  (hour  10))
   ("l"      'zone  (hour  11))
   ("m"      'zone  (hour  12))
   ("n"      'zone  (hour -1))
   ("o"      'zone  (hour -2))
   ("p"      'zone  (hour -3))
   ("q"      'zone  (hour -4))
   ("r"      'zone  (hour -5))
   ("s"      'zone  (hour -6))
   ("t"      'zone  (hour -7))
   ("u"      'zone  (hour -8))
   ("v"      'zone  (hour -9))
   ("w"      'zone  (hour -10))
   ("x"      'zone  (hour -11))
   ("y"      'zone  (hour -12))
   ("z"      'zone  (hour   0)))

;meridians
(def-lazy-table meridians
   ("am" 'meridian 'meram)
   ("pm" 'meridian 'merpm) ) 

(define (to-year year)
   (let ((year (abs year)))
      ; XPG4 suggests that years 00-68 map to 2000-2068, and
      ; years 69-99 map to 1969-1999.  */
      (if (< year 69)
	  (+ year 2000)
	  (if (< year 100)
	      (+ year 1900)
	      year))))

(define (to-hour hours meridian)
   (case meridian
      ((mer24) (if (or (< hours 0) (> hours 23))
		   -1
		   hours))
      ((meram) (if (or (< hours 1) (> hours 12))
		   -1
		   (if (= hours 12)
		       0)))
      ((merpm) (if (or (< hours 1) (> hours 12))
		   -1
		   (if (= hours 12)
		       0
		       (+ hours 12))))
      (else (error 'to-hour "bad meridian" meridian))))

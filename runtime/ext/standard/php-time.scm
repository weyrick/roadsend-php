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

(module php-time-lib
   (include "../phpoo-extension.sch")
   (library profiler)
   (import (time-c-bindings "time-c-bindings.scm"))
   (import
    (parsedate "parsedate.scm"))
      
   ; exports
   (export
    (init-php-time-lib)

    ; standard lib
    (date_default_timezone_set ident)
    (date_default_timezone_get)
    (checkdate mon day year)
    (php-date format tstamp)
    (getdate tstamp)
    (gettimeofday)
    (gmdate format tstamp)
    (gmmktime hour min sec month day year is_dst)
    (gmstrftime format tstamp)
    (php-localtime tstamp assoc)
    (microtime)
    (php-mktime hour min sec month day year is_dst)
    (php-strftime format tstamp)
    (strtotime str now)
    (time)
    (uniqid prefix entropy)))


; init the module
(define (init-php-time-lib)
   1)

(define *dim* (vector 31 28 31 30 31 30 31 31 30 31 30 31))
(define *dim-l* (vector 31 29 31 30 31 30 31 31 30 31 30 31))

(define (days-in-month mon year)
   (set! mon (mkfixnum mon))
   (set! year (mkfixnum year))
   (if (and (> mon 0) (< mon 13))
       (if (leap-year? year)
	   (vector-ref *dim-l* (- mon 1))
	   (vector-ref *dim* (- mon 1)))
       0))

; checkdate -- Validate a gregorian date
(defbuiltin (checkdate mon day year)
;   (letrec ((numeric-string-or-num?
;	     ; for checking if a value is either a number or a numeric string
;	    (lambda (rval)
;	       (or (php-number? rval)
;		   (numeric-string? rval)))))
      ; if not numbers, return #f as per php 4.3.4
;      (if (not (and (numeric-string-or-num? mon)
;		    (numeric-string-or-num? day)
;		    (numeric-string-or-num? year)))
;	  (begin
;	     (php-warning "checkdate expects numbers for parameters")
;	     #f)
;	  (begin
	     (set! mon (convert-to-number mon))
	     (set! day (convert-to-number day))
	     (set! year (convert-to-number year))
	     (if (or (or (php-< mon 1) (php-> mon 12))
		     (or (php-< year 1) (php-> year 32767))
		     (or (php-< day 1) (php-> day (days-in-month mon year))))
		 #f
		 #t));)))
   

; date -- Format a local time/date
(define (day-suffix day)
   (if (and (>= day 10)
	    (<= day 19))
       "th"
       (let ((day-ones (remainder day 10)))
	  (cond ((= day-ones 1) "st")
		((= day-ones 2) "nd")
		((= day-ones 3) "rd")
		(else "th")))))

(define (stime-hour tstamp lead-zero)
   (let ((hour (date-hour tstamp)))
      (if (> hour 12)
	  (set! hour (- hour 12)))
      (if (= hour 0)
	  (set! hour 12))
      (if lead-zero
	  (if (< hour 10)
	      (string-append "0" (number->string hour)) 
	      (number->string hour))
	  (number->string hour))))

(define (stime-minute tstamp lead-zero)
   (let ((min (date-minute tstamp)))
      (if lead-zero
	  (if (< min 10)
	      (string-append "0" (number->string min)) 
	      (number->string min))
	  (number->string min))))


(define (tzname)
   (values
    (pragma::bstring
     "string_to_bstring(tzname[0])")
    (pragma::bstring
     "string_to_bstring(tzname[1])")))

(define (tzval tdate)
  (multiple-value-bind (name0 name1)
     (tzname)
     (if (> (date-is-dst tdate) 0)
	 name1
	 name0)))

(define (GMT-hours tstamp)
   (let* ((tzval (if (> (date-is-dst tstamp) 0)
		     (- (date-timezone tstamp) 3600)
		     (date-timezone tstamp)))
	  (sign (if (> tzval 0) "-" "+"))
	  (off1 (abs (/ tzval 3600)))
	  (off2 (abs (/ (modulo tzval 3600) 60)))
	  (soff1 "")
	  (soff2 ""))
      (if (< off1 10)
	  (set! soff1 (string-append "0" (number->string off1)))
	  (set! soff1 (number->string off1)))
      (if (< off2 10)
	  (set! soff2 (string-append "0" (number->string off2)))
	  (set! soff2 (number->string off2)))
      (string-append sign soff1 soff2)))

; take a date, return offset in seconds from GMT
(define (tzoffsecs tstamp)
   (if (> (date-is-dst tstamp) 0)
       (- (- (date-timezone tstamp) 3600))
       (- (date-timezone tstamp))))

; takes a date, spits out another date with GMT offset added in
(define (tzoffset tstamp)
   (let ((csecs (date->seconds tstamp))
	 (offsecs (tzoffsecs tstamp)))
      (seconds->date (- csecs (make-elong offsecs)))))

(defalias date php-date)
(defbuiltin (php-date format (tstamp 'unpassed))
   (if (eqv? tstamp 'unpassed)
       (set! tstamp (current-date))
       (set! tstamp (seconds->date (onum->elong (convert-to-integer tstamp)))))
   (parse-date (mkstr format) tstamp))

(defbuiltin (gmdate format (tstamp 'unpassed))
   (if (eqv? tstamp 'unpassed)
       (set! tstamp (tzoffset (current-date)))
       (set! tstamp (tzoffset (seconds->date (onum->elong (convert-to-integer tstamp))))))
   (parse-date (mkstr format) tstamp))

(define (parse-date format tstamp)
   (let ((date-grammar
	  (regular-grammar ()
	     (#\a (if (>= (date-hour tstamp) 12)
			"pm"
			"am"))
	     (#\A (if (>= (date-hour tstamp) 12)
			"PM"
			"AM"))
	     ; B - Swatch Internet time
	     ;d	Day of the month, 2 digits with leading zeros	01 to 31
	     (#\d (if (< (date-day tstamp) 10)
			(string-append "0" (number->string (date-day tstamp))) 
			(number->string (date-day tstamp))))
	     ;D	A textual representation of a day, three letters	Mon through Sun
	     (#\D (day-aname (date-wday tstamp)))
	     ;e Timezone identifier
	     (#\e (or (getenv "TZ") ""))
	     ;F	A full textual representation of a month, such as January or March
	     ;January through December
	     (#\F (month-name (date-month tstamp)))
	     ;g	12-hour format of an hour without leading zeros	1 through 12
	     (#\g (stime-hour tstamp #f))
	     ;G	24-hour format of an hour without leading zeros	0 through 23
	     (#\G (number->string (date-hour tstamp)))
	     ;h	12-hour format of an hour with leading zeros	01 through 12
	     (#\h (stime-hour tstamp #t))
	     ;H	24-hour format of an hour with leading zeros	00 through 23
	     (#\H (if (< (date-hour tstamp) 10)
			(string-append "0" (number->string (date-hour tstamp))) 
			(number->string (date-hour tstamp))))
	     ;i	Minutes with leading zeros	00 to 59
	     (#\i (stime-minute tstamp #t))
	     ;I (capital i)	Whether or not the date is in daylights savings time
	     ;1 if Daylight Savings Time, 0 otherwise.
	     (#\I (if (> (date-is-dst tstamp) 0) "1" "0"))
	     ;j	Day of the month without leading zeros	1 to 31
	     (#\j (number->string (date-day tstamp)))
	     ;l (lowercase 'L')	A full textual representation of the day of the week	Sunday through Saturday
	     (#\l (day-name (date-wday tstamp)))
	     ;L	Whether it's a leap year	1 if it is a leap year, 0 otherwise.
	     (#\L (if (leap-year? (date-year tstamp)) "1" "0"))
	     ;m	Numeric representation of a month, with leading zeros	01 through 12
	     (#\m (if (< (date-month tstamp) 10)
			(string-append "0" (number->string (date-month tstamp))) 
			(number->string (date-month tstamp))))
	     ;M	A short textual representation of a month, three letters	Jan through Dec
	     (#\M (month-aname (date-month tstamp)))
	     ;n	Numeric representation of a month, without leading zeros	1 through 12
	     (#\n (number->string (date-month tstamp)))
	     ;O	Difference to Greenwich time (GMT) in hours	Example: +0200
	     (#\O (GMT-hours tstamp))
	     ;o ISO-8601 year number. This has the same value as Y, except that if the ISO week number (W) belongs to the previous or next year, that year is used instead
	     ; XXX
	     (#\o (number->string (date-year tstamp)))
	     ;r	RFC 822 formatted date	Example: Thu, 21 Dec 2000 16:01:07 +0200
	     (#\r (mkstr ; 3 letter name of weekday
		         (day-aname (date-wday tstamp)) ", "
			 ; day of month with leading 0's
			 (if (< (date-day tstamp) 10)
			     (string-append "0" (number->string (date-day tstamp))) 
			     (number->string (date-day tstamp))) " "
			 ; 3 letter day of month
			 (month-aname (date-month tstamp)) " "
			 ; 4 digit year
			 (number->string (date-year tstamp)) " "
			 ; time stamp, all with leading 0's
			 (if (< (date-hour tstamp) 10)
			     (string-append "0" (number->string (date-hour tstamp))) 
			     (number->string (date-hour tstamp))) ":"
			 (stime-minute tstamp #t) ":"
			 (if (< (date-second tstamp) 10)
			     (string-append "0" (number->string (date-second tstamp))) 
			     (number->string (date-second tstamp))) " "
			 ; GMT offset
			 (GMT-hours tstamp)))			 
	     ;s	Seconds, with leading zeros	00 through 59
	     (#\s (if (< (date-second tstamp) 10)
			(string-append "0" (number->string (date-second tstamp))) 
			(number->string (date-second tstamp))))
	     ;S	English ordinal suffix for the day of the month,
	     ;2 characters: st, nd, rd or th. Works well with j
	     (#\S (day-suffix (date-day tstamp)))
	     ;t	Number of days in the given month	28 through 31
	     (#\t (number->string
		     (days-in-month (date-month tstamp)
				    (date-year tstamp))))
	     ;T	Timezone setting of this machine	Examples: EST, MDT ...
	     (#\T (tzval tstamp))
	     ;U	Seconds since the Unix Epoch (January 1 1970 00:00:00 GMT)	See also time()
	     (#\U (elong->string (current-seconds)))
	     ;w	Numeric representation of the day of the week	0 (for Sunday) through 6 (for Saturday)
	     (#\w (number->string (- (date-wday tstamp) 1)))
	     ;W	ISO-8601 week number of year, weeks starting on Monday
	     ; XXX
	     ;(added in PHP 4.1.0) Example: 42 (the 42nd week in the year)
	     ;Y	A full numeric representation of a year, 4 digits
	     ;Examples: 1999 or 2003
	     (#\Y (number->string (date-year tstamp)))
	     ;y	A two digit representation of a year	Examples: 99 or 03
	     (#\y (substring (number->string (date-year tstamp)) 2 4))
	     ;z	The day of the year	0 through 366
	     (#\z (number->string (- (date-yday tstamp) 1)))
	     ;Z	Timezone offset in seconds. The offset for timezones west of UTC is always negative,
	     ;    and for those east of UTC is always positive.	-43200 through 43200
	     (#\Z (number->string (tzoffsecs tstamp)))
	     (#\\ "")
	     ((: #\\ all)
	      (the-substring 1 2))
	     (else
	      (if (char? (the-failure))
		  (the-string)
		  (the-failure))) )))

      (append-strings (get-tokens-from-string date-grammar format))))


; getdate -- Get date/time information
(defbuiltin (getdate (tstamp 'unpassed))
   (let ((result (make-php-hash))
	 (tdate (if (eqv? tstamp 'unpassed)
		    (current-date)
		    (seconds->date (onum->elong (convert-to-integer tstamp))))))
      (php-hash-insert! result "seconds" (int->onum (date-second tdate)))
      (php-hash-insert! result "minutes" (int->onum (date-minute tdate )))
      (php-hash-insert! result "hours" (int->onum (date-hour tdate)))
      (php-hash-insert! result "mday" (int->onum (date-day tdate)))
      (php-hash-insert! result "wday" (int->onum (- (date-wday tdate) 1)))
      (php-hash-insert! result "mon" (int->onum (date-month tdate)))
      (php-hash-insert! result "year" (int->onum (date-year tdate)))
      (php-hash-insert! result "yday" (int->onum (- (date-yday tdate) 1)))
      (php-hash-insert! result "weekday" (day-name (date-wday tdate)))
      (php-hash-insert! result "month" (month-name (date-month tdate)))
      (php-hash-insert! result 0 (elong->onum (date->seconds tdate)))
      result))
      
(define (make-timeval::timeval*)
   (pragma::timeval* "(struct timeval*)GC_MALLOC_ATOMIC(sizeof(struct timeval))"))

(define (make-timezone::timezone*)
   (pragma::timezone* "(struct timezone*)GC_MALLOC_ATOMIC(sizeof(struct timezone))"))

(define *default-timezone* "UTC")

; set timezone
(defbuiltin (date_default_timezone_set ident)
   (let ((tz (mkstr ident)))
      (putenv "TZ" tz)
      #t))

; get timezone
(defbuiltin (date_default_timezone_get)
   (or (getenv "TZ")
       *default-timezone*))

; gettimeofday -- Get current time
(defbuiltin (gettimeofday)
   (let ((result (make-php-hash))
	 (tv (make-timeval))
	 (tz (make-timezone)))
      (if (= (c-gettimeofday tv tz) 0)
	  (begin
	     (php-hash-insert! result "sec" (elong->onum (timeval*-sec tv)))
	     (php-hash-insert! result "usec" (elong->onum (timeval*-usec tv)))
	     (php-hash-insert! result "minuteswest" (/fx (date-timezone (current-date)) 60)) ;(int->onum (timezone*-minuteswest tz)))
	     (php-hash-insert! result "dsttime" (date-is-dst (current-date))) ;(int->onum (timezone*-dsttime tz)))
	     result)
	  #f)))
      

; gmmktime -- Get UNIX timestamp for a GMT date
(defbuiltin (gmmktime (hour 'unpassed) (min 'unpassed) (sec 'unpassed)
		    (month 'unpassed) (day 'unpassed) (year 'unpassed) (is_dst 'unpassed))
   (let* ((mt (do-mktime hour min sec month day year is_dst))
	  (offsecs (tzoffsecs mt)))
      (convert-to-integer (+ (date->seconds mt) (make-elong offsecs)))))

; gmstrftime --  Format a GMT/UTC time/date according to locale settings
(defbuiltin (gmstrftime format (tstamp 'unpassed))
   (let ((tstamp
	  (if (eqv? tstamp 'unpassed)
	      (gmtime (current-seconds))
	      (gmtime (onum->elong (convert-to-integer tstamp))))))
      (strftime tstamp (mkstr format))))

; localtime -- Get the local time
(defalias localtime php-localtime)
(defbuiltin (php-localtime (tstamp 'unpassed) (assoc 'unpassed))
   (let ((result (make-php-hash))
	 (tdate (if (eqv? tstamp 'unpassed)
		    (current-date)
		    (seconds->date (onum->elong (convert-to-integer tstamp))))))
      (if (or (eqv? assoc 'unpassed)
	      (eqv? assoc #f))
	  (begin
	     (php-hash-insert! result :next (int->onum (date-second tdate)))
	     (php-hash-insert! result :next (int->onum (date-minute tdate )))
	     (php-hash-insert! result :next (int->onum (date-hour tdate)))
	     (php-hash-insert! result :next (int->onum (date-day tdate)))
	     (php-hash-insert! result :next (int->onum (- (date-month tdate) 1)))
	     (php-hash-insert! result :next (int->onum (- (date-year tdate) 1900)))
	     (php-hash-insert! result :next (int->onum (- (date-wday tdate) 1)))
	     (php-hash-insert! result :next (int->onum (- (date-yday tdate) 1)))
	     (php-hash-insert! result :next (int->onum (date-is-dst tdate))))
	  (begin
	     (php-hash-insert! result "tm_sec" (int->onum (date-second tdate)))
	     (php-hash-insert! result "tm_min" (int->onum (date-minute tdate)))
	     (php-hash-insert! result "tm_hour" (int->onum (date-hour tdate)))
	     (php-hash-insert! result "tm_mday" (int->onum (date-day tdate)))
	     (php-hash-insert! result "tm_mon" (int->onum (- (date-month tdate) 1)))
	     (php-hash-insert! result "tm_year" (int->onum (- (date-year tdate) 1900)))
	     (php-hash-insert! result "tm_wday" (int->onum (- (date-wday tdate) 1)))
	     (php-hash-insert! result "tm_yday" (int->onum (- (date-yday tdate) 1)))
	     (php-hash-insert! result "tm_isdst" (int->onum (date-is-dst tdate)))))	  
      result))   

; microtime --  Return current UNIX timestamp with microseconds
(defbuiltin (microtime)
   (let ((tv (make-timeval))
	 (tz (make-timezone))
	 (usec *zero*)
	 (sec 0.0)
	 (s-sec "")
	 (s-usec ""))
      (if (= (c-gettimeofday tv tz) 0)
	  (begin
	     (set! sec (elong->onum (timeval*-sec tv)))
	     (set! usec (php-/ (elong->onum (timeval*-usec tv)) 1000000.00))
	     ; ugly
	     (set! s-sec (onum->string sec 10))
;	     (set! s-sec (substring s-sec 0 (- (string-length s-sec) 2)))
	     ; uglier
	     (set! s-usec (onum->string usec 10))
	     (if (< (string-length s-usec) 10)
		 (set! s-usec (string-append s-usec (make-string (- 10 (string-length s-usec)) #\0))))
	     (string-append s-usec " " s-sec))
	  
	  #f)))

; mktime -- Get UNIX timestamp for a date
(define (do-mktime hour min sec month day year is_dst)
   (let ((c-date (current-date)))
      (when (eqv? hour 'unpassed)
	 (set! hour (date-hour c-date)))
      (when (eqv? min 'unpassed)
	 (set! min (date-minute c-date)))
      (when (eqv? sec 'unpassed)
	 (set! sec (date-second c-date)))
      (when (eqv? month 'unpassed)
	 (set! month (date-month c-date)))
      (when (eqv? day 'unpassed)
	 (set! day (date-day c-date)))
      (when (eqv? year 'unpassed)
	 (set! year (date-year c-date)))
      ; is_dst is deprecated, always set to dst from current TZ
      (set! is_dst (date-is-dst (current-date)))
      (cond ((php-< year 70) (set! year (php-+ year 2000)))
	    ((and (php->= year 70)
		  (php-<= year 99)) (set! year (php-+ year 1900))))
      ; windows doesn't support negative timestamps
      (cond-expand
       (PCC_MINGW (when (php-< year 1900)
			(set! year (php-+ year 1900))))
       (else #t))
      (make-date sec: (mkfixnum sec)
		 min: (mkfixnum min)
		 hour: (mkfixnum hour)
		 day: (mkfixnum day)
		 month: (mkfixnum month)
		 year: (mkfixnum year)
		 ;; XXX This is a workaround for a bigloo bug. We should be
		 ;; able to just say (date-timezone (current-date)), but he
		 ;; does the adjustment incorrectly for timezones west of GMT.
		 ;; Until either Manuel changes it himself or accepts my patch
		 ;; it's easier to work around it here to avoid having to
		 ;; patch bigloo locally. --Nate 2004-05-26
		 timezone: (let ((tz (date-timezone (current-date))))
                              (if (< tz 0)
                                  tz
                                  (- tz)))
		 dst: (mkfixnum is_dst))))
	 
(defalias mktime php-mktime)
(defbuiltin (php-mktime (hour 'unpassed) (min 'unpassed) (sec 'unpassed)
		    (month 'unpassed) (day 'unpassed) (year 'unpassed) (is_dst 'unpassed))
   (convert-to-integer (date->seconds (do-mktime hour min sec month day year is_dst))))


; strftime --  Format a local time/date according to locale settings
(defalias strftime php-strftime)

(defbuiltin (php-strftime format (tstamp 'unpassed))
   (let ((tstamp
	  (if (eqv? tstamp 'unpassed)
	      (current-seconds)
	      (onum->elong (convert-to-integer tstamp)))))
      (strftime (localtime tstamp) (mkstr format))))

; strtotime --  Parse about any English textual datetime description into a UNIX timestamp
(defbuiltin (strtotime timestr (now 'unpassed))
   (set! timestr (mkstr timestr))
   (if (eqv? now 'unpassed)
       (super-date-parser timestr)
       (super-date-parser timestr (seconds->date (onum->elong (convert-to-number now))))))

; time -- Return current UNIX timestamp
(defbuiltin (time)
   (convert-to-integer (current-seconds)))

; uniqid -- Generate a unique ID
(defbuiltin (uniqid (prefix "") (entropy 'unpassed))
   (set! prefix (mkstr prefix)) 
   (let ((prefix (if (> (string-length prefix) 114) (substring prefix 0 114) prefix))
	 (str (make-string 128)))
      (sleep 1)
      (pragma "{
struct timeval tv;
int sec, usec;
gettimeofday(&tv, NULL);
sec = (int) tv.tv_sec;
usec = (int) (tv.tv_usec % 0x100000);
sprintf($1, \"%s%08x%05x\", $2, sec, usec);}
" ($bstring->string str) ($bstring->string prefix))
      (substring str 0 (+ (string-length prefix) 13))))

;(define (time-t->time-t* foo::time-t)
;   (pragma::time-t* "&$1" foo))

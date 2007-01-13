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

(module time-c-bindings
;	(library common)
   (extern
    (include "sys/time.h")
    (include "time.h")    
    (include "windows-time.h") ;mingw
    
;     (macro localtime-tm::tm* (::time-t*) "localtime") ;mingw
;     (macro gmtime-tm::tm* (::time-t*) "gmtime");mingw
    
;     (type tm ;mingw
; 	  (struct (sec::int "tm_sec")
; 		  (min::int "tm_min")
; 		  (hour::int "tm_hour")
; 		  (mday::int "tm_mday")
; 		  (mon::int "tm_mon")
; 		  (year::int "tm_year"))
; 	  "struct tm")
    (type timeval
	  (struct (sec::elong "tv_sec")
		  (usec::elong "tv_usec"))
	  "struct timeval")
    (type timezone
	  (struct (minuteswest::int "tz_minuteswest")
		  (dsttime::int "tz_dsttime"))
	  "struct timezone")
    (c-gettimeofday::int (::timeval* ::timezone*) "gettimeofday"))
   (export
    (gmtime::tm #!optional 
                (seconds::elong (current-seconds))
                (tm::tm (make-tm))) ;;mingw
    (localtime::tm #!optional 
                   (seconds::elong (current-seconds))
                   (tm::tm (make-tm))) ;;mingw 
    )

;;tm for mingw
;   (export (tm-sec::int o::tm))
;   (export (tm-min::int o::tm))
;   (export (tm-hour::int o::tm))
;   (export (tm-mday::int o::tm))
;   (export (tm-mon::int o::tm))
;   (export (tm-year::int o::tm))

;   (type (subtype tm #"struct tm*" (cobj))
;         (coerce cobj tm () (cobj->tm))
;         (coerce tm cobj () (tm->cobj))
;         (coerce
;           tm
;           bool
;           ()
;           ((lambda (x) (pragma::bool #"$1 != NULL" x))))
;         (subtype btm #"obj_t" (obj))
;         (coerce obj btm () ())
;         (coerce btm obj () ())
;         (coerce btm tm (tm?) (btm->tm))
;         (coerce
;           tm
;           obj
;           ()
;           ((lambda (result)
;               (pragma::btm
;                 #"cobj_to_foreign($1, $2)"
;                 'tm
;                 result)))))
;   (foreign
;     (macro tm cobj->tm (cobj) #"(struct tm*)")
;     (macro cobj tm->cobj (tm) #"(long)")
;     (macro tm
;            btm->tm
;            (foreign)
;            #"(struct tm*)FOREIGN_TO_COBJ"))
;   (export (tm?::bool o::obj))

)






; (define (localtime::tm
;          #!optional
;          (seconds::elong (current-seconds))
;          (tm::tm (make-tm)))
;   (let ()
;     (pragma #"unsigned long iseconds = $1" seconds)
;     (pragma #"localtime_r(&iseconds, $1)" tm)
;     tm))


;                       int     tm_sec;         /* seconds */
;                       int     tm_min;         /* minutes */
;                       int     tm_hour;        /* hours */
;                       int     tm_mday;        /* day of the month */
;                       int     tm_mon;         /* month */
;                       int     tm_year;        /* year */
;                       int     tm_wday;        /* day of the week */
;                       int     tm_yday;        /* day in the year */
;                       int     tm_isdst;       /* daylight saving time */


;; mingw doesn't have localtime_r
;; the localtime and gmtime in libcommon treat seconds as a float,
;; which is broken.
(define (localtime::tm #!optional 
		       (seconds::elong (current-seconds))
		       (tm::tm (make-tm)))
    (let ()
      (pragma 
" { unsigned long iseconds = $1;
    struct tm *tittm = localtime(&iseconds);
    if (tittm) {
       $2->tm_sec = tittm->tm_sec;
       $2->tm_min = tittm->tm_min;
       $2->tm_hour = tittm->tm_hour;
       $2->tm_mday = tittm->tm_mday;
       $2->tm_mon = tittm->tm_mon;
       $2->tm_year = tittm->tm_year;
       $2->tm_wday = tittm->tm_wday;
       $2->tm_yday = tittm->tm_yday;
       $2->tm_isdst = tittm->tm_isdst;
     }
  }" seconds tm))
  tm)

; (define (gmtime::tm
;          #!optional
;          (seconds::elong (current-seconds))
;          (tm::tm (make-tm)))
;   (let ()
;     (pragma #"unsigned long iseconds = $1" seconds)
;     (pragma #"gmtime_r(&iseconds, $1)" tm)
;     tm))

(define (gmtime::tm #!optional 
		       (seconds::elong (current-seconds))
		       (tm::tm (make-tm)))
    (let ()
      (pragma 
" { unsigned long iseconds = $1;
    struct tm *tittm = gmtime(&iseconds);
    if (tittm) {
       $2->tm_sec = tittm->tm_sec;
       $2->tm_min = tittm->tm_min;
       $2->tm_hour = tittm->tm_hour;
       $2->tm_mday = tittm->tm_mday;
       $2->tm_mon = tittm->tm_mon;
       $2->tm_year = tittm->tm_year;
       $2->tm_wday = tittm->tm_wday;
       $2->tm_yday = tittm->tm_yday;
       $2->tm_isdst = tittm->tm_isdst;
     }
  }" seconds tm))
  tm)

  
  


; (define (make-tm::tm)
;   (pragma::tm
;     #"(struct tm*)GC_malloc_atomic(sizeof(struct tm))"))


; (define (tm-sec::int o::tm)
;   (let ((result (pragma::int #"$1->tm_sec" o)))
;     result))


; (define (tm-min::int o::tm)
;   (let ((result (pragma::int #"$1->tm_min" o)))
;     result))


; (define (tm-hour::int o::tm)
;   (let ((result (pragma::int #"$1->tm_hour" o)))
;     result))


; (define (tm-mday::int o::tm)
;   (let ((result (pragma::int #"$1->tm_mday" o)))
;     result))


; (define (tm-mon::int o::tm)
;   (let ((result (pragma::int #"$1->tm_mon" o)))
;     result))


; (define (tm-year::int o::tm)
;   (let ((result (pragma::int #"$1->tm_year" o)))
;     result))


; (define (tm?::bool o::obj)
;   (and (foreign? o) (eq? (foreign-id o) 'tm)))

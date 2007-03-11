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
   (extern
    (include "sys/time.h")
    (include "time.h")    
    (include "windows-time.h") ;mingw
    
    (type timeval
	  (struct (sec::elong "tv_sec")
		  (usec::elong "tv_usec"))
	  "struct timeval")
    (type timezone
	  (struct (minuteswest::int "tz_minuteswest")
		  (dsttime::int "tz_dsttime"))
	  "struct timezone")
    (macro c-gettimeofday::int (::timeval* ::timezone*) "gettimeofday"))
   (export
    (gmtime::tm #!optional 
                (seconds::elong (current-seconds))
                (tm::tm (make-tm))) ;;mingw
    (localtime::tm #!optional 
                   (seconds::elong (current-seconds))
                   (tm::tm (make-tm))) ;;mingw 
    )

)



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

  
  

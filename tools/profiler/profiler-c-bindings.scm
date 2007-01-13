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

(module profiler-c-bindings
   (export
    (now)
    (time-difference t1 t2))
   (extern
    (include "time.h")
    (include "sys/time.h")
    (type proftv
	  (struct (sec::elong "tv_sec")
		  (usec::elong "tv_usec"))
	  "struct timeval")
    (type proftz
	  (struct (minuteswest::int "tz_minuteswest")
		  (dsttime::int "tz_dsttime"))
	  "struct timezone")
    (macro profc-gettimeofday::int (::proftv* ::proftz*) "gettimeofday")) )


(define (now)
   (let ((tz (pragma::proftz* "((struct timezone*)NULL)"))
	 (t1 (make-proftv*)))
      (profc-gettimeofday t1 tz)
      t1))

(define (time-difference t1 t2)
   (+ (- (elong->flonum (proftv*-sec t2))
	 (elong->flonum (proftv*-sec t1)))
      (/ (- (elong->flonum (proftv*-usec t2))
	    (elong->flonum (proftv*-usec t1)))
	 1000000.0)))

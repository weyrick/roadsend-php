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

(module mystical-profiler
   (import (profiler-c-bindings "profiler-c-bindings.scm"))
   ;    (extern
   ;     (include "time.h")
   ;     (include "sys/time.h")
   ;     (type proftv
   ; 	  (struct (sec::elong "tv_sec")
   ; 		  (usec::elong "tv_usec"))
   ; 	  "struct timeval")
   ;     (type proftz
   ; 	  (struct (minuteswest::int "tz_minuteswest")
   ; 		  (dsttime::int "tz_dsttime"))
   ; 	  "struct timezone")
   ;     (profc-gettimeofday::int (::proftv* ::proftz*) "gettimeofday"))
   (export
    *source-level-profile*
    (profile-enter signature)
    (profile-leave signature)
    (finish-profiling)))

;#t if we want the php source-level profiling code to kick in.
;(define *source-level-profile* #f)



; Report files list the time per call, total calls, and total time for
; each function.

; Creative additional statistics are of course possible.  The main point
; of this module is to provide the framework for collecting them.

(define *source-level-profile* #f)

(define *call-graph* (make-hashtable))
(define *profile-data* (make-hashtable))
(define *profile-stack* '())

(define (profile-enter signature)
   (when *source-level-profile*
      ;note the time of entry
      (let ((enter-time (now)))
	 ;unless this is the first entry
	 (unless (null? *profile-stack*)
	    ;add the time up till now onto the record for the function that called us
	    (increment-time (caar *profile-stack*) (cdar *profile-stack*) 0 enter-time)
	    ;note the call for the call-graph
	    (add-edge (caar *profile-stack*) signature)))
      ;now push the function we're entering onto the profile stack
      (set! *profile-stack*
	    (cons (cons signature (now)) *profile-stack*)) ))


(define (profile-leave signature)
   (when *source-level-profile*
      ;note the time of exit
      (let ((leave-time (now)))
	 ;add the time up till now onto the record for the function we're leaving
	 (increment-time (caar *profile-stack*) (cdar *profile-stack*) 1 leave-time))
      ;    (unless (eq? (caar *profile-stack*) signature)
      ;       (error 'profile-leave
      ; 	     (format "profile calls out of order, leaving ~A but top function is ~A"
      ; 		     signature (caar *profile-stack*))
      ; 	     *profile-stack*))
      ;pop the function we're leaving off the profile stack
      (set! *profile-stack* (cdr *profile-stack*))
      ;unless we just left the last function we were profiling
      (unless (null? *profile-stack*)
	 ;replace the head of the stack with 
	 (set! *profile-stack*
	       ;add an entry with the name of the function that called us
	       ;and an updated from-time
	       (cons
		(cons (caar *profile-stack*) (now))
		(cdr *profile-stack*))))))
       


(define (increment-time function from-time call-count to-time)
   ;look up the profile record for the function
   (let ((old-record (hashtable-get *profile-data* function)))
      ;set the total-time and total calls either to the value in the old record,
      ;or 0 if the old record wasn't found.
      (let ((total-time (or (and old-record (car old-record)) 0))
	    (total-calls (or (and old-record (cdr old-record)) 0)))
	 ;now update the old record with  
	 (hashtable-put! *profile-data* function
			 ;the total time used so far
			 (cons (+ total-time (time-difference from-time (now)))
			       ;and the total calls so far
			       (+fx total-calls call-count))))))

(define (add-edge from to)
   ;make the edge into a string
   (let ((edge (string-append (symbol->string from) "  ->  " (symbol->string to))))
      ;lookup the total calls, or start with zero if we didn't have this edge yet
      (let ((calls (or (hashtable-get *call-graph* edge) 0)))
	 ;save the new total calls
	 (hashtable-put! *call-graph* edge (+fx calls 1))) ))





; (register-exit-function!
;  (lambda (a) (finish-profiling) a))


(define (finish-profiling)
   (let ((profile-dump-name
	  (pregexp-replace* ":"
			    (pregexp-replace* "\\\\"
					      (with-output-to-string
						  (lambda () (apply display* (command-line))))
					      "_")
			    "")))
      (with-output-to-file (string-append profile-dump-name ".profile")
	 (lambda ()
	    (let ((profile-data '()))
	       (hashtable-for-each *profile-data*
		  (lambda (key val)
		     (set! profile-data
			   (cons
			    (list key (car val) (cdr val))
			    profile-data))))
	       (set! profile-data
		     (sort profile-data
			   (lambda (x y)
			      (> (cadr x) (cadr y)))))
	       (print "Time\t\tCalls\t\tTime/call\t\tSig")
	       (for-each
		(lambda (a)
		   (print (cadr a) "\t\t" (max 1 (caddr a)) "\t\t" (/ (cadr a) (max 1 (caddr a))) "\t\t" (car a)))
		profile-data))
	    (newline)
	    (newline)
	    (newline)
	    (let ((call-data '()))
	       (hashtable-for-each *call-graph*
		  (lambda (key val)
		     (set! call-data (cons (list key val) call-data))
		     (set! call-data
			   (sort call-data
				 (lambda (x y)
				    (> (cadr x) (cadr y)))))))
	       (print "Edge\t\t\t\tCalls")
	       (let loop ((calls-printed 0)
			  (call-data call-data))
		    (when (and (< calls-printed 50)
			       (pair? call-data))
		       (print (caar call-data) "\t" (cdar call-data))
		       (loop (+fx 1 calls-printed) (cdr call-data)))))))))


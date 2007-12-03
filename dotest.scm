;; ***** BEGIN LICENSE BLOCK *****
;; Roadsend PHP Compiler
;; Copyright (C) 2007 Roadsend, Inc.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
;; ***** END LICENSE BLOCK *****

(module dotest
   (main dotest)
;   (library "common")
   (extern
    (include "sys/time.h")
    (include "runtime/ext/standard/windows-time.h")
    (type timeval
	  (struct (tv-sec::elong "tv_sec")
		  (tv-usec::elong "tv_usec"))
	  "struct timeval")
    (type timezone* opaque "struct timezone*")
    (macro gettimeofday::int (::timeval* ::timezone*) "gettimeofday") ) )

(define *phpoo* (string-append (getenv "PCC_HOME") 
			       (string (file-separator)) 
			       "compiler" 
			       (string (file-separator)) 
			       "pcc " (or (getenv "PCC_OPTS") "")))

(define *php-bin* "php")
(if (getenv "PHP")
    (set! *php-bin* (getenv "PHP")))
(if (getenv "PHP5")
    (set! *php-bin* (getenv "PHP5")))

(define *php* (string-append *php-bin* " -d display_errors=off")) ;-n?  what if my mysql.sock is someplace else?
(define *diff* (cond-expand (PCC_MINGW "diff -u -w ") (else "diff -u ")))


(flush-fprint (current-error-port) "using roadsend command: " *phpoo*)
(flush-fprint (current-error-port) "using zend command    : " *php*)


; optimize?
(when (getenv "OPTIMIZE")
   (flush-fprint (current-error-port) "compiling all tests with optimization")
   ;;looks like static is no longer fastest.. ?!
   (set! *phpoo* (string-append *phpoo* " -O"))); --static")))

(when (getenv "TEST_CYCLES")
   (flush-fprint (current-error-port) (format "operating with ~a test cycles" (getenv "TEST_CYCLES")))) 

;XXX this is temporary
(define *phpoo-interpreter* (string-append "pcc " (or (getenv "PCC_OPTS") "") " -f "))

(define *run* 0)
(define *build-fail* 0)
(define *run-fail* 0)
(define *interpret-fail* 0)

(define *run-failures* '())
(define *interpret-failures* '())

(define *faster-compiled* 0)
(define *faster-interpreted* 0)

(define *php-run-total* 0.0)
(define *raven-run-total* 0.0)
(define *raven-interp-total* 0.0)

(define-macro (time . prog)
   `(let ((t1 (make-timeval*))
	  (t2 (make-timeval*))
	  (tz (pragma::timezone* "((struct timezone*)NULL)")))
       (gettimeofday t1 tz)
       ,@prog
       (gettimeofday t2 tz)
       (time-difference t1 t2)))


(define (average-time cycles thunk)
   (/ (time
       (let loop ((i 0))
	  (when (< i cycles)
	     (thunk)
	     (loop (+ i 1)))))
      cycles))

(define (aborting-system . args)
   (let ((retval (apply system args)))
      (if (= retval 2)
	  (error 'aborted (format "~A was aborted, exiting." (car args)) retval)
	  retval)))

(define (add-run-fail what)
   (set! *run-fail* (+ *run-fail* 1))
   (set! *run-failures* (cons what *run-failures*)))

(define (add-interpreter-fail what)
   (set! *interpret-fail* (+ *interpret-fail* 1))
   (set! *interpret-failures* (cons what *interpret-failures*)))

(define (test file home target cycles)
   "Copy FILE from HOME to TARGET, run it CYCLES times with Zend and Raven,
and compare the results"
   (aborting-system "cp " home "/" file " " target)
   (set! *run* (+ 1 *run*))
   (let ((zend-time 0)
	 (raven-time 0)
	 (raven-interpreter-time 0)
	 (build-time 0)
	 (retval 0)
	 (mydir (pwd))
	 (pass (color green "[PASS]"))
	 (fail (color red "[FAIL]"))
	 ;(basename (string-append target "/" (prefix file)));
	 (basename (prefix file))
	 (zend (lambda (f)
		  (aborting-system *php* " -f " f ".php > " f ".ee.out") ))
	 (raven-build (lambda (f)
			 (aborting-system *phpoo* " " f ".php > " f ".log 2>&1") ))
	 (raven-interpret (lambda (f)
			     (aborting-system *phpoo-interpreter* " " f ".php > "
					      f ".rebel.interpreter.out 2> " f ".rebel.interpreter.log")))
	 (raven-run (lambda (f)
		       ;; XXX without this ./, tests like "sort" might run the wrong command
		       (aborting-system "." (cond-expand (PCC_MINGW "\\") (else "/"))
					f " > " f ".rebel.out")))
	 (diff (lambda (f)
		  (let* ((dfile (string-append f ".diff"))
			 (retval (aborting-system *diff* f ".ee.out " f ".rebel.out > " dfile)))
		     ; clean empty diff files
		     (when (and (file-exists? dfile)
				(= 0 (file-size dfile)))
			(delete-file dfile))
		     retval))))
      (flush-print "[" file "]")
      (bind-exit (return)
	 ; chdir
	 (chdir target)
	 ;;Evil Empire
	 (set! zend-time (time (zend basename)))
	 ;;Rebel Alliance Build
	 (set! build-time (time (set! retval (raven-build basename))))
	 (if (= 0 retval)
	     (display (format "build:  ~a ( ~a ) " pass build-time))
	     (begin
		(flush-print "build:  " fail)
		(set! *build-fail* (+ 1 *build-fail*))
		(return #f)
		))
	 ;;Rebel Alliance Run
	 (set! raven-time (time (set! retval (raven-run	basename))))	 
	 ;;diff
	 (if (= 0 retval)
	     (if (= 0 (diff basename))
		 (flush-print "run:  " pass)
		 (begin
		    (flush-print "run:  " fail)
		    (add-run-fail file)
		    (return #f)
		    ))
	     (begin
		(add-run-fail file)
		(flush-print "run:  " fail " (retval " retval ")\n")
		(return #f)
		)))
	 (when (getenv "INTERPRETER")
	    (set! raven-interpreter-time (time (raven-interpret basename)))
	    (if (= 0 (aborting-system *diff* basename ".ee.out "
				      basename ".rebel.interpreter.out > " basename ".interpreter.diff"))
		(flush-print  "interpreter: " pass)
		(begin
		   (flush-print "interpreter: " fail)
		   (add-interpreter-fail file)))
	    ; clean empty diff files
	    (when (and (file-exists? (string-append basename ".interpreter.diff"))
		       (= 0 (file-size (string-append basename ".interpreter.diff"))))
	       (delete-file (string-append basename ".interpreter.diff"))))
	 ;;benchmark
	 (unless (< cycles 2)
	    (set! zend-time (average-time cycles (lambda () (zend basename))))
	    (set! raven-time (average-time cycles (lambda () (raven-run basename))))
	    (when (getenv "INTERPRETER")
	       (set! raven-interpreter-time (average-time cycles (lambda () (raven-interpret basename))))))	      
	 
	 (set! *php-run-total* (+ *php-run-total* zend-time))
	 (set! *raven-run-total* (+ *raven-run-total* raven-time))
	 (set! *raven-interp-total* (+ *raven-interp-total* raven-interpreter-time))

	 (flush-print "zend: " zend-time " / raven    : " raven-time
		(let ((time-diff (/ (round  (* (- raven-time zend-time) 1000)) 1000.0))
		      (xtime (number->string (if (> raven-time zend-time)
						 (/ raven-time zend-time)
						 (/ zend-time raven-time))))
		      (perc (truncate (* 100 (/ raven-time zend-time)))))
		   (set! xtime (substring xtime 0 (min 5 (string-length xtime))))
		   (if (< time-diff 0)
		       (begin
			  (set! *faster-compiled* (+ *faster-compiled* 1))
			  (color green (format " [~a ~a% | ~aX faster]" time-diff perc xtime)))		       
			  (color red (format " [+~a ~a% | ~aX slower]" time-diff perc xtime))))
		(if (getenv "INTERPRETER")
		    ""
		   "\n"))
	 
	 (when (getenv "INTERPRETER")
	    (flush-print "               / interpret: " raven-interpreter-time
		(let ((time-diff (/ (round  (* (- raven-interpreter-time zend-time) 1000)) 1000.0))
		      (xtime (number->string (if (> raven-interpreter-time zend-time)
						 (/ raven-interpreter-time zend-time)
						 (/ zend-time raven-interpreter-time))))
		      (perc (truncate (* 100 (/ raven-interpreter-time zend-time) ))))
		   (set! xtime (substring xtime 0 (min 5 (string-length xtime))))
		   (if (< time-diff 0)
		       (begin
			  (set! *faster-interpreted* (+ *faster-interpreted* 1))
			  (color green (format " [~a ~a% | ~aX faster]" time-diff perc xtime)))
		       (color red (format " [+~a ~a% | ~aX slower]" time-diff perc xtime))))
		"\n"))
	 (chdir mydir)))



	 
       
(define (time-difference t1::timeval* t2::timeval*)
   "time-difference = t2 - t1"
   (+ (- (elong->flonum (timeval*-tv-sec t2))
	 (elong->flonum (timeval*-tv-sec t1)))
      (/ (- (elong->flonum (timeval*-tv-usec t2))
	    (elong->flonum (timeval*-tv-usec t1)))
	 1000000.0)))

(define (dotest argv)
   (unless (directory? (getenv "PCC_HOME"))
      (flush-fprint (current-error-port) "Before running dotest, you must first define the PCC_HOME environment to the location of your Roadsend PHP source tree")
      (exit 1))
   (unless (>= (length argv) 3)
      (flush-print "Wrong number of arguments: " argv)
      (usage)
      (exit 1))
   (let ((home (cadr argv))
	 (target (caddr argv))
	 (cycles (string->integer
		  (cond ((> (length argv) 3) (cadddr argv))
			((getenv "TEST_CYCLES"))
			(else "1")))))
      (unless (directory? home)
	 (flush-print "Test script directory is invalid: " home)
	 (exit 2))
      (unless (directory? target)
	 (flush-print "Test target directory is invalid: " target)
	 (exit 3))
      ;;so that zend can find the include files
      (aborting-system "cp " home "/*.inc " target "/")
      (let ((single-test (getenv "TEST")))
	 (if single-test
	     (begin
		(test single-test home target cycles)
		(dump-results single-test target))
	     (begin
		(for-each (lambda (t)
			     (test t home target cycles))
			  (scripts home))
		(when (> (length *run-failures*) 0)
		   (flush-print "compiler run failures:")
		   (for-each (lambda (v)
				(flush-print v))
			     *run-failures*)
                   (newline))
		(when (> (length *interpret-failures*) 0)
		   (flush-print "interpreter failures:")
		   (for-each (lambda (v)
				(flush-print v))
			     *interpret-failures*)
                   (newline)))))
      (flush-print *run* " total tests, " *build-fail* " failed to compile and "
		   *run-fail* " ran wrong. \n")
      (when (> *run* 1)
	 (flush-print (format "~a tests ran faster than zend php" *faster-compiled*))
	 (flush-print (format "AVERAGE PHP TIME: ~a" (/ *php-run-total* *run*)))
	 (flush-print (format "AVERAGE PCC TIME: ~a" (/ *raven-run-total* *run*)))
	 )
      (when (getenv "INTERPRETER")
	 (flush-print *interpret-fail* " of " *run* " failed to interpret.")
	 (when (> *run* 1)
	    (flush-print (format "AVERAGE INTERPRETER TIME: ~a" (/ *raven-interp-total* *run*)))
	    (flush-print (format "~a tests ran faster interpreted than zend php" *faster-interpreted*))))))


(define (usage)
   (flush-print "Usage: " (executable-name) " TEST_HOME TEST_TARGET [CYCLES]")
   (flush-print "     Test scripts from TEST_HOME in scratch directory TEST_TARGET.  Scripts")
   (flush-print "     are run CYCLES times, (for benchmarking).")
   (flush-print)
   (flush-print "     The CYCLES option can be passed via environment variable TEST_CYCLES.")
   (flush-print "     If OPTIMIZE environment variable is set, -O --static is passed to pcc")
   (flush-print)
   (flush-print "     If the environment variable TEST is set, it will cause only that test")
   (flush-print "     to be run."))

(define (scripts dir)
   (filter (lambda (a)
	      (pregexp-match "\\.php$" a))
	   (sort (directory->list dir) string<?)))

(define yellow 33)
(define red 31)
(define green 32)

(define (color col txt)
   "colorize txt"
   (format "\033[~a;1m~a\033[0m" col txt))
   
(define (dump-results test target)
   (when (> *build-fail* 0)
      (flush-print "Log:")
      (aborting-system "cat " target "/" (prefix test) ".log"))
   (when (> *run-fail* 0)
      (flush-print "Differences: (diff <evil empire> <rebel alliance>)")
      (aborting-system "cat " target "/" (prefix test) ".diff"))
   (when (> *interpret-fail* 0)
      (flush-print "Differences (interpreter): (diff <evil empire> <rebel alliance>)")
      (aborting-system "cat " target "/" (prefix test) ".interpreter.diff"))
   (flush-print "\n"))

(define (flush-fprint port . rest)
   (apply fprint port rest)
   (flush-output-port port))

(define (flush-print . rest)
   (apply print rest)
   (flush-output-port (current-output-port)))

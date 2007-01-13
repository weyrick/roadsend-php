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


;; XXX 10/06 - this is exploratory code and is _NOT_ part of the main build

;;;; Dynamically load PHP code
(module dynloader
   (export (dynload file))
   (import
    (driver "driver.scm")
    (ast "ast.scm")
    (tcc-binding "tcc-binding.scm"))
   (include "../runtime/php-runtime.sch")
   )




(define (dynload file)
   (let* ((program-name (symbol->string (gensym)))
	  (scheme-code
	   (fluid-let ((*generating-dynamic-code* #t)
		       (*library-mode?* #t)
		       (*compile-includes?* #f))
	      (compile program-name (list file)))))
      (with-output-to-file (string-append "/tmp/" program-name ".scm")
	 (lambda ()
	    (for-each write scheme-code)))
      (let* ((proc (run-process "bigloo" (string-append "/tmp/" program-name ".scm")
				"-cgen" "-o" (string-append "/tmp/" program-name ".c")
				"-dload-sym" ;"-mkaddlib"
				;; XXX these next ones should come from the current config
				"-O3" "-saw" ;"-unsafe"
				"-L" "/home/tim/phpoo/libs"
				"-I" "/home/tim/phpoo/runtime"
				output: pipe: input: pipe:))
	     (in-port (process-input-port proc))
	     (out-port (process-output-port proc)))
	 ;; send the scheme to bigloo
	 ;	 (for-each (lambda (o) (write  o in-port))
	 ;		   scheme-code)
	 ;	 (close-output-port in-port)
	 ;; read the C from bigloo
	 ; 	 (let ((c-code
	 ; 		(with-output-to-string
	 ; 		   (lambda ()
	 ; 		      (let loop ((line (read-line out-port)))
	 ; 			 (if (eof-object? line)
	 ; 			     (close-input-port out-port)
	 ; 			     (begin
	 ; 				(print line)
	 ; 				(loop (read-line out-port)))))))))
	 (process-wait proc)
	 (debug-trace 2 "the exit status of bigloo was: " (process-exit-status proc))
	 (let ((c-code
		(with-output-to-string
		   (lambda ()
		      (with-input-from-file (string-append "/tmp/" program-name ".c")
			 (lambda ()
			    (let loop ((line (read-line)))
			       (unless (eof-object? line)
				  (print line)
				  (loop (read-line))))))))))
	    ;; now compile the C code with tcc
	    (run-c-program c-code)
	    ))))


;; a simple scheme hello world
(define my-scheme-program
   '((module foo)
     (print "this is the toplevel code in the scheme program")
     (define (afun bar)
	(print "afun in the scheme program was called with " bar))
     (afun 22)))

;;;; a straight C program

(define my-program
   (with-output-to-string
      (lambda ()
	 (for-each print
		   (list "int fib(int n)\n"
			 "{\n"
			 "    if (n <= 2)\n"
			 "        return 1;\n"
			 "    else\n"
			 "        return fib(n-1) + fib(n-2);\n"
			 "}\n"
			 "\n"
			 "int foo(int n)\n"
			 "{\n"
			 "    printf(\"Hello World!\\n\");\n"
			 "    printf(\"fib(%d) = %d\\n\", n, fib(n));\n"
			 ;			 "    printf(\"add(%d, %d) = %d\\n\", n, 2 * n, add(n, 2 * n));\n"
			 "    return 0;\n"
			 "}\n")))))

;;the dload entry point is:
;; obj_t bigloo_dlopen_init() {

(define *dynloaded* '())
(define (run-c-program c-code)
   (let ((s (tcc_new)))
      (when (s-TCCState*-null? s)
	 (error 'main "could not create tcc state" 'foo))
      
      (tcc_set_output_type s TCC_OUTPUT_MEMORY)

      (tcc_add_include_path s "/home/tim/bigloo/2.6f/lib/bigloo/2.6f")
      
      (tcc_compile_string s c-code)
      (tcc_relocate s)
      (let ((val::ulong 0))

 	 (tcc_get_symbol s (pragma::ulong* "&$1" val) "bigloo_dlopen_init")
	 (if (zero? val)
	     (error 'run-c-program "error compiling C program" val)
	     (pragma "{void *(*func)(); func=(void*)$1; func();}" val))

	 ; 	 (tcc_get_symbol s (pragma::ulong* "&$1" val) "foo")
	 ; 	 (pragma "{int (*func)(int); func=(void*)$1; func(32);}" val)
	 
	 0)
; 	 (let ((func::void* (pragma::void* "(void *)$1" val)))
; 	    (let ((retval (pragma::int "$1(32)" func)))
; 	       (print "retval was " retval))))
;      (print "foo")
;      (tcc_delete s)
      (pushf s *dynloaded*)
      0))



;     (include "libtcc.h")
;     (type tccstate (opaque) "TCCState*")
;     (tcc-new::tccstate () "tcc_new")
;     (tcc-delete (::tccstate) "tcc_delete")
;     (tcc-enable-debug (::tccstate) "tcc_enable_debug"))))
;    (include "php-runtime.sch")
;    ;   (include "common.sch")
;    (library php-runtime)
;    (import (ast "ast.scm")
; 	   (declare "declare.scm")
; 	   (driver "driver.scm"))
;    (export
;     (dynload filename)))

; ;; compile file to scheme

; ;; compile scheme to c and return c in a string

; ;; compile c string with tcc, load it, and return a function to call it



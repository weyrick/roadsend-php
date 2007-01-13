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
(module tcc-binding
   (extern
    (include "libtcc.h")
    ;; beginning of /usr/local/include/libtcc.h
    (macro TCC_OUTPUT_MEMORY::long "TCC_OUTPUT_MEMORY")
    (macro TCC_OUTPUT_EXE::long "TCC_OUTPUT_EXE")
    (macro TCC_OUTPUT_DLL::long "TCC_OUTPUT_DLL")
    (macro TCC_OUTPUT_OBJ::long "TCC_OUTPUT_OBJ")
    (macro TCC_OUTPUT_FORMAT_ELF::long "TCC_OUTPUT_FORMAT_ELF")
    (macro TCC_OUTPUT_FORMAT_BINARY::long "TCC_OUTPUT_FORMAT_BINARY")
    (macro TCC_OUTPUT_FORMAT_COFF::long "TCC_OUTPUT_FORMAT_COFF")
    (macro tcc_new::TCCState* () "tcc_new")
    (macro tcc_delete::void (TCCState*) "tcc_delete")
    (macro tcc_enable_debug::void (TCCState*) "tcc_enable_debug")
    ;; this needs the type that's commented out below because of a problem with driver.scm or something
    (macro tcc_set_error_func::void (TCCState* void* *void*,string->void) "tcc_set_error_func")
    (macro tcc_set_warning::int (TCCState* string int) "tcc_set_warning")
    (macro tcc_add_include_path::int (TCCState* string) "tcc_add_include_path")
    (macro tcc_add_sysinclude_path::int (TCCState* string) "tcc_add_sysinclude_path")
    (macro tcc_define_symbol::void (TCCState* string string) "tcc_define_symbol")
    (macro tcc_undefine_symbol::void (TCCState* string) "tcc_undefine_symbol")
    (macro tcc_add_file::int (TCCState* string) "tcc_add_file")
    (macro tcc_compile_string::int (TCCState* string) "tcc_compile_string")
    (macro tcc_set_output_type::int (TCCState* int) "tcc_set_output_type")
    (macro tcc_add_library_path::int (TCCState* string) "tcc_add_library_path")
    (macro tcc_add_library::int (TCCState* string) "tcc_add_library")
    (macro tcc_add_symbol::int (TCCState* string ulong) "tcc_add_symbol")
    (macro tcc_output_file::int (TCCState* string) "tcc_output_file")
    (macro tcc_run::int (TCCState* int string*) "tcc_run")
    (macro tcc_relocate::int (TCCState*) "tcc_relocate")
    (macro tcc_get_symbol::int (TCCState* ulong* string) "tcc_get_symbol")
    
    (type s-TCCState (struct) "struct TCCState")
    (type TCCState s-TCCState "TCCState")
    (type void->TCCState* "TCCState *($(void))")
    (type TCCState*->void "void ($(TCCState *))")
    ;    (type void* (pointer void) "void *")
    (type void*,string->void "void ($(void *,char *))")
    ;; this type conflicts with driver.scm in some way
    (type *void*,string->void (function void (void* string)) "void ((*$)(void *,char *))")
    (type TCCState*,void*,*void*,string->void->void "void ($(TCCState *,void *,void ((*)(void *,char *))))")
    (type TCCState*,string,int->int "int ($(TCCState *,char *,int))")
    (type TCCState*,string->int "int ($(TCCState *,char *))")
    (type TCCState*,string,string->void "void ($(TCCState *,char *,char *))")
    (type TCCState*,string->void "void ($(TCCState *,char *))")
    (type TCCState*,int->int "int ($(TCCState *,int))")
    (type TCCState*,string,ulong->int "int ($(TCCState *,char *,unsigned long))")
;    (type string* (pointer string) "char **")
    (type TCCState*,int,string*->int "int ($(TCCState *,int,char **))")
    (type TCCState*->int "int ($(TCCState *))")
    (type ulong* (pointer ulong) "unsigned long *")
    (type TCCState*,ulong*,string->int "int ($(TCCState *,unsigned long *,char *))")
    ;; end of /usr/local/include/libtcc.h
    ))





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

; ;;the dload entry point is:
; ;; obj_t bigloo_dlopen_init() {

; (define (run-c-program c-code)
;    (let ((s (tcc_new)))
;       (when (s-TCCState*-null? s)
; 	 (error 'main "could not create tcc state" 'foo))
      
;       (tcc_set_output_type s TCC_OUTPUT_MEMORY)

;       (tcc_add_include_path s "/home/tim/bigloo/2.6f/lib/bigloo/2.6f")
      
;       (tcc_compile_string s c-code)
;       (tcc_relocate s)
;       (let ((val::ulong 0))

;  	 (tcc_get_symbol s (pragma::ulong* "&$1" val) "bigloo_dlopen_init")
; 	 (if (zero? val)
; 	     (error 'run-c-program "error compiling C program" val)
; 	     (pragma "{void *(*func)(); func=(void*)$1; func();}" val))

; 	 ; 	 (tcc_get_symbol s (pragma::ulong* "&$1" val) "foo")
; 	 ; 	 (pragma "{int (*func)(int); func=(void*)$1; func(32);}" val)
	 
; 	 0)
; ; 	 (let ((func::void* (pragma::void* "(void *)$1" val)))
; ; 	    (let ((retval (pragma::int "$1(32)" func)))
; ; 	       (print "retval was " retval))))
;       (print "foo")
;       (tcc_delete s)
;       0))



; ;     (include "libtcc.h")
; ;     (type tccstate (opaque) "TCCState*")
; ;     (tcc-new::tccstate () "tcc_new")
; ;     (tcc-delete (::tccstate) "tcc_delete")
; ;     (tcc-enable-debug (::tccstate) "tcc_enable_debug"))))
; ;    (include "php-runtime.sch")
; ;    ;   (include "common.sch")
; ;    (library php-runtime)
; ;    (import (ast "ast.scm")
; ; 	   (declare "declare.scm")
; ; 	   (driver "driver.scm"))
; ;    (export
; ;     (dynload filename)))

; ; ;; compile file to scheme

; ; ;; compile scheme to c and return c in a string

; ; ;; compile c string with tcc, load it, and return a function to call it



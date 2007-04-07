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

;Make all the parts of the compiler work together
(module driver
   (library php-runtime)
   (library profiler webconnect)
   (include "../runtime/php-runtime.sch")
   
   (load (php-macros "../php-macros.scm"))
   (import
    (lexers "lexers.scm")
    (parser "parser.scm")
    (ast "ast.scm")
    (evaluate "evaluate.scm")
    (debugger "debugger.scm")
    (basic-blocks "basic-blocks.scm")
    (containers "containers.scm")
    (generate "generate.scm")
    (declare "declare.scm")
    (php-cfa "cfa.scm")
    (include "include.scm")
    (config "config.scm")
    (target "target.scm")
    )

   (export
    (load-runtime-libs libs)
    load-web-libs
    (php-eval code)
    (init-eval-lib)
    (dump-tokens input-file)
    (dump-ast input-file)
    (dump-containers input-file)
    (dump-types input-file)
    (dump-flow input-file)
    (dump-preprocessed input-file)
    (interpret input-file)
    (debug input-file)
    (library-httpd-stub libname)
    (fastcgi-stub filename)
    (setup-web-target)
    (compile program-name input-file #!optional library?)
    (run-url::string filename::string webapp-lib index-file)
    (input-file->ast input-file strip-shebang?)
    (evaluate-from-file file name-to-use)))

(init-php-runtime)
(init-webconnect-lib)

(define (init-eval-lib)
   1)

(register-extension "compiler" "1.0.0"
                    "phpeval" '()
                    required-extensions: '("webconnect"))

(define-macro (bigloo-version)
   `',*bigloo-version*)

(define %%memo-count 0)
(define %%memo-reset-count 0)
(define %%memo-miss-count 0)
(signal 2 (lambda (arg)
             (if *RAVEN-DEVEL-BUILD*
                 (begin
                    (debug-trace 0 "worked: " %%memo-count " times")
                    (debug-trace 0 "reset: " %%memo-reset-count " times")
                    (debug-trace 0 "missed: " %%memo-miss-count " times")
                    (php-error "*interrupted*"))
                 (begin
                  (fprint (current-error-port) "*interrupted*")
                  (exit 1)))))


; load runtime libraries
(define *libraries-loaded* (make-hashtable)) ; prevent dupes based on name, without _s or _u 

(define (load-runtime-libs libs)
   (letrec ((get-lib-name (lambda (l)
			     (let ((lname (if (string? l)
                                              (pregexp-match "lib(\\w+)_[us]([0-9]\\.[0-9][a-z])?\\.so" l)
                                              l)))
				(if (pair? lname)
				    (cdr lname)
				    l))))
	    (lib-error (lambda (e p m o)
			   (php-error (format "Extension ~a didn't load because: ~a, ~a, ~a~%You may wish to remove this extension from ~a if it exists."
				   (get-lib-name o) m p o *config-file*)))))
      (for-each (lambda (v)
		   (let* ((libname v)
			  (libfile (mkstr "lib" libname (safety-ext) "-"
                                          (bigloo-version) (make-shared-library-name ""))))
		      ;(debug-trace 1 "get: " (hashtable-get *libraries-loaded* libname))
		      (unless (hashtable-get *libraries-loaded* (mkstr libname)) ; don't load twice
			 (debug-trace 2 (format "loading compiled library ~a [~a]" libfile libname))
			 (pushf libfile *user-libs*)
			 ;(debug-trace 1 "reget: " (hashtable-get *libraries-loaded* libname))
			 ;; if debug-level is higher than 1, don't prettify library-loading errors,
			 ;; since they're often in top level code in the library.
			 (if (< *debug-level* 2)
			     (try (begin
                                     (dynamic-load libfile)
                                     (hashtable-put! *libraries-loaded* (mkstr libname) #t))
                                  lib-error)
			     (begin
                                (dynamic-load libfile)
                                (hashtable-put! *libraries-loaded* (mkstr libname) #t))))))
		libs) ))


; pcc.conf libs
(define load-web-libs
   (let ((web-libs-loaded? #f))
      (lambda ()
         (when (not web-libs-loaded?)
            (debug-trace 1 (format "loading 'web-libs' libraries from pcc.conf: ~a"
                                   (reverse *web-libs*)))
            ;the reverse is because we use pushf to build up the list,
            ;but the libs should be loaded in the order that they are listed in the file
            (load-runtime-libs (reverse *web-libs*))
            (set! web-libs-loaded? #t)))))

;; web backends will use this target
(define (setup-web-target)
   (set! *current-target* (instantiate::interpret-target)))

;;;main entry point when running from the web (including mhttpd) 
(define (run-url::string filename::string webapp-lib index-file)
   (do-include-paths)
   (debug-trace 1 "Running file: " filename
		", webapp-lib: " (if webapp-lib webapp-lib "(none)")
		", index-file: " (if index-file index-file "(none)" ))
   (unless *static-webapp?*
      (load-web-libs)
      )
   (run-startup-functions)
   (if webapp-lib
       ; app
       (with-output-to-string
	  (lambda ()
	     (let ((lib-inc-name
		    (or (find-include-file-in-lib filename *PHP-FILE*)
			(and index-file
			     (find-include-file-in-lib (append-paths filename (string (pcc-file-separator)) index-file) *PHP-FILE*)))))
		(debug-trace 1 "lib-inc-name is " lib-inc-name)
		(if lib-inc-name
 		    (try
		     (php-funcall lib-inc-name 'unset)
		     handle-runtime-error)
		    (begin
		       (debug-trace 1 "Unable to find webapp file: " filename ", signalling 404")
		       (error 'run-url "File not found" 'file-not-found))))
             ;; The shutdown-funcs should still be able to output stuff.
             ;; The 0 is just a nonsense exit-stat -- required because
             ;; run-php-shutdown-funcs is also a bigloo exit-function.
             (run-php-shutdown-funcs 0)
	     ;; flush all output
	     (ob-flush-all)
	     ; reset state for next view	
	     (reset-runtime-state)))
       ; interpret
       (begin
	  (unless (file-exists? filename)
	     (debug-trace 1 "Unable to find web file to interpret: " filename ", signalling 404")
	     (error 'run-url "File not found" 'file-not-found))
	  (chdir (dirname filename))
          (target-source-files-set! *current-target* (list filename))
	  (with-output-to-string
	     (lambda ()
		(try ;(interpret filename)
                 (build-target *current-target*)
		 handle-runtime-error)
                (run-php-shutdown-funcs 0)
		; flush all output
		(ob-flush-all)
		; reset state for next view	
		(reset-runtime-state))))))

;;;main entry point for php -i
(define (interpret input-file)
   ; read config and user libs handled in either run-url for web or commandline for comand line
   (do-include-paths)
   (let ((ast-nodes (input-file->ast input-file #t))) ; this will bail out to proper parse error handler 
      (if (and *RAVEN-DEVEL-BUILD*
	       (getenv "BIGLOOSTACKDEPTH"))
	  ; if devel mode allow stack trace
	  (evaluate ast-nodes)
	  (try
	   (evaluate ast-nodes)
	   handle-runtime-error))))

;; like interpret, but for when we're debugging
;(define *debugging* #f)
(define (debug input-file)
   ; read config and user libs handled in either run-url for web or commandline for comand line
   (do-include-paths)
   (if (and *RAVEN-DEVEL-BUILD*
	    (getenv "BIGLOOSTACKDEPTH"))
       ; if devel mode allow stack trace
       (debugger-start input-file)
       (try
	(debugger-start input-file)
	handle-runtime-error)))

;;;main entry point in compiled code
(define (program-prologue filename main?)
    (debug-trace 3 "compiler: generating program prologue, file: " filename ", main: " main?)

   `((module ,(main-name filename)
	,@(if main? `((main main)) '())
	,@(scheme-libraries-and-includes)
	)
     
     ,@(if main?
	   `((define (main argv)
;		(set! *debug-level* ,*debug-level*)
		,@(if *source-level-profile*
		      '((begin (set! *source-level-profile* #t)
			 (register-exit-function! (lambda (s) (finish-profiling) s))))
		      '())
		(check-runtime-library-version ,%runtime-library-version)
                (set! PHP5? ,PHP5?)
                
					; check for auto session start
                (init-php-runtime)
                ,(generate-config-ini-entries)
		
; XXX cgi deprecated in favor or fastcgi in dual mode		
; 		,@(if (target-option cgi?:)
; 		      `((cgi-init)
; 			(cgi-print-headers))
; 		      '())

		(run-startup-functions)

		(init-php-argv argv)
		,(if *RAVEN-DEVEL-BUILD*
					;this provides a way to get at the scheme file line number, at least.
					;unfortunately, bigloo behaves really crappily if you set BIGLOOSTACKDEPTH
					;so we use a different env var to avoid that necessity
		     `(if (getenv "BIGLOOSTACK")
		       (,(main-name filename) argv)
		       (try (,(main-name filename) argv)
                            handle-runtime-error))
		     `(try (,(main-name filename) argv)
		       handle-runtime-error))
		#t))
	   '())))


(define (library-httpd-stub filename)
   `((module ,(string->symbol (string-append filename "-stub"))
	(main main)
 	(library mhttpd)
	; if static, we need to init the library files
	,@(if (target-option static?:)
	      `((library ,(string->symbol filename))
		(include ,(mkext filename ".sch")))
	      '())
        ,@(scheme-libraries-and-includes)

	)

     ; handle ctrl-c to quit
     (signal 2 (lambda (arg)
		  (stop-micro-server)
		  (when (> *debug-level* 0)
		     (fprint (current-error-port) "[] server shutdown"))
		  (exit 1)))

     (define (main argv)
;	(set! *debug-level* ,*debug-level*)

        ; possibly override port 
        ,@(if (target-option micro-web-port:)
	      `((set! *micro-web-port* ,@(target-option micro-web-port:)))
	      '())

	; possibly override index/404 pages
	,@(if (target-option webapp-index-page:)
	      `((set! *webapp-index-page* ,@(target-option webapp-index-page:)))
	      '())
        
        ,@(if (target-option webapp-404-page:)
              `((set! *webapp-404-page* ,@(target-option webapp-404-page:)))
              '())
	
	(set! *micro-web-lib* ,filename)

	; if we will link statically, we compile in the extension libraries
	; so we don't want to load them at runtime. this will prevent that
	,@(if (target-option static?:)
	      `((set! *static-webapp?* #t))
	      '())
	
	; process some command line args
	(args-parse (cdr argv)
	   ((("-h" "--help") (help "This help message"))
	    (args-parse-usage #f)
	    (exit 0))
	   ((("-d") ?level (help "Debug level"))
	    (set! *debug-level* (string->integer level)))
	   ((("-l") ?log (help "Log all requests to the specfied file"))
	    (set! *micro-web-log* log))	   	   
	   ((("-p") ?port (help "Server port number"))
	    (set! *micro-web-port* (string->integer port)))
	   (else
	    (cond
	       ((char=? (string-ref else 0) #\-)
		(print "Illegal argument `" else "'. ")
		(args-parse-usage #f)
		(exit 1)))))

	(check-runtime-library-version ,%runtime-library-version)
        (set! PHP5? ,PHP5?)
	(setup-library-paths)
        (init-php-runtime)
	,(generate-config-ini-entries)
        (unless *static-webapp?*
           (load-runtime-libs (list *micro-web-lib*)))
	(run-startup-functions)
	(init-php-argv argv)
	
	(try (run-micro-server)
	     handle-runtime-error))))

(define (fastcgi-stub filename)
   `((module ,(string->symbol (string-append filename "-stub"))
	(main main)
	,@(if (target-option static?:)
	      `((library ,(string->symbol filename))
		(include ,(mkext filename ".sch")))
	      '())
        ,@(scheme-libraries-and-includes))
     
     (define (main argv)
        ;	(set! *debug-level* ,*debug-level*)
        (set! *fastcgi-webapp* ,filename)

	,@(if (target-option webapp-index-page:)
	      `((set! *webapp-index-page* ,@(target-option webapp-index-page:)))
	      '())
        
        ,@(if (target-option webapp-404-page:)
              `((set! *webapp-404-page* ,@(target-option webapp-404-page:)))
              '())

	; if we will link statically, we compile in the extension libraries
	; so we don't want to load them at runtime. this will prevent that
	,@(if (target-option static?:)
	      `((set! *static-webapp?* #t))
	      '())
        
        (check-runtime-library-version ,%runtime-library-version)
        (set! PHP5? ,PHP5?)
	(setup-library-paths)
        (init-php-runtime)
	(run-startup-functions)
	(init-php-argv argv)
	
        (fastcgi-main argv))))

(define (dump-ast input-file)
   (print-pretty-ast (input-file->ast input-file #t)))

(define (dump-containers input-file)
   (let ((ast (input-file->ast input-file #t)))
      (walk-ast/parent ast declare)
      (walk-ast ast find-containers)
      (print-pretty-ast ast)))

(define (dump-types input-file)
   (let ((ast (input-file->ast input-file #t)))
      (walk-ast/parent ast declare)
      (walk-ast ast find-containers)
;      (walk-ast ast infer-types-you-brute)
      (cfa-annotate (identify-basic-blocks ast))
      (print-pretty-ast ast)))

(define (dump-flow input-file)
   (dump-php-flow (input-file->ast input-file #t)))

 
(define (produce-failed-compile-error input-file included-from)
   (delayed-error
    (format "Unable to compile input file ~A~A. ~%See previous errors for more information."
	    (normalize-path input-file)
	    (with-output-to-string
	       (lambda ()
		  (let loop ((a included-from))
		     (when (pair? a)
			(display ", included from ")
			(display (normalize-path (car a)))
			(loop (cdr a)))))))))


; (define (dump-copies input-files)
;    (let ((asts (map (lambda (a)
; 		       (input-file->ast a #t))
; 		    input-files)))
;       (for-each (lambda (a)
; 		   (walk-ast/parent a declare))
; 		asts)
;       (for-each (lambda (a)
; 		   (walk-ast a find-containers))
; 		asts)
;       (for-each (lambda (a)
; 		   (cfa-annotate (identify-basic-blocks a)))
; 		asts)
;       (for-each (lambda (a)
; 		   (show-copies a))
; 		asts)))


(define (compile program-name input-files #!optional library?)
   (fluid-let ((*library-mode?* library?))
      ;    (let ((not-founds (filter (lambda (f) (not (file-exists? f))) input-files)))
      ;       (unless (null? not-founds)
      ; 	 (fprint (current-error-port) (format "file(s) not found: ~a" not-founds))
      ; 	 (exit 1)))
      (let ((strip-first #t)
            (asts '()))
         (letrec ((input-file->asts
                   (lambda (input-file included-from)
                      (let ((ast (input-file->ast input-file strip-first)))
                         (if (not (php-ast? ast))
                             (produce-failed-compile-error input-file included-from)
                             (begin
                                (when strip-first
                                   (set! strip-first #f))
                                (pushf ast asts)
                                (php-ast-program-name-set! ast program-name)
                                (php-ast-original-filename-set! ast input-file)
                                (php-ast-real-filename-set! ast
                                                            ;							 (if *library-mode?*
                                                            ;;libraries can be moved around, so don't
                                                            ;;encode the original path in them
                                                            ;							     (path-relative-to-include-path input-file)
                                                            (util-realpath input-file)) ;)
                                (php-ast-project-relative-filename-set!
                                 ast ;(path-relative-to-include-path input-file)
                                 (path-relative-to-project-path input-file))
                                
                                (when (target-option compile-includes?:)
                                   (let ((include-files (find-include-files ast)))
                                      (debug-trace 3 "file " input-file " includes " include-files)
                                      (for-each (lambda (a)
                                                   (input-file->asts a  (cons input-file included-from)))
                                                ;(lambda (a)
                                                ; 					 (unless (hashtable-get *all-files-ever-included* (include-name a))
                                                ; 					    (hashtable-put! *all-files-ever-included* (include-name a) #t)
                                                ; 					    (input-file->asts a)))
                                                include-files)))))))))
            (for-each (lambda (a)
                         (unless (hashtable-get *all-files-ever-included* (include-name a))
                            (hashtable-put! *all-files-ever-included* (include-name a) #t)
                            (input-file->asts a '())))
                      input-files)
            (debug-trace 3 "compiler: finished reading input files")
            
            (debug-trace 3 "compiler: starting declare phase")
            (for-each (lambda (a)
                         (walk-ast/parent a declare))
                      asts)
            (debug-trace 3 "compiler: finished declare phase")
            
            (debug-trace 3 "compiler: starting container analysis")
            (for-each (lambda (a)
                         (walk-ast a find-containers))
                      asts)
            
            (debug-trace 4 "the input-files to compile are " input-files)
            ;cfa-annotate needs to actually pay attention to containers... maybe
            (for-each (lambda (a)
                         (debug-trace 4 "invoking cfa-annotate on the AST for " (php-ast-real-filename a))
                         (cfa-annotate (identify-basic-blocks a)))
                      asts)
            (debug-trace 3 "compiler: finished cfa and basic-blocks")
            
            (if *library-mode?*
                (let ((i 1))
                   ; lib
                   (for-each (lambda (a)
                                (debug-trace 3  (format "compiler: outputting ~a (~a of ~a)"
                                                        (php-ast-real-filename a)
                                                        i
                                                        (length asts)))
				(set! i (+ i 1))
				(write-one-generated-module a))
                             asts)
                   (write-library-include-file program-name asts)
                   (library-prologue program-name asts))
                ; non lib compile
                (for-each (lambda (code)
                             (debug-trace 3 "compiler: outputting generated code")
                             (maybe-pp code)
                             (newline))
                          (apply append (program-prologue ;(path-relative-to-include-path (car input-files))
                                         (path-relative-to-project-path (car input-files))
                                         #t; (if (> (length input-files) 1) #f #t)
                                         )
                                 (map (lambda (ast)
                                         (debug-trace 3 "compiler: generating code for  module")
                                         (with-access::php-ast ast (project-relative-filename)
                                            
                                            (let ((code (generate-code ast)))
                                               (append
                                                (list `(begin ,(main-sig (include-name project-relative-filename))
                                                              (define ,(include-name project-relative-filename)
                                                                 ,(car code))))
                                                (cdr code)))))
                                      
                                      asts))))
            (when (handle-delayed-errors)
               (exit 1))))))

(define (file->init-fun-name ast::php-ast)
   (string->symbol (mkstr (php-ast-project-relative-filename ast)
			  "-init")))

(define (write-one-generated-module ast::php-ast)
   (let ((init-fun-name (file->init-fun-name ast))
	 (outfile (mkstr (prefix (php-ast-real-filename ast)) ".scm"))
         (mangled-name (include-name (php-ast-project-relative-filename ast))))
      (with-output-to-file outfile
	 (lambda ()
	    (multiple-value-bind (code include-asts exports)
	       (generate-code ast)
	       
	       (maybe-pp
		`(module ,(string->symbol (php-ast-project-relative-filename ast))
                    ,@(scheme-libraries-and-includes)
		    (eval (export-exports))
		    (export (,init-fun-name))
		    ,@(if (null? exports) '() `((export ,@exports)))
		    ,@(map (lambda (a)
			      `(import (,(string->symbol (php-ast-project-relative-filename a))
					,(mkstr (prefix (php-ast-real-filename a)) ".scm"))))
			   (delete-duplicates (delete ast include-asts)))))
	       (print `(define (,init-fun-name) 1))
	       
	       (maybe-pp `(define ,mangled-name
			     (check-runtime-library-version ,%runtime-library-version)
                             (set! PHP5? ,PHP5?)
			     ;;this is the actual main function, including stuff like storing
			     ;;the function signatures for the file, and the global code in the
			     ;;file.
			     ,(car code)))
	       (maybe-pp `(store-library-include
			   ,(php-ast-program-name ast)
			   ,mangled-name
			   ,ft-main #f
			   ',mangled-name
			   1 1 0 '$obj 0))
               ;; in case a library strip path would change the name
               ;; of the file, add another library include under that
               ;; name.
               (let ((stripped-mangled-name (include-name
                                             (strip-library-strip-path
                                              (php-ast-project-relative-filename ast)))))
                  (unless (eqv? stripped-mangled-name mangled-name)
                     (maybe-pp `(store-library-include
                                 ,(php-ast-program-name ast)
                                 ,mangled-name
                                 ,ft-main #f
                                 ',stripped-mangled-name
                                 1 1 0 '$obj 0))))
	       (for-each maybe-pp (cdr code)))))))

(define (write-library-include-file libname asts)
   (with-output-to-file (mkext libname ".sch")
      (lambda ()
	 (for-each (lambda (f)
		      (print "(" (file->init-fun-name f) ")"))
		   asts))))

(define (library-prologue libname::bstring asts)
   (maybe-pp
    `(module ,(symbol-append '__make- (string->symbol libname) '-lib)
	,@(map (lambda (ast)
		  `(import (,(string->symbol (php-ast-project-relative-filename ast))
			    ,(mkstr (prefix (php-ast-real-filename ast)) ".scm"))))
	       asts)
	)))


(defalias eval php-eval)
(defbuiltin (php-eval code)
   (evaluate
    (with-input-from-string (string-append "<?php " (mkstr code) " ?>")
       (lambda ()
          (%memoized-parse (read-string) 'php-lambda "Eval String")
          ))))


(define (evaluate-from-file file name-to-use)
   (debug-trace 1 "evaluating from: " file)
   (if (= (file-size file) 0)
       (debug-trace 2 "file was empty, ignoring")
       (evaluate ;(if *debugging* recursive-debugger-start evaluate)
	(with-input-from-file file
	   (lambda ()
              (%memoized-parse (read-string) name-to-use file)
              )))))

;parse takes a string instead of a file, so you can use it for eval
(define (parse input-string main-name input-file)
   (php-reset)
   (lineno-munch-file input-file)
   (let ((ast (with-input-from-string input-string
		 (lambda ()
		    (read/lalrp *php-syntax* (php-surface)
				(current-input-port))))))
      (lineno-unmunch-file)
      ast))


(define (dump-tokens input-file)
   (php-reset)
   (lineno-munch-file input-file)
   (pp
    (with-input-from-file input-file
       (lambda ()
	  (with-input-from-string (php-preprocess (current-input-port) "toks")
	     (lambda ()
		(get-tokens (php-surface) (current-input-port))))))))

(define (dump-preprocessed input-file)
   (php-reset)
   (lineno-munch-file input-file)
   (print
    (with-input-from-file input-file
       (lambda ()
	  (php-preprocess (current-input-port) "toks" #t)))))


(define (input-file->ast input-file strip-shebang?)
   (debug-trace 4 "input-file->ast " input-file)
   (with-input-from-file input-file
      (lambda ()
	 ; strip shebang
	 (let ((shebang (read-line (current-input-port))))
	    (when (or (not strip-shebang?)
		      (not (and (string? shebang)
				(substring=? shebang "#!" 2))))
	       (set-input-port-position! (current-input-port) 0))
	    (let ((ast (%memoized-parse (read-string) (main-name input-file) input-file)
                   ))
               (when (php-ast? ast)
                  (php-ast-original-filename-set! ast input-file))
	       ast)))))

;; some resource limits... maybe have to tune them
(define %%largest-file-to-memoize 128000)
(define %%max-memoized-files 128)
;; the table to store memoized parses in
(define %%memoized-parses #f)

(define (%memoized-parse input-string main-name filename)
   ;; save the result of parsing a file so that we can skip parsing it next time
   (let ((do-parse (lambda ()
                      ;(debug-trace 0 "Parsing " filename " for the first time")
                      (set! %%memo-miss-count (+ %%memo-miss-count 1))
                      (with-input-from-string input-string
                         (lambda ()
                            (try (parse (php-preprocess (current-input-port) filename)
                                        main-name filename)
                                 handle-token-error))))))
      ;; I think that memoization will only help when running as a web
      ;; server, because it only speeds up the 2nd and subsequent
      ;; include of a file. --timjr 2005.5.6
      (if *commandline?*
          (begin
             ;(debug-trace 0 "because it's commandline")
             (do-parse))
          (begin
             ;; initialize the table lazily
             (unless %%memoized-parses (set! %%memoized-parses (make-hashtable)))
             ;; check there are not too many memoized files
             (when (> (hashtable-size %%memoized-parses) %%max-memoized-files)
                ;; simple-mindedly completely clear the table
                (set! %%memo-reset-count (+ %%memo-reset-count 1))
                (set! %%memoized-parses (make-hashtable)))
             ;; check that the file is not too big
             (if (> (string-length input-string) %%largest-file-to-memoize)
                 ;; file is too big: simply parse, don't memoize
                 (begin
                    ;(debug-trace 0 "because it's too big")
                    (do-parse))
                 ;; memoize the result of parsing by calculating an md5 hash
                 ;; of the file and using it as a hashtable key
		 (let ((key (md5sum-string input-string)))
		   (aif (hashtable-get %%memoized-parses key)
                       (begin
                          ;(debug-trace 4 "Using memoized parse of " filename)
                          (set! %%memo-count (+ %%memo-count 1))
                          it)
                       (let ((ast (begin
                                     ;(debug-trace 0 "becauset the other case")
                                     (do-parse))))
                          (hashtable-put! %%memoized-parses key ast)
                          ast))))))))


(define (main-name filename)
   (include-name filename))

(define (php-reset)
   (lexer-reset!))

(define (maybe-pp lst)
   (if (or (target-option pretty?:)
	   (> *debug-level* 1))
       (pp lst)
       (write lst)))

(define (main-sig main-name)
   (store-signature-1 #f ft-main #f main-name 1 1 0 '$obj 0)
   `(store-signature-1 ,main-name ,ft-main #f ',main-name 1 1 0 '$obj 0))


(define (path-relative-to-project-path::bstring filename::bstring)
   (let* ((project-path (util-realpath (pwd)))
          (file-path (util-realpath filename)))
      (if (substring-at? file-path project-path 0)
          (substring file-path
                     ;; +1 so we chop off the separator too
                     (+ 1 (string-length project-path))
                     (string-length file-path))
          (error 'path-relative-to-project-path
                 "file is not within project path"
                 (cons project-path file-path)))))


;;Check that the userinfo is correct, used to prevent beta and demo
;;users from distributing their compiled stuff.
;(define (check-distributable userinfo library? binary-name)
;   (check-license-userinfo PCC-HOME userinfo library? binary-name))


(define (strip-library-strip-path filename::bstring)
   "if any of *LIBRARY-COMPILE-STRIP-PATHS* is a prefix of FILENAME, strip it"
   (let loop ((paths (target-option strip-paths:)))
      (if (pair? paths)
          (let* ((path (car paths))
                 (prefix-len (string-length path)))
	     ;; if the path is a prefix of the filename
	     (if (substring=? path filename prefix-len)
		 ;; strip the prefix and return the rest of the filename
		 (substring filename prefix-len (string-length filename))
		 ;; otherwise, try another
		 (loop (cdr paths))))
          ;; no path was a prefix of filename so return the whole thing
          filename)))

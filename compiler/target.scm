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

;;;; Here we define the various targets of the compiler. In other words,
;;;; these are the top-level recipes for things like standalone
;;;; binaries, libraries, webapps, etc.  Other things like "interpret
;;;; this file", "dump CFA information", etc., which don't necessarily
;;;; produce an output file, but do involve the compiler, are also
;;;; defined here.
(module target
   (library php-runtime)
   (include "php-runtime.sch")
   (import (driver "driver.scm")
           (config "config.scm"))
   (extern
    ;; this gets us windows.h, essentially. 
    (include "debugger.h"))
   (export
    *current-target*
    *verbosity*
    (verbose-trace level . rest)
    (add-target-option! key value)
    (set-target-option! key value)
    (target-option key)
    (generic build-target target)
    (mkext file ext)
    (mksext file ext)
    (scheme-libraries-and-includes)
    (require-extension extension)
    ;; roughly, if it's required for the target to be built, then it
    ;; should be a separate slot, otherwise it should be in the
    ;; target-options.
    (final-class target
       (output-path (default #f))
       (source-files (default '()))
       (libraries (default '()))
       (options (default '())))
    (wide-class dump-target::target
       dump-type)
    (wide-class php-repl-target::target)
    (wide-class scheme-repl-target::target)    
    (wide-class cleanup-target::target)
    (wide-class debug-target::target)
    (wide-class interpret-target::target)
    (wide-class autocompile-target::target)
    (wide-class standalone-target::target)
    (wide-class library-target::target
       name)
    (wide-class webapp-target::target
       name)))

(define-macro (with-temp-file (name path) . body)
   `(invoke-with-temp-file ,path (lambda (,name) ,@body)))

(define *current-target* #f)
(define *verbosity* 0)

; similiar to debug-trace but only used by the frontend
; during compilation, not by runtime code
; also it goes to STDOUT, not STDERR like debug-trace
(define (verbose-trace level . rest)
   "print REST when *VERBOSITY* is >= LEVEL"
   (when (>= *verbosity* level)
      (for-each
       (lambda (a)
	  (cond
	     ((php-object? (maybe-unbox a))
	      (fprint (current-output-port)
		      (with-output-to-string
			 (lambda ()
			    (when (container? a) (display "("))
			    (pretty-print-php-object (maybe-unbox a))
			    (when (container? a)
			       (display " . ")
			       (display (cdr a))
			       (display ")"))))))
	     (else (display-circle a (current-output-port)))))
       rest)
      (newline (current-output-port))
      (flush-output-port (current-output-port)))
   #f)

;;; build-target is the recipe for cooking a target.  To add a new
;;; target type, you should at least add a new wide-class that
;;; extends the class "target", and a new method for build-target.
;;; You probably also want to add another commandline option, or
;;; other entry point, which widens *current-target* into a target of
;;; the new type.
(define-generic (build-target target)
   (bomb "Unhandled target of type: " (class-name (object-class target)))) 

(define-method (build-target target::php-repl-target)
   (with-access::php-repl-target target (options)
      (fluid-let ((*dynamic-load-path* (append (or (target-option library-paths:) '())
                                               *dynamic-load-path*)))
		 (setup-library-paths)
		 (load-runtime-libs (or (target-option default-libs:) '()))
		 (load-runtime-libs (or (target-option commandline-libs:) '()))
		 (init-php-argv (if (target-option script-argv:)
				    (reverse (target-option script-argv:))
				    '()))
		 (run-startup-functions)
		 (print "Interactive shell")
		 (let loop ()
		    (display* "pcc > ")
		    (let ((input (read-line)))
		       (unless (or (eof-object? input)
				   (string=? input "quit")
				   (string=? input "exit"))
			  (try 
			   (php-eval input)
			   (lambda (e p m o)
			      (print m)
			      (e #f)))
			  (loop))))
		 (print))))

(define-method (build-target target::scheme-repl-target)
   (with-access::scheme-repl-target target (options)
      (fluid-let ((*dynamic-load-path* (append (or (target-option library-paths:) '())
                                               *dynamic-load-path*)))
		 (setup-library-paths)
		 (load-runtime-libs (or (target-option default-libs:) '()))
		 (load-runtime-libs (or (target-option commandline-libs:) '()))
		 (init-php-argv (if (target-option script-argv:)
				    (reverse (target-option script-argv:))
				    '()))
		 (run-startup-functions)
		 (print *RAVEN-VERSION-TAG*)	 
		 (print "You are now in a scheme REPL. Ctrl-D or (quit) to exit.")
		 (repl))))

(define-method (build-target target::interpret-target)
   (with-access::interpret-target target (source-files)
      (fluid-let ((*dynamic-load-path* (append (or (target-option library-paths:) '())
                                               *dynamic-load-path*)))
         (setup-library-paths)
         (load-runtime-libs (or (target-option default-libs:) '()))
         (load-runtime-libs (or (target-option commandline-libs:) '()))
         (init-php-argv (if (target-option script-argv:)
                            (reverse (target-option script-argv:))
                            '()))
         (run-startup-functions)
         (set! source-files (reverse (validate-files source-files)))
         (when (null? source-files)
            (bomb "No files to interpret"))
         (interpret (car source-files)))))

(define-method (build-target target::debug-target)
   (with-access::debug-target target (source-files)
      (fluid-let ((*dynamic-load-path* (append (or (target-option library-paths:) '())
                                               *dynamic-load-path*)))
         (setup-library-paths)
         (load-runtime-libs (or (target-option default-libs:) '()))
         (load-runtime-libs (or (target-option commandline-libs:) '()))
         (run-startup-functions)
         (set! source-files (reverse (validate-files source-files)))
         (when (null? source-files)
            (bomb "No files to debug"))
	 (debug (car (target-source-files target))))))

(define-method (build-target target::standalone-target)
   (fluid-let ((*dynamic-load-path* (append (or (target-option library-paths:) '())
                                            *dynamic-load-path*)))
      (set! *compile-mode?* #t) ; for error output (see php-errors)
      (setup-library-paths)
      ;; first, check our inputs, default some things
      (with-access::standalone-target target
            (output-path source-files libraries options)
         ;; we reverse the source files so that the first file on the
         ;; commandline will be the first source file.
         (set! source-files (reverse (validate-files source-files)))
         (when (null? source-files)
            (bomb "No files to compile."))
         (unless output-path
            (set! output-path (prefix (car source-files))))
	 (verbose-trace 1 *RAVEN-VERSION-TAG*)
         (verbose-trace 1 "Compiling standalone target:\n  output-path: " output-path
			"\n  source-files: " source-files "\n  libraries: " libraries "\n")
	 (debug-trace 2 "options: " options)
         ;; if we are using a windows resource file, compile it first
         (awhen (target-option resource-file:)
                (verbose-trace 1 "using windows resource file: " it)
                (compile-res-file it))
         ;; We load all of the libraries that the user has enabled, so
         ;; that function, constant, and class definitions will be found
         ;; by the compiler.
         (load-runtime-libs (or (target-option default-libs:) '()))
         (load-runtime-libs (or (target-option commandline-libs:) '()))
         (run-startup-functions)         
         ;; This is the compilation step itself.  The compiler simply
         ;; prints the Scheme code that it generates.  We capture that
         ;; output and stick it in a .scm file.         
;         (print "output path 1 " output-path)
         (let* ((output-dir (util-realpath (dirname output-path)))
                (scheme-file (append-paths output-dir (mkext (basename output-path) ".scm")))
                (o-file (append-paths output-dir (mkext (basename output-path) ".o"))))
;            (print "output path 2 " scheme-file)
;            (exit 1)
            ;; We CD into the project dir because the compiler wants to
            ;; use its current working directory to convert all paths to
            ;; relative paths.  We use relative paths because, while
            ;; my-lib/foo.php might make sense on a user's system,
            ;; /home/tim/my-lib/foo.php probably doesn't.  Unfortunately,
            ;; this behavior means it's impossible to compile anything
            ;; outside the project dir.  The exit function in
            ;; commandline.scm takes care of returning us to our initial
            ;; directory.
            (if (target-option project-dir:)
                (chdir (target-option project-dir:))
                (bomb "Please set a project directory"))
	    (verbose-trace 1 "compiling...")
            (with-temp-file (outport scheme-file)
               (try (with-output-to-port outport
                       (lambda ()
                          (compile output-path source-files)))
                  (target-fatal "Compilation failed")))
	    (verbose-trace 1
			   "creating console binary: "
			   output-path (if (target-option static?:)
					   " (statically linked)"
					   " (dynamically linked)"))
            (bigloo-compile-scheme-to-object-file scheme-file o-file)
            (link-standalone-executable o-file output-path)))))

(define (bigloo-compile-scheme-to-object-file scheme-file o-file)
   ;; Bigloo compiles the Scheme to a native executable for us.
   (apply run-command #t BIGLOO scheme-file "-c" "-o" o-file
          (or (target-option bigloo-optimization:) "-O3")
          `(,@(cond-expand 
                 (unsafe '("-unsafe" "-saw"))
                 (else '()))
              ,@(if (target-option static?:) '("-static-bigloo") '())
              ,@(reverse (or (target-option bigloo-args:) '()))
              ,@(if (> *debug-level* 1) '("-v2") '())
              ,@(apply append (map (lambda (lib-path)
                                      `("-L" ,lib-path "-I" ,lib-path))
                                   (target-option scheme-include-paths:))))))

(define (link-standalone-executable o-file output-pathname)
   (apply run-command #t LD "-o" output-pathname o-file
          "-L" (bigloo-lib-dir) 
          `(,@(if (target-option static?:) '("-static") '())
              ;; microservers always get -mwindows on windows,
              ;; standalones only get it if --gui is specified.
              ,@(if (or (target-option gui?:)
                        (and (or (target-option microserver?:)
                                 (target-option fastcgi?:))
                             (cond-expand (PCC_MINGW #t) (else #f))))
                    '("-mwindows")
                    '())
              ,@(aif (target-option resource-file:)
                     `(,(res-out-file-name it))
                     '())
              ,@(cond-expand
                   ;; on mingw, the root dir can be in different
                   ;; places.  We use local/lib/ for a bunch of
                   ;; libs, but gcc won't look there by default.
                   (PCC_MINGW `(,(string-append 
                                  "-L" (append-paths MINGW-ROOT-DIR "/local/lib"))))
                   (else '()))
              ,@(if (> *debug-level* 1) '("-v") '("-s"))
              ,@(apply append (map (lambda (lib-path)
                                      `("-L" ,lib-path "-I" ,lib-path))
                                   (target-option scheme-include-paths:)))
              ,@(cond
                   ((target-option microserver?:)
                    (microserver-link-libs))
                   ((target-option fastcgi?:)
                    (fastcgi-link-libs))
                   (else '()))
              ,@(standalone-link-libs)
              ,@(reverse (or (target-option ld-args:) '())))))	      

(define-method (build-target target::library-target)
   (set! *compile-mode?* #t) ; for error output (see php-errors)
   (setup-library-paths)
   (load-runtime-libs (or (target-option default-libs:) '()))
   (load-runtime-libs (or (target-option commandline-libs:) '()))
   (run-startup-functions)
   (when (target-option fastcgi?:)
      ;; force the fastcgi extension's dependancies to be loaded
      (require-extension "fastcgi"))
   (with-access::library-target target
         (name output-path source-files libraries options)
      (set! source-files (validate-files source-files))
      (when (and (not (target-option install?:))
		 (null? source-files))
         (bomb "No library files to compile."))
      (verbose-trace 1 *RAVEN-VERSION-TAG*)
      (let* ((mhttpd-binary (if output-path (basename output-path) name))
             (fastcgi-binary (string-append (if output-path (basename output-path) name) ".fcgi"))
             (output-dir (if output-path (dirname output-path) ""))
             (dynamic-lib
              (append-paths output-dir
                            (make-shared-library-name (string-append "lib" name (safety-ext) "-" (bigloo-version)))))
             (static-lib
              (append-paths output-dir
                            (make-static-library-name (string-append "lib" name (safety-ext)))))
             (heap-file (append-paths output-dir (mkext name ".heap")))
             (lib-make-file (append-paths output-dir (string-append name "-make-lib.scm")))
	     (dirty-source-files (filter needs-rebuild? source-files)))

	 (when (target-option install?:)
	     (do-install name dynamic-lib static-lib)) ; won't return
	 
         (verbose-trace 1 "building lib: " dynamic-lib ", "
		                         static-lib ", "
;					 lib-make-file ", "
					 (length source-files) " source files "
					 "(" (length dirty-source-files) " require build)")
         ;; finally, we've got all our paths, so let's compile to scheme
	 ; NOTE: we always generate all scheme files, not just dirty ones.
	 (verbose-trace 1 "compiler: preprocessing...")	 
         (with-temp-file (outport lib-make-file)
            (with-output-to-port outport
               (lambda ()
		  (compile name source-files #t))))
	 (append! *files-to-clean* (map (lambda (f) (mkext f ".scm")) source-files))
	 (pushf lib-make-file dirty-source-files)
	 ;
         (let ((include-path (apply append
                                    (map (lambda (lib-path)
                                            `("-L" ,lib-path "-I" ,lib-path))
                                         (target-option scheme-include-paths:)))))
            ;; have bigloo build a library "heap"
            (apply run-command #t BIGLOO "-unsafe" "-mkaddheap" "-mkaddlib"
                   "-heap-library" name lib-make-file "-addheap" heap-file include-path)
            ;; now let bigloo compile all the scheme files. We CD
            ;; around because otherwise the .o files will overwrite
            ;; each other.
            (let* ((object-files '())
                   (compile-lib-file
                    (lambda (file . dload-sym)
                       (let ((cwd (pwd))
                             (filedir (dirname file))
                             (scheme-file (mkext (basename file) ".scm"))
                             (c-file (mkext (mkstr (basename file) (safety-ext)) ".c"))
                             (o-file (mksext (basename file) ".o")))
                          (pushf (append-paths filedir o-file) object-files)
                          (unwind-protect
			    (if (member file dirty-source-files)
                             (begin
                              (debug-trace 2 "CDing to " filedir " to compile " scheme-file " to " o-file)
                              (chdir filedir)
			      ; cleanup. we add the .c file because if the user ctrl-c, it might be left around
                              (pushf (append-paths filedir c-file) *files-to-clean*)
                              (verbose-trace 1 "compiling " file)
                              (apply run-command #t BIGLOO "-c" scheme-file "-o" o-file "-saw" "-mkaddlib" 
                                     (or (target-option bigloo-optimization:) "-O3")
                                     `(,@(cond-expand
                                          (PCC_MINGW '())
                                          (else '("-copt" "-fPIC")))
                                       ,@(cond-expand 
                                          (unsafe '("-unsafe"))
                                          (else '()))
				       ,@(or (target-option bigloo-args:) '())
				       ; XXX this is relavent for microweb apps, but not for
				       ; libraries since we build both. except on windows, we should build
				       ; each library file twice, once with static and once without
				       ; then use different object files when we link, like we
				       ; do for our extensions
				       ;
				       ,@(if (and (or (target-option microserver?:)
                                                      (target-option fastcgi?:))
						  (target-option static?:)) '("-static-bigloo") '())
                                       ;; we only want a dload-sym on
                                       ;; the first one, the make-lib
                                       ;; file.
                                       ,@(if (null? dload-sym)
                                             '()
                                             '("-dload-sym"))
                                       ,@include-path)))
			      ; up to date
			      (verbose-trace 1 file " is up to date"))
                             (chdir cwd))))))
               (compile-lib-file lib-make-file #t)
               (dolist (file source-files)
                  (compile-lib-file file))
               (verbose-trace 1 "linking shared library: " dynamic-lib)
               ;; now make the shared lib            
               (apply run-command #t LD "-shared" "-L" (bigloo-lib-dir)
                      "-o" dynamic-lib
                      `(,@object-files
                        ,@include-path
                        ,@(cond-expand
                           ;; on mingw, the root dir can be in different
                           ;; places.  We use local/lib/ for a bunch of
                           ;; libs, but gcc won't look there by default.
                           (PCC_MINGW `(,(string-append 
                                          "-L" (append-paths MINGW-ROOT-DIR "/local/lib"))))
                           (else '()))

                        ,@(dll-link-libs); (apply append (map (lambda (lib) 
;                                                 `("-l" ,lib))
;                                              (dll-link-libs)))
                        ))

               ;; And the static lib. XXX static libs don't work on
               ;; windows because of the __declspec(dllimport) stuff,
               ;; but we kludge them to work with microservers for
               ;; now.
               (when (cond-expand
                        (PCC_MINGW (or (target-option microserver?:)
                                       (target-option fastcgi?:)))
                        (else #t))
                  (apply run-command #t AR "ru" static-lib object-files)
                  (verbose-trace 1 "linking static library: " static-lib))
;;;;;;;;;;;;;;;
               ;; in case the user wants a microserver stub, generate it.
               ;; I wanted this to be another target type which extends
               ;; library-target, but bigloo doesn't allow that with wide
               ;; classes...
               (when (or (target-option microserver?:)
                         (target-option fastcgi?:))
		  ;; if we are using a windows resource file, compile it first
		  (awhen (target-option resource-file:)
			 (verbose-trace 1 "using windows resource file: " it)
			 (compile-res-file it))
                  (let ((microserver-source-file (append-paths output-dir (mkext name ".scm")))
			(o-file (mkext name ".o")))
                     (with-temp-file (outport microserver-source-file)
                                     (for-each (lambda (form)
                                                  (pp form outport)
                                                  (newline outport))
                                               (if (target-option microserver?:)
                                                   (library-httpd-stub name)
                                                   (fastcgi-stub name))))

		     (verbose-trace 1
				    "creating " (if (target-option microserver?:)
						    "MicroServer"
						    "FastCGI")
				    " binary: " (if (target-option microserver?:)
						    mhttpd-binary
						    fastcgi-binary)
				    (if (target-option static?:)
					" (statically linked)"
					" (dynamically linked)"))
                     ;; XXX bigloo doesn't clean this for some reason?
		     (pushf (mkext name ".c") *files-to-clean*)
		     
		     (bigloo-compile-scheme-to-object-file microserver-source-file o-file)
		     (link-standalone-executable o-file (if (target-option microserver?:)
                                                                         mhttpd-binary
                                                                         fastcgi-binary)))))))))


(define-method (build-target target::dump-target)
   (with-access::dump-target target
         (source-files dump-type)
      (case dump-type
         ((tokens) (dump-tokens (car source-files)))
         ((types) (dump-types (car source-files)))
         ((ast) (dump-ast (car source-files)))
         ((preprocessor-tokens) (dump-preprocessed (car source-files)))
         (else (bomb "unsupported dump type")))))


(define (validate-files flist)
   (let ((invalid (filter (lambda (f)
                             (or (not (file-exists? f))
                                 (= (file-size f) 0)))
                          flist))
         (valid (filter (lambda (f)
                           (and (file-exists? f)
                                (> (file-size f) 0)))
                        flist)))
      (if (null? invalid)
          flist
          (begin
             (whine "Files are empty or don't exist -- " (string-join invalid ", "))
             valid))))

;;;; target options
(define (target-option key)
   "get the option identified by key from current target"
   (let loop ((lst (target-options *current-target*)))
      (cond
	 ((null? lst) #f)
	 ((eqv? (car lst) key) (cadr lst))
	 (else (loop (cddr lst))))))

(define (set-target-option! key value)
   "set the value of the option identified by key to value in current target"
   (let loop ((lst (target-options *current-target*)))
      (cond
	 ((null? lst)
	  (target-options-set!
           *current-target* (cons* key value (target-options *current-target*))))
	 ((eqv? (car lst) key) (set-car! (cdr lst) value))
	 (else (loop (cddr lst))))))

(define (add-target-option! key value)
   "add value to the list of options identified by key in current target" 
   (let loop ((lst (target-options *current-target*)))
      (cond
	 ((null? lst)
	  (target-options-set!
           *current-target* (cons* key (list value) (target-options *current-target*))))
	 ((eqv? (car lst) key) (set-car! (cdr lst) (cons value (cadr lst))))
	 (else (loop (cddr lst))))))


(define bigloo-lib-dir
   (let ((bigloo-lib-dir #f))
      (lambda ()
	 (or bigloo-lib-dir
	     (begin
		(set! bigloo-lib-dir (get-bigloo-var "*default-lib-dir*"))
		bigloo-lib-dir)))))


   

(define (get-bigloo-var var)
   (let ((out (system->string
               (string-append BIGLOO " -eval \"(begin (print " var ") (exit 0))\""))))
      (if (<= (string-length out) 1)
	  #f
	  (substring out 0 (- (string-length out) 1)))))


; ;these two are lazy - the call to get-bigloo-var is actually quite expensive!
(define-macro (bigloo-version)
   `',*bigloo-version*)

(define (res-out-file-name file)
   (string-append (prefix file) "-res.o"))


(define (run-command errors-fatal? command . args)
   ; on the mac, if the command is the linker, translate -L foo to
   ; -Lfoo to keep it happy.
   (cond-expand
    (PCC_MACOSX
     (when (string=? command LD)
	(let ((new-args '())
	      (arg-is-L #f))
	   (for-each (lambda (arg)
			(cond
			   (arg-is-L
			    (pushf (mkstr "-L" arg) new-args)
			    (set! arg-is-L #f))
			   ((string=? arg "-L")
			    (set! arg-is-L #t))
			   (else (pushf arg new-args))))
		     args)
	   (set! args (reverse! new-args))))))
   ; in MinGW, translate paths to unix style
   (cond-expand
    (PCC_MINGW
     (string-replace! command #\\ #\/)
     (map! (lambda (p) (string-replace p #\\ #\/)) args)))
   (debug-trace 2 "running command: " command ", args: " args)
   (let* ((proc (try (apply run-process command (append args '(output: pipe: error: pipe: wait: #f)))
                     ;; it's interesting that the error handler seems
                     ;; to be running in the child process, so even if
                     ;; it calls exit(), run-command keeps going!
                     ((if errors-fatal? target-fatal target-warn)
                      (mkstr "running command " command))))
          (port (process-output-port proc))
          (error-port (process-error-port proc))
          (exit-status
           (let ((trace-nonempty (lambda (str) (unless (zero? (string-length str))
                                             (debug-trace 2 str)))))
              (let loop ()
                 (if (process-alive? proc)
                     (begin
                        (trace-nonempty (read-available port "OUT: "))
                        (trace-nonempty (read-available error-port "ERR: "))
                        ;; lame attempt to not busy-wait
                        (sleep 10)
                        (loop))
                     (begin 
                        (trace-nonempty (read-available port "OUT: "))
                        (trace-nonempty (read-available error-port "ERR: "))
                        (process-exit-status proc)))))))
      (unless (= exit-status 0)
         ((if errors-fatal? bomb whine)
          "problem running command '" command "', exit status " exit-status))))

(define (compile-res-file file)
   (when (and file 
	      (file-exists? file))
      (run-command #f WINDRES file (res-out-file-name file))))


; install library to lib dir
(define (do-install libbase soname aname)
   (letrec ((heapfile (mkext libbase ".heap"))
	    (schfile (mkext libbase ".sch"))
	    (load-paths (filter (lambda (f) (directory? f)) *dynamic-load-path*))
	    (checkfile (lambda (f)
			  (when (not (file-exists? f))
			      (fprint (current-error-port) (format "library file not found: ~a" f))
			      (exit 1)))))
      (print *RAVEN-VERSION-TAG*)
      ; make sure all files exist
      (checkfile soname)
      (checkfile aname)
      (checkfile heapfile)
      (checkfile schfile)
      ; make sure we have a directory
      (let ((sel-path ""))
	 (cond ((< (length load-paths) 1)
		(begin
		   (fprintf (current-error-port) "there are no library paths specified in your config file")
		   (exit 1)))
	       ((= (length load-paths) 1) (set! sel-path (car load-paths)))
	       (else
		; select path
		(set! sel-path (select-path (unique-strings load-paths)))))
	 (print "installing to " sel-path " ....")
	 ; go for liftoff
	 (copy-file soname (mkstr sel-path (pcc-file-separator) soname))
	 (copy-file aname (mkstr sel-path (pcc-file-separator) aname))
	 (copy-file heapfile (mkstr sel-path (pcc-file-separator) heapfile))
	 (copy-file schfile (mkstr sel-path (pcc-file-separator) schfile))
	 (when (string=? (os-class) "unix")
	    (system "strip " (mkstr sel-path (pcc-file-separator) soname)))
	 (print "done.")
	 )
      (exit 0)))

(define (select-path plist)
   ; get rid of current directory
   (let ((glst (filter (lambda (v)
			      (not (string=? (util-realpath (pwd))
					     (util-realpath (normalize-path v)))))
			   plist)))
      (let loop ((lst glst)
		 (i 1))
	 (if (pair? lst)
	     (begin
		(print (format "[~a] ~a" i (car lst)))
		(loop (cdr lst) (+ i 1)))))
      (display "select an install directory: ")
      (flush-output-port (current-output-port))
      (let* ((inchar (read-line (current-input-port)))
	     (innum (string->number inchar)))
	 (when (eqv? innum #f)
	    (exit 0))
	 (if (and (> innum 0)
		  (<= innum (length glst)))
	     (list-ref glst (- innum 1))
	     (begin
		(fprint (current-error-port) "invalid directory")
		(exit 1))))))


(define (scheme-libraries-and-includes)
   (apply append
          (map (lambda (f)
                  `((library ,(if (string? f) (string->symbol f) f))
                    ,@(let ((include-file-name (mkext f ".sch")))
                           (if (find-file/path include-file-name (target-option scheme-include-paths:))
                               `((include ,include-file-name))
                               '()))))
               ;; since we aren't all that hot at detecting library
               ;; dependencies yet, we give the user an easy
               ;; workaround by forcing libraries specified explicitly
               ;; to always be loaded. 
               (delete-duplicates (append 
                                   ;; unfortunately, every builtin contains calls to the
                                   ;; profiler.  It would be nice to get rid of that.
                                   '("php-runtime" "profiler")
                                   (cond
                                      ((or (target-option cgi?:) 
                                           (target-option microserver?:))
                                       '("phpeval" "webconnect"))
;                                       ((target-option fastcgi?:)
;                                        '("cgi" "phpeval" "webconnect" "fastcgi"))
                                      (else
                                       '()))
                                   (target-libraries *current-target*)
                                   (or (target-option commandline-libs:) '()))))))

(define (standalone-link-libs)   
   (let ((libs '())
         (lib->extensions (make-hashtable)))
      (extensions-for-each 
       (lambda (name)          
          (hashtable-put! lib->extensions
                          (get-extension-info name scheme-lib-name:)
                          (cons name (or (hashtable-get lib->extensions 
                                                        (get-extension-info name scheme-lib-name:)) 
                                         '())))))
      (for-each (match-lambda 
                 ;; the code required some extension, which turns into
                 ;; a requirement for a library.  However, each
                 ;; library can contain more than one extension.  So
                 ;; we get the list of all the extensions in the
                 ;; library, and then tack on all of the system
                 ;; libraries that they depend on.
                 ((library ?name) 
                  (pushf (string-append "-l" (mkstr name) (safety-ext) "-" (bigloo-version)) libs)
                  (let* ((extensions
                          (or (hashtable-get lib->extensions (mkstr name))
                              ;; some libraries have no extensions, such as php-runtime
                              (list name)))
                         (ext-libs (apply append
                                          (map (lambda (extension)
                                                  (if (extension-registered? extension)
                                                      (get-extension-info extension lib-list:)
                                                      '()))
                                               extensions))))
                     
                     (debug-trace 2 "libraries needed for extensions " extensions ": " ext-libs)
                     (for-each (lambda (l) (pushf l libs)) ext-libs))))
                (scheme-libraries-and-includes))
      (pushf (string-append "-l" "bigloo" (safety-ext) "-" (bigloo-version)) libs)
      (pushf (string-append "-l" "bigloogc" "-" (bigloo-version)) libs)

      ; verbose if we're really debugging
      (when (> *debug-level* 2)
	    (pushf "-Wl,--verbose" libs))

      (cond-expand
	 (PCC_MINGW
	  ;; these are needed for the profiler, which uses gettimeofday
	  ;; and ws2_32 is needed by libbigloo.  If the standard extension
	  ;; gets pulled in, it masks the need for putting these here,
	  ;; since it uses them too.
	  (set! libs (cons* "-lws2_32" "-lgw32c" "-lole32" "-luuid" libs)))
	 (PCC_FREEBSD
	  ;; FreeBSD doesn't use -ldl
	  (set! libs (cons* "-lm" libs)))
	 (else
	  ; Linux
	  (set! libs (cons* "-lm" "-ldl" libs))))

      ;; voodoo.
      (reverse! (append libs libs))))

(define (dll-link-libs)
   (standalone-link-libs)
   )

(define (microserver-link-libs)
   `(,(string-append "-lmhttpd" (safety-ext) "-" (bigloo-version))
     "-lwebserver"
     ,@(if (target-option static?:)
           `(,(string-append "-l" (library-target-name *current-target*) (safety-ext)))
           '())))

(define (fastcgi-link-libs)
   `(,@(if (target-option static?:)
           `(,(string-append "-l" (library-target-name *current-target*) (safety-ext)))
           '())))
;       ,"-lfcgi"))



(define (mkext file ext)
   (string-append (prefix file) ext))

; same but tack in safety extension
(define (mksext file ext)
   (string-append (prefix file) (safety-ext) ext))

;;;;;;


;;; Error handlers
(define (target-fatal . msg)
   (lambda (e p m o)
      (apply bomb (append msg (list " -- " m)))))

(define (target-warn . msg)
   (lambda (e p m o)
      (apply whine (append msg (list " -- " m)))
      (e #t)))

(define (bomb . msg)
   (apply fprint (current-error-port) "Error: " msg)
   (when (< *debug-level* 2)
      (fprint (current-error-port) "Rerunning with debug level 2 may provide more information."))
   (when (and *RAVEN-DEVEL-BUILD* (getenv "BIGLOOSTACKDEPTH"))
      (dump-bigloo-stack (current-error-port)
                        (max 1 (string->integer (getenv "BIGLOOSTACKDEPTH")))))
   (when *commandline?*
      (exit 1)))

(define (whine . msg)
   (apply fprint (current-error-port) "Warning: " msg))


;;; Cleanup temporary files
(define *files-to-clean* '())

;; run as a shutdown function so it will cleanup after errors
(register-exit-function!
 (lambda (exit-status)
    (cond ((or (not *current-target*) (target-option no-cleanup?:))
           exit-status)
          (else 
           (debug-trace 2 "cleaning up...")
           (for-each (lambda (f)
                        (when (file-exists? f)
                           (debug-trace 3  "removing " f)
                           (delete-file f)))
                     *files-to-clean*)
           exit-status))))

(define (invoke-with-temp-file path k #!optional errmsg)
   (let ((outport (open-output-file path)))
      (pushf path *files-to-clean*)
      (if (not outport)
          (bomb "Unable to open temporary file " path)
          (unwind-protect
             (k outport)
             (close-output-port outport)))))

(define (read-available port #!optional (prefix ""))   
   (with-output-to-string
       (lambda ()
          (let loop ()
               (when (char-ready? port)
                  (let ((char (read-char port)))
                     (unless (eof-object? char)
                        (display char)
                        (when (char=? char #\newline)
                           (display prefix))
                        (loop))))))))

;; only compile again if source file last mod is greater than .o
(define (needs-rebuild? file)
   (if (target-option force-rebuild?:)
       #t
       (let ((obj-file (mksext file ".o"))
	     (php-file file))
	  (if (and (file-exists? obj-file)
		   (file-exists? php-file))
	      (let ((obj-mod (file-modification-time obj-file))
		    (php-mod (file-modification-time php-file)))
		 (> php-mod obj-mod))
	      #t))))



(define (require-extension extension)
   (with-access::target *current-target* (libraries)
      (let ((lib-name (get-extension-info extension scheme-lib-name:)))                      
         (unless (member lib-name libraries) 
            ;; we want to make sure that the required
            ;; extensions come after the extension that
            ;; requires them, so we add to the end of the
            ;; list instead of the beginning.
            (set! libraries (append libraries (list lib-name)))
            (debug-trace 2 "Ensuring that extension " extension " will load.")
            (for-each require-extension
                      (get-extension-info extension required-extensions:))))))

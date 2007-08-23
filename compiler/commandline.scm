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

;Parse and implement the commandline arguments
(module commandline
   (library php-runtime)
   (include "php-runtime.sch")
   (library profiler)
   (import (driver "driver.scm")
           (declare "declare.scm")
	   (ast "ast.scm")
	   (lexers "lexers.scm")
	   (target "target.scm")
           (config "config.scm"))
   (main php-commandline) )

; php compatible commandline switches
(define *php-compat* #f)
(define *initialdir* (pwd))
(define (return-to-original-dir exit-status)
   (when *initialdir*
      (chdir *initialdir*))
   exit-status)
(register-exit-function! return-to-original-dir)
 
(define (php-commandline argv)
   (set! *current-target* (instantiate::target))
   (let ((pcc-argv argv))
	 
      (when (= (length pcc-argv) 1)
	 (print (usage-header))
	 (exit 1))

      ; php compat mode
      (when (string=? (basename (car pcc-argv)) "php")
	 (set! *php-compat* #t))
      
      ;; We read the config file prior to parsing the commandline
      ;; arguments, so that the commandline arguments will override
      ;; the config file.  
      (when (member "-c" pcc-argv)
	  ;; -c is the option for an alternate config file.
         (set! *config-file* (cadr (member "-c" pcc-argv))))

      (read-config-file)

      ;; We check the license after reading the config file, so we
      ;; know where to look for the license, but before anything else.
;      (check-license PCC-HOME)

      ; start with no command line arguments for interpreter
      (set-target-option! script-argv: '())

      (try (if *php-compat*
	       (parse-php-commandline-arguments pcc-argv)
	       (parse-commandline-arguments pcc-argv))	       
	   (lambda (e p m o)
	      (print (format "pcc: argument parsing error: ~a ~a" m p))
	      (exit 1)))

      (when (eqv? target (object-class *current-target*))
         ;; default to a standalone target.
         ;; XXX maybe we should rename compile-includes? to
         ;; don't-compile-includes? so we don't have to default it here.
         (set-target-option! compile-includes?: #t)
         (widen!::standalone-target *current-target*))
      
      (build-target *current-target*)))


(define (parse-commandline-arguments pcc-argv)
   (let* ((eat-doubledash? #t)
	  (argv-passthru #f)
	  (add-script-argv (lambda (var)
			      (set-target-option! script-argv: (cons var (target-option script-argv:)))))
	  (maybe-add-script-argv (lambda (var)
				    (if argv-passthru
					(begin
					   (add-script-argv var)
					   #f)
					#t)))
          (do-library-mode
           (lambda (library-name)

              (when (maybe-add-script-argv "-l")
                 (widen!::library-target *current-target* (name library-name))
                 (set-target-option! compile-includes?: #f)))))
      
      (args-parse (cdr pcc-argv)
       (section "Help")

       (("--")
	(unless eat-doubledash?
	   (add-script-argv "--"))
	(set! argv-passthru #t))
       
       (("-?")
	(when (maybe-add-script-argv "-?")	
	   (args-parse-usage #f)
	   (exit 1)))
       
       ((("-h" "--help") (help "This help message"))
	(when (maybe-add-script-argv "-h")
	   (print (usage-header))
	   (args-parse-usage #f)
	   (exit 1)))

       ((("-v") (help "Verbose output"))
	(when (maybe-add-script-argv "-v")
	   (set! *verbosity* 1)))
       
       ((("--version") (help "Current version information"))
	(when (maybe-add-script-argv "--version")	
	   (print *RAVEN-VERSION-STRING*)
	   (exit 1)))

       (section "Run Mode (default: compile console application)")


       ((("-a") (help "Interactive PHP mode (PHP REPL)"))
	(if (maybe-add-script-argv "-a")
	    (begin
	       (widen!::php-repl-target *current-target*))))
       
       ((("-i" "-f" "--interpret") ?script (help "Execute code immediately, instead of compiling"))
	(if (maybe-add-script-argv "-f")
	    (begin
	       (widen!::interpret-target *current-target*)
	       (add-script-argv script)
	       (target-source-files-set! *current-target* (list script)))
	    ; we're in pass through, so add the script var too
	    (add-script-argv script)))
       
       ((("--fastcgi" "--cgi") ?fastcgi-name (help "Generate stand alone FastCGI application (also runs as normal CGI)"))
        (do-library-mode fastcgi-name)
        (when (maybe-add-script-argv "--fastcgi")
	   (add-target-option! fastcgi?: #t)
           (add-target-option! commandline-libs: "fastcgi")))

       ((("-s" "--microserver") ?server-name (help "Generate stand alone MicroServer application"))
        (do-library-mode server-name)
        ;(widen!::microserver-target *current-target*)
	(when (maybe-add-script-argv "-s")
	   (set-target-option! microserver?: #t)
	   (add-target-option! bigloo-args: "-lwebserver")))

       ((("--gui") (help "Generate desktop GUI application (PHP-GTK)"))
	(when (maybe-add-script-argv "--gui")
	   (add-target-option! commandline-libs: "php-gtk")
	   (cond-expand
	      (PCC_MINGW (add-target-option! gui?: #t))
	      (else '()))))
       
;        ((("--cgi") (help "Generate stand alone (normal) CGI application"))
;         (when (maybe-add-script-argv "--cgi")
; 	   (add-target-option! cgi?: #t)))
       
       ((("-l" "--library-mode") ?library-name (help "Generate a library"))
        (do-library-mode library-name))

       
       (section "Compiler Options")

;       ((("-5") (help "Enable PHP5 support"))
;	(when (maybe-add-script-argv "-5")
;	   (go-php5)))

       ((("-c") ?config-file (help "Use the specified config file"))
	(maybe-add-script-argv "-c")
	; this option is actually checked for above because the *config-file* variable needs
	; to be set before read-config-file is called, so this is just here to swallow the
	; option and provide commandline help
	)

       ((("--static") (help "Generate optimized statically linked binary"))
	(when (maybe-add-script-argv "--static")
	   (add-target-option! static?: #t)))
       
       ((("-O" "--optimize") (help "Generate optimized dynamically linked binary"))
	(when (maybe-add-script-argv "-O")
	   (unless (not *track-stack?*)
	      ;; just to keep from frobbing the *bigloo-optimization* twice
	      (set! *track-stack?* #f)
	      (set-target-option! bigloo-optimization: "-O6"))))
       
       ((("-m" "--make-file") ?file (help "Build using specified project make file"))
	(when (maybe-add-script-argv "-m")
	   (parse-make-file file)))
       
       ((("-u" "--use") ?lib-name (help "Use specified PCC library (created with -l) when compiling and linking"))
	(when (maybe-add-script-argv "-u")
	   (add-target-option! commandline-libs: lib-name)))

       ((("-o" "--output-file") ?file (help "The output file"))
	(when (maybe-add-script-argv "-o")
	   (target-output-path-set! *current-target* file)))
       
       ((("-I" "--include-path") ?dir (help "Add a directory to the include file search path")) ;
        ;; XXX I would love these include-paths globals to go away. --timjr
        (set! *include-paths* (cons dir *include-paths*))
        (add-target-option! include-paths: dir))       

       ((("-L" "--library-path") ?lib-path (help "Add lib-path to library search path"))
	(when (maybe-add-script-argv "-L")
	   (add-target-option! library-paths: lib-path)))

       ((("--bopt") ?string (help "Invoke bigloo (scheme compiler) with STRING"))
	(when (maybe-add-script-argv "--bopt")
	   (add-target-option! bigloo-args: (mkstr string))))
       
       ((("--copt") ?string (help "Invoke cc (c compiler) with STRING"))
	(when (maybe-add-script-argv "--copt")
	   (add-target-option! bigloo-args: "-copt")
	   (add-target-option! bigloo-args: (mkstr #\" string #\"))))

       ((("--ldopt") ?string (help "Invoke ld (linker) with STRING"))
	(when (maybe-add-script-argv "--ldopt")
	   (add-target-option! bigloo-args: "-ldopt")
	   (add-target-option! bigloo-args: (mkstr #\" string #\"))
	   (add-target-option! ld-args: string)))
       
       (section "MicroServer Compile Options")

       ((("--port") ?port (help "Set the default port that the MicroServer should use"))
	(add-target-option! micro-web-port: (mkfixnum port)))	

       (section "Web Application (MicroServer/FastCGI) Compile Options")

       ((("--default-index") ?iname (help "Set the default index page [default: index.php]"))
	(add-target-option! webapp-index-page: (mkstr iname)))	
       
       ((("--not-found") ?iname (help "Set the default not found page [default: 404.php]"))
        (add-target-option! webapp-404-page: (mkstr iname)))

       (section "PHP-GTK Compile Options")

       ((("--resource") ?file (help "Compile and use the specified windows resource file"))
	(when (maybe-add-script-argv "--resource")
	   (set-target-option! resource-file: file)))
       
       (section "Library Related Options (requires -l, --fastcgi, or --microserver)")
       
       ((("--strip-path") ?strip-path (help "Strip leading path from source files when compiling a library"))
	(when (maybe-add-script-argv "--strip-path")
	   (add-target-option! strip-paths: strip-path)))

       ((("--install") (help "Install library to PCC library directory"))
;	(widen!::install-target *current-target*))
	(when (maybe-add-script-argv "--install")
	   (set-target-option! install?: #t)))
       
       ((("--force-rebuild") (help "Force rebuild of all source files in a library"))
	(when (maybe-add-script-argv "--force-rebuild")
	   (set-target-option! force-rebuild?: #t)))
       
       (section "Debugging")
       
       ((("-d" "--debug-level") ?level (help "Set the debug level (0=None/1=Med/2=High)"))
	(when (maybe-add-script-argv "-d")
	   (set! *debug-level* (if *RAVEN-DEVEL-BUILD*
				   (string->integer level)
				   (min (string->integer level) 2)))
	   (when (> *debug-level* 0)
	      (set! *verbosity* 1)
	      (add-target-option! bigloo-args: "-g")
	      (add-target-option! bigloo-args: "-cg"))))

;        ((("-g" "--debugger") (help "Run file in the PCC step debugger"))
; 	(when (maybe-add-script-argv "-g")
; 	   (widen!::debug-target *current-target*)))

        ((("--repl") (help "A scheme REPL with access to the roadsend-php runtime"))
	 (if (maybe-add-script-argv "-a")
	     (begin
		(widen!::scheme-repl-target *current-target*))))
       
       ((("-P" "--profile") (help "Generate code for PHP source level profiling"))
	; (set-target-option! source-level-profile: #t)
	(when (maybe-add-script-argv "-P")
	   (set! *source-level-profile* #t)
	   (add-target-option! bigloo-args: "-library")
	   (add-target-option! bigloo-args: "profiler")))

       ((("-R") (help "Generate code suitable for profiling with gprof/bprof"))
	(when (maybe-add-script-argv "-R")	
	   (add-target-option! bigloo-args: "-pg")
	   (add-target-option! bigloo-args: "-p2")
	   (set-target-option! bigloo-optimization: "-O4")))
       
       ; GET/POST definitions
       ((("--GET") ?gvar (help "Add this key/value pair to _GET superglobal (form: key=val)"))
	(when (string-contains gvar "=")
	   (let ((vals (string-split gvar "=")))
	      (php-hash-insert! (container-value $HTTP_GET_VARS) (mkstr (car vals)) (mkstr (cadr vals)))
              (php-hash-insert! (container-value $_GET) (mkstr (car vals)) (mkstr (cadr vals)))
	      (php-hash-insert! (container-value $_REQUEST) (mkstr (car vals)) (mkstr (cadr vals))))))
       ((("--POST") ?gvar (help "Add this key/value pair to _POST superglobal (form: key=val)"))
	(when (string-contains gvar "=")
	   (let ((vals (string-split gvar "=")))
	      (php-hash-insert! (container-value $HTTP_POST_VARS) (mkstr (car vals)) (mkstr (cadr vals)))
              (php-hash-insert! (container-value $_POST) (mkstr (car vals)) (mkstr (cadr vals)))
	      (php-hash-insert! (container-value $_REQUEST) (mkstr (car vals)) (mkstr (cadr vals))))))
       ((("--COOKIE") ?gvar (help "Add this key/value pair to _COOKIE superglobal (form: key=val)"))
	(when (string-contains gvar "=")
	   (let ((vals (string-split gvar "=")))
	      (php-hash-insert! (container-value $HTTP_COOKIE_VARS) (mkstr (car vals)) (mkstr (cadr vals)))
              (php-hash-insert! (container-value $_COOKIE) (mkstr (car vals)) (mkstr (cadr vals)))
	      (php-hash-insert! (container-value $_REQUEST) (mkstr (car vals)) (mkstr (cadr vals))))))
       ((("--SERVER") ?gvar (help "Add this key/value pair to _SERVER superglobal (form: key=val)"))
	(when (string-contains gvar "=")
	   (let ((vals (string-split gvar "=")))	      
	      (php-hash-insert! (container-value $HTTP_SERVER_VARS) (mkstr (car vals)) (mkstr (cadr vals)))
              (php-hash-insert! (container-value $_SERVER) (mkstr (car vals)) (mkstr (cadr vals))))))

       ((("-rm" "--no-clean") (help "Don't cleanup temporary files")
	 )
	(when (maybe-add-script-argv "-rm")
	   (when *RAVEN-DEVEL-BUILD*
	      (set-target-option! no-cleanup?: #t)
	      (set-target-option! pretty?: #t)
	      (add-target-option! bigloo-args: "-rm"))))
       
       (("--dump-pre" (help "Dump the string produced by the preprocessor")
         )
        (when *RAVEN-DEVEL-BUILD*
           (widen!::dump-target *current-target* (dump-type 'preprocessor-tokens))))
       
       (("--dump-toks" (help "Dump the tokens produced by the main lexer")
         )
        (when *RAVEN-DEVEL-BUILD*
           (widen!::dump-target *current-target* (dump-type 'tokens))))
       
       (("--dump-ast" (help "Dump the syntax tree produced by the parser")
         )
        (when *RAVEN-DEVEL-BUILD*
           (widen!::dump-target *current-target* (dump-type 'ast))))
       
;        (("--dump-containers" (help "Dump the syntax tree produced by the parser, after container analysis")
;          )
;         (when *RAVEN-DEVEL-BUILD*
;            (widen!::dump-target *current-target* (dump-type 'containers))))
       
       (("--dump-types" (help "Dump the syntax tree produced by the parser, after type inference")
         )
        (when *RAVEN-DEVEL-BUILD*
           (widen!::dump-target *current-target* (dump-type 'types))))
       
       ; 	 (("--show-copies" ;(help "Dump the syntax tree produced by the parser, after type inference")
       ; 			  )
       ;	  (set! show-copies? #t))
;        (("--dump-flow" (help "Dump the flow graph of the program")
;          )
;         (when *RAVEN-DEVEL-BUILD*
;            (widen!::dump-target *current-target* (dump-type 'flow-graph))))

;        (("--dump-times" (help "Compile, printing the times required for each stage")
;          )
;         (when *RAVEN-DEVEL-BUILD*
;            (widen!::dump-target *current-target* (dump-type 'times))))
       
       ; this is for pretending to be in non devel mode so we can see what the user will see
       (("--fake-no-devel")
	(add-target-option! bigloo-args: "-s")
	(set! *RAVEN-DEVEL-BUILD* #f))
       
       (else
	(cond
           ((char=? (string-ref else 0) #\-)
	    (print "Illegal argument `" else "'.\n" (usage-header))
            (args-parse-usage #f)
            (exit 1))
	   ; argument is source file, unless interpreting whence it becomes a script argument
	   ; -f requires the file to interpret as an argument above so it's not handled here
           ((if (interpret-target? *current-target*)
		(begin
		   ; script argument
		   (add-script-argv else)
		   ; php compatibility
		   (set! eat-doubledash? #f)
		   )
		; source file
		(let ((source-files (cons else (target-source-files *current-target*))))
		   (unless (target-option project-dir:)
		      (cond ((pathname-relative? (car source-files))
			     (set-target-option! project-dir: (pwd)))
			    (else
			     ;; this is kind of a kludge to deal with the
			     ;; case that the user wants to compile
			     ;; something outside the current directory.
			     ;; See the comment in target.scm for more
			     ;; about the project-dir.
			     ; XXX pita.  we get an error from the assembler that it can't write to /tmp.
			     ;(set-target-option! project-dir: "/")
			     (set-target-option! project-dir: (dirname (car source-files)))
			     (set! source-files (map util-realpath source-files)))))
		   (target-source-files-set! *current-target* source-files)))))))))

; 
; Zend PHP compatible commandline arguments. These are enabled automatically
; if pcc is started as "php", e.g. by a symlink or if it's renamed
;
(define (parse-php-commandline-arguments pcc-argv)
   (let* ((eat-doubledash? #t)
	  (argv-passthru #f)
	  (add-script-argv (lambda (var)
			      (set-target-option! script-argv: (cons var (target-option script-argv:)))))
	  (maybe-add-script-argv (lambda (var)
				    (if argv-passthru
					(begin
					   (add-script-argv var)
					   #f)
					#t))))
      (args-parse (cdr pcc-argv)
       (section "Help")

       (("--")
	(unless eat-doubledash?
	   (add-script-argv "--"))
	(set! argv-passthru #t))
       
       ((("-h" "--help") (help "This help message"))
	(when (maybe-add-script-argv "-h")
	   (print (usage-header))
	   (args-parse-usage #f)
	   (exit 1)))

       ((("-v") (help "Verbose output"))
	(print *RAVEN-VERSION-STRING*)
	(exit 1))

       ((("-c") ?config-file (help "Use the specified config file"))
	(maybe-add-script-argv "-c")
	; this option is actually checked for above because the *config-file* variable needs
	; to be set before read-config-file is called, so this is just here to swallow the
	; option and provide commandline help
	)
       
       ((("-f") ?script (help "Execute code immediately, instead of compiling"))
	(if (maybe-add-script-argv "-f")
	    (begin
	       (widen!::interpret-target *current-target*)
	       (add-script-argv script)
	       (target-source-files-set! *current-target* (list script)))
	    ; we're in pass through, so add the script var too
	    (add-script-argv script)))
       
       ((("-d") ?keyval (help "Define INI entry foo=bar"))
	(maybe-add-script-argv "-d")
	(unless (= (string-index keyval "=") -1)
	   (let ((kv (string-split keyval "=")))
	      (if (= (length kv) 1)
		  (set-ini-entry (car kv) TRUE)
		  (set-ini-entry (car kv) (cadr kv))))))

       (else
	(print "Illegal argument `" else "'.\n" (usage-header))
	(args-parse-usage #f)
	(exit 1)))))


(define (usage-header)
   (format "~a\n~a\n~a\n"
	   *RAVEN-VERSION-TAG*
	   "Usage: pcc [options] <input-files> [-- script args]"
	   "see pcc -h for help with command line options"))



;; these correspond to the IDE when it saves a makefile
(define *PROJ-TYPE-CL* "0")
(define *PROJ-TYPE-GUI* "1")
(define *PROJ-TYPE-LIB* "2")
(define *PROJ-TYPE-WEBAPP* "3")
(define *PROJ-TYPE-MICROWEB* "4")
(define *PROJ-TYPE-CGI* "5")

(define *EXT-TYPE-PHP* "0")
(define *LANG-COMPAT-PHP5* "1")

(define (parse-make-file file)
   (debug-trace 1 (format "reading from project make file: ~a" file))
   (unless (file-exists? file)
      (print (format "project make file ~a does not exist" file))
      (exit -1))
   (let ((mainFile "")
         (output-file "")
         (libname "")
         (lib? #f)
         (ptype "")
         (source-files '())
         (ini-vals (ini-file-parse file #t)))
      (php-hash-for-each ini-vals
         (lambda (section vals)
            (when (php-hash? vals)
               (php-hash-for-each vals
                  (lambda (key val)
                     (let ((k (mkstr key))
                           (v (mkstr val)))
                        (debug-trace 3 (format "makefile: ~a => ~a" k v))                       
                        (cond
                           ((string=? section "files")
                            (when (string=? v *EXT-TYPE-PHP*)
                               (debug-trace 2 (format "add projectfile: ~a" (windows->unix-path k)))
                               (pushf (windows->unix-path k) source-files)))
                           ((string=? k "projectName") (set! output-file (windows->unix-path v)))
                           ((string=? k "libName") (set! libname v))
;			   ((and (string=? k "langCompat")
;				 (string=? v *LANG-COMPAT-PHP5*))
;			    (go-php5))
                           ((string=? k "mainFile") (set! mainFile (windows->unix-path v)))
                           ((string=? k "microWebPort") (add-target-option! micro-web-port: (mkfixnum v)))
                           ((string=? k "profile") (when (string=? v "1")
                                                      (set! *source-level-profile* #t)
                                                      ;(set-target-option! source-level-profile: #t)
                                                      (add-target-option! bigloo-args: "-library")
                                                      (add-target-option! bigloo-args: "profiler")))
                           ((string=? k "linkStatic") (when (string=? v "1") 
                                                         ; (pushf "-static-bigloo" *bigloo-optimization*)
							    (add-target-option! static?: #t)))
                                                         ;(add-target-option! bigloo-args: "-static-bigloo")))
                           ((string=? k "projectType") (set! ptype v))
                           ((string=? k "projectDirectory") (begin
                                                               (set-target-option! project-dir: v)))
                           ((string=? k "stripPath") (unless (string=? v "")
                                                        ; (set! *library-compile-strip-paths*
                                                        ;   (add-strip-path (windows->unix-path v)))
                                                        (add-target-option! strip-paths: (force-trailing-/ (windows->unix-path v))))))))))))
      (cond
;        ((string=? ptype *PROJ-TYPE-CGI*)          
;         (add-target-option! cgi?: #t))
        ((string=? ptype *PROJ-TYPE-GUI*) 
         (add-target-option! commandline-libs: "php-gtk")
	 (cond-expand
	    (PCC_MINGW (add-target-option! gui?: #t))
	    (else '())))
;         (add-target-option! bigloo-args: "-copt")
;         (add-target-oauption! bigloo-args: "-mwindows"))
        ;; we do this after reading everything because otherwise
        ;; the library name gets set too late
        ((or (string=? ptype *PROJ-TYPE-LIB*)
             (string=? ptype *PROJ-TYPE-MICROWEB*)
             (string=? ptype *PROJ-TYPE-WEBAPP*))
         ;; default to the project name, but let
         ;; an explicit libname setting override it
         (unless (> (string-length libname) 0)
            (set! libname output-file))
         (set! lib? #t)
         (debug-trace 2 "will build library: " libname)
         (widen!::library-target *current-target* (name libname))
         (set-target-option! compile-includes?: #f)
	 (when (string=? ptype *PROJ-TYPE-WEBAPP*)
	    (add-target-option! fastcgi?: #t)
	    (add-target-option! commandline-libs: "fastcgi"))
         (when (string=? ptype *PROJ-TYPE-MICROWEB*)
            (set-target-option! microserver?: #t)
            (add-target-option! bigloo-args: "-lwebserver"))
         (target-source-files-set! *current-target* source-files)))
      ;; if this is not a library, add mainfile to front of filelist, (if it exists).
      (when (and (not lib?)
                 (> (string-length mainFile) 0))
         (debug-trace 2 "output name: " output-file " main file: "  mainFile)
         (widen!::standalone-target *current-target*)
         (target-output-path-set! *current-target* output-file)
         (target-source-files-set! *current-target* 
                                   (reverse (cons mainFile (delete mainFile source-files)))))))


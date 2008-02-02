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


; Commandline interface to debugger
(module pcc-debugger
   (library php-runtime)
   (include "php-runtime.sch")
   (library profiler)
   (library mhttpd)
   (library webconnect)
   (import (pcc-highlighter "synhighlight.scm")
           (driver "driver.scm")
           (declare "declare.scm")
	   (ast "ast.scm")
	   (lexers "lexers.scm")
	   (target "target.scm")
	   (debugger "debugger.scm")
	   (evaluate "evaluate.scm") ; access to environments
           (config "config.scm"))
   (main debug-main) )

(define *initialdir* (pwd))
(define (return-to-original-dir exit-status)
   (when *initialdir*
      (chdir *initialdir*))
   exit-status)
(register-exit-function! return-to-original-dir)

;;; The variable `*slavemode*' is for internal use by our graphical
;;; front-end.  Once it has been enabled, it will never be turned off
(define *slavemode* #f)

; debug target - either a file (commandline) or web root (http)
(define *debug-target-file* #f)
(define *debug-target-webroot* #f)

(define *web-scan-skip-dirs* '(".svn" ".cvs"))
(define *web-ext-list* '("php" "inc"))
(define *web-files* '())

(define *syntax-highlight* #t)

(define (debug-main argv)
   (let ((pcc-argv argv))

      (set! *current-target* (instantiate::debug-target))

      ; define the callbacks that the debugger will use
      (set! *debugger-repl* debugger-repl)
      (set! *debugger-run* debugger-run)
      (set! *breakpoint-file-line-event* breakpoint-file-line-event)
      (set! *breakpoint-function-event* breakpoint-function-event)
      (set! *breakpoint-web-event* breakpoint-web-event)      
            
      ;; We read the config file prior to parsing the commandline
      ;; arguments, so that the commandline arguments will override
      ;; the config file.  
      (when (member "-c" pcc-argv)
	  ;; -c is the option for an alternate config file.
         (set! *config-file* (cadr (member "-c" pcc-argv))))

      (read-config-file)

      ; start with no command line arguments for interpreter
      (set-target-option! script-argv: '())

      (parse-commandline-arguments pcc-argv)

      ; if we had a file on the commandline, run it
      (if (or *debug-target-file*
	      *debug-target-webroot*)
	  (start-debugger)
	  (usage-header))
      
      (exit 0)))

      
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
					#t))))
      
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

;       ((("-5") (help "Enable PHP5 support"))
;	(when (maybe-add-script-argv "-5")
;	   (go-php5)))

       ((("-v") (help "Verbose output"))
	(when (maybe-add-script-argv "-v")
	   (set! *verbosity* 1)))
       
       ((("--version") (help "Current version information"))
	(when (maybe-add-script-argv "--version")	
	   (print *RAVEN-VERSION-STRING*)
	   (exit 1)))

       ((("--port") ?port (help "Set the default port that the MicroServer should use"))
	(add-target-option! micro-web-port: (mkfixnum port)))	
       
       ((("-u" "--use") ?lib-name (help "Use specified PCC library when compiling and linking"))
	(when (maybe-add-script-argv "-u")
	   (add-target-option! commandline-libs: lib-name)))

       ((("-c") ?config-file (help "Use the specified config file"))
	(maybe-add-script-argv "-c")
	; this option is actually checked for above because the *config-file* variable needs
	; to be set before read-config-file is called, so this is just here to swallow the
	; option and provide commandline help
	)
       
       ((("-I" "--include-path") ?dir (help "Add a directory to the include file search path")) ;
        ;; XXX I would love these include-paths globals to go away. --timjr
        (set! *include-paths* (cons dir *include-paths*))
        (add-target-option! include-paths: dir))       

       ((("-L" "--library-path") ?lib-path (help "Add lib-path to library search path"))
	(when (maybe-add-script-argv "-L")
	   (add-target-option! library-paths: lib-path)))
       
       ((("-d" "--debug-level") ?level (help "Set the debug level (0=None/1=Med/2=High)"))
	(when (maybe-add-script-argv "-d")
	   (set! *debug-level* (if *RAVEN-DEVEL-BUILD*
				   (string->integer level)
				   (min (string->integer level) 2)))
	   (when (> *debug-level* 0)
	      (set! *verbosity* 1)
	      (add-target-option! bigloo-args: "-g")
	      (add-target-option! bigloo-args: "-cg"))))

       ; GET/POST definitions
       ((("--GET") ?gvar (help "Add this key/value pair to _GET superglobal (form: key=val)"))
	(when (string-contains gvar "=")
	   (let ((vals (string-split gvar "=")))
              (php-hash-insert! (container-value $_GET) (mkstr (car vals)) (mkstr (cadr vals)))
	      (php-hash-insert! (container-value $_REQUEST) (mkstr (car vals)) (mkstr (cadr vals))))))
       ((("--POST") ?gvar (help "Add this key/value pair to _POST superglobal (form: key=val)"))
	(when (string-contains gvar "=")
	   (let ((vals (string-split gvar "=")))
              (php-hash-insert! (container-value $_POST) (mkstr (car vals)) (mkstr (cadr vals)))
	      (php-hash-insert! (container-value $_REQUEST) (mkstr (car vals)) (mkstr (cadr vals))))))
       ((("--COOKIE") ?gvar (help "Add this key/value pair to _COOKIE superglobal (form: key=val)"))
	(when (string-contains gvar "=")
	   (let ((vals (string-split gvar "=")))
              (php-hash-insert! (container-value $_COOKIE) (mkstr (car vals)) (mkstr (cadr vals)))
	      (php-hash-insert! (container-value $_REQUEST) (mkstr (car vals)) (mkstr (cadr vals))))))
       ((("--SERVER") ?gvar (help "Add this key/value pair to _SERVER superglobal (form: key=val)"))
	(when (string-contains gvar "=")
	   (let ((vals (string-split gvar "=")))	      
              (php-hash-insert! (container-value $_SERVER) (mkstr (car vals)) (mkstr (cadr vals))))))
       
       ; this is for pretending to be in non devel mode so we can see what the user will see
       (("--fake-no-devel")
	(add-target-option! bigloo-args: "-s")
	(set! *RAVEN-DEVEL-BUILD* #f))

       ((("--highlight") ?file (help "Display syntax highlighted version of file"))
        (when (file-exists? file)
	   (let ((source-hash (syntax-highlight-file file 'ansi)))
	      (hashtable-for-each source-hash
				  (lambda (line source)
				     (print source)))))
        (exit 0))
       
       (else
	; commandline file or webroot specification
	(if (directory? else)
	    (set! *debug-target-webroot* else)
	    (when (file-exists? else)
	       (set! *debug-target-file* else)))))))

(define (start-debugger)
   ;; commandline
   (if *debug-target-file*
       (begin
	  (target-source-files-set! *current-target* (list *debug-target-file*))
	  (build-target *current-target*))
   ;; web app
       (begin
	  (chdir *debug-target-webroot*)
	  (scan-project-root)
	  (set! *micro-debugger?* #t)
	  (set! *micro-web-root* *debug-target-webroot*)
	  (set! *web-debugger?* #t)
	  ; handle ctrl-c to quit
	  (signal 2 (lambda (arg)
		       (stop-micro-server)
		       (when (> *debug-level* 0)
			  (fprint (current-error-port) "[] server shutdown"))
		       (exit 1)))
	  ; register http debug interface handlers
	  (register-micro-handler "^/pdb/index.php$" page-debug-main)
	  (register-micro-handler "^/pdb/file-line-break-add.pdb$" page-file-line-break-add)
	  (register-micro-handler "^/pdb/file-line-break-remove.pdb$" page-file-line-break-remove)
	  (register-micro-handler "^/pdb/file-line-break-clearall.pdb$" page-file-line-break-clearall)	  
	  (register-micro-handler "^/pdb/function-break-add.pdb$" page-function-break-add)
	  (register-micro-handler "^/pdb/function-break-remove.pdb$" page-function-break-remove)
	  (register-micro-handler "^/pdb/web-break-add.pdb$" page-web-break-add)
	  (register-micro-handler "^/pdb/web-break-remove.pdb$" page-web-break-remove)
	  (register-micro-handler "^/pdb/scan-root.pdb$" page-scan-root)
	  (register-micro-handler "^/pdb/examine.pdb$" page-examine-script)	  
	  ; go
	  (run-micro-server)))
   )

(define (page-return)
   (let ((ret (php-hash-lookup (container-value $_REQUEST) "ret")))
      (if (not (php-null? ret))
	  (header (mkstr "Location: " ret) #t)
	  (header "Location: /pdb/index.php" #t))))

; breakpoint maintanence
(define (page-file-line-break-add url)
   (let ((script (mkstr *debug-target-webroot* (file-separator)
			(php-hash-lookup (container-value $_REQUEST) "script")))
	 (line (mkfixnum (php-hash-lookup (container-value $_REQUEST) "line")))
	 (ret (php-hash-lookup (container-value $_REQUEST) "ret")))
      (breakpoint-add-file-line script line)
      (page-return)))

(define (page-file-line-break-remove url)
   (let ((script (php-hash-lookup (container-value $_REQUEST) "script"))
	 (line (mkfixnum (php-hash-lookup (container-value $_REQUEST) "line")))
	 (ret (php-hash-lookup (container-value $_REQUEST) "ret")))	 
      (breakpoint-remove-file-line script line)
      (page-return)))      

(define (page-file-line-break-clearall url)
   (let ((script (php-hash-lookup (container-value $_REQUEST) "script"))
	 (ret (php-hash-lookup (container-value $_REQUEST) "ret")))
      (breakpoint-file-clearall script)
      (page-return)))

(define (page-function-break-add url)
   (let ((func (mkstr (php-hash-lookup (container-value $_REQUEST) "func"))))
      (breakpoint-add-function func)
      (page-return)))      

(define (page-function-break-remove url)
   (let ((func (mkstr (php-hash-lookup (container-value $_REQUEST) "func"))))
      (breakpoint-remove-function func)
      (page-return)))      

(define (page-web-break-add url)
   (let ((script (mkstr (php-hash-lookup (container-value $_REQUEST) "script"))))
      (breakpoint-add-web (if (substring-at? script "/" 0)
			      script
			      (mkstr *debug-target-webroot* (file-separator) script)))
      (page-return)))            

(define (page-web-break-remove url)
   (let ((script (mkstr (php-hash-lookup (container-value $_REQUEST) "script"))))
      (breakpoint-remove-web script)
      (page-return)))                  

(define (page-scan-root url)
   (let ((ext (mkstr (php-hash-lookup (container-value $_REQUEST) "ext"))))
      (set! *web-ext-list* (string-split ext ","))
      (scan-project-root)
      (page-return)))                  

; main debug welcome page
(define (page-debug-main url)
   (bind-exit (return)
     
      ; possibly handle GET args
      (when (php-= (php-hash-lookup (container-value $_GET) "exit") *one*)
	 (stop-micro-server)
	 (return "debugger exit"))
   
      (mkstr "<h2>"
	     *RAVEN-VERSION-TAG*
	     "</h2>"
	     "Web Application Debugger<br>Current Web Root: "
	     *debug-target-webroot*
	     "<br><br>"
	     ; PROJECT FILE EXAMINE
	     "<form action=\"/pdb/examine.pdb\" method=\"get\">"
	     (script-select-options)
	     "<input type=\"submit\" value=\"Examine\"></form><br>"
	     ; BREAK ON SCRIPT ENTRY
	     (current-web-break-list)
	     "<form action=\"/pdb/web-break-add.pdb\" method=\"post\">"
	     (script-select-options)
	     "<input type=\"submit\" value=\"Add URL Entry Break\"></form><br>"	     
	     ; BREAK ON FILE/LINE
	     (current-file-line-break-list)
	     "<form action=\"/pdb/file-line-break-add.pdb\" method=\"post\">"
	     (script-select-options)
	     "<input type=\"text\" name=\"line\" size=\"5\">"
	     "<input type=\"submit\" value=\"Add File/Line Break\"></form><br>"
	     ; BREAK ON FUNCTION
	     (current-function-break-list)
	     "<form action=\"/pdb/function-break-add.pdb\" method=\"post\">"
	     "<input type=\"text\" name=\"func\" size=\"20\" maxlength=\"100\">"
	     "<input type=\"submit\" value=\"Add Function Break\"></form><br>"
	     ; PROJECT ROOT SCANNING
	     "Found " (length *web-files*) " project files"
	     "<form action=\"/pdb/scan-root.pdb\" method=\"post\">"
	     "<input type=\"text\" name=\"ext\" size=\"30\" maxlength=\"100\" value=\""
	     (string-join *web-ext-list* ",")
	     "\">"
	     "<input type=\"submit\" value=\"Rescan\"></form><br>"	     
	     ; QUIT
	     "<a href=\"/pdb/index.php?exit=1\">Exit Debugger</a><br>")))


(define (css-style)
   "<style type=\"text/css\">
       .whitespace { font-size: 11px; white-space: pre; font-family: monospace; }
       .string { font-size: 11px; white-space: pre; font-family: monospace; color: #DD0000; }
       .comment { font-size: 11px; white-space: pre; font-family: monospace; font-style: italic; color: #41ba25; }
       .ident { font-size: 11px; font-family: monospace; color: #000000; }
       .var { font-size: 11px; font-family: monospace; color: #000044; }
       .number { font-size: 11px; font-family: monospace; color: #0000EE; }
       .linenumber { font-size: 11px; font-family: monospace; color: #000000; }
    </style>")

5; examine a source file
; print a syntax highlighted version of the source file, with linked line numbers
; allowed breakpoints to be set/unset
(define (page-examine-script url)
   (bind-exit (return)
      (let ((script (file-name-canonicalize (mkstr (php-hash-lookup (container-value $_REQUEST) "script"))))
	    (relscript ""))
	 (if (file-exists? script)
	     (set! relscript (strip-string-prefix *debug-target-webroot* script))
	     (begin
		(set! relscript script)
		(set! script (file-name-canonicalize (mkstr *debug-target-webroot* (file-separator) script)))
		(unless (file-exists? script)
		   (return (mkstr "File not found: " script)))))
	 (let ((lineinfo (debugger-get-lineinfo script))
	       (blist (breakpoint-get-file-line-list))
	       (highlit-source (syntax-highlight-file script 'html)))
	    (with-output-to-string
	       (lambda ()
		  (print "<html>")
		  (print (css-style))
		  (print "<body><b>" script "</b><br>")
		  (when (> (hashtable-size blist) 0)
		     (print "<a href=\"/pdb/file-line-break-clearall.pdb?script="
			    script
			    "\">clear all breakpoints</a>"))
		  (print "<table class=\".code\">")
		  (let loop ((n 1))
		     (when (<= n (hashtable-size highlit-source))
			(let ((is-break? (breakpoint-check-file-line script n)))
			   (print "<tr " (if is-break?
					     "bgcolor=\"red\""
					     "")
				  "><td class=\"linenumber\" bgcolor=\"#eeeeff\" align=\"right\">"
				  "<a name=\"line-" n "\">"
				  (if (member n lineinfo)
				      (mkstr "<a href=\"/pdb/file-line-break-" (if is-break?
										   "remove"
										   "add")
					     ".pdb?script="
					     (cgi-url-encode relscript)
					     "&line="
					     n
					     "&ret=" (cgi-url-encode
						      (mkstr "/pdb/examine.pdb?script="
							     relscript
							     "#line-"
							     (if (< (- n 5) 0)
								 n
								 (- n 5))))
					     "\">" n "</a>")
				      n)
				  "</td><td>"
				  ;(clean-source line)
				  (hashtable-get highlit-source n)
				  "</td></tr>")
			   (loop (+ n 1)))))
		  (print "</table></body></html>")))))))


; select list of files in web root
(define (script-select-options)
   (with-output-to-string
      (lambda ()
	 (print "<select name=\"script\">")	 
	 (for-each (lambda (v)
		      (print "<option value=\"" v "\">" v "</option>"))
		   *web-files*)
	 (print "</select>"))))

; current list of break points
(define (current-file-line-break-list)
   (let ((blist (breakpoint-get-file-line-list))
	 (nl (if *web-debugger?* "<br>\n" "\n")))
      (if (or (not (hashtable? blist))
	      (= (hashtable-size blist) 0))
	  "No current file/line breakpoints"
	  (begin
	     (mkstr "Current file/line breakpoints: " nl
		    (with-output-to-string
		       (lambda ()
			  (hashtable-for-each blist
                             (lambda (k v)
				(multiple-value-bind (file line ok?)
				   (breakpoint-file-and-line k)
				   (when ok?
				      (if *web-debugger?*
					  (print k
						 (mkstr " (<a href=\"/pdb/file-line-break-remove.pdb?script="
							(cgi-url-encode file)
							"&line="
							line
							"\">remove</a>)" nl))
					  (print k)))))))))))))
								     
; function breaks
(define (current-function-break-list)
   (let ((blist (breakpoint-get-function-list))
	 (nl (if *web-debugger?* "<br>\n" "\n")))	 
      (if (or (not (hashtable? blist))
	      (= (hashtable-size blist) 0))
	  "No current function breakpoints"
	  (begin
	     (mkstr "Current function breakpoints: " nl
		    (with-output-to-string
		       (lambda ()
			  (hashtable-for-each blist
                             (lambda (k v)
				(if *web-debugger?*
				    (print k
					   (mkstr " (<a href=\"/pdb/function-break-remove.pdb?func="
						  (cgi-url-encode k)
						  "\">remove</a>)<br>"))
				    (print k)))))))))))

; function breaks
(define (current-web-break-list)
   (let ((blist (breakpoint-get-web-list))
	 (nl (if *web-debugger?* "<br>\n" "\n")))
      (if (or (not (hashtable? blist))
	      (= (hashtable-size blist) 0))
	  "No current URL entry breakpoints"
	  (begin
	     (mkstr "Current URL entry breakpoints: " nl
		    (with-output-to-string
		       (lambda ()
			  (hashtable-for-each blist
                             (lambda (k v)
				(if *web-debugger?*
				    (print k
					   (mkstr " (<a href=\"/pdb/web-break-remove.pdb?script="
						  (cgi-url-encode k)
						  "\">remove</a>)" nl))
				    (print k)))))))))))
				


; commandline usage header
(define (usage-header)
   (format "~a: Step Debugger\n~a\n~a\n"
	   *RAVEN-VERSION-TAG*
	   "Usage: pdb [options] <target file or webroot directory> [-- script args]"
	   "see pdb -h for help with command line options"))

(define (breakpoint-file-line-event file line)
   (unless *slavemode*
      (debug-print "breakpoint reached at " file " line " line)))
    
(define (breakpoint-function-event function)
   (unless *slavemode*
      (debug-print "function breakpoint reached: " function)))

(define (breakpoint-web-event script)
   (unless *slavemode*
      (debug-print "URL breakpoint reached: " script)))

; find all source files in the web root, by matching against
; the extensions in *web-ext-list*
(define (scan-project-root)
   (let ((flist '()))
      (let loop ((level ""))
	 ;(debug-trace 1 "loop: level is " level)
	 (let* ((level-path (mkstr *debug-target-webroot*
				   (file-separator)
				   (if (string=? level "")
				       ""
				       (mkstr level (file-separator)))))
		(level-list (directory->list level-path)))
	    ;(debug-trace 1 "level-path is " level-path)
	    (map (lambda (v)
		    ;(debug-trace 1 "looking at " v)
		    (if (and (directory? (mkstr level-path v))
			     (not (member v *web-scan-skip-dirs*)))
			(loop (mkstr level (file-separator) v))
			(when (member (suffix v) *web-ext-list*)
			   (set! flist (cons (mkstr (if (string=? level "")
							""
							(mkstr level (file-separator))) v) flist)))))
		 level-list)))
      (set! *web-files* (sort flist string<?))))

(define (get-hl-source-at-file-line file line)
   (let ((line (debugger-get-source-at-file-line file line)))
      (if *syntax-highlight*
	  (syntax-highlight-line line 'ansi)
	  line)))

(define (pdb-prompt-display)
   (cond-expand (HAVE_LIBREADLINE #f)
		(else
		 (display "\n(pdb) "
			  (if *web-debugger?*
			      (current-error-port)
			      (current-output-port))))))

(define (pdb-readline)
   (cond-expand (HAVE_LIBREADLINE
		 (readline "(pdb) "))
		(else
		 (read-line))))

;;;## Command Definitions

;;; The function `debugger-repl' defines all of the commands that the
;;; debugger will accept.  Say (loop) to prevent moving to the next
;;; node on the AST.
;; k is either #f or the kontinuation for the redo command
(define (debugger-repl node #!optional k)
;   (dump-bigloo-stack (current-error-port) 10)
   (cond-expand (HAVE_LIBREADLINE (history-init)))
   (let loop ()
      (if *slavemode*
	  (debug-print "Location: " *debugger-file* ":" *debugger-line*)
	  (begin
	     ; location, including source at line
	     (when *debugger-file*
		(fprint (if *web-debugger?*
			    (current-error-port)
			    (current-output-port))
			#\newline *debugger-file* #\newline *debugger-line* #\tab
			(get-hl-source-at-file-line *debugger-file* *debugger-line*)))
	     ; prompt
	     (pdb-prompt-display)))
      (flush-output-port (current-output-port))
      (flush-output-port (current-error-port))
      (let ((command (pdb-readline)))
	 (when (eof-object? command)
	    (print)
	    (exit 0))
	 (cond-expand (HAVE_LIBREADLINE (history-add command)))
	 (string-case command
;;; The all important help command.
	    ((or "h" "help")
	     (debug-print "Most commands can be abbreviated.  When single-stepping,")
	     (debug-print "hitting enter is the same as the command 's', or 'step'.")
	     (debug-print "Commands available: ")
	     (debug-print "help, quit, step, next, continue, reset, backtrace, list,")
	     (debug-print "$<var>, break <function|file:line>, clear <function>, trace,")
	     (debug-print "clearall, locals, show breaks")
	     (loop))
	    
;;;### Secret Internal Commands

;;; lineinfo takes a filename and prints a list of lines
	    ((eof (: "lineinfo" blank (+ all)))
	     (debug-print (debugger-get-lineinfo (pregexp-replace "^lineinfo\\s+" (the-string) "")))
	     (loop))
	    
	    ((eof "slavemode")
	     (set! *slavemode* #t)
	     (loop))
	    
;;;### Public Commands
	    
;;; This is the quit command. 
	    ((eof (or "q" "quit" "exit"))
	     (debug-print "\nbye")
	     (exit 0))
;;; `step' will single-step until reaching a different line, which has
;;; the effect of stepping "into" functions, which will necessarily be
;;; defined someplace different from where they are called.  Step will
;;; start the program if it is not running.
	    ((eof (or "s" "step"))
	     (set! *debugger-stepping?* #t)
	     ;; start if not running
	     (unless  *program-restart*
		(debugger-run node))
	     #t)
;;; The `next' command steps until a sourcecode line greater than the
;;; current line is reached.  This will often have the effect of
;;; stepping over functions, unless they're later in the same file, I
;;; guess.  XXX that's probably a bug.  `next' will start the program
;;; if it is not running.
	    ((eof (or "n" "next"))
	     (set! *debugger-stepping?* 'next)
	     ;; start if not running
	     (unless  *program-restart*
		(debugger-run node))
	     #t)
;;; If the program has been stopped due to stepping or a breakpoint,
;;; then start it right where it was stopped.
	    ((eof (or "c" "cont" "continue"))
	     (if *program-restart*
		 (begin
		    (set! *debugger-stepping?* #f)
		    #t)
		 (debug-error
		  "Program is not running.  Use one of `run', `step', or `next' start it"))
	     #t)
;;; The `run' command will start the program from the beginning.  If
;;; the program is already running, the user is prompted to make sure
;;; he meant to restart it.
	    ((eof (or "r" "run"))
	     (set! *debugger-stepping?* #f)
	     (if *program-restart*
		 (if (or *slavemode*
			 (y-or-n-p "Program is already running.  Restart it? "))
		     (begin
			(set! *debugger-stepping?* #f)
			(*program-restart* #t))
		     (loop))
		 (debugger-run node))
	     #f)
;;; The `reset' command will reset the program state
	    ((eof (or "res" "reset"))
	     (debugger-reset)
	     (when *program-restart*
		   (*program-restart* #f)))
;;; The `backtrace' command prints the current PHP call stack.  Note
;;; that code which is compiled in -O (unsafe) mode will not maintain
;;; stack traces, so backtrace won't be as useful.
	    ((eof (or "bt" "backtrace"))
	     (for-each (lambda (a)
			  (debug-print (stack-entry-file a) ":"
				 (stack-entry-line a) ": "
				 (stack-entry-function a) "()"))
;				 (string-join
;				  (map mkstr (stack-entry-args a))
;				  ", ")))
		       *stack-trace*)
	     (loop))
;;; The `list' command shows the 10 lines around the current line.
           ((eof (or "l" "li" "list"))
	     (if (not *debugger-file*)
		 (debug-error
		  "Program is not running.  Use one of `run', `step', or `next' start it")
		 (let loop ((i (min 0 (- *debugger-line* 5))))
		    (when (< i (+ *debugger-line* 5))
		       (if (= i *debugger-line*)
			   (display "-> ")
			   (display "   "))
		       (debug-print (get-hl-source-at-file-line *debugger-file* i))
		       (loop (+ i 1)))))
	     (loop))
;;; Entering a variable's name (including the $) will print the
;;; variable's value.
	    ((: #\$ (or alpha "_") (* (or alnum "_")))
	     (if (env? *current-env*)
		 ;; env-lookup would create the value if it doesn't exist
		 (let ((name (substring (the-string) 1 (the-length))))
		    (if (php-hash-contains? (env-bindings *current-env*) name)
			(debug-dump (maybe-unbox (env-lookup *current-env* name)))
			(if *slavemode*
			    (debug-print "<unset>")
			    (debug-warn "Variable is not set."))))
		 (debug-error "No variables currently available."))
	     (loop))
;;; Dump an object property.
	    ((: #\$ (or alpha "_") (* (or alnum "_")) "->" (or alpha "_") (* (or alnum "_")))
	     (if (not (env? *current-env*))
		 (debug-error "No variables currently available.")
		 (multiple-value-bind (object-variable property)
		       (apply values (pregexp-split "->" (the-string)))
		    (let ((object-name (substring object-variable 1 (string-length object-variable))))
		       (if (php-hash-contains? (env-bindings *current-env*) object-name)
			   (let ((object (maybe-unbox (env-lookup *current-env* object-name))))
			      (if (php-object? object)
				  (debug-dump (php-object-property object property 'all))
				  (if *slavemode*				      
				      (debug-print "<unset>")
				      (debug-warn object-variable " is not an object."))))
			   (if *slavemode*			       
			       (debug-print "<unset>")
			       (debug-warn "Variable is not set."))))))
	     (loop))
;;; Display a list of all local variables.
	    ((eof (or "lo" "local" "locals"))
	     (if (env? *current-env*)
		 (let ((h (env-php-hash-view *current-env*)))
		    (if *slavemode*
			(php-hash-for-each h
					   (lambda (k v)
					     ;; filter the superglobals
					     (unless (member k '("_ENV" "_FILES" "_COOKIE" "_SESSION" "_POST"
								 "_GET" "_REQUEST" "GLOBALS" "_SERVER"))
						     (debug-print "VAR:" k)
						     (debug-dump (maybe-unbox (env-lookup *current-env* k)))))) 
			(let ((locals '()))
			  (debug-print "Local Variables:")
			  (php-hash-for-each h
					     (lambda (k v)
					       ;; filter the superglobals
					       (unless (member k '("_ENV" "_FILES" "_COOKIE" "_SESSION" "_POST"
								   "_GET" "_REQUEST" "GLOBALS" "_SERVER"))
						       (pushf (mkstr "$" k) locals))))
			  (debug-print (string-join locals ", ")))))
		 (debug-error "No variables currently available."))
	     (loop))

;;; Turn tracing on or off
	    ("trace"
	     (set! *debugger-tracing?* (not *debugger-tracing?*))
	     (if *debugger-tracing?*
		 (debug-print "Tracing enabled")
		 (debug-print "Tracing disabled"))
	     (loop))


;;; Show current breakpoint lists
            ((eof (or "sh" "show" "show break" "show breaks"))
	     (debug-print (current-file-line-break-list))
	     (debug-print (current-function-break-list))
	     (debug-print (current-web-break-list))
	     (loop))
	    
;;; Break sets a breakpoint.  The argument is the name of a function.
;;; The function must be currently defined.
	    ((: "break" (+ blank) 
			(or alpha "_") (* (or alnum "_")))
	     (let ((function-name (pregexp-replace "^break\\s+" (the-string) "")))
                (breakpoint-add-function function-name))
	     (loop))
;;; Break can also take a numeric argument, in which case it's a line
;;; number.
	    ((: "break" (+ blank) (+ digit))
	     (if *debugger-file*
		 (breakpoint-add-file-line *debugger-file*
					   (the-substring 5 (the-length)))
		 (debug-error "Not debugging any particular file yet."))
	     (loop))
;;; Or a file:line argument.
            ((: "break" (+ blank) (+ all))
             (multiple-value-bind (file line ok?)
                 (breakpoint-file-and-line (pregexp-replace "^break\\s+" (the-string) ""))
                (if ok?
                    (breakpoint-add-file-line file line)
                    (debug-error "Malformed breakpoint -- file " file ", line " (mkstr line)))
                (loop)))
	    
;;; Clear unsets a breakpoint.  The argument should be the same
;;; function name as was originally given to the break command.
	    ((: "clear" (+ blank) 
			(or alpha "_") (* (or alnum "_")))
	     (let ((function-name (pregexp-replace "clear\\s+" (the-string) "")))
		(when (not (breakpoint-remove-function function-name))
		   (debug-error "No such breakpoint was set.")))
	     (loop))
;;; Clear line number breakpoint.
	    ((: "clear" (+ blank) (+ digit))
	     (breakpoint-remove-file-line *debugger-file* (the-substring 5 (the-length)))
	     (loop))
;;; Or a file:line argument.
	    ((: "clear" (+ blank) (+ all))
             (multiple-value-bind (file line ok?)
                   (breakpoint-file-and-line (pregexp-replace "^clear\\s+" (the-string) ""))
                (if ok?
                    (breakpoint-remove-file-line file line)
                    (debug-error "Malformed breakpoint -- file " file ", line " (mkstr line)))
                (loop)))
;;; Clearall clears all breakpoints.
	    ("clearall"
	     (breakpoint-clear-all)
	     (unless *slavemode*
	     	(debug-print "All breakpoints have been cleared."))
	     (loop))
;;; Eval will evaluate PHP code at the current spot in the ast
            ((: (or "e" "ev" "eval") (+ blank) (+ all))
             (dynamically-bind (*debugging?* #f)
                (try (php-funcall 'eval (pregexp-replace "^e((v)?al)?\\s+" (the-string) ""))
                     (lambda (e p m o)			   
                        (debug-error (mkstr "Eval error: " m))
                        (e 'eval-error))))
             (loop))
;;; Redo will try to re-evaluate the current node, say after an error or something            
            ((: (or "red" "redo"))
             (if k
                 (k)
                 (debug-error "Nothing to redo.")))
            
	    (else 		   
;;; The "default command" is to just continue evaluating.
	     (if (and (string=? command "") *debugger-stepping?* *program-restart*)
		 #t
		 (begin
		    (unless (string=? command "")
		       (debug-error "Unknown command: " command))
		    (loop))))))))

;;; The `debugger-run' function is the part of the `run' command that
;;; is common to `next', `step', and `run'.
(define (debugger-run node)
   (let loop ((flag #t))
      (when flag
	 (loop
	  (bind-exit (restart)
	     (debugger-reset)
	     (dynamically-bind (*program-restart* restart)
		(if (not (php-ast? node))
		   ;(error 'debug-repl "not a php-ast" node))
		    (begin
		       (unless *slavemode*
			  (debug-print "Program is not loaded.  Attempting to reload."))
		       #f)
		    (begin
		       (unless *slavemode*
			  (debug-print "Starting program: " (php-ast-original-filename node)))
		       (evaluate node)
		       (set! *debugger-line* -1)
		       (set! *debugger-file* #f)
		       (unless *slavemode*
			  (debug-print "Program exited normally."))
		       #f)))
	     ))))
   ; continue script from begin after it ends? (not in web mode)
   (not *web-debugger?*)
   )

;;; The function `debug-print' is used for all debugger (non program)
;;; output. It goes to stdout unless we're in slavemode, then it's stderr.
(define (debug-print . rest)
  (if (or *slavemode* *web-debugger?*)
      (begin
	 (apply fprint (current-error-port) rest)
	 (flush-output-port (current-error-port)))
      (begin
	 (apply print rest)
	 (flush-output-port (current-output-port)))))

;;; The function `debug-warn' will issue a warning at the debugger
;;; prompt. It goes to stdout unless we're in slavemode, then it's stderr.
(define (debug-warn . rest)
  (if (or *slavemode* *web-debugger?*)
      (begin
	 (apply fprint (current-error-port) "Warning: " rest)
	 (flush-output-port (current-error-port)))
      (begin
	 (apply print "Warning: " rest)
	 (flush-output-port (current-output-port)))))

;;; The function `debug-error' will issue an error at the debugger
;;; prompt. It goes to stdout unless we're in slavemode, then it's stderr.
(define (debug-error . rest)
  (if (or *slavemode* *web-debugger?*)
      (begin
	 (apply fprint (current-error-port) "Error: " rest)
	 (flush-output-port (current-error-port)))
      (begin
	 (apply print "Error: " rest)
	 (flush-output-port (current-output-port)))))	 

;;; This function prints a string with a max length so we don't spew too much
(define (debug-short-string str)
  (let* ((max-string-length 70)
	 (new-str (mkstr (substring str 0 (min max-string-length (string-length str)))
			 (if (> (string-length str) max-string-length)
			     "..."
			     ""))))
    new-str))

;;; The function `debug-dump' will print PHP data (strings, objects,
;;; etc.) in a nice human-readable form.
(define (debug-dump phpobj)
      (cond
	 ((php-object? phpobj) (begin 
				 (debug-print "Object (" (php-object-class phpobj) "):")
				 (debug-hash-dump (php-object-props phpobj))))

;				      "): " (php-hash-size (php-object-props phpobj))
;				      " properties."))
; 	 ((php-hash? phpobj) (debug-print "Array: "
; 				    (php-hash-size phpobj) " items"))
	 ((php-hash? phpobj) (begin 
			       (debug-print (mkstr "Array (" (php-hash-size phpobj) "):"))
			       (debug-hash-dump phpobj)))
	 ((string? phpobj) (debug-print "String (" (string-length phpobj) ") "
				  "\""
				  (debug-short-string phpobj)
				  "\""))
	 ((null? phpobj) (debug-print "NULL"))
	 ((eqv? phpobj TRUE) (debug-print "TRUE"))
	 ((eqv? phpobj FALSE) (debug-print "FALSE"))
	 (else (debug-print (mkstr phpobj)))))

; very basic dump of a hash
(define (debug-hash-dump hash)
  (bind-exit (exit)
    (let ((max-loops 15)
	  (cur-loop 0))
      (php-hash-for-each hash (lambda (k v)
				(set! cur-loop (+ cur-loop 1))
				(when (> cur-loop max-loops)
				      (debug-print (mkstr "... " 
							  (- (php-hash-size hash) cur-loop)
							  " more entries"))			       
				      (exit #t))
				(debug-print (mkstr k) 
					     " => " 
					   (cond
					    ((php-object? v) (mkstr "Object (" (php-object-class v) ")"))
					    ((php-hash? v) (mkstr "Array (" (php-hash-size v) " items)"))
					    ((string? v) (mkstr "String (" (string-length v) ") "
									   "\""
									   (debug-short-string v)
									   "\""))
					    ((null? v) (mkstr "NULL"))
					    ((eqv? v TRUE) (mkstr "TRUE"))
					    ((eqv? v FALSE) (mkstr "FALSE"))
					    (else (mkstr v)))
					   ))))))

;;; The inspector lets you examine PHP data in depth.
(define (inspect phpobj . prev)
   (let ((window-size 10)
	 (window-offset 0))
      (let loop ()
	 (display "\n(inspect) ")
	 (let ((command (read-line)))
	    (string-case command
	       ;; empty command, just redisplay
	       ((* blank)
		(display-segment phpobj window-offset window-size)
		(loop))
	       ((or "?" "h" "help")
		(print "Commands available: ")
		(print "help, quit (back to pdb prompt), next, prev, (show next or previous segment),")
		(print "<number> (inspect a field recursively), back (inspect previous object)"))
	       ;; if they enter a number, inspect recursively
	       ((+ digit)
		(multiple-value-bind (entry exists?)
		      (fetch-entry (+ window-offset (string->integer command)))
		   (if exists?
		       (inspect entry (cons phpobj prev))
		       (begin
			  (debug-warn "No field numbered " (string->integer command))
			  (loop)))))
	       ;; `back' means to visit the last thing we inspected
	       ((or "b" "back")
		(if (pair? prev)
		    (inspect (car prev) (cdr prev))
		    (begin
		       (debug-warn "Can't go back any further.")
		       (loop))))
	       ((or "q" "quit")
		(print "*wave*"))
	       (else
		(debug-error "Unknown command: " (the-string)

	       )))))))





(define (display-segment obj offset size)
   (print "segment"))

(define (fetch-entry offset)
   "foo")


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


;;;# Introduction: A PHP Debugger

;;; This is an interactive debugger for PHP programs. It implements
;;; single-stepping, setting breakpoints, and inspecting values.

;;;## Overview

;;; The evaluator in evaluate.scm calls the debug-hook function
;;; defined here before evaluating each AST node.  It passes the node
;;; to be evaluated and a thunk that will do the actual evaluation.
;;; This allows us to stop evaluation at any time, as well as perform
;;; actions before and after evaluating a node.


;;;# Module Prologue
(module debugger
   (include "php-runtime.sch")
   (library php-runtime)
   (import
    ;; ast.scm and declare.scm define the AST node types.
    (ast "ast.scm")
    (declare "declare.scm")
    ;; evaluate.scm provides the evaluator, which the debugger calls
    ;; to implement its `run' command.
    (evaluate "evaluate.scm")
    ;; driver.scm gives us input-file->ast, which is used to implement
    ;; the `lineinfo' command.
    (driver "driver.scm"))

   (export
    ;; debugger-start is the main entry point to the debugger.  It
    ;; should be called where evaluate would be called, if we were
    ;; interpreting the file normally.
    (debugger-start filename)
    (debugger-reset)

    (debugger-get-lineinfo filename)
    
    (debugger-get-source-at-file-line file line)

    ;; the repl
    *debugger-repl*
    ;; the runner
    *debugger-run*

    ;; various debugger exports
    *debugger-file*
    *debugger-line*
    *program-restart*
    *debugger-stepping?*
    *debugger-tracing?*
    
    ;; breakpoint API
    *breakpoint-file-line-event*
    *breakpoint-function-event*
    *breakpoint-web-event*
    (breakpoint-clear-all)
    (breakpoint-file-and-line match)
    ; file/line
    (breakpoint-get-file-line-list)
    (breakpoint-add-file-line file line)
    (breakpoint-remove-file-line file line)
    (breakpoint-check-file-line file line)
    (breakpoint-file-clearall file)    
    ; function
    (breakpoint-get-function-list)    
    (breakpoint-add-function name)
    (breakpoint-remove-function name)
    ; web scripts
    (breakpoint-get-web-list)    
    (breakpoint-add-web name)
    (breakpoint-remove-web name)
    
    ;; recursive-debugger-start is like debugger-start, but should be
    ;; called if we are already debugging.
;    (recursive-debugger-start php-ast)
    ;; *debugging?* will be #f unless we are currently debugging.  Use
    ;; it to decide whether to call recursive-debugger-start.
    *debugging?*
    ;; *web-debugger?* will be #t when we are using microserver to debug
    ;; a web application
    *web-debugger?*
    ;; The evaluator must call debug-hook if *debugging?* is true.
    (generic debug-hook node k)
    (pcc-ctrl-handler::int ctrl-type::int ))
   
   (extern
    (include "debugger.h")
    (export pcc-ctrl-handler "PccCtrlHandler")))

;;;# Main Entrypoints

;;; The `debugger-start' function starts the debugger for the first
;;; time.  It binds `*debugging?*' to #t, and prompts the user.
;;; It also saves the argument environment so it can restore upon reset
(define (debugger-start filename)
   ;; setting *debugging?* to true causes the evaluator to call the debug-hook
   ;   (signal 2 (lambda (arg)
   ;		(set! *debugger-stepping?* #t)))
   (save-arg-env)
   (register-signal-handler)
   ;(when *web-debugger?*
    ;  (debug-print "entry point for URL request: " filename))
   (dynamically-bind (*debugging?* #t) 
      ;      (try 
      (let loop ((flag #t))
	 (when flag
	    ;; since we re-read a file here, we have to make sure the
	    ;; cache gets reset.
	    (reset-file-line-cache)
	    (let ((php-ast
		   (try (input-file->ast filename #t)
			(lambda (e p m o)			   
			   (debug-error (mkstr "start: " m))
			   (e 'not-an-ast)))))
	       (loop (if *web-debugger?*
			 ; if it's a web breakpoint, start the repl
			 ; otherwise if it's a web page we default to evaluting it 
			 (if (breakpoint-check-web filename)
			     (begin
				(*breakpoint-web-event* filename)
				(*debugger-repl* php-ast)
				#f) ; don't restart after this page
			     (*debugger-run* php-ast))
			 ; console program default to starting in the repl
			 (*debugger-repl* php-ast))))))
      ;       (lambda (e p m o)
      ;	  (debug-error m)
      ;	  (e #t)))
      )
   (reset-debug-evaluator-state)
   (unless *web-debugger?*
      (debugger-start filename)))

(define (debugger-reset)
   (reset-debug-evaluator-state)
   (set! *debugger-line* -1)
   (set! *debugger-file* #f))

;;; The `recursive-debugger-start' function will re-enter the debugger
;;; once it is already running. This comes up, for example, when
;;; including a file.
; (define (recursive-debugger-start php-ast)
;    (evaluate php-ast))

;;;# Global State

;;; The variable `*debugging?*' will be #t whenever we are debugging.
(define *debugging?* #f)

;;; True when debugging a web application through microserver
(define *web-debugger?* #f)

;;; The repl function
(define *debugger-repl* #f)
;;; The run function
(define *debugger-run* #f)

;;; The variables `*debugger-line*' and `*debugger-file*' represent
;;; the location of the code that the debugger is currently examining.
(define *debugger-line* -1)
(define *debugger-file* #f)

;;; The variable `*debugger-stepping*' can be `#t', `#f', or the
;;; symbol `next'... or the symbol `break'.  Huh.  If it is `#t', the
;;; debugger will prompt the user whenever the current line
;;; changes. If it is set to the symbol `next', the debugger will only
;;; prompt the user if it reaches a line past the current line and
;;; also in the current file.
(define *debugger-stepping?* #f)

(define *debugger-tracing?* #f)

; a function that is run when a breakpoint is reached
; actually set in pdb
(define *breakpoint-file-line-event* #f)
(define *breakpoint-function-event* #f)
(define *breakpoint-web-event* #f)

;;; We need to restore the arguments to the program, including
;;; any GET/POST arguments each time the debugger state is reset
(define *original-foo* (make-hashtable))
; (define *original-argv* (make-php-hash))
; (define *original-argc* #f)
; (define *original-POST* (make-php-hash))
; (define *original-GET* (make-php-hash))
; (define *original-SERVER* (make-php-hash))
; (define *original-COOKIE* (make-php-hash))
; (define *original-REQUEST* (make-php-hash))

;;; save the argument environment (program args, GET/POST, etc)
(define (save-arg-env)
   (for-each (lambda (v)
                (hashtable-put! *original-foo* v
                                (copy-php-data (env-lookup *global-env* v))))
             '("_GET" "_POST"
               "_COOKIE" "_REQUEST" "argv" "argc")))
   
;;; restore the argument environment (program args, GET/POST etc) after an evaluator reset
(define (restore-arg-env)
   (for-each (lambda (v)
                (env-extend *global-env* v (hashtable-get *original-foo* v)))
             '("_GET" "_POST"
               "_COOKIE" "_REQUEST" "argv" "argc")))

(define *program-restart* #f)

;;; We use this function to reset the world when restarting a program.
(define (reset-debug-evaluator-state)
   (reset-evaluator-state)
   (reset-runtime-state)
   (restore-arg-env))



;;;# The Debug Hook

;;; The `debug-hook' gives the debugger a chance to do something
;;; before a node is evaluated.  `node' should be the AST node that is
;;; about to be evaluated, and `k' should be a closure that will
;;; perform the evaluation.  `node' can also be a list, in which case
;;; we call `k' immediately.

;;; The `debug-hook' is implemented as generic function, specialized
;;; on AST node types.  The default behavior is to just call the
;;; kontinuation thunk.
(define-generic (debug-hook node k)
   ;; we don't call continue here because "node" is probably a list of
   ;; nodes.
   (k))

(define-method (debug-hook node::ast-node k)
   (with-access::ast-node node (location)
      (let ((line (car location))
	    (file (cdr location)))
	 (when (breakpoint-check-file-line file line)
	    ;(debug-print "\nbreakpoint reached: " file ":" line)
	    (*breakpoint-file-line-event* file line)
	    (set! *debugger-stepping?* #t))
	 (when (prompt-here? location)
	    (debugger-prompt node))))
   (continue node k))


(define-method (debug-hook node::function-invoke k)
   (debug-trace 3 "in function-invoke, debug-stepping "
		*debugger-stepping?* ", file " *debugger-file* " on line " *debugger-line*)
   (with-access::function-invoke node (name location)
      (debugger-trace name location)
      (cond
	 ;; give breakpoints first priority
	 ((breakpoint-check-function name)
	  ;(debug-print "\nbreakpoint reached: " name)
	  (*breakpoint-function-event* name)	  
	  (set! *debugger-stepping?* #t)
          (debugger-prompt node)
	  (call-next-method))
	 ;; make sure to step over function invocations when the user
	 ;; has hit `next'
	 
	 (*debugger-stepping?*
	  ;(and (eqv? 'next *debugger-stepping?*)
	  ;	       *debugger-file*)
	  
	  (when (prompt-here? location)
	     (debugger-prompt node))
	  (if (eqv? 'next *debugger-stepping?*)
	      (dynamically-bind (*debugger-stepping?* #f)
		 (continue node k))
	      (continue node k)))
	 ; 	  (dynamically-bind (*debugger-stepping?* #f)
	 ; 	     (continue node k)))
	 ;; nothing to see here, move along
	 (else (call-next-method)))))

(define-method (debug-hook node::method-invoke k)
   (debug-trace 3 "in method-invoke, debug-stepping "
		*debugger-stepping?* ", file " *debugger-file* " on line " *debugger-line*)
   (with-access::method-invoke node (method location)
      (debugger-trace (if (property-fetch? method)
			  (if (literal-string? (property-fetch-prop method))
			      (literal-string-value (property-fetch-prop method))
			      (property-fetch-prop method))
			  "unknown")
		      location)
      (cond
	 (*debugger-stepping?*
	  (when (prompt-here? location)
	     (debugger-prompt node))
	  (if (eqv? 'next *debugger-stepping?*)
	      (dynamically-bind (*debugger-stepping?* #f)
		 (set-debugger-loc location))
	      (continue node k)))
	 (else (call-next-method)))))

(define-method (debug-hook node::static-method-invoke k)
   (with-access::static-method-invoke node (class-name method location)
      (debugger-trace (mkstr class-name "::"
			     (if (lyteral? method)
				 (lyteral-value method)
				 "unknown"))
		      location)
      (cond
	 (*debugger-stepping?*
	  (when (prompt-here? location)
	     (debugger-prompt node))
	  (if (eqv? 'next *debugger-stepping?*)
	      (dynamically-bind (*debugger-stepping?* #f)
		 (continue node k))
	      (continue node k)))
	 (else (call-next-method)))))

(define-method (debug-hook node::constructor-invoke k)
   (with-access::constructor-invoke node (class-name location)
      (debugger-trace class-name location)
      (cond
	 (*debugger-stepping?*
	  (when (prompt-here? location)
	     (debugger-prompt node))
	  (if (eqv? 'next *debugger-stepping?*)
	      (dynamically-bind (*debugger-stepping?* #f)
		 (continue node k))
	      (continue node k)))
	 (else (call-next-method)))))


(define-method (debug-hook node::function-decl k)
  (continue node k))

(define-method (debug-hook node::method-decl k)
  (continue node k))

(define-method (debug-hook node::property-decl k)
  (continue node k))

(define-method (debug-hook node::class-decl k)
   (dynamically-bind (*debugger-stepping?* #f)
      (continue node k)))

(define (continue node k)
   (when (eqv? *debugger-stepping?* 'break)
      ;; this is your friendly neighborhood break handler calling
      (set! *debugger-stepping?* #t)
      (debugger-prompt node))
   (begin0
    (try (k)
	 (lambda (e p m o)
	    ;; this stops us right at the node we left off at
	    ;; (set! *debugger-stepping?* #t)
	    (unless (or (eqv? p 'php-exit)
			(eqv? o 'php-exit))
	       (debug-error m)
	       (debugger-prompt node (lambda () (continue node k))))
	    (e NULL)))
    (set-debugger-loc (ast-node-location node))))

(define (set-debugger-loc location)
   (set! *debugger-line* (loc-line location))
   (set! *debugger-file* (loc-file location)))

(define (debugger-trace name location)
   (when *debugger-tracing?*
      (let ((line (car location))
	    (file (cdr location)))
	 (fprint (current-error-port) "[TRACE] "file ":" line " -- "
                 (if (ast-node? name)
                     (ast-node->brief-string name)
                     name)))))

(define (prompt-here? location)
   ;;; basically, check if the debugger has completed a "step"
   (let ((line (loc-line location))
	 (file (loc-file location)))
      (and *debugger-stepping?*
	   (not (= line *debugger-line*))
	   ;; If we're stepping to 'next, then we want the
	   ;; next line of code in the same file, but not
	   ;; e.g. inside of the function we just called.
	   (not (and (eqv? 'next *debugger-stepping?*)
		     (equal? *debugger-file* file)
		     (<= line *debugger-line*))))))



;;;# The Prompt

(define (debugger-prompt node::ast-node #!optional k)
   (with-access::ast-node node (location)
      (set-debugger-loc location)
      ;(let ((line (car location))
      ;	    (file (cdr location)))
      (*debugger-repl* node k)))


;;; `print-lineinfo' returns a list of linenumbers which represents the
;;; lines in a file that it would be meaningful to set a breakpoint
;;; on.  This is the implementation of the private command `lineinfo'.
(define (debugger-get-lineinfo filename)
   "Return the lines that the debugger could potentially break on."
   (try 
    (let ((ast-nodes (input-file->ast filename #t)))
      (let ((lines (make-hashtable)))
	(walk-ast ast-nodes (lambda (node k)
			      (when (ast-node? node)
				    (unless (or (declaration? node)
						(formal-param? node)
						(php-constant? node)
						(lyteral? node))
					    (hashtable-put! lines (car (ast-node-location node)) #t)))
			      (unless (or (formal-param? node)
					  (constant-decl? node)
					  (property-decl? node))
				      (k))))
	(sort (hashtable-key-list lines) <)))
    (lambda (e p m o)
       (debug-error m)
       (e 'not-an-ast))))

;;; The function `debug-error' will issue an error at the debugger
;;; prompt. It goes to stdout unless we're in slavemode, then it's stderr.
(define (debug-error . rest)
   (apply fprint (current-error-port) "Error: " rest)
   (flush-output-port (current-error-port)))

;;;# Breakpoints

;;; The hashtable `*breakpoints*' contains the function names that the
;;; debugger will currently break on.  It is not reset when the
;;; debugger is reset, so it will survive a restart of the program we
;;; are debugging.
(define *breakpoints* (make-hashtable))
(define *web-breakpoints* (make-hashtable))
(define *file-line-breakpoints* (make-hashtable))

(define (breakpoint-clear-all)
   (set! *breakpoints* (make-hashtable))
   (set! *web-breakpoints* (make-hashtable))
   (set! *file-line-breakpoints* (make-hashtable)))

(define (breakpoint-add-function name)
   (hashtable-put! *breakpoints* (mkstr name) #t))

(define (breakpoint-check-function name)
   (hashtable-get *breakpoints*
		  (string-downcase (mkstr name))))

(define (breakpoint-remove-function name)
   (let ((filename (util-realpath name)))
      (hashtable-remove! *breakpoints* filename)))

(define (breakpoint-add-web name)
   (let ((filename (util-realpath name)))
      (hashtable-put! *web-breakpoints* filename #t)))

(define (breakpoint-check-web name)
   (hashtable-get *web-breakpoints*
		  (mkstr name)))

(define (breakpoint-remove-web name)
   (hashtable-remove! *web-breakpoints* (mkstr name)))

(define (breakpoint-get-file-line-list)
   *file-line-breakpoints*)

(define (breakpoint-get-function-list)
   *breakpoints*)

(define (breakpoint-get-web-list)
   *web-breakpoints*)

(define (breakpoint-add-file-line file line)
   (let ((filename (util-realpath file)))
      (if (not (file-exists? filename))
	  (debug-error "File " filename " not found.")
	  (begin
;	     (print "adding breakpoint :" (mkstr  ":" line))
	     (hashtable-put! *file-line-breakpoints*
			     (mkstr (util-realpath file) ":" line)
			     #t)))))

(define (breakpoint-remove-file-line file line)
   (let ((breakpoint-name (mkstr (util-realpath file) ":" line)))
      (if (hashtable-get *file-line-breakpoints*
			 breakpoint-name)
	  (hashtable-remove! *file-line-breakpoints*
			     breakpoint-name)
	  (debug-error "No breakpoint set at line " line " in file " file))))

(define (breakpoint-check-file-line file line)
;   (print "checking breakpoint: " (mkstr file ":" line))
   (hashtable-get *file-line-breakpoints*
		  (mkstr (util-realpath file) ":" line)))

(define (breakpoint-file-clearall file)
   (let ((blist *file-line-breakpoints*))
      (hashtable-for-each blist
			  (lambda (k v)
			     (let* ((parts-reversed (reverse (pregexp-split ":" k)))
				    (l (string->number (car parts-reversed)))
				    (f (string-join (reverse (cdr parts-reversed)) ":")))
				(when (string=? file f)
				   (hashtable-remove! *file-line-breakpoints* k)))))))

;;;# Utility Functions

;;; The function `get-file-line' is used to get the original source
;;; text at a particular line in a file. It's often used to provide
;;; context when prompting the user.
(define *file-line-cache* (make-hashtable))
(define (reset-file-line-cache)
   (set! *file-line-cache* (make-hashtable)))

(define (debugger-get-source-at-file-line file line)
   (when (and file line)
      (let ((cached-file (hashtable-get *file-line-cache* file)))
	 (if cached-file
	     (or (hashtable-get cached-file line)
		 "");(mkstr "Error: File " file " has no such line -- " line))
	     (let ((new-cached-file (make-hashtable)))
		(with-input-from-file file
		   (lambda ()
		      (let loop ((line (read-line))
				 ;; people count from 1
				 (i 1))
			 (unless (eof-object? line)
			    (hashtable-put! new-cached-file i line)
			    (loop (read-line) (+ i 1))))))
		(hashtable-put! *file-line-cache* file new-cached-file)
		(debugger-get-source-at-file-line file line))))))			    


(define *signal-handler-registered?* #f)
(define (register-signal-handler)
   (flush-output-port (current-output-port))
   (unless *signal-handler-registered?*
      (set! *signal-handler-registered?* #t)
      (cond-expand
       (PCC_MINGW
	(when (zero? (pragma::int "SetConsoleCtrlHandler( (PHANDLER_ROUTINE) PccCtrlHandler, TRUE )"))
	   (error 'register-signal-handler "unable to install control handler" 'rats)))
       (else
	(signal 2 (lambda (arg)
		     (set! *debugger-stepping?* 'break)))))))

(define (pcc-ctrl-handler::int ctrl-type::int)
   (cond-expand
    (PCC_MINGW
     (cond
       ((= ctrl-type (pragma::int "CTRL_C_EVENT"))
	(set! *debugger-stepping?* 'break)
	1)
       ((= ctrl-type (pragma::int "CTRL_BREAK_EVENT"))
	(set! *debugger-stepping?* 'break)
	1)
       (else
	(print "DEBUG: got unknown ctrl event")
	0)))
    (else 0)))
    

(define (breakpoint-file-and-line match)
   (let* ((parts-reversed (reverse (pregexp-split ":" match)))
          (line (string->number (car parts-reversed)))
          (file (string-join (reverse (cdr parts-reversed)) ":")))
      (if (and (number? line) (> (string-length file) 0))
          (values file line #t)
          (values file line #f))))

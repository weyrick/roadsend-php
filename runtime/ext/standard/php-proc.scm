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

(module php-proc-lib
   (include "../phpoo-extension.sch")
   (library profiler)
   (import
    (php-files-lib "php-files.scm")    
    (php-streams-lib "php-streams.scm"))
   ; exports
   (export
    (init-php-proc-lib)
    (proc_close proc)
    (proc_get_status proc)
    (proc_open cmd descspec pipes cwd env other_options)
    (proc_terminate proc signal)
    SIGQUIT
    SIGILL
    SIGTRAP
    SIGABRT
    SIGFPE
    SIGKILL
    SIGSEGV
    SIGPIPE
    SIGALRM
    SIGTERM
    ))

(define (init-php-proc-lib)
   1)

(defresource php-proc "process"
   bproc
   cmd)

(define *resource-counter* 0)
(define (make-finalized-process)
   (when (> *resource-counter* 50) ; an arbitrary constant which may be a php.ini entry
      (gc-force-finalization (lambda () (<= *resource-counter* 50))))
   (let ((new-resource (php-proc-resource #f #f)))
      (set! *resource-counter* (+fx *resource-counter* 1))
      (register-finalizer! new-resource (lambda (res)
					   (proc-cleanup res)))
      new-resource))

; this finalizes a php-proc resource
(define (proc-cleanup res::struct)
   (when (and (process? (php-proc-bproc res))
	      (process-alive? (php-proc-bproc res)))
      (php-warning "terminating process " (process-pid (php-proc-bproc res)))
      (process-kill (php-proc-bproc res))
      (close-process-ports (php-proc-bproc res))
      (set! *resource-counter* (- *resource-counter* 1))))

(define (php-proc-proper? proc)
   (and (php-proc? proc)
	(process? (php-proc-bproc proc))))

; proc_close - Close a process opened by proc_open() and return the exit code of that process.
(defbuiltin (proc_close proc)
   (if (php-proc-proper? proc)
       (begin
	  (process-wait (php-proc-bproc proc))
	  (convert-to-number (process-exit-status (php-proc-bproc proc))))
       #f))

; proc_get_status - Get information about a process opened by proc_open()
(defbuiltin (proc_get_status proc)
   (if (php-proc-proper? proc)
       (let ((result (make-php-hash)))
	  (php-hash-insert! result "command" (php-proc-cmd proc))
	  (php-hash-insert! result "pid" (convert-to-number (process-pid (php-proc-bproc proc))))
	  (php-hash-insert! result "running" (process-alive? (php-proc-bproc proc)))
	  (php-hash-insert! result "signaled" #f)
	  (php-hash-insert! result "stopped" #f)
	  (php-hash-insert! result "exitcode" (convert-to-number (process-exit-status (php-proc-bproc proc))))
	  (php-hash-insert! result "termsig" *zero*)
	  (php-hash-insert! result "stopsig" *zero*)
	  result)))		  

; proc_open - Execute a command and open file pointers for input/output
(defbuiltin (proc_open cmd descriptorspec (ref . pipes) (cwd 'unset) (env 'unset) (other_options 'unset))
   (let ((rp-args '(fork: #t)))
    (bind-exit (return)
      ; verify format of descriptorspec      
      (unless (php-hash? descriptorspec)
	 (php-warning "invalid descriptorspec")
	 (return #f))
      ; currently, we only support handles 0,1,2      
      (php-hash-for-each descriptorspec
			 (lambda (k v)
			    ; check key
			    (case (mkfixnum k)
			       ((0 1 2) 'ok)
			       (else
				(php-warning "proc_open only supports descriptors 0,1,2 (stdout, stdin, stderr) in the descriptorspec")
				(return #f)))
			    ; check val
			    (unless (and (php-hash? v)
					 ; pipe
					 (or (and (php-hash-lookup v "pipe")
						  (= (php-hash-size v) 2))    
					 ; file
 					     (and (php-hash-lookup v "file")
 						  (= (php-hash-size v) 3))))
			       (php-warning "descriptorspec array is invalid")
			       (return #f))
			    ; build args
			    (cond ((string=? (mkstr (php-hash-lookup v *zero*)) "pipe")
				   (cond ((php-= k *zero*) (set! rp-args (append (list input: pipe:) rp-args)))
					 ((php-= k *one*) (set! rp-args (append (list output: pipe:) rp-args)))
					 ((php-= k 2) (set! rp-args (append (list error: pipe:) rp-args)))))
				  ((string=? (mkstr (php-hash-lookup v *zero*)) "file")
				   (cond ((php-= k *zero*) (set! rp-args (append (list input: (php-hash-lookup v *one*)) rp-args)))
					 ((php-= k *one*) (set! rp-args (append (list output: (php-hash-lookup v *one*)) rp-args)))
					 ((php-= k 2) (set! rp-args (append (list error: (php-hash-lookup v *one*)) rp-args))))))
			    ))
      (let* ((proc-resource (make-finalized-process))
	     ; XXX this is naive: it doesn't keep quoted args together
	     (bcmd (string-split (mkstr cmd) " "))
	     (proc (apply run-process (append bcmd rp-args))))
	 (if (process? proc)
	     (let ((p (make-php-hash)))
		; setup proc
		(php-proc-cmd-set! proc-resource (mkstr cmd))
		(php-proc-bproc-set! proc-resource proc)
		; fill pipes hash
		(php-hash-for-each descriptorspec
				   (lambda (k v)
				      ; pipe
				      (cond ((string=? (mkstr (php-hash-lookup v *zero*)) "pipe")
					     (let ((stream (process-stream cmd
									   (port->file (cond ((php-= k *zero*) (process-input-port proc))
											     ((php-= k *one*) (process-output-port proc))
											     ((php-= k 2) (process-error-port proc))))
									   (string=? (mkstr (php-hash-lookup v *one*)) "w")
									   (string=? (mkstr (php-hash-lookup v *one*)) "r"))))
						(php-hash-insert! p k stream))))))
		; send back in reference
		(container-value-set! pipes p)
		proc-resource)
	     FALSE)))))


; proc_terminate - Kills a process opened by proc_open
(defbuiltin (proc_terminate proc (signal 'unset))
   (let ((sig (if (eqv? signal 'unset)
		  SIGTERM
		  (mkfixnum signal))))
      (if (php-proc-proper? proc)
	  (process-send-signal (php-proc-bproc proc) sig)
	  #f)))

; signal constants
(defconstant SIGQUIT  3)
(defconstant SIGILL   4)
(defconstant SIGTRAP  5)
(defconstant SIGABRT  6)
(defconstant SIGFPE   8)
(defconstant SIGKILL  9)
(defconstant SIGSEGV 11)
(defconstant SIGPIPE 13)
(defconstant SIGALRM 14)
(defconstant SIGTERM 15)

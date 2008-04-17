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
(module php-core-lib
   (include "../phpoo-extension.sch")
   (library phpeval)
   (library profiler)
   (extern
    (include "php-system.h")
    (macro php-c-system::obj (str1::string) "php_c_system"))
   (import
    (php-pack "pack.scm")
    (re-extension-lib "re-extensions.scm")    
    (php-string-lib "php-strings.scm")
    (php-math-lib "php-math.scm")
    (php-files-lib "php-files.scm")
    (php-time-lib "php-time.scm")
    (php-array-lib "php-array.scm")
    (php-variable-lib "php-variable.scm")
    (php-eregexp-lib "php-eregexp.scm")
    (php-output-control-lib "php-output-control.scm")
    (php-network-lib "php-network.scm")
    (php-posix-lib "php-posix.scm")
    (php-session-lib "php-session.scm")
    (php-streams-lib "php-streams.scm")
    (php-proc-lib "php-proc.scm")
    (php-image-lib "php-image.scm"))
   ; exports
   (export
     E_LOG_SYSTEM 
     E_LOG_EMAIL 
     E_LOG_TCPIP 
     E_LOG_FILE
     PHP_SHLIB_SUFFIX
     ;; builtins
     (init-php-standard-lib)     
     (getlastmod)
     (getmygid)
     (getmypid)
     (getmyuid)
     (get_current_user)
     (set_include_path path)
     (get_included_files)
     (get_include_dirs)
     (get_include_path)
     (php-putenv val)
     (php-getenv key)
     (pack format . args)
     (unpack format data)
     (ini_get name)
     (ini_set name value)     
     (php-sleep secs)
     (usleep msecs)
     (get_magic_quotes_runtime)
     (get_magic_quotes_gpc)
     (set_magic_quotes_runtime val)
     (register_shutdown_function func)
     (extension_loaded ext)
     (get_loaded_extensions)
     (get_declared_classes)
     (get_defined_constants)
     (get_defined_functions)
     (get_defined_vars)
     (set_time_limit secs)
     (dl module)
     (constant name)
     (defined var)
     ; php info, versioning, etc
     (phpinfo infotype)
     (phpcredits)
     (phpversion extension)
     (zend_version)
     (php_uname)
     (php_sapi_name)
     ; error handling
     (error_reporting number)
     (set_error_handler handler-name)
     (restore_error_handler)
     (trigger_error msg etype)
     (error_log msg msg-type dest extra)
     (debug_backtrace)
     ; program execution
     (php-system command return-var)
     (passthru command return-var)
     (exec command output-array return-var)
     (escapeshellarg string)
     (escapeshellcmd string) 
     ;classes / functions
     (class_exists class-name autoload)
     (interface_exists class-name autoload)     
     (method_exists class-name method-name)
     (get_class obj)
     (get_parent_class obj)
     (is_a obj class-name)
     (is_subclass_of obj class-name)
     (get_object_vars obj)
     (get_class_vars class-name)
     (get_class_methods class-name)
     (call_user_func . callback)
     (call_user_func_array callback array)
     (call_user_method callback object . arglist)
     (call_user_method_array callback object array)
     (function_exists func)
     (shell_exec command)
     (is_callable var syntax-only name)
     ;;variable arity user functions
     (func_get_args)
     (func_num_args)
     (func_get_arg arg-num)
     (create_function args body)
    ))

; init the module
(define (init-php-standard-lib)
   (init-re-extension-lib)
   (init-php-variable-lib)
   (init-php-string-lib)
   (init-php-math-lib)
   (init-php-files-lib)
   (init-php-time-lib)
   (init-php-array-lib)
   (init-php-eregexp-lib)
   (init-php-output-control-lib)
   (init-php-network-lib)
   (init-php-session-lib)
   (init-php-streams-lib)
   (init-php-image-lib)
   (init-php-proc-lib)
   1)

; register the extension
(register-extension "standard" "1.0.0"
                    "php-std"
                    ; XXX the new autoconf stuff might not get this right
                    ; --timjr Sat Dec 22 14:26:24 PST 2007
                    ;  (cond-expand
;                                  (PCC_MINGW '("-lws2_32"))
;                                  (PCC_FREEBSD '("-lcrypt"))
; 				 (PCC_MACOSX '("-lresolv" "-lm"))
;                                  (else '("-lresolv" "-lm" "-lcrypt")))
		    ;; XXX we don't really want this to require the
		    ;; curl extension, but right now it has to, in
		    ;; order for http://foo streams to work.
                    required-extensions: '("compiler" "curl"))
 
;;;;;;;


(defbuiltin-v (pack format args)
   (do-pack format args))

(defbuiltin (unpack format data)
   (do-unpack format data))

(defbuiltin (getlastmod)
   (file-modification-time *PHP-FILE*))

(defbuiltin (getmygid)
   (posix_getgid))
   
(defbuiltin (getmypid)
   (posix_getpid))
   
(defbuiltin (getmyuid)
   (posix_getuid))
   
(defbuiltin (get_current_user)
   (let ((phash (posix_getpwuid (posix_getuid))))
      (php-hash-lookup phash "name")))

;;;;;;;;

(defalias sleep php-sleep)
(defbuiltin (php-sleep secs)
   (sleep (* (mkfixnum secs) 1000000)))

(defbuiltin (usleep msecs)
   (sleep (mkfixnum msecs)))

; putenv
(defalias putenv php-putenv)
; split on =
(defbuiltin (php-putenv val)
   (set! val (mkstr val))
   (let ((esign (string-index val "=")))
      (when esign
	 (let ((lval (substring val 0 esign))
	       (rval (substring val (+ esign 1) (string-length val))))
	    (putenv lval rval)))))

; getenv
(defalias getenv php-getenv)
(defbuiltin (php-getenv key)
   (getenv (mkstr key)))


; exec
(defbuiltin (exec command ((ref . output-array) 'unset) ((ref . return-var) 'unset))
   (let* ((nlchar (cond-expand
		     (PCC_MINGW "\r\n")
		     (else "\n")))
	  (result (php-c-system command))
	  (output (if (pair? result) (car result) ""))
	  (retval (if (pair? result) (cond-expand (PCC_MINGW 
						   (cdr result))
						  (else
						   (bit-rsh (cdr result) 8)))

		      *one*)))
     (if (null? result)
	  ; no result, but if they passed retval or output array, define em
	  (begin
	     (unless (eqv? return-var 'unset)
		(container-value-set! return-var *one*))
	     (unless (eqv? output-array 'unset)
		(unless (php-hash? (container-value output-array))
		   (container-value-set! output-array (make-php-hash))))
	     #f)
	  (begin
	     ; return var?
	     (unless (eqv? return-var 'unset)
		(container-value-set! return-var (convert-to-integer retval)))
	     ; possibly strip trailing newline
	     (set! output (rtrim output nlchar)) 
	     ; output array?
	     (unless (eqv? output-array 'unset)
		(unless (php-hash? (container-value output-array))
		   (container-value-set! output-array (make-php-hash)))
		(when (> (string-length output) 2)
		   (container-value-set! output-array (array_merge
						       (container-value output-array)
						       (explode "\n" output 'unpassed)))))
	     ; return last line of output (sans trailing newline)
	     (let ((nlpos (strrpos output nlchar)))
		(if nlpos
		    (substring output (mkfixnum (php-+ nlpos 1)) (string-length output))
		    output))))))

; system
(defalias system php-system)
(defbuiltin (php-system command ((ref . return-var) 'unset))
   (let* ((nlchar (cond-expand
		     (PCC_MINGW "\r\n")
		     (else "\n")))
	  (result (php-c-system command))
	  (output (if (pair? result) (car result) ""))
	  (retval (if (pair? result) (cond-expand (PCC_MINGW 
						   (cdr result))
						  (else
						   (bit-rsh (cdr result) 8)))
		      *one*)))
      (if (null? result)
	  (begin
	     (unless (eqv? return-var 'unset)
		(container-value-set! return-var *one*))
	     #f)
	  (begin
	     ; return var?
	     (unless (eqv? return-var 'unset)
		(container-value-set! return-var (convert-to-integer retval)))
	     ; output results to output buffer
	     (echo output)
	     ; possibly strip trailing newline
	     (set! output (rtrim output nlchar)) 
	     ; return last line of output (sans trailing newline)
	     (let ((nlpos (strrpos output nlchar)))
		(if nlpos
		    (substring output (mkfixnum (php-+ nlpos 1)) (string-length output))
		    ""))))))

; passthru
(defbuiltin (passthru command ((ref . return-var) 'unset))
   (let* ((result (php-c-system command))
	  (output (if (pair? result) (car result) ""))
	  (retval (if (pair? result) (cond-expand (PCC_MINGW 
						   (cdr result))
						  (else
						   (bit-rsh (cdr result) 8)))
		      *one*)))
      (if (null? result)
	  (begin
	     (unless (eqv? return-var 'unset)
		(container-value-set! return-var *one*))
	     #f)	  
	  (begin
	     ; return var?
	     (unless (eqv? return-var 'unset)
		(container-value-set! return-var retval))
	     ; output results to output buffer
	     (echo output)
	     NULL))))

(defbuiltin (shell_exec command)
    (let ((result (php-c-system command)))
       (if (pair? result)
           (car result)
           "")))


; escapeshellarg
(defbuiltin (escapeshellarg string)
   (let ((qchar (cond-expand
		   (PCC_MINGW "\"")
		   (else "'")))
	 (rp (cond-expand
		(PCC_MINGW
		 (regular-grammar ((nasties (in "%\"")))
		    (nasties " ")
		    ((+ (out nasties)) (the-string))
		    ; pass the rest thru
		    (else (the-failure))))
		(else
		 ; unix
		 (regular-grammar ()
		    ( (:#\') "'\\''")
		    ((+ (out #\')) (the-string))
		    ; pass the rest thru
		    (else (the-failure)))))))
      (append-strings (append (list qchar) (get-tokens-from-string rp (mkstr string)) (list qchar)))))

; escapeshellcmd
(defbuiltin (escapeshellcmd string)
   (let ((rp (cond-expand
		(PCC_MINGW
		 (regular-grammar ((nasties (in "%#&;`|*?~<>^(){}[]$\\'\"")))
		    (nasties " ")
		    ((+ (out nasties)) (the-string))
		    ; pass the rest thru
		    (else (the-failure))))
		(else
		 ; unix
		 (regular-grammar ((nasties (in "#&;`|*?~<>^(){}[]$\\'\"")))
		    (nasties (string-append "\\" (the-string)))
		    ((+ (out nasties)) (the-string))
		    ; pass the rest thru
		    (else (the-failure)))))))
      (append-strings (get-tokens-from-string rp (mkstr string)))))

; register_shutdown_function
(defbuiltin (register_shutdown_function func)
   ; func can be a hash, in which case it's an object callback
   (set! *shutdown-functions*
	 (cons (if (php-hash? func)
		   func
		   (mkstr func))
	       *shutdown-functions*)))

; extension_loaded
(defbuiltin (extension_loaded ext)
   (bind-exit (return)
      (extensions-for-each (lambda (e)
                              (when (string=? (mkstr ext) e)
                                  (return TRUE))))
      FALSE))


; get a list of functions currently in builtins
; will include library functions
(defbuiltin (get_defined_functions)
   (let ((fhash (make-php-hash))
	 (bhash (make-php-hash))
	 (uhash (list->php-hash (get-user-function-list))))
      ; builtins
      (builtins-for-each
       (lambda (key obj)
	  (php-hash-insert! bhash :next (symbol->string key))))
      ; builtins: aliases
      (aliases-for-each
       (lambda (key obj)
	  (php-hash-insert! bhash :next (symbol->string key))))
      ; user defined      
      (php-hash-insert! fhash "internal" bhash)
      (php-hash-insert! fhash "user" uhash)
      fhash))

; currently defined vars
(defbuiltin (get_defined_vars)
   (let ((the-env (env-php-hash-view *current-variable-environment*)))
      ;;note that env-php-hash-view returns a copy, so we can't use the-env to
      ;;check for globalness
      (unless (eq? *current-variable-environment* *global-env*)
	 (hashtable-for-each *superglobals*
	    (lambda (k v)
	       (php-hash-remove! the-env k))))
      the-env))


; for manually setting the include path from php land
(defbuiltin (set_include_path path)
   (let ((old-paths (string-join *include-paths* ":")))
      (set-include-paths! (unix-path->list (mkstr path)))
      old-paths))

; ; for getting a list of included files
(defalias get_required_files get_included_files)
(defbuiltin (get_included_files)
   (let ((rethash (make-php-hash)))
      (hashtable-for-each *all-files-ever-included*
 			  (lambda (k v)
 			     (php-hash-insert! rethash k v)))
      rethash))


(defbuiltin (get_declared_classes)
   (get-declared-php-classes))

(defbuiltin (get_defined_constants)
   (let ((rethash (make-php-hash)))
      (constants-for-each (lambda (name value)
			     (php-hash-insert! rethash name value)))
      rethash))

; get a php hash of the current include paths
(defbuiltin (get_include_dirs)
   (list->php-hash *include-paths*))

(defbuiltin (get_include_path)
   (string-join *include-paths* ":"))

; get_loaded_extensions
(defbuiltin (get_loaded_extensions)
   (let ((extensions (make-php-hash)))
      (extensions-for-each (lambda (e)
                              (php-hash-insert! extensions :next e)))
      extensions))

; set_time_limit
(defbuiltin (set_time_limit secs)
;;   (php-warning "set_time_limit: functionality not implemented")
   FALSE)

(defconstant PHP_SHLIB_SUFFIX (let* ((shared-lib-suffix (make-shared-library-name ""))
				     (len (string-length shared-lib-suffix)))
				 (if (and (> len 0)
					  (char=? #\. (string-ref shared-lib-suffix 0)))
				     (substring shared-lib-suffix 1 len)
				     shared-lib-suffix)))

; dl
(defbuiltin (dl module-name)
   (let* ((module-name (pregexp-replace "_" (mkstr module-name) "-"))
	  (ext-name (pregexp-replace (string-append "\." PHP_SHLIB_SUFFIX "$")
						       (pregexp-replace "^php-" module-name "")
						       "")))
      (debug-trace 1 "dl: module-name -> " module-name " ext-name -> " ext-name " (dyn-load-path: " *dynamic-load-path* ")")
      (try (begin
	      (load-runtime-libs (list (mkstr "php-" ext-name)))
	      (run-startup-functions-for-extension ext-name)
	      TRUE)
	   (lambda (e p m o)
	      (php-warning "Unable to load extension " module-name)
	      (e FALSE)))))
      



;;;;;;;;;; php info, versioning, etc

; XXX dehardcodify
(defbuiltin (php_sapi_name)
   (if *commandline?*
       "cli"
       "apache"))

(defbuiltin (php_uname)
   (lookup-constant "PHP_OS"))


(define (info-html-header)
   (echo (mkstr "<html>
<head>
	<title>PHP Info</title>
<style>
.h0lowColor      {color: #17105D;        font-family: Arial, Helvetica;          font-size: xx-small;     font-style: normal;     font-weight: normal } 
.h0mainColor     {color: #471C02;        font-family: Arial, Helvetica;          font-size: xx-small;     font-style: normal;     font-weight: normal } 
.h1lowColor      {color: #17105D;        font-family: Arial, Helvetica;          font-size: x-small;       font-style: normal;     font-weight: normal } 
.h1mainColor     {color: #17105D;        font-family: Arial, Helvetica;          font-size: x-small;       font-style: normal;     font-weight: normal } 
.b0lowColor      {color: #471C02;        font-family: Arial, Helvetica;          font-size: xx-small;     font-style: normal;     font-weight: bold } 
.b0mainColor     {color: #17105D;        font-family: Arial, Helvetica;          font-size: xx-small;     font-style: normal;     font-weight: bold } 
.b1lowColor      {background-color:  #E4E1D1;             color: #471C02;        font-family: Arial, Helvetica;          font-size: x-small;     font-style: normal;     font-weight: bold } 
.b1lowColor2     {color: #471C02;        font-family: Arial, Helvetica;          font-size: x-small;     font-style: normal;     font-weight: bold } 
.b1mainColor     {color: #17105D;        font-family: Arial, Helvetica;          font-size: x-small;     font-style: normal;     font-weight: bold } 
.b2lowColor      {color: #471C02;        font-family: Arial, Helvetica;          font-size: medium;     font-style: normal;     font-weight: bold } 
.header			 {background-color:  #FFFFFF;             color: #471C02;        font-family: Arial, Helvetica;          font-size: small;     font-style: normal;     font-weight: bold } 
body {background-color: #ffffff; color: #471C02;}
table {border-collapse: collapse;}
td { border: 1px solid #9A5C45; vertical-align: baseline;}
.center table { margin-left: auto; margin-right: auto; text-align: left;}
</STYLE>
</head>

<body WIDTH=\"700\" align=\"center\">

<center><span CLASS=\"b2lowColor\">" (lookup-constant "RAVEN_VERSION_TAG") "<br></span> 
<span CLASS=\"b1lowColor2\">&copy; " (date-year (current-date)) " Roadsend, Inc.</span></center>

<br>")))

(define (info-html-footer)
   (echo "</body></html>")) 

(defbuiltin (phpinfo (infotype 'unpassed))
   ; XXX we ignore infotype
   (unless *commandline?*
      (info-html-header))
   (unless *commandline?*
      (echo "<table BORDER=\"0\" width=\"700\" cellpadding=\"3\" bgcolor=\"#EEF6F7\" class=\"h1mainColor\" ALIGN=\"CENTER\">")
      (echo "<tr><td colspan=2 class=\"header\">Web Environment</td></tr>")
      ;(echo "<TR><TD>Variable</TD><TD>Value</TD></TR>")
      (php-hash-for-each (container-value $_SERVER)
			 (lambda (k v)
			    (echo (mkstr "<TR><TD class=\"b1lowColor\" valign=\"top\">" k "</TD><TD>" v "</TD></TR>"))))
      (echo "</TABLE><br><br>"))
   (if *commandline?*
       (begin
	  (phpcredits)
	  (echo "\n== Include Paths ==\n")
	  (if (> (length *include-paths*) 0)
	      (php-hash-for-each (get_include_dirs)
				 (lambda (k v)
				    (echo (mkstr v "\n"))))
	      (echo "none\n")))
       (begin
	  (echo "<table BORDER=\"0\" width=\"700\" cellpadding=\"3\" bgcolor=\"#EEF6F7\" class=\"h1mainColor\" ALIGN=\"CENTER\">")
	  (echo "<tr><td class=\"header\">Include Paths</td></tr>")
	  (if (> (length *include-paths*) 0)
	      (php-hash-for-each (get_include_dirs)
				 (lambda (k v)
				    (echo (mkstr "<TR><TD class=\"b1lowColor\" valign=\"top\">" v "</TD></TR>"))))
	      (echo "<TR><TD class=\"b1lowColor\" valign=\"top\">none</TD></TR>"))
	  (echo "</TABLE><br><br>")))
   (if *commandline?*
       (begin
	  (echo "== PHP Libraries ==\n")
	  (if (> (length *user-libs*) 0)
	      (php-hash-for-each (re_get_loaded_libs)
				 (lambda (k v)
				    (echo (mkstr v "\n"))))
	      (echo "none\n")))
       (begin
	  (echo "<table BORDER=\"0\" width=\"700\" cellpadding=\"3\" bgcolor=\"#EEF6F7\" class=\"h1mainColor\" ALIGN=\"CENTER\">")
	  (echo "<tr><td class=\"header\">PHP Libraries</td></tr>")
	  (if (> (length *user-libs*) 0)
	      (php-hash-for-each (re_get_loaded_libs)
				 (lambda (k v)
				    (echo (mkstr "<TR><TD class=\"b1lowColor\" valign=\"top\">" v "</TD></TR>"))))
	      (echo "<TR><TD class=\"b1lowColor\" valign=\"top\">none</TD></TR>"))
	  (echo "</TABLE><br><br>")))
   (if *commandline?*
       (begin
	  (echo "== Environment ==\n")
	  (php-hash-for-each (container-value $_ENV)
			     (lambda (k v)
				(echo (mkstr k " => " v "\n")))))
       (begin
	  (echo "<table BORDER=\"0\" width=\"700\" cellpadding=\"3\" bgcolor=\"#EEF6F7\" class=\"h1mainColor\" ALIGN=\"CENTER\">")
	  (echo "<tr><td colspan=2 class=\"header\">Environment</td></tr>")
	  ;(echo "<TR><TD>Variable</TD><TD>Value</TD></TR>")
	  (php-hash-for-each (container-value $_ENV)
			     (lambda (k v)
				(echo (mkstr "<TR><TD class=\"b1lowColor\" valign=\"top\">" k "</TD><TD>" v "</TD></TR>"))))
	  (echo "</TABLE><br><br>")))
   (unless *commandline?*
      (info-html-footer))
   )
   
(defbuiltin (phpcredits)
   (echo (mkstr (lookup-constant "RAVEN_VERSION_TAG")
		" Copyright (c) "
		(date-year (current-date))
		" Roadsend, Inc.")))

(defbuiltin (phpversion (extension 'unpassed))
   ; XXX we ignore extension right now 
   (lookup-constant "PHP_VERSION"))

(defbuiltin (zend_version)
   *ZEND2-VERSION*)

;;;; miscellaneous functions

; ;Returns the value of a constant
(defbuiltin (constant name)
   (lookup-constant name))

; ; Checks whether a given named constant exists
(defbuiltin (defined name)
   (if (constant-defined? (mkstr name))
       TRUE
       FALSE))

;Output a message and terminate the current script

;;;LXXVI.1 PHP Options&Information
; assert -- Checks if assertion is FALSE
; assert_options -- Set/get the various assert flags
; extension_loaded -- Find out whether an extension is loaded
; dl -- Loads a PHP extension at runtime

; get_cfg_var --  Gets the value of a PHP configuration option
; XXX this actually does something different, but we don't support it yet
(defalias get_cfg_var ini_get)

; get_current_user --  Gets the name of the owner of the current PHP script
; get_defined_constants --  Returns an associative array with the names of all the constants and their values
; get_extension_funcs --  Returns an array with the names of the functions of a module
; getmygid -- Get PHP script owner's GID
; get_included_files --  Returns an array with the names of included or required files
; get_loaded_extensions --  Returns an array with the names of all modules compiled and loaded


(define *php-magic-quotes* 0)

; get_magic_quotes_runtime --  Gets the current active configuration setting of magic_quotes_runtime
(defbuiltin (get_magic_quotes_runtime)
   *php-magic-quotes*)

; get_magic_quotes_gpc --  Gets the current active configuration setting of magic quotes gpc
(defbuiltin (get_magic_quotes_gpc)
   *php-magic-quotes*)

; getlastmod -- Gets time of last page modification
; getmyinode -- Gets the inode of the current script
; getmypid -- Gets PHP's process ID
; getmyuid -- Gets PHP script owner's UID
; get_required_files --  Returns an array with the names of included or required files
; getrusage -- Gets the current resource usages
; ini_alter --  Changes the value of a configuration option

; ini_get -- Gets the value of a configuration option
(defbuiltin (ini_get name)
   (get-ini-entry name))


; ini_get_all -- Gets all configuration options
; ini_restore -- Restores the value of a configuration option

; ini_set -- Sets the value of a configuration option
(defbuiltin (ini_set name value)
   ; special case for include_path
   (when (string=? (mkstr name) "include_path")
      (set-include-paths! (unix-path->list (mkstr value))))
   (set-ini-entry name value))

; php_sapi_name --  Returns the type of interface between web server and PHP
; php_uname --  Returns information about the operating system PHP was built on

; set_magic_quotes_runtime --  Sets the current active configuration setting of magic_quotes_runtime
(defbuiltin (set_magic_quotes_runtime val)
   (unless (php-= val 0)
      (php-warning "magic quotes are not implemented")))

; set_time_limit -- Limits the maximum execution time
; version_compare --  Compares two "PHP-standardized" version number strings



;;;XXVII. Error Handling and Logging Functions
;; The error levels


; error_log -- send an error message somewhere
(defconstant E_LOG_SYSTEM 0)  
(defconstant E_LOG_EMAIL 1)  
(defconstant E_LOG_TCPIP 2)  
(defconstant E_LOG_FILE 3)  

(defbuiltin (error_log msg (msg-type E_LOG_SYSTEM) (dest 'unpassed) (extra 'unpassed))
   (case msg-type
      ((E_LOG_SYSTEM) (php-warning msg))
      ((E_LOG_EMAIL)
       ;XXX send an error email to destination, with extra headers from extra
       #t)
      ((E_LOG_TCPIP) (php-warning "Warning!  TCPIP logging is not implemented.")
		     #t)
      ((E_LOG_FILE) (with-output-to-file (mkstr dest)
		       (lambda ()
			  (echo msg))))))
   

; error_reporting -- set which PHP errors are reported
(defbuiltin (error_reporting (number 'unset))
   (let ((old-level *error-level*))
      (unless (eqv? number 'unset)
	 (set! *error-level* (mkfixnum (convert-to-number number)))) 
      old-level))

; restore_error_handler --  Restores the previous error handler function
(defbuiltin (restore_error_handler)
   (if (not (eqv? *old-error-handler* #f))
       (set_error_handler *old-error-handler*)))


; restore_exception_handler --  Restores the previous exception handler function
(defbuiltin (restore_exception_handler)
   (if (not (eqv? *old-exception-handler* #f))
       (set_exception_handler *old-exception-handler*)))

(define *old-error-handler* #f)
(define *old-exception-handler* #f)

; set_error_handler --  Sets a user-defined error handler function.
(defbuiltin (set_error_handler handler-name)
   (if (function_exists handler-name)
       (begin
	  (set! *old-error-handler* *error-handler*)
	  (set! *error-handler* handler-name)
	  *old-error-handler*)
       (php-warning "no function by the name of " handler-name " exists")))

; set_exception_handler --  Sets a user-defined exception handler function.
(defbuiltin (set_exception_handler handler-name)
   (if (function_exists handler-name)
       (begin
	  (set! *old-exception-handler* *error-handler*)
	  (set! *default-exception-handler* handler-name)
	  *old-exception-handler*)
       (php-warning "no function by the name of " handler-name " exists")))

; trigger_error --  Generates a user-level error/warning/notice message
(define *catch-error-recurse* 0)
(define *error-threshold* 50)

; reset every page load
(add-end-page-reset-func reset-error-recurse)
(define (reset-error-recurse)
   (set! *catch-error-recurse* 0))

(defbuiltin (trigger_error msg (etype E_USER_NOTICE))
   (if (and (not (equalp etype E_USER_NOTICE))
	    (not (equalp etype E_USER_WARNING))
	    (not (equalp etype E_USER_ERROR)))
       (php-error "trigger_error: invalid error type")
       (if (> *catch-error-recurse* *error-threshold*)
	   (php-error "trigger_error: recursion in custom error handler: " msg)
	   (begin
	      (set! *catch-error-recurse* (+ *catch-error-recurse* 1))
	      (php-funcall *error-handler* etype (mkstr msg) *PHP-FILE* *PHP-LINE* (make-php-hash))))))
   
; user_error --  Generates a user-level error/warning/notice message
(defalias user_error trigger_error)

; debug_backtrace --  Generates a backtrace
(defbuiltin (debug_backtrace)
   (let ((hash (make-php-hash)))
      (unless (null? *stack-trace*)
	 (for-each (lambda (a)
		      (let ((entry (make-php-hash)))
			 (php-hash-insert! entry "file" (mkstr (stack-entry-file a)))
			 (php-hash-insert! entry "line" (convert-to-number (stack-entry-line a)))
			 (php-hash-insert! entry "function" (mkstr (stack-entry-function a)))
                         (php-hash-insert! entry "class" (if (eqv? 'unset (stack-entry-class-name a))
							     ""
                                                             (mkstr (stack-entry-class-name a))))
                         (php-hash-insert! entry "args" (list->php-hash (stack-entry-args a)))
			 (php-hash-insert! hash :next entry)))
		   (cdr *stack-trace*)))
      hash))

;;;IX. Class/Object Functions

; class_exists -- Checks if the class has been defined
(defbuiltin (class_exists class-name (autoload TRUE))
   (php-class-exists? class-name (convert-to-boolean autoload)))

; interface_exists -- Checks if the interface has been defined
(defbuiltin (interface_exists class-name (autoload TRUE))
   (php-interface-exists? class-name (convert-to-boolean autoload)))

; get_class -- Returns the name of the class of an object
(defbuiltin (get_class obj)
  (if (php-object? obj)
      (mkstr (php-object-class obj))
      FALSE))

; get_class_methods -- Returns an array of class methods' names
(defbuiltin (get_class_methods class-name)
   (let ((mlist (php-class-methods (if (php-object? class-name)
				       (php-object-class class-name)
				       (mkstr class-name)))))
      (if (eqv? mlist #f)
	  (begin 
	     (php-warning "No such class: " class-name)
	     #f)
	  mlist)))

; get_class_vars --  Returns an array of default properties of the class
(defbuiltin (get_class_vars class-name)
   (copy-php-data (php-class-props class-name)))

; get_object_vars -- Returns an associative array of object properties
(defbuiltin (get_object_vars obj)
   (if (php-object? obj)
       (copy-php-data (php-object-props obj))
       #f))

; get_parent_class -- Retrieves the parent class name for object or class
(defbuiltin (get_parent_class obj)
   (if (php-object? obj)
       (php-object-parent-class obj)
       (php-class-parent-class (mkstr obj))))

; is_a --  Returns true if the object is of this class or has this class as one of its parents
(defbuiltin (is_a obj class-name)
   (if (php-object? obj)
       (php-object-is-a obj class-name)
       #f))

; is_subclass_of --  Returns true if the object has this class as one of its parents
(defbuiltin (is_subclass_of obj class-name)
   (if (php-object? obj)
       (php-object-is-subclass obj class-name)
       (php-class-is-subclass (mkstr obj) (mkstr class-name))))

; method_exists -- Checks if the class method exists
(defbuiltin (method_exists obj method-name)
   (if (php-object? obj)
       (php-class-method-exists? (php-object-class obj) (mkstr method-name))
       (php-class-method-exists? (mkstr obj) (mkstr method-name))))

;;;;;

; call_user_func -- Call a user function given by the first parameter
(defbuiltin-v (call_user_func cb)
   (let ((callback (if (pair? cb) (car cb) cb))
	 (arglist (if (pair? cb) (cdr cb) '())))
      (apply php-callback-call callback arglist)))
; 	 (if (php-hash? callback)
; 	     (let ((class-or-obj (php-hash-lookup callback 0))
; 		   (methodname (php-hash-lookup callback 1)))
; 		(if (php-object? class-or-obj)
; 		    (apply call-php-method class-or-obj methodname arglist)
; 		    (apply call-static-php-method class-or-obj NULL methodname arglist)))
; 	     (apply php-funcall callback arglist))))

; call_user_func_array -- Call a user function given with an array of parameters
(defbuiltin (call_user_func_array callback (argarray 'unset))
   (if (php-hash? argarray)
       (apply call_user_func callback (php-hash->list argarray))))

; call_user_method_array --  Call a user method given with an array of parameters
(defbuiltin (call_user_method_array callback object arglist)
   (apply call-php-method object (mkstr callback) (php-hash->list arglist)))
   
; call_user_method --  Call a user method on an specific object
(defbuiltin-v (call_user_method callback object arglist)
   (apply call-php-method object (mkstr callback) arglist))

; function_exists
(defbuiltin (function_exists func)
   (if (and (not (equal? func NULL))
	    (get-php-function-sig func))
       TRUE
       FALSE))

; is_callable --  Verify that the contents of a variable can be called as a function
(defbuiltin (is_callable var (syntax-only #f) ((ref . name) 'unpassed))
   (let* ((valid-syntax (if (php-hash? var)
			    ; proper array
			    (and (= (php-hash-size var) 2)
				 (or (string? (php-hash-lookup var 0))
				     (php-object? (php-hash-lookup var 0)))
				 (string? (php-hash-lookup var 1)))
			    ; string function name only
			    (string? var)))
	  (exists (if (and valid-syntax (not syntax-only))
		      (if (php-hash? var)
			  (method_exists (php-hash-lookup var 0) (php-hash-lookup var 1))
			  (function_exists (mkstr var)))
		      #f)))
      (when (and valid-syntax
		 (not (eqv? name 'unpassed)))
	 (if (php-hash? var)
	     (container-value-set! name (mkstr (php-object-class (php-hash-lookup var 0)) "::" (php-hash-lookup var 1)))
	     (container-value-set! name (mkstr var))))
      (if (eqv? syntax-only #t)
	  valid-syntax
	  exists)))


;;;the *func-args-stack* is maintained in php-runtime.scm, so that
;;;evaluate can get to it.
(defbuiltin (func_get_args)
   (if (null? *func-args-stack*)
       (php-warning "Called from the global scope - no function context")
       (begin
	  (unless (php-hash? (car *func-args-stack*))
	     (set-car! *func-args-stack* (list->php-hash (car *func-args-stack*))))
	  (car *func-args-stack*))))

(defbuiltin (func_num_args)
   (if (null? *func-args-stack*)
       (begin
	  (php-warning "Called from the global scope - no function context")
	  (convert-to-number #e-1))
       (begin   
	  (if (php-hash? (car *func-args-stack*))
	      (php-hash-size (car *func-args-stack*))
	      (convert-to-number (length (car *func-args-stack*)))))))

(defbuiltin (func_get_arg arg-num)
   (php-hash-lookup (func_get_args)
		    (convert-to-number arg-num)))

(defbuiltin (create_function args body)
  (let* ((name (symbol->string (gensym 'phplambda)))
	 (code (string-append "function " name "(" args ") {" body "}")))
     (php-eval code)
     name))

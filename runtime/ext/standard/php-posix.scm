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

(module php-posix-lib
   (include "../phpoo-extension.sch")
   (library php-runtime)
   (library profiler)
;   (library "common")
   (import (posix-c-bindings "posix-c-bindings.scm"))
   (export
    (init-php-posix-lib)
    (posix_get_last_error)
    (posix_strerror errnum)
    (posix_kill pid signal) 
    (posix_getpid)
    (posix_getppid)
    (posix_getuid)
    (posix_geteuid)
    (posix_getgid)
    (posix_getegid)
    (posix_setuid uid)
    (posix_seteuid uid)
    (posix_setgid gid)
    (posix_setegid gid)
    (posix_getgroups)
    (posix_getlogin)
    (posix_getpgrp)
    (posix_setsid)
    (posix_setpgid pid pgid)
    (posix_getpgid pid)
    (posix_getsid pid)
    (posix_uname)
    (posix_times)
    (posix_ctermid)
    (posix_ttyname fd)
    (posix_isatty fd)
    (posix_getcwd)
    (posix_mkfifo pathname mode)
    (posix_getgrnam name)
    (posix_getgrgid gid)
    (posix_getpwnam username)
    (posix_getpwuid uid)
    (posix_getrlimit)))
    
;;; Initialize the module
(define (init-php-posix-lib)
   1)

; register the extension
(register-extension "posix" "1.0.0"
                    "php-std" '())

;;; Undocumented Posix Functions

;; this stuff is not in the php documentation but it is in their code
;; and you can use these functions from php, so I should probably
;; implement them

; last error return value set by a failed posix function
(define *errno* 0)

; posix_get_last_error - Return the integer value of the most recent error
(defbuiltin (posix_get_last_error)
   (convert-to-number *errno*))

; posix_strerror - Return the string describing an error code
(defbuiltin (posix_strerror errnum)
   (c-strerror (mkfixnum errnum)))

;;; Documented Posix Functions

; posix_kill -- Send a signal to a process
(defbuiltin (posix_kill pid signal)
   (cond-expand
      (PCC_MINGW
       (mingw-missing 'posix_kill))
      (else
       (let ((retval (c-kill (mkfixnum pid) (mkfixnum signal))))
	  (cond ((= 0 retval) TRUE)
		(else (set! *errno* c-errno)
		      FALSE))))))

; posix_getpid -- Return the current process identifier
(defbuiltin (posix_getpid)
   (convert-to-integer
    (cond-expand
       (PCC_MINGW (mingw-missing 'posix_getpid))
       (else (c-getpid)))))

; posix_getppid -- Return the parent process identifier
(defbuiltin (posix_getppid)
   (convert-to-integer
    (cond-expand
       (PCC_MINGW (mingw-missing 'posix_getppid))
       (else (c-getppid)))))

; posix_getuid --  Return the real user ID of the current process
(defbuiltin (posix_getuid)
   (convert-to-integer
    (cond-expand
       (PCC_MINGW (mingw-missing 'posix_getuid))
       (else (c-getuid)))))

; posix_geteuid --  Return the effective user ID of the current process
(defbuiltin (posix_geteuid)
   (convert-to-integer
    (cond-expand
       (PCC_MINGW (mingw-missing 'posix_getuid))
       (else (c-geteuid)))))

; posix_getgid --  Return the real group ID of the current process
(defbuiltin (posix_getgid)
   (convert-to-integer
    (cond-expand
       (PCC_MINGW (mingw-missing 'posix_getgid))
       (else (c-getgid)))))

; posix_getegid --  Return the effective group ID of the current process
(defbuiltin (posix_getegid)
   (convert-to-integer
    (cond-expand
       (PCC_MINGW (mingw-missing 'posix_getegid))
       (else (c-getegid)))))

; posix_setuid --  Set the UID of the current process
(defbuiltin (posix_setuid uid)
   (cond-expand
      (PCC_MINGW (mingw-missing 'posix_setuid))
      (else
       (let ((retval (c-setuid (mkfixnum uid))))
	  (cond ((php-= retval 0) TRUE)
		(else (set! *errno* c-errno)
		      FALSE))))))

; posix_seteuid --  Set the effective UID of the current process
(defbuiltin (posix_seteuid uid)
   (cond-expand
      (PCC_MINGW (mingw-missing 'posix_seteuid))
      (else
       (let ((retval (c-seteuid (mkfixnum uid))))
	  (cond ((php-= retval 0) TRUE)
		(else (set! *errno* c-errno)
		      FALSE))))))

; posix_setgid --  Set the GID of the current process
(defbuiltin (posix_setgid gid)
   (cond-expand
      (PCC_MINGW #t)
      (else
       (let ((retval (c-setgid (mkfixnum gid))))
	  (cond ((php-= retval 0) TRUE)
		(else (set! *errno* c-errno)
		      FALSE))))))

; posix_setegid --  Set the effective GID of the current process
(defbuiltin (posix_setegid gid)
   (cond-expand
      (PCC_MINGW (mingw-missing 'posix_setegid))
      (else
       (let ((retval (c-setegid (mkfixnum gid))))
	  (cond ((php-= retval 0) TRUE)
		(else (set! *errno* c-errno)
		      FALSE))))))

; posix_getgroups --  Return the group set of the current process
(defbuiltin (posix_getgroups)
   (cond-expand
      (PCC_MINGW (mingw-missing 'posix_getgroups))
      (else
       (let* ((gid-array-ptr (make-gid_t* c-ngroups-max))
	      (group-count (c-getgroups c-ngroups-max gid-array-ptr)))
	  (cond
	     ((php-< group-count 0) ;; negative number of groups means error
	      (set! *errno* c-errno)
	      FALSE)
	     (else
	      (let ((h (make-php-hash)))
		 (let loop ((i 0))
		    (when (< i group-count)
		       (php-hash-insert! h i (gid_t*-ref gid-array-ptr i))
		       (loop (+ i 1))))
		 h)))))))

; posix_getlogin -- Return login name
(defbuiltin (posix_getlogin)
   (cond-expand
      (PCC_MINGW (mingw-missing 'posix_getlogin))
      (else
       ;; note - manpage does not say that getlogin sets errno
       (let ((login (c-getlogin)))
	  (if (string-ptr-null? login)
	      FALSE
	      login)))))

; posix_getpgrp --  Return the current process group identifier
(defbuiltin (posix_getpgrp) 
   (convert-to-integer
    (cond-expand
       (PCC_MINGW (mingw-missing 'posix_getpgrp))
       (else (c-getpgrp)))))

; posix_setsid -- Make the current process a session leader
(defbuiltin (posix_setsid)
   (convert-to-integer
    (cond-expand
       (PCC_MINGW (mingw-missing 'posix_setsid))
       (else (c-setsid)))))

; posix_setpgid -- set process group id for job control
(defbuiltin (posix_setpgid pid pgid)
   (cond-expand
      (PCC_MINGW (mingw-missing 'posix_setpgid))
      (else
       (let ((retval (c-setpgid (mkfixnum pid) (mkfixnum pgid))))
	  (cond ((php-= retval 0) TRUE)
		(else (set! *errno* c-errno)
		      FALSE))))))

; posix_getpgid -- Get process group id for job control
(defbuiltin (posix_getpgid pid)
   (cond-expand
      (PCC_MINGW (mingw-missing 'posix_getpgid))
      (else
       (let ((pgid (c-getpgid (mkfixnum pid))))
	  (cond ((< pgid 0) ;; negative pgid means error
		 (set! *errno* c-errno)
		 FALSE)
		(else (convert-to-integer pgid)))))))

; posix_getsid -- Get the current sid of the process
(defbuiltin (posix_getsid pid)
   (cond-expand
      (PCC_MINGW
       (mingw-missing 'posix_getsid))
      (else
       (let ((sid (c-getsid (mkfixnum pid))))
	  (cond ((< sid 0) ;; negative sid means error
		 (set! *errno* c-errno)
		 FALSE)
		(else (convert-to-integer sid)))))))

; WARNING!! This is very very ugly! But it had to be done.
; OK.. so the members of the utsname struct are all of type char[]
; and bigloo pukes on them if you use the (eval (export-all)) form
; in the module clause. So basically it's one or the other. My
; investigations tell me that this is most like a bug in bigloo.
; Until we have time to figure out what the actual problem is and
; how to solve it, this is an acceptable workaround.
; -Nate
(cond-expand
   (PCC_MINGW #t)
   (else
    (define (workaround-uname)
       ;; basically we create a string large enough to hold all the values
       ;; of all of the struct members plus a newline for each, then we
       ;; execute a block of C code to get all those values and stick 'em
       ;; in the string (picking up the return value along the way so we
       ;; can handle the errno stuff), then we return the return value of
       ;; the uname call and a list which is the big string split on newlines
       (let* ((size::int (* 5 (+ 1 c-sys_nmln)))
	      (str (pragma::string "((char*)GC_MALLOC_ATOMIC((int)$1))" size))
	      (retval::int 0))
	  (pragma
	   "{ struct utsname uts;
          $1 = (int)uname(&uts);
          sprintf((char*)$2,\"%s\\n%s\\n%s\\n%s\\n%s\",
	          uts.sysname,
	          uts.nodename,
                  uts.release,
                  uts.version,
                  uts.machine);
        }" retval str)
	  (values retval (pregexp-split "\n" str))))))

; posix_uname -- Get system name
(defbuiltin (posix_uname)
   (cond-expand
      (PCC_MINGW
       (mingw-missing 'posix_uname))
      (else
       (multiple-value-bind (retval uname-list)
	  (workaround-uname)  ;; this is a hack.. see comment above
	  (cond ((< 0 retval) ;; negative return value means error
		 (set! *errno* c-errno)
		 FALSE)
		(else
		 (let ((h (make-php-hash)))
		    (php-hash-insert! h "sysname" (list-ref uname-list 0))
		    (php-hash-insert! h "nodename" (list-ref uname-list 1))
		    (php-hash-insert! h "release" (list-ref uname-list 2))
		    (php-hash-insert! h "version" (list-ref uname-list 3))
		    (php-hash-insert! h "machine" (list-ref uname-list 4))
		    h)))))))

; posix_times -- Get process times
(defbuiltin (posix_times)
   (cond-expand
      (PCC_MINGW
       (mingw-missing 'posix_times))
      (else
       (let* ((t (make-struct-tms*))
	      (h (make-php-hash))
	      (ticks (c-times t))) ;; writes to the time-struct t
	  (cond ((< ticks 0) ;; negative ticks means error
		 (set! *errno* c-errno)
		 FALSE)
		(else
		 (php-hash-insert! h "ticks" ticks)
		 (php-hash-insert! h "utime" (struct-tms*-tms_utime t))
		 (php-hash-insert! h "stime" (struct-tms*-tms_stime t))
		 (php-hash-insert! h "cutime" (struct-tms*-tms_cutime t))
		 (php-hash-insert! h "cstime" (struct-tms*-tms_cstime t))
		 h))))))

; posix_ctermid -- Get path name of controlling terminal
(defbuiltin (posix_ctermid)
   (cond-expand
      (PCC_MINGW (mingw-missing 'posix_ctermid))
      (else
       ;; note - manpage does not say that ctermid sets errno
       (let ((termid (c-ctermid (make-null-char*))))
	  (if (string-ptr-null? termid)
	      FALSE
	      termid)))))

; posix_ttyname -- Determine terminal device name
(defbuiltin (posix_ttyname fd)
   (cond-expand
      (PCC_MINGW #t)
      (else
       ;; NOTE - manpage does not say that ttyname sets errno
       (let ((ttyname (c-ttyname (mkfixnum fd))))
	  (if (string-ptr-null? ttyname)
	      FALSE
	      ttyname)))))

; posix_isatty --  Determine if a file descriptor is an interactive terminal
(defbuiltin (posix_isatty fd)
   (if (= 1 (c-isatty (mkfixnum fd)))
       TRUE
       FALSE))

; posix_getcwd -- Pathname of current directory
(defbuiltin (posix_getcwd)
   (pwd))

; posix_mkfifo --  Create a fifo special file (a named pipe)
(defbuiltin (posix_mkfifo pathname mode)
   (cond-expand
      (PCC_MINGW #t)
      (else
       ;; XXX When safe mode is enabled, PHP checks whether the directory in which
       ;; you are about to operate has the same UID as the script that is being
       ;; executed.
       (let ((retval (c-mkfifo (mkstr pathname) (mkfixnum mode))))
	  (cond ((= retval 0) TRUE)
		(else (set! *errno* c-errno)
		      FALSE))))))

; extract the members from a group struct's member array and return as a list
(define (group-members mem-array)
   ;; the member array in some cases appears to be larger than the
   ;; actual number of members, and it also appears that they use
   ;; a 0 length string as a sort of terminator, so we loop through
   ;; the array until we see either a null pointer *or* a 0 length string
   (let loop ((index 0) (the-list '()))
      (let ((elt (char**-ref mem-array index)))
	 (if (or (string-ptr-null? elt)
		 (= (string-length elt) 0))
	     (list->php-hash (reverse! the-list))
	     (loop (+ index 1) (cons elt the-list))))))

; convert a group structure to a php hash
(define (group-struct->php-hash g)
   (let ((h (make-php-hash)))
      (cond-expand
	 (PCC_MINGW
	  h)
	 (else
	  (php-hash-insert! h "name" (struct-group*-gr_name g))
	  (php-hash-insert! h "passwd" (struct-group*-gr_passwd g))
	  (php-hash-insert! h "members" (group-members (struct-group*-gr_mem g)))
	  (php-hash-insert! h "gid" (convert-to-integer (struct-group*-gr_gid g)))
	  h))))

; posix_getgrnam -- Return info about a group by name
(defbuiltin (posix_getgrnam name)
   (cond-expand
      (PCC_MINGW (mingw-missing 'posix_getgrnam))
      (else
       ;; note - manpage does not say that getgrnam sets errno
       (let ((gstruct (c-getgrnam (mkstr name))))
	  (if (struct-group*-null? gstruct)
	      FALSE
	      (group-struct->php-hash gstruct))))))

; posix_getgrgid -- Return info about a group by group id
(defbuiltin (posix_getgrgid gid)
   (cond-expand
      (PCC_MINGW (mingw-missing 'posix_getgrgid))
      (else
       ;; note - manpage does not say that getgrgid sets errno
       (let ((gstruct (c-getgrgid (mkfixnum gid))))
	  (if (struct-group*-null? gstruct)
	      FALSE
	      (group-struct->php-hash gstruct))))))

; convert a passwd structure to a php hash
(cond-expand
   (PCC_MINGW #t)
   (else
    (define (passwd-struct->php-hash p)
       (let ((h (make-php-hash)))
	  (php-hash-insert! h "name" (struct-passwd*-pw_name p))
	  (php-hash-insert! h "passwd" (struct-passwd*-pw_passwd p))
	  (php-hash-insert! h "uid" (convert-to-integer (struct-passwd*-pw_uid p)))
	  (php-hash-insert! h "gid" (convert-to-integer (struct-passwd*-pw_gid p)))
	  (php-hash-insert! h "gecos" (struct-passwd*-pw_gecos p))
	  (php-hash-insert! h "dir" (struct-passwd*-pw_dir p))
	  (php-hash-insert! h "shell" (struct-passwd*-pw_shell p))
	  h))))

; posix_getpwnam -- Return info about a user by username
(defbuiltin (posix_getpwnam username)
   (cond-expand
      (PCC_MINGW (mingw-missing 'posix_getpwnam))
      (else
       ;    ;; note - manpage does not say that getpwnam sets errno
       (let ((pstruct (c-getpwnam (mkstr username))))
	  (if (struct-passwd*-null? pstruct)
	      FALSE
	      (passwd-struct->php-hash pstruct))))))

; posix_getpwuid -- Return info about a user by user id
(defbuiltin (posix_getpwuid uid)
   (cond-expand
      (PCC_MINGW (mingw-missing 'posix_getpwuid))
      (else
       ;    ;; note - manpage does not say that getpwuid sets errno
       (let ((pstruct (c-getpwuid (mkfixnum uid))))
	  (if (struct-passwd*-null? pstruct)
	      FALSE
	      (passwd-struct->php-hash pstruct))))))

; resources and resource names for posix_getrlimit
; in each sublist, the car is the integer resource-id, the cadr
; is the php name for the current value for this resource, and
; the caddr is the php name for the max value for this resource
(cond-expand
   (PCC_MINGW
    (define *resources* '()))
   (else
    (define *resources*
       `((,c-rlimit_core    "soft core"      "hard core")
	 (,c-rlimit_data    "soft data"      "hard data")
	 (,c-rlimit_stack   "soft stack"     "hard stack")
	 ; not really posix (problem for freebsd?)
	 (,c-rlimit_as      "soft totalmem"  "hard totalmem")
	 (,c-rlimit_rss     "soft rss"       "hard rss")
	 (,c-rlimit_nproc   "soft maxproc"   "hard maxproc")
	 (,c-rlimit_memlock "soft memlock"   "hard memlock")
	 (,c-rlimit_cpu     "soft cpu"       "hard cpu")
	 (,c-rlimit_fsize   "soft filesize"  "hard filesize")
	 (,c-rlimit_nofile  "soft openfiles" "hard openfiles")))))


; check if the limit for a given resource R is equal to the RLIM_INFINITY
; if it is, return the string "unlimited", else just return the value
(define (rlimit-or-unlimited r)
   (cond-expand
      (PCC_MINGW "unlimited")
      (else
       (if (= r c-rlim_infinity)
	   "unlimited"
	   r))))

; posix_getrlimit -- Return info about system resource limits
(defbuiltin (posix_getrlimit)
   (let ((h (make-php-hash)))
      (cond-expand
	 (PCC_MINGW
	  h)
	 (else
	  (let loop ((resource (car *resources*)) (rlist (cdr *resources*)))
	     (let* ((r (make-struct-rlimit*))
		    (retval (c-getrlimit (car resource) r))) ;; writes to r
		(cond
		   ((= retval 0) ;; 0 means success
		    ;; function call succeeded, so insert current and max values
		    ;; for the current resource into the php-hash
		    (php-hash-insert! h
				      (cadr resource)
				      (rlimit-or-unlimited
				       (struct-rlimit*-rlim_cur r)))
		    (php-hash-insert! h
				      (caddr resource)
				      (rlimit-or-unlimited
				       (struct-rlimit*-rlim_max r)))
		    ;; if no more resources, return the php-hash, else continue
		    (if (null? rlist)
			h 
			(loop (car rlist) (cdr rlist))))
		   (else  ;; retval was non-zero
		    ;; function call failed, so set *errno* and return false
		    (set! *errno* c-errno)
		    FALSE))))))))

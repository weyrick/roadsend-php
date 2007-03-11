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

(module php-files-lib
   (import (php-string-lib "php-strings.scm"))
   (include "../phpoo-extension.sch")
   (include "php-streams.sch")
   (library php-runtime)
   (library profiler)
   (import (streams-c-bindings "streams-c-bindings.scm"))
   (import (php-streams-lib "php-streams.scm"))
   (import (time-c-bindings "time-c-bindings.scm"))
   (export
    (init-php-files-lib)
    (php-basename path suffix) ; suffix is optional
    (chgrp filename group) 
    (php-chmod filename mode)
    (php-chdir path)
    (chown filename user)  
    (clearstatcache)
    (copy source dest)
    (php-dirname path)
    (disk_free_space directory)
    (disk_total_space directory)
    (fclose handle)
    (feof handle)
    (fflush handle)
    (fgetc handle)
    (fgetcsv handle length delimiter enclosure) ; delimiter, enclosure are optional
    (fgets handle length) ; length is optional
    (fgetss handle length allowable_tags) ; allowable_tags is optional
    (file_exists filename)
    (file_get_contents filename use_include_path context) ; use_include_path, context are optional
;    (file_put_contents filename data flags context) ; flags, context are optional
    (file filename use_include_path context) ; use_include_path, context are optional
    (fileatime filename)
    (filectime filename)
    (filegroup filename)
    (fileinode filename)
    (filemtime filename)
    (fileowner filename)
    (fileperms filename)
    (filesize filename)
    (filetype filename)
    (php-flock handle operation wouldblock) ; wouldblock is optional
    (fnmatch patten string flags) ; flags is optional
    (php-fopen filename mode use_include_path zcontext) ; use_include_path, zcontext are optional
    (fread handle length)
    (fscanf handle format var1) ; var1 is optional
    (fseek handle offset whence) ; whence is optional
    (fstat handle)
    (ftell handle)
    (ftruncate handle size)
    (fwrite handle string length) ; length is optional
    ;(glob pattern flags) ; flags is optional
    (is_dir filename)
    (is_executable filename)
    (is_file filename)
    (is_link filename)
    (is_readable filename)
    ;(is_uploaded_file filename)
    (is_writable filename)
    (link target link)
    ;(linkinfo path)
    ;(lstat filename)
    (php-mkdir pathname mode) ; mode is optional
    (parse_ini_file filename process_sections) ; process_sections is optional
    (pathinfo path)
    (pclose handle)
    (popen command mode)
    (readfile filename use_include_path context) ; use_include_path, context are optional
    ;(php-readlink path)
    (realpath path)
    (rename oldname newname)
    (rewind handle)
    (rmdir dirname)
    ;(set_file_buffer stream buffer) ; alias of stream_set_write_buffer.. a streams function
    (php-stat filename)
    (symlink target link)
    (tempnam dir prefix)
    ;(tmpfile)
    (touch filename time atime) ; time, atime are optional
    (umask mask) ; mask is optional
    (unlink filename)
    ; other file related builtins
    (dir path)
    (getcwd)
    (opendir path)
    (readdir dirhandle)
    (rewinddir dirhandle)
    (closedir dirhandle)
    ; constants
    STDIN
    STDOUT
    STDERR
    SEEK_SET
    SEEK_END
    SEEK_CUR
    LOCK_SH
    LOCK_EX
    LOCK_UN
    LOCK_NB
    ))

;;;
;;; Module Init
;;; ===========

(define (init-php-files-lib)
   1)

;;;
;;; Constants
;;; =========

(defconstant STDIN  (local-file-stream "STDIN"  (pragma::FILE* "stdin")  #t #f))
(defconstant STDOUT (local-file-stream "STDOUT" (pragma::FILE* "stdout") #f #t))
(defconstant STDERR (local-file-stream "STDERR" (pragma::FILE* "stderr") #f #t))

(defconstant SEEK_SET (int->onum (pragma::int "SEEK_SET")))
(defconstant SEEK_END (int->onum (pragma::int "SEEK_END")))
(defconstant SEEK_CUR (int->onum (pragma::int "SEEK_CUR")))

(defconstant LOCK_SH  1)
(defconstant LOCK_EX  2)
(defconstant LOCK_UN  8)
(defconstant LOCK_NB  4)

;;;
;;; Resources
;;; =========

;; php directory handle (just two pointers to a list of files)
(defresource directory-handle
   "stream"
   (files '())
   (next-file '()))

;;;
;;; Utility Functions
;;; =================

; check if an optional parameter was provided
(define (passed? arg)
   (not (eqv? arg 'unpassed)))

; check if an optional parameter was *not* provided
(define (unpassed? arg)
   (eqv? arg 'unpassed))

; get the st_blksize member of a stat struct
(define (stat-blksize::ulong o::stat)
   (cond-expand
      (PCC_MINGW 0)
      (else
       (let ((result (pragma::ulong "$1->st_blksize" o)))
	  result))))

; get the st_blocks member of a stat struct
(define (stat-blocks::ulong o::stat)
   (cond-expand
      (PCC_MINGW 0)
      (else
       (let ((result (pragma::ulong "$1->st_blocks" o)))
	  result))))

; coerce an stmode object to a mode_t type
(define (stmode->mode_t::pfl-mode_t s::stmode)
   (let ((result (pragma::pfl-mode_t "$1" s)))
      result))

; convert a stat struct to a php hash
(define (stat-struct->php-hash s)
    (let ((h       (make-php-hash))
	  (dev     (convert-to-integer (stat-dev s)))
	  (ino     (convert-to-integer (stat-ino s)))
	  (mode    (convert-to-integer (stmode->mode_t (stat-mode s))))
	  (nlink   (convert-to-integer (stat-nlink s)))
	  (uid     (convert-to-integer (stat-uid s)))
	  (gid     (convert-to-integer (stat-gid s)))
	  (rdev    (convert-to-integer (stat-rdev s)))
	  (size    (convert-to-integer (stat-size s)))
	  (atime   (convert-to-integer (stat-atime s)))
	  (mtime   (convert-to-integer (stat-mtime s)))
	  (ctime   (convert-to-integer (stat-ctime s)))
	  (blksize (convert-to-integer (stat-blksize s)))
	  (blocks  (convert-to-integer (stat-blocks s))))
       (php-hash-insert! h :next     dev)
       (php-hash-insert! h :next     ino)
       (php-hash-insert! h :next     mode)
       (php-hash-insert! h :next     nlink)
       (php-hash-insert! h :next     uid)
       (php-hash-insert! h :next     gid)
       (php-hash-insert! h :next     rdev)
       (php-hash-insert! h :next     size)
       (php-hash-insert! h :next     atime)
       (php-hash-insert! h :next     mtime)
       (php-hash-insert! h :next     ctime)
       (php-hash-insert! h :next     blksize)
       (php-hash-insert! h :next     blocks)
       (php-hash-insert! h "dev"     dev)
       (php-hash-insert! h "ino"     ino)
       (php-hash-insert! h "mode"    mode)
       (php-hash-insert! h "nlink"   nlink)
       (php-hash-insert! h "uid"     uid)
       (php-hash-insert! h "gid"     gid)
       (php-hash-insert! h "rdev"    rdev)
       (php-hash-insert! h "size"    size)
       (php-hash-insert! h "atime"   atime)
       (php-hash-insert! h "mtime"   mtime)
       (php-hash-insert! h "ctime"   ctime)
       (php-hash-insert! h "blksize" blksize)
       (php-hash-insert! h "blocks"  blocks)
       h))

; convert a group name string into a group id
(define (groupname->gid name)
   (cond-expand
      (PCC_MINGW -1)
      (else
       (let* ((name::string (mkstr name))
	      (gstruct (pragma::void* "getgrnam($1)" name))) ;(pfl-getgrnam name)))
	  (if (pragma::bool "$1 == NULL" gstruct);(pfl-struct-group*-null? gstruct)
	      -1  ; if you pass a -1 to chown it means not to change anything
	      ;(pfl-struct-group*-gr_gid gstruct)
	      (pragma::pfl-gid_t "((struct group*)$1)->gr_gid" gstruct))))))

; convert a username string into a userid
(define (username->uid name)
   (cond-expand
      (PCC_MINGW -1)
      (else
       (let* ((name::string (mkstr name))
	      (pstruct (pragma::void* "getpwnam($1)" name))) ;(pfl-getpwnam name)))
	  (if (pragma::bool "$1 == NULL" pstruct);(pfl-struct-passwd*-null? pstruct)
	      -1  ; if you pass a -1 to chown it means not to change anything
	      ;(pfl-struct-passwd*-pw_uid pstruct)
	      (pragma::pfl-uid_t "((struct passwd*)$1)->pw_uid" pstruct))))))

(define (wait-for-read fd::int timeout-sec::int timeout-usec::int)
   (and fd (let ((retval::int 0))
	      (pragma "
                { fd_set rfds;
                  struct timeval tv;
                  FD_ZERO(&rfds);
                  FD_SET((int)$1, &rfds);
                  tv.tv_sec = (long)$2;
                  tv.tv_usec = (long)$3;
                  $4 = select(((int)$1) + 1, &rfds, NULL, NULL, &tv);
                }" fd timeout-sec timeout-usec retval)
	      (cond 
		((> retval 0) #t)
		((= retval 0) #f)
		((< retval 0) (php-warning "select error, errno: " 
					   (cond-expand
					      (PCC_MINGW
					       (pragma::int "WSAGetLastError()"))
					      (else
					       (pragma::int "errno")))))))))


(define (socket-alive? fd)
   ;; if select says there's data available, but recv can't get any
   ;; data, then the socket is closed.  (wtf?)
   (and (wait-for-read fd 0 0)
        (not (socket-read-returns-data fd))))

   
(define (wait-for-write fd::int timeout-sec::int timeout-usec::int)
   (and fd (let ((retval::int 0))
	      (pragma "
                { fd_set wfds;
                  struct timeval tv;
                  FD_ZERO(&wfds);
                  FD_SET((int)$1, &wfds);
                  tv.tv_sec = (long)$2;
                  tv.tv_usec = (long)$3;
                  $4 = select(((int)$1) + 1, NULL, &wfds, NULL, &tv);
                }" fd timeout-sec timeout-usec retval)
	      (if (< 0 retval)
		  #t
		  #f))))

(define (wait-for-except fd::int timeout-sec timeout-usec)
   (and fd (let ((retval 0))
	      (pragma "
                { fd_set efds;
                  struct timeval tv;
                  FD_ZERO(&efds);
                  FD_SET((int)$1, &efds);
                  tv.tv_sec = (long)$2;
                  tv.tv_usec = (long)$3;
                  $4 = select(((int)$1) + 1, NULL, NULL, &efds, &tv);
                }" fd timeout-sec timeout-usec retval)
	      (if (< 0 retval)
		  #t
		  #f))))

;;;
;;; Filesystem Functions
;;; ====================

;; basename -- Returns filename component of path
(defalias basename php-basename) ; basename is a bigloo function
(defbuiltin (php-basename path (suffix 'unpassed))
   (let ((the-basename (basename (mkstr path))))
      (if (passed? suffix)
	  (let* ((suffix (mkstr suffix))
		 (suffix-len (string-length suffix))
		 (basename-len (string-length the-basename))
		 (base-minus-suffix-len (- basename-len suffix-len))
		 (substr (substring the-basename base-minus-suffix-len basename-len)))
	     (if (string=? substr suffix)
		 (substring the-basename 0 base-minus-suffix-len)
		 the-basename))
	  the-basename)))

;; chdir -- Change directory
(defalias chdir php-chdir)
(defbuiltin (php-chdir path)
   (if (chdir path)
       TRUE
       FALSE))

;; chgrp -- Changes file group
(defbuiltin (chgrp filename group)
   (cond-expand
      (PCC_MINGW (mingw-missing 'chgrp))
      (else 
       (let* ((group (if (number? group)
			 group
			 (groupname->gid (mkstr group))))
	      (retval (pfl-chown (mkstr filename) -1 group))) ; -1 means don't change the owner
	  (if (zero? retval)
	      TRUE
	      FALSE)))))

;; chmod -- Changes file mode
(defalias chmod php-chmod)
(defbuiltin (php-chmod filename mode)
   (let ((filename (mkstr filename)))
      (if (file-exists? filename)
	  (let ((retval (pfl-chmod filename (mkfixnum mode))))
	     (if (zero? retval)
		 TRUE
		 FALSE))
	  FALSE)))

;; chown -- Changes file owner
(defbuiltin (chown filename user)
   (cond-expand
      (PCC_MINGW TRUE) ;yes, in php, on windows, chgrp returns FALSE and chown returns TRUE.
      (else
       (let* ((user (if (number? user)
			user
			(username->uid (mkstr user))))
	      (retval (pfl-chown (mkstr filename) user -1))) ; -1 means don't change the group
	  (if (zero? retval)
	      TRUE
	      FALSE)))))

;; clearstatcache -- Clears file status cache
(defbuiltin (clearstatcache)
   ;;; For some reason the Zend guys are caching the results of calls to
   ;;; stat. I don't see the point of this, so for now stat just gets the
   ;;; info fresh everytime and clearstatcache does nothing.
   TRUE)

;; copy -- Copies file
(defbuiltin (copy source dest)
   ; runtime/utils.scm
   (if (copy-file (mkstr source) (mkstr dest))
       TRUE
       FALSE))

;; dirname -- Returns directory name component of path

; windows emulation frobbing
; this is only because we use bigloo's dirname, which works
; different from php. we should probably just implement our own
; that is more compatible
(define (frob-dirname dir)
  (if (and (= (string-length dir) 2)
	   (char=? (string-ref dir 1) #\:)
	   (char-alphabetic? (string-ref dir 0)))
      dir
      (let* ((fdir (if (and (> (string-length dir) 3)
			    (or (char=? (string-ref dir (- (string-length dir) 1)) #\\)
				(char=? (string-ref dir (- (string-length dir) 1)) #\/)))
		       (substring dir 0 (- (string-length dir) 1))
		       dir))
	     (newdir (dirname fdir)))
	; if we end in :, add a \
	(if (char=? (string-ref newdir (- (string-length newdir) 1)) #\:)
	    (mkstr newdir "\\")
	    newdir))))

(defalias dirname php-dirname)
(defbuiltin (php-dirname path)
   (let ((spath (mkstr path)))
      (if (string=? "" spath)
	  ""
	  (cond-expand (PCC_MINGW (frob-dirname spath))
		       (else (dirname spath))))))

;; disk_free_space -- Returns available space in directory
(defalias diskfreespace disk_free_space)
(defbuiltin (disk_free_space directory)
   (cond-expand
      (PCC_MINGW (mingw-missing 'disk_free_space))
      (else
       (let ((freespace::double (fixnum->flonum 0))
	     (retval::int 0)
	     (directory::string (mkstr directory)))
	  (pragma
	   "{ struct statfs buf;
          $1 = (int)statfs((char *)$3, &buf);
          $2 = (((double)buf.f_bavail) * ((double)buf.f_bsize));
        }" retval freespace directory)
	  (if (zero? retval)
	      (convert-to-float freespace)
	      FALSE)))))
   
;;;; Correct Version for when bigloo bug with array struct members is fixed   
;    (let* ((s (make-pfl-struct-statfs*))
; 	  (retval (pfl-statfs (mkstr directory) s)))
;       (if (zero? retval)
; 	  (* (pfl-struct-statfs*-f_bavail s) (pfl-struct-statfs*-f_bsize s))
; 	  FALSE)))

;; disk_total_space -- Returns the total size of a directory
(defbuiltin (disk_total_space directory)
   (cond-expand
      (PCC_MINGW (mingw-missing 'disk_total_space))
      (else
       (let ((totalspace::double (fixnum->flonum 0))
	     (retval::int 0)
	     (directory::string (mkstr directory)))
	  (pragma
	   "{ struct statfs buf;
          $1 = (int)statfs((char *)$3, &buf);
          $2 = (((double)buf.f_blocks) * ((double)buf.f_bsize));
        }" retval totalspace directory)
	  (if (zero? retval)
	      (convert-to-float totalspace)
	      FALSE)))))

;;;; Correct Version for when bigloo bug with array struct members is fixed
;    (let* ((s (make-pfl-struct-statfs*))
; 	  (retval (pfl-statfs (mkstr directory) s)))
;       (if (zero? retval)
; 	  (* (pfl-struct-statfs*-f_blocks s) (pfl-struct-statfs*-f_bsize s))
; 	  FALSE)))

;; fclose -- Closes an open file pointer
(defbuiltin (fclose handle)
   (if (or (readable-stream? handle)
	   (writeable-stream? handle))
       (case (stream-type handle)
 	  ((local-file socket)
	   (and-let* ((file-ptr (stream-file-ptr handle)))
		     (pfl-fclose file-ptr))
           (stream-file-ptr-set! handle #f)
 	   (stream-close! handle)
           (set! *stream-resource-counter* (- *stream-resource-counter* 1))
 	   TRUE)
	  ((remote-file)           
	   (stream-close! handle)
           (set! *stream-resource-counter* (- *stream-resource-counter* 1))
	   TRUE)
	  (else FALSE))
       FALSE))

;; feof -- Tests for end-of-file on a file pointer
(defbuiltin (feof handle)
   (if (readable-stream? handle)
       (case (stream-type handle)
	 ((socket)
          (socket-alive? (php-stream-fd handle)))
;           ; XXX likely not to work on windows
;           (if (zero? (pfl-feof (stream-file-ptr handle)))
; 	       FALSE
; 	       TRUE))
	  ((local-file process)  
	   (if (zero? (pfl-feof (stream-file-ptr handle)))
	       FALSE
	       TRUE))
	  ((remote-file)
	   (if (eof-object? (peek-char (stream-in-port handle)))
	       TRUE
	       FALSE))
	  ((extended)
	   ;; this is kind of a hack
	   (if (extended-stream-read handle 0)
	       FALSE
	       TRUE))
	  (else FALSE))
       TRUE))

;; fflush -- Flushes the output to a file
(defalias fpassthru fflush)
(defbuiltin (fflush handle)
   (if (writeable-stream? handle)
       (case (stream-type handle)
	 ((socket) TRUE)
	  ((local-file process)
	   (if (zero? (pfl-fflush (stream-file-ptr handle)))
	       TRUE
	       FALSE))
	  ((remote-file)
	   (flush-output-port (stream-out-port handle))
	   TRUE)
	 (else FALSE))
       FALSE))

;; fgetc -- Gets character from file pointer
(defbuiltin (fgetc handle)
   (let ((c (internal-fgetc handle)))
      (if (char? c)
	  (string c)
	  c)))

;; the internal-fgetc functions are split off so that they can
;; efficiently be used by other builtins like fgets
(define (internal-fgetc handle)
   "read a character from a handle, returns the char or FALSE"
   (if (readable-stream? handle)
       (case (stream-type handle)
	 ((socket)
	  (cond-expand
	     (PCC_MINGW
	      (if (stream-blocking? handle)
		  (internal-sock-fgetc handle)
		  (internal-sock-fgetc-nonblock handle)))
	     (else
	      (if (stream-blocking? handle)
		  (internal-local-fgetc handle)
		  (internal-local-fgetc-nonblock handle)))))
	 ((local-file process)
	  (if (stream-blocking? handle)
	      (internal-local-fgetc handle)
	      (internal-local-fgetc-nonblock handle)))
	 ((remote-file)
	  (if (stream-blocking? handle)
	      (internal-remote-fgetc handle)
	      (internal-remote-fgetc-nonblock handle)))
	 ((extended)
	  (if (stream-blocking? handle)
	      (let ((c (extended-stream-read handle 1)))
		 (if (string? c) (string-ref c 0) #f))
	      (begin
	       (php-warning "non-blocking reads not yet implemented for extended curl streams")
	       FALSE)))
	 (else FALSE))
       FALSE))


(cond-expand
   (PCC_MINGW
    (define *socket-buffers* (make-hashtable))
    (define (internal-sock-fgetc handle)
       "read a char from a FILE*"
       (let* ((fd (php-stream-fd handle))
	      (buffer (hashtable-get *socket-buffers* fd)))
	  (when (or (not buffer) (string=? buffer ""))
	     (set! buffer (bigloo-recv (php-stream-fd handle) 8192)))
	  ; 	 (let ((buf::string (make-string 8192)))
	  ; 	    (let ((bytes-read (pragma::int "recv($1, $2, $3, 0)"
	  ; 					   (php-stream-fd handle)
	  ; 					   buf 8192)))
	  ; 	       (if (or (zero? bytes-read)
	  ; 		       (and (= bytes-read -1)
	  ; 			    (not (= (pragma::int "WSAGetLastError()")
	  ; 				    (pragma::int "WSAEWOULDBLOCK")))))
	  ; 		   (begin
	  ; 		    (php-warning "read error on socket: " (pragma::int "WSAGetLastError()"))
	  ; 		    (set! buffer ""))
	  ; 		   (set! buffer (string-shrink! buf bytes-read)))
	  ; 	       (hashtable-put! *socket-buffers* fd buffer))))
	  (if (and buffer (> (string-length buffer) 0))
	      (begin
		 (hashtable-put! *socket-buffers* fd (substring buffer 1 (string-length buffer)))
		 (string-ref buffer 0))
	      FALSE)))
      
    (define (internal-sock-fgetc-nonblock handle)
       "read a char from a FILE*"
       (let* ((fd (php-stream-fd handle))
	      (buffer (hashtable-get *socket-buffers* fd)))
	  (when (or (not buffer) (string=? buffer ""))
	     (if (wait-for-read (php-stream-fd  handle) 
				(stream-timeout-sec handle) 
				(stream-timeout-usec handle))
		 (set! buffer (bigloo-recv (php-stream-fd handle) 8192))
		 (set! buffer #f)))
	  ; 	     (let ((buf::string (make-string 8192)))
	  ; 		(let ((bytes-read (pragma::int "recv($1, $2, $3, 0)"
	  ; 					       (php-stream-fd handle)
	  ; 					       buf 8191)))
	  ; 		   (if (or (zero? bytes-read)
	  ; 			   (and (= bytes-read -1)
	  ; 				(not (= (pragma::int "WSAGetLastError()")
	  ; 					(pragma::int "WSAEWOULDBLOCK")))))
	  ; 		       (begin
	  ; 			(php-warning "read error on socket: " (pragma::int "WSAGetLastError()"))
	  ; 			(set! buffer ""))
	  ; 		       (set! buffer (string-shrink! buf bytes-read)))
	  ; 		   (hashtable-put! *socket-buffers* fd buffer)))
	  ; 	     (set! buffer "")))
	  (if (and buffer (> (string-length buffer) 0))
	      (begin
		 (hashtable-put! *socket-buffers* fd (substring buffer 1 (string-length buffer)))
		 (string-ref buffer 0))
	      FALSE))))
   (else))


(define (internal-local-fgetc handle)
   "read a char from a FILE*"
   (let ((retval (pfl-fgetc (stream-file-ptr handle))))
      (if (pragma::bool "$1 == EOF" retval)
	  FALSE
	  (integer->char retval))))

(define (internal-local-fgetc-nonblock handle)
   (if (wait-for-read (php-stream-fd  handle) (stream-timeout-sec handle) (stream-timeout-usec handle))
       (internal-local-fgetc handle)
       FALSE))
   
(define (internal-remote-fgetc handle)
   "read a char from a bigloo port"
   (let ((c (read-char (stream-in-port handle))))
      (if (eof-object? c)
	  FALSE
	  c)))

(define (internal-remote-fgetc-nonblock handle)
   (if (wait-for-read (port->fd (stream-in-port handle)) (stream-timeout-sec handle) (stream-timeout-usec handle))
       (internal-remote-fgetc handle)
       FALSE))
   
;; fgetcsv -- Gets line from file pointer and parses it for CSV fields
(defbuiltin (fgetcsv handle length (delimiter ",") (enclosure "\""))
   (let ((line (fgets handle (mkfixnum length))))
      (if (not (and line (> (string-length line) 0)))
	  FALSE
	  (let* ((line (trim line (list #a032 #a009 #a010 #a013 #a000 #a011)))
		 (delimiter (mkstr delimiter))
		 (enclosure (substring (mkstr enclosure) 0 1))
		 (delim-len (string-length delimiter))
		 (enclo-len (string-length enclosure))
		 (next-token-type (lambda (str)
				     (cond ((substring=? str delimiter delim-len) 'delimiter)
					   ((substring=? str enclosure enclo-len) 'enclosure)
					   ((char=? (string-ref str 0) #\\)       'backslash)
					   (else                                  'tokenchar))))
		 (tokens (make-php-hash))
		 (in-enclosure? #f)
		 (escaped?      #f)
		 (in-token?     #f)
		 (current-token (open-output-string)))
	     (let parse ((str line))
		(let ((length (string-length str)))
		   (if (= 0 length)
		       (if (and in-token? (not in-enclosure?))
			   (begin (php-hash-insert! tokens :next (get-output-string current-token))
				  tokens)
			   tokens)
		       (if in-token?
			   (if in-enclosure?
			       (if escaped?
				   ;; in-token/in-enclosure/escaped
				   (begin (set! escaped? #f)
					  (display (string-ref str 0) current-token)
					  (parse (substring str 1 length)))
				   ;; in-token/in-enclosure/not-escaped
				   (case (next-token-type str)
				      ('backslash (set! escaped? #t)
						  (display (string-ref str 0) current-token)
						  (parse (substring str 1 length)))
				      ('enclosure (set! in-enclosure? #f)
						  (set! in-token? #f)
						  (php-hash-insert! tokens :next (get-output-string current-token))
						  (set! current-token (open-output-string))
						  (parse (substring str enclo-len length)))
				      (else (display (string-ref str 0) current-token)
					    (parse (substring str 1 length)))))
			       (if escaped?
				   ;; in-token/not-in-enclosure/escaped
				   (begin (set! escaped? #f)
					  (display (string-ref str 0) current-token)
					  (parse (substring str 1 length)))
				   ;; in-token/not-in-enclosure/not-escaped
				   (case (next-token-type str)
				      ('backslash (set! escaped? #t)
						  (parse (substring str 1 length)))
				      ('delimiter (php-hash-insert! tokens :next (get-output-string current-token))
						  (set! current-token (open-output-string))
						  (parse (substring str delim-len length)))
				      ('enclosure (set! in-enclosure? #t)
						  (set! current-token (open-output-string))
						  (parse (substring str enclo-len length)))
				      (else (display (string-ref str 0) current-token)
					    (parse (substring str 1 length))))))
			   (if escaped?
			       ;; not-in-token/escaped
			       (begin (set! escaped? #f)
				      (parse (substring str 1 length)))
			       ;; not-in-token/not-escaped
			       (case (next-token-type str)
				  ('backslash (set! escaped? #t)
					      (parse (substring str 1 length)))
				  ('delimiter (set! in-token? #t)
					      (parse (substring str delim-len length)))
				  ('enclosure (set! in-token? #t)
					      (set! in-enclosure? #t)
					      (parse (substring str enclo-len length)))
				  (else (set! in-token? #t)
					(display (string-ref str 0) current-token)
					(parse (substring str 1 length)))))))))))))

;; fgets -- Gets line from file pointer
(defbuiltin (fgets handle (length 'unpassed))
   ;; Returns a string of up to length - 1 bytes read from the file pointed to
   ;; by handle. Reading ends when length - 1 bytes have been read, or a newline
   ;; (which is included in the return value), or an EOF (whichever comes first).
   ;; If no length is specified, the length defaults to 1k, or 1024 bytes.
   ;; If an error occurs, returns FALSE.
   (set! length (if (unpassed? length) 1024 (mkfixnum length)))
   (if (readable-stream? handle)
       (case (stream-type handle)
	  ((local-file process)
	   (if (stream-blocking? handle)
	       (let ((str (c-php-fgets (stream-file-ptr handle) length)))
		  (if (null? str)
		      FALSE
		      str))
	       (if (wait-for-read (php-stream-fd handle) (stream-timeout-sec handle) (stream-timeout-usec handle))
		   (let ((str (c-php-fgets (stream-file-ptr handle) length)))
		      (if (null? str)
			  (begin
; 			   (fprint (current-error-port) "null string")
; 			   (flush-output-port (current-error-port))
			   FALSE)
			  str))
		   (begin
; 		    (fprint (current-error-port) "read timed out")
; 		    (flush-output-port (current-error-port))
		    FALSE))))
	  ((remote-file extended socket)
	   (let ((retval (with-output-to-string
			     (lambda ()
				(let ((c #f))
				   (let loop ((i 1))
					(when (<fx i length)
					   (set! c (internal-fgetc handle))
					   ;; we only loop when c is not #f
					   (when c
					      (display c)
					      (unless (char=? c #\newline)
						 (loop (+fx i 1)))))))))))
	      (if (zero? (string-length retval))
		  FALSE
		  retval)))
	  (else FALSE))
       FALSE))

;; fgetss -- Gets line from file pointer and strip HTML tags
(defbuiltin (fgetss handle length (allowable_tags 'unpassed))
   (let ((line (fgets handle (mkfixnum length))))
      (if line
	  (strip_tags line (if (passed? allowable_tags) allowable_tags ""))
	  FALSE)))

;; file_exists -- Checks whether a file or directory exists
(defbuiltin (file_exists filename)
   (if (file-exists? (mkstr filename))
       TRUE
       FALSE))


(define (end-of-file? value)
   ;;at least extended streams use #f for end of file. --tpd
   (not value))

;; file_get_contents -- Reads entire file into a string
(defbuiltin (file_get_contents filename (use_include_path 'unpassed) (context 'unpassed))
   (let ((s (php-fopen filename "rb" use_include_path context)))
      (cond
	 ((stream? s)
	  (with-output-to-string
	     (lambda ()
		(let loop ((data (fread s 8192)))
		   (display data)
		   (when (= (string-length data) 8192)
		      (loop (fread s 8192)))))))
	 (else
	  (php-warning "failed to open stream for " filename)
	  FALSE))))


;; file_put_contents -- Write a string to a file
;; XXX context ignored for now because stream contexts are not yet implemented -nd
; (defbuiltin (file_put_contents filename data (flags 'unpassed) (context 'unpassed))
;    FALSE)

;; file -- Reads entire file into an array
(defbuiltin (file filename (use_include_path 'unpassed) (context 'unpassed))
   (let ((s (php-fopen filename "rb" use_include_path context)))
      (if (stream? s)
	  (let ((h (make-php-hash)))
	     ;;we just call fgets with a huge chunk size.  This is for speed reasons.
	     ;;I can't think of any faster way to do it. --tim
	     (let loop ((line (fgets s 268435456))) ;256 megs or so
		(when (string? line)
		   (php-hash-insert! h :next line)
		   (loop (fgets s 268435456))))
             (php-funcall 'fclose s)
	     h)
	  FALSE)))

;; fileatime -- Gets last access time of file
(defbuiltin (fileatime filename)
   (let ((filename (mkstr filename)))
      (if (file-exists? filename)
	  (convert-to-integer (stat-atime (stat filename)))
	  FALSE)))

;; filectime -- Gets inode change time of file
(defbuiltin (filectime filename)
   (let ((filename (mkstr filename)))
      (if (file-exists? filename)
	  (convert-to-integer (stat-ctime (stat filename)))
	  FALSE)))

;; filegroup -- Gets file group
(defbuiltin (filegroup filename)
   (let ((filename (mkstr filename)))
      (if (file-exists? filename)
	  (convert-to-integer (stat-gid (stat filename)))
	  FALSE)))

;; fileinode -- Gets file inode
(defbuiltin (fileinode filename)
   (let ((filename (mkstr filename)))
      (if (file-exists? filename)
	  (convert-to-integer (stat-ino (stat filename)))
	  FALSE)))

;; filemtime -- Gets file modification time
(defbuiltin (filemtime filename)
   (let ((filename (mkstr filename)))
      (if (file-exists? filename)
	  (convert-to-integer (stat-mtime (stat filename)))
	  FALSE)))

;; fileowner -- Gets file owner
(defbuiltin (fileowner filename)
   (let ((filename (mkstr filename)))
      (if (file-exists? filename)
	  (convert-to-integer (stat-uid (stat filename)))
	  FALSE)))

;; fileperms -- Gets file permissions
(defbuiltin (fileperms filename)
   (let ((filename (mkstr filename)))
      (if (file-exists? filename)
	  (begin
;       (fprint (current-error-port) "stat-mode: " (stat-mode (stat filename)))
;       (fprint (current-error-port) "mode_t: " (stmode->mode_t (stat-mode (stat filename))))

	   (convert-to-integer (stmode->mode_t (stat-mode (stat filename)))))
	  FALSE)))

;; filesize -- Gets file size
(defbuiltin (filesize filename)
   (if (file-exists? filename)
       (convert-to-integer (file-size filename))
       FALSE))

;; filetype -- Gets file type
(defbuiltin (filetype filename)
   (let ((filename (mkstr filename)))
      (if (file-exists? filename)
	  (let ((mode (stat-mode (stat filename))))
	     (cond ((member 'fifo mode) "fifo")
		   ((member 'fchr mode) "char")
		   ((member 'fdir mode) "dir")
		   ((member 'fblk mode) "block")
		   ((member 'flnk mode) "link")
		   ((member 'freg mode) "file")
		   (else "unknown")))
	  FALSE)))

;; flock -- Portable advisory file locking
(defalias flock php-flock)
(defbuiltin (php-flock handle operation (wouldblock 'unpassed))
   ;; XXX need to handle wouldblock parameter and remote streams
   (if (and (local-stream? handle)
	    (zero? (pfl-flock (pfl-fileno (stream-file-ptr handle)) (mkfixnum operation))))
       TRUE
       FALSE))

;; fnmatch -- Match filename against a pattern
(defbuiltin (fnmatch pattern string (flags 'unpassed))
   (cond-expand
      (PCC_MINGW (mingw-missing 'fnmatch))
      (else
       (let* ((pattern (mkstr pattern))
	      (string (mkstr string))
	      (flags (if (passed? flags) flags 0))
	      (retval (pfl-fnmatch pattern string flags)))
	  (if (zero? retval)
	      TRUE
	      FALSE)))))

(defalias fopen php-fopen)
;; fopen -- Opens file or URL
(defbuiltin (php-fopen filename mode (use_include_path 'unpassed) (zcontext 'unpassed))
   (let ((retval
          (let* ((filename (mkstr filename))
                 (filename (if (substring=? filename "file://" 7)
                               (substring filename 6 (string-length filename))
                               filename))
                 (mode (mkstr mode))
                 (in-open? (or (substring=? mode "r" 1)
                               (substring=? mode "a+" 2)
                               (substring=? mode "w+" 2)))
                 (out-open? (or (substring=? mode "w" 1)
                                (substring=? mode "a" 1)
                                (substring=? mode "r+" 2)))
                 (append? (substring=? mode "a" 1)))
             (string-case filename
                ("php://stdin" ;; standard input
                 (if (and in-open? (not out-open?))
                     STDIN
                     FALSE))
                ("php://stdout" ;; standard output
                 (if (and out-open? (not in-open?))
                     STDOUT
                     FALSE))
                ("php://stderr" ;; standard error output
                 (if (and out-open? (not in-open?))
                     STDERR
                     FALSE))
                ((bol (: (+ all) "://"))
                 (let* ((protocol (car (pregexp-split "://" filename)))
                        (stream-wrapper (lookup-stream-wrapper protocol)))
                    (debug-trace 3 "tried to lookup stream wrapper for " protocol ", found " stream-wrapper)
                    (if stream-wrapper
                        ((stream-wrapper-open-fun stream-wrapper)
                         stream-wrapper filename mode #f #f)
                        ;; remote file
                        (let ((remote-file
                               (remote-file-stream filename
                                                   (and in-open? (open-input-file filename))
                                                   (and out-open? (if append?
                                                                      (append-output-file filename)
                                                                      (open-output-file filename)))
                                                   in-open?
                                                   out-open?)))
                           (if (or (and in-open? (not (stream-in-port remote-file)))
                                   (and out-open? (not (stream-out-port remote-file))))
                               FALSE
                               remote-file)))))
                (else
                 ;; local file
                 (let* ((filename (if (passed? use_include_path)
                                      (let ((found (find-file/path filename *include-paths*)))
                                         (if found found filename))
                                      filename))
                        (file-ptr (pfl-fopen filename mode)))
                    (if (pragma::bool "$1 == NULL" file-ptr)
                        FALSE
                        (local-file-stream filename file-ptr in-open? out-open?))))))))
      (if (php-= retval FALSE)
          (php-warning "failed to open stream: " (pragma::string "strerror(errno)"))
          retval)))

;;supposedly, this is unreliable
(define (waiting-to-be-read handle)
   (let ((amt (pragma::int "0")))
      (let ((retval (pragma::int "ioctlsocket($1, FIONREAD, (long *)&$2)" 
				 (php-stream-fd handle) amt)))
	 (if (zero? retval)
	     amt
	     (begin
	      (php-warning "Couldn't determine how much data is waiting to be read, error " 
			   (pragma::int "WSAGetLastError()"))
	      0)))))


(define (fread-internal-nonblock handle length::int)
   (cond-expand
      (PCC_MINGW
       (flush-output-port (current-error-port))
       (if (wait-for-read (php-stream-fd handle) 
			  (stream-timeout-sec handle) 
			  (stream-timeout-usec handle))
	   ;       (set-sock-nonblocking! (php-stream-fd handle))
	   (bigloo-recv (php-stream-fd handle) 8192)
	   FALSE))
      (else
       (if (wait-for-read (php-stream-fd handle) ;(file->fd (stream-file-ptr handle))
			  (stream-timeout-sec handle) (stream-timeout-usec handle))
	   (let* ((buf (make-string length))
		  (actually-read (pfl-fread buf 1 length (stream-file-ptr handle))))
	      (unless (= actually-read length)
		 (set! buf (string-shrink! buf actually-read)))
	      buf)
	   ""))))



;; fread -- Binary-safe file read
(defbuiltin (fread handle length)
   ;; fread() reads up to length bytes from the file pointer referenced by handle.
   ;; Reading stops when length bytes have been read or EOF (end of file) reached,
   ;; whichever comes first.
   (if (readable-stream? handle)
       (let ((length (mkfixnum length)))
	  (case (stream-type handle)
	     ((extended)
	      (let ((data (extended-stream-read handle length)))
		 (if (end-of-file? data)
		     ""
		     data)))
	     ((local-file process)
	      ;; the fast path, using libc fread()
;	      (if (stream-blocking? handle)
		  (let* ((buf (make-string length))
			 (actually-read  (pfl-fread buf 1 length (stream-file-ptr handle))))
		     (unless (= actually-read length)
			(set! buf (string-shrink! buf actually-read)))
		     buf))
;		  (fread-internal-nonblock handle length)))
             ((socket)
              ;; returns "as soon as a packet is available"
              (if (stream-blocking? handle)
                  (begin
                     ;(fprint (current-error-port) "blocking? ")
                     ;(set-stream-blocking! handle)
                     (bigloo-recv (php-stream-fd handle) length))
                  (if (wait-for-read (php-stream-fd handle) 
                                     (stream-timeout-sec handle) 
                                     (stream-timeout-usec handle))
                      (bigloo-recv (php-stream-fd handle) length)
                      "")))
	   ;       (set-sock-nonblocking! (php-stream-fd handle))
;              (fread-internal-nonblock handle length))
	     ((remote-file)
	      ;; slower, in terms of fgetc, for the other cases (remote streams)
	      ;; not because it needs to be, just because I have neither tests nor time
	      ;; -tim
	      (let ((result 
		     (with-output-to-string
			 (lambda ()
			    (let ((fgetc-func (if (stream-blocking? handle)
						  internal-remote-fgetc
						  internal-remote-fgetc-nonblock)))
			       (let loop ((c (fgetc-func handle)) (cnum length))
				    (when (and c (> cnum 0))
				       (display c)
				       (loop (if (> cnum 1) (fgetc-func handle) c) (- cnum 1) ) )))))))
		 (if (zero? (string-length result))
		     FALSE
		     result)))
	     (else FALSE)))
       (begin 
	  (php-warning "supplied argument is not a readable stream resource")
	  FALSE)))
	
   
;; fscanf -- Parses input from a file according to a format
(defbuiltin (fscanf handle format ((ref . var1) 'unpassed))
   (if (readable-stream? handle)
       (sscanf (fread handle (filesize (stream-name handle))) format var1)
       FALSE))

;; fseek -- Seeks on a file pointer
(defbuiltin (fseek handle offset (whence SEEK_SET))
   (if (and (local-stream? handle) (stream-readable? handle))
       (let* ((offset (mkfixnum offset))
	      (whence (mkfixnum whence)))
	  (if (zero? (pfl-fseek (stream-file-ptr handle) offset whence))
	      *zero*
              (begin
                 (php-warning "Seek error: " (pragma::string "strerror(errno)"))
                 (int->onum -1))))
       FALSE))

;; fstat -- Gets information about a file using an open file pointer
(defbuiltin (fstat handle)
   (if (local-stream? handle)
       (let ((filename (stream-name handle)))
	  (if (file-exists? filename)
	      (stat-struct->php-hash (stat filename))
	      FALSE))
       FALSE))

;; ftell -- Tells file pointer read/write position
(defbuiltin (ftell handle)
   (if (local-stream? handle)
       (let ((retval (pfl-ftell (stream-file-ptr handle))))
	  (if (= retval -1)
	      FALSE
	      (convert-to-integer retval)))
       FALSE))

;; ftruncate -- Truncates a file to a given length
(defbuiltin (ftruncate handle size) 
   (cond-expand
      (PCC_MINGW #f)
      (else
       (if (and (local-stream? handle)
		(zero? (pfl-ftruncate (pfl-fileno (stream-file-ptr handle)) (mkfixnum size))))
	   TRUE
	   FALSE))))

;; fwrite -- Binary-safe file write
(defalias fputs fwrite)
(defbuiltin (fwrite handle string (length 'unpassed))
;    (fprint (current-error-port) "definitely got to fwrite more errno: " (pragma::int "errno") " writable: " (writeable-stream? handle) " type " (stream-type handle) " blocking? " (stream-blocking? handle) ", sockfd is " (php-stream-fd handle))
;   (flush-output-port (current-error-port))
   ;; XXX handle nonblocking output
   (if (writeable-stream? handle)
       (let* ((string (mkstr string))
	      (length (if (passed? length)
			  (let ((fixnum-len (mkfixnum length))
				(string-len (string-length string)))
			     (if (or (< fixnum-len 0)
				     (> fixnum-len string-len))
				 string-len
				 fixnum-len))
			  (string-length string))))
	  (case (stream-type handle)
	    ((socket)
	     (if (or (stream-blocking? handle)
                     (wait-for-write (php-stream-fd handle) 
                                     (stream-timeout-sec handle)
                                     (stream-timeout-usec handle)))
		 (let ((s::string string)
		       (len::int length))
		    (let ((wrote
			   (pragma::int "send($1, $2, $3, 0)"
					(php-stream-fd handle)
					s len)))
		       (cons s 'keepme)
		       (cons len 'keephimtoo)
		       (if (> length wrote)
			   FALSE
			   length)))
		 (begin
; 		  (fprint (current-error-port) "socket seems to be blocked ")
; 		  (fflush (current-error-port))
		  FALSE)))
	     ((local-file process)
	      (if (stream-blocking? handle)
		  (let ((wrote (pfl-fwrite string 1 length (stream-file-ptr handle))))
		     (if (> length wrote)
			 (begin
;			  (fprint (current-error-port) "the errno: " (pragma::int "errno"))
			  FALSE)
			 (and (pfl-fflush (stream-file-ptr handle))
;			      (fprint (current-error-port) "no errno: " (pragma::int "errno"))
			      length)))
		  (if (wait-for-write (php-stream-fd handle) (stream-timeout-sec handle) (stream-timeout-usec handle))
		      (if (> length (pfl-fwrite string 1 length (stream-file-ptr handle)))
			 (begin
;			  (fprint (current-error-port) "the more errno: " (pragma::int "errno"))
			  FALSE)
			  (and (pfl-fflush (stream-file-ptr handle))
;			       (fprint (current-error-port) "less errno: " (pragma::int "errno"))
			       length))
			 (begin
;			  (fprint (current-error-port) "wait-for-write returned false")
;			  (flush-output-port (current-error-port))
			  FALSE))))
	     ((remote-file)
	      (let ((string (substring string 0 length)))
		 (if (stream-blocking? handle)
		     (and (display string (stream-out-port handle))
			  (flush-output-port (stream-out-port handle))
			  length)
		     (if (wait-for-write (port->fd (stream-out-port handle)) (stream-timeout-sec handle) (stream-timeout-usec handle))
			 (and (display string (stream-out-port handle))
			      (flush-output-port (stream-out-port handle))
			      length)
			  FALSE))))
	     (else FALSE)))
       (begin 
	  (php-warning "supplied argument is not a writeable stream resource")
	  (debug-trace 3 "handle given to fwrite: " handle)
	  FALSE)))

;; glob -- Find pathnames matching a pattern
;(defbuiltin (glob pattern (flags 'unpassed))
;   (error "glob" "function not yet implemented" "glob"))

;; is_dir -- Tells whether the filename is a directory
; XXX bigloo 2.6e (which we use on mingw) segfaults when
; on directory? when compiled statically, so we use our
; own stat here. this can probably change back with new versions
; of bigloo, if we want
; XXX appears to be an underlying mingw issue, as stat is
; returning 0 for a file mode when compiled statically
(defbuiltin (is_dir filename)
   (let* ((prettify (lambda (d) 
		      (let ((dir (cond-expand
				  (PCC_MINGW
				   (pregexp-replace* "/" (mkstr d) "\\\\"))
				  (else
				   (mkstr d)))))
			(if (and (> (string-length dir) 1)
				 (char=? (string-ref dir (- (string-length dir) 1)) (pcc-file-separator)))
			   (substring dir 0 (- (string-length dir) 1))
			   dir))))
          (stat-struct (stat (prettify filename)))
	  (mode (stat-mode stat-struct)))
;      (fprint (current-error-port) (format "stat said: ~a" mode))
      (if (member 'fdir mode)
	  TRUE
	  FALSE)))

;    (if (directory? (mkstr filename))
;        TRUE
;        FALSE))

;; is_executable -- Tells whether the filename is executable
(defbuiltin (is_executable filename)
   (cond-expand
      (PCC_MINGW #f)
      (else 
       (let ((filename (mkstr filename)))
	  (if (file-exists? filename)
	      (let* ((effective-uid (pfl-geteuid))
		     (effective-gid (pfl-getegid))
		     (stat-struct (stat filename))
		     (mode (stat-mode stat-struct)))
		 (if (or (member 'xoth mode)
			 (and (member 'xusr mode)
			      (= effective-uid (stat-uid stat-struct)))
			 (and (member 'xgrp mode)
			      (= effective-gid (stat-gid stat-struct))))
		     TRUE
		     FALSE))
	      FALSE)))))

;; is_file -- Tells whether the filename is a regular file
(defbuiltin (is_file filename)
;    (fprint (current-error-port) "filename : " filename)
;   (fprint (current-error-port) "stat says: " (stat filename))
   (let ((filename (mkstr filename)))
      (if (file-exists? filename)
	  (try (let ((regular-file? (member 'freg (stat-mode (stat filename)))))
		  (debug-trace 2 "This is what stat returned: " (stat-mode (stat filename)))

		  (if regular-file?
		      TRUE
		      FALSE))
	       (lambda (e p m o)
		  (e FALSE)))
	  FALSE)))

;; is_link -- Tells whether the filename is a symbolic link
(defbuiltin (is_link filename)
   (cond-expand
      (PCC_MINGW #f)
      (else 
       (let ((filename (mkstr filename)))
	  (let ((stat-struct (try (lstat-internal filename)
				  (lambda (e p m o)
				     (print "error is " m)
				     (e #f)))))
	     (if (and stat-struct
		      (member 'flnk (stat-mode stat-struct)))
		 TRUE
		 FALSE))))))

;; is_readable -- Tells whether the filename is readable
(defbuiltin (is_readable filename)
   (cond-expand
      (PCC_MINGW 
       ;; just try to open it, and if there's an error return false.
       (try (with-input-from-file filename
               (lambda () TRUE))
            (lambda (e p m o)
;               (print "error is " (list p m o))
               (e FALSE))))
      (else
       (let ((filename (mkstr filename)))
          ;; XXX this might be a bug: maybe we should use lstat and
          ;; not call file-exists?, so that we treat symbolic links
          ;; correctly?
	  (if (file-exists? filename)
	      (let* ((effective-uid (pfl-geteuid))
		     (effective-gid (pfl-getegid))
		     (stat-struct (stat filename))
		     (mode (stat-mode stat-struct)))
		 (if (or (member 'roth mode)
			 (and (member 'rusr mode)
			      (= effective-uid (stat-uid stat-struct)))
			 (and (member 'rgrp mode)
			      (= effective-gid (stat-gid stat-struct))))
		     TRUE
		     FALSE))
	      FALSE)))))

; XXX moved to webconnect
;; is_uploaded_file -- Tells whether the file was uploaded via HTTP POST
;(defbuiltin (is_uploaded_file filename)
;   (error "is_uploaded_file" "function not yet implemented" "is_uploaded_file"))

;; is_writable -- Tells whether the filename is writable
(defalias is_writeable is_writable)
(defbuiltin (is_writable filename)
   (cond-expand
      (PCC_MINGW 
       (let ((filename (mkstr filename)))
	  (if (file-exists? filename)
	      (let* ((stat-struct (stat filename))
		     (mode (stat-mode stat-struct)))
		 (if (or (member 'woth mode)
			 (member 'wusr mode)
			 (member 'wgrp mode))
		     TRUE
		     FALSE))
	      FALSE)))
      (else
       (let ((filename (mkstr filename)))
	  (if (file-exists? filename)
	      (let* ((effective-uid (pfl-geteuid))
		     (effective-gid (pfl-getegid))
		     (stat-struct (stat filename))
		     (mode (stat-mode stat-struct)))
		 (if (or (member 'woth mode)
			 (and (member 'wusr mode)
			      (= effective-uid (stat-uid stat-struct)))
			 (and (member 'wgrp mode)
			      (= effective-gid (stat-gid stat-struct))))
		     TRUE
		     FALSE))
	      FALSE)))))

;; link -- Create a hard link
(defbuiltin (link target link)
   (cond-expand
      (PCC_MINGW #f)
      (else
       (let ((retval (pfl-link (mkstr target) (mkstr link))))
	  (if (zero? retval)
	      TRUE
	      FALSE)))))

;; linkinfo -- Gets information about a link
;(defbuiltin (linkinfo path)
;   (error "linkinfo" "function not yet implemented" "linkinfo"))

(cond-expand
   (PCC_MINGW)
   (else
    (define (lstat-internal filename)
       (let ((filename (mkstr filename)))
	  (let* ((statbuf
		  (pragma::stat "(struct stat*)GC_malloc_atomic(sizeof(struct stat))"))
		 (retval
		  (pragma::int "lstat($1, $2)" ($bstring->string filename) statbuf)))
	     (if (zero? retval)
		 statbuf
		 #f))))))

;; lstat -- Gives information about a file or symbolic link
(cond-expand
   (PCC_MINGW)
   (else
    (defbuiltin (lstat filename)
       (let ((filename (mkstr filename)))
	  (let* ((statbuf
		  (pragma::stat "(struct stat*)GC_malloc_atomic(sizeof(struct stat))"))
		 (retval
		  (pragma::int "lstat($1, $2)" ($bstring->string filename) statbuf)))
	     (if (zero? retval)
		 (stat-struct->php-hash statbuf)
		 FALSE))))))
	     
;; mkdir -- Makes directory
(defalias mkdir php-mkdir)
(defbuiltin (php-mkdir pathname (mode 'unpassed))
   (let ((pathname (mkstr pathname)))
      (if (make-directory pathname)
	  (begin
	     (when (passed? mode)
		(php-chmod pathname (mkfixnum mode)))
	     TRUE)
	  FALSE)))


;; parse_ini_file -- Parse a configuration file
(defbuiltin (parse_ini_file filename (process_sections #f))
   (let ((fname (mkstr filename)))
      (if (not (file-exists? fname))
	  ; no good
	  (php-warning (format "cannot open ~a for reading" fname)) 
	  ; good
	  (ini-file-parse fname (convert-to-boolean process_sections)))))

;; pathinfo -- Returns information about a file path
(defbuiltin (pathinfo path)
   (let ((spath (mkstr path))
	 (phash (make-php-hash)))
      (php-hash-insert! phash "dirname" (dirname spath))
      (php-hash-insert! phash "basename" (basename spath))
      (php-hash-insert! phash "extension" (suffix spath))
      phash))

;; pclose -- Closes process file pointer
(defbuiltin (pclose handle)
   (if (process-stream? handle)
       (let ((retval (pfl-pclose (stream-file-ptr handle))))
	  (stream-close! handle)
	  (convert-to-integer retval))
       FALSE))

;; popen -- Opens process file pointer
(defbuiltin (popen command mode)
   (let ((file-ptr (pfl-popen (mkstr command) (mkstr mode))))
      (if (pragma::bool "$1 == NULL" file-ptr)
	  FALSE
	  (cond ((string=? mode "r") (process-stream command file-ptr #t #f))
		((string=? mode "w") (process-stream command file-ptr #f #t))
		(else (php-warning (format "invalid file mode ~a" mode)))))))

;; readfile -- Outputs a file
(defbuiltin (readfile filename (use_include_path 'unpassed) (context 'unpassed))
   (let ((filename (if (passed? use_include_path)
		       (find-file/path (mkstr filename) *include-paths*)
		       (mkstr filename))))
      (if (and filename (file-exists? filename))
	  (with-input-from-file filename (lambda ()
					    (let ((contents (read-string)))
					       (echo contents)
					       (string-length contents))))
					    
	  FALSE)))

;; readlink -- Returns the target of a symbolic link
; (defalias readlink php-readlink)
; (defbuiltin (php-readlink path)
;    (error "readlink" "function not yet implemented" "readlink"))))

;; realpath -- Returns canonicalized absolute pathname
(defbuiltin (realpath path)
   ; our util-realpath will return the same path
   ; back to us if there was an error (e.g. the file
   ; didn't exist). php in this case returns FALSE
   ; so we emulate that here
   (let ((rpguess (util-realpath (mkstr path))))
      (if (and (string=? path rpguess)
	       (not (file_exists path)))
	  FALSE
	  rpguess)))

;; rename -- Renames a file
(defbuiltin (rename oldname newname)
   (let ((oldname (mkstr oldname))
	 (newname (mkstr newname)))
      (if (and (file-exists? oldname) (rename-file oldname newname))
	  TRUE
	  FALSE)))

;; rewind -- Rewind the position of a file pointer
(defbuiltin (rewind handle)
   ;; XXX doesn't work for remote streams
   (if (local-stream? handle)
       (begin (pfl-rewind (stream-file-ptr handle))
	      TRUE)
       FALSE))

;; rmdir -- Removes directory
(defbuiltin (rmdir dirname)
   (let ((dirname (mkstr dirname)))
      (if (directory? dirname)
	  (begin (delete-directory dirname)
		 TRUE)
	  FALSE)))

;; set_file_buffer -- Alias of stream_set_write_buffer()
; alias of stream_set_write_buffer.. a streams function which doesn't exist yet
;(defbuiltin (set_file_buffer stream buffer)
;   (error "set_file_buffer" "function not yet implemented" "set_file_buffer"))

;; stat -- Gives information about a file
(defalias stat php-stat) 
(defbuiltin (php-stat filename)
   (let ((filename (mkstr filename)))
      (if (file-exists? filename)
	  (stat-struct->php-hash (stat filename))
	  FALSE)))
   
;; symlink -- Creates a symbolic link
(defbuiltin (symlink target link)
   (cond-expand
      (PCC_MINGW #f)
      (else
       (let ((retval (pfl-symlink (mkstr target) (mkstr link))))
	  (if (zero? retval)
	      TRUE
	      FALSE)))))

; moved to utils.scm
;(define (make-tmpfile-name dir prefix)
   
;; tempnam -- Create file with unique file name
(defbuiltin (tempnam dir prefix)
   (let* ((dir (mkstr dir))
	  (dir (if (directory? dir)
		   dir
		   (get-temp-dir)))
	  (prefix (mkstr prefix)))
      (let loop ((filename (make-tmpfile-name dir prefix)))
	 (if (file-exists? filename)
	     (loop (make-tmpfile-name dir prefix))
	     (begin
		(touch filename 'unpassed 'unpassed)
		filename)))))

;; tmpfile -- Creates a temporary file
;(defbuiltin (tmpfile)
;   (error "tmpfile" "function not yet implemented" "tmpfile"))

;; touch -- Sets access and modification time of file
(defbuiltin (touch filename (time 'unpassed) (atime 'unpassed))
   (let* ((filename (mkstr filename))
	  (time     (if (passed? time)
			(mkfixnum time)
			(pragma::pfl-time_t "time(NULL)")))
	  (atime    (if (passed? atime)
			(mkfixnum atime)
			time))
	  (utimbuf  (pfl-struct-utimbuf* atime time)))
      (debug-trace 3  "trying to touch filename " filename)
      ;; first create the file if it doesn't already exist
      (unless (file-exists? filename)
	 (try
	  (with-output-to-file filename (lambda () #t))
	      (lambda (e p m o) (e FALSE))))
      (when (file-exists? filename)
	 ;; then update the timestamps
	 (let ((retval (pfl-utime filename utimbuf)))
	    (if (zero? retval)
		TRUE
		(begin
		 (debug-trace 2 "retval from utime: " retval " errno: " (pragma::int "errno"))
		 FALSE))))))

(cond-expand
   (PCC_MINGW
    (define get-temp-dir
       (let ((tempdir #f))
	  (lambda ()
	     (if (string? tempdir)
		 tempdir
		 (let ((path::string (make-string (pragma::int "MAX_PATH"))))
		    (pragma "GetTempPath(MAX_PATH, $1)" path)
		    (set! tempdir path)
		    path))))))
   (else
    (define (get-temp-dir) "/tmp")))


;; umask -- Changes the current umask
(defbuiltin (umask (mask 'unpassed))
   (if (passed? mask)
       (pfl-umask (mkfixnum mask))
       (let ((oldmask (pfl-umask 0)))      ; get current mask, changing it to 0 in the process
	  (pfl-umask oldmask)              ; then change it back to th current mask
	  (convert-to-integer oldmask))))  ; and then return it

;; unlink -- Deletes a file
(defbuiltin (unlink filename)
   (if (zero? (pragma::int "unlink($1)" ($bstring->string (mkstr filename))))
     ;(and (file-exists? filename) (not (delete-file filename)))
       TRUE
       FALSE))

;;;; Functions not in the Filesystem section

(defbuiltin (getcwd)
   (pwd))

(defbuiltin (opendir path)
   (set! path (mkstr path))
   (if (directory? path)
       (let ((files (append (list "." "..") (reverse (directory->list path)))))
          (directory-handle-resource files files))
       FALSE))

(defbuiltin (readdir dirhandle)
   (if (directory-handle? dirhandle)
       (let ((next-file (directory-handle-next-file dirhandle)))
	  (if (null? next-file)
	      FALSE
	      (begin
		 (directory-handle-next-file-set! dirhandle (cdr next-file))
		 (car next-file))))
       FALSE))

(defbuiltin (rewinddir dirhandle)
   (if (directory-handle? dirhandle)
       (directory-handle-next-file-set! dirhandle (directory-handle-files dirhandle))
       FALSE))

(defbuiltin (closedir dirhandle)
   (if (directory-handle? dirhandle)
       (begin
	  (directory-handle-files-set! dirhandle '())
	  (directory-handle-next-file-set! dirhandle '()))
       FALSE))

;; Directory class
; this is horrible
(define Directory=>Directory
  (let ()
    (lambda ($this . args)
       (let (($p (if (>= 0 (length args))
                   (error 'Directory "not enough params" 0)
                   (container-value (list-ref args 0)))))
         (push-stack '"Directory" '"Directory" $p)
         (let ((retval
		(bind-exit
		      (return)
                   (let ()
		      (set! $this (maybe-box $this))
		      (let ((env #f))
			 #t
			 (begin
			    (php-object-property-set!
			     (container-value $this)
			     "path"
			     (maybe-unbox (copy-php-data $p)))
			    (php-object-property-set!
			     (container-value $this)
			     "handle"
			     (maybe-unbox
			      (copy-php-data
                               (maybe-unbox
				(begin
                                   (let ((retval1001 (opendir $p)))
				      retval1001)))))))
			 (make-container NULL))))))
	    (pop-stack)
	    retval)))))


(define Directory=>read
  (let ()
    (lambda ($this . args)
       (let ()
         (push-stack '"Directory" '"read")
         (let ((retval
                 (bind-exit
                   (return)
                   (let ()
                     (set! $this (maybe-box $this))
                     (let ((env #f))
                       #t
                       (begin
                         (return
                           (copy-php-data
                             (maybe-box
                               (begin
                                 (let ((retval1002
                                         (readdir
                                           (maybe-unbox
                                             (php-object-property-ref
                                               (container-value $this)
                                               (string->symbol
                                                 (mkstr "handle")))))))
                                   retval1002))))))
                       (make-container NULL))))))
           (pop-stack)
           retval)))))
 
 
(define Directory=>rewind
  (let ()
    (lambda ($this . args)
       (let ()
         (push-stack '"Directory" '"rewind")
         (let ((retval
                 (bind-exit
                   (return)
                   (let ()
                     (set! $this (maybe-box $this))
                     (let ((env #f))
                       #t
                       (begin
                         (return
                           (copy-php-data
                             (maybe-box
                               (begin
                                 (let ((retval1003
                                         (rewinddir
                                           (maybe-unbox
                                             (php-object-property-ref
                                               (container-value $this)
                                               (string->symbol
                                                 (mkstr "handle")))))))
                                   retval1003))))))
                       (make-container NULL))))))
           (pop-stack)
           retval)))))
 
 
(define Directory=>close
  (let ()
    (lambda ($this . args)
       (let ()
         (push-stack '"Directory" '"close")
         (let ((retval
                 (bind-exit
                   (return)
                   (let ()
                     (set! $this (maybe-box $this))
                     (let ((env #f))
                       #t
                       (begin
                         (return
                           (copy-php-data
                             (maybe-box
                               (begin
                                 (let ((retval1004
                                         (closedir
                                           (maybe-unbox
                                             (php-object-property-ref
                                               (container-value $this)
                                               (string->symbol
                                                 (mkstr "handle")))))))
                                   retval1004))))))
                       (make-container NULL))))))
           (pop-stack)
           retval)))))

(define (def-dir-class)
   (define-php-class 'Directory '())
   (define-php-property 'Directory "path" (make-container '()))
   (define-php-property 'Directory "handle" (make-container '()))
   (define-php-method 'Directory "Directory" Directory=>Directory)
   (define-php-method 'Directory "read"  Directory=>read)
   (define-php-method 'Directory "rewind" Directory=>rewind)
   (define-php-method 'Directory "close"  Directory=>close))

; this is a startup function because at top level init the object
; system hasn't been initialized
(add-startup-function def-dir-class)

(defbuiltin (dir path)
   (construct-php-object "Directory" path))

;;mingw!
;(define (stat-mode a)
;    (list a))
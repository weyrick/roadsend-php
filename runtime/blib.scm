
; ROADSEND NOTE:
;
; all of these functions are adapted from bigloo-lib, common library
; by Vladimir Tsichevski <wowa1@online.ru>
;
; full source is avalailable at:
; http://bigloo-lib.sourceforge.net/
;
; his copyright notice appears below
;

;************************************************************************/
;*                                                                      */
;* Copyright (c) 2003 Vladimir Tsichevski <wowa1@online.ru>             */
;*                                                                      */
;* This file is part of bigloo-lib (http://bigloo-lib.sourceforge.net)  */
;*                                                                      */
;* This library is free software; you can redistribute it and/or        */
;* modify it under the terms of the GNU Lesser General Public           */
;* License as published by the Free Software Foundation; either         */
;* version 2 of the License, or (at your option) any later version.     */
;*                                                                      */
;* This library is distributed in the hope that it will be useful,      */
;* but WITHOUT ANY WARRANTY; without even the implied warranty of       */
;* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU    */
;* Lesser General Public License for more details.                      */
;*                                                                      */
;* You should have received a copy of the GNU Lesser General Public     */
;* License along with this library; if not, write to the Free Software  */
;* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 */
;* USA                                                                  */
;*                                                                      */
;************************************************************************/

(module blib
   (extern
    (include "sys/types.h")    
    (include "sys/stat.h")    
    (include "sys/time.h")
    (include "time.h")
    (type dev-t ulong #"dev_t")    
    )
  (type (subtype fd-set #"fd_set*" (cobj))
        (coerce cobj fd-set () (cobj->fd-set))
        (coerce fd-set cobj () (fd-set->cobj))
        (coerce
          fd-set
          bool
          ()
          ((lambda (x) (pragma::bool #"$1 != NULL" x))))
        (subtype bfd-set #"obj_t" (obj))
        (coerce obj bfd-set () ())
        (coerce bfd-set obj () ())
        (coerce
          bfd-set
          fd-set
          (fd-set?)
          (bfd-set->fd-set))
        (coerce
          fd-set
          obj
          ()
          ((lambda (result)
              (pragma::bfd-set
                #"cobj_to_foreign($1, $2)"
                'fd-set
                result)))))
  (foreign
    (macro fd-set cobj->fd-set (cobj) #"(fd_set*)")
    (macro cobj fd-set->cobj (fd-set) #"(long)")
    (macro fd-set
           bfd-set->fd-set
           (foreign)
           #"(fd_set*)FOREIGN_TO_COBJ"))
  (export (fd-set?::bool o::obj))   
   (type (subtype stmode #"int" (cobj))
	 (coerce cobj stmode () (cobj->stmode))
	 (coerce stmode cobj () ())
	 (subtype bstmode #"obj_t" (obj))
	 (coerce obj bstmode (stmode?) ())
	 (coerce bstmode obj () ())
	 (coerce bstmode bool () ((lambda (x) #t)))
	 (coerce bstmode stmode () (bstmode->stmode))
	 (coerce stmode bstmode () (stmode->bstmode))
	 (coerce pair stmode () (bstmode->stmode))
	 (coerce stmode pair () (stmode->bstmode))
	 (coerce pair-nil stmode () (bstmode->stmode))
	 (coerce bool stmode () ((lambda (x) 0)))
	 (coerce stmode pair-nil () (stmode->bstmode)))
   (foreign
    (macro stmode cobj->stmode (cobj) #"(int)"))
   (export
    (stmode?::bool o::obj)
    (bstmode->stmode::stmode o::obj)
    (stmode->bstmode::bstmode o::stmode))
   (type (subtype stat #"struct stat*" (cobj))
	 (coerce cobj stat () (cobj->stat))
	 (coerce stat cobj () (stat->cobj))
	 (coerce
          stat
          bool
          ()
          ((lambda (x) (pragma::bool #"$1 != NULL" x))))
	 (subtype bstat #"obj_t" (obj))
	 (coerce obj bstat () ())
	 (coerce bstat obj () ())
	 (coerce bstat stat (stat?) (bstat->stat))
	 (coerce
          stat
          obj
          ()
          ((lambda (result)
              (pragma::bstat
	       #"cobj_to_foreign($1, $2)"
	       'stat
	       result)))))
   (foreign
    (macro stat cobj->stat (cobj) #"(struct stat*)")
    (macro cobj stat->cobj (stat) #"(long)")
    (macro stat
           bstat->stat
           (foreign)
           #"(struct stat*)FOREIGN_TO_COBJ"))
   (export (stat?::bool o::obj))
   (export (stat::stat what))
   (type (subtype string* #"char**" (cobj))
	 (coerce cobj string* () (cobj->string*))
	 (coerce string* cobj () (string*->cobj))
	 (coerce
          string*
          bool
          ()
          ((lambda (x) (pragma::bool #"$1 != NULL" x))))
	 (subtype bstring* #"obj_t" (obj))
	 (coerce obj bstring* () ())
	 (coerce bstring* obj () ())
	 (coerce
          bstring*
          string*
          (string*?)
          (bstring*->string*))
	 (coerce
          string*
          obj
          ()
          ((lambda (result)
              (pragma::bstring*
	       #"cobj_to_foreign($1, $2)"
	       'string*
	       result)))))
   (foreign
    (macro string* cobj->string* (cobj) #"(char**)")
    (macro cobj string*->cobj (string*) #"(long)")
    (macro string*
           bstring*->string*
           (foreign)
           #"(char**)FOREIGN_TO_COBJ"))
   (type (subtype tm #"struct tm*" (cobj))
        (coerce cobj tm () (cobj->tm))
        (coerce tm cobj () (tm->cobj))
        (coerce
          tm
          bool
          ()
          ((lambda (x) (pragma::bool #"$1 != NULL" x))))
        (subtype btm #"obj_t" (obj))
        (coerce obj btm () ())
        (coerce btm obj () ())
        (coerce btm tm (tm?) (btm->tm))
        (coerce
          tm
          obj
          ()
          ((lambda (result)
              (pragma::btm
                #"cobj_to_foreign($1, $2)"
                'tm
                result)))))
   (foreign
    (macro tm cobj->tm (cobj) #"(struct tm*)")
    (macro cobj tm->cobj (tm) #"(long)")
    (macro tm
           btm->tm
           (foreign)
           #"(struct tm*)FOREIGN_TO_COBJ"))
   (export (stat-mode::stmode o::stat))
   (export (stat-ino::int o::stat))
   (export (stat-dev::dev-t o::stat))
   (export (stat-rdev::int o::stat))
   (export (stat-nlink::int o::stat))
   (export (stat-uid::int o::stat))
   (export (stat-gid::int o::stat))
   (export (stat-size::long o::stat))
   (export (stat-atime::double o::stat))
   (export (stat-mtime::double o::stat))
   (export (stat-ctime::double o::stat))    
   (export

    (make-tm::tm)
    (strftime::bstring tm::tm #!optional (format::bstring #"%x %X"))
    (mktime::tm year::int month::int day::int #!optional (hour::int 0) (minute::int 0) (second::int 0))
    (timezone::int)
    (daylight::int)
    (tm-sec::int o::tm)
    (tm-min::int o::tm)
    (tm-hour::int o::tm)
    (tm-mday::int o::tm)
    (tm-mon::int o::tm)
    (tm-year::int o::tm)
    (tm?::bool o::obj)
    (string->hex::bstring s::bstring)
    (string*?::bool o::obj)
    (string*->string-list::pair-nil sp::string* #!optional len)
    (string-list->string*::string* sl::pair-nil)
    (last ::pair-nil)
    (remove::pair-nil ::procedure lis::pair-nil)
    (delete-duplicates lis #!optional (elt=::procedure equal?))
    (string-join string-list #!optional (delimiter " ") (grammar 'infix))    
    (lset-difference elt=::procedure lis1 . lists)
    (lset-union!::pair-nil elt=::procedure . lists)
    (char->hex::bstring c::uchar)    
    (environ::pair-nil)
    (setenv name::string value::string)
    ))


;;;;;;;
;
; macros
;

(define-macro (string*-set! s::string* i::int v::string)
  `(pragma "$1[$2] = $3" ,s ,i ,v))

(define-macro (string*-ref s::string* i::int)
  `(pragma::string "$1[$2]" ,s ,i))

(define-macro (make-string* size::int)
  `(pragma::string* "(char**)(GC_malloc($1 * sizeof(char**)))" ,size))

(define-macro (string*-null? s::string*)
  `(pragma::bool "$1 == (char**)0" ,s))

(define-macro (list->cpointers type::symbol)
  (let*((type* (symbol-append type '*))
	(set* (symbol-append type* '-set!))
	(pragma (symbol-append 'pragma:: type))
	(pragma* (symbol-append 'pragma:: type*))
	(make* (symbol-append 'make- type*)))

    `(lambda (constructor::procedure attvals::pair-nil)
       (let((valsp (,make* (+fx 1 (length attvals)))))
	 (let loop((i 0)(attvals attvals))
	   (if(null? attvals)
	      (begin
		(,set* valsp i(,pragma "NULL"))
		valsp)
	      (begin
		(,set* valsp i
		       (constructor(car attvals)))
		(loop(+fx i 1)(cdr attvals)))))))))

(define-macro (check-range . body)
  (if *unsafe-range*
      `'()
      `(begin ,@body)))

(define-macro (with-optional-range procname s start end . body)
  (let((len-name (symbol-append s '-len)))
    `(let*((,len-name(string-length ,s)))
       (if ,start
	   (check-range
	    (unless(and (>=fx ,start 0)
			(<=fx ,start ,len-name))
		   (error ,procname "start string offset out of range" ,start)))
	   (set! ,start 0))
       (if ,end
	   (check-range
	    (unless(and(>=fx ,end 0)(<=fx ,end ,len-name))
		   (error ,procname "end string offset out of range" ,end)))
	   (set! ,end ,len-name))
       ,@body)))

(define-macro (cpointer->list type::symbol . proc)
  `(lambda(,(symbol-append 'p*:: type '*) #!optional len)
     (let loop((accu '())(i 0))
       (let((,(symbol-append 'p:: type)
	     (,(symbol-append 'pragma:: type) "$1[$2]" p* i)))
	 (if(or (and len (=fx i len))
		(pragma::bool "$1 == NULL" p))
	    (reverse accu)
	    (loop
	     (cons ,(if(null? proc) 'p (list(car proc) 'p)) accu)
	     (+fx i 1)))))))

;;;;;;;;;;;
;
; supporting functions not exported (used internally here)
;

(define (alist-lookup alist name)
  (cond((assq name alist) => cdr)
       (else #f)))

(define (alist-set! alist name value)
  (let((bucket(assq name alist)))
    (if bucket
	(begin
	  (set-cdr! bucket value)
	  alist)
	(cons(cons name value)alist))))

(define (find-tail pred::procedure list)
  (let lp ((list list))
    (and (not (null-list? list))
	 (if (pred (car list)) list
	     (lp (cdr list))))))

(define (member x lis #!optional (elt=::procedure equal?))
  (find-tail (lambda (y) (elt= x y)) lis))

(define (ptr->0..255 o)
  (pragma::long "get_hash_number_from_int($1)" o))

; delete-duplicates
(define (delete x lis #!optional (elt=::procedure equal?))
  (filter (lambda (y) (not (elt= x y))) lis))

; lset-union!
(define (%cdrs lists)
   (bind-exit (abort)
      (let recur ((lists lists))
	 (if (pair? lists)
	     (let ((lis (car lists)))
		(if (null-list? lis) (abort '())
		    (cons (cdr lis) (recur (cdr lists)))))
	     '()))))

; lset-union!
(define (pair-fold f::procedure zero lis1 . lists)
   (if (pair? lists)
      (let lp ((lists (cons lis1 lists)) (ans zero))	; N-ary case
	(let ((tails (%cdrs lists)))
	  (if (null? tails) ans
	      (lp tails (apply f (append! lists (list ans)))))))

      (let lp ((lis lis1) (ans zero))
	(if (null-list? lis) ans
	    (let ((tail (cdr lis)))		; Grab the cdr now,
	      (lp tail (f lis ans)))))))

; lset-union!
(define (car+cdr pair) (values (car pair) (cdr pair)))

; lset-union!
(define (%cars+cdrs+ lists cars-final)
   (bind-exit (abort)
      (let recur ((lists lists))
        (if (pair? lists)
	    (receive (list other-lists) (car+cdr lists)
	      (if (null-list? list) (abort (values '() '())) ; LIST is empty -- bail out
		  (receive (a d) (car+cdr list)
		    (receive (cars cdrs) (recur other-lists)
		      (values (cons a cars) (cons d cdrs))))))
	    (values (list cars-final) '())))))

; lset-union!
(define (null-list? l)
  (cond ((pair? l) #f)
	((null? l) #t)
	(else (error "null-list?" "argument out of domain" l))))

; lset-union!
(define (fold kons::procedure knil lis1 . lists)
   (if (pair? lists)
      (let lp ((lists (cons lis1 lists)) (ans knil))	; N-ary case
	(receive (cars+ans cdrs) (%cars+cdrs+ lists ans)
	  (if (null? cars+ans) ans ; Done.
	      (lp cdrs (apply kons cars+ans)))))
	    
      (let lp ((lis lis1) (ans knil))			; Fast path
	(if (null-list? lis) ans
	    (lp (cdr lis) (kons (car lis) ans))))))

; lset-union!
(define (reduce f::procedure ridentity lis)
  (if (null-list? lis) ridentity
      (fold f (car lis) (cdr lis))))

; environ
(define (string-after s::bstring delim::char)
  (let((found(pragma::string "strchr($1, $2)"
			     ($bstring->string s)
			     delim)))
    (and(pragma::bool "($1 != 0L)" found)
	($string->bstring(pragma::string "$1 + 1" found)))))
;;(string-after "asdf.qwerty.zxcv" #\.)
;;(string-after "asdf.qwerty.zxcv" #\,)

; environ
(define (string-before::bstring s::bstring delim::char)
  (let((found(pragma::string "strchr($1, $2)"
			     ($bstring->string s)
			     delim)))
    (if(pragma::bool "($1 == 0L)" found)
       s
       (substring s 0 (pragma::int "$1 - $2" found
				   ($bstring->string s))))))

(define (strerror::string #!optional errnum)
  (let ((errnum::int (or errnum (pragma::int #"errno"))))
    (pragma::string #"strerror($1)" errnum)))


(define (cerror name::bstring . arguments)
  (let ((errnum ;; (errno)
                (pragma::int "errno")))
    (and (not (=fx errnum 0))
         (error name
                (format
                  #"~a: ~a~a"
                  errnum
                  (strerror errnum)
                  (if (null? arguments) #"" #" arguments was"))
                (print-list-delimited arguments)))))

(define (proc-output proc . args)
  (let((os(open-output-string)))
    (with-output-to-port
     os
     (lambda()(apply proc args)))
    (get-output-string os)))

(define (transpose l)
  [assert(l)(list? l)]
  (let loop((l l)(accu '()))
    (if(null? (car l))
       (reverse accu)
       (loop (map cdr l)(cons(map car l)accu)))))

(define (for-each-delimited proc thunk . lists)
  (let loop((l (transpose lists)))
    (unless(null? l)
 	   (apply proc(car l))
 	   (unless(null?(cdr l))(thunk))
 	   (loop(cdr l)))))

(define (print-list-delimited
	lst
	#!optional
	(delim "")
	(display display))
  (proc-output
   (lambda(l)
     (for-each-delimited
      display
      (lambda()(display delim))
      l))
   lst))
;;;;;;;;
;
; everything below is exported (ie, used in pcc)
;

(define (string->hex s)
  (let*((len(string-length s))
	(result(make-string (*fx len 2))))
    (pragma "
{
  static char mask[]=\"0123456789abcdef\";
  while( $1 --) {
    char c = * $2 ++;
    * $3 ++ = mask[(c >> 4) & 15];
    * $3 ++ = mask[c & 15];
  }
}"
  len
  ($bstring->string s)
  ($bstring->string result))
    result))

(define (string*?::bool o::obj)
  (and (foreign? o) (eq? (foreign-id o) 'string*)))

(define (string*->string-list::pair-nil
         sp::string*
         #!optional
         len)
  ((cpointer->list string) sp len))

(define (string-list->string*::string* sl::pair-nil)
  ((list->cpointers string)
   (lambda (s::bstring) (let ((cs::string s)) cs))
   sl))

(define (last lis) (car (last-pair lis)))

(define (remove  pred l) (filter  (lambda (x) (not (pred x))) l))

(define (delete-duplicates lis #!optional (elt=::procedure equal?))
  (let recur ((lis lis))
    (if (null-list? lis) lis
	(let* ((x (car lis))
	       (tail (cdr lis))
	       (new-tail (recur (delete x tail elt=))))
	  (if (eq? tail new-tail) lis (cons x new-tail))))))

(define (string-join string-list #!optional (delimiter " ") (grammar 'infix))
  (apply
   string-append
   (let loop((string-list string-list)
	     (accu '()))
     (if(null? string-list)
	(if(null? accu)
	   (if(eq? grammar 'strict-infix)
	      (error "string-join"
		     "string-list should be non-empty list for strict-infix grammar" "")
	      '())
	   (case grammar
	     ((infix strict-infix)
	      (reverse (cdr accu)))
	     ((suffix)
	      (reverse accu))
	     ((prefix)
	      (cons delimiter(reverse(cdr accu))))
	     (else
	      (error "string-join"
		     "invalid grammar, must be one of: infix, strict-infix, suffix or prefix"
		     grammar))))
	(loop
	 (cdr string-list)
	 (cons* delimiter(car string-list)accu))))))

(define (lset-difference elt=::procedure lis1 . lists)
  (let ((lists (filter pair? lists)))	; Throw out empty lists.
    (cond ((null? lists)     lis1)	; Short cut
	  ((memq lis1 lists) '())	; Short cut
	  (else (filter (lambda (x)
			  (every (lambda (lis) (not (member x lis elt=)))
				 lists))
			lis1)))))

(define (lset-union! elt= . lists)
  (reduce (lambda (lis ans)		; Splice new elts of LIS onto the front of ANS.
	    (cond ((null? lis) ans)	; Don't copy any lists
		  ((null? ans) lis) 	; if we don't have to.
		  ((eq? lis ans) ans)
		  (else
		   (pair-fold (lambda (pair ans)
				(let ((elt (car pair)))
				  (if (any (lambda (x) (elt= x elt)) ans)
				      ans
				      (begin (set-cdr! pair ans) pair))))
			      ans lis))))
	  '() lists))

(define (char->hex::bstring c::uchar)
  (let((s(make-string 2)))
    (pragma "sprintf($1, \"%02x\", $2)"
	    ($bstring->string s)
	    c)
    s))

(define (environ::pair-nil)
  (pragma #"extern char** environ")
  (map (lambda (str)
          (cons (string-before str #\=)
                (string-after str #\=)))
       (string*->string-list
         (pragma::string* #"environ"))))

(define (tm-sec::int o::tm)
  (let ((result (pragma::int #"$1->tm_sec" o)))
    result))


(define (tm-min::int o::tm)
  (let ((result (pragma::int #"$1->tm_min" o)))
    result))


(define (tm-hour::int o::tm)
  (let ((result (pragma::int #"$1->tm_hour" o)))
    result))


(define (tm-mday::int o::tm)
  (let ((result (pragma::int #"$1->tm_mday" o)))
    result))


(define (tm-mon::int o::tm)
  (let ((result (pragma::int #"$1->tm_mon" o)))
    result))


(define (tm-year::int o::tm)
  (let ((result (pragma::int #"$1->tm_year" o)))
    result))


(define (tm?::bool o::obj)
  (and (foreign? o) (eq? (foreign-id o) 'tm)))


(define (timezone::int)
  (cond-expand
   (PCC_MINGW
    (pragma::int #"_timezone"))
   (PCC_FREEBSD
    0)
   (else
    (pragma::int #"__timezone"))))


(define (daylight::int)
  (cond-expand
   (PCC_MINGW
    (pragma::int #"_daylight"))
   (PCC_FREEBSD
    0)
   (else
    (pragma::int #"__daylight"))))

(define (make-tm::tm)
  (pragma::tm
    #"(struct tm*)GC_malloc_atomic(sizeof(struct tm))"))

(define (strftime::bstring
         tm::tm
         #!optional
         (format::bstring #"%x %X"))
  (let ()
    (pragma #"char formatted_time[1024]")
    (pragma
      #"strftime(formatted_time,\n           sizeof(formatted_time),\n           $1,\n           $2)"
      ($bstring->string format)
      tm)
    (pragma::string #"formatted_time")))


(define (mktime::tm
         year::int
         month::int
         day::int
         #!optional
         (hour::int 0)
         (minute::int 0)
         (second::int 0))
  (let ((tm::tm (make-tm)))
    (pragma
      #"\n  $1->tm_sec = $2;\n  $1->tm_min = $3;\n  $1->tm_hour = $4;\n  $1->tm_mday = $5;\n  $1->tm_mon = $6 - 1;\n  $1->tm_year = $7 - 1900;"
      tm
      second
      minute
      hour
      day
      month
      year)
    tm))

(define (setenv name::string value::string)
   (when (pragma::bool #"setenv($1, $2, 1)" name value)
      (cerror #"setenv")))

(define (stat?::bool o::obj)
  (and (foreign? o) (eq? (foreign-id o) 'stat)))

(define (stat::stat what)
  (cond-expand 
   (PCC_MINGW
    (let* ((buf (pragma::stat
		 #"(struct stat*)GC_malloc_atomic(sizeof(struct stat))"))
	   (failed?
	    (cond ((string? what)
		   (pragma::bool
		    #"_stat($1, $2)"
		    ($bstring->string what)
		    buf))
		  ((and (integer? what) (positive? what))
		   (pragma::bool
		    #"_fstat($1, $2)"
		    ($bint->int what)
		    buf))
		  (else
		   (error #"stat"
			  #"must be filename or open file descriptor"
			  what)))))
      buf))
   (else
    (let* ((buf (pragma::stat
		 #"(struct stat*)GC_malloc_atomic(sizeof(struct stat))"))
	   (failed?
	    (cond ((string? what)
		   (pragma::bool
                    #"stat($1, $2)"
                    ($bstring->string what)
                    buf))
		  ((and (integer? what) (positive? what))
		   (pragma::bool
                    #"fstat($1, $2)"
                    ($bint->int what)
                    buf))
		  (else
		   (error #"stat"
			  #"must be filename or open file descriptor"
			  what)))))
      buf))))
    ;(when failed? (cerror #"stat" what))
; this is broken on mingw statically    
;    (pragma "fprintf(stderr, \"here1: %d\\n\", $1->st_mode);" buf)
;    (pragma "fprintf(stderr, \"here1a: %d\\n\", $1->st_size);" buf)
;    buf))

(define (bstmode->stmode::stmode o::obj)
   (let ((res::int 0))
      (for-each
       (lambda (o)
	  (cond-expand
	     (PCC_MINGW
	      (case o
		 ((freg)
		  (set! res (bit-or res (pragma::int #"S_IFREG"))))
		 ((fblk)
		  (set! res (bit-or res (pragma::int #"S_IFBLK"))))
		 ((fdir)
		  (set! res (bit-or res (pragma::int #"S_IFDIR"))))
		 ((fchr)
		  (set! res (bit-or res (pragma::int #"S_IFCHR"))))
		 ((fifo)
		  (set! res (bit-or res (pragma::int #"S_IFIFO"))))
		 ((rusr)
		  (set! res (bit-or res (pragma::int #"S_IRUSR"))))
		 ((wusr)
		  (set! res (bit-or res (pragma::int #"S_IWUSR"))))
		 ((xusr)
		  (set! res (bit-or res (pragma::int #"S_IXUSR"))))
		 (else
		  (error #"bstmode->stmode"
			 #"invalid argument, must be one of (fsock flnk freg fblk fdir fchr fifo suid sgid svtx rusr wusr xusr rgrp wgrp xgrp roth woth xoth): "
			 o))))
	     (else
	      (case o
		 ((fsock)
		  (set! res (bit-or res (pragma::int #"S_IFSOCK"))))
		 ((flnk)
		  (set! res (bit-or res (pragma::int #"S_IFLNK"))))
		 ((freg)
		  (set! res (bit-or res (pragma::int #"S_IFREG"))))
		 ((fblk)
		  (set! res (bit-or res (pragma::int #"S_IFBLK"))))
		 ((fdir)
		  (set! res (bit-or res (pragma::int #"S_IFDIR"))))
		 ((fchr)
		  (set! res (bit-or res (pragma::int #"S_IFCHR"))))
		 ((fifo)
		  (set! res (bit-or res (pragma::int #"S_IFIFO"))))
		 ((suid)
		  (set! res (bit-or res (pragma::int #"S_ISUID"))))
		 ((sgid)
		  (set! res (bit-or res (pragma::int #"S_ISGID"))))
		 ((svtx)
		  (set! res (bit-or res (pragma::int #"S_ISVTX"))))
		 ((rusr)
		  (set! res (bit-or res (pragma::int #"S_IRUSR"))))
		 ((wusr)
		  (set! res (bit-or res (pragma::int #"S_IWUSR"))))
		 ((xusr)
		  (set! res (bit-or res (pragma::int #"S_IXUSR"))))
		 ((rgrp)
		  (set! res (bit-or res (pragma::int #"S_IRGRP"))))
		 ((wgrp)
		  (set! res (bit-or res (pragma::int #"S_IWGRP"))))
		 ((xgrp)
		  (set! res (bit-or res (pragma::int #"S_IXGRP"))))
		 ((roth)
		  (set! res (bit-or res (pragma::int #"S_IROTH"))))
		 ((woth)
		  (set! res (bit-or res (pragma::int #"S_IWOTH"))))
		 ((xoth)
		  (set! res (bit-or res (pragma::int #"S_IXOTH"))))
		 (else
		  (error #"bstmode->stmode"
			 #"invalid argument, must be one of (fsock flnk freg fblk fdir fchr fifo suid sgid svtx rusr wusr xusr rgrp wgrp xgrp roth woth xoth): "
			 o))))))
	     o)
	  (let ((res::int res)) (pragma::stmode #"$1" res))))


(define (stmode->bstmode::bstmode o::stmode)   
; this is broken on mingw statically    
;   (pragma "fprintf(stderr, \"here2: %d\\n\", $1);" o)
   (let ((res '()))
      (cond-expand
	 (PCC_MINGW '())
	 (else 
	  (when (pragma::bool #"($1 & S_IFSOCK) == S_IFSOCK" o)
	     (set! res (cons 'fsock res)))))
      (cond-expand
	 (PCC_MINGW '())
	 (else       
	  (when (pragma::bool #"($1 & S_IFLNK) == S_IFLNK" o)
	     (set! res (cons 'flnk res)))))
      (when (pragma::bool #"($1 & S_IFREG) == S_IFREG" o)
         (set! res (cons 'freg res)))
      (when (pragma::bool #"($1 & S_IFBLK) == S_IFBLK" o)
         (set! res (cons 'fblk res)))
;       (when (pragma::bool #"($1 & S_IFDIR) == S_IFDIR" o)
;          (set! res (cons 'fdir res)))
      (when (pragma::bool #"S_ISDIR( $1 )" o)
         (set! res (cons 'fdir res)))
      (when (pragma::bool #"($1 & S_IFCHR) == S_IFCHR" o)
         (set! res (cons 'fchr res)))
      (when (pragma::bool #"($1 & S_IFIFO) == S_IFIFO" o)
         (set! res (cons 'fifo res)))
      (cond-expand
	 (PCC_MINGW '())
	 (else       
	  (when (pragma::bool #"($1 & S_ISUID) == S_ISUID" o)
	     (set! res (cons 'suid res)))))
      (cond-expand
	 (PCC_MINGW '())
	 (else       
	  (when (pragma::bool #"($1 & S_ISGID) == S_ISGID" o)
	     (set! res (cons 'sgid res)))))
      (cond-expand
	 (PCC_MINGW '())
	 (else       
	  (when (pragma::bool #"($1 & S_ISVTX) == S_ISVTX" o)
	     (set! res (cons 'svtx res)))))
      (when (pragma::bool #"($1 & S_IRUSR) == S_IRUSR" o)
	 (set! res (cons 'rusr res)))
      (when (pragma::bool #"($1 & S_IWUSR) == S_IWUSR" o)
	 (set! res (cons 'wusr res)))      
      (when (pragma::bool #"($1 & S_IXUSR) == S_IXUSR" o)
	 (set! res (cons 'xusr res)))
      (cond-expand
	 (PCC_MINGW '())
	 (else       
	  (when (pragma::bool #"($1 & S_IRGRP) == S_IRGRP" o)
	     (set! res (cons 'rgrp res)))))
      (cond-expand
	 (PCC_MINGW '())
	 (else             
	  (when (pragma::bool #"($1 & S_IWGRP) == S_IWGRP" o)
	     (set! res (cons 'wgrp res)))))
      (cond-expand
	 (PCC_MINGW '())
	 (else             
	  (when (pragma::bool #"($1 & S_IXGRP) == S_IXGRP" o)
	     (set! res (cons 'xgrp res)))))
      (cond-expand
	 (PCC_MINGW '())
	 (else             
	  (when (pragma::bool #"($1 & S_IROTH) == S_IROTH" o)
	     (set! res (cons 'roth res)))))
      (cond-expand
	 (PCC_MINGW '())
	 (else             
	  (when (pragma::bool #"($1 & S_IWOTH) == S_IWOTH" o)
	     (set! res (cons 'woth res)))))
      (cond-expand
	 (PCC_MINGW '())
	 (else             
	  (when (pragma::bool #"($1 & S_IXOTH) == S_IXOTH" o)
	     (set! res (cons 'xoth res)))))
      res))


(define (stmode?::bool o::obj)
  (and (list? o)
       (null? (lset-difference
                eq?
                o
                '(fsock flnk
                        freg
                        fblk
                        fdir
                        fchr
                        fifo
                        suid
                        sgid
                        svtx
                        rusr
                        wusr
                        xusr
                        rgrp
                        wgrp
                        xgrp
                        roth
                        woth
                        xoth)))))


(define (stat-mode::stmode o::stat)
  (let ((result (pragma::stmode #"$1->st_mode" o)))
    result))


(define (stat-ino::int o::stat)
  (let ((result (pragma::int #"$1->st_ino" o)))
    result))


(define (stat-dev::dev-t o::stat)
  (let ((result (pragma::dev-t #"$1->st_dev" o)))
    result))


(define (stat-rdev::int o::stat)
  (let ((result (pragma::int #"$1->st_rdev" o)))
    result))


(define (stat-nlink::int o::stat)
  (let ((result (pragma::int #"$1->st_nlink" o)))
    result))


(define (stat-uid::int o::stat)
  (let ((result (pragma::int #"$1->st_uid" o)))
    result))


(define (stat-gid::int o::stat)
  (let ((result (pragma::int #"$1->st_gid" o)))
    result))


(define (stat-size::long o::stat)
  (let ((result (pragma::long #"$1->st_size" o)))
    result))


(define (stat-atime::double o::stat)
  (let ((result (pragma::double #"$1->st_atime" o)))
    result))


(define (stat-mtime::double o::stat)
  (let ((result (pragma::double #"$1->st_mtime" o)))
    result))


(define (stat-ctime::double o::stat)
  (let ((result (pragma::double #"$1->st_ctime" o)))
    result))

(define (fd-set?::bool o::obj)
  (and (foreign? o) (eq? (foreign-id o) 'fd-set)))


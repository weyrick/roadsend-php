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

;;;; Code to deal with function and method signatures in a concise and
;;;; speedy way.

;; Function signatures are used to represent functions that can be
;; called from PHP.  They contain information about the name of the
;; function, how many arguments the function takes, the default values
;; of optional arguments, and whether or not the function is variable
;; arity, i.e. has no maximum limit on the number of arguments.  There
;; is also room for type information, but it is not currently used.

;; Function signatures are stored in tables so that they can be looked
;; up.  A function signature is looked up prior to calling the
;; function, or generating code to call the function.  If the function
;; signature is not found, the function is not defined.  Function
;; signatures are also looked up when defining a new user function
;; (function written in PHP), to check for redefinition, which is an
;; error.

;; Aliases are mappings from an alias to a canonical name.  A single
;; function can have any number of aliases.  When looking up a
;; function signature by name, we first check if the name is an alias,
;; and if so use the canonical name instead to look up the function
;; signature.

;; There are three types of function: main, builtin, and user.  

;; Builtin functions are part of our runtime system, and are normally
;; written in scheme code using the defbuiltin form.  User functions
;; are regular PHP functions.

;; Builtin functions use the "file" field of the signature class to
;; store the extension they are associated with.

;; Main functions contain the toplevel PHP code in a PHP program
;; (i.e. the code that's in global scope), as well as some additional
;; bookeeping code for e.g., storing signatures for the rest of the
;; functions in the file, checking the runtime library version,
;; verifying that a program compiled with a demo license hasn't been
;; distributed, etc.  There is one main function per compiled PHP
;; file.

;; Normally signatures are added to the table using the
;; store-signature* functions.  The different versions all do the same
;; thing; the -1, -2, -3 variants are for performance reasons, (to
;; avoid consing a rest argument list. (This might spurious
;; optimization.))

;; Main and user functions are deleted from the signature table
;; between requests by the function reset-signatures!.  Otherwise
;; functions that were defined by a previous, unrelated, http request
;; would still be in the signature table when processing the next
;; request.  That would lead to function redefinition errors and
;; potential nasal demons.

;; Main functions are special, and cannot be called directly by PHP
;; user code.  Instead, the include(), include_once(), require(), and
;; require_once() PHP functions lookup and call main functions.  This
;; is enforced by having characters in the name of the main function
;; that are illegal syntax for a PHP function call, like e.g. #\/.

;; Instead of using store-signature directly, the main functions of a
;; library will be stored using store-library-include.
;; Store-library-include stores the signature normally, but also adds
;; it to a special library include table.  The library include table
;; is indexed by filename (with the include path stripped), and will
;; be used to lookup these functions when processing an include() in
;; PHP code.  The library include table is not reset between requests.


(module signatures
   (import (php-runtime "php-runtime.scm")
	   (php-hash "php-hash.scm")
	   (grass "grasstable.scm")
           (php-errors "php-errors.scm")
	   (dynarray "dynarray.scm"))
   (export
    
    t-required 
    t-reference
    t-optional 
    t-optional-reference

    ft-main
    ft-builtin
    ft-builtin-constructor
    ft-builtin-method
    ft-user-interpreted
    ft-user-compiled
    ft-compat 

    (try-import-cached-sigs::bbool file-location::bstring)    
    (add-library-include lib-name include-name sig)
    (get-library-include include-name lib-name)
    (dump-builtin-list)
    (get-php-function-sig name)
    (function-name-canonicalize::symbol fun-name::symbol)
    (get-signature-extension sig)
    (store-signature fun::obj
		     fun-type::bint
		     loc::obj
		     name::symbol
		     minimum-arity::bint
		     maximum-arity::bint . params)
    (store-signature-0 fun::obj
		       fun-type::bint
		       loc::obj
		       name::symbol
		       minimum-arity::bint
		       maximum-arity::bint)
    (store-signature-1 fun::obj
		       fun-type::bint
		       loc::obj
		       name::symbol
		       minimum-arity::bint
		       maximum-arity::bint
		       t::bint
		       n::symbol
		       o::obj)
    (store-signature-2 fun::obj
		       fun-type::bint
		       loc::obj
		       name::symbol
		       minimum-arity::bint
		       maximum-arity::bint
		       t::bint
		       n::symbol
		       o::obj
		       t1::bint
		       n1::symbol
		       o1::obj)
    (store-signature-3 fun::obj
		       fun-type::bint
		       loc::obj
		       name::symbol
		       minimum-arity::bint
		       maximum-arity::bint
		       t::bint
		       n::symbol
		       o::obj
		       t1::bint
		       n1::symbol
		       o1::obj
		       t2::bint
		       n2::symbol
		       o2::obj)
    (store-library-include program fun::obj fun-type::bint loc::obj name::symbol minimum-arity::bint maximum-arity::bint t::bint n::symbol o::obj)    
    (store-alias alias::symbol name::symbol)
    (function-name-uncase::symbol fun-name::symbol)
    (builtins-for-each proc)
    (aliases-for-each proc)
    (get-user-function-list)
    (reset-signatures!)
    (php-check-arity signature::object call-name::obj call-length::bint)
    (get-user-function-sig name)
    ;;the api for the signatures themselves
    (sig-minimum-arity::bint sig::object)
    (sig-maximum-arity::bint sig::object)
    (sig-length::bint sig::object)
    (sig-ref sig::object i)
    (sig-canonical-name::symbol sig::object)
    (sig-param-default-value param::object)
    (sig-param-ref?::bbool param::object)
    (sig-param?::bbool param::obj)
    (sig-param-optional?::bbool param::object)
    (sig?::bbool sig::obj)
    (sig-var-arity?::bbool sig::object)
    (sig-function::obj sig::object)
    (sig-function-set! sig::object function::procedure)
    (function-available-at-link-time?::bbool sig::object))

   (static
    
    ;the formal parameters, name, and type of a function
    (class function-signature
       file::bstring
       line::bint
       name::symbol
       canonical-name::symbol
       function::obj
       minimum-arity::bint
       maximum-arity::bint
       type::bint
       (* params::param))
    
    ;signature of a function with a variable number of params
    (class var-arity-signature::function-signature)
    
    ;a formal parameter of a function
    ;XXX incredibly enough, if this class is called "parameter", the make-parameter
    ;function isn't bound to the constructor in php.scm, but instead to something that
    ;returns #f.. !?  Oh well, "param" is shorter, anyway.
    (abstract-class param
       file::bstring
       line::bint
       name::symbol
       ref?::bbool
       type::bint)
    (class required-param::param)
    (class optional-param::param
       default-value::obj)
    
    (generic sig-argref sig index) ))



(define *builtins* (make-grasstable))
(define *aliases* (make-grasstable))

;the table containing main and user function sigs. reset each page load.
(define *function-sig-table* (make-grasstable))
;the table that caching sigs based on source file so we can load them quickly
;on consecutive page loads. this is key'd by file-location, the value is a dynarray of sigs
(define *function-sig-cache-table* (make-grasstable))

(define (reset-signatures!)
   ;XXX oops!  aliases defined for user functions should probably be deleted too. 
   (set! *function-sig-table* (make-grasstable)))

(define (function-name-canonicalize::symbol fun-name::symbol)   
   (set! fun-name (function-name-uncase fun-name))
   (let ((alias (grasstable-get *aliases* fun-name)))
      ;(fprint (current-error-port) "canoning " fun-name " alias is " alias " aliases is " *aliases*)
      (if alias
	  alias
	  fun-name)))

(define (function-name-uncase::symbol fun-name::symbol)
   (let ((sfun-name (symbol->string fun-name)))
      (if (string-index sfun-name "+/")
	  fun-name
	  (string->symbol (string-downcase sfun-name)))))

;   (let ((fun-name-str (symbol->string fun-name)))
;      (let loop ((i (-fx (string-length fun-name-str) 1)))
;	 (if (>=fx i 0)
;	     ;; Only downcase if there's no slash, to avoid screwing up mangled names
;	     ;; Also, a plus indicates an +include+:foo.php name, which we shouldn't
;	     ;; touch either.
;	     (if (or (char=? (string-ref fun-name-str i) #\/)
;		     (char=? (string-ref fun-name-str i) #\+))
;		 ;; slash or plus found, no downcase
;		 fun-name
;		 (if (=fx i 0)
;		     ;at the end (beginning), no slash found, so downcase
;		     (string->symbol (string-downcase fun-name-str))
;		     ;still looking
;		     (loop (-fx i 1))))))))

(define (dump-builtin-list)
    (print "current builtin function list:")
    (display *builtins*)
    (grasstable-for-each *builtins*
 		       (lambda (key obj)
 			  (print key ))))

(define (builtins-for-each proc)
   (grasstable-for-each *builtins* proc))

(define (aliases-for-each proc)
   (grasstable-for-each *aliases* proc))


(define-generic (sig-argref v i)
   (error 'sig-argref "not a function signature" v))

(define-method (sig-argref v::function-signature i)
   (with-access::function-signature v (params)
      (if (>= i params-len)
	  an-instance-of-a-non-reference-param
	  (params-ref i))))

(define an-instance-of-a-non-reference-param
   (make-required-param "" 0 'sandy #f -1))

(define-method (sig-argref v::var-arity-signature i)
   (with-access::var-arity-signature v (params)
      (if (= params-len 0)
	  ;in the no parameter case, use a dummy
	  an-instance-of-a-non-reference-param
	  (if (>= i params-len)
	      (params-ref (- params-len 1))
	      (params-ref i)))))


(define (sig-function::obj sig::object)
   (function-signature-function sig))

(define (sig-function-set! sig::object function::procedure)
   (function-signature-function-set! sig function))

;;;parameter types
;same in php-macros
(define t-notype -1)
(define t-required 0)
(define t-reference 1)
(define t-optional 2)
(define t-optional-reference 3)

;;;function types
;same in php-macros
(define ft-main 0)
(define ft-builtin 1)
(define ft-user-interpreted 2)
(define ft-builtin-constructor 3)
(define ft-builtin-method 4)
(define ft-compat 5)
(define ft-user-compiled 6)

;(function-type function-name parameter-type parameter-name ...)

; try to import previously created signatures for compiled file-location
(define (try-import-cached-sigs::bbool file-location::bstring)
;   (debug-trace 0 "trying import for " file-location ", cache is: \n" *function-sig-cache-table*)
   (let ((sig-array (grasstable-get *function-sig-cache-table* file-location)))
      (if sig-array
	  (begin
	     (let loop ((i 0))
		(when (<fx i (dynarray-length sig-array))
		   (let* ((sig-pair (dynarray-ref sig-array i))
			  (grassnumber (car sig-pair))
			  (sig (cdr sig-pair)))
		      (grasstable-put!/pre *function-sig-table*
					   (function-signature-name sig)
					   grassnumber
					   sig)
		      (loop (+fx i 1)))))
	     #t)
	  #f)))

; signatures come in chunks by file, as that file is included
; rather than calculate grassnumber for each file-location, we store the last
; file-location we caclulated and do a string compare to match, since this is
; less expensive than the hash. this way we only recalcuate it as the signatures
; from a new file come in
(define %last-file-location "")
(define %last-grassnumber 0)

(define (%add-sig fun-type::bint file-location::bstring fun-name::symbol sig::function-signature)
;   (debug-trace 0 "adding " fun-name " @ " file-location " type " fun-type)
   (let ((fun-table (case fun-type
		       ;ft-main
		       ((0) *function-sig-table*)
		       ;ft-builtin, ft-compat
		       ((1 5) *builtins*)
		       ;ft-user-*
		       ((2 6) *function-sig-table*)
		       (else (error 'get-function-table "unknown function type" fun-type))))
	 (fun-grassnumber (get-grassnumber fun-name)))
      ; active table
      (grasstable-put!/pre fun-table fun-name fun-grassnumber sig)
      ;
      ; XXX we should distinguish between compiled-for-web and standalones because this is useless
      ; for stand alones and increases startup time
      ;
      ; cache the signature. only useful for compiled functions in web backends
      (when (and (=fx fun-type 6) (>fx (string-length file-location) 0))
	 (let* ((grassnumber (if (string=? %last-file-location file-location)
				 %last-grassnumber
				 (begin
				    (set! %last-file-location file-location)
				    (set! %last-grassnumber (get-grassnumber file-location))
				    %last-grassnumber)))
		(cache-array (grasstable-get/pre *function-sig-cache-table* grassnumber file-location)))
	    (if cache-array
		(dynarray-pushback! cache-array (cons fun-grassnumber sig))
		(let ((new-array (make-dynarray)))
		   (dynarray-pushback! new-array (cons fun-grassnumber sig))
		   (grasstable-put!/pre *function-sig-cache-table* file-location grassnumber new-array)))))))

(define (store-signature fun::obj fun-type::bint loc::obj name::symbol minimum-arity::bint maximum-arity::bint . params)
   (let ((file (if (pair? loc) (cdr loc) (mkstr loc)))
	 (line (if (pair? loc) (car loc) 0)) ; 0 = unknown line
	 (params-len (/fx (length params) 3)))
      (let ((sig (if (=fx -1 maximum-arity)
		     (make-var-arity-signature file line name 'unset fun minimum-arity maximum-arity fun-type params-len (param-nil))
		     (make-function-signature file line name 'unset fun minimum-arity maximum-arity fun-type params-len (param-nil)))))
	 (let loop ((i 0)
		    (params params))
	    (when (pair? params)
	       (let ((param-type (car params))
		     (param-name (cadr params))
		     (param-default-value (caddr params)))
		  (store-param sig i param-type param-name param-default-value)
		  (loop (+fx i 1) (cdddr params)))))
	 (%add-sig fun-type file name sig)
	 sig)))


(define (store-signature-0 fun::obj fun-type::bint loc::obj name::symbol minimum-arity::bint maximum-arity::bint)
   (let ((file (if (pair? loc) (cdr loc) (mkstr loc)))
	 (line (if (pair? loc) (car loc) 0)))
      (let ((sig (if (=fx -1 maximum-arity)
		     (make-var-arity-signature file line name 'unset fun minimum-arity maximum-arity fun-type 0 (param-nil))
		     (make-function-signature file line name 'unset fun minimum-arity maximum-arity fun-type 0 (param-nil)))))
	 (%add-sig fun-type file name sig))))

(define (store-signature-1 fun::obj
			   fun-type::bint
			   loc::obj
			   name::symbol
			   minimum-arity::bint
			   maximum-arity::bint
			   t::bint
			   n::symbol
			   o::obj)
   (let ((file (if (pair? loc) (cdr loc) (mkstr loc)))
	 (line (if (pair? loc) (car loc) 0)))
      (let ((sig (if (=fx -1 maximum-arity)
		     (make-var-arity-signature file line name 'unset fun minimum-arity maximum-arity fun-type 1 (param-nil))
		     (make-function-signature file line name 'unset fun minimum-arity maximum-arity fun-type 1 (param-nil)))))
	 (store-param sig 0 t n o)
	 (%add-sig fun-type file name sig))))

(define (store-signature-2 fun::obj
			   fun-type::bint
			   loc::obj
			   name::symbol
			   minimum-arity::bint
			   maximum-arity::bint
			   t::bint
			   n::symbol
			   o::obj
			   t1::bint
			   n1::symbol
			   o1::obj)
   (let ((file (if (pair? loc) (cdr loc) (mkstr loc)))
	 (line (if (pair? loc) (car loc) 0)))
      (let ((sig (if (=fx -1 maximum-arity)
		     (make-var-arity-signature file line name 'unset fun minimum-arity maximum-arity fun-type 2 (param-nil))
		     (make-function-signature file line name 'unset fun minimum-arity maximum-arity fun-type 2 (param-nil)))))
	 (store-param sig 0 t n o)
	 (store-param sig 1 t1 n1 o1)
	 (%add-sig fun-type file name sig))))

(define (store-signature-3 fun::obj
			   fun-type::bint
			   loc::obj
			   name::symbol
			   minimum-arity::bint
			   maximum-arity::bint
			   t::bint
			   n::symbol
			   o::obj
			   t1::bint
			   n1::symbol
			   o1::obj
			   t2::bint
			   n2::symbol
			   o2::obj)			   
   (let ((file (if (pair? loc) (cdr loc) (mkstr loc)))
	 (line (if (pair? loc) (car loc) 0)))
      (let ((sig (if (=fx -1 maximum-arity)
		     (make-var-arity-signature file line name 'unset fun minimum-arity maximum-arity fun-type 3 (param-nil))
		     (make-function-signature file line name 'unset fun minimum-arity maximum-arity fun-type 3 (param-nil)))))
	 (store-param sig 0 t n o)
	 (store-param sig 1 t1 n1 o1)
	 (store-param sig 2 t2 n2 o2)
	 (%add-sig fun-type file name sig))))

(define (store-library-include program fun::obj fun-type::bint loc::obj name::symbol minimum-arity::bint maximum-arity::bint t::bint n::symbol o::obj)
   (let ((file (if (pair? loc) (cdr loc) (mkstr loc)))
	 (line (if (pair? loc) (car loc) 0)))
      (let ((sig (if (=fx -1 maximum-arity)
		     (make-var-arity-signature file line name 'unset fun minimum-arity maximum-arity fun-type 1 (param-nil))
		     (make-function-signature file line name 'unset fun minimum-arity maximum-arity fun-type 1 (param-nil)))))
	 (store-param sig 0 t n o)
	 (%add-sig fun-type file name sig)	 
	 (add-library-include program name sig))))
      
(define (store-param sig::object index::bint param-type::bint param-name::symbol param-default-value::obj)
   (function-signature-params-set!
    sig index
    (case param-type
       ;t-required
       ((0) (make-required-param "" 0 param-name #f -1))
       ;t-reference
       ((1) (make-required-param "" 0 param-name #t -1))
       ;t-optional
       ((2) (make-optional-param "" 0 param-name #f -1 param-default-value))
       ;t-optional-reference
       ((3) (make-optional-param "" 0 param-name #t -1 param-default-value))
       (else (error 'store-signature "unknown param-type" param-type)))))


(define (get-php-function-sig name)
   (let* ((canon-fun (function-name-canonicalize
		      (if (string? name)
			  (string->symbol name)
			  name) ))
	  (sig (or (grasstable-get *function-sig-table* canon-fun)
		   (grasstable-get *builtins* canon-fun)
		   (get-library-include canon-fun #f))))
;       (debug-trace 0 "got " sig " looking up " name " which canonicalized to " canon-fun)
;       (hashtable-for-each *builtins*
;          (lambda (k v)
;             (debug-trace 0 "jjj: have " k)))
      (if sig
	  (begin
	     ;not the prettiest, but whatever
	     (function-signature-canonical-name-set! sig canon-fun)
	     sig)
	  #f)))

(define (get-user-function-sig name)
   "doesn't canonicalize or anything.. for internal use blah blah"
   (grasstable-get *function-sig-table* name))

(define (get-user-function-list)
   "return a list of currently define user functions. used in get_defined_functions builtin"
   (let ((flist '()))
      (grasstable-for-each *function-sig-table*
			  (lambda (fname sig)
			     (when (= (function-signature-type sig) 2)
				(set! flist (cons (symbol->string fname) flist)))))
      flist))

(define (store-alias alias name)
   (grasstable-put! *aliases* alias name))




;the table containing include init functions from libraries
(define *library-includes* (make-grasstable))

; a library will define its include files with this
(define (add-library-include lib-name include-name sig)
   (let ((current (grasstable-get *library-includes* include-name)))
      (if current
	  (grasstable-put! *library-includes*
			  include-name
			  (cons (cons lib-name sig) current))
	  (grasstable-put! *library-includes*
			  include-name
			  (list (cons lib-name sig))))))

; find-include-file-in-lib uses this
(define (get-library-include include-name lib-name)
   (let ((current (grasstable-get *library-includes* include-name)))
      (if current
	  (if lib-name
	      ; specific lib
	      (let loop ((liblist current))
		 (when (pair? liblist)
		    (if (string=? (caar liblist) lib-name)
			(cdar liblist)
			(loop (cdr liblist)))))
	      ; first match
	      (cdar current))
	  ; include file not found in libs
	  #f)))

(define (php-check-arity signature::object call-name::obj call-length::bint)
   "signal a warning if a function call has too few or too many arguments"
   (if (<fx call-length (sig-minimum-arity signature))
       (php-warning (format "Not enough arguments for function ~a: ~a required, ~a provided."
			    call-name (sig-minimum-arity signature) call-length))
       (if (and (not (=fx (sig-maximum-arity signature) -1))
		(>fx call-length (sig-maximum-arity signature)))
	   (php-warning (format "Too many arguments for function ~a: ~a accepted, ~a provided."
				call-name (sig-maximum-arity signature) call-length)))))

(define (sig-minimum-arity sig)
   (function-signature-minimum-arity sig))

(define (sig-maximum-arity sig)
   (function-signature-maximum-arity sig))

(define (sig-length sig)
   (function-signature-params-len sig))

(define (sig-ref sig i)
   (sig-argref sig i))

(define (sig-canonical-name sig)
   (function-signature-canonical-name sig))

(define (sig? sig)
   (function-signature? sig))

(define (sig-var-arity? sig)
   (var-arity-signature? sig))

(define (sig-param? param)
   (param? param))

(define (sig-param-default-value param)
   (if (optional-param? param)
       (optional-param-default-value param)
       ''()))

(define (sig-param-ref? param)
   (param-ref? param))

(define (sig-param-optional? param)
   (optional-param? param))

(define (get-signature-extension sig)
   ;; return the extension name, e.g. "php-gtk", that this function is
   ;; defined in.
   (if (or (= ft-builtin (function-signature-type sig))
           (= ft-compat (function-signature-type sig)))
       (function-signature-file sig)
       #f))

(define (function-available-at-link-time? sig)
   (not (= (function-signature-type sig) ft-compat)))
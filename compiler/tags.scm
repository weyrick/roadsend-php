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


;;;; Create TAGS files in the Exuberant Ctags format.
;;;; See http://ctags.sourceforge.net/FORMAT for more info.
(module tags
   (library php-runtime)
   (include "php-runtime.sch")
   (import
    (ast "ast.scm")
    (driver "driver.scm"))
   (main main)) 

(define *scm-extension* #f)
(define *apidoc?* #f)
(define *progress?* #f)
(define *do-sort?* #t)
(define *limit-defines* #f)

(define *define-cache* (make-hashtable))

(define *EXT-TYPE-PHP* "0")
(define *LANG-COMPAT-PHP5* "1")

(define (main argv)
   (let* ((input-files '())
	  (parse-make-file (lambda (file)
			      (debug-trace 1 (format "Using project make file " file))
			      (unless (file-exists? file)
				 (print (format "project make file ~a does not exist" file))
				 (exit -1))
			      (let ((ini-vals (ini-file-parse file #t)))
			        (php-hash-for-each ini-vals
					(lambda (section vals)
					   (when (php-hash? vals)
					      (php-hash-for-each vals
							(lambda (k v)
							   (cond
							    ((and (string=? section "base")
								  (string=? k "langCompat")
								  (string=? v *LANG-COMPAT-PHP5*))
							     (set! PHP5? #t))
							    ((string=? section "files")
							     (when (string=? v *EXT-TYPE-PHP*)
								   (set! input-files (cons k input-files)))
							      ))))))))
			     )))
      (args-parse (cdr argv)
	 (section "Help")
	 (("?")
	  (args-parse-usage #f)
	  (exit -1))
	 ((("-h" "--help") (help "?,-h,--help" "This help message"))
	  (args-parse-usage #f)
	  (exit -1)
	  )	 
	 (section "Misc")
	 ((("-v" "--version") (help "Version number"))
	  (print *RAVEN-VERSION-STRING*)
	  (exit -1)
	  )
	 ((("-p") (help "Show progress on stderr"))
	  (set! *progress?* #t)
	  )
	 ((("-5") (help "Enable PHP5 support"))
	  (set! PHP5? #t))
	 ((("--no-sort") (help "Don't sort the tags"))
	  (set! *do-sort?* #f)
	  )
	 (("--limit-defs" ?limit (help "Limit amount of duplicate defines"))
	  (set! *limit-defines* (mkfixnum limit)))
	 (("-m" ?file (help "Use file list from specified project config file"))
	  (parse-make-file file))
	 (("--scm-extension" ?ext-name (help "Parse scheme extension"))
	  (set! *scm-extension* ext-name))
	 (("--apidoc" (help "Make API documentation instead of a tag file"))
	  (set! *apidoc?* #t))	 
	 (else
	  (set! input-files (cdr argv))))
      ;
      (unless *apidoc?*
	 (print-ctags-header))
      (when *progress?*
	 (fprint (current-error-port) (mkstr ">>> # " (length input-files)))
	 (flush-output-port (current-error-port)))
      (if *scm-extension*
	  ;; scheme extension, scan for defbuiltin, defalias, defconstant
	  (begin
	     (for-each (lambda (file)
			  (parse-scm-extension-file file))
		       input-files)
	     (finish-gtk-tags-generation)
	     (clean-ctags))
	  ;;read each file into an ast, and then walk over it collecting tag info
	  (let ((cnt 1))
	     (for-each (lambda (file)
			  (when *progress?*
			     (fprint (current-error-port) (mkstr ">>> " cnt))
			     (flush-output-port (current-error-port))
			     (set! cnt (+ 1 cnt)))
			  (when (file-exists? file)
			     ;;we bind *RAVEN-DEVEL-BUILD* to #f so that the lexer prints
			     ;;an error instead of throwing it.  This way the behavior will be
			     ;;consistent.
			     (dynamically-bind (*RAVEN-DEVEL-BUILD* #f)
					       (walk-ast (input-file->ast file #t)
							 collect-tag-info))))
		       input-files)))
      ; sort, print
      (when *do-sort?*
	 (sort-ctags))
      (print-ctags)))

(define (parse-scm-extension-file file)
   (let ((alias-hash (make-hashtable))
	 (func-hash (make-hashtable)))
      (when (file-exists? file)
	 (with-input-from-file file
	    (lambda ()
	       (let loop ((exp (read (current-input-port))))
		  (when (not (eof-object? exp)) 
		     (when (pair? exp)
			(case (car exp)
			   ((defbuiltin defbuiltin-v)
			    (let* ((def (cadr exp))
				   (docstring (if (string? (caddr exp)) (caddr exp) ""))
				   (fname (->string (car def)))
				   (paramlist (scm-parameter-list->string (cdr def))))
			       (collect-extension-ctag
				fname
				docstring
				*scm-extension*
				+kind-function+							  
				(cons "parameters" paramlist))
			       (hashtable-put! func-hash fname paramlist)))
			   ((defalias)			    
			    (hashtable-put! alias-hash (cadr exp) (list-ref exp 2)))
			   ((defconstant)
			    (collect-extension-ctag
			     (->string (cadr exp))
			     "" ; docstring
			     *scm-extension*
			     +kind-constant+))
			   ((def-pgtk-methods) (handle-pgtk-methods exp))
			   ((def-static-methods) (handle-static-methods exp))
			   ((def-ext-class) (handle-ext-class exp))
			   ((defclass) (handle-defclass exp))
			   ((defmethod) (handle-defmethod exp))
			   ((defenum) (handle-defenum exp))
			   ((defflags) (handle-defflags exp))
			   ((def-property-getter) (handle-def-property-getter exp))))
		     ; next!
		     (loop (read (current-input-port)))))))
	 ; do aliases
	 (hashtable-for-each alias-hash
			     (lambda (alias-name real-name)
				;(print "looking up real name " real-name)
				(let ((paramlist (hashtable-get func-hash (->string real-name))))
				   (if paramlist
				       (collect-extension-ctag
					(->string alias-name)
					"" ; docstring
					*scm-extension*
					+kind-function+
					(cons "parameters" paramlist))			   
				       (fprint (current-error-port)
					       "function that alias points to wasn't found: "
					       alias-name " -> " real-name))))))))

;;skim tag info from an AST, one method per node type that we print out
(define-generic (collect-tag-info node k)
   (k))

(define *current-class* "none")
(define-method (collect-tag-info node::class-decl k)
   (with-access::class-decl node (name parent location end-line)
      (if (null? parent)
	  (collect-ctag (->string name) "" (cdr location) (car location)
			+kind-class+ (cons "end-line" (car end-line)))
	  (collect-ctag (->string name) "" (cdr location) (car location)
			+kind-class+ (cons "inherits" (->string parent))
			(cons "end-line" (car end-line))))
      (dynamically-bind (*current-class* (->string name))
	 (k))))

(define-method (collect-tag-info node::function-decl k)
   (with-access::function-decl node (name location decl-arglist end-line)
      (collect-ctag (->string name) "" (cdr location) (car location)
		    +kind-function+
		    (cons "parameters"
			  (parameter-list->string decl-arglist))
		    (cons "end-line" (car end-line))))
   (k))

(define-method (collect-tag-info node::method-decl k)
   (with-access::method-decl node (name location decl-arglist end-line)
      (collect-ctag (->string name) "" (cdr location) (car location)
		    +kind-method+ (cons "class" *current-class*)
		    (cons "parameters"
			  (parameter-list->string decl-arglist))
		    (cons "end-line" (car end-line))))
   (k))

(define-method (collect-tag-info node::property-decl k)
   (with-access::property-decl node (name location)
      (collect-ctag (->string name) "" (cdr location) (car location)
		    +kind-property+ (cons "class" *current-class*)))
   (k))

(define-method (collect-tag-info node::constant-decl k)
   (with-access::constant-decl node (name location)
      (let ((allow? #t))
	 (if *limit-defines*
	     (let ((this-def (hashtable-get *define-cache* (->string name))))
		(if this-def
		    (if (< this-def *limit-defines*)
			; inc count
			(hashtable-put! *define-cache* (->string name) (+ this-def 1))
			; over limit
			(set! allow? #f))
		    ; inc count
		    (hashtable-put! *define-cache* (->string name) 1))))
	 (when allow?
	    (collect-ctag (->string name) "" (cdr location) (car location)
			  +kind-constant+))))
   (k))


;; this the list of all tags seen so far
(define *ctags* '())

;; collect a tag from a scheme extension
(define (collect-extension-ctag name docstring extension kind . extended)
   (apply collect-ctag name docstring extension 0 kind (cons "extension" extension) extended))

;; create a tag and add it to *ctags*
(define (collect-ctag name docstring file address kind . extended)
   (let ((new-tag (apply create-ctag name docstring file address kind extended)))
      (set! *ctags* (cons new-tag *ctags*))
      new-tag))

;; clean ctags of functions that aren't valid php. this is basically
;; for scheme extensions that have aliases to schemey named functions
(define (clean-ctags)
   (set! *ctags*
	 (filter (lambda (v)
		    (not (pregexp-match "-" (ctag-name v))))
		 *ctags*)))

;;sort the tags in *ctags* alphabetically by name
(define (sort-ctags)
   (set! *ctags*
	 (sort *ctags*
	       (lambda (a b)
		  (string<? (ctag-name a) (ctag-name b))))))

;;print out the tags in *ctags*
(define (print-ctags)
   (if *apidoc?*
       (for-each (lambda (tag)
		    (when (and (string? (ctag-kind tag))
			       (or (string=? (ctag-kind tag) +kind-function+)
				   (string=? (ctag-kind tag) +kind-constant+)))
		       (let ((texi-type (cond ((string=? (ctag-kind tag) +kind-function+) "Function")
					      ((string=? (ctag-kind tag) +kind-constant+) "Constant")
					      (else
					       "Unknown"))))
			  (display* "@deffn " texi-type " " (ctag-name tag) " ")
			  (for-each (lambda (p)
				       (when (string=? (car p) "parameters")
					  (display (cdr p))))
				    (ctag-extended tag))
			  (newline)
			  (display* (ctag-docstring tag) "\n")
			  (newline)
			  (display* "@end deffn\n")
			  (newline))))
		 *ctags*)
       (for-each (lambda (tag)
		    (display* (ctag-name tag) "\t"
			      (ctag-file tag) "\t"
			      (ctag-address tag) ";\"\t"
			      (ctag-kind tag))
		    (for-each (lambda (p)
				 (display* "\t" (car p) ":" (cdr p)))
			      (ctag-extended tag))
		    (newline))
		 *ctags*)))

;;print an exuberant ctags header
(define (print-ctags-header)
   (print "!_TAG_FILE_FORMAT\t2\t/extended format; --format=1 will not append ;\" to lines/")
   (print "!_TAG_FILE_SORTED\t1\t/0=unsorted, 1=sorted, 2=foldcase/")
   (print "!_TAG_PROGRAM_AUTHOR\tRoadsend\t/support@roadsend.com/")
   (print "!_TAG_PROGRAM_NAME\tRoadsend Tags\t//")
   (print "!_TAG_PROGRAM_URL\thttp://roadsend.com\t/Roadsend site/")
   (print "!_TAG_PROGRAM_VERSION\t5.5\t//"))

;;;;the ctag type.  
(define (create-ctag name docstring file address kind . extended)
   (list name docstring file address kind extended))

(define (ctag-name tag)
   (car tag))

(define (ctag-docstring tag)
   (cadr tag))

(define (ctag-file tag)
   (caddr tag))

(define (ctag-address tag)
   (cadddr tag))

(define (ctag-kind tag)
   (cadddr (cdr tag)))

;;an alist of extended properties
(define (ctag-extended tag)
   (cadddr (cddr tag)))


(define +kind-class+ "c") 		; class name
(define +kind-constant+ "d")		; define() 
(define +kind-function+ "f")		; function name
(define +kind-method+ "m") 		; method name
(define +kind-property+ "v")		; var $foo


(define (clean s)
   (pregexp-replace "[-/]" (->string s) "_"))
   
;;;produce a string representation of a function's parameter
;;;list which looks roughly like it would in PHP source
(define (parameter-list->string decl-arglist)
;   (let ((op-count 0))
   (with-output-to-string
      (lambda ()
	 (display "(")
	 (let loop ((p1 (gcar decl-arglist))
		    (p2 (gcar (gcdr decl-arglist)))
		    (rest (gcdr (gcdr decl-arglist))))
	    (when (not (null? p1))
	       (when (optional-formal-param? p1)
		  (display "["))	       
	       (display (formal-param-name p1))
	       (when (optional-formal-param? p1)
		  ;(set! op-count (+ op-count 1))
		  (display "=")
		  (display (default-value->string
			      (optional-formal-param-default-value p1)));)
		  (display "]"))
	       (when (not (null? p2))
;		  (if (optional-formal-param? p2)
;		      (display " [,")
		      (display ","));)
	       (loop p2 (gcar rest) (gcdr rest))))
;	 (display (make-string op-count #\]))
	 (display ")"))));)

; same but for scheme extensions 
(define (scm-parameter-list->string arglist)
   (with-output-to-string
      (lambda ()
	 (display "(")
	 (let loop ((arg (gcar arglist))
		    (rest (gcdr arglist)))
	    (when (not (null? arg))
;	       (print "arg is " arg)
	       (if (pair? arg)
		   (if (pair? (cdr arg))
		       ; default arg
		       (display (->string "[$" (if (pair? (car arg))
					       (clean (cdr (car arg))) ; optional by ref 
					       (clean (car arg)))
					       "=" (strip-newlines
							  (cond ((pair? (cadr arg)) "NULL")
								((symbol? (cadr arg)) (symbol->string (cadr arg)))
								((number? (cadr arg)) (number->string (cadr arg)))
								(else (->string "\"" (cadr arg) "\""))))
					       "]"))
		       ; ref
		       (display (->string "$" (clean (cdr arg)))))
		   ; normal
		   (display (->string "$" (clean arg))))
	       (when (not (null? rest))
		  (display ","))
	       (loop (gcar rest) (gcdr rest))))
	 (display ")"))))


(define (strip-newlines str)
   (list->string
    (filter (lambda (v)
	       (not (or (char=? v #\Newline)
			(char=? v #\Return))))
	    (string->list str))))

;;;this generic function produces a string represention for
;;;the default values of optional arguments, which should look
;;;roughly the same as it would in PHP source.
(define-generic (default-value->string node)
   (fprint (current-error-port) "don't know what to do with default value: " node))

(define-method (default-value->string node::php-constant)
   (->string (php-constant-name node)))

(define-method (default-value->string node::lyteral)
   (cond ((eq? (lyteral-value node) #f) "false")
	 ((eq? (lyteral-value node) #t) "true")
	 (else (lyteral-value node))))

(define-method (default-value->string node::literal-string)
   (let ((thestring (strip-newlines (lyteral-value node))))      
      (->string #\" thestring  #\")))

(define-method (default-value->string node::literal-null)
   "NULL")

(define-method (default-value->string node::literal-integer)
   (->string (convert-to-number (lyteral-value node))))

(define-method (default-value->string node::literal-float)
   (->string (convert-to-number (lyteral-value node))))

(define-method (default-value->string node::arithmetic-unop)
   (with-access::arithmetic-unop node (op a)
      (ecase op
	 ((php-+) (->string (convert-to-number (default-value->string a))))
	 ((php--) (->string (php-- *zero* (default-value->string a)))))))


(define-method (default-value->string node::literal-array)
   (with-access::literal-array node (array-contents)
      (with-output-to-string
	 (lambda ()
	    (display "array(")
	    (let loop ((a (gcar array-contents))
		       (b (gcar (gcdr array-contents)))
		       (rest (gcdr (gcdr array-contents))))
	       (when (not (null? a))
		  (with-access::array-entry a (key value ref?)
		     (unless (eqv? key :next)
			(display (default-value->string key))
			(display "=>"))
		     (when ref? (display "&"))
		     (display (default-value->string value))
		     (when (not (null? b))
			(display ", "))
		     (loop b (gcar rest) (gcdr rest)))))
	    (display ")")))))



;;;;;;;;;;;;;;;;
;;; This is Gtk Stuff
(define (finish-gtk-tags-generation)
   "hook for any final fixups we might need"
   #t)

		
;; def-pgtk-methods
(define (handle-pgtk-methods exp)
   (let ((php-class-name (cadr exp)))
      (for-each (lambda (method)
		   (let ((parameters (cdr method)))
;			  (cons `($this :gtk-type ,php-class-name)

		      ;; we want to avoid emitting tags for methods that are
		      ;; currently disabled so we check if any of the parameters
		      ;; or the return value has a "borked" type
		      (unless (or (some currently-borked?
					(map (lambda (a)
						(key-assoc :gtk-type a 'borked))
					     parameters))
				  (currently-borked? (key-assoc :return-type (car method)
								'okay-batman)))
			 (let ((method-name (argument-name (car method))))
			    (handle-php-method php-class-name method-name parameters)))))
		(cdddr exp))))


(define (handle-php-method class-name method-name parameters)
   (collect-extension-ctag
    (->string method-name) "" *scm-extension* 
    +kind-method+ (cons "class" (->string class-name))
    (cons "parameters"
	  ;; the parameter list can include optional parameters
	  ;; with default values  
	  (with-output-to-string
	     (lambda ()
		(display "(")
		(for-each display
			  (join ","
				(map (lambda (arg)
					(if (key-assoc :default arg #f)
					    (->string "[$" (argument-name arg) "="
						   (gtk-default-value->string
						    (key-assoc :default arg #f))
						   "]")
					    (->string "$" (argument-name arg))))
				     parameters)))
		(display ")"))))))

(define (gtk-default-value->string value)
   (if (pair? value)
       (if (eqv? (car value) 'bitwise-or)
	   (with-output-to-string
	      (lambda ()
		 (for-each display
			   (join "|" (cdr value)))))
	   (error 'gtk-default-value->string "please add code to make this default value printable to tags.scm" value))
       (if (string? value)
	   (->string #\" value #\")
	   value)))


;; def-static-methods
(define (handle-static-methods exp)
   (handle-pgtk-methods exp))

;; def-ext-class
(define (handle-ext-class exp)
   (handle-defclass exp))

;; defclass
(define (handle-defclass exp)
   (let ((name (cadr exp)))
      (if (pair? name)
	  (let ((parent (cadr name))
		(name (car name)))
	     (collect-extension-ctag (->string name) "" *scm-extension* 
				     +kind-class+ (cons "inherits" (->string parent))))
	  (collect-extension-ctag (->string name) "" *scm-extension* 
				  +kind-class+))))


;; defmethod
(define (handle-defmethod exp)
   (let ((class-name (cadr exp))
	 (method-name (caar (cddr exp)))
	 (parameters (cdar (cddr exp))))
      (cond
	 ((member '#!optional parameters)
	  (set! parameters
		;; we rewrite the optional parameters into the def-pgtk-methods format
		(reverse!
		 (let loop ((params (reverse parameters))
			    (new-params '()))
		    (match-case (car params)
		       (#!optional (append (cdr params) new-params))
		       ((?name ?value) (loop (cdr params)
					     (cons (list name :default value)
						   new-params)))
		       (?a (loop (cdr params) (cons a new-params)))
		       (else (error 'handle-defmethod "malformed optional parameter" (car params))))))))
	 ((member '#!rest parameters)
	  (set! parameters
		;; take advantage of the fact that member returns the tail of the list
		(reverse (cons (list (last parameters) :default "NULL")
			       (cdr (member #!rest (reverse parameters))))))))
      (handle-php-method class-name method-name parameters)))


;; defenum
(define (handle-defenum exp)
   (let ((names (map cadr (cddr exp))))
      (for-each (lambda (c)
		   (collect-extension-ctag (->string c) "" *scm-extension* 
					   +kind-constant+))
		names)))

;; defflags
(define (handle-defflags exp)
   (handle-defenum exp))

;; def-property-getter
(define (handle-def-property-getter exp)
   ;;XXX there are still some properties not being defined with def-property-getter
   (let ((class-name (->string (caddr exp)))
	 (properties (map car (cdddr exp)))
	 (propert-types (map cadr (cdddr exp))))
      (for-each (lambda (p t)
		   (unless (currently-borked? t)
		      (collect-extension-ctag (->string "$" p) "" *scm-extension* 
					      +kind-property+ (cons "class" class-name))))
		properties propert-types)))

(define (some thunk lst)
   (bind-exit (found)
      (for-each (lambda (a)
		   (when (thunk a)
		      (found #t)))
		lst)
      #f))

(define (currently-borked? type)
   (member type *currently-borked-types*))

(define *currently-borked-types*
   ;; these are mostly fixed.  For more info on what still needs work,
   ;; do a GTK_DEBUG=t make clean all in runtime/ext/gtk.
   '())
;   '(GdkBitmap** GdkPoint*)
   ; '(guint* GSList* gint* int* GList*
;      guint32** GSList** GtkArgInfo** GScanner* GtkPatternSpec* gpointer
;      GtkMenuEntry* GtkFunction GdkInputFunction GtkKeySnoopFunc
;      GtkPreviewInfo* GtkRcStyle* GtkImageLoader GdkEventProperty*
;      GtkSignalFunc GtkEmissionHook GtkSignalQuery* GtkArg*
;      GtkSignalMarshal GdkPoint* GtkTooltipsData* GtkTypeObject*
;      GtkTypeClass* GtkEnumValue* GtkFlagValue* GdkBitmap**
;      const-GdkWChar* GdkImage* GdkSegment* GdkAtom GtkAccelEntry* GQuark
;      GtkDestroyNotify GtkWidget** GdkEventSelection* GtkTargetList*
;      const-GtkTargetEntry* GtkItemFactoryEntry* GtkTranslateFunc
;      GtkCallback GdkPixmap** gfloat* GdkImage** gboolean*
;      GtkCListCompareFunc guint8* GdkGeometry* GtkCTreeCompareDragFunc
;      GtkCTreeRow* GtkCTreeFunc GNode* oops: GtkMenuDetachFunc
;      GtkMenuPositionFunc GtkObjectClass GtkTypeQuery* const-GtkTypeInfo*
;      GtkSelectioData* GtkTargetList)
;   )


(define (key-assoc key lst default)
   (if (pair? lst)
       (let loop ((a (car lst))
		  (lst (cdr lst)))
	  (if (eqv? a key)
	      (if (pair? lst)
		  (car lst)
		  (error 'my-key-assoc "short keyword list" lst))
	      (if (pair? lst)
		  (loop (car lst) (cdr lst))
		  default)))
       default))

(define (argument-name a)
   (if (pair? a) (car a) a))

(define (join mortar list)
   "(join 'mo '(a b c)) => '(a mo b mo c)"
   (let loop ((list list)
	      (hum-woodle '()))
      (if (pair? list)
	  (loop (cdr list)
		(if (pair? (cdr list))
		    (cons mortar
			  (cons (car list) hum-woodle))
		    (cons (car list) hum-woodle)))
	  (reverse! hum-woodle))))

(define (->string . objs)
   "Just like mkstr except it should never return :ufo:."
   (cond
      ((null? objs) "")
      ((valid-php-type? (car objs)) (mkstr (car objs) (apply ->string (cdr objs))))
      ((symbol? (car objs))
       (mkstr (symbol->string (car objs)) (apply ->string (cdr objs))))
      ((char? (car objs))
       (mkstr (make-string 1 (car objs)) (apply ->string (cdr objs))))
      ((number? (car objs))
       (mkstr (number->string (car objs)) (apply ->string (cdr objs))))
      (else (error '->string "no obvious string represenation for" (car objs)))))

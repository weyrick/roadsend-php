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
(module php-gtk-macros
   (load (php-macros "../../../php-macros.scm"))
   (include "../../php-runtime.sch"))


(define *debugging-gtk-macros?* (getenv "GTK_DEBUG"))

(define (dprint . rest)
   (when *debugging-gtk-macros?*
      (apply fprint (current-error-port) rest)))

; (define-macro (begin0 first . rest)
;    (let ((val (gensym 'val)))
;       `(let ((,val ,first))
; 	  ,@rest
; 	  ,val)))
;;;
;;; Macros
;;; ======

(define-macro (defclass klass . properties)
   (let* ((classname (if (list? klass)
			 (car klass)
			 klass))
	  (parent (if (list? klass)
		      (cadr klass)
		      '()))
	  (declare-property (lambda (prop)
			       (if (list? prop)
				   `(define-php-property ',classname (mkstr ',(car prop)) ,(cadr prop))
				   `(define-php-property ',classname (mkstr ',prop) '())))))
      `(add-startup-function-for-extension "gtk2"
	(lambda ()
	   (define-extended-php-class ',classname ',parent #f #f (lambda (a) a))
	   ,@(map declare-property properties)))))

(define-macro (def-ext-class klass get set copy) ;. properties)
   (let* ((classname (if (list? klass)
			 (car klass)
			 klass))
	  (parent (if (list? klass)
		      (cadr klass)
		      '())))
; 	  (declare-property (lambda (prop)
; 			       (if (list? prop)
; 				   `(define-php-property ',classname (mkstr ',(car prop)) ,(cadr prop))
; 				   `(define-php-property ',classname (mkstr ,prop) '())))))
      `(add-startup-function-for-extension "gtk2"
	(lambda ()
	   (define-extended-php-class ',classname ',parent
	      ,get ,set ,copy)))))

; (define-macro (def-gtk-constructor studly-class)
;    (let ((c-constructor (symbol-append (studly-to-underscores studly-class)
; 				       '_new)))
;       `(defmethod ,studly-class (,studly-class)
; 	  (let ((wrapped-obj (,c-constructor)))
; 	     (if (pragma::bool "!$1" wrapped-obj)
; 		 (begin
; 		    (php-warning "Could not create " ,(symbol->string studly-class) " object.")
; 		    +constructor-failed+)
; 		 (gtk-object-init! $this wrapped-obj))))))

(define-macro (defmethod klass (method-name . args) . body)
   (set! body (add-function-name-to-warnings (symbol-append klass '-> method-name) body))
   `(add-startup-function-for-extension "gtk2"
     (lambda ()
	(define-php-method ',klass (mkstr ',method-name)
	   (lambda ($this ,@args)
	      (bind-exit (return)
		 (debug-trace 3 "DEBUG: " ',klass "->" ',method-name " called.")
		 (set! $this (maybe-unbox $this))
                 (maybe-box
                  (cond
                     ((php-object? $this) ,@body)
                     (else (php-warning ',klass "->" ',method-name "() is not a static method."))))))))))

(define-macro (def-static-method klass (method-name . args) . body)
   (set! body (add-function-name-to-warnings (symbol-append klass ':: method-name) body))
   `(add-startup-function-for-extension "gtk2"
     (lambda ()
	(define-php-method ',klass (mkstr ',method-name)
	   (lambda ($this ,@args)
              (maybe-box
               (bind-exit (return)
                  (debug-trace 3 "DEBUG: " ',klass "::" ',method-name " called.")
                  ,@body)))))))

(define-macro (defmethod-XXX klass (method-name . args) . body)
   `(add-startup-function-for-extension "gtk2"
     (lambda ()
	(define-php-method ',klass (mkstr ',method-name)
	   (lambda ignore-args
              (maybe-box
               (begin
                  (debug-trace 3 "DEBUG: " ',klass "->" ',method-name " called.")
                  (php-warning ',klass "->" ',method-name " not implemented!")
                  ,@body)))))))

(define-macro (define-enum name . body)
   `(define-flags ,name ,@body))

(define-macro (define-flags name . body)
   (let* ((values (cdr (assoc 'values body)))
          (php-class (cadr (assoc 'in-module body)))
          (strip-prefix (string-append (string-upcase php-class) "_")))
      `(begin
          ,@(map (lambda (value)
                    (let* ((name (cadr (cadr value)))
                           (stripped-name
                            (if (substring=? strip-prefix name (string-length strip-prefix))
                                (substring name
                                           (string-length strip-prefix)
                                           (string-length name))
                                name)))
                       `(define-class-constant ',(string->symbol php-class) ,stripped-name
                           (convert-to-integer (pragma::long ,name)))))
                 values))))



; (define (gtk-type->scheme-type type)
;    (key-assoc type '(int int
; 		     string string
; 		     string-array string*)
; 	      (string->symbol
; 	       (pregexp-replace* "_" (symbol->string type) "-"))))

; (define +scheme->c-casts+ '(int mkfixnum
; 			    string mkstr
; 			    string-array php-hash->string*))

; (define +scheme->php-casts+ '(int convert-to-integer
; 			      string-array string*->php-hash
; 			      gtk-style (lambda (a) (gtk-wrapper-new 'gtkstyle a))))

(define (argument-name a)
   (if (pair? a) (car a) a))



			    
			    
(define (studly-to-underscores str)
   (set! str (symbol->string str))
   (string->symbol
    (with-output-to-string
       (lambda ()
	  (let ((first-char? #t)
		(prev-was-caps? #t))
	     (let loop ((chars (string->list str)))
		(unless (null? chars)
		   (let ((char (car chars)))
		      (if first-char?
			  (begin (set! first-char? #f)
				 (display (char-downcase char))
				 (loop (cdr chars)))
			  (begin (if (char-upper-case? char)
				     (if prev-was-caps?
					 (display (char-downcase char))
					 (begin (set! prev-was-caps? #t)
						(display* #\_ (char-downcase char))))
				     (begin (set! prev-was-caps? #f)
					    (display char)))
				 (loop (cdr chars))))))))))))

(define (dashes-to-underscores str)
   (set! str (symbol->string str))
   (string->symbol
    (pregexp-replace* "-" str "_")))

(define (underscores-to-dashes str)
   (set! str (symbol->string str))
   (string->symbol
    (pregexp-replace* "_" str "-")))

(define (studly-to-dashes str)
   (symbol-append str '*))
;   (string->symbol (pregexp-replace "\*$" (symbol->string (underscores-to-dashes (studly-to-underscores str))) "")))

(define (any-to-studly str)
   (set! str (symbol->string str))
   (string->symbol
    (apply string-append (map string-capitalize (pregexp-split "(-|_)+" (string-downcase str))))))


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

(define (make-pragma::pair fname::bstring return-type args)
   (let ((nargs (length args)))
      (cons*
       (if return-type
	   (symbol-append 'pragma:: return-type)
	   'pragma)
       (with-output-to-string
	  (lambda ()
             (let ((needs-delim? #f))
                (display* fname #\()
                (do ((i 1 (+fx i 1)))
                    ((>fx i nargs))
                    (if needs-delim?
                        (display ", ")
                        (set! needs-delim? #t))
                    (when (out-param? (list-ref args (- i 1)))
                       (display #\&))
                    (display* #\$ i))
                (display* #\)))))
       (map argument-name args))))

(define *defs-files* '("defs/gdk.defs" "defs/gtk.defs" "defs/gtk-types.defs"
                         "defs/gdk-types.defs" "defs/libglade.defs"))
(define (do-defs filenames proc)
   (let ((forms  '()))
      (for-each (lambda (filename)
		   (with-input-from-file filename
		      (lambda ()
			 (let loop ((s (read)))
			    (unless (eof-object? s)
			       (set! forms (cons s forms))
			       (loop (read)))))))
		filenames)
      (set! forms (reverse! forms))
      (for-each proc forms)))

(define gdk-functions '())

; (define c->scheme-db '())
; (define (c->scheme type)
;    (let ((scheme-type (assoc type c->scheme-db)))
;       (if scheme-type
; 	  (cadr scheme-type)
; 	  (begin
; 	     (print "what is the scheme equivalent of this type: " type "?")
; 	     (set! scheme-type (read))
; 	     (set! c->scheme-db (cons (list type scheme-type) c->scheme-db))
; 	     scheme-type))))

; (define cast-to-php-db '())
; (define (cast-scheme-to-php type form)
;    (if (not type)
;        form
;        (begin
; 	  (let ((cast-form
; 		 (let ((cast-to-php (assoc type cast-to-php-db)))
; 		    (if cast-to-php
; 			(begin
; 			   (print "here, " cast-to-php)
; 			   (cadr cast-to-php))
; 			(begin
; 			   (print 'there)
; 			   (print "what's the butlast of the form to cast this to from scheme php: " type "?")
; 			   (set! cast-to-php (read))
; 			   (set! cast-to-php-db (cons (list type cast-to-php) cast-to-php-db))
; 			   cast-to-php)))))
; 	     (if (null? cast-form) form (append cast-form form))))))



; (define (generate-struct s)
;    (print 'struct (cadr s)))




;;from gtk type to php type
;;$arg = new None_Arg()
(define gtk->php-db
   '(
     (null none)
     (none none)

     ;;$arg = new String_Arg()
     (char* string)
     (gchar* string)
     (const-char* string)
     (const-gchar* string)
     (string string)
     (static_string string)
     (unsigned-char* string)
     (guchar* string)
     (const-guchar* string)

     ;;string-array
     (gchar** string-array)
     
     ;;$arg = new Char_Arg()
     (char char)
     (gchar char)
     (guchar char)
     
     ;;$arg = new Int_Arg()
     (int int)
     (gint int)
     (guint int)
     (short int)
     (gshort int)
     (gushort int)
     (long int)
     (glong int)
     (gulong int)
     
     (guint8 int)
     (gint8 int)
     (guint16 int)
     (gint16 int)
     (guint32 int)
     (gint32 int)
     (GtkType int)
     
     ;;$arg = new Bool_Arg()
     (gboolean bool)
     
     ;;$arg = new Double_Arg()
     (double double)
     (gdouble double)
     (float double)
     (gfloat double)
     
     ;;$arg = new Atom_Arg()
     (GdkAtom gdkatom)
     
     ;;$arg = new Drawable_Arg()
     (GdkDrawable* drawable)
     
     ;;boxed
     (GdkEvent* boxed GdkEvent)
     (GdkWindow* boxed GdkWindow)
     (GdkPixmap* boxed GdkPixmap)
     (GdkBitmap* boxed GdkBitmap)
     (GdkColor* boxed GdkColor)
     (GdkColormap* boxed GdkColormap)
     (GdkCursor* boxed GdkCursor)
     (GdkVisual* boxed GdkVisual)
     (GdkFont* boxed GdkFont)
     (GdkGC* boxed GdkGC)
     (GdkDragContext* boxed GdkDragContext)
     (GtkSelectionData* boxed GtkSelectionData)
     (GtkCTreeNode* boxed GtkCTreeNode)
     (GtkAccelGroup* boxed GtkAccelGroup)
     (GtkStyle* boxed GtkStyle)


     
;     (GdkWindow* boxed GdkWindow)
;     (GdkWindow boxed GdkWindow)

;      ;otherwise the lookup for $this won't work... gotta think about a nicer solution
     (GdkEvent boxed GdkEvent)
     (GdkWindow boxed GdkWindow) 
     (GdkPixmap boxed GdkPixmap)
     (GdkBitmap boxed GdkBitmap)
     (GdkColor boxed GdkColor)
     (GdkColormap boxed GdkColormap)
     (GdkCursor boxed GdkCursor*)
     (GdkVisual boxed GdkVisual)
     (GdkFont boxed GdkFont)
     (GdkGC boxed GdkGC)
     (GdkDragContext boxed GdkDragContext)
     (GtkSelectionData boxed GtkSelectionData)
     (GtkCTreeNode boxed GtkCTreeNode)
     (GtkAccelGroup boxed GtkAccelGroup)
     (GtkStyle boxed GtkStyle)

     (const-GdkEvent* boxed GdkEvent)
     (const-GdkWindow* boxed GdkWindow)
     (const-GdkPixmap* boxed GdkPixmap)
     (const-GdkBitmap* boxed GdkBitmap)
     (const-GdkColor* boxed GdkColor)
     (const-GdkColormap* boxed GdkColormap)
     (const-GdkCursor* boxed GdkCursor)
     (const-GdkVisual* boxed GdkVisual)
     (const-GdkFont* boxed GdkFont)
     (const-GdkGC* boxed GdkGC)
     (const-GdkDragContext* boxed GdkDragContext)
     (const-GtkSelectionData* boxed GtkSelectionData)
     (const-GtkCTreeNode* boxed GtkCTreeNode)
     (const-GtkAccelGroup* boxed GtkAccelGroup)
     (const-GtkStyle* boxed GtkStyle)
     ))

(define (param-cast-form type name rest)
   (let ((default (key-assoc :default rest #f))
	 (null-ok (key-assoc :null-ok rest #f))
	 (var-list (key-assoc :var-list rest '()))
	 (parse-list (key-assoc :parse-list rest '()))
	 (arg-list (key-assoc :arg-list rest '()))
	 (extra-pre-code (key-assoc :extra-pre-code rest #f))
	 (extra-post-code (key-assoc :extra-post-code rest #f)))
      (match-case (assoc type gtk->php-db)
	 ((?- int) `(,(symbol-append name '::int) (mkfixnum ,name)))
	 ((?- string) `(,(symbol-append name '::string) (mkstr ,name)))
	 ((?- string-array) `(,(symbol-append name '::string*) (php-hash->string* ,name)))
	 ((?- bool) `(,(symbol-append name '::bool) (convert-to-boolean ,name)))
	 ((?- double) `(,(symbol-append name '::double) (onum->float (convert-to-float ,name))))
	 ((?- gdkatom) `(,(symbol-append name '::GdkAtom) (php-gdk-atom-get ,name)))
	 ((?- struct ?canon-type)
	  (dprint type "is a struct.")
	  `(,(symbol-append name ':: (studly-to-dashes canon-type))
	    ,(if null-ok
		 `(if (php-null? (maybe-unbox ,name))
		      (,(symbol-append 'pragma ':: (studly-to-dashes canon-type)) "NULL")
		      (gtk-boxed-alloc ',canon-type ,name))
		 `(gtk-boxed-alloc ',canon-type ,name))))
	 ((?- boxed ?canon-type)
	  ;(dprint type "is boxed.")
	  `(,(symbol-append name ':: (studly-to-dashes canon-type))
	    ,(if #t;null-ok
		 `(if (php-null? (maybe-unbox ,name))
		      (,(symbol-append 'pragma ':: (studly-to-dashes canon-type)) "NULL")
		      (gtk-object/safe ',canon-type ,name return))
; 		      (if (php-object-is-a (maybe-unbox ,name) ',canon-type)
; 			  (gtk-object ,name)
; 			  (begin
; 			     (php-warning "expected a " ',canon-type " or NULL, but got " ,name)
; 			     (return 0))))
		 `(gtk-object/safe ',canon-type ,name return))))
; 		 `(if (php-object-is-a (maybe-unbox ,name) ',canon-type)
; 		      (gtk-object ,name)
; 		      (begin
; 			 (php-warning "expected a " ',canon-type ", but got " ,name)
; 			 (return 0))))))
	 ((?- object ?canon-type)
	  `(,(symbol-append name ':: (studly-to-dashes canon-type))
	    ,(if #t;null-ok
		 `(if (php-null? (maybe-unbox ,name))
		      (,(symbol-append 'pragma ':: (studly-to-dashes canon-type)) "NULL")
		      ,(gtk-testing-cast canon-type `(gtk-object/safe ',canon-type ,name return)))
; 		      (if (php-object-is-a (maybe-unbox ,name) ',canon-type)
; 			  ,(gtk-testing-cast canon-type `(gtk-object ,name))
; 			  (begin
; 			     (php-warning "expected a " ',canon-type " or NULL, but got " ,name)
; 			     (return 0))))
		 (gtk-testing-cast canon-type `(gtk-object/safe ',canon-type ,name return)))))
; 		 `(if (php-object-is-a (maybe-unbox ,name) ',canon-type)
; 		      ,(gtk-testing-cast canon-type `(gtk-object ,name))
; 		      (begin
; 			 (php-warning "expected a " ',canon-type ", but got " ,name)
; 			 (return 0))))))
	 ((?- drawable)
	  `(,(symbol-append name '::GdkDrawable*)
	    (let ((,name (maybe-unbox ,name)))
	       (cond
		  ((php-object-is-a ,name 'GdkWindow)
		   (let ((o::GdkWindow* (gtk-object ,name)))
		      (pragma::GdkDrawable* "(GdkDrawable*)$1" o)))
		  ((php-object-is-a ,name 'GdkPixmap)
		   (let ((o::GdkPixmap* (gtk-object ,name)))
		      (pragma::GdkDrawable* "(GdkDrawable*)$1" o)))
		  ((php-object-is-a ,name 'GdkBitmap)
		   (let ((o::GdkBitmap* (gtk-object ,name)))
		      (pragma::GdkDrawable* "(GdkDrawable*)$1" o)))
		  (else
		   (debug-trace 3 "drawable is " ,name)
		   (php-warning "drawable must ba a GdkWindow, GdkPixmap, or GdkBitmap")
		   (pragma::GdkDrawable* "NULL"))))))

	 ((?type flags) `(,(symbol-append name '::int) (gtk-flag-value ',type ,name)))
	 ((?type enum) `(,(symbol-append name '::int) (gtk-enum-value ',type ,name)))
 	 (?- (error 'param-cast-form "yutz" (cons* type name rest))))))

(define (pragma-form return-type fname args . rest)
   (let ((fname (symbol->string fname))
	 (var-list (key-assoc :var-list rest '()))
	 (separate (key-assoc :parse-list rest #f)))
      (match-case (assoc return-type gtk->php-db)
	 ((?- none) `(begin ,(make-pragma fname #f args) NULL))
	 ((?- int) `(convert-to-integer ,(make-pragma fname 'int args)))
	 ((?- string) `(mkstr ,(make-pragma fname 'string args)))
	 ((?- string-array) `(string*->php-hash ,(make-pragma fname 'string* args)))
	 ((?- bool) `(convert-to-boolean ,(make-pragma fname 'bool args)))
	 ((?- double) `(convert-to-float ,(make-pragma fname 'double args)))
	 ((?- boxed ?canon-type)
	  `(gtk-wrapper-new ',canon-type ,(make-pragma fname (studly-to-dashes canon-type) args)))
	 ((?- object ?canon-type)
	  `(gtk-object-wrapper-new ',canon-type ,(make-pragma fname (studly-to-dashes canon-type) args)))
	 ((?- flags) `(convert-to-integer ,(make-pragma fname 'int args)))
	 ((?- enum) `(convert-to-integer ,(make-pragma fname 'int args)))
	 (?- (error 'pragma-form "patz" (cons* return-type fname args rest))))))




(define (register-types)
   (do-defs *defs-files*
	    (match-lambda
	       ((define-object ?type ??- (c-name ?c-type) . ?-)
                (set! c-type (string->symbol c-type))
		(unless (assoc c-type gtk->php-db)
		   (set! gtk->php-db
			 (cons (list c-type 'object c-type) gtk->php-db))
		   (set! gtk->php-db
			 (cons (list (symbol-append c-type '*) 'object c-type) gtk->php-db))))
;; 	       ((struct ?type ??- (c-name ?c-type) . ?-)
;; ;		(print "registering struct type " c-type)
;; 		(unless (assoc c-type gtk->php-db)
;; 		   (set! gtk->php-db
;; 			 (cons (list c-type 'struct c-type) gtk->php-db))
;; 		   (set! gtk->php-db
;; 			 (cons (list (symbol-append c-type '*) 'struct c-type) gtk->php-db))
;; 		   (set! gtk->php-db
;; 			 (cons (list (symbol-append 'const- c-type '*) 'struct c-type) gtk->php-db))))
	       ((define-enum ?type ??- (c-name ?c-type) . ?-)
                (set! c-type (string->symbol c-type))
		(unless (assoc c-type gtk->php-db)
		   (set! gtk->php-db
			 (cons (list c-type 'enum) gtk->php-db))))
	       ((define-flags ?type ??- (c-name ?c-type) . ?-)
                (set! c-type (string->symbol c-type))
		(unless (assoc c-type gtk->php-db)
		   (set! gtk->php-db
			 (cons (list c-type 'flags) gtk->php-db))))
	       )))
;	       (?a (print (car a))))))

(define *types-registered?* #f)



(define (required-parameters args)
   (filter symbol?
	   (map (lambda (a) (if (eqv? 'foot (key-assoc :default a 'foot)) (argument-name a) '()))
		args)))

(define (optional-parameters args)
   (filter pair?
	   (map (lambda (a) (if (eqv? 'foot (key-assoc :default a 'foot)) '() `(,(argument-name a)
									     ,(key-assoc :default a #f))))
		args)))

(define (filter-not thunk list)
   (filter (lambda (a) (not (thunk a))) list))

(define (allocate-out-param p)
   (match-case p
      ((?name :gtk-type (or gint* guint*
                            ;; GdkModifierType is a flag type
                            GdkModifierType*))
       `(,(symbol-append name '::int) 0))
      (else (error 'allocate-out-param "unknown param type" p))))

(define (out-param? p)
   (match-case p
      ((??- (or gint* guint* GdkModifierType*)) #t)
      (else #f)))

(define-macro (def-pgtk-methods klass gtk_class . methods)
   (unless *types-registered?* (register-types))
   (define (generate-one-method method)
      (unless (pair? method)
         (error 'def-pgtk-methods "ill-formed method declaration" method))
      (let* ((args (cons `($this :gtk-type ,klass) (cdr method)))
             (in-params (filter-not out-param? args))
             (out-params (filter out-param? args))
             (method-name (argument-name (car method)))
             (return-type (key-assoc :return-type (car method) 'none))
             (in-param-names (map argument-name in-params))
             (out-param-names (map argument-name out-params))
             ;(parameter-names (map argument-name args))
             (required-parameters (required-parameters (cdr in-params)))
             (optional-parameters (optional-parameters in-params))
             (in-param-types (map (lambda (a) (key-assoc :gtk-type a #f)) in-params)))
         `(defmethod ,klass (,method-name ,@required-parameters
                                          ,@(if (pair? optional-parameters) 
                                                `(#!optional ,@optional-parameters)
                                                '()))
             (let (,@(map param-cast-form
                          in-param-types in-param-names in-params)
                   ,@(map allocate-out-param out-params))
                ,@(if (eqv? method-name 'add)
                      `((debug-trace 3 "about to call " ',method-name
                                     " with args : " ,@in-param-names))
                      '())
                ,(pragma-form return-type
                              (key-assoc :c-name (car method)
                                         (symbol-append gtk_class '_ method-name))
                              args)
                ,@(if (null? out-params)
                      '()
                      `((vector->php-hash (vector ,@out-param-names))))))))
   `(begin
       ,@(map (lambda (method)
		 (try (generate-one-method method)
		      (lambda (e p m o)
			 (dprint "oops: " p m o ", method " method)
			 (e '(begin #t)))))
	      methods)))

(define-macro (def-static-methods klass gtk_class . methods)
   (unless *types-registered?* (register-types))
   `(begin
       ,@(map (lambda (method)
		 (try (begin
			 (unless (pair? method)
			    (error 'def-static-methods "ill-formed method declaration" method))
			 (let* ((args (cdr method))
				(method-name (argument-name (car method)))
				(return-type (key-assoc :return-type (car method) 'none))
				(parameter-names (map argument-name args))
				(required-parameters (required-parameters args))
				(optional-parameters (optional-parameters args))
				(parameter-types (map (lambda (a) (key-assoc :gtk-type a #f)) args)))
			    `(def-static-method ,klass (,method-name ,@required-parameters
							     ,@(if (pair? optional-parameters) 
								   `(#!optional ,@optional-parameters)
								   '()))
				(let ,(map param-cast-form parameter-types parameter-names args)
				   ,(pragma-form return-type (key-assoc :c-name (car method) (symbol-append gtk_class '_ method-name))
						 parameter-names)))))
		      (lambda (e p m o)
			 (dprint "oops: " p m o ", static method: " method)
			 (e '(begin #t)))))
	      methods)))

(define-macro (def-property-getter (name obj prop ref? k) studly-class . properties)
   (unless *types-registered?* (register-types))
   `(define (,name ,obj ,prop ,ref? ,k)
       (let ((wrapped-obj (gtk-object ,obj)))
	  (if (not (and (foreign? wrapped-obj) (not (foreign-null? wrapped-obj))))
	      (begin
		 (debug-trace 3 "warning, no gtkobj for `this' in property getter " ',name " (got: " ,obj)
		 NULL)
	      (let ((,prop (string->symbol (mkstr ,prop)))
		    (,(symbol-append 'this:: (studly-to-dashes studly-class))
		     ,(gtk-testing-cast studly-class `wrapped-obj)))
		 (case ,prop
		    ,@(map (lambda (prop)
			      (let ((impl (key-assoc :impl prop #f)))
				 `((,(car prop)) ,(if impl
						      impl
						      (try
						       (property-get-form (cadr prop) (car prop) studly-class)
						       (lambda (e p m o)
							  (dprint "couldn't produce property-get-form for " studly-class "->" prop ": " m ", " o)
							  (e #t)))))))
			   
			   properties)
		    (else (,k))))))))


(define (property-get-form return-type name studly-class)
;    (let ((name (symbol->string name))
; 	 (gtk-type-check (string-upcase (symbol->string (studly-to-underscores studly-class))))
; 	 )
   (let ((property-reader (symbol-append studly-class '* '- name)))
      (match-case (assoc return-type gtk->php-db)
	 ((?- none) (error 'property-get-form "'none' type makes no sense here" (cons studly-class name)))
	 ((?- int) ;`(convert-to-integer (pragma::int ,(string-append gtk-type-check "($1)->" name) this)))
	  `(convert-to-integer (,property-reader ,(gtk-testing-cast studly-class 'this))))
	 ((?- gdkatom) `(php-gdk-atom-new (,property-reader this)))
	 ((?- string) ;`(mkstr (pragma::string ,(string-append gtk-type-check "($1)->" name) this)))
	  `(mkstr (,property-reader ,(gtk-testing-cast studly-class 'this))))
	 ((?- bool) ;`(convert-to-boolean (pragma::bool ,(string-append gtk-type-check "($1)->" name) this)))
	  `(convert-to-boolean (,property-reader ,(gtk-testing-cast studly-class 'this))))
	 ((?- double) ; `(convert-to-float (pragma::double ,(string-append gtk-type-check "($1)->" name) this)))
	  `(convert-to-float (,property-reader ,(gtk-testing-cast studly-class 'this))))
	 ((?- boxed ?canon-type)
; 	  `(gtk-wrapper-new ',canon-type (,(symbol-append 'pragma:: (studly-to-dashes canon-type))
; 					  ,(string-append gtk-type-check "($1)->" name) this)))
	  `(gtk-wrapper-new ',canon-type (,property-reader ,(gtk-testing-cast canon-type 'this))))
	 ((?- object ?canon-type)
; 	  `(gtk-object-wrapper-new #f  (,(symbol-append 'pragma:: (studly-to-dashes canon-type))
; 					,(string-append gtk-type-check "($1)->" name) this)))
	  `(gtk-object-wrapper-new #f (,property-reader this)));,(gtk-testing-cast studly-class 'this))))


;  	 ((?- flags) ;`(convert-to-integer (pragma::int ,(string-append gtk-type-check "($1)->" name) this)))
; 	  `(convert-to-integer (pragma::int ,(string-append "$1->" (symbol->string name)) this)))
 	 ((?- enum) ;`(convert-to-integer (pragma::int ,(string-append gtk-type-check "($1)->" name) this)))
	  `(convert-to-integer (pragma::int ,(string-append "$1->" (symbol->string name)) this)))
	 (?- (error 'pragma-form "snook" (list return-type name studly-to-dashes))))))

; (define (transform-gdk-function s)
;    (let* ((name (cadr s))
; 	  (body (cddr s))
; 	  (c-name (cadr (assoc 'c-name body)))
; 	  (return-type (cadr (assoc 'return-type body)));(let ((r (cadr (assoc 'return-type body)))) (if (eqv? r 'none) #f r)))
; 	  (parameters (map cdadr (filter (lambda (a) (and (pair? a) (eqv? (car a) 'parameter)))
; 					 body)))
; 	  (parameter-name (lambda (a) (cadr a)))
; 	  (parameter-names (map parameter-name parameters))
; 	  (parameter-type (lambda (a) (car a)))
; 	  (parameter-types (map parameter-type parameters)))
;       (try
;        `(defmethod gdk (,name ,@parameter-names)
; 	   (let ,(map param-cast-form parameter-types parameter-names)
; 	      ,(pragma-form return-type c-name parameter-names)))
;        (lambda (e p m o)
; 	  (print "oops: " p m o)
; 	  (e `(begin ',(cadr s)))))))

(define (symbol-upcase sym)
   (string->symbol (string-upcase (symbol->string sym))))

(define (gtk-testing-cast gtk-studly-type form)
   (case gtk-studly-type
;      ((GtkWidget) `(GTK_WIDGET ,form))
;      ((GtkObject) `(GTK_OBJECT ,form))

;      ((GdkWindow) `(pragma::GdkWindow* "$1" ,form))
;      ((GdkCursor) `(pragma::GdkCursor* "$1" ,form))
      ((GtkSelectionData) form)
      ((GdkWindow) form)
      ((GdkCursor) form)
      ((GtkBoxChild) form)
      ((GtkStyle) form)
      (else `(,(symbol-upcase (studly-to-underscores gtk-studly-type)) ,form))))


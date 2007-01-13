(module generate
   (main main))


;;; XXX I added null-ok by hand! make sure this generates it next time
;;; around.  --tpd 2005.4.12

;;; XXXXXX although... it looks like it's not used by php-gtk anyway
;;; --tpd 2005.5.2

;;;
;;; globals
;;; =======

(define *classes* (make-hashtable))
(define *filename* #f)

;;;
;;; main
;;; ====

(define (main args)
   (unless (= (length args) 2)
      (error "main" "expected one argument" args))
   (set! *filename* (cadr args))
   (generate-gdk-functions))



(define (generate-custom-properties)
   (let ((classes '()))
      
      (for-each-list *filename*
		     (lambda (x)
			(when (eqv? (car x) 'object)
			   (set! classes (cons x classes)))))
      (set! classes (reverse! classes))
      
      (for-each (lambda (class)
		   (unless (null? (class-properties class))
		      (print "(def-property-getter (" (underscores-to-dashes (studly-to-underscores (symbol->string (class-cname class)))) "-custom-lookup obj prop ref? k) " (class-cname class))
		      (for-each (lambda (prop)
				   (print (tab) "(" (property-name prop) " " (property-type prop) ")"))
				(class-properties class))
		      (display* (tab) ")" #\newline #\newline)))
		classes)))


(define (generate-gtk-functions)
   ;;the static methods of the gtk class
   (let ((classname 'Gtk)
	 (gtk-functions '()))
      (for-each-list *filename*
		     (lambda (a)
			(when (and (pair? a) (eqv? (car a) 'define-function))
			   (set! gtk-functions (cons a gtk-functions)))))
      (set! gtk-functions (reverse! gtk-functions))

      (print "(def-static-methods " classname " " (studly-to-underscores (symbol->string classname)))
      (for-each (lambda (function)
		   (let ((str-name (symbol->string (function-cname function))))
		      (unless (or (pregexp-match "_new" str-name)
				  (pregexp-match "_get_type" str-name))
			 (display* (tab) "(")
			 (let ((function-options '()))
			    (when (function-requires-special-c-name? classname function) 
			       (set! function-options
				     (cons* :c-name (function-special-c-name function)
					    function-options)))
			    (when (not (eqv? 'none (function-return-type function)))
			       (set! function-options
				     (cons* :return-type (function-return-type function)
					    function-options)))
			    (if (null? function-options)
				(display (function-php-name function))
				(display (cons (function-php-name function) function-options))))
			 (for-each-parameter function
					     (lambda (param)
						(display* #\space
							  `(,(parameter-name param)
							    :gtk-type
							    ,(parameter-type param)
							    ,@(if (parameter-optional? param)
								  `(:default ,(parameter-default param))
								  '())))))
			 (display* ")" #\newline))))
		gtk-functions)
      (display* (tab) ")" #\newline #\newline)))

(define (generate-gdk-functions)
   ;;the static methods of the gdk class
   (let ((classname 'Gdk)
	 (gdk-functions '()))
      (for-each-list *filename*
		     (lambda (a)
			(when (and (pair? a) (eqv? (car a) 'define-function))
			   (set! gdk-functions (cons a gdk-functions)))))
      (set! gdk-functions (reverse! gdk-functions))
      
      (print "(def-static-methods " classname " " (studly-to-underscores (symbol->string classname)))
      (for-each (lambda (function)
		   (display* (tab) "(")
		   (let ((function-options '()))
		      (when (function-requires-special-c-name? classname function) 
			 (set! function-options
			       (cons* :c-name (function-special-c-name function)
				      function-options)))
		      (when (not (eqv? 'none (function-return-type function)))
			 (set! function-options
			       (cons* :return-type (function-return-type function)
				      function-options)))
		      (if (null? function-options)
			  (display (function-php-name function))
			  (display (cons (function-php-name function) function-options))))
		   (for-each-parameter function
				       (lambda (param)
					  (display* #\space
						    `(,(parameter-name param)
						      :gtk-type
						      ,(parameter-type param)
						      ,@(if (parameter-optional? param)
							    `(:default ,(parameter-default param))
							    '())))))
		   (display* ")" #\newline))
		gdk-functions)
      (display* (tab) ")" #\newline #\newline)))

(define (generate-gtk-methods)
   (populate-classes)
   (for-each-class (lambda (classname methods)
		      ;		      (when (some? (lambda (a) (some? parameter-optional? (method-parameters a))) methods)
		      (print "(def-pgtk-methods " classname " " (studly-to-underscores (symbol->string classname)))
		      
		      (for-each (lambda (method)
				   (display* (tab) "(")
				   (let ((method-options '()))
				      (when (method-requires-special-c-name? classname method) 
					 (set! method-options
					       (cons* :c-name (method-special-c-name method)
						      method-options)))
				      (when (not (eqv? 'none (method-return-type method)))
					 (set! method-options
					       (cons* :return-type (method-return-type method)
						      method-options)))
				      (if (null? method-options)
					  (display (method-php-name method))
					  (display (cons (method-php-name method) method-options))))
				   (for-each-parameter method
						       (lambda (param)
							  (display* #\space
								    `(,(parameter-name param)
								      :gtk-type
								      ,(parameter-type param)
								      ,@(if (parameter-optional? param)
									    `(:default ,(parameter-default param))
									    '())))))
				   (display* ")" #\newline))
				methods)
		      (display* (tab) ")" #\newline #\newline))))

(define (populate-classes)
   (for-each-list *filename*
		  (lambda (x)
		     (when (eqv? (car x) 'define-method)
			(add-method x)))))


;;;
;;; random utility functions
;;; ========================

(define (some? pred lst)
   (bind-exit (return)
      (for-each (lambda (a)
		   (when (pred a) (return #t)))
		lst)
      #f))

(define (symbol-downcase sym)
   (string->symbol (string-downcase (symbol->string sym))))

(define (dashes-to-underscores str)
   (pregexp-replace* "-" str "_"))

(define (underscores-to-dashes str)
   (pregexp-replace* "_" str "-"))

(define (any-to-studly str)
   (apply string-append (map string-capitalize (pregexp-split "(-|_)+" (string-downcase str)))))

(define (studly-to-underscores str)
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
				(loop (cdr chars)))))))))))

			      
(define (for-each-sexpr-if filename test thunk)
   (with-input-from-file filename
      (lambda ()
	 (let loop ((sexpr (read)))
	    (unless (eof-object? sexpr)
	       (when (test sexpr)
		  (thunk sexpr))
	       (loop (read)))))))

(define (for-each-sexpr filename thunk)
   (for-each-sexpr-if filename (lambda (s) #t) thunk))

(define (for-each-list filename thunk)
   (for-each-sexpr-if filename list? thunk))

(define (tab #!optional (times 1) (tab-length 3))
   (make-string (* times tab-length) #\space))

;;;
;;; Properties
;;; ==========

(define (property-name prop)
   (list-ref (list-ref prop 1) 2))

(define (property-type prop)
   (list-ref (list-ref prop 1) 1))

;;;
;;; CLASSes
;;; =======

(define (class-properties class)
   (filter (lambda (a) (and (pair? a) (eqv? (car a) 'field)))
	   class))

(define (class-name class)
   (list-ref class 1))

(define (class-cname class)
   (cadr (assoc 'c-name (cddr class))))

(define (class-methods classname)
   (or (get-class classname)
       '()))

(define (get-class classname)
   (hashtable-get *classes* classname))

(define (add-class classname)
   (when (not (get-class classname))
      (hashtable-put! *classes* classname '())))

(define (for-each-class thunk)
   (hashtable-for-each *classes* thunk))
    
;;;
;;; METHODs
;;; =======

(define (method-php-name method)
   (list-ref method 1))

(define (method-class method)
   (string->symbol (cadr (assoc 'of-object (cddr method))))
   ;; (symbol-append (car (list-ref (list-ref method 2) 2))
;; 		  (list-ref (list-ref method 2) 1))
   )

(define (method-cname method)
   ;(string->symbol (list-ref (list-ref method 3) 1))
   (string->symbol (cadr (assoc 'c-name (cddr method)))))

(define (method-return-type method)
   ;(string->symbol (list-ref (list-ref method 4) 1)))
   (string->symbol (cadr (or (assoc 'return-type (cddr method))
                             '(foo "none")))))

(define (method-parameters method)
   (filter (lambda (x)
	      (and (pair? x)
		   (eqv? 'parameter (car x))))
	   (list-tail method 5)))

(define (add-method method)
;   (print "adding method " method)
   (let ((classname (method-class method)))
      (add-class classname) ; ensure class has been added
      (hashtable-put! *classes* classname (cons method (hashtable-get *classes* classname)))))

(define (for-each-method classname thunk)
   (for-each thunk (class-methods classname)))

(define (method-requires-special-c-name? classname method)
   (not
    (string=? (string-append (studly-to-underscores (symbol->string classname))
			     "_"
			     (symbol->string (method-php-name method)))
	      (symbol->string (method-cname method)))))

(define (method-special-c-name method)
   (method-cname method))
;;;
;;; FUNCTIONs
;;; =======

(define (function-php-name function)
   (list-ref function 1))

(define (function-cname function)
   (list-ref (list-ref function 2) 1))

(define (function-return-type function)
   (list-ref (list-ref function 3) 1))

(define (function-parameters function)
   (let ((parameters (assoc 'parameters (cddr function))))
      (if parameters
          (cdr parameters)
          '())))

;    (filter (lambda (x)
; 	      (and (pair? x)
; 		   (eqv? 'parameter (car x))))
; 	   function)   )
;	   (list-tail function 4)))

(define (function-requires-special-c-name? classname function)
   ;; if the C name is not the same as the class name . _ . the scheme
   ;; name, then the function will require an explicit C name.
   (not
    (string=? (string-append (studly-to-underscores (symbol->string classname))
			     "_"
			     (symbol->string (function-php-name function)))
              (function-cname function))))

(define (function-special-c-name function)
   (function-cname function))


;;;
;;; PARAMETERs
;;; ==========

(define (parameter-name param)
   (list-ref (cadr param) 1))

(define (parameter-type param)
   (list-ref (cadr param) 0))

(define (for-each-parameter method thunk)
   (for-each thunk
	     (if (eqv? (car method) 'method)
		 (method-parameters method)
		 (function-parameters method))))

(define (parameter-optional? param)
   (assoc 'default (cdr param)))

(define (parameter-default param)
   (cadr (assoc 'default (cdr param))))

;; generated the flags and enums just by copying them, like this:
;; (for-each-list "gtk-types.defs"
;;    (lambda (s)
;;      (match-case s ((define-enum  ??-) (pp s) (newline))
;;                    ((define-flags  ??-) (pp s) (newline)))))

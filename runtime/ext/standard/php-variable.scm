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

(module php-variable-lib
   (include "../phpoo-extension.sch")
   (library profiler)
   (export
    ;doubleval (alias of floatval)
    (floatval var)
    (empty var)
    (gettype var)
    ;(get_defined_vars) ;won't work without happy cheese
    (get_resource_type resource)
    (intval var)
    (is_array var)
    (is_bool var)
    (is_float var)
    ;(is_double var) (alias of is_float)
    (is_int var)
    ;is_integer (alias of is_int)
    ;is_long (alias of is_int)
    (is_null var)
    (is_numeric var)
    (is_object var)
    ;is_real (alias of is_float)
    (is_resource var)
    (is_scalar var)
    (is_string var)
;    (isset . vars)
    (print_r var)
    (serialize var)
    (settype var type)
    (strval var)
    (unserialize var)
    ;unset  (unset is not a function)
    (var_dump . vars)
    (var_export var return-result)
    ;(is_callable var syntax_only callable_name)
    (init-php-variable-lib)))

(define (init-php-variable-lib)
   1)


; floatval -- Get float value of a variable
(defbuiltin (floatval var)
   (string->number (mkstr var)))

; doubleval -- Alias of floatval()
(defalias doubleval floatval)

; empty -- Determine whether a variable is set
(defbuiltin (empty var)
   (cond ((null? var) #t)
	 ((boolean? var) (not var))
	 ((string? var) (or (string=? var "") (string=? var "0")))
	 ((php-number? var) (php-= var 0))
	 ((php-hash? var) (= (php-hash-size var) 0)) 
	 (else FALSE)))

; gettype -- Get the type of a variable
(defbuiltin (gettype var)
   (get-php-datatype var))

; get_defined_vars --  Returns an array of all defined variables
;(defbuiltin (get_defined_vars)
;   (error 'get_defined_vars "This function is not yet implemented." 'none))

; get_resource_type --  Returns the resource type
(defbuiltin (get_resource_type var)
   (if (php-resource? var)
       (struct-ref var 0)
       (php-warning "Not a valid resource handle: " var)))

; intval -- Get integer value of a variable
(defbuiltin (intval var)
   (convert-to-integer var))

; is_array -- Finds whether a variable is an array
(defbuiltin (is_array var)
   (php-hash? var))

; is_bool --  Finds out whether a variable is a boolean
(defbuiltin (is_bool var)
   (boolean? var))


; is_float -- Finds whether a variable is a float
(defbuiltin (is_float var)
   (and (php-number? var) (onum-float? var)))
;   (flonum? var))

; is_double -- Alias of is_double()
(defalias is_double is_float)

; is_int -- Find whether a variable is an integer
(defbuiltin (is_int var)
   (and (php-number? var) (onum-long? var)))
;   (or (fixnum? var) (elong? var)))

;this is #t even for 0.0
;   (integer? var))
   
; is_integer -- Alias of is_int()
(defalias is_integer is_int)

; is_long -- Alias of is_int()
(defalias is_long is_int)

; is_null --  Finds whether a variable is NULL
(defbuiltin (is_null var)
   (null? var))

; is_numeric --  Finds whether a variable is a number or a numeric string
(defbuiltin (is_numeric var)
;    (print "is numberic " var " we get " (or (php-number? var)
; 					    (numeric-string? var)) )
   (or (php-number? var)
       (numeric-string? var)))

   
; is_object -- Finds whether a variable is an object
(defbuiltin (is_object var)
   (php-object? var))


; is_real -- Alias of is_float()
(defalias is_real is_float)

; is_resource --  Finds whether a variable is a resource
(defbuiltin (is_resource var)
   (php-resource? var))

; is_scalar --  Finds whether a variable is a scalar
(defbuiltin (is_scalar var)
   (or (php-number? var)
       (string? var)
       (boolean? var)))

; is_string -- Finds whether a variable is a string
(defbuiltin (is_string var)
   (string? var))

; serialize --  Generates a storable representation of a value
(defbuiltin (serialize var)
   (let ((refhash (make-grasstable))
	 (varcount 0))
      (letrec ((fork-it   (lambda (v ref? key?)
			     ; handle refs
			     (let ((ref-loc (grasstable-get refhash v)))
				(if (and ref-loc ref?)					 
				    (format "R:~a;" ref-loc)
				    (begin
				       ; increase var count unless array key
				       (unless key?
					  (set! varcount (+ varcount 1)))
				       (if ref?
					  (grasstable-put! refhash v varcount))
				       (cond
					  ((is_bool v) (do-bool v))
					  ((is_int v) (do-int v))
					  ((is_float v) (do-float v))
					  ((is_string v) (do-string v))
					  ((is_array v) (do-array v))
					  ((is_object v) (do-object v))
					  ((is_null v) (do-null v))
					  (else
					   ;(php-warning "serialize: unknown type for " v)
					   "i:0;")))))))
	       (do-int    (lambda (v)
			     ;(fprint (current-error-port) "i'm an int")
			     (format "i:~a;" (onum->string v 0))))
	       (do-float  (lambda (v)
			     ;(fprint (current-error-port) "i'm a float")
			     (format "d:~a;" (onum->string v 46))))
	       (do-array  (lambda (v)
			     ;(fprint (current-error-port) "i'm an array")
			     (with-output-to-string
				(lambda ()
				   (display (format "a:~a:{" (php-hash-size v)))
				   (php-hash-for-each-with-ref-status v
								      (lambda (ak av r?)
									 ;(fprint (current-error-port) "doing " ak " => " av)
									 (display (fork-it ak #f #t))
									 (display (fork-it av r? #f))))
				   (display "}")))))
	       (do-object (lambda (v)
			     ;(fprint (current-error-port) "i'm an object")
			     (let ((propshash (php-object-props v))
				   (classtype (php-object-class v)))
				; sleep?			
				(let ((ser-vars (maybe-unbox (if (php-class-method-exists? (php-object-class v) "__sleep")
						    (call-php-method v "__sleep")
						    'all))))
				   (format "O:~a:\"~a\":~a"
					   (string-length classtype)
					   classtype
					   (with-output-to-string
					      (lambda ()
						 (display (format "~a:{" (if (eqv? ser-vars 'all)
									     (php-hash-size propshash)
									     (php-hash-size ser-vars))))
						 (php-hash-for-each-with-ref-status
						  propshash
						  (lambda (ak av r?)
						     (when (or (eqv? ser-vars 'all)
							     (php-hash-in-array? ser-vars ak #f))
							(display (fork-it ak #f #t))
							(display (fork-it av r? #f)))))
						 (display "}")))
					   )))))
	       (do-string (lambda (v)
			     ;(fprint (current-error-port) "i'm a string")
			     (format "s:~a:\"~a\";" (string-length v) v)))
	       (do-null   (lambda (v)
			     ;(fprint (current-error-port) "i'm a null")
			     "N;"))
	       (do-bool   (lambda (v)
			     ;(fprint (current-error-port) "i'm a bool")
			     (if v "b:1;" "b:0;"))))
	 (fork-it var #f #f))))

; unserialize --  Creates a PHP value from a stored representation
(defbuiltin (unserialize var)
   (multiple-value-bind (value end-offset)
      (do-unserialize var)
      ; just care about the value here
      value))

; returns value unserialized and offset in string we stopped at
(define (do-unserialize var)
   (bind-exit (return)
      (let ((offset 0)
	    (varcopy (mkstr var))	     
            (varcount 0)
            (hash-stack '())
            (key-stack '())
            ; this is different from rechash in serializer because we don't know
            ; ahead of time which variables we might need to refer to to make into references
            ; so we have to track them all and change them on the fly
            (varvec (make-grasstable))
            (refvec (make-grasstable)) ; this one stores active references
            )
         (letrec ((uncerealize (lambda (key?)
                                  (set! offset (+ offset 1))
                                  (unless key?
                                     (set! varcount (+ varcount 1)))
                                  (let ((uval (ecase (read-char)
                                                 ;reference
                                                 ((#\R) (set! key? #t) ; we don't want to store the ref in varvec
                                                        (set! varcount (- varcount 1)) ; also don't increase this
                                                        (read-and-test #\:)
                                                        (let* ((idx (string->integer (read-up-to #\;)))
                                                               (p-ref (grasstable-get refvec idx)) ; check for previous 
                                                               (hpair (grasstable-get varvec idx)))
                                                           (unless hpair
                                                              (php-warning "serialized reference doesn't exist at " idx)
                                                              (bomb))
                                                           
                                                           ;(print "R idx is " idx)
                                                           ;(grasstable-for-each varvec
                                                           ;		      (lambda (k v)
                                                           ;		 (print k " => " (mkstr (cdr v)))))
                                                           
                                                           ; if we have already made this idx a reference, use it here,
                                                           ; otherwise create a new one
                                                           (if p-ref
                                                               p-ref
                                                               ; need to turn this value into a reference
                                                               (let* ((rhash (car hpair))
                                                                      (rkey (cdr hpair))
                                                                      (new-ref (make-container (php-hash-lookup rhash rkey))))
                                                                  ;(print "found my pair with key " (mkstr rkey))
                                                                  ; replace it in hash
                                                                  (php-hash-insert! rhash rkey new-ref)
                                                                  ; save in case we use it again
                                                                  (grasstable-put! refvec idx new-ref)
                                                                  ; return as current unserialized value here
                                                                  new-ref))))
                                                 ;null
                                                 ((#\N) (read-and-test #\;) NULL)
                                                 ;bool
                                                 ((#\b) (read-and-test #\:)
                                                        (string-case (read-up-to #\;)
                                                           ("1" TRUE)
                                                           ("0" FALSE)
                                                           (else (bomb))))
                                                 ;int
                                                 ((#\i) (read-and-test #\:) (string->onum/long (read-up-to #\;)))
                                                 ;double
                                                 ((#\d) (read-and-test #\:) (string->onum/float (read-up-to #\;)))
                                                 ;string
                                                 ((#\s) (read-and-test #\:)
                                                        (let ((len (string->integer (read-up-to #\:))))
                                                           (read-and-test #\")
                                                           (let ((str (read-counted len)))
                                                              (read-and-test #\")
                                                              (read-and-test #\;)
                                                              str)))
                                                 ;array
                                                 ((#\a) (read-and-test #\:)
                                                        (let ((size (string->integer (read-up-to #\:))))
                                                           (read-and-test #\{)
                                                           (let ((the-array (make-php-hash)))
                                                              (when (> (length hash-stack) 0)
                                                                 ; if we've got a hash stack already,
                                                                 ; we'll add array to varvec by hand in case
                                                                 ; we come across a reference to ourself
                                                                 ;(print "adding in array varvec at count " varcount)
                                                                 (grasstable-put! varvec
                                                                                  varcount
                                                                                  (cons (car hash-stack)
                                                                                        (car key-stack)))
                                                                 ; for this iteration, key should be true so we don't dupe later
                                                                 (set! key? #t))
                                                              (set! hash-stack (cons the-array hash-stack))
                                                              (dotimes (i size)
                                                                 ; we assume here the key would never be an array or object 
                                                                 (set! key-stack (cons (uncerealize #t) key-stack))
                                                                 (php-hash-insert! the-array (car key-stack) (uncerealize #f))
                                                                 (set! key-stack (cdr key-stack)))
                                                              (set! hash-stack (cdr hash-stack))
                                                              (read-and-test #\})
                                                              the-array)))
                                                 ; object
                                                 ((#\O) (read-and-test #\:)
                                                        (let ((classname-len (string->integer (read-up-to #\:))))
                                                           (read-and-test #\")
                                                           (let ((classname (read-counted classname-len)))
                                                              (read-and-test #\")
                                                              (read-and-test #\:)
                                                              ; if class doesn't exist, might as well bomb (fatal)
                                                              (unless (php-class-exists? classname)
                                                                 (php-warning "cannot unserialize bo undefined class: " classname)
                                                                 (bomb))
                                                              ; properties
                                                              (let ((class-props (php-class-props classname))
                                                                    (size (string->integer (read-up-to #\:))))
                                                                 (read-and-test #\{)
                                                                 (let ((props (make-php-hash)))
                                                                    ; (dotimes (i size)
                                                                    ; 						     (let ((k (uncerealize #t))
                                                                    ; 							   (v (uncerealize #f)))
                                                                    ; 							(print "jjj, i is: " i)
                                                                    ; 							(php-hash-insert! props k v )))
                                                                    (let loop  ((i 0))
                                                                       (when (< i size)
                                                                          (let* ((k (uncerealize #t))
                                                                                 (v (uncerealize #f)))
                                                                             (php-hash-insert! props k v ))
                                                                          (loop (+ i 1))))
                                                                    (read-and-test #\})
                                                                    ; construct new object
                                                                    (let ((new-obj (construct-php-object-sans-constructor classname)))
                                                                       ; if there are less properties in this object than there are
                                                                       ; for the class, we have to overwrite one by one
                                                                       ; because they used __sleep
                                                                       ; otherwise we can overwrite the whole thing
                                                                       
                                                                       ; copy properties from unserialized val
                                                                       (php-hash-for-each props
                                                                          (lambda (k v)
                                                                             (php-object-property-set! new-obj k v 'all)))
                                                                       ; call __wakeup
                                                                       (if (php-class-method-exists? classname "__wakeup")
                                                                           (call-php-method new-obj "__wakeup"))
                                                                       ; return new object
                                                                       new-obj))))))						  
                                                 ; oops!
                                                 (else (bomb)))))
                                     ; add to var hash
                                     ;(fprint (current-error-port) "putting " uval " at index " (grasstable-size varvec))
                                     (when (and (not key?)
                                                (> (length hash-stack) 0)) ; it's 0 when it's cataloging itself
                                        ; store which hash, and what key this value comes from				   
                                        ;(print "adding in varvec at count " varcount)
                                        (grasstable-put! varvec
                                                         varcount
                                                         (cons (car hash-stack)
                                                               (car key-stack))))
                                     (values uval offset))))
                  (bomb (lambda ()
                           (php-notice "corrupt serialized data at offset "
                                       offset ": "
                                       (substring varcopy (- offset 1) (string-length varcopy)))
                           (return FALSE)))
                  (read-and-test (lambda (c)
                                    (set! offset (+ offset 1))
                                    (unless (char=? (read-char) c) (bomb))))
                  (read-counted
                   (lambda (count)
                      (let loop ((count count)
                                 (chars '()))		   
                         (if (> count 0)
                             (begin
                                (set! offset (+ offset 1)) 
                                (loop (- count 1) (cons (read-char) chars)))
                             (list->string (reverse chars))))))
                  (read-up-to
                   (lambda (end)
                      (let loop ((chars '())
                                 (c (read-char)))
                         (set! offset (+ offset 1)) 
                         (if (char=? c end)
                             (list->string (reverse chars))
                             (loop (cons c chars) (read-char)))))))
            
            (with-input-from-string varcopy
               (lambda ()
                  (uncerealize #f)))))))

			 
; settype -- Set the type of a variable
(defbuiltin (settype (ref . var) type)
   (let ((act 
	  (cond
	     ((or (string-ci=? type "boolean")
		  (string-ci=? type "bool"))   convert-to-boolean)
	     ((or (string-ci=? type "integer")
		  (string-ci=? type "int"))    convert-to-integer)
	     ((or (string-ci=? type "double")
		  (string-ci=? type "float"))  convert-to-float)
	     ((string-ci=? type "string")      mkstr)
	     ((string-ci=? type "array")       convert-to-hash)
	     ((string-ci=? type "object")      convert-to-object)
	     ((string-ci=? type "null")        'make-null)
	     (else 'unknown))))
      (cond ((eqv? act 'make-null) (begin (container-value-set! var NULL) #t))
	    ((eqv? act 'unknown) (begin
				    (php-warning "invalid type " type)
				    #f))
	    (else
	     (begin
		(container-value-set! var (act var))
		#t)))))


; strval -- Get string value of a variable
(defbuiltin (strval var)
   (if (is_scalar var)
       (mkstr var)
       (begin
	  (unless (eq? NULL var)
	     (php-warning "You cannot use strval on non-scalar values: " var))
	  "")))


;; visit, leave, and skip are used to prevent infinite recursion in
;; var_dump and print_r

(define (visit seen val)
   (let ((state (grasstable-get seen val)))
      (if state
	  (if (eqv? state 'skip)
	      (error 'visit "too many visits!" (cons seen val))
	      (grasstable-put! seen val 'skip))
	  (grasstable-put! seen val #t))))

(define (leave seen val)
   (let ((state (grasstable-get seen val)))
      (if state
	  (if (eqv? state 'skip)
	      (grasstable-put! seen val #t)
	      (grasstable-remove! seen val))
	  (error 'leave "can't leave what you don't visit" (cons seen val)))))

(define (skip? seen val)
   (eqv? 'skip (grasstable-get seen val)))

; var_dump -- Dumps information about a variable
(defbuiltin-v (var_dump vars)
   (letrec ((dump-hash-entries
	     ;dump a php-hash to a string and return that and it's cardinality
	     (lambda (hash seen indent)
		(let ((cardinality 0)
		      (entries ""))
		   (php-hash-for-each-with-ref-status
		    hash
		    (lambda (key val ref?)
		       (set! cardinality (+ cardinality 1))
		       (set! entries 
			     (mkstr entries  "  " indent
				    "[" (if (string? key)
					    (mkstr "\"" key "\"")
					    key)
				    "]=>\n" 
				    (recursive-var-dump val seen (mkstr "  " indent) ref?))))) ;))
		   (values entries cardinality))))
	    (dump-object-entries
	     ;dump a php-object to a string and return that and it's cardinality
	     (lambda (hash seen indent)
		(let ((cardinality 0)
		      (entries ""))
		   (php-object-for-each-with-ref-status
		    hash
		    (lambda (key val ref?)
		       (set! cardinality (+ cardinality 1))
		       (set! entries 
			     (mkstr entries  "  " indent
				    "[" (if (string? key)
					    (mkstr "\"" key "\"")
					    key)
				    "]=>\n" 
				    (recursive-var-dump val seen (mkstr "  " indent) ref?)))))
		   (values entries cardinality))))
	    (recursive-var-dump 
	     (lambda (var seen indent ref?)
		(if (skip? seen var)
		    (mkstr indent "*RECURSION*\n")
		    (let ((rtag (if ref? "&" ""))) 
		       (cond
			  ((is_null var) (mkstr indent rtag "NULL\n"))
			  ((is_bool var) (mkstr indent rtag "bool("
						(if var "true" "false")
						")\n"))
			  ((is_int var) (mkstr indent rtag "int(" var ")\n"))
			  ((is_float var) 
                           (mkstr indent rtag "float(" (onum->string/g-vardump var *float-precision*) ")\n"))
			  ((is_string var) (mkstr indent rtag "string("
						  (string-length var) ") \"" var "\"\n"))
			  ((is_array var)
			   (visit seen var)
			   (multiple-value-bind (entries cardinality)
			      (dump-hash-entries var seen indent)
			      (leave seen var)
			      (mkstr indent rtag "array(" cardinality ") {\n" entries indent "}\n")))
			  ((is_object var)
			   (visit seen var) ;)
			   (multiple-value-bind (entries cardinality)
			      (dump-object-entries var seen indent)
			      (leave seen var) 
			      (mkstr indent rtag "object(" (php-object-class var) ")"
				     (mkstr "#" (php-object-id var) " ") "("
				     cardinality ") {\n" entries indent "}\n")));)
			  ((is_resource var) (mkstr indent rtag "resource(" (resource-id var)
                                                    ") of type (" (resource-description var) ")\n"))
;                          ((foreign? var)
;                           (recursive-var-dump (zval->phpval-coercion-routine var) seen indent ref?))
			  (else (echo (mkstr "var is of unknown type :" var ":")))))))))
      (for-each (lambda (v)
		   (if (container? v)
		       (fprint (current-error-port) "it was a container"))
		   ;   		   (when (php-object? v)
		   ;   		      (set! v (copy-php-data v)))
		   (echo (recursive-var-dump v (make-grasstable) "" #f)))
		vars))
   NULL)


; var_export -- Outputs or returns a string representation of avariable
(defbuiltin (var_export var (return-result #f))
   (letrec ((dump-hash-entries
	     ;dump a php-hash to a string and return that
	     (lambda (hash seen indent)
		(let ((entries ""))
		   (php-hash-for-each-with-ref-status
		    hash
		    (lambda (key val ref?)
		       (set! entries 
			     (mkstr entries  "  " indent
				    (if (string? key)
					(mkstr "'" key "'")
					key)
				    " => " 
				    (recursive-var-export val seen (mkstr "  " indent) ref? #t)))))
		   entries)))
	    (dump-object-entries
	     ;dump a php-object to a string and return that
	     (lambda (hash seen indent)
		(let ((entries ""))
		   (php-object-for-each-with-ref-status
		    hash
		    (lambda (key val ref?)
		       ; demangle if necessary
		       (when (string-index key #\:)
			  (set! key (car (string-split key ":"))))
		       (set! entries 
			     (mkstr entries  "   " indent
				    (if (string? key)
					(mkstr "'" key "'")
					key)
				    " => "
				    (recursive-var-export val seen (mkstr "  " indent) ref? #t)))))
		   entries)))
	    (recursive-var-export
	     (lambda (var seen indent ref? array-entry?)
		(if (skip? seen var)
		    (mkstr indent "*RECURSION*\n")
		    (let ((rtag (if ref? "&" ""))
			  (line-end (if array-entry? ",\n" (if (string=? indent "") "" "\n")))
			  (indent (if (or (not array-entry?)
					  (and array-entry?
					       (is_array var)))
				      indent)))
		       (cond
			  ((is_null var) (mkstr indent rtag "NULL" line-end))
			  ((is_bool var) (mkstr indent rtag (if var "true" "false") line-end))
			  ((is_int var) (mkstr indent rtag var line-end))
			  ((is_float var) 
                           (mkstr indent rtag (onum->string/g-vardump var *float-precision*) line-end))
			  ((is_string var) (mkstr indent rtag "'" (string-subst var "'" "\\'") "'" line-end))
			  ((is_array var)
			   (visit seen var)
			   (let ((entries (dump-hash-entries var seen indent)))
			      (leave seen var)
			      (mkstr (if array-entry? "\n" "") indent rtag "array (\n" entries indent ")" line-end)))
			  ((is_object var)
			   (visit seen var) ;)
			   (let ((entries (dump-object-entries var seen indent)))
			      (leave seen var) 
			      (mkstr (if array-entry? "\n" "") indent rtag (php-object-class var) "::__set_state(array(\n" entries indent "))" line-end)))
			  (else (mkstr ""))))))))
      (let ((ret (recursive-var-export var (make-grasstable) "" #f #f)))
	 (if return-result
	     ret
	     (begin
		(echo ret)
		NULL)))))
	     
; is_callable --  Find out whether the argument is a valid callable construct
;(defbuiltin (is_callable var syntax_only callable_name)
;   (error 'is_callable "This function is not yet implemented." var))



; isset -- Determine whether a variable is set
; XXX this is now a language construct

;only true if they're all set
; (defbuiltin-v (isset vars)
;    (if (pair? vars)
;        (let loop ((a (car vars))
; 		  (vars (cdr vars)))
; 	  (if (null? a)
; 	      #f
; 	      (if (pair? vars)
; 		  (loop (car vars) (cdr vars))
; 		  #t)))
;        #f))


; print_r --  Prints human-readable information about an array
(defbuiltin (print_r var)
   (if (not (or (php-hash? var)
		(php-object? var)))
       (echo var)
       (letrec ((recursive-print
		 (lambda (var seen indent)
		    (cond
		       ((php-hash? var)
			(visit seen var)
			(echo "Array\n")
			(if (skip? seen var)
			    (begin
			       (echo " *RECURSION*"))
			    (begin
			       (print-hash-innards var seen indent) ))
			(leave seen var))
		       ((php-object? var)
			(visit seen var)
			(if (skip? seen var)
			    (begin
			       (echo (php-object-class var))
			       (echo " Object\n")			       
			       (echo " *RECURSION*"))
			    (begin
			       (echo (php-object-class var))
			       (echo " Object\n")
			       (print-hash-innards (php-object-props var) seen indent)
			       ))
			(leave seen var))
		       (else (echo var)))))
		(print-hash-innards
		 (lambda (var seen indent)
		    (echo indent)
		    (echo "(\n")
		    (php-hash-for-each var
		       (lambda (key val)
			  (echo indent)
			  (echo "    [")
			  (echo key)
			  (echo "] => ")
			  (recursive-print val seen (string-append "        " indent))
			  (echo "\n") ))
		    (echo indent)
		    (echo ")\n"))))
	  
	  
	  (if (php-object? var) (set! var (copy-php-data var)))
	  (recursive-print var (make-grasstable) ""))))


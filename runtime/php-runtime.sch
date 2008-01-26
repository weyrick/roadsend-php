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

(define-struct env
   bindings)

; stack traces

; XXX this is responsible for a lot of inline code in
; /every file/ that uses php-runtime. :(
(define-struct stack-entry
   file
   line
   function
   args
   class-name
   class-type)

(define-macro (pushf val stack)   
   `(set! ,stack (cons ,val ,stack)))

(define-macro (popf stack)
   `(if (eq? ,stack '())
       '()
       (let ((retval (car ,stack)))
	  (set! ,stack (cdr ,stack))
	  retval)))

;introduce a temporary binding of a global variable
(define-macro (dynamically-bind (var val) . body)
   (let ((saved-name (gensym 'saved)))
      `(let ((,saved-name ,var))
	  (unwind-protect
	     (begin
		(set! ,var ,val)
		,@body)
	     (set! ,var ,saved-name)))))

(define-macro (fluid-let binding-forms . body)
   (let* ((saved-names (map gensym
			    (map car
				 binding-forms))))
      `(let ,(map (lambda (s b)
		     `(,s ,(car b)))
		  saved-names
		  binding-forms)
	  (unwind-protect
	     (begin
		,@(map (lambda (b)
			  `(set! ,@b))
		       binding-forms)
		,@body)
	     ,@(map (lambda (s b)
		       `(set! ,(car b) ,s))
		    saved-names
		    binding-forms)))))



(define-macro (ecase var . forms)
   `(case ,var
       ,@forms
       ,@(let ((possibilities (map car forms)))
	    (if (member 'else possibilities)
		'()
		`((else (error 'ecase ,(format "not a member of any of ~a" possibilities) ,var)))))))


;try my own because the above is unhygenic
(define-macro (dolist (el lst) . body)
   (let ((lst-name (gensym 'lst))
	 (loop-name (gensym 'loop)))
      `(let ,loop-name ((,lst-name ,lst))
	    (unless (null? ,lst-name)
	       (let ((,el (car ,lst-name)))
		  ,@body)
	       (,loop-name (cdr ,lst-name))))))

;; the list and the index
(define-macro (enumerate (el index lst) . body)
   (let ((lst-name (gensym 'lst))
	 (loop-name (gensym 'loop)))
      `(let ,loop-name ((,lst-name ,lst)
                        (,index 0))
	    (unless (null? ,lst-name)
	       (let ((,el (car ,lst-name)))
		  ,@body)
	       (,loop-name (cdr ,lst-name) (+fx ,index 1))))))

;this is also unhygenic
(define-macro dotimes
  (lambda (args . body)
    `(do ((,(car args) 0 (+ 1 ,(car args)))
	  (iteration-limit ,(cadr args)))
	 ((>= ,(car args) iteration-limit))
	 ,@body)))


;;;;time stuff
(define-macro (time-to . prog)
   `(let ((t1 (make-timeval*))
	  (t2 (make-timeval*))
	  (tz (pragma::timezone* "((struct timezone*)NULL)")))
       (c-gettimeofday t1 tz)
       ,@prog
       (c-gettimeofday t2 tz)
       (+ (- (elong->flonum (timeval*-sec t2))
	     (elong->flonum (timeval*-sec t1)))
	  (/ (- (elong->flonum (timeval*-usec t2))
		(elong->flonum (timeval*-usec t1)))
	     1000000.0))))

;; binary files
(define-macro (with-output-to-binary-file (of tmpname) . body)
   `(let ((,of '()))
       (unwind-protect
	  (begin
	     (set! ,of (open-output-binary-file ,tmpname))
	     ,@body)
	  (when (binary-port? ,of) (close-binary-port ,of)))))

(define-macro (begin0 first . rest)
   (let ((val (gensym 'val)))
      `(let ((,val ,first))
	  ,@rest
	  ,val)))

(define-macro (with-unique-names variables . forms)
  `(let (,@(map (lambda (v) (list v `(gensym ,(symbol->string v)))) variables))
    ,@forms))

(define-macro (awhen test . rest)
   `(let ((it ,test))
       (when it
          ,@rest)))

(define-macro (aif test consequent ernf)
   `(let ((it ,test))
       (if it
           ,consequent
           ,ernf)))

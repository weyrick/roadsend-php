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
(module output-buffering
   (import
    (utils "utils.scm")
    (php-runtime "php-runtime.scm")
    (php-hash "php-hash.scm")
    (url-rewriter "url-rewriter.scm")
    (php-object "php-object.scm")    
    (php-errors "php-errors.scm")
    (signatures "signatures.scm")    
    (php-ini "php-ini.scm"))
   (load (php-macros "../php-macros.scm"))   
   (export
    PHP_OUTPUT_HANDLER_START 
    PHP_OUTPUT_HANDLER_CONT 
    PHP_OUTPUT_HANDLER_END
    *output-buffer-implicit-flush?*
    *output-buffer-stack*
    *output-callback-stack*
    *output-rewrite-vars*
    (maybe-init-url-rewriter)
    (ob-reset!)
    (ob-start callback)
    (ob-pop-stacks)
    (ob-verify-stacks)
    (ob-flush-to-next from to callback)
    (ob-flush)
    (ob-flush-all)
    (ob-rewrite-urls output)))

(define *output-buffer-implicit-flush?* #f)

(defconstant PHP_OUTPUT_HANDLER_START 1)
(defconstant PHP_OUTPUT_HANDLER_CONT  (bit-lsh 1 1))
(defconstant PHP_OUTPUT_HANDLER_END   (bit-lsh 1 2))

;the top of this stack is the current output buffer, if the stack is
;empty output is unbuffered
(define *output-buffer-stack* '())

; this should mirror the output-buffer-stack: always the same length.
; either there will be a string representing the function to call, or
; a nil.
(define *output-callback-stack* '())

; for url rewriter
(define *output-rewrite-vars* (make-hashtable))

; called each page view
(define (ob-reset!)
   (set! *output-buffer-stack* '())
   (set! *output-callback-stack* '())
   (unless (=fx (hashtable-size *output-rewrite-vars*) 0)
      (set! *output-rewrite-vars* (make-hashtable))))

(define (maybe-init-url-rewriter)
   (when (convert-to-boolean (get-ini-entry "session.use_trans_id"))
      ; defbuiltin is defined in ext/standard/php-output-control.scm
      (ob-start "_internal_url_rewriter")))

; rewrite urls for transparent session ids

(define (ob-build-get-vars)
   (let ((getvars ""))
      (hashtable-for-each *output-rewrite-vars*
	 (lambda (k v)
	    (set! getvars (mkstr getvars k "=" v "&"))))
      (substring getvars 0 (max 0 (- (string-length getvars) 1)))))

(define (ob-build-post-vars)
   (let ((postvars ""))
      (hashtable-for-each *output-rewrite-vars*
			  (lambda (k v)
			     (set! postvars (string-append postvars
							   (format "<input type=\"hidden\" name=\"~a\" value=\"~a\">~%" k v)))))
      postvars))

(define (ob-rewrite-urls output)
   (let ((getvars (ob-build-get-vars))
	 (postvars (ob-build-post-vars))
	 (tags-to-rewrite (get-ini-entry "url_rewriter.tags")))
      ; list of tags to replace comes from tags-to-rewrite which defaults to
      ; "a=href,area=href,frame=src,input=src,form=fakeentry" per php ini
      (let ((a? #f) (area? #f) (frame? #f) (input? #f) (form? #f))
	 (let ((rg (regular-grammar ()
		      ("a=href" (set! a? #t))
		      ("area=href" (set! area? #t))
		      ("frame=src" (set! frame? #t))
		      ("input=src" (set! input? #t))
		      ("form=fakeentry" (set! form? #t))
		      ("," 'woo!))))	    
	    (get-tokens-from-string rg tags-to-rewrite)
	    (debug-trace 4 "rewrite tags: a? " a? ", area? " area? ", frame? " frame?
			 ", input? " input? ", form? " form?))
	 (rewrite-urls output getvars postvars a? area? frame? input? form?))))

(define (ob-start callback)
   (ob-verify-stacks)
   (set! *output-buffer-stack*
	 (cons (open-output-string) *output-buffer-stack*))
   (set! *output-callback-stack*
	 (cons (if (eqv? callback 'unpassed)
		   #f
		   (if (php-hash? callback)
		       (cons (container-value
                              (php-hash-lookup-location callback #f 0))
			     (php-hash-lookup callback 1))
		       callback))
	       *output-callback-stack*)) )

(define (ob-pop-stacks)
   (ob-verify-stacks)
   (if (pair? *output-buffer-stack*)
       (begin
	  (set! *output-buffer-stack* (cdr *output-buffer-stack*))
	  (set! *output-callback-stack* (cdr *output-callback-stack*))
	  #t)
       #f))

(define (ob-verify-stacks)
   (unless (= (length *output-callback-stack*)
	      (length *output-buffer-stack*))
      (php-error
       "verify-stacks: output buffer stacks currupted. callbacks: "
       *output-callback-stack*
       ", buffers "
       *output-buffer-stack*)))

(define (ob-flush-to-next from to callback)
   "flush output from buffer from into buffer to, if to is #f, display
   the output"
   (let* ((len (length *output-buffer-stack*))
	  (output (close-output-port from))
	  ; XXX this isn't right yet see #1156
	  (mode (cond ((= len 1) PHP_OUTPUT_HANDLER_START)
		      ((eqv? to #f) PHP_OUTPUT_HANDLER_END)
		      (else PHP_OUTPUT_HANDLER_END))))
      (when callback
	 ; a pair means we call a method
	 (if (pair? callback)
	     (set! output (mkstr (call-php-method (car callback) (cdr callback) output)))
	     (let ((callback-sig (get-php-function-sig callback)))
	     (if callback-sig
		 (case (sig-length callback-sig)
		    ((1) (set! output (mkstr (php-funcall callback output))))
		    ((2) (set! output (mkstr (php-funcall callback output mode))))
		    (else (php-error "output buffering callback has invalid number of arguments")))
		 (php-error "output buffering callback undefined: " callback)))))
      (if to
	  (display output to)
	  (begin
	     (display output)
	     ))
      #t))


(define (ob-flush)
   (let ((len (length *output-buffer-stack*)))
      (cond 
	 ((= len 1) (ob-flush-to-next (car *output-buffer-stack*) #f
				      (car *output-callback-stack*)))
	 ((> len 1) (ob-flush-to-next (car *output-buffer-stack*)
				      (cadr *output-buffer-stack*)
				      (car *output-callback-stack*)))
	 (else #f))))

(define (ob-flush-all)
   (let loop ()
      (ob-flush)
      (if (ob-pop-stacks)
 	  (loop))))


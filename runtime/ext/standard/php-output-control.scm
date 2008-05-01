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

(module php-output-control-lib
   (include "../phpoo-extension.sch")
   (library profiler)
   ; exports
   (export
    (init-php-output-control-lib)
    (flush)
    (ob_start callback)
    (ob_get_contents)
    (ob_get_clean)
    (ob_get_length)
    (ob_get_level)
    (ob_get_status full-status)
    (ob_gzhandler buf mode)
    (ob_flush)
    (ob_clean)
    (ob_end_flush)
    (ob_end_clean)
    (output_reset_rewrite_vars)
    (output_add_rewrite_var name value)
    (_internal_url_rewriter output)
    (ob_implicit_flush flag)
    ))

(define (init-php-output-control-lib)
   1)


; flush any remaining output at end of script
; note this is useful for command line only
(register-exit-function!
 (lambda (status)
    (let loop ()
       (if (ob_end_flush)
	   (loop)))
    status))

; internal url rewriter
(defbuiltin (_internal_url_rewriter output)
   ; php-runtime
   (ob-rewrite-urls output))

(defbuiltin (output_reset_rewrite_vars)
   (set! *output-rewrite-vars* (make-hashtable)))

(defbuiltin (output_add_rewrite_var name value)
   (hashtable-put! *output-rewrite-vars* (mkstr name) (mkstr value)))

; flush -- Flush the output buffer
(defbuiltin (flush)
   (if (> (length *output-buffer-stack*) 0)
       (map ob-flush-to-next
	    *output-buffer-stack*
	    (append (cdr *output-buffer-stack*) '(#f))
	    *output-callback-stack*)
       (begin
	  (unless (output-string-port? (current-output-port))
	     (flush-output-port (current-output-port)))
	  #f)))

; ob_start -- Turn on output buffering
(defbuiltin (ob_start (callback 'unpassed))
   (ob-start callback))

; ob_get_contents --  Return the contents of the output buffer
(defbuiltin (ob_get_contents)
   (if (pair? *output-buffer-stack*)
       (get-output-string (car *output-buffer-stack*))
       #f))

; ob_get_clean --  Get current buffer contents and delete current output buffer
(defbuiltin (ob_get_clean)
   (let ((outp (ob_get_contents)))
      (if (not (eqv? outp #f))
	  (ob_end_clean))
      outp))

; ob_get_length --  Return the length of the output buffer
(defbuiltin (ob_get_length)
   (if (pair? *output-buffer-stack*)
       (string-length (get-output-string (car *output-buffer-stack*)))
       #f))

; ob_get_level --  Return the nesting level of the output buffering mechanism
(defbuiltin (ob_get_level)
   (length *output-buffer-stack*))

; returns status information on either the top level output buffer or all active output buffer levels if full_status  is set to TRUE.
(defbuiltin (ob_get_status (full-status? #f))
   (set! full-status? (convert-to-boolean full-status?))
   (if (pair? *output-buffer-stack*)
       (let ((stack (if full-status?
			*output-buffer-stack*
			(list (car *output-buffer-stack*))))
	     (rhash (make-php-hash))
	     (level 0))
	  (for-each (lambda (o)
		       (set! level (+fx level 1))
		       (let ((lhash (if full-status? (make-php-hash) rhash)))
			  (if full-status?
			      (begin
				 (php-hash-insert! lhash "chunk_size" *zero*) ; XXX ?
				 (php-hash-insert! lhash "size" (convert-to-number (string-length (get-output-string o))))
				 (php-hash-insert! lhash "block_size" #e10240) ; XXX ?
				 )
			      (php-hash-insert! lhash "level" (convert-to-number level)))
			  (php-hash-insert! lhash "type" *one*) ; XXX ?
			  (php-hash-insert! lhash "status" *zero*) ; XXX ?
			  (php-hash-insert! lhash "name" "default output handler") ; XXX ?
			  (php-hash-insert! lhash "del" TRUE) ; XXX ?
			  (when full-status?
			     (php-hash-insert! rhash :next lhash))))
		    stack)
	  rhash)
       ; no buffers
       (make-php-hash)))

; ob_gzhandler --  ob_start callback function to gzip output buffer
(defbuiltin (ob_gzhandler buf (mode 'unset))
   ; XXX needs to compress
   buf)
   
; ob_flush --  Flush (send) the output buffer
(defbuiltin (ob_flush)
   (ob-flush))

; ob_clean --  Clean (erase) the output buffer
(defbuiltin (ob_clean)
   (when (pair? *output-buffer-stack*)
      (flush-output-port (car *output-buffer-stack*))))
   
; ob_end_flush --  Flush (send) the output buffer and turn off output buffering
(defbuiltin (ob_end_flush)
   (ob-flush)
   (ob-pop-stacks))

; ob_end_clean --  Clean (erase) the output buffer and turn off output buffering
(defbuiltin (ob_end_clean)
   (ob_clean)
   ; needs to return false if there was no stack
   (ob-pop-stacks))

; ob_implicit_flush --  Turn implicit flush on/off
(defbuiltin (ob_implicit_flush (flag 'unpassed))
   (if (convert-to-boolean flag)
       (set! *output-buffer-implicit-flush?* #t)
       (set! *output-buffer-implicit-flush?* #f)))


   

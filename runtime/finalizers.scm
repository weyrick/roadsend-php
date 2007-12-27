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
(module finalizers
   (extern
    (export finalizer-callback "finalizer_callback")
    (macro gc_finalize_on_demand::int "GC_finalize_on_demand")
    )
   (export

    ;;don't call this function
    (finalizer-callback obj::obj context::procedure)

    ;;call this function to register a callback.  Only the last callback
    ;;registered for a particular object will be called.
    (register-finalizer! obj::obj callback::procedure)

    ;;call this function to attempt to force finalization of finalizable
    ;;objects.  It'll be called automatically upon exit.
    (gc-force-finalization enough?)))


(define *finalization-enabled?* #f)

(define *finalizers-left* 0)

(define (register-finalizer! obj::obj callback::procedure)
   "Register a finalizer for object obj. Callback should be a
   procedure of one argument, which will be obj when it is invoked."
   (unless *finalization-enabled?*
      (gc-enable-finalization)
      (set! *finalization-enabled?* #t)
      (register-exit-function!
       (lambda (status)
	  (gc-force-finalization (lambda () (> *finalizers-left* 0)))
	  status)))
   (set! *finalizers-left* (+ *finalizers-left* 1))
   (gc-register-finalizer
    obj
    (lambda (obj)
       (set! *finalizers-left* (- *finalizers-left* 1))
       (callback obj))))

(define (finalizer-callback obj::obj context::procedure)
   ;;The "context" is the user's callback,
   ;;obj is the object being finalized.
   (context obj))


(define (gc-register-finalizer obj::obj callback::procedure)
   ;;; Choose one of these three.  See gc.h for more information.

;     (pragma "GC_register_finalizer_ignore_self ($1, finalizer_callback, $2, NULL, NULL)"
;  	   obj callback)

;   (pragma "GC_register_finalizer_no_order ($1, finalizer_callback, $2, NULL, NULL)"
; 	   obj callback)

   ;; self-cycles won't get finalized, but it seems like this makes a
   ;; stronger guarantee that the object will still be in one piece
   ;; when the finalizer gets it.
   (pragma "GC_register_finalizer ($1, finalizer_callback, $2, NULL, NULL)"
	   obj callback)
   #t)

(define (gc-force-finalization enough?)
   ;; This will ensure, to the extent that we can, that all
   ;; finalizable objects get finalized, I hope.  The enough?
   ;; parameter should be a function that returns true if enough
   ;; finalizers have been run.  (lambda () #f) will always work, but
   ;; might do more work than it needs to.
   (pragma "GC_COLLECT();")
   (pragma "GC_invoke_finalizers();")
   (unless (enough?)
      (pragma "
{
  int i;
  while (GC_collect_a_little()) { }
  for (i = 0; i < 16; i++) {
    GC_gcollect();
    GC_invoke_finalizers();
  }
}  
"))
   #t)

(define (gc-enable-finalization)
   (pragma "BGL_IMPORT int GC_finalize_on_demand;")

   (pragma::void "GC_finalize_on_demand = 0")
   ;;we return this so that bigloo will keep the extern declaration
   ;;of GC_finalize_on_demand
   gc_finalize_on_demand)

(when (getenv "INCREMENTAL")
   (pragma "GC_enable_incremental()")
   #t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;this is all test code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(test)

; (define-struct foot
;    afoot
;    bfoot
;    number)


; (define *finalized-count* 0)
; (define *finalizable-count* 0)
; (define *total* 0)
; (define *total-should-be* 0)

; (define (allocate-some)
;    (let loop ((i 0))
;       (when (< i 500000)
; 	 (let ((afoot (make-foot i))
; 	       (bfoot (make-foot i)))
; 	    (gc-register-finalizer afoot
; 			     (lambda (a)
; 				(set! *finalized-count* (+ *finalized-count* 1))
; 				(set! *total* (+ *total* (foot-number a)))))
; 	    (gc-register-finalizer bfoot
; 			     (lambda (a)
; 				(set! *finalized-count* (+ *finalized-count* 1))
; 				(set! *total* (+ *total* (foot-number a)))))
; 	    (foot-afoot-set! afoot bfoot)
; 	    (foot-bfoot-set! bfoot afoot)
; 	    (foot-afoot-set! afoot bfoot)
; 	    (foot-bfoot-set! bfoot afoot)
; ; 	    (foot-afoot-set! afoot prev-foot)
; 	    (set! *finalizable-count*
; 		  (+ *finalizable-count* 2))
; 	    (set! *total-should-be*
; 		  (+ *total-should-be* i))
; 	    (set! *total-should-be*
; 		  (+ *total-should-be* i))
; 	    (loop (+ i 1))))))


; (define (test)
;    (print "the value of GC_finalize_on_demand is: "
; 	  gc_finalize_on_demand)
;    (gc-enable-finalization)
;    (print "now the value of GC_finalize_on_demand is: "
; 	  gc_finalize_on_demand)
;    (allocate-some)
;    (allocate-some)
;    (allocate-some)
;    (allocate-some)
;    (allocate-some)
;    (allocate-some)
;    (allocate-some)
;    (allocate-some)
;    (allocate-some)
;    (allocate-some)
;    (gc-force-finalization)
;    (print "finalized: " *finalized-count* ", of: " *finalizable-count*)
;    (print "totals: " *total* ", of: " *total-should-be*))






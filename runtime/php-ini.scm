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
(module php-ini
   (import
    (utils "utils.scm")
    (php-runtime "php-runtime.scm")
    (php-hash "php-hash.scm")
    (php-errors "php-errors.scm"))
   (export
    (set-ini-entry name value)
    (get-ini-entry name)
    (default-ini-entry name value)
    (config-ini-entry name value)
    (reset-ini!)
    (generate-config-ini-entries)
    (ini-file-parse fname::bstring parse-sections?::bool)))



;;;;ini file
(define *ini-table* (make-hashtable))
(define *default-ini-table* (make-hashtable))
(define *config-ini-table* (make-hashtable))

(define (reset-ini!)
   ;; reset ini settings to config file state
   (unless (or (=fx (hashtable-size *ini-table*) 0)
	       (=fx (hashtable-size *ini-table*) (hashtable-size *config-ini-table*)))
      (set! *ini-table* (make-hashtable))
      (hashtable-for-each *config-ini-table*
			  (lambda (k v)
			     (hashtable-put! *ini-table* k v)))))

; return current value, attemping a default if current doesn't exist
(define (get-ini-entry name)
   (let ((ival (hashtable-get *ini-table* (mkstr name))))
      (debug-trace 9 (format "(runtime) getting ~a which is ~a" name ival))
      (if ival
	  ival
	  (hashtable-get *default-ini-table* (mkstr name)))))      

; used by php land code and .htaccess to override
(define (set-ini-entry name value)
   (debug-trace 9 (format "(runtime) setting ~a to ~a" name value))
   (hashtable-put! *ini-table* (mkstr name) value)
   ; precision?
   (when (string=? (mkstr name) "precision")
      (set! *float-precision* (mkfixnum value))))

; used only by config file reader
; ini table will be reset to this after every page load
(define (config-ini-entry name value)
   (debug-trace 9 (format "(runtime) config setting ~a to ~a" name value))
   (hashtable-put! *config-ini-table* (mkstr name) value)
   ; initially we also setup the main ini
   ; it will be reset every page load
   (set-ini-entry name value))

;; generate code to re-create ini entries from the config file 
(define (generate-config-ini-entries)
   (let ((code '()))
      (hashtable-for-each *config-ini-table*
         (lambda (k v)
            (set! code (cons `(config-ini-entry ,k ,v) code))))
      `(begin ,@(reverse code))))

; used by extensions to set base values
; these will be used if no other is available
(define (default-ini-entry name value)
   (hashtable-put! *default-ini-table* (mkstr name) value))



;
; This module implements reading an INI file
; into a php hash. it is used in the builtin functions
; in stdlib (parse_ini_file) and also by the compiler
; to process project files from the IDE
;

;
; this still needs more work to be compatible with php:
;  1) it will replace constants with their values
;  2) bitewise operations

(define *current-lineno* 1)

(define *first-eof-p* #t)

(define *ini-surface*
   (regular-grammar
	 ((crlf (: (* "\r") #\newline )))
      ; yadda
      ("[" 'lbrak)
      ("]" 'rbrak)
      ("=" 'assign)
      ; space, newlines
      ((+ (in space #\Tab)) (ignore))
      ;
      (crlf (begin
	       (set! *current-lineno* (+ *current-lineno* 1))
	       'nl))
      ; comment
      ((: (in #\; #\#) (* all) crlf)
       (begin
	       (set! *current-lineno* (+ *current-lineno* 1))
	       'nl))
      ; value (quoted string)
      ((: #\" (* (or (out #\\ #\") (: #\\ (or all crlf)))) #\")
       ; XXX if the string was multiline, our current-lineno isn't advanced. does this happen?
       (cons 'string (the-substring 1 (-fx (the-length) 1))))
      ; value (symbol)
      ((+ (out space #\= #\newline #\tab "\r" #\[ #\] #\" #\; #\#))
       (cons 'symbol (the-string)))
      (else
       ;; this trick is so that the first time we see the eof, it will
       ;; be returned as a newline, and the second time the actual eof
       ;; will be returned.  It allows us to read ini files that don't
       ;; end in a newline.
       (cond
          ((and *first-eof-p*
                (eof-object? (the-failure)))
           (set! *first-eof-p* #f)
           'nl)
          (else
           ;; reset *first-eof-p*
           (set! *first-eof-p* #t)
           (the-failure))))))


(define *ini-grammar*
   (lalr-grammar
      ; terminals
      (assign lbrak rbrak string symbol nl)

      (inifile
       ((line inifile) (cons line inifile))
       (() '()))

      (line
       ; section header
       ; XXX symbol-list here because headers can contain spaces
       ((lbrak symbol-list rbrak nl) (cons 'section symbol-list))

       ; XXX this symbol-list gets us around not supporting bitwise
       ; operations on constants (e.g. error_reporting). we just concat the symbols together
       ((symbol@key assign symbol-list nl) (cons* 'value key symbol-list))

       ; value assign, quoted string 
       ((symbol@key assign string@val nl) (cons* 'value key val))

       ; value assign, blank string
       ((symbol assign nl) (cons* 'value symbol ""))

       ; blank line
       ((nl) '()))

      (symbol-list
       ((symbol symbol-list) (string-append symbol symbol-list))
       ((symbol) symbol))
      
       ))


(define (ini-file-parse fname::bstring parse-sections?::bool)
   (bind-exit (exit)
      (if (file-exists? fname)
	  (let ((rhash (make-php-hash))
		(current-section "")
		(ini-toks '()))
; XXX grammer debug	     
;	     (set! *current-lineno* 1)
;	     (with-input-from-file fname
;		(lambda ()
;		   (pp (get-tokens *ini-surface* (current-input-port)))))
	     (set! *current-lineno* 1)	     
	     (try
	      (set! ini-toks (with-input-from-file fname
				(lambda ()
				   (read/lalrp *ini-grammar* *ini-surface* (current-input-port)))))
	      (lambda (e p m o)
		 (php-warning (format "On line ~a of ~a: ~a" *current-lineno* fname m))
		 (exit #f)))
	     ; go through tokens and build php hash
	     (for-each (lambda (a)
			  (unless (null? a)
			  (let ((tok (car a)))
			     (cond
				;
				; NOTE: assumes parser has already handler conversion to string
				;
				((eqv? tok 'section) (set! current-section (cdr a)))
				((eqv? tok 'value) (let* ((key (cadr a))
							  (val (cddr a))
							  (down-val (string-downcase val)))
						      (when (or (string=? down-val "on")
								(string=? down-val "true"))
							 (set! val "1"))
						      (when (or (string=? down-val "off")
								(string=? down-val "null")
								(string=? down-val "false"))
							 (set! val ""))
						      (if (and parse-sections?
							       (> (string-length current-section) 0))
							  ; use section
							  (let ((shash (php-hash-lookup rhash current-section)))
							     (if (php-hash? shash)
								 ; already have the section
								 (php-hash-insert! shash key val)
								 ; make a new section hash
								 (begin
								    (set! shash (make-php-hash))
								    (php-hash-insert! shash key val)
								    (php-hash-insert! rhash current-section shash))))
							  ; no sections or none current
							  (php-hash-insert! rhash key val))))))))
		       ini-toks)
	     ; make hash
	     rhash)
	  ; bad file
	  #f)))
   

;;;;;;;;;
;
; defaults
;

; url rewriter tag defaults
(default-ini-entry "url_rewriter.tags" "a=href,area=href,frame=src,input=src,form=fakeentry")
(default-ini-entry "arg_separator.input" "&")
(default-ini-entry "precision" "12")
(default-ini-entry "register_globals" #f)

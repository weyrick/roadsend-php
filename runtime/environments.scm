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
(module environments
   (include "php-runtime.sch")
   (import
    (utils "utils.scm")
    (php-hash "php-hash.scm")
    (rt-containers "containers.scm")    
    (php-errors "php-errors.scm")
    (blib "blib.scm"))
   (export
    *superglobals*
    *global-env*
    *current-variable-environment*
    $_ENV
    $_SERVER
    $_GET
    $_POST
    $_COOKIE
    $_REQUEST
    $_SESSION
    $_FILES
    (superglobal? key)
    (init-superglobals)
    (init-env-superglobal)
    (reset-superglobals!)
    (env-php-hash-view env)
    (env-new)
    (env-import env source-hash prefix::bstring)
    (env-extend env name::bstring value)
    (env-extend/pre env name::bstring hashnumber value)
    (env-lookup env name::bstring)
    (env-lookup-internal-index env name::bstring)
    (inline env-internal-index-value index)
    (inline env-internal-index-value-set! index value)    
    (var-lookup env name)
    (var-store env name value)))

;;;; environment
;the global environment
(define *global-env* 'unset)

;the variable environment of the currently executing function, if it
;has one.  if your function uses this, please add your function to
;*builtins-requiring-variable-env* in ../compiler/declare.scm
(define *current-variable-environment* 'unset)

;a table of all the variables considered superglobal, that is,
;implicitly declared global in every function
(define *superglobals* (make-hashtable))

(define $_GET 'unset)
(define $_POST 'unset)
(define $_COOKIE 'unset)
(define $_REQUEST 'unset)
(define $_SERVER 'unset)
(define $_SESSION 'unset)
(define $_FILES 'unset)
(define $_ENV 'unset)

(define (superglobal? key)
   (let ((name (undollar key)))
      (hashtable-get *superglobals* name)))

(define (init-superglobals)
   (hashtable-put! *superglobals* "GLOBALS" #t)
   (hashtable-put! *superglobals* "_GET" #t)
   (hashtable-put! *superglobals* "_POST" #t)
   (hashtable-put! *superglobals* "_COOKIE" #t)
   (hashtable-put! *superglobals* "_FILES" #t)
   (hashtable-put! *superglobals* "_ENV" #t)
   (hashtable-put! *superglobals* "_SERVER" #t)
   (hashtable-put! *superglobals* "_SESSION" #t)
   (hashtable-put! *superglobals* "_REQUEST" #t)
   (set! $_SERVER (make-container (make-php-hash)))
   (set! $_FILES (make-container (make-php-hash)))
   (set! $_GET (make-container (make-php-hash)))
   (set! $_POST (make-container (make-php-hash)))
   (set! $_ENV (make-container (make-php-hash)))
   (set! $_REQUEST (make-container (make-php-hash)))
   (set! $_COOKIE (make-container (make-php-hash)))
   (set! $_SESSION (make-container (make-php-hash))))

;
; we precalculate these because they never change and
; are recreated on every page load
;
(define GLOBALS-key (precalculate-string-hashnumber "GLOBALS"))
(define _SERVER-key (precalculate-string-hashnumber "_SERVER"))
(define _FILES-key (precalculate-string-hashnumber "_FILES"))
(define _GET-key (precalculate-string-hashnumber "_GET"))
(define _POST-key (precalculate-string-hashnumber "_POST"))
(define _REQUEST-key (precalculate-string-hashnumber "_REQUEST"))
(define _COOKIE-key (precalculate-string-hashnumber "_COOKIE"))
(define _SESSION-key (precalculate-string-hashnumber "_SESSION"))
(define _ENV-key (precalculate-string-hashnumber "_ENV"))

(define (reset-superglobals!)
   (let ((new-global-env (make-env))
	 (new-global-bindings (make-php-hash)))
      ; always a new global environment
      (env-bindings-set! new-global-env new-global-bindings)
      (set! *global-env* new-global-env)
      ; reset each superglobal, unless it wasn't used last hit
      (unless (=fx 0 (php-hash-size (container-value $_SERVER)))
	 (set! $_SERVER (make-container (make-php-hash))))
      (unless (=fx 0 (php-hash-size (container-value $_FILES)))      
	 (set! $_FILES (make-container (make-php-hash))))
      (unless (=fx 0 (php-hash-size (container-value $_GET)))
	 (set! $_GET (make-container (make-php-hash))))
      (unless (=fx 0 (php-hash-size (container-value $_POST)))
	 (set! $_POST (make-container (make-php-hash))))
      (unless (=fx 0 (php-hash-size (container-value $_REQUEST)))
	 (set! $_REQUEST (make-container (make-php-hash))))
      (unless (=fx 0 (php-hash-size (container-value $_COOKIE)))      
	 (set! $_COOKIE (make-container (make-php-hash))))
      (unless (=fx 0 (php-hash-size (container-value $_SESSION)))
	 (set! $_SESSION (make-container (make-php-hash))))
      ; always extend global with superglobals
      (env-extend/pre *global-env* "_SERVER" _SERVER-key $_SERVER)
      (env-extend/pre *global-env* "_FILES" _FILES-key $_FILES)
      (env-extend/pre *global-env* "_GET" _GET-key $_GET)
      (env-extend/pre *global-env* "_POST" _POST-key $_POST)
      (env-extend/pre *global-env* "_REQUEST" _REQUEST-key $_REQUEST)
      (env-extend/pre *global-env* "_COOKIE" _COOKIE-key $_COOKIE)
      (env-extend/pre *global-env* "_SESSION" _SESSION-key $_SESSION)
      (env-extend/pre *global-env* "GLOBALS" GLOBALS-key new-global-bindings)))

; this sets up the $_ENV superglobal
; which is a list of current environment variables
(define (init-env-superglobal)
   (env-extend *global-env* "_ENV" $_ENV)
   (for-each (lambda (a)
		(php-hash-insert! (container-value $_ENV) (car a) (cdr a)))
	     (environ)))

(define (env-new)
   (let ((env (make-env))
	 (bindings (make-php-hash)))
      (env-bindings-set! env bindings)
      ; always extend new environments with superglobals
      (php-hash-insert!/pre bindings "GLOBALS" GLOBALS-key (env-bindings *global-env*))
      (php-hash-insert!/pre bindings "_SERVER" _SERVER-key (container-value $_SERVER))
      (php-hash-insert!/pre bindings "_FILES" _FILES-key (container-value $_FILES))
      (php-hash-insert!/pre bindings "_GET" _GET-key (container-value $_GET))
      (php-hash-insert!/pre bindings "_POST" _POST-key (container-value $_POST))
      (php-hash-insert!/pre bindings "_REQUEST" _REQUEST-key (container-value $_REQUEST))
      (php-hash-insert!/pre bindings "_COOKIE" _COOKIE-key (container-value $_COOKIE))
      (php-hash-insert!/pre bindings "_SESSION" _SESSION-key (container-value $_SESSION))
      (php-hash-insert!/pre bindings "_ENV" _ENV-key (container-value $_ENV))
      env))

; import values from a php hash into the specified environment
; see extract and import_request_variables in php-variables
(define (env-import env source-hash prefix::bstring)
   (debug-trace 2 "env-import: importing with prefix: " prefix)
   (let ((source (maybe-unbox source-hash)))
      (if (php-hash? source)
	  (php-hash-for-each source
	     (lambda (k v)
		(debug-trace 2 "env-import: importing: " k)
		(let ((sname (string-append prefix k)))
		   (if (pregexp-match "^[a-zA-Z_]\\w*" sname)
		       (env-extend env sname v)
		       (php-warning "env-import: can't import symbol: " k)))))
	  (debug-trace 2 "env-import: Not a hashtable: " source-hash))))

(define (env-extend env name::bstring value)
      (php-hash-insert! (env-bindings env) name value))

(define (env-extend/pre env name::bstring hashnumber value)
      (php-hash-insert!/pre (env-bindings env) name hashnumber value))

(define (env-php-hash-view env)
   "return a view of an env as a php-hash"
   (let ((new-hash (make-php-hash)))
      (php-hash-for-each (env-bindings env)
	 (lambda (k v)
	    (php-hash-insert! new-hash k v)))
      new-hash))

(define (env-lookup env name::bstring)
   (php-hash-lookup-location (env-bindings env) #t name))

(define (env-lookup-internal-index env name::bstring)
   (let ((bindings (env-bindings env)))
      (or (php-hash-lookup-internal-index bindings name)
	  (begin
	     ;create it if it doesn't exist
	     (php-hash-lookup-location bindings #t name)
	     (php-hash-lookup-internal-index bindings name)))))

;; merely inlining these two makes a 14% improvement in the
;; globals1.php benchmark.
(define-inline (env-internal-index-value index)
   (php-hash-internal-index-value index))

(define-inline (env-internal-index-value-set! index value)
   (php-hash-internal-index-value-set! index value))

(define (var-lookup env name)
   (env-lookup env name))
; 	       (string->symbol
; 		(mkstr "$"  name))))
;      (if var
;	  var
;	  #f)))

(define (var-store env name value)
   (env-extend env ;(string->symbol (mkstr "$" name))
	       name value))

    
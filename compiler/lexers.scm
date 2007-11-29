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


;;;; A two pass lexer for PHP
(module lexers
   (library php-runtime)
   (include "php-runtime.sch")
   (import (ast "ast.scm"))
   (export
    (php-surface)
    *current-lineno*
    *syntax-highlight?*
    (php-preprocess port filename #!optional syntax-highlight?)
    (lexer-reset!)
    (reset-lexer-state)
    (lineno-munch-file file)
    (lineno-unmunch-file)
    (handle-token-error escape proc msg token) ))

;current line number in current file
(define *current-lineno* 1)

;the current file we are parsing
(define *current-file* #f)

;stack of files we are currently visiting
(define *file-stack* '())

(define (reset-lexer-state)
   (lineno-reset!)
   (set! *file-stack* '())
   (set! *current-file* #f) )

; run after every page view
(add-end-page-reset-func reset-lexer-state)

(define (lexer-reset!)
   "Reset global variables used by the preprocessor/lexer"
   (lineno-reset!)
   (set! *file-stack* '())
   ;don't reset the current file, because it makes the parse function in
   ;php.scm bork the current file set by the php function.
;   (set! *current-file* #f)

   )

(define (lineno-inc! amt)
   "Advance the current line number by amt lines"
   (set! *current-lineno* (+ *current-lineno* amt)))

(define (lineno-reset!)
   "Reset the current-lineno to 1"
   (set! *current-lineno* 1))

(define (lineno-munch-file file)
   "Start counting lines for a new file"
   ;first save the old file/line, if any
   ;(print "munching file " file ", current line " *current-lineno*)
   (when *current-file*
      (pushf (cons *current-file* *current-lineno*) *file-stack*))
   (lineno-reset!)
   (set! *current-file* (util-realpath (mkstr file))))

(define (lineno-unmunch-file)
   "Return to counting lines for a file we've previously visited, if any."
   ;(print "unmunching file " *current-file* ", current line " *current-lineno*)
   (cond
      ((pair? *file-stack*)
       (set! *current-file* (caar *file-stack*))
       (set! *current-lineno* (cdar *file-stack*))
       (popf *file-stack*))
      (*current-file* (set! *current-file* #f))
      (else
       (error 'lineno-unmunch-file "Extra call to unmunch!" *current-file*)))
   ;(print "remunching file " *current-file* ", current line " *current-lineno*)
   )


(define (handle-token-error escape proc msg token)
   "Handle an error, printing the line number of the token."
   ;   (print "current-function: " *current-function*)
   ;   (print "current-block: " *current-block*)
   ;   (print "current-class: " *current-class*)
   (if (memv token '(error-handler php-exit php-warning/notice))
      (handle-runtime-error escape proc msg token)
      (let ((outmsg
             (format "~%~a in ~a on line ~a"
		     msg
                     (if *current-file*
                         (if (substring=? *current-file* (pwd) (string-length (pwd)))
                             (substring *current-file* (+ 1 (string-length (pwd))) ;+1 for the trailing /
                                        (string-length *current-file*))
                             *current-file*)
                         "unknown file")
                     *current-lineno*)))
         (if (and *RAVEN-DEVEL-BUILD* (> *debug-level* 1))
             (begin
                (error proc outmsg token)
                (escape #t))
             (begin
                (fprint (current-error-port) outmsg) ;" -- \"" (if (pair? token) (cdr token) token) "\"")
		(exit 1))))))
;                (escape #t))))))

(define *syntax-highlight?* #f)
(define-macro (stok type . value)
   `(if *syntax-highlight?*
        (cons ,type (the-length))
        (tok ,type ,@value)))

;a token is a vector of #(type value file line)
(define (tok type . value)
   "produce a new token for the current file and line"
   (let ((file (or *current-file*
		   (error 'tok "case of the runaway files" *file-stack*))))
      (set! *parse-loc* (cons *current-lineno* file))
      (if (pair? value)
	  (cons type (car value))
	  type)))
   
(define (handle-newlines str)
   "count the newlines in a string.  used in the lexers to keep
   line numbers accurate."
   (let ((len (string-length str)))
      (let loop ((i 0)
		 (lines 0))
	 (if (<fx i len)	    
		(loop (+fx i 1)
		      (if (char=? (string-ref str i) #\newline)
			  (+fx lines 1)
			  lines))
		(lineno-inc! lines))))
   str)

(define (just-newlines str)
   "return just the newlines in a string.  used in the case when the
   preprocessor strips something, so that the line count stays
   accurate."
   (list->string
    (let ((len (string-length str)))
       (let loop ((i 0)
		  (newlines '()))
	  (if (<fx i len)
	      (loop (+fx i 1)
		    (if (char=? (string-ref str i) #\newline)
			(cons #\newline newlines)
			newlines))
	      newlines)))))

(define (php-surface)
      (regular-grammar ((punkt (in "*" "/" "%"))
			(identifier (: (or alpha "_") (* (or alnum "_"))))
			(variable (: #\$ (or alpha "_") (* (or alnum "_")))))

	 ((+ #\Newline)
	  (set! *current-lineno* (+ *current-lineno* (the-length)))
	  (if *syntax-highlight?*
              (stok 'whitespace)
              (ignore)))

	 ((+ (in " \t\r")) (if *syntax-highlight?*
                               (stok 'whitespace)
                               (ignore)))

         ((when *syntax-highlight?*
             (: "/*" (* (out #\* #\/)) "*/"))
          (stok 'comment))
         ((when *syntax-highlight?*
             (: (or "//" "#") (* (in "x "))))
          (stok 'comment))

	 ((uncase "include") (stok 'includekey))
	 ((uncase "include_once") (stok 'include-once))
	 ((uncase "require") (stok 'requirekey))
	 ((uncase "require_once") (stok 'require-once))
	 
	 ((uncase "continue") (stok 'continue))

	 ((uncase "define") (stok 'definekey))

	 ((uncase "clone") (stok 'clone))
	 ((uncase "const") (stok 'classconst))
	 ((uncase "parent::") (stok 'parent))
	 ((uncase "self::") (stok 'selfkey))

	 ((uncase "exit") (stok 'exitkey))
	 ((uncase "die") (stok 'exitkey))

	 ((uncase "false") (stok 'boolean FALSE))  
	 
	 ((uncase "true") (stok 'boolean TRUE))

	 ((uncase "echo") (stok 'echokey))

	 ((uncase "print") (stok 'printkey))

	 ((uncase "if") (stok 'ifkey (cons *current-lineno* *current-file*)))

	 ((uncase "else") (stok 'elsekey (cons *current-lineno* *current-file*)))

	 ((uncase "elseif") (stok 'elseifkey (cons *current-lineno* *current-file*)))

	 ((uncase "while") (stok 'while (cons *current-lineno* *current-file*)))

	 ((uncase "do") (stok 'dokey (cons *current-lineno* *current-file*)))

	 ;logical ops, these have higher precedence than the onces below
	 ((uncase "or") (stok 'orkey))
	 ((uncase "xor") (stok 'xorkey))
	 ((uncase "and") (stok 'andkey))

	 ((uncase "endwhile") (stok 'endwhile))

	 ((uncase "endfor") (stok 'endfor))
	 ((uncase "endforeach") (stok 'endforeach))

	 ((uncase "endif") (stok 'endif))

	 ((uncase "for") (stok 'for (cons *current-lineno* *current-file*)))

	 ((uncase "foreach") (stok 'foreach (cons *current-lineno* *current-file*)))

	 ((uncase "as") (stok 'foreach-as))

	 ((uncase "unset") (stok 'unset))

	 ;; here we're returning a *current-lineno* as the value, any other
	 ;; value would be pointless, and this location is more
	 ;; accurate than the global variable would be, because the
	 ;; parser has parsed to the end of the block before reducing
	 ;; the function production.
	 ((uncase "function") (stok 'functionkey (cons *current-lineno* *current-file*)))

	 ((uncase "var") (stok 'varkey))

	 ;;same trick as functionkey
	 ((uncase "class") (stok 'classkey (cons *current-lineno* *current-file*)))
	 ((uncase "interface") (stok 'interfacekey (cons *current-lineno* *current-file*)))

         ((uncase "public") (stok 'public))
         ((uncase "private") (stok 'private))
         ((uncase "protected") (stok 'protected))
	 ((uncase "abstract") (stok 'abstract))
	 ((uncase "final") (stok 'final))

	 ((uncase "extends") (stok 'extends))
	 ((uncase "implements") (stok 'implements))

	 ((uncase "array") (stok 'array (cons *current-lineno* *current-file*)))

	 ((uncase "list") (stok 'listkey))

	 ("::" (stok 'static-classderef))

	 ("=>" (stok 'array-arrow))

	 ((uncase "new") (stok 'newkey))

	 ((uncase "return") (stok 'returnkey))

	 ((uncase "break") (stok 'break))

	 ((uncase "global") (stok 'global))

	 ((uncase "static") (stok 'static))

	 ((uncase "switch") (stok 'switch (cons *current-lineno* *current-file*)))

	 ((uncase "endswitch") (stok 'endswitch))

	 ((uncase "default") (stok 'default))

	 ((uncase "break") (stok 'break))

	 ((uncase "case") (stok 'casekey))

	 ((uncase "null") (stok 'nullkey))

	 ((uncase "try") (stok 'trykey))
	 ((uncase "throw") (stok 'throwkey))
	 ((uncase "catch") (stok 'catchkey))
	 
	 ; we're piggy backing comparator. zend actually doesn't allow a constant as
	 ; an operand and throws a parse error
	 ("instanceof" (stok 'comparator 'instanceof))

	 ;typecasts
	 ((: "(" (* space) "bool" (* space) ")" )    (stok 'boolcast "bool"))
	 ((: "(" (* space) "boolean" (* space) ")") (stok 'boolcast "boolean"))
	 ((: "(" (* space) "int" (* space) ")")     (stok 'intcast "int"))
	 ((: "(" (* space) "integer" (* space) ")") (stok 'intcast "integer"))
	 ((: "(" (* space) "float" (* space) ")")   (stok 'floatcast "float"))
	 ((: "(" (* space) "real" (* space) ")")    (stok 'floatcast "real"))
	 ((: "(" (* space) "double" (* space) ")")  (stok 'floatcast "double"))
	 ((: "(" (* space) "string" (* space) ")")  (stok 'stringcast))
 	 ((: "(" (* space) "object" (* space) ")")  (stok 'objectcast))
 	 ((: "(" (* space) "array" (* space) ")")  (stok 'arraycast))

	 ; octal numbers
	 ((: "0" (+ digit))
	  (if (or (> (the-flonum) *MAX-INT-SIZE-F*)
		  (< (the-flonum) *MIN-INT-SIZE-F*)) 
	      (stok 'float (the-flonum))
	      (stok 'integer (string->elong (the-string) 8))))

	 ; hex numbers
	 ((: "0x" (+ xdigit))
	  ; if > (SIZEOF_LONG*2) hex digits php automatically makes it an int maxed at MAX-INT-SIZE
	  (if (> (- (the-length) 2) (* *SIZEOF-LONG* 2))
	      (stok 'integer *MAX-INT-SIZE-L*)
	      (let ((hex-flo (hex-string->flonum (the-substring 2 (the-length)))))
		 (if (or (>fl hex-flo *MAX-INT-SIZE-F*)
			 (<fl hex-flo *MIN-INT-SIZE-F*)) 
		     (stok 'float hex-flo)
		     (stok 'integer (flonum->elong hex-flo))))))

	 ; decimal numbers
	 ((or (: (in "123456789") (* digit)) "0")
	  (if (or (>fl (the-flonum) *MAX-INT-SIZE-F*)
		  (<fl (the-flonum) *MIN-INT-SIZE-F*))
	      (stok 'float (the-flonum))
	      (stok 'integer (string->elong (the-string)))))

	 ; floats
	 ((: (+ digit) (? (: #\. (* digit))) (? (: (uncase #\e) (or (? #\-) (? #\+)) (+ digit))))
	  (stok 'float (convert-to-number (the-string))));(the-flonum)))

	 ((: #\. (+ digit) (? (: (uncase #\e) (or (? #\-) (? #\+)) (+ digit))))
	  (stok 'float (convert-to-number (the-string))));(the-flonum)))
	 
	 ; identifiers
	 (identifier (stok 'id (the-symbol)))

	 ; variables
	 (variable (stok 'var (the-symbol)))

	 ; single quoted string
	 ((: "'" (* (or (out #\\ "'") (: #\\ (or all #\newline)))) "'")
	  (handle-newlines (the-string))
	  (stok 'string (quoted-string-escape #\' (the-substring 1 (- (the-length) 1)))))

	 ; double quoted string
	 ((: #\" (* (or (out #\\ #\") (: #\\ (or all #\newline)))) #\")
          (handle-newlines (the-string))
	  (stok 'string (quoted-string-escape #\" (the-substring 1 (- (the-length) 1)))))

	 (punkt (stok 'punkt (string->symbol (mkstr "php-" (the-string)))))

	 (#\+ (stok  'plus 'php-+))

	 (#\- (stok  'minus 'php--))

	 ((: punkt #\=) (stok 'punktequals (string->symbol (mkstr "php-" (the-substring 0 1)))))

	 ((: #\+ #\=) (stok 'plusequals 'php-+))

	 ((: #\- #\=) (stok 'minusequals 'php--))

	 ((or "++" "--") (stok 'crement (the-symbol)))

	 ("->" (stok 'classderef))

	 (#\( (stok 'lpar))

	 (#\) (stok 'rpar))

	 (#\? (stok 'ugly-then))

	 (#\: (stok 'colon))

	 (#\& (stok 'ref))
	 
	 (#\{ (stok 'lcurly))

	 (#\} (stok 'rcurly (cons *current-lineno* *current-file*)))

	 (#\[ (stok 'lbrak))

	 (#\] (stok 'rbrak))

	 (#\; (stok 'semi))

	 (#\= (stok 'equals (cons *current-lineno* *current-file*)))

	 (#\. (stok 'dot))

	 (#\, (stok 'comma))

	 (".="  (stok 'dotequals))

	 (#\@ (stok 'atsign))

;	 ("&="  'refequals)

	 ; comparators
	 ("==" (stok 'comparator 'equalp))
	 ("===" (stok 'comparator 'identicalp))
	 ((or "!=" "<>") (stok 'comparator 'not-equal-p))
	 ("!==" (stok 'comparator 'not-identical-p))
	 ("<" (stok 'comparator 'less-than-p))
	 (">" (stok 'comparator 'greater-than-p))
	 ("<=" (stok 'comparator 'less-than-or-equal-p))
	 (">=" (stok 'comparator 'greater-than-or-equal-p))

	 ; logical operators
 	 ("&&" (stok 'boolean-and))
 	 ("||" (stok 'boolean-or))

 	 ("!" (stok 'logical-not))

	 ;bitwise operators
;	 ("&" (stok 'bitwise-and)) XXX this is ref
	 ("|" (stok 'bitwise-or))
	 ("^" (stok 'bitwise-xor))
	 ("~" (stok 'bitwise-not))
	 ("<<" (stok 'bitwise-shift 'bitwise-shift-left))
	 (">>" (stok 'bitwise-shift 'bitwise-shift-right))

	 ;assigning bitwise operators
	 ("&=" (stok 'bitwise-and-equals))
	 ("|=" (stok 'bitwise-or-equals))
	 ("^=" (stok 'bitwise-xor-equals))
	 ("~=" (stok 'bitwise-not-equals))
	 ("<<=" (stok 'bitwise-shift-equals 'bitwise-shift-left))
	 (">>=" (stok 'bitwise-shift-equals 'bitwise-shift-right))

	 ("$" (stok 'varnamed))

	 ; whatchou be talkin bout, willis?
	 (else
	  (let ((c (the-failure)))
	     (if (eof-object? c)
		 c
		 (error 'php-surface "Illegal character" c))))))




;; This function is run by the preprocessor on backtick, heredoc,
;; and double-quote strings.  heredoc? will be true for backtick
;; and heredoc strings -- it basically means not to change \" into ".
;; constant-string? strings have no code in them.
;; The output of dqstring-parse should be simple double quoted
;; strings using only the \\ and \" escapes, with all
;; interpolated code broken out.
;; e.g., "asdfasdf" . $asdf[asdf] . "Asdfasdf", etc.
(define-macro (maybe-tok token value)
   (let ((v (gensym 'value)))
      `(let ((,v (if syntax-highlight?
                     (begin
                        ;(print "convert " (the-string) " into " (make-string (the-length) #\x))
                        (make-string (the-length) #\x))
                     ,value)))
          (if constant-string? ,v (tok ,token ,v)))))

(define (dqstring-parse astring heredoc? constant-string? syntax-highlight?)
   (let* ((handle-char-code
           (lambda (code base)
              (let ((num (string->integer code base)))
                 (if (zero? num)
                     ;; this is a workaround for an obscure rgc
                     ;; bug that keeps our lexer from being able
                     ;; to match #a000 in a string. --timjr 2006.5.28
                     "\\0"
                     (integer->char num)))))
          (lexer (regular-grammar ()
		   (#\[ (maybe-tok 'lbrak "["))
		   (#\] (maybe-tok 'rbrak "]"))		   
		   ; these next four are to deal with "$foo[".$blah."] blah"
		   ((: #\[ #\") ;; (maybe-tok 'chars "[") -- maybe-tok comes
                    ; out one too long when syntax highlighting
                    (if constant-string? "[" (tok 'chars "[")))
		   ((: #\" #\]) ;; (maybe-tok 'chars "]")
                    (if constant-string? "]" (tok 'chars "]")))
		   ((: #\\ #\\) (maybe-tok 'chars "\\\\"))
		   ((: #\\ #\") (maybe-tok 'chars (if heredoc? "\\\\\\\"" "\\\"")))
                   ((: #\\ #\n) (maybe-tok 'chars "\\n")) ;(maybe-tok 'chars (string #\newline)))
                   ((: #\\ #\f) (maybe-tok 'chars (string #a012)))
                   ((: #\\ #\r) (maybe-tok 'chars (string #a013)))		   
                   ((: #\\ #\t) (maybe-tok 'chars (string #\tab)))
                   ((: #\\ #\$) (maybe-tok 'chars "$"))
                   ((: #\\ #\{) (if constant-string? (maybe-tok 'chars "\\{") (maybe-tok 'chars "{")))
                   ((: #\\ #\x (** 1 2 xdigit))
                    (maybe-tok 'chars
                               (handle-char-code (the-substring 2 (the-length)) 16)))
                   ((: #\\ (** 1 3 (in ("07"))))
                    (maybe-tok 'chars
                               (handle-char-code (the-substring 1 (the-length)) 8)))
                   (#\" (if heredoc? (maybe-tok 'chars "\\\"") (ignore)))
		   ("{$" (maybe-tok 'curly-dollar "{$"))
		   ("${" (maybe-tok 'dollar-curly "${"))
		   (#\{ (maybe-tok 'lcurly "{"))
		   (#\} (maybe-tok 'rcurly "}"))
		   ((: (or alpha "_") (* (or alpha digit "_")))
		    (maybe-tok 'id (the-string)))
		   ((: #\$ (or alpha "_") (* (or alpha digit "_")))
		    (maybe-tok 'var (the-string)))
		   (#\$ (maybe-tok 'dollar "$"))
		   ("->" (maybe-tok 'arrow "->"))
		   ((or (+ (out alnum "\"_[]${}\\->")) digit "{" "}"  "\\$" "\\{"
                        "\\" "-" ">")
		    (maybe-tok 'chars (handle-newlines (the-string))))
		   (else (the-failure))))

	 (parser (lalr-grammar
		    (dollar var (left: lcurly lbrak arrow) curly-dollar rbrak dollar-curly id rcurly chars sqstring)
		    
		    (string
		     ((dqstring string) (cons dqstring string))
		     (() (list)))
		    
		    (dqstring
		     ((chars) chars)
		     ((arrow) arrow)
		     ((lbrak) lbrak)
		     ((rbrak) rbrak)
		     ((id) id)
		     ((dollar) dollar)
		     ((code) code)
		     ((lcurly) lcurly)
		     ((rcurly) rcurly))

		    ;{$...} and ... {$...{..}} (string-ref)
		    (curly-code
		     ((curly-dollar expr rcurly) (mkstr " $" expr " ")))

		    ;${asdf} and ${asdf[...]}
		    (dollar-curly-code
		     ((dollar-curly id rcurly) (mkstr " $" id " "))
		     ((dollar-curly id lbrak expr rbrak rcurly) (mkstr " $" id "[" expr "] "))
		     ((dollar-curly variable rcurly) (mkstr " $" variable " ")))

		    (variable
		     ((var) var)
		     ((var arrow id) (mkstr var arrow id))
		     ((var lbrak index rbrak) (mkstr var "[" index "]")))

                    (exp
                     ((dollar) dollar)
                     ((var) var)
                     ((lcurly expr rcurly) (mkstr "{" expr "}"))
                     ((lbrak expr rbrak) (mkstr "[" expr "]"))
                     ((arrow) arrow)
                     ((curly-dollar expr rcurly) (mkstr "{$" expr "}"))
                     ((dollar-curly expr rcurly) (mkstr "${" expr "}"))
                     ((chars) chars)
                     ((id) id)
                     ((sqstring) sqstring))

                    (expr
                     ((exp) exp)
                     ((expr exp) (mkstr expr exp)))

		    (variable-code
		     ((variable lcurly index rcurly) (mkstr variable "{" index "}"))
		     ((variable) variable))
		    
		    (code
		     ((sqstring)
		      ;this is tagged as code even though it could just be a string, since the recursive call to
		      ;dqstring-parse will turn it into code already
		      (cons 'code
			    (mkstr "\"'\" ."
				   (dqstring-parse (substring sqstring 1 (- (string-length sqstring) 1)) #f #f syntax-highlight?)
				   ". \"'\"")))
		     ((curly-code) (cons 'code curly-code))
		     ((variable-code) (cons 'code variable-code))
                     ((dollar-curly-code) (cons 'code dollar-curly-code)))

		    (nchars
		     ((nchars chars) (mkstr nchars chars))
		     ((chars) chars))

		    (index
		     ((id) (if syntax-highlight? id (mkstr #\' id #\')))
		     ((chars@a id chars@b) (mkstr a id b))
		     ((nchars) nchars)
		     ((variable-code) variable-code)) ) ) )

      (let ((result
             (if constant-string?
                 (string-append "\"" (append-strings
                                      (get-tokens-from-string lexer astring)) "\"")
                 (try
                  (let ((code-string  (read/lalrp parser lexer (open-input-string astring)) ))
                     (string-append "\""
                                    (append-strings
                                     (map (lambda (str)
                                             (if (pair? str)
                                                 (if syntax-highlight?
                                                     ;; ${{ is a syntax error in php, so we use that to mark code
                                                     (string-append "$"
                                                                    (make-string (- (string-length (cdr str)) 1) #\{))
                                                     (string-append "\" . "
                                                                    (cdr str)
                                                                    " . \""))
                                                 str))
                                          code-string))
                                    "\""))
                  handle-token-error)
             )))

	 result)))
	 
(define *php-preprocess-string-port* (open-output-string))

(define-macro (shtest value)
   `(let ((r ,value 
             ))
       (when syntax-highlight?
          (begin
             (unless (= (the-length) (string-length r))
                (print "bad key:" r ":")
                (print "bad val:" (the-string) ":"))
             ))
       r))

(define (php-preprocess input-port filename #!optional syntax-highlight?)
   (let ((state 'in-html)
         ;; (token-position-info (when syntax-highlight? (make-hashtable)))
	 (short-tags #t)
	 (unescape-backticks (lambda (str)
				(pregexp-replace* "\\\\`" str "`")))
	 (stringify (lambda (html)
		       ;		       (fprint (current-error-port) "stringifying: |" html "|")
                       (if syntax-highlight?
                           (make-string (string-length html) #\/)
                           (string-append "echo '" 
                                          (pregexp-replace* "'"
                                                            (pregexp-replace* "\\\\"
                                                                              html
                                                                              "\\\\\\\\")
                                                            "\\\\'")
                                          "';")))))
      (letrec ((html-lexer
		(regular-grammar ()
		   ((or (+ (or (out "<")
			       (: "<" (out "?<s"))))
			"<" "<s")
		    (shtest (stringify (handle-newlines (the-string)))))
		   
		   ;regular open tag
		   ((: (uncase "<?php") (in #" \t\r"))
		    (cons code-lexer (shtest (if syntax-highlight? (make-string (the-length) #\space) ""))))
		   
		   ((: (uncase "<?php") "\n")
		    (lineno-inc! 1)
		    (cons code-lexer                        
                          (shtest
                           (if syntax-highlight?
                               (pregexp-replace* "[^\n]" (the-string) " ")
                               "\n"))))
		   
		   ;short and javascript style open tags
		   ((or "<?"
			(: "<script" (+ blank)  "language"
				     (* blank) "=" (* blank)
				     (or "php" "\"php\"" "'php'")
				     (* blank) ">"))
		    (if (or short-tags (> (the-length) 2))
			(cons code-lexer (shtest (if syntax-highlight? (make-string (the-length) #\space) "")))
			(shtest (stringify (handle-newlines (the-string))))))
		   
		   ;"echo" open tag
		   ("<?="
		    (cons code-lexer (shtest (if syntax-highlight?
                                                 (make-string (the-length) #\space)
                                                 "echo "))) )))
	       
	       (code-lexer
		(regular-grammar ((newline (: (? "\r") "\n"))
				  (include-path
				   (: (* (in " \t"))
				      (or
				       (: #\( (* (in " \t")) #\" (+ (out #\newline #\; #\) #\")) #\" (* (in " \t")) #\))
				       (: #\( (* (in " \t")) #\' (+ (out #\newline #\; #\) #\')) #\' (* (in " \t")) #\))
				       (: #\" (+ (out #\newline #\; #\) #\")) #\")
				       (: #\' (+ (out #\newline #\; #\) #\')) #\'))
				      (* (in " \t")) #\;)))
                   
		   ;sometimes these are doubled, or occur in random places
		   ("\r" (shtest " "))
		   
		   ;closing tag
		   ((: (or "?>"
			   (: (uncase "</script") (* (in " \t")) ">")))
		    (cons html-lexer (shtest (if syntax-highlight? (make-string (the-length) #\space) ";"))))
		   
		   ;closing tag, hide newline from html
		   ((: (or "?>"
			   (: (uncase "</script") (* (in " \t")) ">"))
		       (? newline) )
		    (cons html-lexer (shtest (if syntax-highlight? (make-string (the-length) #\space) ";\n"))))
		   
		   ;		    (cons html-lexer (string-append ";" (just-newlines (the-string)))))
		   
		   ;single quoted string, so that a double quote in a single quoted string
		   ;won't be seen by the form below.
		   ((: #\' (* (or (out #\\ #\') (: #\\ (or all #\newline)))) #\') 
		    (shtest (handle-newlines (the-string))))
		   
		   ;backtick
		   ((: #\` (* (or (out #\\ #\`) (: #\\ (or all #\newline)))) #\`)
		    ;		    (fprint (current-error-port) "I was here, dammit!" (the-string) ", " (dqstring-parse (the-string) #t))
                    (shtest (string-append "shell_exec("
                                           (unescape-backticks
                                            (dqstring-parse (the-substring 1 (- (the-length) 1))
                                                            #t #f syntax-highlight?)) ")")))
                   
                   ;; This one has no dollar sign.  PHP treats it differently
                   ;; (as a T_CONSTANT_ENCAPSED_STRING), the main difference seems to be that
                   ;; \{ keeps the backslash. (It will be eaten by a non-constant double-quoted
                   ;; string). Weird.
                   ((: #\" (* (or (out #\$ #\" #\\) (: #\\ (or all #\newline)))) #\")
                    (shtest (dqstring-parse (handle-newlines (the-string)) #f #t syntax-highlight?)))
                   
		   ;double quoted strings
		   ((: #\" (* (or (out #\\ #\") (: #\\ (or all #\newline)))) #\")
		    ;dqstring-parse should handle newlines itself
                    (shtest (dqstring-parse (the-string) #f #f syntax-highlight?)))
		   
		   ;heredoc open
		   ((: "<<<" (* space) (or alpha "_") (* (or alnum "_")) newline)
		    (handle-newlines (the-string))
		    (set! heredoc-id (pregexp-replace* "[\\s]+" (the-substring 3 (the-length)) ""))
		    (set! heredoc-str "")
		    (cons heredoc-lexer ""))
		   
		   ;everything but closing tag, strings, comments,
		   ;and includes/requires
		   ((or (+ (out #\< ;#\r ;#\i
				#\# #\" #\' #\` #\? #\> #\/ #\* "\r" #\newline))
			#\<
			#\`
			;			#\r
			;			#\i
			;			#\#
			;			"\r"
			#\"
			#\'
			#\/
			#\*
			#\?
			#\>) ;)
		    (the-string))
		   
		   (newline (lineno-inc! 1) (shtest (if syntax-highlight? (the-string) "\n")))
		   
		   ; line comments
		   ;line comments don't have to reach to the end of the line:
		   ;a php close tag like ?> will terminate them too
		   ((or "#" "//")
		    (cons line-comment-lexer (shtest (if syntax-highlight? (the-string) ""))))
		   ; 		   ((: (or "#" "//")  (* (or (out "\n?")
		   ; 					     (: "?" (out "\n?>"))))
		   ; 				      (? (or "?\n" "\n")))
		   ; 		    (handle-newlines (the-string))
		   ; 		    (just-newlines (the-string)))
		   
		   ; block comments
		   ("/*"
		    (cons comment-lexer (shtest (if syntax-highlight? (the-string) "")))) ) )
	       
	       (heredoc-id #f)
	       (heredoc-str "")
	       
	       (heredoc-lexer
		(regular-grammar ((id (: (or alpha "_") (* (or alnum "_")))))		   
		   
		   ((bol id)
		    (unless heredoc-id
		       (error 'heredoc-lexer "this is a bug" (the-string)))
		    (if (string=? (the-string) heredoc-id)
			(begin
			   (set! heredoc-id #f)
			   (set! heredoc-str (pregexp-replace "\r?\n$" heredoc-str ""))
			   (cons code-lexer (shtest (dqstring-parse heredoc-str #t #f syntax-highlight?))))
			(begin
			   (set! heredoc-str (mkstr heredoc-str (the-string)))
			   ;			   (fprint (current-error-port) "didn't match, heredoc-id: :" heredoc-id ":, id :" (the-string) ":")
			   "") ) ) 
		   
		   ((+ (out alpha "_"))
		    (set! heredoc-str (mkstr heredoc-str (the-string)))
		    "")
		   
		   ((in "_" alpha)
		    (set! heredoc-str (mkstr heredoc-str (the-string)))
		    "")) ) 
	       
	       (line-comment-lexer 
		(regular-grammar ()
		   ((in "?%>")
		    (shtest (if syntax-highlight? (make-string (the-length) #\x) (ignore))))
		   
		   ((+ (out "\r\n?%>"))
		    (shtest (if syntax-highlight? (make-string (the-length) #\x) (ignore))))
		   
		   ((: "?>" (? (: (? "\r") "\n")))
		    (cons html-lexer
                          (shtest (if syntax-highlight? (make-string (the-length) #\x) ";"))))
		   
		   ((in "\r\n")
		    (handle-newlines (the-string))
                    (cons code-lexer (shtest
                                      (if syntax-highlight?
                                          (pregexp-replace* "[^\n]" (the-string) "x")
                                          (just-newlines (the-string))))))))
	       
	       
	       
	       (comment-lexer 
		(regular-grammar ()
		   ((+ (out "*"))
		    (handle-newlines (the-string))
                    (shtest (if syntax-highlight?
                                (pregexp-replace* "[^\n]" (the-string) "x")
                                (just-newlines (the-string)))))
		   
		   ("*"
		    (shtest (if syntax-highlight? " " (ignore))))
		   
		   ("*/"
		    (cons code-lexer (shtest (if syntax-highlight? (the-string) "")))))))
	 
	 (lineno-munch-file filename)
	 ;	 (let ((i 0))
	 (let ((out *php-preprocess-string-port*))
	    (let loop ((token (read/rp html-lexer input-port))
		       (the-lexer html-lexer))
	       (let ((lexer-name (cond 
				    ((eq? the-lexer html-lexer) 'html-lexer)
				    ((eq? the-lexer code-lexer) 'code-lexer)
				    ((eq? the-lexer line-comment-lexer) 'line-comment-lexer)
				    ((eq? the-lexer comment-lexer) 'comment-lexer)
				    ((eq? the-lexer heredoc-lexer) 'heredoc-lexer)
				    (else (error 'foo "mysterious unkown lexer" the-lexer)))))
		  ;		     (set! i (+fx i 1))
		  (cond
		     ((string? token) (display token out)
				      ;				      (fprint (current-error-port) i ": token: |" token "|")
				      (loop (read/rp the-lexer input-port)
					    the-lexer))
		     ((pair? token) (display (cdr token) out)
				    ;				    (fprint (current-error-port) i ": ptoken: |" token "|")
				    (loop (read/rp (car token) input-port)
					  (car token)))
		     ((eof-object? token) #t)
		     (else (error 'oops "can't happen" (cons token lexer-name))))))
	    (lineno-unmunch-file)
            (flush-string-port/bin out)))))

(define *quoted-string-port* (open-output-string))

(define (quoted-string-escape quote astring)
   "translate the escape chars in php single-quoted strings"
   (let ((len (string-length astring))
	 (out *quoted-string-port*)
	 (seen-backslash? #f))
      (let loop ((i 0))
	 (when (<fx i len)
	    (let ((c (string-ref astring i)))
	       (if seen-backslash?
		   (begin
		      (set! seen-backslash? #f)
		      (cond
			 ((char=? c #\\) (display #\\ out))
                         ((char=? c quote) (display quote out))
                         ;; this is kind of ugly, but putting actual
                         ;; newline chars into the dqstrings screws up
                         ;; handle-newlines
                         ((and (char=? quote #\") (char=? c #\n)) (display #\newline out))
                         ;; even uglier... there's a bug that keeps
                         ;; rgc from being able to handle nulls
                         ((and (char=? quote #\") (char=? c #\0) (display #a000 out)))
			 (else (display #\\ out)
			       (display c out))))
		   (if (char=? c #\\)
		       (set! seen-backslash? #t)
		       (display c out))))
	    (loop (+fx i 1))))
      ;in case astring ended in a backslash
      (when seen-backslash? (display #\\ out))
      (flush-string-port/bin out)))


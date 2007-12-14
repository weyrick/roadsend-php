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

;;;; grammar turns the list of tokens from the lexer into an AST 
(module parser
   (import (ast "ast.scm"))
   (library php-runtime)
   (export *php-syntax*) )


;;; This is the PHP grammar
(define *php-syntax*
   (lalr-grammar
      ;; note that this precedence order (highest on top) is opposite
      ;; from the way it works in yacc.
      ((right: varnamed)
       (left: elsekey elseifkey)
       (left: newkey)
       (right: logical-not bitwise-not crement atsign boolcast intcast floatcast stringcast objectcast arraycast)
       (left: punkt)
       (left: plus minus dot)
       (left: bitwise-shift)
       (none: comparator)
       (left: ref) 
       (left: bitwise-xor)
       (left: bitwise-or)
       (left: boolean-and)
       (left: boolean-or)
       (left: ugly-then colon)
       (left: dotequals punktequals plusequals minusequals equals refequals)
       (left: bitwise-shift-equals bitwise-not-equals bitwise-xor-equals bitwise-or-equals bitwise-and-equals)
       (right: printkey)
       (right: static abstract final public private protected)
       (right: catchkey)
       (left: andkey)
       (left: xorkey)
       (left: orkey)
       (left: comma)


       (right: lpar) ;did this for precedence in instantiation
;       (right: classderef static-classderef)  ;for $$foo->bar
       (left: classderef static-classderef)
       (left: exitkey)

       (left: lbrak lcurly)



       ifkey ;elsekey elseifkey ;somehow, the dangling-else problem is magically fixed.
       semi
       rpar definekey endif varkey casekey endswitch switch default id 
       array classkey implements interfacekey for break includekey requirekey include-once require-once
       global endwhile while  var  rcurly ;html
       rbrak echokey functionkey returnkey string extends
       array-arrow dokey unset foreach endforeach endfor foreach-as parent
       boolean integer float nullkey listkey clone ;globalhash
       this continue throwkey trykey selfkey classconst)

      (start
       ((statements) (finish-ast (reverse statements))))

      (statements
       ((statements statement) (cons statement statements))
       ((statement) (list statement)))


      ;worthless things
      (statement
       ;block
       ((lcurly statements rcurly)
	(reverse statements))
       ((lcurly rcurly)
	'())
       ((function) function)
       ((class-decl) class-decl)
       ((global-decl) global-decl)
       ((static-decl) static-decl)
       ((unset lpar lvals rpar semi)
	(make-unset-stmt *parse-loc* lvals))

       ;disable errors
       ((atsign statement)
	(make-disable-errors *parse-loc* statement))
       
       ;if statement
       ((ifkey lpar rval rpar statement)
 	(make-if-stmt ifkey ;; location smuggling
		      rval statement '()))
       ((ifkey lpar rval rpar statement elseif-series)
	(make-if-stmt ifkey rval statement elseif-series))
       ((ifkey lpar rval rpar colon statements endif)
	(make-if-stmt ifkey rval (reverse statements) '()))
       ((ifkey lpar rval rpar colon endif)
	(make-if-stmt ifkey rval '() '()))
       ((ifkey lpar rval rpar colon statements crufty-elseif-series endif)
	(make-if-stmt ifkey rval (reverse statements) crufty-elseif-series))
       ((ifkey lpar rval rpar colon crufty-elseif-series endif)
	(make-if-stmt ifkey rval '() crufty-elseif-series))

       ;switch
       ((switch lpar rval rpar switch-block)
	(make-switch-stmt switch rval switch-block))

       ;while 
       ((while lpar rval rpar statement)
	(make-while-loop while rval statement))
       ((while lpar rval rpar colon statements endwhile)
	(make-while-loop while rval (reverse statements)))

       ;do
       ((dokey statement while lpar rval rpar semi)
	(make-do-loop dokey rval statement))

       ;foreach
       ((foreach lpar rval foreach-as lval@value rpar statement)
        (make-foreach-loop foreach rval '() value statement))
       ((foreach lpar rval foreach-as lval@key array-arrow lval@value rpar statement)
        (make-foreach-loop foreach rval key value statement))
       ((foreach lpar rval foreach-as lval@value rpar colon statements endforeach semi)
        (make-foreach-loop foreach rval '() value (reverse statements)))
       ((foreach lpar rval foreach-as lval@key array-arrow lval@value rpar colon statements endforeach semi)
        (make-foreach-loop foreach rval key value (reverse statements)))

       ; throw
       ((throwkey rval semi)
	(make-throw *parse-loc* rval))
       
       ; try/catch
       ((trykey statement catches)
	(make-try-catch *parse-loc* statement catches))

       ((forloop) forloop)
       ((break semi)
	(make-break-stmt *parse-loc* '()))
       ((break rval semi)
	(make-break-stmt *parse-loc* rval))
       ((continue semi)
	(make-continue-stmt *parse-loc* '()))
       ((continue rval semi)
	(make-continue-stmt *parse-loc* rval))
       
       ((returnkey rval semi)
	(make-return-stmt *parse-loc* rval))
       ((returnkey semi)
	(make-return-stmt *parse-loc* '()))
       ((echokey echoclauses semi)
	(make-echo-stmt *parse-loc* echoclauses))
       ((rval semi) rval)
       ((semi)
	(make-nop *parse-loc*)))

      ;; end statement

      (exit-stmt
       ((exitkey rval)
	(make-exit-stmt *parse-loc* rval))
       ((exitkey lpar rpar)
	(make-exit-stmt *parse-loc* '()))
       ((exitkey)
	(make-exit-stmt *parse-loc* '())))

      ;things that can name a constant
      (constant-name
       ((string) string)
       ((id) id))

      (echoclauses
       ((rval comma echoclauses) (cons rval echoclauses))
       ((rval) (list rval)))

      ;switch statement
      (switch-block
       ((lcurly rcurly) '())
       ((lcurly switch-cases rcurly) switch-cases)
       ((colon switch-cases endswitch) switch-cases))

      (switch-delim ((colon) colon) ((semi) semi))

      (switch-cases
       ((switch-case switch-cases) (cons switch-case switch-cases))
       ((switch-case) (list switch-case)))
	 
      (switch-case
       ((casekey rval switch-delim statements)
	(make-switch-case *parse-loc* rval (reverse statements)))
       ((casekey rval switch-delim)
	(make-switch-case *parse-loc* rval '()))
       ((default switch-delim statements)
	(make-default-switch-case *parse-loc* (reverse statements)))
       ((default switch-delim)
	(make-default-switch-case *parse-loc* '())))

      ; catches
      (catches
       ((catch-block catches) (cons catch-block catches))
       ((catch-block) (list catch-block)))

      (catch-block       
       ((catchkey lpar id@classname lval@varname rpar statement)
	(make-catch *parse-loc* classname varname statement)))
       
      ;forloop
      (forloop-stmt
       ((nonempty-forloop-stmt) nonempty-forloop-stmt)
       (() '()))

      (nonempty-forloop-stmt
       ((rval comma nonempty-forloop-stmt) (cons rval nonempty-forloop-stmt))
       ((rval) (list rval)))

      (forloop
       ((for lpar forloop-stmt@init semi forloop-stmt@cond semi forloop-stmt@step rpar statement)
	(make-for-loop
	 for ;; we pass the parse-loc in the for token, so it's set to the top of the loop
	 init cond step statement))
       ((for lpar forloop-stmt@init semi forloop-stmt@cond semi forloop-stmt@step rpar colon statements endfor)
	(make-for-loop for init cond step (reverse statements))))

      ;classes
      (class-decl
       ;;using the same trick with classkey as with functionkey
       ;;to get the first line, and with rcurly for the last line

       ; class
       ((class-decl-flags classkey id maybe-class-extends maybe-implements lcurly class-statements rcurly)
	(make-class-decl classkey id maybe-class-extends maybe-implements class-decl-flags class-statements rcurly))
       ; empty class
       ((class-decl-flags classkey id maybe-class-extends maybe-implements lcurly rcurly)
	(make-class-decl classkey id maybe-class-extends maybe-implements class-decl-flags '() rcurly))       
       ; interface (abstract class)
       ((interfacekey id maybe-interface-extends lcurly class-statements rcurly)
	(make-class-decl interfacekey id maybe-interface-extends '() (list 'interface 'abstract) class-statements rcurly))
       ; empty interface
       ((interfacekey id maybe-interface-extends lcurly rcurly)
	(make-class-decl interfacekey id maybe-interface-extends '() (list 'interface 'abstract) '() rcurly)))

      (maybe-implements
       (() '())
       ((implements interface-list) interface-list))


      (maybe-interface-extends
       (() '())
       ((extends interface-list) interface-list))
      
      (interface-list
       ((id@class-name comma interface-list) (cons class-name interface-list ))
       ((id@class-name) (list class-name)))
      
      (maybe-class-extends
       (() '())
       ; note: this is a list because we use this field for interfaces too, which can have multiple parents
       ((extends id) (list id)))
      
      (class-decl-flags
       (() '())
       ((final) (list 'final))
       ((abstract) (list 'abstract)))

      (class-statements
       ((class-statement class-statements)
	(cons class-statement class-statements))
       ((class-statement) (list class-statement)))
            
      (class-statement
       ((class-var-flags class-vars semi) (do-property-flags class-var-flags class-vars))
       ((class-function-flags class-function) (do-method-flags class-function-flags class-function))
       ((classconst id equals decl-literal semi) (make-class-constant-decl *parse-loc* id decl-literal)))

      (class-var-flags
       ((varkey) (list 'public))
       ((class-flags) class-flags))

      (class-function-flags
       (() (list 'public))
       ((class-flags) class-flags))
      
      (class-flags
       ((class-flag class-flags) (cons class-flag class-flags))
       ((class-flag) (list class-flag)))

      (class-flag
       ((static) 'static)
       ((public) 'public)
       ((private) 'private)
       ((protected) 'protected)
       ((abstract) 'abstract)
       ((final) 'final))
           
      (class-vars
       ((class-var comma class-vars) (cons class-var class-vars))
       ((class-var) (list class-var)))

      (class-var
       ((var equals decl-literal)
	(make-property-decl *parse-loc* var decl-literal #f 'public))
       ((var)
	(make-property-decl *parse-loc* var '() #f 'public)))

      ;;note that, like for regular functions, the current line is snuck in by
      ;;way of functionkey, because otherwise you get the end of the function
      ;;instead of the beginning.
      ;;also, rcurly's value is the last line number of the method
      (class-function
       ; non-abstract
       ((functionkey maybe-ref function-name lpar decl-arglist rpar lcurly statements rcurly)
	(make-method-decl functionkey function-name decl-arglist (reverse statements) maybe-ref rcurly #f 'public))
       ; abstract
       ((functionkey maybe-ref function-name lpar decl-arglist rpar semi)
	(make-method-decl functionkey function-name decl-arglist '() maybe-ref rpar #f '(public abstract)))
       ((functionkey maybe-ref function-name lpar decl-arglist rpar lcurly rcurly)
	(make-method-decl functionkey function-name decl-arglist '() maybe-ref rcurly #f '(public abstract))))

      ;
      
      (decl-literal
       ((simple-literal) simple-literal)
       ((literal-array) literal-array)
       ((minus simple-literal)
	(make-arithmetic-unop *parse-loc* minus simple-literal)))
      
      ;elseif
      (elseif-series
       ((elseifkey lpar rval rpar statement elseif-series)
	(make-if-stmt elseifkey rval statement elseif-series))
       ((elseifkey lpar rval rpar statement)
	(make-if-stmt elseifkey rval statement '()))
       ((elsekey statement) statement))


      (crufty-elseif-series
       ((elseifkey lpar rval rpar colon statements crufty-elseif-series)
	(make-if-stmt elseifkey rval (reverse statements) crufty-elseif-series))
       ((elseifkey lpar rval rpar colon crufty-elseif-series)
	(make-if-stmt elseifkey rval '() crufty-elseif-series))
       ((elseifkey lpar rval rpar colon statements)
	(make-if-stmt elseifkey rval (reverse statements) '()))
       ((elseifkey lpar rval rpar colon)
	(make-if-stmt elseifkey rval '() '()))
       ((elsekey colon statements)
	(reverse statements)))


      ;;;function
      ;;note that the current line is snuck in by way of functionkey, whose
      ;;value is useless.  also, the last line is snuck in via rcurly.
      (function
       ((functionkey function-name lpar decl-arglist rpar lcurly statements rcurly)
	(make-function-decl functionkey function-name decl-arglist (reverse statements) #f rcurly))
       ((functionkey ref function-name lpar decl-arglist rpar lcurly statements rcurly)
	(make-function-decl functionkey function-name decl-arglist (reverse statements) #t rcurly))
       ((functionkey function-name lpar decl-arglist rpar lcurly rcurly)
	(make-function-decl functionkey function-name decl-arglist '() #f rcurly))
       ((functionkey ref function-name lpar decl-arglist rpar lcurly rcurly)
	(make-function-decl functionkey function-name decl-arglist '() #t rcurly)))

      ;the nonempty-decl-arglist/nonempty-optional-arglist dichotomy
      ;causes all formal parameters beginning at the first optional one
      ;to parse as optional, even if no explicit default value is supplied
      (decl-arglist
       ((nonempty-decl-arglist) nonempty-decl-arglist)
       (() '()))

      (nonempty-decl-arglist
       ((required-decl-arg comma nonempty-decl-arglist)
	(cons required-decl-arg nonempty-decl-arglist))
       ((optional-decl-arg-with-value comma nonempty-optional-arglist)
	(cons optional-decl-arg-with-value nonempty-optional-arglist))
       ((optional-decl-arg-with-value)
	(list optional-decl-arg-with-value))
       ((required-decl-arg) (list required-decl-arg)))


      (nonempty-optional-arglist
       ((optional-decl-arg-with-value comma nonempty-optional-arglist)
	(cons optional-decl-arg-with-value nonempty-optional-arglist))
       ((optional-decl-arg-without-value comma nonempty-optional-arglist)
	(cons optional-decl-arg-without-value nonempty-optional-arglist))
       ((optional-decl-arg-with-value) (list optional-decl-arg-with-value))
       ((optional-decl-arg-without-value) (list optional-decl-arg-without-value)))


      (optional-decl-arg-with-value
       ((maybe-typehint maybe-ref var equals decl-literal)
	(make-optional-formal-param *parse-loc* var maybe-ref maybe-typehint decl-literal)))

      (optional-decl-arg-without-value
       ((maybe-typehint maybe-ref var)
	(make-optional-formal-param *parse-loc* var maybe-ref maybe-typehint (make-literal-null *parse-loc* '()))))

      (required-decl-arg
       ((maybe-typehint maybe-ref var)
	(make-required-formal-param *parse-loc* var maybe-ref maybe-typehint)))

      (maybe-typehint
       (() '())
       ((id) id)
       ((array) '%array))

      (maybe-ref
       (() #f)
       ((ref) #t))
            
      ;;global variables
      (global-decl
       ((global global-decl-varlist semi) global-decl-varlist))

      (global-decl-varlist       
       ((global-decl-var comma global-decl-varlist) (cons global-decl-var global-decl-varlist))
       ((global-decl-var) (list global-decl-var)))

      (global-decl-var
;       ((id)
;	(make-global-decl *parse-loc* (make-php-constant *parse-loc* id)))
       ((var)
	(make-global-decl *parse-loc* var))
       ((varnamed lval)
	(make-global-decl *parse-loc* lval)))

      ;;static variables
      (static-decl
       ((static static-decl-varlist semi)
	static-decl-varlist))

      (static-decl-varlist
       ((static-decl-var comma static-decl-varlist) (cons static-decl-var static-decl-varlist))
       ((static-decl-var) (list static-decl-var)))
      
      (static-decl-var
       ((var)
	(make-static-decl *parse-loc* var '()))
       ((var equals decl-literal)
	(make-static-decl *parse-loc* var decl-literal)))

      ;so we can left-factor the newkey production 
      (constructor-arglist
       ((lpar arglist rpar) arglist)
       (() '()))
      
      ;function call
      (arglist
       ((rval comma arglist) (cons rval arglist))
       ((rval) (list rval))
       ;ignoring this ref for now - use function sig
       ((ref rval comma arglist) (cons rval arglist))
       ((ref rval) (list rval))
       (() '()))

      (literal-array
       ((array lpar array-contents rpar)
	(make-literal-array array array-contents)))

      (array-contents
       ((array-content comma array-contents)
	(cons array-content array-contents))
       ((array-content) (list array-content))
       (() '()))

      (array-content
       ((rval)
	(make-array-entry (ast-node-location rval) :next rval #f))
       ((ref rval)
	(make-array-entry *parse-loc* :next rval #t))
       ((rval@key array-arrow rval@val)
	(make-array-entry *parse-loc* key val #f))
       ((rval@key array-arrow ref rval@val)
	(make-array-entry *parse-loc* key val #t)))
 
      (constant
       ((id)
	(make-php-constant *parse-loc* id)))

      ;this is for class properties and the like.
      ;many random tokens are treated as strings here.
      (id-or-var
       ((id)
	(make-literal-string *parse-loc*  id))
       ((includekey)
	(make-literal-string *parse-loc* "include"))
       ((include-once)
	(make-literal-string *parse-loc* "include_once"))
       ((requirekey)
	(make-literal-string *parse-loc* "require"))
       ((require-once)
	(make-literal-string *parse-loc* "require_once"))
       ((continue)
	(make-literal-string *parse-loc* "continue"))
       ((definekey)
	(make-literal-string *parse-loc* "define"))
       ((exitkey)
	(make-literal-string *parse-loc* "exit"))
       ((boolean)
	(if (eqv? TRUE boolean)
	    (make-literal-string *parse-loc* "true")
	    (make-literal-string *parse-loc* "false")))
       ((echokey)
	(make-literal-string *parse-loc* "echo"))
       ((printkey)
	(make-literal-string *parse-loc* "print"))
       ((ifkey)
	(make-literal-string *parse-loc* "if"))
       ((elsekey)
	(make-literal-string *parse-loc* "else"))
       ((elseifkey)
	(make-literal-string *parse-loc* "elseif"))
       ((while)
	(make-literal-string *parse-loc* "while"))
       ((dokey)
	(make-literal-string *parse-loc* "do"))
       ((orkey)
	(make-literal-string *parse-loc* "or"))
       ((xorkey)
	(make-literal-string *parse-loc* "xor"))
       ((andkey)
	(make-literal-string *parse-loc* "and"))
       ((endwhile)
	(make-literal-string *parse-loc* "endwhile"))
       ((endif)
	(make-literal-string *parse-loc* "endif"))
       ((for)
	(make-literal-string *parse-loc* "for"))
       ((foreach)
	(make-literal-string *parse-loc* "foreach"))
       ((foreach-as)
	(make-literal-string *parse-loc* "as"))
       ((unset)
	(make-literal-string *parse-loc* "unset"))
       ((functionkey)
	(make-literal-string *parse-loc* "function"))
       ((varkey)
	(make-literal-string *parse-loc* "var"))
       ((classkey)
	(make-literal-string *parse-loc* "class"))
       ((extends)
	(make-literal-string *parse-loc* "extends"))
       ((array)
	(make-literal-string *parse-loc* "array"))
       ((listkey)
	(make-literal-string *parse-loc* "list"))
       ((newkey)
	(make-literal-string *parse-loc* "new"))
       ((returnkey)
	(make-literal-string *parse-loc* "return"))
       ((break)
	(make-literal-string *parse-loc* "break"))
       ((global)
	(make-literal-string *parse-loc* "global"))
       ((static)
	(make-literal-string *parse-loc* "static"))
       ((switch)
	(make-literal-string *parse-loc* "switch"))
       ((endswitch)
	(make-literal-string *parse-loc* "endswitch"))
       ((default)
	(make-literal-string *parse-loc* "default"))
       ((casekey)
	(make-literal-string *parse-loc* "case"))
       ((nullkey)
	(make-literal-string *parse-loc* "null")))

      ;all the things that can name a function
      (function-name
       ((id) id)
       ((definekey) 'define)
       ((nullkey) 'null)
       ((boolean) (if (eqv? TRUE boolean) 'true 'false)))

      (include-stmt
       ((includekey rval)
	(make-function-invoke *parse-loc* 'include (list rval)))
       ((include-once rval)
	(make-function-invoke *parse-loc* 'include_once (list rval)))
       ((requirekey rval)
	(make-function-invoke *parse-loc* 'require (list rval)))
       ((require-once rval)
	(make-function-invoke *parse-loc* 'require_once (list rval))))

      ;used for list assignment
      (lvals-or-empties
       ((lval comma lvals-or-empties)
        (check-lval-writeable lval)
        (cons lval lvals-or-empties))
       ((comma lvals-or-empties) (cons '() lvals-or-empties))
       ((lval comma)
        (check-lval-writeable lval)
        (list (list lval) '()))
       ((comma) '(()))
       ((lval) (list lval)))

      ;used for unset
      (lvals
       ((lval comma lvals)
        (check-lval-writeable lval)
        (cons lval lvals))
       ((lval) (list lval))
       (() '()))

      (function-call
       ((id lpar arglist rpar)
	(make-function-invoke *parse-loc* id arglist))
       ((variable-lval lpar arglist rpar)
	(make-function-invoke *parse-loc* variable-lval arglist))
       ((array-lval lpar arglist rpar)
	(make-function-invoke *parse-loc* array-lval arglist))
       ((parent id-or-var@method lpar arglist rpar) 
	(make-parent-method-invoke *parse-loc* method arglist))
       ((id@klass static-classderef id-or-var@method lpar arglist rpar) 
	(make-static-method-invoke *parse-loc* klass method arglist))
       ((selfkey id@method lpar arglist rpar)
	; we make a literal string here because static-method-invoke expects an ast-node there (from non self:: call)
	(make-static-method-invoke *parse-loc* '%self (make-literal-string *parse-loc* (mkstr method)) arglist)))
       
       
       ;expression
       (rval

	; class const
	((selfkey id)
	 (make-class-constant-fetch *parse-loc* '%self (mkstr id)))
        ((id@class static-classderef id@name)
         (make-class-constant-fetch *parse-loc* class (mkstr name)))

	; object cloning
	((clone rval)
	 (make-obj-clone *parse-loc* rval))
	
        ((rval@a ugly-then rval@b colon rval@c)
         (make-if-stmt *parse-loc* a b c))
        
        ((atsign rval)
         (make-disable-errors *parse-loc* rval))
        
        ((exit-stmt) exit-stmt)
        
        ;; constructor invocation
	((newkey variable-lval)
         (make-constructor-invoke *parse-loc* variable-lval '()))
	; = new $this->a(arg1,arg2) where a is a class property containing a class name
	((newkey class-prop-fetch lpar arglist rpar)
         (make-constructor-invoke *parse-loc* class-prop-fetch arglist))
        ((newkey function-call);id-or-var constructor-arglist)
         (function-call->constructor function-call))
        ((newkey id-or-var)
         (make-constructor-invoke *parse-loc* id-or-var '()))

        
        ((definekey lpar constant-name comma rval rpar)
         (make-constant-decl *parse-loc* constant-name rval '()))
        ((definekey lpar lval comma rval rpar)
         (make-constant-decl *parse-loc* lval rval '()))
        ((definekey lpar constant-name comma rval@name comma rval@insensitive? rpar)
         (make-constant-decl *parse-loc* constant-name name insensitive?))
        
	
        ((lval equals rval)
         (check-lval-writeable lval)
         (make-assignment equals lval rval))
        ((lval equals ref rval)
         (check-lval-ref-writeable lval)
         (make-reference-assignment equals lval rval))
        
        ;this is for list($foo, ...) = ...
        ((listkey lpar lvals-or-empties rpar equals rval)
	 (make-list-assignment equals lvals-or-empties rval))
        
        
        ;typecast
        ((boolcast rval)
         (make-typecast *parse-loc* 'boolean rval))
        ((intcast rval)
         (make-typecast *parse-loc* 'integer rval))
        ((floatcast rval)
         (make-typecast *parse-loc* 'float rval))
        ((stringcast rval)
         (make-typecast *parse-loc* 'string rval))
        ((arraycast rval)
         (make-typecast *parse-loc* 'hash rval))
        ((objectcast rval)
         (make-typecast *parse-loc* 'object rval))
        
        ((lpar rval rpar)
         rval)
        
        ; this can't actually be on the rhs of an assignment...
        ((rval@a comparator rval@b)
         (make-comparator *parse-loc* comparator a b))
        
        
        ;;logical operators
        ((rval@a boolean-and rval@b)
         (make-boolean-and *parse-loc* boolean-and a b))
        ((rval@a boolean-or rval@b)
         (make-boolean-or *parse-loc* boolean-or a b))
        ((rval@a andkey rval@b)
         (make-boolean-and *parse-loc* andkey a b))
        ((rval@a orkey rval@b)
         (make-boolean-or *parse-loc* orkey a b))
        ((rval@a xorkey rval@b)
         (make-boolean-xor *parse-loc* xorkey a b))
        
        ((logical-not rval)
         (make-boolean-not *parse-loc* rval))
        
        ((simple-literal) simple-literal)
        
        ;array
        ((literal-array) literal-array)
                
        ;this is so awful
        ((printkey rval)
         (make-echo-stmt *parse-loc* rval))
        ((include-stmt) include-stmt)
        
        
        
        
        ((rval@a punkt rval@b)
         (make-arithmetic-op *parse-loc* punkt a b))
        ((rval@a plus rval@b)
         (make-arithmetic-op *parse-loc* plus a b))
        
        ((plus rval)
         (make-arithmetic-unop *parse-loc* plus rval))
        ((minus rval)
         (make-arithmetic-unop *parse-loc* minus rval))
        
        ((rval@a minus rval@b)
         (make-arithmetic-op *parse-loc* minus a b ))
        ((rval@a ref rval@b)
         (make-bitwise-op *parse-loc* 'bitwise-and a b))
        ((rval@a bitwise-or rval@b)
         (make-bitwise-op *parse-loc* 'bitwise-or a b ))
        ((rval@a bitwise-xor rval@b)
         (make-bitwise-op *parse-loc* 'bitwise-xor a b))
        
        ((rval@a bitwise-shift rval@b)
         (make-bitwise-op *parse-loc* bitwise-shift a b))
        
        ((lval bitwise-and-equals rval)
         (check-lval-writeable lval)
         (make-assigning-arithmetic-op *parse-loc* 'bitwise-and lval rval))
        ((lval bitwise-or-equals rval)
         (check-lval-writeable lval)
         (make-assigning-arithmetic-op *parse-loc* 'bitwise-or lval rval))
        ((lval bitwise-xor-equals rval)
         (check-lval-writeable lval)
         (make-assigning-arithmetic-op *parse-loc* 'bitwise-xor lval rval))
        ((lval bitwise-not-equals rval)
         (check-lval-writeable lval)
         (make-assigning-arithmetic-op *parse-loc* 'bitwise-not lval rval))
        ((lval bitwise-shift-equals rval)
         (check-lval-writeable lval)
         (make-assigning-arithmetic-op *parse-loc* bitwise-shift-equals lval rval))
        
        ((bitwise-not rval)
         (make-bitwise-not-op *parse-loc* rval))
        
        ((rval@a dot rval@b)
         (make-string-cat *parse-loc* a b))
        
        ((lval punktequals rval)
         (check-lval-writeable lval)
         (make-assigning-arithmetic-op *parse-loc* punktequals lval rval))
        ((lval plusequals rval)
         (check-lval-writeable lval)
         (make-assigning-arithmetic-op *parse-loc* plusequals lval rval))
        ((lval minusequals rval)
         (check-lval-writeable lval)
         (make-assigning-arithmetic-op *parse-loc* minusequals lval rval))
        ((lval dotequals rval)
         (check-lval-writeable lval)
         (make-assigning-string-cat *parse-loc* lval rval))
        
        ((crement lval)
         (check-lval-writeable lval)
         (make-precrement *parse-loc* crement lval))
        ((lval crement)
         (check-lval-writeable lval)
         (make-postcrement *parse-loc* crement lval))
        
        ((lval) lval))
       
       (simple-literal
        ((constant) constant)
        ((nullkey)
         (make-literal-null *parse-loc* '()))
        ((string)
         (make-literal-string *parse-loc* string))
        ((boolean)
         (make-literal-boolean *parse-loc* boolean))
        ((integer)
         (make-literal-integer *parse-loc* integer))
        ((float)
         (make-literal-float *parse-loc* float)))
       
       (class-lval 
	((class-prop-fetch) class-prop-fetch)
        ((class-lval lpar arglist rpar)
         (make-method-invoke (ast-node-location class-lval) class-lval arglist))
        ((function-call)
         function-call))

       (class-prop-fetch
        ((lval classderef id-or-var)
         (make-property-fetch *parse-loc* lval id-or-var))
        ((lval classderef variable-lval)
         (make-property-fetch *parse-loc* lval variable-lval))
        ((lval classderef lcurly rval rcurly)
         (make-property-fetch *parse-loc* lval rval))
	; PHP5
        ((function-call classderef id-or-var)
         (make-property-fetch *parse-loc* function-call id-or-var))
        ((function-call classderef lcurly rval rcurly)
         (make-property-fetch *parse-loc* function-call rval))
	; static props
	((selfkey variable-lval@prop)
         (make-static-property-fetch *parse-loc* '%self prop))
	((parent variable-lval@prop)
         (make-static-property-fetch *parse-loc* '%parent prop))
        ((id@class static-classderef variable-lval@prop)
         (make-static-property-fetch *parse-loc* class prop)))
        
	
       
       ;place
       (lval
        ((variable-lval) variable-lval)
        ((class-lval) class-lval)
        ((array-lval) array-lval))
       
       (variable-lval
        ((varnamed lval)
         (make-var-var *parse-loc* lval))
        
        ((varnamed lcurly rval rcurly)
         (make-var-var *parse-loc* rval))
        
        ((var)
         (make-var *parse-loc* var)))
       
       (any-l-bracket
        ((lbrak) lbrak)
        ((lcurly) lcurly))
       
       (any-r-bracket
        ((rbrak) rbrak)
        ((rcurly) rcurly))
       
       (array-lval
        ((variable-lval any-l-bracket rval any-r-bracket)
         (make-hash-lookup *parse-loc* variable-lval rval))
        
        ((array-lval any-l-bracket rval any-r-bracket)
         (make-hash-lookup *parse-loc* array-lval rval))
        
        ((class-lval any-l-bracket rval any-r-bracket)
         (make-hash-lookup *parse-loc* class-lval rval))
        
        ((variable-lval any-l-bracket any-r-bracket)
         (make-hash-lookup *parse-loc* variable-lval :next))
        
        ((array-lval any-l-bracket any-r-bracket)
         (make-hash-lookup *parse-loc* array-lval :next))
        
        ((class-lval any-l-bracket any-r-bracket)
         (make-hash-lookup *parse-loc* class-lval :next)) ) ))

(define (do-property-flags flags prop-decl-list)
   (let ((seen-visibility #f))
      (when (member 'static flags)
	 (map (lambda (c) (property-decl-static?-set! c #t) c) prop-decl-list))
      (when (member 'public flags)
	 (set! seen-visibility #t))
      (when (member 'private flags)
	 (if seen-visibility
	     (error 'do-property-flags "Multiple access type modifiers are not allowed" "")
	     (begin
		(map (lambda (c) (property-decl-visibility-set! c 'private) c) prop-decl-list)
		(set! seen-visibility #t))))
      (when (member 'protected flags)
	 (if seen-visibility
	     (error 'do-property-flags "Multiple access type modifiers are not allowed" "")
	     (begin
		(map (lambda (c) (property-decl-visibility-set! c 'protected) c) prop-decl-list)
		(set! seen-visibility #t))))
      prop-decl-list))

(define (do-method-flags flags method-decl)
   (let ((seen-visibility #f))
      (when (member 'static flags)
	 (method-decl-static?-set! method-decl #t))
      (when (member 'public flags)
	 (set! seen-visibility #t))
      (when (member 'private flags)
	 (if seen-visibility
	     (error 'do-method-flags "Multiple access type modifiers are not allowed" "")
	     (begin
		(set! seen-visibility #t))))
      (when (member 'protected flags)
	 (if seen-visibility
	     (error 'do-method-flags "Multiple access type modifiers are not allowed" "")
	     (begin
		(set! seen-visibility #t))))

; XXX we have to do these checks in declare, we don't have enough information here
;      (when (and (member 'abstract flags)
;		 (not (null? (method-decl-body method-decl))))
;	 (error 'do-method-flags "Abstract function cannot contain a body" ""))
;      (when (and (null? (method-decl-body method-decl))
;		 (not (member 'abstract flags)))
;	 (error 'do-method-flags "Non-abstract method must contain a body" ""))
      
      (method-decl-flags-set! method-decl flags)
      method-decl))


(define (check-lval-writeable lval)
   ;; one of the novel properties of the new php5 grammar is that a
   ;; function call can end up being on the left-hand-side of an
   ;; assignment.
   (when (or (function-invoke? lval)
             (method-invoke? lval)
             (parent-method-invoke? lval)
             (static-method-invoke? lval))
      (error 'check-lval-writeable "Can't use function return value in write context" "")))

(define (check-lval-ref-writeable lval)
   (when (or (function-invoke? lval)
             (method-invoke? lval)
             (parent-method-invoke? lval)
             (static-method-invoke? lval))
      (error 'check-lval-ref-writeable "Can't use function return value in write context" ""))
   (when (static-property-fetch? lval)
      (error 'check-lval-ref-writeable "Can't assign static properties by reference" "")))

(define (function-call->constructor fun)
   (let ((name "")
         (arglist '()))
      (cond ((function-invoke? fun)
             (set! name (function-invoke-name fun))
             (set! arglist (function-invoke-arglist fun)))
            ((method-invoke? fun)
             (error 'fun->constructor "methods are not supported in constructors" "")
             )
            ((parent-method-invoke? fun)
             (error 'fun->constructor "parent methods are not supported in constructors" "")
             )
            ((static-method-invoke? fun)
             (error 'fun->constructor "static methods are not supported in constructors" "")
             )
            (else (error 'fun->constructor "unsupported type" "")))
      (make-constructor-invoke (ast-node-location fun)
                               (if (ast-node? name)
                                   name
                                   (make-literal-string *parse-loc* name))
                               arglist)))

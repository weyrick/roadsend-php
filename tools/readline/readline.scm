;************************************************************************/
;*                                                                      */
;* Copyright (c) 2003 Vladimir Tsichevski <wowa1@online.ru>             */
;*                                                                      */
;* This file is part of bigloo-lib (http://bigloo-lib.sourceforge.net)  */
;*                                                                      */
;* This library is free software; you can redistribute it and/or        */
;* modify it under the terms of the GNU Lesser General Public           */
;* License as published by the Free Software Foundation; either         */
;* version 2 of the License, or (at your option) any later version.     */
;*                                                                      */
;* This library is distributed in the hope that it will be useful,      */
;* but WITHOUT ANY WARRANTY; without even the implied warranty of       */
;* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU    */
;* Lesser General Public License for more details.                      */
;*                                                                      */
;* You should have received a copy of the GNU Lesser General Public     */
;* License along with this library; if not, write to the Free Software  */
;* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 */
;* USA                                                                  */
;*                                                                      */
;************************************************************************/
(module pcc-readline
  (extern
   (type FILE* (opaque) "FILE *")  
   (include #"readline/readline.h")
   (include #"string.h"))
  (export
    (rl-library-version::string)
    (set-rl-readline-name! name::string)
    (readline #!optional prompt))
  ;
  ; XXX this string* conflicts with exports we have in runtime/blib.scm
  ; it's only used in the completion interface, which we're not using for now,
  ; so it's simply disabled

;     (rl-completion-entry-function-cb::string
;       s::string
;       state::int)
;     (set-rl-completion-function!
;       #!optional
;       generator))
;    (rl-attempted-completion-function-callback::string*
;      s::string
;      start::int
;      end::int)
;    (set-attempted-completion-function!
;      #!optional
;      generator))
;   (extern
;   (type string* (pointer string) "char *")
;    (export
;     rl-completion-entry-function-cb
;     #"rl_completion_entry_function_callback")
;    (export
;     rl-attempted-completion-function-callback
;     #"rl_attempted_completion_function_callback"))
  (type (subtype undo-code #"enum undo_code" (cobj))
        (coerce cobj undo-code () (cobj->undo-code))
        (coerce long undo-code () (cobj->undo-code))
        (coerce short undo-code () (cobj->undo-code))
        (coerce undo-code cobj () ())
        (subtype bundo-code #"obj_t" (obj))
        (coerce obj bundo-code (undo-code?) ())
        (coerce bundo-code obj () ())
        (coerce bundo-code bool () ((lambda (x) #t)))
        (coerce
          bundo-code
          undo-code
          ()
          (bundo-code->undo-code))
        (coerce
          undo-code
          bundo-code
          ()
          (undo-code->bundo-code))
        (coerce
          symbol
          undo-code
          ()
          (bundo-code->undo-code))
        (coerce
          undo-code
          symbol
          ()
          (undo-code->bundo-code)))
  (foreign
    (macro undo-code
           cobj->undo-code
           (cobj)
           #"(enum undo_code)"))
  (export
    (undo-code?::bool o::obj)
    (undo-code->bundo-code::bundo-code o::undo-code)
    (bundo-code->undo-code::undo-code o::obj))
  (export (undo-list-next::undo-list o::undo-list))
  (export (undo-list-start::int o::undo-list))
  (export (undo-list-end::int o::undo-list))
  (export (undo-list-text::string o::undo-list))
  (export (undo-list-what::undo-code o::undo-list))
  (type (subtype undo-list #"UNDO_LIST*" (cobj))
        (coerce cobj undo-list () (cobj->undo-list))
        (coerce undo-list cobj () (undo-list->cobj))
        (coerce
          undo-list
          bool
          ()
          ((lambda (x) (pragma::bool #"$1 != NULL" x))))
        (subtype bundo-list #"obj_t" (obj))
        (coerce obj bundo-list () ())
        (coerce bundo-list obj () ())
        (coerce
          bundo-list
          undo-list
          (undo-list?)
          (bundo-list->undo-list))
        (coerce
          undo-list
          obj
          ()
          ((lambda (result)
              (pragma::bundo-list
                #"cobj_to_foreign($1, $2)"
                'undo-list
                result)))))
  (foreign
    (macro undo-list
           cobj->undo-list
           (cobj)
           #"(UNDO_LIST*)")
    (macro cobj
           undo-list->cobj
           (undo-list)
           #"(long)")
    (macro undo-list
           bundo-list->undo-list
           (foreign)
           #"(UNDO_LIST*)FOREIGN_TO_COBJ"))
  (export (undo-list?::bool o::obj))
  (export
    (rl-complete::int arg1001::int arg1002::int))
  (type (subtype keymap #"Keymap" (cobj))
        (coerce cobj keymap () (cobj->keymap))
        (coerce keymap cobj () (keymap->cobj))
        (coerce
          keymap
          bool
          ()
          ((lambda (x) (pragma::bool #"$1 != NULL" x))))
        (subtype bkeymap #"obj_t" (obj))
        (coerce obj bkeymap () ())
        (coerce bkeymap obj () ())
        (coerce
          bkeymap
          keymap
          (keymap?)
          (bkeymap->keymap))
        (coerce
          keymap
          obj
          ()
          ((lambda (result)
              (pragma::bkeymap
                #"cobj_to_foreign($1, $2)"
                'keymap
                result)))))
  (foreign
    (macro keymap cobj->keymap (cobj) #"(Keymap)")
    (macro cobj keymap->cobj (keymap) #"(long)")
    (macro keymap
           bkeymap->keymap
           (foreign)
           #"(Keymap)FOREIGN_TO_COBJ"))
  (export (keymap?::bool o::obj))
  (export (rl-make-bare-keymap::keymap))
  (export (rl-copy-keymap::keymap arg1003::keymap))
  (export (rl-make-keymap::keymap))
  (export (rl-discard-keymap arg1004::keymap))
  (export
    (rl-get-keymap-by-name::keymap arg1005::string))
  (export
    (rl-get-keymap-name::string arg1006::keymap))
  (export (rl-set-keymap arg1007::keymap))
  (export (rl-get-keymap::keymap))
  (export (set-rl-outstream! file*::FILE*))
  (export (rl-set-keymap-from-edit-mode))
  (export
    (rl-get-keymap-name-from-edit-mode::string))
  (export (rl-prep-terminal arg1008::int))
  (export (rl-deprep-terminal))
  (export (rl-reset-terminal::int #!optional term))
  (export (rl-prompt::string #!optional value))
  (export
    (rl-line-buffer::string #!optional value))
  (export (rl-point::int #!optional value))
  (export (rl-end::int #!optional value))
  (export (rl-mark::int #!optional value)))
;  (static *rl-completion-entry-function*))
;  (static *rl-attempted-completion-function*))

(define (bundo-code->undo-code::undo-code o::obj)
  (case o
    ((delete) (pragma::undo-code #"UNDO_DELETE"))
    ((insert) (pragma::undo-code #"UNDO_INSERT"))
    ((begin) (pragma::undo-code #"UNDO_BEGIN"))
    ((end) (pragma::undo-code #"UNDO_END"))
    (else
     (error #"bundo-code->undo-code"
            #"invalid argument, must be integer or one of (delete insert begin end): "
            o))))


(define (undo-code->bundo-code::bundo-code o::undo-code)
  (let ((res (pragma #"BUNSPEC")))
    (pragma
      #"switch($1) { case UNDO_END: $2 = $6; break;\ncase UNDO_BEGIN: $2 = $5; break;\ncase UNDO_INSERT: $2 = $4; break;\ncase UNDO_DELETE: $2 = $3; break;\ndefault: $2 = BINT($1);}"
      o
      res
      'delete
      'insert
      'begin
      'end)
    (pragma::bundo-code #"$1" res)))


(define (undo-code?::bool o::obj)
  (memq o '(delete insert begin end)))


(define (undo-list-next::undo-list o::undo-list)
  (let ((result (pragma::undo-list #"$1->next" o)))
    result))


(define (undo-list-start::int o::undo-list)
  (let ((result (pragma::int #"$1->start" o)))
    result))


(define (undo-list-end::int o::undo-list)
  (let ((result (pragma::int #"$1->end" o)))
    result))


(define (undo-list-text::string o::undo-list)
  (let ((result (pragma::string #"$1->text" o)))
    result))


(define (undo-list-what::undo-code o::undo-list)
  (let ((result (pragma::undo-code #"$1->what" o)))
    result))


(define (undo-list?::bool o::obj)
  (and (foreign? o)
       (eq? (foreign-id o) 'undo-list)))


(define (rl-complete::int arg1001::int arg1002::int)
  (let ((arg1001::int arg1001) (arg1002::int arg1002))
    (pragma::int
      #"rl_complete($1, $2)"
      arg1001
      arg1002)))


(define (readline #!optional prompt)
  (let* ((prompt::string
           (or prompt (pragma::string #"NULL")))
         (result::string
           (pragma::string #"readline($1)" prompt)))
    (if (pragma::bool #"$1 == NULL" result)
      beof
      (let ((retval::bstring result))
        (pragma #"free($1)" result)
        retval))))


(define (keymap?::bool o::obj)
  (and (foreign? o) (eq? (foreign-id o) 'keymap)))


(define (rl-make-bare-keymap::keymap)
  (let ()
    (pragma::keymap #"rl_make_bare_keymap()")))


(define (rl-copy-keymap::keymap arg1003::keymap)
  (let ((arg1003::keymap arg1003))
    (pragma::keymap #"rl_copy_keymap($1)" arg1003)))


(define (rl-make-keymap::keymap)
  (let () (pragma::keymap #"rl_make_keymap()")))


(define (rl-discard-keymap arg1004::keymap)
  (let ((arg1004::keymap arg1004))
    (pragma #"rl_discard_keymap($1)" arg1004)
    #unspecified))


(define (rl-get-keymap-by-name::keymap arg1005::string)
  (let ((arg1005::string arg1005))
    (pragma::keymap
      #"rl_get_keymap_by_name($1)"
      arg1005)))


(define (rl-get-keymap-name::string arg1006::keymap)
  (let ((arg1006::keymap arg1006))
    (pragma::string
      #"rl_get_keymap_name($1)"
      arg1006)))


(define (rl-set-keymap arg1007::keymap)
  (let ((arg1007::keymap arg1007))
    (pragma #"rl_set_keymap($1)" arg1007)
    #unspecified))


(define (rl-get-keymap::keymap)
  (let () (pragma::keymap #"rl_get_keymap()")))


(define (rl-set-keymap-from-edit-mode)
  (let ()
    (pragma #"rl_set_keymap_from_edit_mode()")
    #unspecified))


(define (rl-get-keymap-name-from-edit-mode::string)
  (let ()
    (pragma::string
      #"rl_get_keymap_name_from_edit_mode()")))


(define (rl-prep-terminal arg1008::int)
  (let ((arg1008::int arg1008))
    (pragma #"rl_prep_terminal($1)" arg1008)
    #unspecified))


(define (rl-deprep-terminal)
  (let ()
    (pragma #"rl_deprep_terminal()")
    #unspecified))


(define (rl-reset-terminal::int #!optional term)
  (let ((term::string (or term (pragma::string #"NULL"))))
    (pragma::int #"rl_reset_terminal($1)" term)))


(define (rl-library-version::string)
  (pragma::string #"(char *)rl_library_version"))


(define (set-rl-readline-name! name::string)
  (pragma #"rl_readline_name = $1" name)
  #unspecified)

(define (set-rl-outstream! file*::FILE*)
   (pragma "rl_outstream = $1" file*)
   #unspecified)

(define (rl-prompt::string #!optional value)
  (let ((old (pragma::string #"rl_prompt")))
    (when value
          (let ((value::string value))
            (pragma #"rl_prompt = $1" value)))
    old))


(define (rl-line-buffer::string #!optional value)
  (let ((old (pragma::string #"rl_line_buffer")))
    (when value
          (let ((value::string value))
            (pragma #"rl_line_buffer = $1" value)))
    old))


(define (rl-point::int #!optional value)
  (let ((old (pragma::int #"rl_point")))
    (when value
          (let ((value::int value))
            (pragma #"rl_point = $1" value)))
    old))


(define (rl-end::int #!optional value)
  (let ((old (pragma::int #"rl_end")))
    (when value
          (let ((value::int value))
            (pragma #"rl_end = $1" value)))
    old))


(define (rl-mark::int #!optional value)
  (let ((old (pragma::int #"rl_mark")))
    (when value
          (let ((value::int value))
            (pragma #"rl_mark = $1" value)))
    old))


; (define *rl-completion-entry-function*
;   *rl-completion-entry-function*)


; (define (rl-completion-entry-function-cb::string
;          s::string
;          state::int)
;   (let ((result (*rl-completion-entry-function* s state)))
;     (if result
;       (let ((result::string result))
;         (pragma::string #"strdup($1)" result))
;       (pragma::string #"NULL"))))


; (define (set-rl-completion-function!
;          #!optional
;          generator)
;   (if (procedure? generator)
;     (begin
;       (pragma
;         #"\nrl_completion_entry_function =\n (rl_compentry_func_t *)rl_completion_entry_function_callback")
;       (set! *rl-completion-entry-function*
;         (let (completions)
;           (lambda (s state)
;              (cond ((zero? state)
;                     (let ((comps (generator s)))
;                       (if (pair? comps)
;                         (begin
;                           (set! completions (list->vector comps))
;                           (vector-ref completions 0))
;                         #f)))
;                    ((>fx state (vector-length completions)) #f)
;                    (else (vector-ref completions (-fx state 1))))))))
;     (case generator
;       ((filename)
;        (pragma
;          #"\nrl_completion_entry_function =\n (rl_compentry_func_t *)rl_filename_completion_function"))
;       ((username)
;        (pragma
;          #"\nrl_completion_entry_function =\n (rl_compentry_func_t *)rl_username_completion_function"))
;       ((#f)
;        (pragma
;          #"\nrl_completion_entry_function =\n (rl_compentry_func_t *)NULL"))
;       (else
;        (error #"set-rl-completion-function!"
;               #"Invalid argument: must be ``filename'', ``username'' or #f"
;               generator))))
;   #unspecified)


; (define (string-list->cpointers-malloced::string*
;          attvals::pair-nil)
;   (let ((valsp::string*
;           (pragma::string*
;             #"malloc($1 * sizeof(void*))"
;             (+fx 1 (length attvals)))))
;     (let loop ((i 0) (attvals attvals))
;       (if (pair? attvals)
;         (let ((s::string (car attvals)))
;           (string*-set!
;             valsp
;             i
;             (pragma::string #"strdup($1)" s))
;           (loop (+fx i 1) (cdr attvals)))
;         (begin
;           (string*-set! valsp i (pragma::string #"NULL"))
;           valsp)))))


; (define *rl-attempted-completion-function*
;   *rl-attempted-completion-function*)


; (define (rl-attempted-completion-function-callback::string*
;          s::string
;          start::int
;          end::int)
;   (let ((matches
;           (*rl-attempted-completion-function* s start end)))
;     (if (pair? matches)
;       (string-list->cpointers-malloced matches)
;       (pragma::string* #"NULL"))))


; (define (set-attempted-completion-function!
;          #!optional
;          generator)
;   (if (procedure? generator)
;     (begin
;       (pragma
;         #"\nrl_attempted_completion_function =\n (rl_completion_func_t *) rl_attempted_completion_function_callback")
;       (set! *rl-attempted-completion-function*
;         generator))
;     (pragma
;       #"\nrl_attempted_completion_function =(rl_completion_func_t *)NULL"))
;   #unspecified)


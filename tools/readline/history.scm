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
(module pcc-history
  (extern (include #"readline/history.h"))
  (export
    (history-list::pair-nil)
    (history-arg-extract
      s::string
      #!optional
      (first 0)
      last)
    (history-get-event
      s::string
      delimiting-quote::char)
;    (history-tokenize::pair-nil s::string)
    (history-remove which::int)
    (history-replace
      which::int
      line::string
      data::obj)
    (history-unstifle)
    (history-current)
    (history-get offset::int)
    (previous-history)
    (next-history)
    (history-search
      string::string
      #!optional
      backward?)
    (history-read #!optional filename from to)
    (history-write #!optional filename from to)
    (history-append nelements::int filename::string)
    (history-truncate-file
      filename::string
      lines::int)
    (history-expand s::string))
  (export (hist-entry-line::string o::hist-entry))
  (export (hist-entry-data::obj o::hist-entry))
  (type (subtype hist-entry #"HIST_ENTRY*" (cobj))
        (coerce cobj hist-entry () (cobj->hist-entry))
        (coerce hist-entry cobj () (hist-entry->cobj))
        (coerce
          hist-entry
          bool
          ()
          ((lambda (x) (pragma::bool #"$1 != NULL" x))))
        (subtype bhist-entry #"obj_t" (obj))
        (coerce obj bhist-entry () ())
        (coerce bhist-entry obj () ())
        (coerce
          bhist-entry
          hist-entry
          (hist-entry?)
          (bhist-entry->hist-entry))
        (coerce
          hist-entry
          obj
          ()
          ((lambda (result)
              (pragma::bhist-entry
                #"cobj_to_foreign($1, $2)"
                'hist-entry
                result)))))
  (foreign
    (macro hist-entry
           cobj->hist-entry
           (cobj)
           #"(HIST_ENTRY*)")
    (macro cobj
           hist-entry->cobj
           (hist-entry)
           #"(long)")
    (macro hist-entry
           bhist-entry->hist-entry
           (foreign)
           #"(HIST_ENTRY*)FOREIGN_TO_COBJ"))
  (export (hist-entry?::bool o::obj))
  (type (subtype history-state #"HISTORY_STATE*" (cobj))
        (coerce
          cobj
          history-state
          ()
          (cobj->history-state))
        (coerce
          history-state
          cobj
          ()
          (history-state->cobj))
        (coerce
          history-state
          bool
          ()
          ((lambda (x) (pragma::bool #"$1 != NULL" x))))
        (subtype bhistory-state #"obj_t" (obj))
        (coerce obj bhistory-state () ())
        (coerce bhistory-state obj () ())
        (coerce
          bhistory-state
          history-state
          (history-state?)
          (bhistory-state->history-state))
        (coerce
          history-state
          obj
          ()
          ((lambda (result)
              (pragma::bhistory-state
                #"cobj_to_foreign($1, $2)"
                'history-state
                result)))))
  (foreign
    (macro history-state
           cobj->history-state
           (cobj)
           #"(HISTORY_STATE*)")
    (macro cobj
           history-state->cobj
           (history-state)
           #"(long)")
    (macro history-state
           bhistory-state->history-state
           (foreign)
           #"(HISTORY_STATE*)FOREIGN_TO_COBJ"))
  (export (history-state?::bool o::obj))
  (export (history-init))
  (export
    (history-get-history-state::history-state))
  (export
    (history-set-history-state state::history-state))
  (export (history-add entry::string))
  (export (history-clear))
  (export (history-stifle preserve::int))
  (export (history-stifled?::bool))
  (export (history-where::int))
  (export (history-set-pos!::bool which::int))
  (export (history-base::int #!optional value)))

(define (hist-entry-line::string o::hist-entry)
  (let ((result (pragma::string #"$1->line" o)))
    result))


(define (hist-entry-data::obj o::hist-entry)
  (let ((result (pragma::obj #"$1->data" o)))
    result))


(define (hist-entry?::bool o::obj)
  (and (foreign? o)
       (eq? (foreign-id o) 'hist-entry)))


(define (history-state?::bool o::obj)
  (and (foreign? o)
       (eq? (foreign-id o) 'history-state)))


(define (history-init)
  (let () (pragma #"using_history()") #unspecified))


(define (history-get-history-state::history-state)
  (let ()
    (pragma::history-state
      #"history_get_history_state()")))


(define (history-set-history-state state::history-state)
  (let ((state::history-state state))
    (pragma #"history_set_history_state($1)" state)
    #unspecified))


(define (history-add entry::string)
  (let ((entry::string entry))
    (pragma #"add_history($1)" entry)
    #unspecified))


(define-macro
  (split-entry . args)
  `(let ((entry::hist-entry (pragma::hist-entry ,@args)))
     (and (pragma::bool #"$1 != NULL" entry)
          (let ((s::string (hist-entry-line entry))
                (o (pragma::obj #"(obj_t)$1->data" entry)))
            (if (pragma::bool #"$1 == NULL" o)
              (set! o #f)
              (object-unref o))
            (pragma #"free($1)" entry)
            (values s o)))))

(define (history-remove which::int)
  (split-entry #"remove_history($1)" which))


(define (history-replace which::int line::string obj)
  (object-ref obj)
  (split-entry
    #"replace_history_entry($1, $2, $3)"
    which
    line
    obj))


(define (history-clear)
  (let () (pragma #"clear_history()") #unspecified))


(define (history-stifle preserve::int)
  (let ((preserve::int preserve))
    (pragma #"stifle_history($1)" preserve)
    #unspecified))


(define (history-unstifle)
  (let ((result (pragma::int #"unstifle_history()")))
    (and (>=fx result 0) result)))


(define (history-stifled?::bool)
  (let () (pragma::bool #"history_is_stifled()")))


(define (history-list::pair-nil)
  (let ((clist (pragma::void* #"history_list()")))
    (if (pragma::bool #"$1 != NULL" clist)
      (let loop ((accu '()) (i 0))
        (let ((p::hist-entry
                (pragma::hist-entry
                  #"((HIST_ENTRY**)$1)[$2]"
                  clist
                  i)))
          (if (pragma::bool #"$1 == NULL" p)
            (reverse accu)
            (loop (cons (cons (pragma::string #"$1->line" p)
                              (and (pragma::bool #"$1->data != NULL" p)
                                   (pragma::obj #"$1->data" p)))
                        accu)
                  (+fx i 1)))))
      '())))


(define (history-where::int)
  (let () (pragma::int #"where_history()")))


(define (history-current)
  (split-entry #"current_history()"))


(define (history-get offset::int)
  (split-entry #"history_get($1)" offset))


(define (history-set-pos!::bool which::int)
  (let ((which::int which))
    (pragma::bool #"history_set_pos($1)" which)))


(define (previous-history)
  (split-entry #"previous_history()"))


(define (next-history)
  (split-entry #"next_history()"))


(define (history-search
         string::string
         #!optional
         backward?)
  (let* ((direction::int (if backward? -1 1))
         (found (pragma::int
                  #"history_search($1, $2)"
                  string
                  direction)))
    (and (>=fx found 0) found)))


(define (history-search-prefix
         string::string
         #!optional
         backward?)
  (let* ((direction::int (if backward? -1 1))
         (found (pragma::int
                  #"history_search_prefix($1, $2)"
                  string
                  direction)))
    (and (>=fx found 0) found)))


(define (history-search-pos
         string::string
         #!optional
         backward?
         pos)
  (let* ((direction::int (if backward? -1 1))
         (pos::int (or pos (history-current)))
         (found (pragma::int
                  #"history_search_pos($1, $2, $3)"
                  string
                  direction
                  pos)))
    (and (>=fx found 0) found)))


(define (history-read #!optional filename from to)
  (let ((filename::string
          (or filename (pragma::string #"NULL")))
        (from::int (or from 0))
        (to::int (or to -1)))
    (when (pragma::bool
            #"read_history_range($1, $2, $3)"
            filename
            from
            to)
          (error "history-read" filename from))))


(define (history-write #!optional filename from to)
  (let ((filename::string
          (or filename (pragma::string #"NULL"))))
    (when (pragma::bool #"write_history($1)" filename)
          (error "history-write" filename from))))


(define (history-append nelements::int filename::string)
  (when (pragma::bool
          #"append_history($1, $2)"
          nelements
          filename)
        (error "history-append" nelements filename)))


(define (history-truncate-file
         filename::string
         lines::int)
  (when (pragma::bool
          #"history_truncate_file($1, $2)"
          filename
          lines)
        (error #"history-truncate-file" filename lines)))


(define (history-expand s::string)
  (let* ((resultp::string (pragma::string #"NULL"))
         (result::int
           (pragma::int
             #"history_expand($1, &$2)"
             s
             resultp))
         (result-string::bstring resultp))
    (pragma #"free($1)" resultp)
    (case result
      ((0) #f)
      ((1) result-string)
      ((-1) (error #"history-expand" result-string s))
      ((2) (list result-string)))))


(define (history-arg-extract
         s::string
         #!optional
         (first 0)
         last)
  (let* ((first::int first)
         (last::int (or last (pragma::int #"'$'")))
         (result::string
           (pragma::string
             #"history_arg_extract($1, $2, $3)"
             first
             last
             s)))
    (and (pragma::bool #"$1 != NULL" result) result)))


(define (history-get-event
         s::string
         delimiting-quote::char)
  (let* ((caller-index::int (pragma::int #"0"))
         (event (pragma::string
                  #"get_history_event($1, &$2, $3)"
                  s
                  caller-index
                  delimiting-quote)))
    (values event caller-index)))


;(define (history-tokenize::pair-nil s::string)
;  (string*->string-list
;    (pragma::string* #"history_tokenize($1)" s)))


(define (history-base::int #!optional value)
  (let ((old (pragma::int #"history_base")))
    (when value
          (let ((value::int value))
            (pragma #"history_base = $1" value)))
    old))

(define *object-refs* (make-hashtable))
(define (object-ref o)
   (hashtable-put! *object-refs* o #f))
(define (object-unref o)
   (hashtable-remove! *object-refs* o))

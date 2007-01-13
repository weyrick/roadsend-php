(module cpy
;   (library common)
   (main main))

(define (main argv)
   (with-output-to-file (caddr argv)
      (lambda ()
         (display (copy-me-a-river (file-contents (cadr argv)))))))

(define (copy-me-a-river input)
   ;; You have to be careful with the ::string type, since it's not
   ;; binary safe.  Use ::void* if you need binary safety.
   (let ((buffer::void* (pragma::void* "malloc($1)" (string-length input))))
      ;; We want to copy the contents of the string, not the struct
      ;; itself, so use BSTRING_TO_STRING
      (pragma "memcpy( $1, BSTRING_TO_STRING($2), $3 )" buffer input (string-length input))
      ;; Copying back into a bigloo string, we have to make sure to
      ;; use bstring_to_string_len, so that we can pass the length.
      ;; Otherwise it's not binary safe.
      (pragma::bstring "string_to_bstring_len( $1, $2 )" buffer (string-length input))))



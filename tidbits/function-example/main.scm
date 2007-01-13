(module main
   (main main)
   (extern
    (include "fun.h")
    ;; beginning of fun.h
    (macro afunstruct::funstruct* "afunstruct")
    (macro fun::int (*int->int) "fun")
    (macro afun::int (int) "afun")
    (type s-funstruct (struct (fun::*int->int "fun")) "struct funstruct")
    (type int->int "int ($(int))")
    (type *int->int (function int (int)) "int ((*$)(int))")
    (type funstruct s-funstruct "funstruct")
    (type *int->int->int "int ($(int ((*)(int))))")
    ;; end of fun.h
    ))

(define (main argv)
;   (pragma::int "$1($2)" (s-funstruct*-fun afunstruct) 32)
   (*int->int-call (s-funstruct*-fun afunstruct) 32 ))
;   (fun (pragma::*int->int "afun")))


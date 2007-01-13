(module __make-php-runtime-lib
   (include "php-runtime.sch")
   ; main runtime
   (import (php-runtime "php-runtime.scm")
	   (php-hash "php-hash.scm")
	   (php-object "php-object.scm")
	   (grass "grasstable.scm")
	   (elong-lib "elongs.scm")
	   (utils "utils.scm")
	   (php-ini "php-ini.scm")
	   (signatures "signatures.scm")
           (php-errors "php-errors.scm"))
;	   (opaque-math "opaque-math-binding.scm"))
   (eval (export-all)) )


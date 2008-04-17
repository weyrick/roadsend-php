(module __make-php-runtime-lib
   (include "php-runtime.sch")
   ; main runtime
   (import (php-runtime "php-runtime.scm")
	   (core-builtins "core-builtins.scm")
	   (php-hash "php-hash.scm")
	   (dynarray "dynarray.scm")
	   (php-object "php-object.scm")
	   (grass "grasstable.scm")
	   (utils "utils.scm")
	   (php-ini "php-ini.scm")
	   (signatures "signatures.scm")
           (php-errors "php-errors.scm")
	   (output-buffering "output-buffering.scm")
	   (builtin-classes "builtin-classes.scm"))
   (eval (export-all)) )


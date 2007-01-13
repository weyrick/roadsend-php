(module fastcgi-main
   (library php-runtime)
   (library phpeval)
   (library webconnect)
   (library profiler)
   (library fastcgi)
   (main main))

(define (main argv)
   (fastcgi-main argv))

;
; this file should import all modules that should be exported
; as part of the extension. this includes any files that use
; defbuiltin, for example.
;
; c-bindings that are used only internally by the extension don't
; need to be listed here
;
(module __make-skeleton-lib
   (import
    (php-skeleton-lib "php-skeleton.scm")
    ))

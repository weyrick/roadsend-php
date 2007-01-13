(defresource xml-res
   "XML parser resource"
   parser       ; parser pointer
   handlers     ; hash table of callback handlers
   options      ; options
   encoding     ; character encoding
   cb-obj       ; callback object
   level        ; parser level
   in-struct    ; in struct flag
   struct-vals  ; struct values
   struct-index ; struct indexes
   last-open    ; check for complete tags
   cur-cdata    ; current cdata
   open?        ; #f after parser_free call
   )

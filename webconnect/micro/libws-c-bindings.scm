;; Created by cgen from (libws-c-bindings.defs). Do not edit!
(module
  libws-c-bindings
  (extern
    (include #"web_server.h")
    (web-log::void
      (format::string . rest::cobj)
      #"web_log")
    (type time-t long #"time_t")
    (type web-client* (opaque) #"struct web_client*")
    (type gethandler* (opaque) #"struct gethandler*")
    (macro ws-local::int #"WS_LOCAL")
    (macro ws-usessl::int #"WS_USESSL")
    (macro ws-useextconf::int #"WS_USEEXTCONF")
    (macro ws-dynvar::int #"WS_DYNVAR")
    (macro ws-uselen::int #"WS_USELEN")
    (type webserver
          (struct
            (socket::int #"socket")
            (port::uint #"port")
            (logfile::string #"logfile")
            (conffile::string #"conffile")
            (conffiletime::time-t #"conffiletime")
            (mimefile::string #"mimefile")
            (dataconf::string #"dataconf")
            (flags::int #"flags")
            (gethandler::gethandler* #"gethandler")
            (client::web-client* #"client")
            (usessl::int #"usessl"))
          #"struct web_server")
    (type const-string string #"const char *"))
  (export
    (web-server-use-ss-lcert
      arg1001::webserver*
      certfile::const-string))
  (export
    (web-server-use-mi-mefile
      arg1002::webserver*
      mimefile::const-string))
  (export
    (web-server-init::int
      arg1003::webserver*
      port::int
      logfile::const-string
      flags::int))
  (export
    (web-server-getconf::string
      arg1004::webserver*
      topic::string
      key::string))
  (export
    (web-server-addhandler::int
      arg1005::webserver*
      mstr::string
      func::void*
      flags::int))
  (export
    (web-server-aliasdir::int
      arg1006::webserver*
      alias::const-string
      path::string
      flags::int))
  (export
    (web-server-run::int arg1007::webserver*))
  (export (web-server-stop arg1008::webserver*))
  (export (web-client-addfile::int file::string))
  (export
    (web-client-setcookie
      key::string
      value::string
      timeoffset::string
      path::string
      domain::string
      secure::int))
  (export (web-client-deletecookie key::string))
  (export
    (web-client-setvar::int key::string val::string))
  (export (web-client-getvar::string key::string))
  (export (web-client-delvar::string key::string))
  (export (web-client-h-ttpdirective dir::string))
  (export (web-client-contenttype type::string)))

(define (web-server-use-ss-lcert
         arg1001::webserver*
         certfile::const-string)
  (let ((arg1001::webserver* arg1001)
        (certfile::const-string certfile))
    (pragma
      #"web_server_useSSLcert($1, $2)"
      arg1001
      certfile)
    #unspecified))


(define (web-server-use-mi-mefile
         arg1002::webserver*
         mimefile::const-string)
  (let ((arg1002::webserver* arg1002)
        (mimefile::const-string mimefile))
    (pragma
      #"web_server_useMIMEfile($1, $2)"
      arg1002
      mimefile)
    #unspecified))


(define (web-server-init::int
         arg1003::webserver*
         port::int
         logfile::const-string
         flags::int)
  (let ((arg1003::webserver* arg1003)
        (port::int port)
        (logfile::const-string logfile)
        (flags::int flags))
    (pragma::int
      #"web_server_init($1, $2, $3, $4)"
      arg1003
      port
      logfile
      flags)))


(define (web-server-getconf::string
         arg1004::webserver*
         topic::string
         key::string)
  (let ((arg1004::webserver* arg1004)
        (topic::string topic)
        (key::string key))
    (pragma::string
      #"web_server_getconf($1, $2, $3)"
      arg1004
      topic
      key)))


(define (web-server-addhandler::int
         arg1005::webserver*
         mstr::string
         func::void*
         flags::int)
  (let ((arg1005::webserver* arg1005)
        (mstr::string mstr)
        (func::void* func)
        (flags::int flags))
    (pragma::int
      #"web_server_addhandler($1, $2, $3, $4)"
      arg1005
      mstr
      func
      flags)))


(define (web-server-aliasdir::int
         arg1006::webserver*
         alias::const-string
         path::string
         flags::int)
  (let ((arg1006::webserver* arg1006)
        (alias::const-string alias)
        (path::string path)
        (flags::int flags))
    (pragma::int
      #"web_server_aliasdir($1, $2, $3, $4)"
      arg1006
      alias
      path
      flags)))


(define (web-server-run::int arg1007::webserver*)
  (let ((arg1007::webserver* arg1007))
    (pragma::int #"web_server_run($1)" arg1007)))


(define (web-server-stop arg1008::webserver*)
  (let ((arg1008::webserver* arg1008))
    (pragma #"web_server_stop($1)" arg1008)
    #unspecified))


(define (web-client-addfile::int file::string)
  (let ((file::string file))
    (pragma::int #"web_client_addfile($1)" file)))


(define (web-client-setcookie
         key::string
         value::string
         timeoffset::string
         path::string
         domain::string
         secure::int)
  (let ((key::string key)
        (value::string value)
        (timeoffset::string timeoffset)
        (path::string path)
        (domain::string domain)
        (secure::int secure))
    (pragma
      #"web_client_setcookie($1, $2, $3, $4, $5, $6)"
      key
      value
      timeoffset
      path
      domain
      secure)
    #unspecified))


(define (web-client-deletecookie key::string)
  (let ((key::string key))
    (pragma #"web_client_deletecookie($1)" key)
    #unspecified))


(define (web-client-setvar::int key::string val::string)
  (let ((key::string key) (val::string val))
    (pragma::int
      #"web_client_setvar($1, $2)"
      key
      val)))


(define (web-client-getvar::string key::string)
  (let ((key::string key))
    (pragma::string #"web_client_getvar($1)" key)))


(define (web-client-delvar::string key::string)
  (let ((key::string key))
    (pragma::string #"web_client_delvar($1)" key)))


(define (web-client-h-ttpdirective dir::string)
  (let ((dir::string dir))
    (pragma #"web_client_HTTPdirective($1)" dir)
    #unspecified))


(define (web-client-contenttype type::string)
  (let ((type::string type))
    (pragma #"web_client_contenttype($1)" type)
    #unspecified))


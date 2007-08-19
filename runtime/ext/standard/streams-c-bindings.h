/*
 these include files are necessary for the stream code
 the exact files depend on which platform we're on
 the makefile determines the OS and creates a define
 accordingly
*/

#include "unistd.h"
#include "fcntl.h"
#include "stdio.h"

#ifdef PCC_FREEBSD
  #include "netinet/in.h"
#endif

#ifndef PCC_MINGW
  #include "syslog.h"
  #include "netdb.h"

  #include "sys/select.h"
  #include "netinet/in.h"
  #include "arpa/inet.h"
  #include "resolv.h"
  #include "grp.h"
  #include "pwd.h"
  #include "fnmatch.h"
  #include "sys/socket.h"
  #ifdef PCC_MACOSX
    #include <sys/param.h>
    #include <sys/mount.h>
  #elif !defined(PCC_FREEBSD)
    #include "sys/statfs.h"
  #endif 
#endif /* NOT PCC_MINGW */

#include "string.h"
#include "time.h"
#include "utime.h"
#include "limits.h"
#include "stdlib.h"
#include "sys/types.h"
#include "sys/time.h"
#include "sys/stat.h"

#ifdef PCC_FREEBSD
  #include "sys/param.h"
  #include "sys/mount.h"
#else

#endif

#include "sys/file.h"
#include "network.h"

#include "windows-streams.h"

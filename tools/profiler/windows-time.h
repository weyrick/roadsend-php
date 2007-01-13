/* A time value that is accurate to the nearest
   microsecond but also has a range of years.  */
/* struct timeval */
/*   { */
/*     __time_t tv_sec;		/\* Seconds.  *\/ */
/*     __suseconds_t tv_usec;	/\* Microseconds.  *\/ */
/*   }; */


#define WIN32_LEAN_AND_MEAN 1
#include <windows.h>


struct timezone
  {
    int tz_minuteswest;		/* Minutes west of GMT.  */
    int tz_dsttime;		/* Nonzero if DST is ever in effect.  */
  };

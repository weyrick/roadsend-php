//#include <windows.h>
#include "windows-time.h"

/* //from http://lists.gnu.org/archive/html/bug-gnu-chess/2004-01/msg00020.html */

/* int gettimeofday(struct timeval* p, void* tz /\* IGNORED *\/){ */
/*   union { */
/*     long long ns100; /\*time since 1 Jan 1601 in 100ns units *\/ */
/*     FILETIME ft; */
/*   } _now; */

/*   GetSystemTimeAsFileTime( &(_now.ft) ); */
/*   p->tv_usec=(long)((_now.ns100 / 10LL) % 1000000LL ); */
/*   p->tv_sec= (long)((_now.ns100-(116444736000000000LL))/10000000LL); */
/*   return 0; */

/* } */


int hide_gettimeofday(struct timeval *tv, struct timezone *tz)
{
    FILETIME        ft;
    LARGE_INTEGER   li;
    __int64         t;
    static int      tzflag;

    if (tv)
    {
        GetSystemTimeAsFileTime(&ft);
        li.LowPart  = ft.dwLowDateTime;
        li.HighPart = ft.dwHighDateTime;
        t  = li.QuadPart;       /* In 100-nanosecond intervals */
        t -= EPOCHFILETIME;     /* Offset to the Epoch time */
        t /= 10;                /* In microseconds */
        tv->tv_sec  = (long)(t / 1000000);
        tv->tv_usec = (long)(t % 1000000);
    }

    if (tz)
    {
        if (!tzflag)
        {
            _tzset();
            tzflag++;
        }
        tz->tz_minuteswest = _timezone / 60;
        tz->tz_dsttime = _daylight;
    }

    return 0;
}

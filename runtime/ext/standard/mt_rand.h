
#include <stdio.h>
#include <stdlib.h>

//
// uint32 must be an unsigned integer type capable of holding at least 32
// bits; exactly 32 should be fastest, but 64 is better on an Alpha with
// GCC at -O3 optimization so try your options and see what's best for you
//

typedef unsigned long uint32;

#define MT_RAND_MAX ((long) (0x7FFFFFFF)) /* (1<<31) - 1 */

#define RAND_RANGE(__n, __min, __max, __tmax) \
    (__n) = (__min) + (long) ((double) ((__max) - (__min) + 1.0) * ((__n) / ((__tmax) + 1.0)))

void seedMT(uint32 seed);
uint32 randomMT(void);
long randomMTrange(long min, long max);


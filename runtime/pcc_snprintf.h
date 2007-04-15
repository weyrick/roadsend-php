
#include <stdarg.h>

#define HAVE_ISNAN 1
#define HAVE_ISINF 1

typedef size_t pcc_size_t;

int pcc_snprintf(char *buf, pcc_size_t len,  const char *format, ...);


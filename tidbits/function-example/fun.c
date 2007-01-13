#include <stdio.h>
#include "fun.h"

funstruct bfunstruct = {afun};
funstruct *afunstruct = &bfunstruct;


int fun(int (*foo)(int)) {
  foo(12);
  return 42;
}


int afun(int arg) {
  printf("arg is %d\n", arg);
  return 24;
}





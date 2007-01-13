int fun(int (*foo)(int));
int afun(int arg);

typedef struct funstruct { 
  int (*fun) (int);
} funstruct;


funstruct *afunstruct;


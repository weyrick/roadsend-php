/* ***** BEGIN LICENSE BLOCK *****
 * Roadsend PHP Compiler Runtime Libraries
 * Copyright (C) 2007 Roadsend, Inc.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
 * ***** END LICENSE BLOCK ***** */

#include <stdio.h>
#include <stdlib.h>
#include <bigloo.h>
#include "opaque-math.h"
/* #include "opaque-piddle.h" */

/* in string_to_double.h */
double string_to_double(const char *s00, char **se);

/* in the C code */
BGL_EXPORTED_DECL obj_t phpadd(obj_t a, obj_t b);
BGL_EXPORTED_DECL obj_t phpsub(obj_t a, obj_t b);
BGL_EXPORTED_DECL obj_t phpmul(obj_t a, obj_t b);
BGL_EXPORTED_DECL obj_t phpdiv(obj_t a, obj_t b);
BGL_EXPORTED_DECL obj_t phpmod(obj_t a, obj_t b);
/* obj_t long_to_phpnum(long num); */
/* obj_t double_to_phpnum(double num); */
BGL_EXPORTED_DECL long phpnum_to_long(obj_t a);
BGL_EXPORTED_DECL double phpnum_to_double(obj_t a);
/* void convert_to_long(obj_t a); */
/* void convert_to_double(obj_t a); */
BGL_EXPORTED_DECL int phpnum_compare(obj_t a, obj_t b);
/* obj_t phpnum_clone(obj_t a); */
BGL_EXPORTED_DECL obj_t phpnum_to_string(obj_t a, int precision, int efg);
BGL_EXPORTED_DECL int phpnum_is_long(obj_t a);
BGL_EXPORTED_DECL int phpnum_is_float(obj_t a);
BGL_EXPORTED_DECL obj_t string_to_float_phpnum(char *str);
BGL_EXPORTED_DECL obj_t string_to_long_phpnum(char *str);
/* int phpnum_hashnumber(obj_t a); */




/*
use this to copy a heap allocated phpnum into a stack allocated phpnum.
commented because it's not been tested yet.
#define PHPNUMCOPY(from,to)   to.type = from->type; \
                              if (to.type == DOUBLE_TYPE) { \
                                 to.value.dval = from->value.dval; \
                              } else { \
                                 to.value.lval = from->value.lval; \
                              }
*/


/* Uncomment this main() and the phpnum_fail() below and compile this
   file using bigloo to test it as a standalone (without the rest of
   pcc). */
/* int main () */
/* { */
/*   obj_t i = long_to_phpnum(0); */
/*   obj_t j = long_to_phpnum(120); */
/*   obj_t zero = long_to_phpnum(0); */
/*   obj_t one = long_to_phpnum(1); */
/*   obj_t two = long_to_phpnum(2); */
/*   obj_t big = long_to_phpnum(1000000); */


/*   for (i=long_to_phpnum(0); phpnum_compare(i,big) < 0; i=phpadd(i, one)) { */
/*     j=phpmul(j, two);//phpmul(i, two)); */
/*     j=phpdiv(j, two); */
/*   } */
/*   printf("opaque math: j: %e, i: %d\n", phpnum_to_double(j), phpnum_to_long(i)); */
/* } */


/* The piddle is something that I saw mentioned in Gabriel's Lisp
   performance book.  It's something that Maclisp did to reduce number
   consing.  We assume that most numbers are in a certain small range,
   and create a table (the FXPDL, in Maclisp) containing them. Then
   instead of consing up new numbers for that range, we index into the
   table. Maclisp also had an FLPDL for floats, but we only do longs
   right now.  I may have completely misunderstood, or done this
   badly, but it does seem to help some.

   To see some memory allocation stats, run programs after setting
   GC_PRINT_STATS=t in the shell. */

#define WITHIN_PDL_RANGE(n) ((-1024 < n) && (n < 1024))   //!((n+1024)&2047)
#define GET_PDL(n) &piddle[(int)n + 1023]

/* so that php can check the type */
int phpnum_is_float(obj_t a) {
  if ( REALP( a ) )
    return 1;
  else
    return 0;
}

/* /\* so that php can check the type *\/ */
int phpnum_is_long(obj_t a) {
  if ( REALP( a ) )
    return 0;
  else
    return 1;
}


/* allocate a new phpnum and stuff num into it as a long */
/* obj_t long_to_phpnum(long num) { */
/* /\*   if (WITHIN_PDL_RANGE(num)) { *\/ */
/* /\*     return GET_PDL(num); *\/ */
/* /\*   } else { *\/ */
/*     obj_t result = (obj_t )GC_MALLOC_ATOMIC(sizeof(phpnum)); */
/*     result->type = LONG_TYPE; */
/*     result->value.lval = num; */
/*     return result; */
/* /\*   } *\/ */
/* } */

/* allocate a new phpnum and stuff num into it as a double */
/* obj_t double_to_phpnum(double num) { */
/*   obj_t result = (obj_t )GC_MALLOC_ATOMIC(sizeof(phpnum)); */
/*   result->type = DOUBLE_TYPE; */
/*   result->value.dval = num; */
/*   return result; */
/* } */


/* get the value of a phpnum as a long. doesn't mutate the phpnum. */
long phpnum_to_long(obj_t a) {
  if (REALP(a)) {
    return (REAL_TO_DOUBLE(a) > PHP_LONGMAX) ?
      (unsigned long) REAL_TO_DOUBLE(a) :
      (long) REAL_TO_DOUBLE(a);
  } else {
    return BELONG_TO_LONG(a);
  }
}

/* get the value of a phpnum as a double. doesn't mutate the phpnum. */
double phpnum_to_double(obj_t a) {
  if (ELONGP(a)) {
    return (double)BELONG_TO_LONG(a);
  } else {
    return REAL_TO_DOUBLE(a);
  }
}

/* /\* change a phpnum into a long.  may mutate the phpnum. *\/ */
/* void convert_to_long(obj_t a) { */
/*   if (a->type == DOUBLE_TYPE) { */
/*     a->type = LONG_TYPE; */
/*     a->value.lval = (a->value.dval > PHP_LONGMAX) ?  */
/*       (unsigned long) a->value.dval :  */
/*       (long) a->value.dval; */
/*   } */
/* } */

/* /\* change a phpnum into a double. may mutate the phpnum. *\/ */
/* void convert_to_double(obj_t a) { */
/*   if (a->type == LONG_TYPE) { */
/*     a->type = DOUBLE_TYPE; */
/*     a->value.dval = (double)a->value.lval; */
/*   } */
/* } */

/* add two phpnums, potentially converting to a double. */
obj_t phpadd(obj_t a, obj_t b) 
{

  if (ELONGP(a) && ELONGP(b)) {
    double dval = (double) BELONG_TO_LONG( a ) + (double) BELONG_TO_LONG( b );
/*     if (WITHIN_PDL_RANGE(dval)) { */
/*       return GET_PDL(dval); */
/*     } else  */
    if ((dval > (double) PHP_LONGMAX) || (dval < (double) PHP_LONGMIN)) {
      return DOUBLE_TO_REAL( dval );
    } else {
      long lval = BELONG_TO_LONG( a ) + BELONG_TO_LONG( b );
      return LONG_TO_BELONG( lval );
    }
  }

  if ((REALP(a) && ELONGP(b)) || (ELONGP(a) && REALP(b))) {
    double dval = (ELONGP(a) ?
		   (((double) BELONG_TO_LONG(a)) + REAL_TO_DOUBLE(b)) :
		   ((REAL_TO_DOUBLE(a) + ((double) BELONG_TO_LONG(b)))));
    return DOUBLE_TO_REAL(dval);
  }

  if (REALP(a) && REALP(b)) {
    double dval = REAL_TO_DOUBLE(a) + REAL_TO_DOUBLE(b);
    return DOUBLE_TO_REAL(dval);
  }
  phpnum_fail("I'm lost!");
}


/* subtract two phpnums, potentially converting to a double. */
obj_t phpsub(obj_t a, obj_t b)
{
  if (ELONGP(a) && ELONGP(b)) {
    double dval = (double) BELONG_TO_LONG(a) - (double) BELONG_TO_LONG(b);

/*     if (WITHIN_PDL_RANGE(dval)) { */
/*       return GET_PDL(dval); */
/*     } else  */
    if ((dval < (double) PHP_LONGMIN) || (dval > (double) PHP_LONGMAX)) {
      return DOUBLE_TO_REAL(dval);
    } else {
      long lval = BELONG_TO_LONG(a) - BELONG_TO_LONG(b);
      return LONG_TO_BELONG(lval);
    }
  }
  if ((REALP(a) && ELONGP(b)) || 
      (ELONGP(a) && REALP(b))) {
    double dval = (REALP(a) ?
		   (REAL_TO_DOUBLE(a) - ((double) BELONG_TO_LONG (b))) :
		   ((double) BELONG_TO_LONG (a) - REAL_TO_DOUBLE(b)));
    return DOUBLE_TO_REAL(dval);
  }
  if (REALP(a) && REALP(b)) {
    double dval = REAL_TO_DOUBLE(a) - REAL_TO_DOUBLE(b);
    return DOUBLE_TO_REAL(dval);
  }
  phpnum_fail("ya got me");
}




#if defined(__i386__) && defined(__GNUC__)

#define FAST_LONG_MULTIPLY(a, b, lval, dval, usedval) do {            \
	long __tmpvar;                                                \
	__asm__ ("imul %3,%0\n"                                       \
		"adc $0,%1"                                           \
			: "=r"(__tmpvar),"=r"(usedval)                \
			: "0"(a), "r"(b), "1"(0));                    \
	if (usedval) (dval) = (double) (a) * (double) (b);            \
	else (lval) = __tmpvar;                                       \
} while (0)

#else

#define FAST_LONG_MULTIPLY(a, b, lval, dval, usedval) do {            \
	double __tmpvar = (double) (a) * (double) (b);                \
                                                                      \
	if (__tmpvar >= PHP_LONGMAX || __tmpvar <= PHP_LONGMIN) {           \
		(dval) = __tmpvar;                                    \
		(usedval) = 1;                                        \
	} else {                                                      \
		(lval) = (a) * (b);                                   \
		(usedval) = 0;                                        \
	}                                                             \
} while (0)

#endif


/* multiply two phpnums, potentially converting to a double. */
obj_t phpmul(obj_t a, obj_t b)
{
  long lval;
  double dval;
  unsigned char tx;

/*   tx = a->type | (b->type << 1); */

/*   switch (tx) { */
/*   case (LONG_TYPE | (LONG_TYPE << 1)): { */
  if (ELONGP(a) && ELONGP(b)) {
    int use_dval;
    long alval = BELONG_TO_LONG(a);
    long blval = BELONG_TO_LONG(b);

    FAST_LONG_MULTIPLY(alval, blval, lval, dval, use_dval);

    if (use_dval) {
      return DOUBLE_TO_REAL(dval);
    } /* else if (WITHIN_PDL_RANGE(lval)) { */
/*       return GET_PDL(lval); */
/*     }  */
    else {
      return LONG_TO_BELONG(lval);
    }
  }

/*   case (DOUBLE_TYPE | (DOUBLE_TYPE << 1)): { */
  else if (REALP(a) && REALP(b)) {
    dval = REAL_TO_DOUBLE(a) * REAL_TO_DOUBLE(b);
    return DOUBLE_TO_REAL(dval);
  } 
/*  case (DOUBLE_TYPE | (LONG_TYPE << 1)): { */
  else if (REALP (a) && ELONGP(b)) {
    dval = REAL_TO_DOUBLE(a) * (double) BELONG_TO_LONG(b);
    return DOUBLE_TO_REAL(dval);
  }
/*   case (LONG_TYPE | (DOUBLE_TYPE << 1)): { */
  else if (ELONGP(a) && REALP(b)) {
    dval = (double) BELONG_TO_LONG(a) * REAL_TO_DOUBLE(b);
    return DOUBLE_TO_REAL(dval);
  }
  phpnum_fail("jeepers creepers");
}

/* divide two phpnums, potentially converting to a double. */
obj_t phpdiv(obj_t a, obj_t b)
{
  if ((ELONGP(b) && (BELONG_TO_LONG(b) == 0)) ||
      (REALP(b) && (REAL_TO_DOUBLE(b) == 0.0))) {
    phpnum_fail("Derision by zero");
  }
  if (ELONGP(a) && ELONGP(b)) {
    if (BELONG_TO_LONG(a) % BELONG_TO_LONG(b) == 0) { /* integer */
      long lval = BELONG_TO_LONG(a) / BELONG_TO_LONG(b);
/*       if (WITHIN_PDL_RANGE(lval)) { */
/* 	return GET_PDL(lval); */
/*       }  else { */
      return LONG_TO_BELONG(lval);
/*       } */
    } else {
      double dval = ((double) BELONG_TO_LONG (a)) / BELONG_TO_LONG(b);
      return DOUBLE_TO_REAL(dval);
    }
  }
  if ((REALP(a) && ELONGP(b)) || 
      (ELONGP(a) && REALP(b))) {
    double dval = (ELONGP(a) ?
		   (((double) BELONG_TO_LONG(a)) / REAL_TO_DOUBLE(b)) :
		   (REAL_TO_DOUBLE(a) / ((double) BELONG_TO_LONG(b))));
    return DOUBLE_TO_REAL(dval);
  }
  if (REALP(a) && REALP(b)) {
    double dval = REAL_TO_DOUBLE(a) / REAL_TO_DOUBLE(b);
    return DOUBLE_TO_REAL(dval);
  }
  phpnum_fail("no clue");
}

/* calculate the remainder of two phpnums.  always returns a phpnum long. */
obj_t phpmod(obj_t a, obj_t b)
{
  long result;
  long aval = phpnum_to_long(a);
  long bval = phpnum_to_long(b);

  if (bval == 0) {
    phpnum_fail("Modulus by 0");
  }

  result = aval % bval;
  return LONG_TO_BELONG(result);
}

/* return 0 if the same, 1 if a is bigger, -1 if a is smaller */
int phpnum_compare(obj_t a, obj_t b)
{
  //  obj_t result = (obj_t )GC_MALLOC_ATOMIC(sizeof(phpnum));
  double aval = phpnum_to_double(a);
  double bval = phpnum_to_double(b);

  return ((aval - bval) ? (((aval - bval) > 0) ? 1 : -1) : 0);
}

#ifdef PCC_MINGW

// mingw doesn't like the uppercase versions
#define E_FORMAT "%.*e"
#define F_FORMAT "%.*f"
#define G_FORMAT "%.*g"

#else

#define E_FORMAT "%.*E"
#define F_FORMAT "%.*F"
#define G_FORMAT "%.*G"

#endif

/* convert a phpnum to a string.  precision is irrelevant for longs. */
obj_t phpnum_to_string(obj_t a, int precision, int efg) {
  int actual_length;
#define ARB_STRING_SIZE 1024
  char result[ARB_STRING_SIZE];

  if (REALP(a)) {
    double dval = REAL_TO_DOUBLE(a);
    while (1) {
      switch (efg) {
      case 0:
        actual_length = snprintf(result, ARB_STRING_SIZE, E_FORMAT, precision, dval);
        break;
      case 1:
        actual_length = snprintf(result, ARB_STRING_SIZE, F_FORMAT, precision, dval);
        break;
      case 2:
        actual_length = snprintf(result, ARB_STRING_SIZE, G_FORMAT, precision, dval);
        break;
      default:
        phpnum_fail("bad value for efg");
      }
      /* this bit is from man snprintf.  */
      if (actual_length > -1 && actual_length < ARB_STRING_SIZE)
	return string_to_bstring_len(result, actual_length);
      if (actual_length > -1)   /* glibc 2.1 */ 
/* 	size = actual_length+1; /\* precisely what is needed *\/ */
        phpnum_fail("Arbitrary constant not large enough");
      else           /* glibc 2.0 */
        phpnum_fail("Arbitrary constant not large enough");
/* 	size *= 2;  /\* twice the old size *\/ */
/*       result = (char *)GC_MALLOC_ATOMIC(size); */
    }
  } else { //long
    long lval = BELONG_TO_LONG(a);
    /* same game as above */
    while (1) {
      actual_length = snprintf(result, ARB_STRING_SIZE, "%ld", lval);
      if (actual_length > -1 && actual_length < ARB_STRING_SIZE)
	return string_to_bstring_len(result, actual_length);
      if (actual_length > -1) 
/* 	size = actual_length+1;  */
        phpnum_fail("Arbitrary constant not large enough");
      else
/* 	size *= 2; */
/*      result = (char *)GC_MALLOC_ATOMIC(size); */
        phpnum_fail("Arbitrary constant not large enough");
    }
  }
  phpnum_fail("Reached end of phpnum_to_string unexpectedly.");
}

obj_t string_to_long_phpnum(char *str) {
  long lval;
  int scanfretval = sscanf(str, "%ld", &lval);

  if (!scanfretval || scanfretval == EOF) {
    phpnum_fail("Failed to read a long.");
  } else {
    return LONG_TO_BELONG(lval);
  }
}

obj_t string_to_float_phpnum(char *str) {
  double dval;
  int scanfretval = sscanf(str, "%lf", &dval); 
  // zend_strtod can easily be grabbed and stuck in this dir if float
  // reading problems ever show up.  (it's not their code anyway).
  // just rename the one function to string-to-double, add the file to
  // the Makefile, and uncomment this line (and comment the rest of
  // this function).
  //  dval = string_to_double(str, NULL);
  if (!scanfretval || scanfretval == EOF) {
    phpnum_fail("Failed to read a float.");
  } else {
    return DOUBLE_TO_REAL(dval);
  }
}

/* obj_t phpnum_clone(obj_t a) { */
/*   obj_t result = (obj_t )GC_MALLOC_ATOMIC(sizeof(phpnum)); */
/*   result->type = a->type; */
/*   if (a->type == DOUBLE_TYPE) { */
/*     result->value.dval = REAL_TO_DOUBLE(a); */
/*   } else { */
/*     result->value.lval = BELONG_TO_LONG(a); */
/*   } */
/*   return result; */
/* } */



/* int phpnum_hashnumber(obj_t a) { */
/*    //it's actually always going to be a long, per php-hash... */
/*   return (phpnum_to_long(a) & 0x1fffffff); */
/* } */



/* BGL_EXPORTED_DECL obj_t  phpnum_fail(char *reason) { */
/*    fprintf(stderr, "Arithmetic error -- %s!!\n", reason);  */
/*    return (obj_t)NULL; */
/* } */




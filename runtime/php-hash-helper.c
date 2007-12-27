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
#include <bigloo.h>
#include "opaque-math.h"

#ifdef PCC_MINGW
typedef int u_int32_t;
typedef char u_int8_t;
#endif

int is_numeric(char *str, int length)
{
  register char *tmp=str;
 
  if (*tmp=='-') { 
    tmp++; 
  } 
  if ((*tmp>='0' && *tmp<='9')) { /* possibly a numeric index */ 
    char *end=str+length;  /* this was length-1, but I don't understand why. */
    unsigned long idx;
    
    if (*tmp++=='0' && length>1) { /* don't accept numbers with leading zeros */ 
/*       fprintf(stderr, "1bailing on %s\n", str); */
      return 0;
    }
    while (tmp<end) { 
      if (!(*tmp>='0' && *tmp<='9')) { 
	break; 
      } 
      tmp++; 
    }
    if (tmp==end && *tmp=='\0') { /* a numeric index */ 
      return 1;
      if (*str=='-') {
	idx = strtol(str, NULL, 10);
	if (idx != PHP_LONGMIN) {
	  return 1;
	}
      } else {
	idx = strtol(str, NULL, 10);
	if (idx != PHP_LONGMAX) {
	  return 1;
	}
      }
    }
  }
/*   fprintf(stderr, "2bailing on %s\n", str); */
  return 0;
}

/* int main(foo) { */
/*   is_numeric("16", 2); */
/* } */

int php_string_hash_number1(char *string)
{
   char c;
   int result = 0;

   while( (c = *string++) )
      result += (result << 3) + (int)c;

   return (result & MAXFIXNUM);
}




/*
 * 32 bit magic FNV-1a prime
 */
#define FNV_32_PRIME ((unsigned int)0x01000193)

#define FNV1_32A_INIT ((unsigned int)0x811c9dc5)
#define MASK_24 (((u_int32_t)1<<24)-1)	/* i.e., (u_int32_t)0xffffff */

// FNV-1a string hash, adapted from http://www.isthe.com/chongo/tech/comp/fnv/
int php_string_hash_number(char *str)
{
  unsigned char *s = (unsigned char *)str;
  unsigned int hval = FNV1_32A_INIT;

  while (*s) {

    /* xor the bottom with the current octet */
    hval ^= (unsigned int)*s++;

    /* multiply by the 32 bit FNV magic prime mod 2^32 */
#if defined(NO_FNV_GCC_OPTIMIZATION)
	hval *= FNV_32_PRIME;
#else
	hval += (hval<<1) + (hval<<4) + (hval<<7) + (hval<<8) + (hval<<24);
#endif
  }

  /* return our new hash value, XOR folded to 24 bits so that it fits
     nicely in a bigloo fixnum */
  return (hval>>24) ^ (hval & MASK_24);
}

#define FNV_32A_OP(hash, octet) \
    (((u_int32_t)(hash) ^ (u_int8_t)(octet)) * FNV_32_PRIME)

int whoop_obj_hash_number( obj_t obj ) {
  return ((int)((long)(CREF( obj )) >> TAG_SHIFT));
}

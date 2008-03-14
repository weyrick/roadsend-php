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
#include <string.h>
#include <ctype.h>

#define MIN(a, b)  (((a)<(b))?(a):(b))

int binary_strcmp(char *s1, int len1, char *s2, int len2)
{
	int rval;
	
	rval = memcmp(s1, s2, MIN(len1, len2));
	if (!rval) {
		return (len1 - len2);
	} else {
		return rval;
	}
}

/* roadsend note: this is from glibc: string/strstr.c under LGPL
   it has been modified to check string length instead of NULL
   to accomodate binary strings */

/*
 * My personal strstr() implementation that beats most other algorithms.
 * Until someone tells me otherwise, I assume that this is the
 * fastest implementation of strstr() in C.
 * I deliberately chose not to comment it.  You should have at least
 * as much fun trying to understand it, as I had to write it :-).
 *
 * Stephen R. van den Berg, berg@pool.informatik.rwth-aachen.de	*/
typedef unsigned char chartype;

char *
re_strstr (phaystack, hslen, pneedle, nlen)
     const char *phaystack;
     int hslen;
     const char *pneedle;
     int nlen;
{
  const unsigned char *haystack, *needle;
  chartype b;
  const unsigned char *rneedle;
  register int ih = hslen;
  register int in = nlen;

  haystack = (const unsigned char *) phaystack;

  b = *(needle = (const unsigned char *) pneedle);
  
  chartype c;
  haystack--;		/* possible ANSI violation */

  {
    chartype a;
    do {
      a = *++haystack;
      ih--;
      if (ih < 0)
	goto ret0;
    } while (a != b);
  }
  

  c = *++needle;
  in--;
  if (in <= 0)
    goto foundneedle;
  ++needle;
  in--;
  goto jin;
  
  for (;;)
    {
      {
	chartype a;
	if (0)
	jin:{
	    ih--;
	    if ((a = *++haystack) == c)
	      goto crest;
	  }
	else {
	  ih--;
	  a = *++haystack;
	}
	do
	  {
	    for (; a != b; a = *++haystack, ih--)
	      {
		if (ih < 0)
		  goto ret0;
		ih--;
		if ((a = *++haystack) == b)
		  break;
		if (ih < 0)
		  goto ret0;
	      }
	    ih--;
	  }
	while ((a = *++haystack) != c);
      }
    crest:
      {
	chartype a;
	int rin = in;
	{
	  const unsigned char *rhaystack;
	  ih++;
	  if (*(rhaystack = haystack-- + 1) == (a = *(rneedle = needle)))
	    do
	      {
		if (in <= 0)
		  goto foundneedle;
		if (*++rhaystack != (a = *++needle)) {
		  in--;
		  break;
		}
		in--;
		if (in <= 0)
		  goto foundneedle;
		in--;
	      }
	    while (*++rhaystack == (a = *++needle));
	  needle = rneedle;	/* took the register-poor aproach */
	}
	if (in <= 0)
	  break;
	in = rin;
	
      }
    }
foundneedle:
  return (char *) haystack;
ret0:
  return 0;
}

/* case insensitive version. essentially a binary safe strcasestr */
char *
re_stristr (phaystack, hslen, pneedle, nlen)
     const char *phaystack;
     int hslen;
     const char *pneedle;
     int nlen;
{
  const unsigned char *haystack, *needle;
  chartype b;
  const unsigned char *rneedle;
  register int ih = hslen;
  register int in = nlen;

  haystack = (const unsigned char *) phaystack;

  b = tolower(*(needle = (const unsigned char *) pneedle));
  
  chartype c;
  haystack--;		/* possible ANSI violation */

  {
    chartype a;
    do {
      a = *++haystack;
      ih--;
      if (ih < 0)
	goto ret0;
    } while (tolower(a) != b);
  }
  

  c = tolower(*++needle);
  in--;
  if (in <= 0)
    goto foundneedle;
  ++needle;
  in--;
  goto jin;
  
  for (;;)
    {
      {
	chartype a;
	if (0)
	jin:{
	    ih--;
	    a = tolower(*++haystack);
	    if (a == c)
	      goto crest;
	  }
	else {
	  ih--;
	  a = tolower(*++haystack);
	}
	do
	  {
	    for (; a != b; a = tolower(*++haystack), ih--)
	      {
		if (ih < 0)
		  goto ret0;
		ih--;
		a = tolower(*++haystack);
		if (a == b)
		  break;
		if (ih < 0)
		  goto ret0;
	      }
	    ih--;
	    a = tolower(*++haystack);
	  }
	while (a != c);
      }
    crest:
      {
	chartype a;
	int rin = in;
	{
	  const unsigned char *rhaystack;
	  ih++;
	  if (*(rhaystack = haystack-- + 1) == (a = *(rneedle = needle)))
	    do
	      {
		if (in <= 0)
		  goto foundneedle;
		a = tolower(*++needle);
		in--;
		if (tolower(*++rhaystack) != a)
		  break;
		if (in <= 0)
		  goto foundneedle;
		a = tolower(*++needle);
		in--;
	      }
	    while (tolower(*++rhaystack) == a);
	  needle = rneedle;	/* took the register-poor aproach */
	}
	if (in <= 0)
	  break;
	in = rin;
	
      }
    }
foundneedle:
  return (char *) haystack;
ret0:
  return 0;
}



// this assume various string/length checks have been done
// before the call on the scheme side (see utils.scm)
int re_strpos(obj_t haystack, obj_t needle, unsigned int offset, int cs) {

  char *result, *h;
  int hlen;

  if (offset) {
    h = BSTRING_TO_STRING(haystack) + offset;
    hlen = STRING(haystack).length - offset;
  }
  else {
    h = BSTRING_TO_STRING(haystack);
    hlen = STRING(haystack).length;
  }

  result = (cs) ? re_strstr(h, hlen, BSTRING_TO_STRING(needle), STRING(needle).length) : 
    re_stristr(h, hlen, BSTRING_TO_STRING(needle), STRING(needle).length);

  if (result) {
    return (int)(result-h) + offset;
  }
  else {
    return -1;
  }

}

/* this is a workaround for a bigloo problem. manuel has been notified, get
   rid of this when we require the next release with a fix (3.0d?) */
BGL_RUNTIME_DEF
obj_t
strport_bin_flush( obj_t port ) {
   obj_t res;

   if( OUTPUT_STRING_PORT(port).buffer ) {
      OUTPUT_STRING_PORT(port).buffer[ OUTPUT_STRING_PORT(port).offset ] = 0;
      res = string_to_bstring_len( OUTPUT_STRING_PORT(port).buffer,
                                   OUTPUT_STRING_PORT(port).offset );
      OUTPUT_STRING_PORT(port).buffer[ 0 ] = 0;
      OUTPUT_STRING_PORT(port).offset = 0;
      
      return res;
   } else {
      return string_to_bstring( "" );
   }
}



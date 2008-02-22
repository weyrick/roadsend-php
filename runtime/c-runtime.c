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

// this assume various string/length checks have been done
// before the call on the scheme side (see utils.scm)
int pcc_strpos(const char *haystack, const char* needle, unsigned int offset, int cs) {

  char *result, *h;

  if (offset) {
    h = haystack + offset;
  }
  else {
    h = haystack;
  }

  result = (cs) ? strstr(h, needle) : strcasestr(h, needle);

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



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
/* #include "c-runtime.h" */

/* #define FLONUM_LEN  32 */
/* #define PRECISION   14 /\* in php this is an ini settings *\/ */

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


/*---------------------------------------------------------------------*/
/*    obj_t                                                            */
/*    strport_flush ...                                                */
/*    -------------------------------------------------------------    */
/*    On flush un string port binary safe mon cherie.                  */
/*---------------------------------------------------------------------*/
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


/* //least power of two greater than x */
/* unsigned clp2(unsigned x) { */
/*    x = x - 1; */
/*    x = x | (x >> 1); */
/*    x = x | (x >> 2); */
/*    x = x | (x >> 4); */
/*    x = x | (x >> 8); */
/*    x = x | (x >>16); */
/*    return x + 1; */
/* }  */


/* obj_t php_string_reappend( obj_t s1, obj_t s2, int allocated_size_of_s1 ) //XXX allocated_size_of_s1 is too small because of STRING_SIZE */
/*      //XXX the hashtable scheme side should really be weak, to prevent memory leaks */
/* { */
/*    int l1 = STRING( s1 ).length; */
/*    int l2 = STRING( s2 ).length; */
/*    int l12 = l1 + l2; */
/*    int to_be_allocated_size = clp2 ( STRING_SIZE + l12 ); */

/*    if (to_be_allocated_size  <= allocated_size_of_s1 ) { */
/*      obj_t string = s1; */
/* #if( !defined( TAG_STRING ) ) */
/*      string->string_t.header = MAKE_HEADER( STRING_TYPE, 0 ); */
/* #endif	 */
/*      string->string_t.length = l12; */

/* /\*      memcpy( &(string->string_t.char0), &STRING_REF( s1, 0 ), l1 ); *\/ */
/*      memcpy( &((char *)(&(string->string_t.char0)))[ l1 ], &STRING_REF( s2, 0 ), l2 ); */
/*      ((char *)(&(string->string_t.char0)))[ l12 ] = '\0'; */
	
/*      return  BSTRING( string ); */
/*    } else { */
/*      obj_t string = GC_MALLOC_ATOMIC( to_be_allocated_size ); */
/* #if( !defined( TAG_STRING ) ) */
/*      string->string_t.header = MAKE_HEADER( STRING_TYPE, 0 ); */
/* #endif	 */
/*      string->string_t.length = l12; */

/*      memcpy( &(string->string_t.char0), &STRING_REF( s1, 0 ), l1 ); */
/*      memcpy( &((char *)(&(string->string_t.char0)))[ l1 ], &STRING_REF( s2, 0 ), l2 ); */
/*      ((char *)(&(string->string_t.char0)))[ l12 ] = '\0'; */
	
/*      return  BSTRING( string ); */
/*    } */

/* } */

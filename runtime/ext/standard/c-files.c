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
#include <string.h>
#include <errno.h>
#include <bigloo.h>

#define BUFFERSIZE 8192
#define MIN(a, b)  (((a)<(b))?(a):(b))

// http://www.mail-archive.com/debian-glibc@lists.debian.org/msg36705.html
/* Reads size-1 characters up to \n including any \0 cf. getline */
int fngets(char *s, int size, FILE *stream)
{
	char *p;
	int c;

	p=s,c=EOF;
	while(--size>0&&(c=getc(stream))!=EOF) {
		*p++=(char)c;
		if (c=='\n') { /* Will read '\0'. */
			break;
		}
	}
	*p='\0'; /* Always mark the end. */
	if(c==EOF) { /* Expected. */
		if(feof(stream)) {
			if(p==s) {
				return -1;
			}
		} else {
			return -1;
		}
	}
	return p-s; /* Return something meaningful. */
}

obj_t php_fgets(FILE *stream, int limit) {
   /* return a bigloo string no bigger than limit, as read by fgets */  
   /* return scheme '() on EOF */
   obj_t string;
   static char *buffer = NULL;
   int actually_read = 0;
  
   /* initialize internal buffer if we haven't yet 
      XXX: this is a bona fide one time BUFFERSIZE memory leak.  
      who cares? */
   if (buffer == NULL) {
      if ((buffer = malloc( BUFFERSIZE )) == NULL) {
	 /* out of memory */
	 return BNIL;
      }
   }
   if (limit <= BUFFERSIZE) { 
      /* in this case we can use the statically allocated buffer that
	 way we can avoid allocating a limit size string for potentially
	 small line */
      if (fngets( buffer, limit, stream ) == -1) {
	 return BNIL;
      }

      actually_read = strlen( buffer );
      string = string_to_bstring_len(buffer, actually_read);
      
   } else {
      /* don't use the static buffer, limit is too big.  We use realloc
	 because, at least on my linux/glibc2 system, it behaves really
	 nicely.  GC_REALLOC_ATOMIC behaves quadratically. */
      char *bigbuf = NULL;
      int len;

      do {
	 if ((bigbuf = realloc( bigbuf, actually_read + BUFFERSIZE )) == NULL) {
	    /* out of memory */
	    return BNIL;
	 }
	 if (fngets( bigbuf + actually_read, 
		    MIN(BUFFERSIZE, limit), stream ) == -1) {
	    /* fgets says there's nothing left to read */
	    if (actually_read > 0) {
	       /* we have read something in previous iterations */
	       break;
	    } else {
	       /* we've read nothing in this iteration, the stream is at EOF */
	       free(bigbuf);
	       return BNIL;
	    }
	 }
	 /* this is how much we read this time around */
	 len = strlen( bigbuf + actually_read );
	 /* this is ho much we've read total */
	 actually_read += len;
	 /* this is how much we've got left to read before hitting the limit */
	 limit -= len;            
      } while (!((len < (BUFFERSIZE - 1)) || /* didn't fill the buffer,
						so must be finished */
		 /* filled the buffer exactly, so must be finished */
		 *(bigbuf + actually_read - 1) == '\n')
	       /* bumped up against the user's limit */
	       && limit >= 0); 
      
      string  = string_to_bstring_len(bigbuf, actually_read);
      if (bigbuf) free(bigbuf);
   }
  
   return string;
}



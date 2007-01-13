#define NO_PATH_IS_ABS 1

/* ====================================================================
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2000-2003 The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution,
 *    if any, must include the following acknowledgment:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowledgment may appear in the software itself,
 *    if and wherever such third-party acknowledgments normally appear.
 *
 * 4. The names "Apache" and "Apache Software Foundation" must
 *    not be used to endorse or promote products derived from this
 *    software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache",
 *    nor may "Apache" appear in their name, without prior written
 *    permission of the Apache Software Foundation.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 *
 * Portions of this software are based upon public domain software
 * originally written at the National Center for Supercomputing Applications,
 * University of Illinois, Urbana-Champaign.
 */

#include "apache_multipart_buffer.h"

/*********************** internal functions *********************/

/*
  search for a string in a fixed-length byte string.
  if partial is true, partial matches are allowed at the end of the buffer.
  returns NULL if not found, or a pointer to the start of the first match.
*/
void* my_memstr(char* haystack, int haystacklen, const char* needle,
		int partial)
{
    int needlen = strlen(needle);
    int len = haystacklen;
    char *ptr = haystack;

    /* iterate through first character matches */
    while( (ptr = memchr(ptr, needle[0], len)) ) {
	/* calculate length after match */
	len = haystacklen - (ptr - (char *)haystack);

	/* done if matches up to capacity of buffer */
	if(memcmp(needle, ptr, needlen < len ? needlen : len) == 0 &&
	   (partial || len >= needlen))
	    break;

	/* next character */
	ptr++; len--;
    }

    return ptr;
}

/*
  fill up the buffer with client data.
  returns number of bytes added to buffer.
*/
int fill_buffer(multipart_buffer *self)
{
    int bytes_to_read, actual_read = 0;

    /* shift the existing data if necessary */
    if(self->bytes_in_buffer > 0 && self->buf_begin != self->buffer)
	memmove(self->buffer, self->buf_begin, self->bytes_in_buffer);
    self->buf_begin = self->buffer;

    /* calculate the free space in the buffer */
    bytes_to_read = self->bufsize - self->bytes_in_buffer;

    if (bytes_to_read >= self->r->remaining) {
        bytes_to_read = self->r->remaining - strlen(self->boundary);
#ifdef DEBUG
        ap_log_rerror(MPB_ERROR, "mozilla 0.97 hack: '%ld'", self->r->remaining);
#endif
    }

    /* read the required number of bytes */
    if(bytes_to_read > 0) {
	char *buf = self->buffer + self->bytes_in_buffer;
	ap_hard_timeout("[libapreq] multipart_buffer.c:fill_buffer", self->r);
	actual_read = ap_get_client_block(self->r, buf, bytes_to_read);
	ap_kill_timeout(self->r);

	/* update the buffer length */
	if(actual_read > 0)
	  self->bytes_in_buffer += actual_read;
    }

    return actual_read;
}

/*
  gets the next CRLF terminated line from the input buffer.
  if it doesn't find a CRLF, and the buffer isn't completely full, returns
  NULL; otherwise, returns the beginning of the null-terminated line,
  minus the CRLF.

  note that we really just look for LF terminated lines. this works
  around a bug in internet explorer for the macintosh which sends mime
  boundaries that are only LF terminated when you use an image submit
  button in a multipart/form-data form.
 */
char* next_line(multipart_buffer *self)
{
    /* look for LF in the data */
    char* line = self->buf_begin;
    char* ptr = memchr(self->buf_begin, '\n', self->bytes_in_buffer);

    /* LF found */
    if(ptr) {
	/* terminate the string, remove CRLF */
	if((ptr - line) > 0 && *(ptr-1) == '\r') *(ptr-1) = 0;
	else *ptr = 0;

	/* bump the pointer */
	self->buf_begin = ptr + 1;
	self->bytes_in_buffer -= (self->buf_begin - line);
    }

    /* no LF found */
    else {
	/* buffer isn't completely full, fail */
	if(self->bytes_in_buffer < self->bufsize)
	  return NULL;

	/* return entire buffer as a partial line */
	line[self->bufsize] = 0;
	self->buf_begin = ptr;
	self->bytes_in_buffer = 0;
    }

    return line;
}

/* returns the next CRLF terminated line from the client */
char* get_line(multipart_buffer *self)
{
    char* ptr = next_line(self);

    if(!ptr) {
	fill_buffer(self);
	ptr = next_line(self);
    }

#ifdef DEBUG
    ap_log_rerror(MPB_ERROR, "get_line: '%s'", ptr);
#endif

    return ptr;
}

/* finds a boundary */
int find_boundary(multipart_buffer *self, char *boundary)
{
    char *line;

    /* loop thru lines */
    while( (line = get_line(self)) ) {
#ifdef DEBUG
      ap_log_rerror(MPB_ERROR, "find_boundary: '%s' ?= '%s'",
		    line, boundary);
#endif

      /* finished if we found the boundary */
      if(strEQ(line, boundary))
	  return 1;
    }

    /* didn't find the boundary */
    return 0;
}

/*********************** external functions *********************/

/* create new multipart_buffer structure */
multipart_buffer *multipart_buffer_new(char *boundary, long length, request_rec *r)
{
    multipart_buffer *self = (multipart_buffer *)
	ap_pcalloc(r->pool, sizeof(multipart_buffer));

    int minsize = strlen(boundary)+6;
    if(minsize < FILLUNIT) minsize = FILLUNIT;

    self->r = r;
    self->buffer = (char *) ap_pcalloc(r->pool, minsize+1);
    self->bufsize = minsize;
    self->request_length = length;
    self->boundary = ap_pstrcat(r->pool, "--", boundary, NULL);
    self->boundary_next = ap_pstrcat(r->pool, "\n", self->boundary, NULL);
    self->buf_begin = self->buffer;
    self->bytes_in_buffer = 0;

    return self;
}

/* parse headers and return them in an apache table */
table *multipart_buffer_headers(multipart_buffer *self)
{
    table *tab;
    char *line;

    /* didn't find boundary, abort */
    if(!find_boundary(self, self->boundary)) return NULL;

    /* get lines of text, or CRLF_CRLF */
    tab = ap_make_table(self->r->pool, 10);
    while( (line = get_line(self)) && strlen(line) > 0 ) {
	/* add header to table */
	char *key = line;
	char *value = strchr(line, ':');

	if(value) {
	    *value = 0;
	    do { value++; } while(ap_isspace(*value));

#ifdef DEBUG
	    ap_log_rerror(MPB_ERROR,
			  "multipart_buffer_headers: '%s' = '%s'",
			  key, value);
#endif

	    ap_table_add(tab, key, value);
	}
	else {
#ifdef DEBUG
	    ap_log_rerror(MPB_ERROR,
			  "multipart_buffer_headers: '%s' = ''", key);
#endif

	    ap_table_add(tab, key, "");
	}
    }

    return tab;
}

/* read until a boundary condition */
int multipart_buffer_read(multipart_buffer *self, char *buf, int bytes)
{
    int len, max;
    char *bound;

    /* fill buffer if needed */
    if(bytes > self->bytes_in_buffer) fill_buffer(self);

    /* look for a potential boundary match, only read data up to that point */
    if( (bound = my_memstr(self->buf_begin, self->bytes_in_buffer,
			   self->boundary_next, 1)) )
	max = bound - self->buf_begin;
    else
	max = self->bytes_in_buffer;

    /* maximum number of bytes we are reading */
    len = max < bytes-1 ? max : bytes-1;

    /* if we read any data... */
    if(len > 0) {
	/* copy the data */
	memcpy(buf, self->buf_begin, len);
	buf[len] = 0;
	if(bound && len > 0 && buf[len-1] == '\r') buf[--len] = 0;

	/* update the buffer */
	self->bytes_in_buffer -= len;
	self->buf_begin += len;
    }

#ifdef DEBUG
    ap_log_rerror(MPB_ERROR, "multipart_buffer_read: %d bytes", len);
#endif

    return len;
}

/*
  XXX: this is horrible memory-usage-wise, but we only expect
  to do this on small pieces of form data.
*/
char *multipart_buffer_read_body(multipart_buffer *self)
{
    char buf[FILLUNIT], *out = "";

    while(multipart_buffer_read(self, buf, sizeof(buf)))
	out = ap_pstrcat(self->r->pool, out, buf, NULL);

#ifdef DEBUG
    ap_log_rerror(MPB_ERROR, "multipart_buffer_read_body: '%s'", out);
#endif

    return out;
}

/* eof if we are out of bytes, or if we hit the final boundary */
int multipart_buffer_eof(multipart_buffer *self)
{
    if( (self->bytes_in_buffer == 0 && fill_buffer(self) < 1) )
	return 1;
    else
	return 0;
}

#ifndef _APACHE_MULTIPART_BUFFER_H
#define _APACHE_MULTIPART_BUFFER_H

#include "apache_request.h"

/*#define DEBUG 1*/
#define FILLUNIT (1024 * 5)
#define MPB_ERROR APLOG_MARK, APLOG_NOERRNO|APLOG_ERR, self->r

#ifdef  __cplusplus
 extern "C" {
#endif 

typedef struct {
    /* request info */
    request_rec *r;
    long request_length;

    /* read buffer */
    char *buffer;
    char *buf_begin;
    int  bufsize;
    int  bytes_in_buffer;

    /* boundary info */
    char *boundary;
    char *boundary_next;
    char *boundary_end;
} multipart_buffer;

multipart_buffer *
    multipart_buffer_new(char *boundary, long length, request_rec *r);
table *multipart_buffer_headers(multipart_buffer *self);
int multipart_buffer_read(multipart_buffer *self, char *buf, int bytes);
char *multipart_buffer_read_body(multipart_buffer *self); 
int multipart_buffer_eof(multipart_buffer *self);

#ifdef __cplusplus
 }
#endif

#endif

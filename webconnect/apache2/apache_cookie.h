#ifndef _APACHE_COOKIE_H
#define _APACHE_COOKIE_H

#include "apache_request.h"

typedef apr_array_header_t ApacheCookieJar;

typedef struct {
    request_rec *r;
    char *name;
    apr_array_header_t *values;
    char *domain;
    char *expires;
    char *path;
    int secure;
} ApacheCookie;

#ifdef  __cplusplus
 extern "C" {
#endif 

#define ApacheCookieJarItems(arr) arr->nelts

#define ApacheCookieJarFetch(arr,i) \
((ApacheCookie *)(((ApacheCookie **)arr->elts)[i]))

#define ApacheCookieJarAdd(arr,c) \
*(ApacheCookie **)apr_array_push(arr) = c

//*(ApacheCookie **)ap_push_array(arr) = c

#define ApacheCookieItems(c) c->values->nelts

#define ApacheCookieFetch(c,i) \
((char *)(((char **)c->values->elts)[i]))

#define ApacheCookieAddn(c,val) \
    if(val) *(char **)apr_array_push(c->values) = (char *)val
//    if(val) *(char **)ap_push_array(c->values) = (char *)val    

#define ApacheCookieAdd(c,val) \
    ApacheCookieAddn(c, apr_pstrdup(c->r->pool, val))

#define ApacheCookieAddLen(c,val,len) \
    ApacheCookieAddn(c, apr_pstrndup(c->r->pool, val, len))

ApacheCookie *ApacheCookie_new(request_rec *r, ...);
ApacheCookieJar *ApacheCookie_parse(request_rec *r, const char *data);
char *ApacheCookie_as_string(ApacheCookie *c);
char *ApacheCookie_attr(ApacheCookie *c, char *key, char *val);
char *ApacheCookie_expires(ApacheCookie *c, char *time_str);
void ApacheCookie_bake(ApacheCookie *c);

#ifdef __cplusplus
 }
#endif

#define APC_ERROR APLOG_MARK, APLOG_NOERRNO|APLOG_ERR, c->r

#endif

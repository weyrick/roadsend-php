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

#include <time.h>

/* this is to keep the linker from saying 'multiple definitions of
   ap_os_is_path_absolute'.  I just edited apache's os.h to add an
   ifndef so we can disable the definition.  Maybe not the right
   thing, but expedient. */
#define NO_PATH_IS_ABS 1

#include "httpd.h"
#include "http_config.h"
#include "http_log.h"
#include "http_core.h"
#include "http_main.h"
#include "http_protocol.h"
#include "http_request.h"
#include "multithread.h"

#include <sys/stat.h>
#include <unistd.h>

#include <bigloo.h>

#include "apache_request.h"
#include "apache_cookie.h"

// XXX real version here
#define ROADSEND_MOD_VER "1.8.1"

#define WEBAPP_MAGIC_TYPE "application/x-pcc-webapp"
#define PCC_MAGIC_TYPE "application/x-httpd-pcc"

static mutex *mod_pcc_mutex = NULL;

// ** EXECUTION **
static int handle_execute(request_rec *r);
static int handle_webapp(request_rec *r);
static int general_handler(request_rec *r, int is_webapp);

// ** SERVER/.htaccess CONFIG FILES **
static const char *pcc_apache_value_handler(cmd_parms *cmd, void *dummy, char *arg1, char *arg2);
static const char *pcc_apache_flag_handler(cmd_parms *cmd, void *dummy, char *arg1, char *arg2);

// ** WEBAPPS **
static const char *do_webapp_exts(cmd_parms *cmd, void *conf, char *ext);
static int match_extension(char *filename, char *ext);
static int try_file_in_lib(request_rec *r);
static const char *mount_webapp(cmd_parms *cmd, void *conf, char *lib, char *index);
static int check_for_webapp(request_rec *r);
static int try_lib_index(request_rec *r);

// imported from scheme
extern int run_url(ApacheRequest *);
extern int run_webapp(ApacheRequest *r, char *webapp_lib, char *filename, char *directory, char *index_file);
extern char* pcc_get_ini_string(char *key);
extern int pcc_get_ini_num(char *key);
extern int handle_config_directive(char *arg1, char *arg2);
extern int process_upload(ApacheUpload *upload);

extern int phpoo_initialize(int, char **, char **);

module MODULE_VAR_EXPORT pcc_module;

// for config files
typedef struct pcc_cfg {
    
    int cmode;                  /* Environment to which record applies (directory,
				 * server, or combination).
				 */
#define CONFIG_MODE_SERVER    1
#define CONFIG_MODE_DIRECTORY 2
#define CONFIG_MODE_COMBO     3     /* Shouldn't ever happen. I don't even 
				       know why it's here.*/
    
    char *loc;                  /* Location to which this record applies. */
    
    char *include_path;         /* include path override in .htaccess */
    char *webapp_lib;           /* current web library to use for app */
    char *webapp_index;         /* if we should use an auto index, this is the page */

#define MAX_EXTS 30
    
    char *webapp_exts[MAX_EXTS];   /* which extensions we look for in web apps */
    int num_exts;
    int custom_exts;
    
} pcc_cfg;


/* Pick our per-dir config out of the wreckage */
static pcc_cfg *our_dconfig(request_rec *r)
{
  return (pcc_cfg *) ap_get_module_config(r->per_dir_config, &pcc_module);
}

/* /\* Per-server  *\/ */
/* static pcc_cfg *our_sconfig(server_rec *s) */
/* { */
/*     return (pcc_cfg *) ap_get_module_config(s->module_config, &pcc_module); */
/* } */

/* /\* Per-request *\/ */
/* static pcc_cfg *our_rconfig(request_rec *r) */
/* { */
/*     return (pcc_cfg *) ap_get_module_config(r->request_config, &pcc_module); */
/* } */


static void pcc_init(server_rec *s, pool *p)
{
  ap_add_version_component("Roadsend PCC/" ROADSEND_MOD_VER);
  if (!mod_pcc_mutex) {
    mod_pcc_mutex = ap_create_mutex(NULL);
  }
/*   fprintf(stderr, "Initmewoo!\n"); */
/*   fflush(stderr); */
}


void pcc_driver(request_rec *r) 
{
  static int initialized = 0;
  char *argv[] = { "mod_pcc", 0 };
  char *envp[] = { 0 };
   
  if (!initialized) {
     phpoo_initialize(1, argv , envp);     
     initialized = 1;
  } 
}

/* int main() { */
/*   pcc_driver((request_rec *)NULL); */
/*   printf("initialized\n"); */
/*   { */
/*     extern int slub_run_url(char *); */
/*     slub_run_url("wakka wakka wakka"); */
/*   } */
/* } */



static int general_handler(request_rec *r, int is_webapp)
{
  int retval;
  pcc_cfg *cfg;

  int status, file_uploads;
  ApacheRequest *req;
  ApacheUpload *upload;

  ap_acquire_mutex(mod_pcc_mutex);

  // apache request object
  req = ApacheRequest_new(r);
  
  
  // this adds vars to the subprocess_env we will use for _SERVER
  //ap_add_common_vars(r);
  //ap_add_cgi_vars(r);
  
  /* initialize chunking for reading post request bodies */
  if ((retval = ap_setup_client_block(r, REQUEST_CHUNKED_ERROR))) {
    ap_release_mutex(mod_pcc_mutex);
    return retval;
  }

  
  pcc_driver(r);


  cfg = our_dconfig(r);

/*   fprintf(stderr, "before the storem 1.0, cfg: %p\n", cfg); */
/*   fflush(stderr); */

  // XXX eventually we should handle more key/values
  if (cfg->include_path) { 
     handle_config_directive("include_path", cfg->include_path);
  } 

/*   fprintf(stderr, "before the storem 1.1\n"); */
/*   fflush(stderr); */

/* /\*   fprintf(stderr, "mime type %s\n", r->content_type); *\/ */
/* /\*   fflush(stderr); *\/ */

  // FILE UPLOADS
  file_uploads = pcc_get_ini_num("file_uploads");

/*   fprintf(stderr, "before the storem 1.2\n"); */
/*   fflush(stderr); */

  if (file_uploads == 0)
     req->disable_uploads = 1;
  req->temp_dir = pcc_get_ini_string("upload_tmp_dir");
  req->post_max = pcc_get_ini_num("upload_max_filesize");

/*   fprintf(stderr, "before the storem 1.3\n"); */
/*   fflush(stderr); */

  // GET/POST
  if((status = ApacheRequest_parse(req)) != OK) {
     char *errmsg = (char *)ap_table_get(r->notes, "error-notes");
     ap_log_rerror(APLOG_MARK, APLOG_ERR|APLOG_NOERRNO, r,
		   "file upload error: %s", errmsg);
     ap_release_mutex(mod_pcc_mutex);
     return status;
  }

/*   fprintf(stderr, "before the storem 1.4\n"); */
/*   fflush(stderr); */

  // UPLOAD
  upload = ApacheRequest_upload(req);
/*   fprintf(stderr, "before the storem 1.5\n"); */
/*   fflush(stderr); */

  if (upload) {
     // hook to scheme
     process_upload(upload);
  }

/*   fprintf(stderr, "before the storem 2\n"); */
/*   fflush(stderr); */


  
  if (is_webapp) {

/*     fprintf(stderr, "before the storem zowie\n"); */
/*     fflush(stderr); */

    //    char *uri_full_path = ap_make_full_path(r->pool, ap_document_root(r), r->uri);
    int file_len = strlen(r->filename);
    int loc_len = strlen(cfg->loc);

    
/*     fprintf(stderr, "sloc: %s, dloc: %s\n", r->server->path, cfg->loc); */
    if (*(cfg->loc + loc_len - 1) == '/') {
      loc_len--;
    }
    if (file_len < loc_len) {
      ap_log_rerror(APLOG_MARK, APLOG_ERR|APLOG_NOERRNO, r,
		    "webapp path too short: %s", r->filename);
      ap_release_mutex(mod_pcc_mutex);
      return DECLINED;
    }
    
    retval = run_webapp(req, cfg->webapp_lib, ap_pstrdup(r->pool, r->filename + loc_len), ap_pstrdup(r->pool, cfg->loc), cfg->webapp_index);
/* 			ap_pstrcat(r->pool, scfg->loc, cfg->loc, NULL)); */
  } else {

/*     fprintf(stderr, "before the storem 3\n"); */
/*     fflush(stderr); */

/*     fprintf(stderr, "sloc: %s, dloc: %s\n", r->server->path, cfg->loc); */
    retval = run_url(req);

/*     fprintf(stderr, "before the storem 3.5\n"); */
/*     fflush(stderr); */

  }
  ap_release_mutex(mod_pcc_mutex);
  return retval;
}

static int handle_execute(request_rec *r) 
{
/*   fprintf(stderr, "handling execute, dirconfig: %p!\n", r->per_dir_config); */
/*   fflush(stderr); */
  return general_handler(r, 0);
}

static int handle_webapp(request_rec *r) 
{
  return general_handler(r, 1);
}


static void *pcc_create_per_dir(pool *p, char *dirspec)
{
   
   pcc_cfg *cfg;
   char *dname = dirspec;

   // ap_pcalloc will let apache cleanup the memory
   cfg = (pcc_cfg *)ap_pcalloc(p, sizeof(pcc_cfg));

   cfg->include_path = 0;
   cfg->webapp_lib = 0;
   cfg->webapp_index = 0;

   // default web app extension   
   cfg->webapp_exts[0] = ap_pstrdup(p, ".php");
   cfg->num_exts = 1;
   cfg->custom_exts = 0;
   
   cfg->cmode = CONFIG_MODE_DIRECTORY;
   dname = (dname != NULL) ? dname : "";
   cfg->loc = ap_pstrdup(p, dname);//ap_pstrcat(p, "DIR(", dname, ")", NULL);

/*    fprintf(stderr, "returning a cfg from create_per_dir: %p\n", cfg); */
/*    fflush(stderr); */

   return (void *)cfg;
   
}

/* For reasons unknown, this routine MUST NOT modify any of its
   arguments. */
static void *pcc_merge_per_dir(pool *p, void *parent_conf, void *newloc_conf)
{

    int i;
    
   // ap_pcalloc will let apache cleanup the memory
   pcc_cfg *merged_config = (pcc_cfg *)ap_pcalloc(p, sizeof(pcc_cfg));
   pcc_cfg *pconf = (pcc_cfg *)parent_conf;
   pcc_cfg *nconf = (pcc_cfg *)newloc_conf;


   /* some things get copied directly from the more-specific record,
      rather than getting merged */
   merged_config->loc = ap_pstrdup(p, nconf->loc);
   if (nconf->webapp_lib) {
/*      fprintf(stderr, "webapp lib a: %s\n", nconf->webapp_lib); */
     merged_config->webapp_lib = nconf->webapp_lib;
     merged_config->webapp_index = nconf->webapp_index;
   } else {
/*      fprintf(stderr, "webapp lib b: %s\n", pconf->webapp_lib); */
     merged_config->webapp_lib = pconf->webapp_lib;
     merged_config->webapp_index = pconf->webapp_index;
   }

   /* others get ORed in */
   if (nconf->include_path && pconf->include_path) {
     char *s = ap_pcalloc(p, 1 + strlen(nconf->include_path) + 
			  strlen(nconf->include_path));
     sprintf(s, "%s:%s", nconf->include_path, pconf->include_path); 
     merged_config->include_path = s;
   } else if (pconf->include_path) {
      merged_config->include_path = ap_pstrdup(p, pconf->include_path);      
   } else if (nconf->include_path) {
      merged_config->include_path = ap_pstrdup(p, nconf->include_path);      
   } else {
      merged_config->include_path = 0;
   }
   merged_config->cmode = CONFIG_MODE_DIRECTORY;

   // use more specific, dump the parent
   for (i = 0; i < nconf->num_exts; i++) {
       merged_config->webapp_exts[i] = ap_pstrdup(p, nconf->webapp_exts[i]);
   }
   merged_config->num_exts = nconf->num_exts;
   merged_config->custom_exts = nconf->custom_exts;

/*    fprintf(stderr, "returning a merged cfg from merge_per_dir: %p\n", merged_config); */
/*    fflush(stderr); */
   
   return (void *)merged_config;
   
}


/* /\* just overrides some behavior from the per-dir stuff *\/ */
/* static void *pcc_create_per_server(pool *p, char *dirspec) */
/* { */
/*    pcc_cfg *cfg = (pcc_cfg *)pcc_create_per_dir(p, dirspec); */
/*    char *dname = dirspec; */

/*    cfg->cmode = CONFIG_MODE_SERVER; */
/*    dname = (dname != NULL) ? dname : ""; */
/*    cfg->loc = ap_pstrdup(p, dname); */
/*      //ap_pstrcat(p, "SVR(", dname, ")", NULL); */

/*    return (void *)cfg; */
/* } */

/* /\* also just overrides some behavior from the per-dir stuff *\/ */
/* static void *pcc_merge_per_server(pool *p, void *parent_conf, void *newloc_conf) */
/* { */
/*   pcc_cfg *merged_config = (pcc_cfg *)pcc_merge_per_dir(p, parent_conf, newloc_conf); */
/*   merged_config->cmode = CONFIG_MODE_SERVER; */
/*   return (void *)merged_config; */
/* } */


static const char *pcc_apache_value_handler(cmd_parms *cmd, void *conf, char *arg1, char *arg2)
{

   pcc_cfg *cfg = (pcc_cfg*)conf; 
   
/*    fprintf(stderr, "pcc_apache_value_handler %s, %s\n", arg1, arg2); */
   if (!strcasecmp(arg1, "include_path")) {
     cfg->include_path = ap_pstrdup(cmd->pool, arg2);
   } 

   return NULL;
}

static const char *pcc_apache_flag_handler(cmd_parms *cmd, void *cfg, char *arg1, char *arg2)
{

   char bv[2];

   if (!strcasecmp(arg2, "On") ||
       (arg2[0] == '1' && arg2[1] == '\0')) {
      bv[0] = '1';
   } else {
      bv[0] = '0';
   }
   bv[1] = 0;

   return pcc_apache_value_handler(cmd, cfg, arg1, bv);

}


// add to web app extension list
// this is called iteratively by apache for each value in the pcc_webapp_exts list
static const char *do_webapp_exts(cmd_parms *cmd, void *conf, char *ext) {
    
    pcc_cfg *cfg = (pcc_cfg*)conf;    
    
    if ( (strlen(ext) < 2) ||
	 (*ext != '.') ||
	 (cfg->num_exts == MAX_EXTS) )
	return NULL;
    
    // if they haven't customize yet, remove the first one
    // so we only get their list and not our default
    if (cfg->custom_exts == 0) {
	// note we don't free the default extension, apache should handle this
	cfg->num_exts = 0;
	cfg->custom_exts = 1;
    }

    cfg->webapp_exts[cfg->num_exts] = ap_pstrdup(cmd->pool, ext);
    cfg->num_exts++;
    
    return NULL;
    
}

static int match_extension(char *filename, char *ext) {

    char *pos;
    
    if (strlen(filename) <= strlen(ext)) {
	return 0;
    }

    pos = strstr(filename, ext);
    if (pos && (pos == (filename+(strlen(filename)-strlen(ext))))) {
	return 1;
    }
    else {
	return 0;
    }
    
}

// run through list of extensions, check for match
static int try_file_in_lib(request_rec *r) {

    int i;
    pcc_cfg *cfg = our_dconfig(r);

    if (!cfg)
	return 0;
    
    if (cfg->num_exts == 0 )
	return 0;

    for (i = 0; i < cfg->num_exts; i++) {
	if (match_extension(r->filename, cfg->webapp_exts[i]))
	    return 1;
    }

    return 0;
    
}


static const char *mount_webapp(cmd_parms *cmd, void *conf, char *lib, char *index)
{
  pcc_cfg *cfg = (pcc_cfg*)conf;
  
  //fprintf(stderr, "mounting a webapp, %s\n", lib);
  cfg->webapp_lib = ap_pstrdup(cmd->pool, lib);

  if (index) {
    cfg->webapp_index = ap_pstrdup(cmd->pool, index);
  }
  
  return NULL;
}


/* check_for_webapp() is run in the fixup stage to check and see if
   the requested file is within a webapp mount point. If so, the
   request's real content type is noted in r->notes, then is set to
   WEBAPP_MAGIC_TYPE. */
static int check_for_webapp(request_rec *r)
{


  

  pcc_cfg *cfg = our_dconfig(r); 
    //(pcc_cfg *)ap_get_module_config(r->per_dir_config, &pcc_module);
    //our_dconfig(r); 
/*   fprintf(stderr, "checking for webapp, dirconfig: %p, size: %d, atime %d, mtime %d, ctime %d\n", r->per_dir_config, r->finfo.st_size, r->finfo.st_atime, r->finfo.st_mtime, r->finfo.st_ctime); */
/*   fprintf(stderr, "query: %s, port: %d, is_init: %d, dns_looked: %d, dns_resolved: %d\n", r->parsed_uri.query, r->parsed_uri.port, r->parsed_uri.is_initialized, r->parsed_uri.dns_looked_up, r->parsed_uri.dns_resolved); */
/*   fprintf(stderr, "our dconfig is: %p\n", cfg); */
/*   fflush(stderr); */

   ap_log_rerror(APLOG_MARK, APLOG_ERR|APLOG_NOERRNO, r,
  	"request: %s webapp lib here: %s", r->filename, cfg->webapp_lib);
      
  if (cfg->webapp_lib) {
      
    /* check to see if this is already typed as a webapp to prevent
       recursively calling the webapp handler  */
    if (r->content_type &&
	!strcmp(r->content_type, WEBAPP_MAGIC_TYPE)) {
      return DECLINED;
    }

    // if we *don't* match extension on the end, we leave alone and let
    // apache process it. otherwise, we get it from lib
    if (try_file_in_lib(r) || try_lib_index(r))
	r->content_type = WEBAPP_MAGIC_TYPE;
    else
	return DECLINED;

  }
  return OK;
}

/* if the file does not exist, or if webapp dir indexing is on and the
   file is a dir, reuturn 1.  Otherwise return 0.*/
static int try_lib_index(request_rec *r)
{
    pcc_cfg *cfg = our_dconfig(r);
    struct stat s;  
  
    if ( stat(r->filename, &s) != 0 ) {  
	return 0;
    }
    if ( S_ISDIR(s.st_mode) && cfg->webapp_index ) {
	return 1;
    }
    
    return 0;
}


/* Dispatch list of content handlers */
static const handler_rec pcc_handlers[] = { 
   { PCC_MAGIC_TYPE, handle_execute },
   { WEBAPP_MAGIC_TYPE, handle_webapp },
   { NULL, NULL }
};

static const command_rec pcc_commands[] =
{

        {"php_value",		pcc_apache_value_handler, NULL, OR_OPTIONS, TAKE2, "Value Modifier"},
	{"php_flag",		pcc_apache_flag_handler, NULL, OR_OPTIONS, TAKE2, "Flag Modifier"},
	{"pcc_value",		pcc_apache_value_handler, NULL, OR_OPTIONS, TAKE2, "Value Modifier"},
	{"pcc_flag",		pcc_apache_flag_handler, NULL, OR_OPTIONS, TAKE2, "Flag Modifier"},	
	{"pcc_webapp",		mount_webapp, NULL, OR_OPTIONS, TAKE12, "Mount a webapp"},
	{"pcc_webapp_exts",     do_webapp_exts, NULL, OR_FILEINFO, ITERATE, "Modify extension list for web app"},
	{NULL}
};


module MODULE_VAR_EXPORT pcc_module = {
    STANDARD_MODULE_STUFF,
    pcc_init,		     /* module initializer                  */
    pcc_create_per_dir,	     /* create per-dir    config structures */
    pcc_merge_per_dir,	     /* merge  per-dir    config structures */
    NULL,   /* create per-server config structures */
    NULL,    /* merge  per-server config structures */
    pcc_commands,	     /* table of config file commands       */
    pcc_handlers,	     /* [#8] MIME-typed-dispatched handlers */
    NULL,		     /* [#1] URI to filename translation    */
    NULL,		     /* [#4] validate user id from request  */
    NULL,		     /* [#5] check if the user is ok _here_ */
    NULL,		     /* [#3] check access by host address   */
    NULL,		     /* [#6] determine MIME type            */
    check_for_webapp,	     /* [#7] pre-run fixups                 */
    NULL,		     /* [#9] log a transaction              */
    NULL,		     /* [#2] header parser                  */
    NULL,		     /* child_init                          */
    NULL,		     /* child_exit                          */
    NULL		     /* [#0] post read-request              */
#ifdef EAPI
   ,NULL,		     /* EAPI: add_module                    */
    NULL,		     /* EAPI: remove_module                 */
    NULL,		     /* EAPI: rewrite_command               */
    NULL		     /* EAPI: new_connection                */
#endif
};




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

#include <sys/types.h>

#include "httpd.h"
#include "http_config.h"
#include "http_core.h"
#include "http_log.h"
#include "http_main.h"
#include "http_protocol.h"
#include "http_request.h"
#include "util_script.h"
#include "http_connection.h"

#include "apr_strings.h"

#include <stdio.h>

#include <sys/stat.h>
#include <unistd.h>

#include <bigloo.h>

#include "apache_request.h"
#include "apache_cookie.h"

// XXX real version here
#define ROADSEND_MOD_VER "1.8.1"

#define WEBAPP_MAGIC_TYPE "application/x-pcc-webapp"
#define PCC_MAGIC_TYPE "application/x-httpd-pcc"

#define CONFIG_MODE_SERVER    1
#define CONFIG_MODE_DIRECTORY 2
#define CONFIG_MODE_COMBO     3     /* Shouldn't ever happen. I don't even 
				       know why it's here.*/


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
extern int run_url(ApacheRequest *r);
extern int run_webapp(ApacheRequest *r, char *webapp_lib, char *filename, char *directory, char *index_file);
extern char* pcc_get_ini_string(char *key);
extern int pcc_get_ini_num(char *key);
extern int handle_config_directive(char *arg1, char *arg2);
extern int process_upload(ApacheUpload *upload);

extern int phpoo_initialize(int, char **, char **);

module AP_MODULE_DECLARE_DATA pcc_module;

// for config files
typedef struct pcc_cfg {
    
    int cmode;                  /* Environment to which record applies (directory,
				 * server, or combination).
				 */
    
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


static int pcc_startup(apr_pool_t *pconf, apr_pool_t *plog, apr_pool_t *ptemp, server_rec *s)
{

   void *data = NULL;
   const char *key = "post_cfg";
   char *argv[] = { "mod_pcc2", 0 };
   char *envp[] = { 0 };
   
   apr_pool_userdata_get(&data, key, s->process->pool);
   if (data == NULL) {
      apr_pool_userdata_set((const void *)1, key, apr_pool_cleanup_null, s->process->pool);
      return OK;
   }
   
   //ap_log_error(APLOG_MARK, APLOG_ERR|APLOG_NOERRNO,  0, NULL, "pcc startup");

   ap_add_version_component(pconf, "Roadsend PCC/" ROADSEND_MOD_VER);

   //ap_log_error(APLOG_MARK, APLOG_ERR|APLOG_NOERRNO,  0, NULL, "initialize");
   
   phpoo_initialize(1, argv , envp);
   //ap_log_error(APLOG_MARK, APLOG_ERR|APLOG_NOERRNO,  0, NULL, "done initialize, main");
   
   //ap_log_error(APLOG_MARK, APLOG_ERR|APLOG_NOERRNO,  0, NULL, "end pcc startup");
   
   return OK;
  
}

static int pcc_handler(request_rec *r)
{

//   ap_log_error(APLOG_MARK, APLOG_ERR|APLOG_NOERRNO,  0, NULL, "pcc handler: %s", r->handler);   

   // first try web app   
   if (check_for_webapp(r) == OK) {

//      ap_log_error(APLOG_MARK, APLOG_ERR|APLOG_NOERRNO,  0, NULL, "webapp said yes: %s", r->handler);         
      return handle_webapp(r);
      
   }
   // now see if we should interpret
   else if (strcmp(r->handler, PCC_MAGIC_TYPE) == 0) {

//      ap_log_error(APLOG_MARK, APLOG_ERR|APLOG_NOERRNO,  0, NULL, "webapp said no, interpreter said yes: %s", r->handler);    
      return handle_execute(r);
      
   }

//   ap_log_error(APLOG_MARK, APLOG_ERR|APLOG_NOERRNO,  0, NULL, "not us at all: %s", r->handler);
      
   return DECLINED;
  
}


static void pcc_register_hooks(apr_pool_t *p)
{

    ap_hook_post_config(pcc_startup, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_handler(pcc_handler, NULL, NULL, APR_HOOK_MIDDLE);

       
}

static int general_handler(request_rec *r, int is_webapp)
{
  int retval;
  pcc_cfg *cfg;

  int status, file_uploads;
  ApacheRequest *req;
  ApacheUpload *upload;

  // apache request object
  req = ApacheRequest_new(r);
  
  /* initialize chunking for reading post request bodies */
//  if ((retval = ap_setup_client_block(r, REQUEST_CHUNKED_ERROR))) {
//    return retval;
//  }
  
  cfg = our_dconfig(r);

  // XXX eventually we should handle more key/values
  if (cfg->include_path) { 
     handle_config_directive("include_path", cfg->include_path);
  }
  
  // FILE UPLOADS
  file_uploads = pcc_get_ini_num("file_uploads");

  if (file_uploads == 0)
     req->disable_uploads = 1;
  req->temp_dir = pcc_get_ini_string("upload_tmp_dir");
  req->post_max = pcc_get_ini_num("upload_max_filesize");

/*   fprintf(stderr, "before the storem 1.3\n"); */
/*   fflush(stderr); */

  // GET/POST  
  if((status = ApacheRequest_parse(req)) != OK) {
     char *errmsg = (char *)apr_table_get(r->notes, "error-notes");
     ap_log_error(APLOG_MARK, APLOG_ERR|APLOG_NOERRNO,  0, NULL,
		  "request error (status %d): %s", status, errmsg);
     return status;
  }


  // UPLOAD
  upload = ApacheRequest_upload(req);

  if (upload) {
     // hook to scheme
     process_upload(upload);
  }


  if (is_webapp) {

    //    char *uri_full_path = ap_make_full_path(r->pool, ap_document_root(r), r->uri);
    int file_len = strlen(r->filename);
    int loc_len = strlen(cfg->loc);

    
/*     fprintf(stderr, "sloc: %s, dloc: %s\n", r->server->path, cfg->loc); */
    if (*(cfg->loc + loc_len - 1) == '/') {
      loc_len--;
    }
    if (file_len < loc_len) {
	//ap_log_rerror(APLOG_MARK, APLOG_ERR|APLOG_NOERRNO, r, 0,
	//    "webapp path too short: %s", r->filename);
      //ap_release_mutex(mod_pcc_mutex);
      return DECLINED;
    }
    
    retval = run_webapp(req, cfg->webapp_lib, apr_pstrdup(r->pool, r->filename + loc_len),
			apr_pstrdup(r->pool, cfg->loc), cfg->webapp_index);
    
  } else {

/*     fprintf(stderr, "sloc: %s, dloc: %s\n", r->server->path, cfg->loc); */
     retval = run_url(req);

  }

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


static void *pcc_create_per_dir(apr_pool_t *p, char *dirspec)
{
   
   pcc_cfg *cfg;
   char *dname = dirspec;

   // ap_pcalloc will let apache cleanup the memory
   cfg = (pcc_cfg *)apr_pcalloc(p, sizeof(pcc_cfg));

   cfg->include_path = 0;
   cfg->webapp_lib = 0;
   cfg->webapp_index = 0;

   // default web app extension   
   cfg->webapp_exts[0] = apr_pstrdup(p, ".php");
   cfg->num_exts = 1;
   cfg->custom_exts = 0;
   
   cfg->cmode = CONFIG_MODE_DIRECTORY;
   dname = (dname != NULL) ? dname : "";
   cfg->loc = apr_pstrdup(p, dname);//ap_pstrcat(p, "DIR(", dname, ")", NULL);

/*    fprintf(stderr, "returning a cfg from create_per_dir: %p\n", cfg); */
/*    fflush(stderr); */

   return (void *)cfg;
   
}

/* For reasons unknown, this routine MUST NOT modify any of its
   arguments. */
static void *pcc_merge_per_dir(apr_pool_t *p, void *parent_conf, void *newloc_conf)
{

    int i;
    
   // ap_pcalloc will let apache cleanup the memory
   pcc_cfg *merged_config = (pcc_cfg *)apr_pcalloc(p, sizeof(pcc_cfg));
   pcc_cfg *pconf = (pcc_cfg *)parent_conf;
   pcc_cfg *nconf = (pcc_cfg *)newloc_conf;


   /* some things get copied directly from the more-specific record,
      rather than getting merged */
   merged_config->loc = apr_pstrdup(p, nconf->loc);
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
     char *s = apr_pcalloc(p, 1 + strlen(nconf->include_path) + 
			  strlen(nconf->include_path));
     sprintf(s, "%s:%s", nconf->include_path, pconf->include_path); 
     merged_config->include_path = s;
   } else if (pconf->include_path) {
      merged_config->include_path = apr_pstrdup(p, pconf->include_path);      
   } else if (nconf->include_path) {
      merged_config->include_path = apr_pstrdup(p, nconf->include_path);      
   } else {
      merged_config->include_path = 0;
   }
   merged_config->cmode = CONFIG_MODE_DIRECTORY;

   // use more specific, dump the parent
   for (i = 0; i < nconf->num_exts; i++) {
       merged_config->webapp_exts[i] = apr_pstrdup(p, nconf->webapp_exts[i]);
   }
   merged_config->num_exts = nconf->num_exts;
   merged_config->custom_exts = nconf->custom_exts;

/*    fprintf(stderr, "returning a merged cfg from merge_per_dir: %p\n", merged_config); */
/*    fflush(stderr); */
   
   return (void *)merged_config;
   
}



static const char *pcc_apache_value_handler(cmd_parms *cmd, void *conf, char *arg1, char *arg2)
{

   pcc_cfg *cfg = (pcc_cfg*)conf; 
   
/*    fprintf(stderr, "pcc_apache_value_handler %s, %s\n", arg1, arg2); */
   if (!strcasecmp(arg1, "include_path")) {
     cfg->include_path = apr_pstrdup(cmd->pool, arg2);
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

    cfg->webapp_exts[cfg->num_exts] = apr_pstrdup(cmd->pool, ext);
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
  
//  fprintf(stderr, "mounting a webapp, %s\n", lib);
  cfg->webapp_lib = apr_pstrdup(cmd->pool, lib);

  if (index) {
    cfg->webapp_index = apr_pstrdup(cmd->pool, index);
  }
  
  return NULL;
}



static int check_for_webapp(request_rec *r)
{


  pcc_cfg *cfg = our_dconfig(r); 

//   ap_log_error(APLOG_MARK, APLOG_ERR|APLOG_NOERRNO,  0, NULL,
//		"request: %s webapp lib here: %s", r->filename, cfg->webapp_lib);
      
  if (cfg->webapp_lib) {
      
     // if we *don't* match extension on the end, we leave alone and let
     // apache process it. otherwise, we get it from lib
     if (try_file_in_lib(r) || try_lib_index(r)) {
	return OK;
     }
     else {
	return DECLINED;
     }
     
  }

  return DECLINED;
  
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


// APACHE 2

static const command_rec pcc_commands[] =
{
	AP_INIT_TAKE2("php_value", pcc_apache_value_handler, NULL, OR_OPTIONS, "Value Modifier"),
	AP_INIT_TAKE2("php_flag", pcc_apache_flag_handler, NULL, OR_OPTIONS, "Flag Modifier"),
	AP_INIT_TAKE2("pcc_value", pcc_apache_value_handler, NULL, OR_OPTIONS, "Value Modifier"),
	AP_INIT_TAKE2("pcc_flag", pcc_apache_flag_handler, NULL, OR_OPTIONS, "Flag Modifier"),
       AP_INIT_TAKE12("pcc_webapp", mount_webapp, NULL, OR_OPTIONS, "Mount a webapp"), 
      AP_INIT_ITERATE("pcc_webapp_exts", do_webapp_exts, NULL, OR_FILEINFO, "Modify extension list for web app"), 
	{NULL}
};


module AP_MODULE_DECLARE_DATA pcc_module =
{
    STANDARD20_MODULE_STUFF,
    pcc_create_per_dir,    /* per-directory config creator */
    pcc_merge_per_dir,     /* dir config merger */
    NULL, /* server config creator */
    NULL,  /* server config merger */
    pcc_commands,                 /* command table */
    pcc_register_hooks,       /* set up other request processing hooks */
};



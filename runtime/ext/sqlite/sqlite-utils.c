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

#include "bigloo.h"
#include "sqlite-utils.h"
#include "stdio.h"

// exported in php-sqlite.scm
extern obj_t pcc_function_callback(sqlite3_context*,int,sqlite3_value**);
extern obj_t pcc_aggregate_step(sqlite3_context*,int,sqlite3_value**);
extern obj_t pcc_aggregate_finalize(sqlite3_context*,int,sqlite3_value**);


// this hooks pcc_function_callback, which is a scheme function exported from
// php-sqlite.scm. it's only done here in c becuase i had a problem getting bigloo
// to hook it correctly
int sqlite_custom_function(sqlite3* db, char* sqlite_name, char* php_name, int num_args) {

   return sqlite3_create_function(db,
				  sqlite_name,
				  num_args,
				  SQLITE_UTF8,
				  (void*)php_name,
				  pcc_function_callback,
				  0,
				  0);
   
}

// same but hooks aggregate functions. notice user_data is different here
int sqlite_custom_aggregate(sqlite3* db, char* sqlite_name, obj_t user_data, int num_args) {

   return sqlite3_create_function(db,
				  sqlite_name,
				  num_args,
				  SQLITE_UTF8,
				  (void*)user_data,
				  0,
				  pcc_aggregate_step,
				  pcc_aggregate_finalize);

   
}

/* ***** BEGIN LICENSE BLOCK *****
 * Roadsend PHP Compiler Runtime Libraries
 * Copyright (C) 2008 Roadsend, Inc.
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

/*  

 Roadsend PHP
 C Runtime Interface

 Note this is NOT used to build the Roadsend PHP runtime. It is used
 by programs that wish to link to the PHP runtime system from C.

 */

#ifndef RE_C_RUNTIME_H
#define RE_C_RUNTIME_H

#include "bigloo.h"

/*********/
/* DEBUG */
/*********/

// the php var_dump function
obj_t re_var_dump(obj_t var);

/*************/
/* BOOL/NULL */
/*************/

// php bools (cast to obj_t)
#define PHP_TRUE   BTRUE
#define PHP_FALSE  BFALSE

// returns non 0 if the obj is a php bool
#define re_is_bool   BOOLEANP

// returns non 0 if the obj is NULL
#define re_is_null   NULLP

/***********/
/* STRINGS */
/***********/

// create a new php string from given c string. note: not binary safe
obj_t re_string(char* str);

// return non 0 if the given obj is a php string
int re_is_string(obj_t var);

/***********/
/* NUMBERS */
/***********/

// create a new php float from the given double
obj_t re_float(double n);

// create a new php int from the given long
obj_t re_int(long n);

// return non 0 if the given obj is either a php int or float
int re_is_number(obj_t var);

// return non 0 if the given obj is a php float
int re_is_float(obj_t var);

// return non 0 if the given obj is a php int
int re_is_int(obj_t var);

/************/
/* PHP HASH */
/************/

// create a new, empty php hash
obj_t re_make_php_hash(void);

// insert a value into a php hash. the key and value should both
// be valid php variables created with one of the other runtime calls
int re_php_hash_insert(obj_t hash, obj_t key, obj_t val);

// insert a string into a hash, associated with the string key
// the key and value should be normal c strings, and are automatically 
// converted to a php strings upon insertion
int re_php_hash_insert_cstr(obj_t hash, char* key, char* val);

// return non 0 if the given obj is a php hash
int re_is_php_hash(obj_t var);

/***********/
/* FUNCALL */
/***********/
// call a php function (from a loaded extension)
// args is a list of arguments, see the re_list_N functions
obj_t re_funcall(char* name, obj_t args);

// return a list of 1 obj
obj_t re_list_1(obj_t var1);

// return a list of 2 objs
obj_t re_list_2(obj_t var1, obj_t var2);

// return a list of 3 objs
obj_t re_list_3(obj_t var1, obj_t var2, obj_t var3);

#endif

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

// initialization
obj_t BGl_modulezd2initializa7ationz75zzrezd2czd2interfacez00(long, char *);
obj_t re_runtime_init(void);

// var_dump
obj_t re_var_dump(obj_t var);

// php-hash
obj_t re_make_php_hash(void);
int re_php_hash_insert(obj_t hash, char* key, char* val);


#endif

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

  The purpose of this file is to test the C interface
  to the Roadsend PHP runtime


 */

#include "re_runtime.h"
#include "stdio.h"

int main(int argc, char *argv[], char *env[])
{

  // initialize runtime
  re_main(argc, argv, env);

  // strings
  obj_t mystr = re_string("this is now a php string");
  re_var_dump(mystr);

  printf("is mystr a string? %s\n", (re_is_string(mystr) ? "yes" : "no"));

  // numbers
  obj_t myfloat = re_float(1.2345);
  re_var_dump(myfloat);

  printf("is myfloat a number? %s\n", (re_is_number(myfloat) ? "yes" : "no"));
  printf("is myfloat a float? %s\n", (re_is_float(myfloat) ? "yes" : "no"));
  printf("is myfloat an int? %s\n", (re_is_int(myfloat) ? "yes" : "no"));

  obj_t myint = re_int(-2312);
  re_var_dump(myint);

  printf("is myint a number? %s\n", (re_is_number(myint) ? "yes" : "no"));
  printf("is myint a float? %s\n", (re_is_float(myint) ? "yes" : "no"));
  printf("is myint an int? %s\n", (re_is_int(myint) ? "yes" : "no"));

  // bool
  obj_t mybool = PHP_TRUE;
  re_var_dump(mybool);

  mybool = PHP_FALSE;
  re_var_dump(mybool);

  // php hash
  obj_t myhash = re_make_php_hash();

  re_php_hash_insert_cstr(myhash, "key1", "val1");
  re_php_hash_insert_cstr(myhash, "key2", "val2");

  obj_t myval = re_string("some data");
  re_php_hash_insert(myhash, re_int(12), myval);

  obj_t nhash = re_make_php_hash();
  re_php_hash_insert_cstr(nhash, "nested", "data");
  re_php_hash_insert(myhash, re_string("my nested hash"), nhash);

  re_var_dump(myhash);

  printf("is myhash a hash? %s\n", (re_is_php_hash(myhash) ? "yes" : "no"));

  // funcalls
  obj_t retval = re_funcall("strlen", re_list_1(mystr));
  re_var_dump(retval);
  
  retval = re_funcall("sizeof", re_list_1(myhash));
  re_var_dump(retval);

  // dump the output of a call to strpos with 2 arguments: mystr and "now"
  re_var_dump(re_funcall("strpos", re_list_2(mystr, re_string("now"))));

}


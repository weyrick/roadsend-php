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

#include "bigloo.h"

// exported from c-interface.scm
obj_t re_runtime_init(void);

obj_t _re_main(obj_t argv_cons)
{
  // these are the mangled initialization functions exported by the compiled c-interface.scm
  BGl_modulezd2initializa7ationz75zzrezd2czd2interfacez00(0, "c-test");
  BGl_bigloozd2initializa7edz12z67zz__paramz00();
}

obj_t re_main(int argc, char *argv[], char *env[]) {

  _bigloo_main(argc, argv, env, &_re_main);
  re_runtime_init();

}


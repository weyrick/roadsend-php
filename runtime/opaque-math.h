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

#ifndef OPQMTH
#define OPQMTH

#define LONG_TYPE   0
#define DOUBLE_TYPE 1

// 64bit friendly
#include <limits.h>

#ifdef LONG_MAX
#define PHP_LONGMAX LONG_MAX
#else
#define PHP_LONGMAX 2147483647L
#endif

#ifdef LONG_MIN
#define PHP_LONGMIN LONG_MIN
#else
#define PHP_LONGMIN (- PHP_LONGMAX - 1)
#endif

// 64bit friendly?
#define MAXFIXNUM 0x1fffffff

/* in the scheme code */
BGL_EXPORTED_DECL obj_t  phpnum_fail(char *reason);

/* #define PHPNUM_HASHNUMBER(a) (((phpnum *)a)->value.lval & 0x1fffffff) */
#define PHPNUM_HASHNUMBER(a) (BELONG_TO_LONG(a) & MAXFIXNUM)

#define ONUMP(a) (ELONGP(a) || REALP(a))
#define PHPNUM_IS_LONG(a) ELONGP(a)
#define PHPNUM_IS_FLOAT(a) REALP(a)

#define PHPNUM_COMPARE_LONG(a,b) ((BELONG_TO_LONG(a) - BELONG_TO_LONG(b)) ? (((BELONG_TO_LONG(a) - BELONG_TO_LONG(b)) > 0) ? 1 : -1) : 0)

#endif /* OPQMTH */

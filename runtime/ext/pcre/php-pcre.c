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

#include "php-pcre.h"
#include <bigloo.h>

/* if this isn't right for your platform, frob the include path in the
   Makefile */
#include <pcre.h>

/*
  called once at pcre startup
  this forces pcre to use the GC
*/
void pcc_pcre_setup() {
    pcre_malloc = pcc_pcre_malloc;
    pcre_free = pcc_pcre_free;
}

void *pcc_pcre_malloc(size_t size)
{
    return GC_MALLOC(size);
}
                                                                                                                            
                                                                                                                            
void pcc_pcre_free(void *ptr)
{
   // the GC should free this for us, but
   // docs say we can free it ourselves and save
   // a collection for possibly faster performance
   GC_free(ptr);
}


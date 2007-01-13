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

#include "windows-odbc.h"
#include "bigloo.h"
#include "sqlext.h"
#include "odbc-utils.h"

obj_t get_odbc_errormsg(SQLHANDLE handle, SQLSMALLINT type) {

   SQLINTEGER	 i = 0;
   SQLINTEGER	 native;
   SQLCHAR	 state[ 6 ];
   SQLCHAR	 text[SQL_MAX_MESSAGE_LENGTH];
   SQLSMALLINT	 len;
   SQLRETURN	 ret;

   obj_t errmsg, errstate;
   
//   do
//   {
      
      ret = SQLGetDiagRec(type, handle, ++i, state, &native, text,
			  sizeof(text), &len );
      
      if (SQL_SUCCEEDED(ret)) {

	 errmsg = string_to_bstring(text);
	 errstate = string_to_bstring(state);

	 return MAKE_PAIR(errmsg, errstate);
	 
      }
      else {
	 // no message
	 return BNIL;
      }
      
//   }
//   while( ret == SQL_SUCCESS );
   
//   return BNIL;
   
}


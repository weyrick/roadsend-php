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

#include <bigloo.h>
#include "pcc-win.h"

obj_t get_registry_string(HKEY key, char *subkey, char *entry) {

  long len = 4096, type, retval;
  char *buf = (char *)GC_MALLOC_ATOMIC(len);
  char *error;
  HKEY pccKey;

  retval = RegOpenKey(key, subkey, &pccKey);

  if (!(retval == ERROR_SUCCESS)) {
    return BFALSE;
  }

  retval = RegQueryValueEx(pccKey, entry, 0, &type, buf, &len);

  RegCloseKey(pccKey);

  if (!(retval == ERROR_SUCCESS)) {
    return BFALSE;
  }

  if (type == REG_DWORD) {
     DWORD dw = *((DWORD *)buf);
     ltoa(dw, buf, 10);
  }

  return string_to_bstring_len(buf, len-1);

}


obj_t set_registry_key(HKEY key, char* subKey, char* entry, DWORD nval, char* strval, int isstr) {

    HKEY newkey;
    DWORD dwDisp;

    if (RegCreateKeyEx(key, subKey, 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &newkey, &dwDisp))
            return BFALSE;

    if (isstr && !strval) {
        if (RegDeleteValue(newkey, entry) != ERROR_SUCCESS)
            return BFALSE;
    } else if (isstr && strval) {
        if (RegSetValueEx(newkey, entry, 0, REG_SZ, (BYTE *)strval, strlen(strval)) != ERROR_SUCCESS)
            return BFALSE;
    } else {
        if (RegSetValueEx(newkey, entry, 0, REG_DWORD, (BYTE *)&nval, sizeof(DWORD)) != ERROR_SUCCESS)
            return BFALSE;
    }

    if (RegCloseKey(newkey) != ERROR_SUCCESS)
            return BFALSE;

    return BTRUE;
}

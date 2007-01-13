/* ***** BEGIN LICENSE BLOCK *****
 * Roadsend PHP Compiler
 * Copyright (C) 2007 Roadsend, Inc.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
 * ***** END LICENSE BLOCK ***** */

#include <bigloo.h>

#ifdef PCC_MINGW

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

//read registry entries from hkey_local_machine 
obj_t get_hklm_string(char *key, char *valueName) {
  long len = 4096, type, retval;
  char *buf = (char *)GC_MALLOC_ATOMIC(len);
  char *error;
  HKEY pccKey;

  retval = RegOpenKey(HKEY_LOCAL_MACHINE, 
/*  "SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment",  */
		      key,
		      &pccKey);
  if (!(retval == ERROR_SUCCESS)) {
    return BFALSE;
  }

  retval = RegQueryValueEx(pccKey, /* "Path",  */ 
			   valueName, 0, &type, buf, &len);
  RegCloseKey(pccKey);
  if (!(retval == ERROR_SUCCESS)) {
    return BFALSE;
  }
  return string_to_bstring_len(buf, len-1);
/*   if (retval == ERROR_SUCCESS) { */
/*     printf("success reported\n"); */
/*     printf("%s\n", buf); */
/*   }  */
/* else { */
/*     printf("failure reported\n"); */
/*     FormatMessage( FORMAT_MESSAGE_ALLOCATE_BUFFER */
/* 		   | FORMAT_MESSAGE_FROM_SYSTEM, */
/* 		   NULL, */
/* 		   GetLastError(), */
/* 		   0, */
/* 		   (LPTSTR)&error, */
/* 		   0, */
/* 		   NULL ); */
/*     printf("%s\n", error); */
/*     LocalFree(error); */
/*   } */

}

#else

obj_t get_hklm_string(char *key, char *valueName) {
  return BFALSE;
}

#endif /* PCC_MINGW */

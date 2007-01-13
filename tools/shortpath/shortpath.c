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

#include <stdio.h>

#ifdef PCC_MINGW

#include <windows.h>

#define BUFLEN 10000

int printShortPath(const char *longPath);

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "Not enough arguments.\n");
    return 1;
  }

  {
    /* join each argument using spaces into a single long path */
    char *longPath = (char *)malloc(BUFLEN);
    int i, j, k;

    k = 0;
    for (i = 1; i < argc; i++) {
      if (i > 1) {
	longPath[k++] = ' ';
      }
      for (j = 0; 
	   k < (BUFLEN - 1) && argv[i][j]; 
	   longPath[k++] = argv[i][j++]);
    }
    longPath[k] = '\0';
    /*       printf("longpath is: %s\n", longPath); */
    /*       printf("retval was: %d\n", retval); */

  /* for a program, returning 0 means a success, and 1 (or any
     non-zero value, I guess) means failure.  Seems to be opposite for
     GetShortPathName() */
    if (printShortPath(longPath)) {
      return 0; 
    } else {
      return 1;
    }
  }
}



int printShortPath(const char *longPath) {
  char *shortPath = (char *)malloc(BUFLEN);
  long len = BUFLEN, type, retval;

  retval = GetShortPathName(longPath, shortPath, len);
  if (retval) {
    printf("%s\n", shortPath);
  } else {
    fprintf(stderr, "Error shortening path.\n"); 
  }
  free(shortPath);
  return retval;
}

#else 

int main() {
  printf("Run me on windows :)\n");
}

#endif /* PCC_MINGW */

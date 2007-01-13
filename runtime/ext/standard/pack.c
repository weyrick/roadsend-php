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
#include "pack.h"

/* determine the host byte-order.
 * see the comp.lang.c FAQ at http://www.eskimo.com/~scs/C-faq/q20.9.html
 */
int host_endian() {
  int x = 1;
  return (*(char *)&x == 1) ? PCC_LITTLE_ENDIAN : PCC_BIG_ENDIAN;
}

int pack_signed_short(char *output, int offset, short arg, int byte_order) {
   printf("output(%s), offset(%d), arg(%d), byte_order(%d)\n", output, offset, arg, byte_order);
   printf("byte0(%c), byte1(%c)\n", ((char *)&arg)[0], ((char *)&arg)[1]);
   if (byte_order == PCC_LITTLE_ENDIAN) {
      printf("signed short little endian\n");
      output[offset]     = ((char *)&arg)[1];
      output[offset + 1] = ((char *)&arg)[0];
   } else { 
      // byte_order == PCC_BIG_ENDIAN
      printf("signed short big endian\n");
      output[offset]     = ((char *)&arg)[0];
      output[offset + 1] = ((char *)&arg)[1];
   }
   return sizeof(arg);
}

int pack_unsigned_short(char *output, int offset, unsigned short arg, int byte_order) {
   printf("output(%s), offset(%d), arg(%d), byte_order(%d)\n", output, offset, arg, byte_order);
   printf("byte0(%c), byte1(%c)\n", ((char *)&arg)[0], ((char *)&arg)[1]);
   if (byte_order == PCC_LITTLE_ENDIAN) {
      printf("unsigned short little endian\n");
      output[offset]     = ((char *)&arg)[1];
      output[offset + 1] = ((char *)&arg)[0];
   } else { 
      // byte_order == PCC_BIG_ENDIAN
      printf("unsigned short big endian\n");
      output[offset]     = ((char *)&arg)[0];
      output[offset + 1] = ((char *)&arg)[1];
   }
   return sizeof(arg);
}

int pack_signed_long(char *output, int offset, long arg, int byte_order) {
   printf("output(%s), offset(%d), arg(%d), byte_order(%d)\n", output, offset, arg, byte_order);
   printf("byte0(%c), byte1(%c), byte2(%c), byte3(%c)\n", ((char *)&arg)[0], ((char *)&arg)[1], ((char *)&arg)[2], ((char *)&arg)[3]);
   if (byte_order == PCC_LITTLE_ENDIAN) {
      printf("signed long little endian\n");
      output[offset]     = ((char *)&arg)[3];
      output[offset + 1] = ((char *)&arg)[2];
      output[offset + 2] = ((char *)&arg)[1];
      output[offset + 3] = ((char *)&arg)[0];
   } else { 
      // byte_order == PCC_BIG_ENDIAN
      printf("signed long big endian\n");
      output[offset]     = ((char *)&arg)[0];
      output[offset + 1] = ((char *)&arg)[1];
      output[offset + 2] = ((char *)&arg)[2];
      output[offset + 3] = ((char *)&arg)[3];
   }
   return sizeof(arg);
}

int pack_unsigned_long(char *output, int offset, unsigned long arg, int byte_order) {
   printf("output(%s), offset(%d), arg(%d), byte_order(%d)\n", output, offset, arg, byte_order);
   printf("byte0(%c), byte1(%c), byte2(%c), byte3(%c)\n", ((char *)&arg)[0], ((char *)&arg)[1], ((char *)&arg)[2], ((char *)&arg)[3]);
   if (byte_order == PCC_LITTLE_ENDIAN) {
      printf("unsigned long little endian\n");
      output[offset]     = ((char *)&arg)[0];
      output[offset + 1] = ((char *)&arg)[1];
      output[offset + 2] = ((char *)&arg)[2];
      output[offset + 3] = ((char *)&arg)[3];
   } else { 
      // byte_order == PCC_BIG_ENDIAN
      printf("unsigned long big endian\n");
      output[offset]     = ((char *)&arg)[3];
      output[offset + 1] = ((char *)&arg)[2];
      output[offset + 2] = ((char *)&arg)[1];
      output[offset + 3] = ((char *)&arg)[0];
   }
   return sizeof(arg);
}

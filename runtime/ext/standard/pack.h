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
#define PCC_LITTLE_ENDIAN 1
#define PCC_BIG_ENDIAN 2

int host_endian();
int pack_signed_short(char *output, int offset, short arg, int byte_order);
int pack_unsigned_short(char *output, int offset, unsigned short arg, int byte_order);
int pack_signed_long(char *output, int offset, long arg, int byte_order);
int pack_unsigned_long(char *output, int offset, unsigned long arg, int byte_order);

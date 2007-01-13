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

#include "php-system.h"

#ifndef PCC_MINGW

#include <stdio.h>

// a version of system that returns a bigloo pair
// the car is the output as a string
// the cdr is the return value
obj_t php_c_system(char *cmd) {

    int retval = 0, len_read = 0;
    int increment = 1024, currentsize = 1024, pos = 0;
    char *buf = (char *)GC_MALLOC_ATOMIC(increment);

    // open as pipe
    FILE *p = popen(cmd, "r");

    if (!p) {
	// woopsie
	return BNIL;
    }

    // read into a buffer
    while ((len_read = fread(buf + pos, sizeof(char), (currentsize - pos), p)) > 0) {

	pos += len_read;
	
	//extend the buffer if we need to
	if (pos == currentsize) {
	    char *newbuf = (char *)GC_MALLOC_ATOMIC(currentsize + increment);
	    memcpy(newbuf, buf, currentsize);
	    currentsize += increment;
	    buf = newbuf;
	}

    }

    // again, extend the buffer if we need to, to make room
    // for the terminating null.
    if (pos == currentsize) {
	char *newbuf = (char *)GC_MALLOC_ATOMIC(currentsize + 1);
	memcpy(newbuf, buf, currentsize);
	currentsize += 1;
	buf = newbuf;
    }

    // tack a null on the end, to terminate the string
    buf[pos] = 0;

    // close, get return value
    retval = pclose(p);

/*     if (WIFEXITED(retval)) { */
/* 	retval = WEXITSTATUS(retval); */
/*     } */
    
    // string_to_bstrinb handles the obj_t malloc and coerce
    return MAKE_PAIR(string_to_bstring(buf), BINT(retval));
    
}

#endif // unix

#ifdef PCC_MINGW

// this stuff comes from the ms docs:
// http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dllproc/base/creating_a_child_process_with_redirected_input_and_output.asp

#define WIN32_LEAN_AND_MEAN
#include <windows.h> 
#include <stdio.h> 

#define BUFSIZE 4096
#define COMSPEC "cmd.exe /c "

obj_t php_c_system(char *cmd) {

   PROCESS_INFORMATION piProcInfo; 
   STARTUPINFO siStartInfo;
   
   HANDLE hChildStdinRd, hChildStdinWr,
          hChildStdoutRd, hChildStdoutWr,
          hStdout;
   
   SECURITY_ATTRIBUTES saAttr; 
   BOOL fSuccess; 

   DWORD len_read = 0;
   DWORD retval = 0;
   int increment = 1024, currentsize = 1024, pos = 0;
   char *buf = (char *)GC_MALLOC_ATOMIC(increment);
   char *realcmd = (char *)GC_MALLOC_ATOMIC(strlen(COMSPEC)+strlen(cmd));

   // always use cmd.exe
   strcpy(realcmd, COMSPEC);
   strcpy(realcmd+strlen(COMSPEC), cmd);
   
// Set the bInheritHandle flag so pipe handles are inherited. 
 
   saAttr.nLength = sizeof(SECURITY_ATTRIBUTES); 
   saAttr.bInheritHandle = TRUE; 
   saAttr.lpSecurityDescriptor = NULL; 

// Create a pipe for the child process's STDOUT. 
 
   if (! CreatePipe(&hChildStdoutRd, &hChildStdoutWr, &saAttr, 0)) 
      return BNIL;

// Ensure the read handle to the pipe for STDOUT is not inherited.

   SetHandleInformation( hChildStdoutRd, HANDLE_FLAG_INHERIT, 0);

// Create a pipe for the child process's STDIN. 
 
   if (! CreatePipe(&hChildStdinRd, &hChildStdinWr, &saAttr, 0)) 
      return BNIL;

// Ensure the write handle to the pipe for STDIN is not inherited. 
 
   SetHandleInformation( hChildStdinWr, HANDLE_FLAG_INHERIT, 0);
 
// Now create the child process. 

// Set up members of the PROCESS_INFORMATION structure. 
 
   ZeroMemory( &piProcInfo, sizeof(PROCESS_INFORMATION) );
 
// Set up members of the STARTUPINFO structure. 
 
   ZeroMemory( &siStartInfo, sizeof(STARTUPINFO) );
   siStartInfo.cb = sizeof(STARTUPINFO); 

   // stderr still goes to stderr
   siStartInfo.hStdError = GetStdHandle(STD_ERROR_HANDLE);
   
   siStartInfo.hStdOutput = hChildStdoutWr;
   siStartInfo.hStdInput = hChildStdinRd;


   // since we run everything through cmd.exe, we want to hide the dos window   
   siStartInfo.dwFlags = STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW;
   siStartInfo.wShowWindow = SW_HIDE;
   
 
// Create the child process. 
    
   fSuccess = CreateProcess(
      NULL,      
      realcmd,       // command line 
      NULL,          // process security attributes 
      NULL,          // primary thread security attributes 
      TRUE,          // handles are inherited 
      0,             // creation flags 
      NULL,          // use parent's environment 
      NULL,          // use parent's current directory 
      &siStartInfo,  // STARTUPINFO pointer 
      &piProcInfo);  // receives PROCESS_INFORMATION 
   
   if (fSuccess == 0) 
      return BNIL;
   else 
   {
      WaitForSingleObject(piProcInfo.hProcess, INFINITE);
      // get exit code
      GetExitCodeProcess(piProcInfo.hProcess, &retval);      
      // close process
      CloseHandle(piProcInfo.hProcess);
      CloseHandle(piProcInfo.hThread);
   }   


// Close the write end of the pipe before reading from the 
// read end of the pipe. 
 
   if (!CloseHandle(hChildStdoutWr)) 
      return BNIL;

   for (;;) 
   { 
      if( !ReadFile( hChildStdoutRd, buf + pos, (currentsize - pos), &len_read, NULL) || len_read == 0) break;

      pos += len_read;
	
      //extend the buffer if we need to
      if (pos == currentsize) {
	 char *newbuf = (char *)GC_MALLOC_ATOMIC(currentsize + increment);
	 memcpy(newbuf, buf, currentsize);
	 currentsize += increment;
	 buf = newbuf;
      }      
      
   } 

   // again, extend the buffer if we need to, to make room
   // for the terminating null.
   if (pos == currentsize) {
      char *newbuf = (char *)GC_MALLOC_ATOMIC(currentsize + 1);
      memcpy(newbuf, buf, currentsize);
      currentsize += 1;
      buf = newbuf;
   }
   
   // tack a null on the end, to terminate the string
   buf[pos] = 0;
   
   // string_to_bstrinb handles the obj_t malloc and coerce
   return MAKE_PAIR(string_to_bstring(buf), BINT(retval));
   
} 
 
 

#endif

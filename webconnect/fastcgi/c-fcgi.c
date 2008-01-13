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

/*
 * Inpired by the fastcgi spawing code in zend php by
 * Ben Mansell, Shane Caraveo, Dmitry Stogov and others
 */

#ifndef PCC_MINGW

// linux
#include <sys/types.h>
#include <unistd.h>
#include <sys/wait.h>
#include <stdio.h>
#include <signal.h>
#include <stdlib.h>

#endif

static int parent = 1;
struct sigaction act, old_term, old_quit, old_int;
static pid_t pgroup;

void catch_fcgi_shutdown(int sig) {
    //    fprintf(stderr, "catch_fcgi_shutdown: %d\n", sig);
    sigaction(SIGTERM, &old_term, 0);
    kill(-pgroup, SIGTERM);
    exit(0);
}

int pcc_fcgi_spawn(int numchildren) {

#ifdef PCC_MINGW
    // this can be written for windows, but right now always just returns
    // saying we are child, so it serves with one process
    return 0;
#else    

    pid_t pid, exit_pid;
    int status;
    int running = 0;
    
    setsid();
    pgroup = getpgrp();
    act.sa_flags = 0;
    act.sa_handler = catch_fcgi_shutdown;
    if (sigaction(SIGTERM, &act, &old_term) ||
	sigaction(SIGINT,  &act, &old_int) ||
	sigaction(SIGQUIT, &act, &old_quit)) {
	perror("Can't set signals");
	exit(1);
    }

 spawn_top:
    while (parent && (running < numchildren)) {
	//	fprintf(stderr, "running: %d\n", running);
	pid = fork();
	switch (pid) {
	case -1:
	    perror("fork failed");
	    exit(1);
	case 0:
	    parent = 0;
	    //	    fprintf(stderr, "i am child\n");
	    sigaction(SIGTERM, &old_term, 0);
	    sigaction(SIGQUIT, &old_quit, 0);
	    sigaction(SIGINT,  &old_int,  0);
	    break;
	default:
	    //	    fprintf(stderr, "i am parent, i spawned [%d]\n", pid);
	    break;
	}
	running++;
    } // spawn loop

    if (parent) {
	while ((exit_pid = wait(&status)) < 0) { }
	//	fprintf(stderr, "a child exited [%d]\n", exit_pid);
	running--;
	goto spawn_top;
    }

    return parent;

#endif /* PCC_MINGW */

}


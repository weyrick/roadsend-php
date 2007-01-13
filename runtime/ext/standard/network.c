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

#include <sys/types.h>
#include <bigloo.h>
#include "network.h"
#include <string.h>

#ifdef PCC_MINGW

#undef SOCKET 
#include <winsock2.h>
#include <mswsock.h>
#include <fcntl.h>

#else

#ifdef PCC_FREEBSD
  #include <arpa/nameser.h>
#endif

/* FreeBSD requires this *before* resolv.h */
#include <netinet/in.h>

#include <resolv.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>

#endif /* PCC_MINGW */

int php_checkdnsrr(char *host, char *typestr) {
#ifdef PCC_MINGW
  return -1;
#else
   unsigned char answer[MAXPACKET];
   int type = T_MX;

   if (strcasecmp(typestr, "MX") == 0)
      type = T_MX;
   else if (strcasecmp(typestr, "A") == 0)
      type = T_A;
   else if (strcasecmp(typestr, "NS") == 0)
      type = T_NS;
   else if (strcasecmp(typestr, "PTR") == 0)
      type = T_PTR;
   else if (strcasecmp(typestr, "ANY") == 0)
      type = T_ANY;
   else if (strcasecmp(typestr, "SOA") == 0)
      type = T_SOA;
   else if (strcasecmp(typestr, "CNAME") == 0)
      type = T_CNAME;
   else
      return -1;
      
   return res_search(host, C_IN, type, answer, MAXPACKET);
#endif /* PCC_MINGW */
}

int php_getprotobyname(char *name) {
#ifdef PCC_MINGW
  return -1;
#else

   struct protoent *p = getprotobyname(name);
   if (p)
      return p->p_proto;
   else
      return -1;

#endif /* PCC_MINGW */

}
   
int php_getservbyname(char *name, char *protocol) {
#ifdef PCC_MINGW
  return -1;
#else

   struct servent *s = getservbyname(name, protocol);
   if (s)
      return ntohs(s->s_port);
   else
      return -1;
#endif /* PCC_MINGW */
}

long php_ip2long(char *ip_address) {
  unsigned long ip = inet_addr(ip_address);
  if (ip == INADDR_NONE)
    return -1;
  else
    return ntohl(ip);
}

int php_getmxrr(char *hostname, char *mx_list, char *weight_list) {
#ifdef PCC_MINGW
  return 0;
#else

   char *mx_list_ptr = (char *)(mx_list + sprintf(mx_list, ""));
   char *weight_list_ptr = (char *)(weight_list + sprintf(weight_list, ""));
   unsigned char answer[MAXPACKET];
   unsigned char expand_buffer[MAXHOSTNAMELEN];
   int ans_len = res_search(hostname, C_IN, T_MX, answer, sizeof(answer));
   HEADER *header_ptr = (HEADER *)&answer;
   unsigned char *body_ptr = (unsigned char *)&answer + NS_HFIXEDSZ;
   unsigned char *eom_ptr = (unsigned char *)&answer + sizeof(answer);
   int n, ancount, qdcount, type, weight;
   
   for (qdcount = ntohs((unsigned short)header_ptr->qdcount); qdcount--; body_ptr += (n + NS_QFIXEDSZ))
      if ((n = dn_skipname(body_ptr, eom_ptr)) < 0)
         return -1;

   ancount = ntohs((unsigned short)header_ptr->ancount);
   while (--ancount >= 0 && body_ptr < eom_ptr) {
      if ((n = dn_skipname(body_ptr, eom_ptr)) < 0)
	 return -1;
      body_ptr += n;
      NS_GET16(type, body_ptr);
      body_ptr += (NS_INT16SZ + NS_INT32SZ);
      NS_GET16(n, body_ptr);
      if (type != T_MX) {
 	 body_ptr += n;
	 continue;
      }
      NS_GET16(weight, body_ptr);
      if ((n = dn_expand(answer, eom_ptr, body_ptr, expand_buffer, sizeof(expand_buffer) - 1)) < 0)
	 return -1;
      body_ptr += n;
      mx_list_ptr += sprintf(mx_list_ptr - 1, " %s  ", expand_buffer);
      weight_list_ptr += sprintf(weight_list_ptr - 1, " %d ", weight);
   }
   return 0;
#endif /* PCC_MINGW */
}

#ifndef PCC_MINGW

int php_fsockopen(char *hostname, int port, int domain, int type, int *errno_p, char **errstr_p) {
   int sockfd;
   struct sockaddr_in dest_addr;
   struct hostent *h = gethostbyname(hostname);
   
   if (!h) return -1;
   
   if ((sockfd = socket(domain, type, 0)) < 0) return -1;
   
   dest_addr.sin_family = domain;
   dest_addr.sin_port = htons(port);
   dest_addr.sin_addr.s_addr = inet_addr(inet_ntoa(*((struct in_addr *)h->h_addr)));
   memset(&(dest_addr.sin_zero), '\0', 8);
   
   if (connect(sockfd, (struct sockaddr *)&dest_addr, sizeof(struct sockaddr)) < 0)
      return -1;
   else
      return sockfd;
}

#else

char *biglooify_string(const char *str) {
  int len = 1 + strlen(str);
  char *retval = (char *)GC_MALLOC_ATOMIC(1+len);
  bcopy(str, retval, len);
  return retval;
}

int php_fsockopen(char *hostname, int port, int domain, int type, int *errno_p, char **errstr_p) {
   SOCKET sockfd;
   //   struct sockaddr_in dest_addr;
   struct sockaddr_in *dest;
   struct hostent *h = gethostbyname(hostname);
   
   if (!h) {
     *errno_p = h_errno;
     switch (h_errno) {
     case HOST_NOT_FOUND:
       	 *errstr_p = biglooify_string("gethostbyname: The specified host is unknown.");
	 break;
     case TRY_AGAIN:
       	 *errstr_p = biglooify_string("gethostbyname: The requested name is valid but does not have an IP address.");
	 break;
     case NO_RECOVERY:
       	 *errstr_p = biglooify_string("gethostbyname: A non-recoverable name server error occurred.");
	 break;
     case NO_ADDRESS:      // also NO_DATA:	
       	 *errstr_p = biglooify_string("gethostbyname: The specified host is unknown.");
	 break;
     }
     return -1;
   }

   //sockfd = WSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL, 0, 0)) == INVALID_SOCKET) {
#ifdef PCC_MINGW   
   if (//(sockfd = WSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL, 0, 0)) == INVALID_SOCKET) {
       (sockfd = socket(AF_INET, SOCK_STREAM, 0)) == INVALID_SOCKET) {
#else
   if ((sockfd = socket(domain, type, 0)) < 0) {
#endif //PCC_MINGW
     *errno_p = WSAGetLastError();
     *errstr_p = strerror(errno);

     return -1;
   }

   dest = (struct sockaddr_in *)malloc(128);//sizeof(struct sockaddr_in));
   dest->sin_family = PF_INET; //domain
   dest->sin_port = htons((unsigned short)port);
   dest->sin_addr.s_addr = inet_addr(inet_ntoa(*((struct in_addr *)h->h_addr)));

   memset(&(dest->sin_zero), '\0', 8);
   //   if (connect(sockfd, (struct sockaddr *)dest, sizeof(dest)) == SOCKET_ERROR) {
   if (connect(sockfd, (struct sockaddr *)dest, sizeof(struct sockaddr)) == SOCKET_ERROR) {
     *errno_p = WSAGetLastError(); //errno;
     *errstr_p = strerror(errno); //XXX not right
     return -1;
   } else {
     return sockfd;
   }
   return -1;
}

#ifdef PCC_MINGW

   int wsock_started = 0;

int init_winsock() {
  WORD wVersionRequested = MAKEWORD(2, 0);
  WSADATA wsaData;

  if (WSAStartup(wVersionRequested, &wsaData) != 0) {
    return 0;
  }
  wsock_started = 1;
  return 1;
}

int cleanup_winsock() {
  WSACleanup();
  return 0;
}


#undef fdopen
FILE *
pcc_fdopen(int fd, char *mode)
{
    FILE *fp;
    char sockbuf[256];
    int optlen = sizeof(sockbuf);
    int retval;

    if (!wsock_started)
	return(fdopen(fd, mode));

    retval = getsockopt((SOCKET)fd, SOL_SOCKET, SO_TYPE, sockbuf, &optlen);
    if(retval == SOCKET_ERROR && WSAGetLastError() == WSAENOTSOCK) {
	return(fdopen(fd, mode));
    }

    {
      int realfd = _open_osfhandle (fd, _O_RDWR);
      return fdopen(realfd, mode);
    }

/*     { */
/*       int sockopt = SO_SYNCHRONOUS_NONALERT; */
/*       int sockread; */

/*       fprintf(stderr, "About to setsockopt() for windows\n"); */
/*       if (setsockopt(INVALID_SOCKET, SOL_SOCKET, SO_OPENTYPE, (char *)&sockopt, sizeof(sockopt)) < 0) { */
/*         perror("setsockopt:"); */
/*       } */
/*       if ( (sockread = _open_osfhandle(fd, 0)) == -1) { */
/*         perror("_open_osfhandle: read:"); */
/*       } */
/*       return fdopen(sockread, mode); */
/*     } */




/*     /\* */
/*      * If we get here, then fd is actually a socket. */
/*      *\/ */
/*     //    Newz(1310, fp, 1, FILE);	/\* XXX leak, good thing this code isn't used *\/ */
/*     fp = (FILE *)malloc(sizeof(FILE)); */
/*     if(fp == NULL) { */
/* 	errno = ENOMEM; */
/* 	return NULL; */
/*     } */

/*     fp->_file = fd; */
/*     if(*mode == 'r') */
/* 	fp->_flag = _IOREAD; */
/*     else */
/* 	fp->_flag = _IOWRT; */
   
/*     return fp; */
}

#endif /* PCC_MINGW */


int wait_for_data(SOCKET fd, int secs)
{
	fd_set fdr, tfdr;
	int retval;
	struct timeval timeout, *ptimeout;

	FD_ZERO(&fdr);
	FD_SET(fd, &fdr);
	
	if (secs == -1) {
	  ptimeout = NULL;	  
	} else {
	  timeout.tv_sec = secs;
	  timeout.tv_usec = 0;
	  ptimeout = &timeout;
	}

	while(1) {
		tfdr = fdr;

		retval = select(fd + 1, &tfdr, NULL, NULL, ptimeout);

/* 		if (retval == 0) { */
/* 		  fprintf(stderr, " seems to've timed out \n "); */
/* 		  fflush(stderr); */
/* 		} */

		if (retval >= 0)
		  return 1;
	}
}

#endif /* PCC_MINGW */



obj_t bigloo_recv(int fd, int maxlen) {
  char *str;
  int bytes_read;

  if (!(str = malloc(maxlen))) {
    perror("couldn't allocate memory in bigloo_recv");
    exit(1);
  }
  bytes_read = recv(fd, str, maxlen, 0);
  if (bytes_read < 0) {
    free(str);
    return BFALSE;
  } {
    obj_t retval = string_to_bstring_len(str, bytes_read);
    free(str);
    return retval;
  }
}

#ifdef PCC_MINGW
#define socket_errno() WSAGetLastError()
#else
#define socket_errno() errno
#endif


obj_t bigloo_socket_read_returns_data(int fd) {
  char buf;

  if ((0 == recv(fd, &buf, 1, MSG_PEEK)) && 
      (socket_errno() != EAGAIN)) {
    return BFALSE;
  } else {
    return BTRUE;
  }
}

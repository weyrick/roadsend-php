/* Copyrights 2002 Luis Figueiredo (stdio@netc.pt) All rights reserved. 
 *
 * See the LICENSE file
 *
 * The origin of this software must not be misrepresented, either by
 * explicit claim or by omission.  Since few users ever read sources,
 * credits must appear in the documentation.
 * 
 * date: Sat Mar 30 14:44:42 GMT 2002
 *
 * -- core server functions
 *
 */

#include "server.h"
#include "logo.h"

#ifdef DEBUG
	char *_libwebserver_version= _SERVER_VERSION "(debug)";
#else
	char *_libwebserver_version= _SERVER_VERSION;
#endif

struct web_server *current_web_server;


/*********************************************************************************************************/
/*
 *	Define certificate file (open_ssl)
 */
void web_server_useSSLcert(struct web_server *server,const char *file) {
#ifdef HAVE_OPENSSL
	if(!(server->cert_file=__ILWS_malloc(strlen(file)+1))) {
		LWSERR(LE_MEMORY);
		return;
	};
	memcpy(server->cert_file,file,strlen(file));
	server->cert_file[strlen(file)]=0;
#else
	printf("OpenSSL not supported in this compilation\n");
#endif
}

void web_server_useMIMEfile(struct web_server *server,const char *file) {
	if(!(server->mimefile=__ILWS_malloc(strlen(file)+1))) {
		LWSERR(LE_MEMORY);
		return;
	};
	memcpy(server->mimefile,file,strlen(file));
	server->mimefile[strlen(file)]=0;
};
/*********************************************************************************************************/
/*
 *  Handler for libwebserver logotipe
 */
void _web_server_logo() {
	printf("Content-type: image/gif\r\n\r\n");
	fwrite((char *)_logo,sizeof(_logo),1,stdout);
}        


/*********************************************************************************************************/
/*
 * Add an handler to request data
 */
int web_server_addhandler(struct web_server *server,const char *mstr,void (*func)(),int flag) {
	_logfile=server->weblog;
	// xor?
	flag ^= (server->flags & WS_LOCAL); // global flag to handler flag
	flag ^= (server->flags & WS_DYNVAR); // global flag to handler fla  g
	flag ^= (server->flags & WS_USELEN); // global flag to handler flag
	web_log("[%s] Adding handler %s <--%s%s%s\n",__ILWS_date(time(NULL),"%d/%b/%Y:%H:%M:%S %z"),mstr, ((flag & WS_LOCAL) == WS_LOCAL && !((server->flags & WS_LOCAL) == WS_LOCAL))?"[LOCAL] ":"", ((flag & WS_DYNVAR) == WS_DYNVAR)?"[DYNVAR]":"", ((flag & WS_USELEN) == WS_USELEN)?"[USELEN]":"");
	return __ILWS_add_handler((struct gethandler *)server->gethandler,mstr,func,NULL,flag,GH_FUNCTION);
}

/*********************************************************************************************************/
/*
 * Add an alias dir (new on 0.5.2)
 */
int web_server_aliasdir(struct web_server *server, const char *str, char *path,int flag) {
	char *mstr;
	int ret;
	mstr=__ILWS_malloc(strlen(str)+7);
	if(!strlen(str)) {
		snprintf(mstr,strlen(str)+7,"* /*");
	} else {
		snprintf(mstr,strlen(str)+7,"* /%s/*",str);
	};
	_logfile=server->weblog;
	flag ^= (server->flags & WS_LOCAL); // global flag to handler flag
	flag ^= (server->flags & WS_DYNVAR); // global flag to handler flag
	flag ^= (server->flags & WS_USELEN); // global flag to handler flag
	web_log("[%s] Adding directory %s <--%s%s%s\n",__ILWS_date(time(NULL),"%d/%b/%Y:%H:%M:%S %z"),mstr, ((flag & WS_LOCAL) == WS_LOCAL && !((server->flags & WS_LOCAL) == WS_LOCAL))?"[LOCAL] ":"", ((flag & WS_DYNVAR) == WS_DYNVAR)?"[DYNVAR]":"", ((flag & WS_USELEN) == WS_USELEN)?"[USELEN]":"");
	ret=__ILWS_add_handler((struct gethandler *)server->gethandler,mstr,NULL,path,flag,GH_DIRECTORY);
	__ILWS_free(mstr);
	return ret;
};


/*********************************************************************************************************/
/*
 *	Personal config (new on 0.5.0)
 */
char *web_server_getconf(struct web_server *server, const char *topic,const char *key) {
	char *dataconf;
	char *tmp1,*tmp2,*tmp3;
	long tmpsize=0;

	dataconf=__ILWS_stristr(server->dataconf,topic);
	if(dataconf==NULL) {
		return NULL;
	};
	dataconf+=strlen(topic);
	tmp1=__ILWS_stristr(dataconf,key);
	do {
		tmp1=__ILWS_stristr(dataconf,key);
		dataconf+=1;
		if(dataconf[0]==0) { 
			return NULL;
		};
		if(dataconf[0]=='[' && dataconf[-1]=='\n') { 
			return NULL;
		};
	}while(!(tmp1!=NULL && tmp1[-1]=='\n' && tmp1[strlen(key)]=='='));
	
	tmp1+=strlen(key)+1;
	tmp2=__ILWS_stristr(tmp1,"\n");
	if(tmp2==NULL) {
		tmp2=tmp1+strlen(tmp1);
	};
	tmpsize=tmp2-tmp1;
	if(!(tmp3=__ILWS_malloc(tmpsize+1))) {
		LWSERR(LE_MEMORY);
		return NULL;
	};
	memcpy(tmp3,tmp1,tmpsize);
	tmp3[tmpsize]=0;
	return tmp3;
};

/*********************************************************************************************************/
/*
 *	Define config file to setup server (new on 0.5.0)
 */
int web_server_setup(struct web_server *server,const char *conffile) {
	FILE *tmpf;
	char *tmp3;
	//long tmpsize=0;
	long sizec;
	struct stat statf; // tested only on win

	if(!(server->conffile=__ILWS_malloc(strlen(conffile)+1))) {
		LWSERR(LE_MEMORY);
		return 0;
	};

	memcpy(server->conffile,conffile,strlen(conffile));
	server->conffile[strlen(conffile)]=0;
	
	tmpf=fopen(server->conffile,"r");
	if(tmpf==NULL) {
		printf("no config file found\r\n");
		server->dataconf="";
		return(0);
	};
	fseek(tmpf,SEEK_SET,SEEK_END);
	sizec=ftell(tmpf);
	fseek(tmpf,0,SEEK_SET);
	if(!(server->dataconf=__ILWS_malloc(sizec+1))) {
		LWSERR(LE_MEMORY);
		return 0;
	};
	fread(server->dataconf,sizec,1,tmpf);
	server->dataconf[sizec]=0; // Hilobok Andrew (han@km.if.ua) said to remove the -9 :)
	fclose(tmpf);
	
	stat(server->conffile,&statf); // tested only on win
	server->conffiletime=statf.st_mtime; // tested only on win

	if((server->logfile=web_server_getconf(server,"LIBWEBSERVER","LOG"))) {
		web_log("\nUsing logfile [%s]\n",server->logfile);
		server->weblog=open_weblog(server->logfile);
	} else {
		web_log("\nLOG entry not found\r\n");
		server->weblog=NULL;
	};
	if((tmp3=web_server_getconf(server,"LIBWEBSERVER","PORT"))) {
		web_log("\nListen port [%s]\n",tmp3);
		server->port=atoi(tmp3);
		__ILWS_free(tmp3);
	} else {
		web_log("PORT entry not found\r\n");
		server->port=0;
	};
#ifdef HAVE_OPENSSL
	// Fetch SSL
	if((tmp3=web_server_getconf(server,"LIBWEBSERVER","USESSL"))) {
		if(tmp3[0]=='1') {
			server->flags = server->flags | WS_USESSL;
		}else if(tmp3[0]=='0') {
			server->flags = server->flags & ~WS_USESSL;
		} else {
			fprintf(stderr,"[USESSL=] argument invalid\n");
		};
		__ILWS_free(tmp3);
	} 
	// Fetch CERTFILE
	server->cert_file=web_server_getconf(server,"LIBWEBSERVER","CERTFILE");
	server->mimefile=web_server_getconf(server,"LIBWEBSERVER","MIMEFILE");
#endif
	// Fetch LOCAL
	if((tmp3=web_server_getconf(server,"LIBWEBSERVER","LOCAL"))) {
		if(tmp3[0]=='1') {
			server->flags = server->flags | WS_LOCAL;
		} else if(tmp3[0]=='0') {
			server->flags=server->flags & ~WS_LOCAL;
		}else {
			fprintf(stderr,"[LOCAL=] argument invalid\n");
		};
		__ILWS_free(tmp3);
	} 
	
	return 1;
};

/*********************************************************************************************************/
/*
 * This function initialize one web_server handler
 */
int web_server_init(struct web_server *server,int port,const char *logfile,int flags) {
#ifdef WIN32	
	WSADATA WSAinfo;
	if (WSAStartup(2,&WSAinfo) != 0) {
		LWSERR(LE_NET);
		return -1;
	}
#endif

	current_web_server=server;
	server->running=0;
	server->port=port;
	server->conffile=NULL;
	server->mimefile=NULL;
	server->weblog=NULL;
	server->usessl=0;
	server->highsocket=0;
	server->flags=flags;
	server->dataconf="";
	if((flags & WS_USEEXTCONF) == WS_USEEXTCONF) {
		if(!(web_server_setup(server,logfile))) {
#ifdef WIN32		
			WSACleanup();
#endif
			return 0;
		};
		_logfile=server->weblog; // Set current log stream
		web_log("%s using config file %s\n",_libwebserver_version,logfile);
	};
	// Create a listen socket port 'port' and listen addr (0) (all interfaces)
	server->socket=__ILWS_listensocket((short)server->port,0);	
	if(server->socket==-1) {
		LWSERR(LE_NET);
#ifdef WIN32		
		WSACleanup();
#endif
		return 0;
	};

	// Setup FILE structure of logfile
	if(logfile!=NULL && !((flags & WS_USEEXTCONF) == WS_USEEXTCONF)) {
		server->logfile=__ILWS_malloc(strlen(logfile)+1);
		memcpy(server->logfile,logfile,strlen(logfile));
		server->logfile[strlen(logfile)]=0;
		server->weblog=open_weblog(logfile); // Create File stream for log
	};
	
	web_log("\n[%s] Server started at port %d (%s)\n",
		__ILWS_date(time(NULL),"%d/%b/%Y:%H:%M:%S %z"),
		server->port,
		_libwebserver_version);
	
#ifdef WIN32
//	ioctlsocket(server->socket,FIONBIO,&t);  //non blocking sockets for win32
#else
/*	if (fcntl(server->socket,F_SETFL,O_NONBLOCK) == -1) {
	   web_log("\n[%s] Error: unable to set nonblocking port\n",
		   __ILWS_date(time(NULL),"%d/%b/%Y:%H:%M:%S %z"));
		   }*/
#endif
		
	// Setup Flags
	
	// openssl
#ifdef HAVE_OPENSSL	
	if((server->flags & WS_USESSL) == WS_USESSL) {
		web_log("[%s] (FLAG) Using SSL in connections\n",__ILWS_date(time(NULL),"%d/%b/%Y:%H:%M:%S %z"));	
		web_log("                       +-- %s certificate file\n",server->cert_file);
		SSL_load_error_strings();
		SSLeay_add_ssl_algorithms(); 	
		server->ctx=SSL_CTX_new (SSLv23_server_method());
		if (SSL_CTX_use_certificate_file(server->ctx, server->cert_file, SSL_FILETYPE_PEM) <= 0) {
			ERR_print_errors_fp(stderr);
			exit(3);
		}
		if (SSL_CTX_use_PrivateKey_file(server->ctx, server->cert_file, SSL_FILETYPE_PEM) <= 0) {
			ERR_print_errors_fp(stderr);
			exit(4);
		}                      
	 	if (SSL_CTX_check_private_key(server->ctx)<= 0)  	 {
			ERR_print_errors_fp(stderr);
			exit(4);
		};
		server->usessl=1;
	};
#endif
	if((server->flags & WS_LOCAL) == WS_LOCAL) {
		web_log("[%s] (FLAG) Accepting only local connections\n",__ILWS_date(time(NULL),"%d/%b/%Y:%H:%M:%S %z"));	
	};
	server->client=__ILWS_init_client_list();										// Initializate client list
	server->gethandler=__ILWS_init_handler_list();									// Initializate handlers list
	web_server_addhandler(server,"* /libwebserver.gif",_web_server_logo,0);	// Add logo default handler

#ifndef WIN32	
	signal(SIGPIPE,SIG_IGN);
#endif
	return 1;
}                            

void setnonblocking(int sock)
{

#ifdef WIN32
	unsigned long t=IOC_INOUT;

	ioctlsocket(sock,FIONBIO,&t);
#else
	int opts;

	opts = fcntl(sock,F_GETFL);
	if (opts < 0) {
		perror("fcntl(F_GETFL)");
		exit(EXIT_FAILURE);
	}
	opts = (opts | O_NONBLOCK);
	if (fcntl(sock,F_SETFL,opts) < 0) {
		perror("fcntl(F_SETFL)");
		exit(EXIT_FAILURE);
	}
	return;
#endif
}


void build_select_list(struct web_server *server) {

   struct web_client *client;

   
   /* First put together fd_set for select(), which will
      consist of the sock veriable in case a new connection
      is coming in, plus all the sockets we have already
      accepted. */
   
   
   /* FD_ZERO() clears out the fd_set called socks, so that
      it doesn't contain any file descriptors. */
   
   // linux?
   //   FD_ZERO(&(server->socks));
   // win32
   FD_ZERO(&server->socks);
   
   /* FD_SET() adds the file descriptor "sock" to the fd_set,
      so that select() will return if a connection comes in
      on that socket (which means you have to do accept(), etc. */
   
   //FD_SET(server->socket, &(server->socks));
   FD_SET(server->socket, &server->socks);
   
   /* Loops through all the possible connections and adds
      those sockets to the fd_set */
   client = server->client;
   while (client->next != NULL) {

     //FD_SET(client->next->socket, &(server->socks));
      FD_SET(client->next->socket, &server->socks);
      if (client->next->socket > server->highsocket)
	 server->highsocket = client->next->socket;

      client = client->next;
   }

   
/*	for (listnum = 0; listnum < 5; listnum++) {
		if (connectlist[listnum] != 0) {
			FD_SET(connectlist[listnum],&socks);
			if (connectlist[listnum] > highsock)
				highsock = connectlist[listnum];
		}
	}
*/

  
}

void handle_new_connection(struct web_server *server) {

   int tsalen=0;
   int tsocket=0;
   struct sockaddr_in tsa;
   struct web_client *client;
   
   tsalen=sizeof(client->sa); 
   tsocket=accept(server->socket,(struct sockaddr *)&tsa,&tsalen); 
   
   if (tsocket < 0) {
      perror("accept");
      exit(EXIT_FAILURE);
   }

   // done in add_client
//   setnonblocking(tsocket);
   
   client=__ILWS_malloc(sizeof(struct web_client));
   if(client==NULL) {
      shutdown(tsocket,SHUT_RDWR);
#ifdef WIN32
      closesocket(tsocket);
#else
      close(tsocket);
#endif
      LWSERR(LE_MEMORY);
      return;
   };
   
   client->salen=tsalen;
   client->socket=tsocket;
   client->sa=tsa;
   
#ifdef HAVE_OPENSSL
   if((server->flags & WS_USESSL) == WS_USESSL) {
      client->ssl = SSL_new(server->ctx);
      SSL_set_fd(client->ssl,client->socket);
      SSL_accept(client->ssl);
      //client->cert = SSL_get_peer_certificate (client->ssl);
   } else {
      client->ssl=NULL;
   };
#endif
   
   if(!__ILWS_add_client(server->client,client)) {
      fprintf(stderr,"No client?\n"); // REMOVE
      return;
   }else {
      web_log("%s - - [%s] Connected\n",
	      inet_ntoa(client->sa.sin_addr),
	      __ILWS_date(time(NULL),"%d/%b/%Y:%H:%M:%S %z")); //REMOBE
   };

	
/* 	for (listnum = 0; (listnum < 5) && (connection != -1); listnum ++) */
/* 		if (connectlist[listnum] == 0) { */
/* 			printf("\nConnection accepted:   FD=%d; Slot=%d\n", */
/* 				connection,listnum); */
/* 			connectlist[listnum] = connection; */
/* 			connection = -1; */
/* 		} */
/* 	if (connection != -1) { */
/* 		/\* No room left in the queue! *\/ */
/* 		printf("\nNo room left for new client.\n"); */
/* 		sock_puts(connection,"Sorry, this server is too busy.  Try again later!\r\n"); */
/* 		close(connection); */
/* 	} */
   
}


void read_socks(struct web_server *server) {

   struct web_client *client;
   
   /* OK, now socks will be set with whatever socket(s)
      are ready for reading.  Lets first check our
      "listening" socket, and then check the sockets
      in connectlist. */
   
   /* If a client is trying to connect() to our listening
      socket, select() will consider that as the socket
      being 'readable'. Thus, if the listening socket is
      part of the fd_set, we need to accept a new connection. */
   
   if (FD_ISSET(server->socket,&server->socks)) {
      //fprintf(stderr,"handling new connection\n");
      handle_new_connection(server);
   }
   
   /* Now check connectlist for available data */
   
   /* Run through our sockets and check to see if anything
      happened with them, if so 'service' them. */

   client = server->client;
   while (client->next != NULL) {

      if (FD_ISSET(client->next->socket,&server->socks)) {

	 current_web_client=client->next;
	 
	 while (client->next->stat == 1) {
	    __ILWS_read_client(current_web_client);
	 }
	 
	 if (client->next->stat == 5) {
	    __ILWS_delete_next_client(client);
	    continue;
	 }
	 
	 __ILWS_process_client(current_web_client,server->gethandler);
	 if (client->next->stat == 5) {
	    __ILWS_delete_next_client(client);
	    continue;
	 }
	 
         while (client->next->stat == 4) {
            __ILWS_output_client(current_web_client);
	 }

	 __ILWS_delete_next_client(client);
	 continue;

      }

      client = client->next;
   }
   
//   for (listnum = 0; listnum < 5; listnum++) {
//      if (FD_ISSET(connectlist[listnum],&socks))
//	 deal_with_data(listnum);    
//   } /* for (all entries in queue) */
   
}

/*********************************************************************************************************/
/*
 */

void web_server_stop(struct web_server *server) {

   server->running = 0;

   // fixme close all sockets
   
}

int web_server_run(struct web_server *server) {
   
	struct timeval timeout;  /* Timeout for select */
	int readsocks;	     /* Number of sockets ready for reading */
		
	_logfile=server->weblog;	
	current_web_server=server;
	
	/* Since we start with only one socket, the listening socket,
	   it is the highest socket so far. */
	server->highsocket = server->socket;	

	// go houston
	server->running = 1;
	
	while (server->running) { /* Main server loop */

	        build_select_list(server);
		timeout.tv_sec = 1;
		timeout.tv_usec = 0;
		
		/* The first argument to select is the highest file
			descriptor value plus 1. In most cases, you can
			just pass FD_SETSIZE and you'll be fine. */
			
		/* The second argument to select() is the address of
			the fd_set that contains sockets we're waiting
			to be readable (including the listening socket). */
			
		/* The third parameter is an fd_set that you want to
			know if you can write on -- this example doesn't
			use it, so it passes 0, or NULL. The fourth parameter
			is sockets you're waiting for out-of-band data for,
			which usually, you're not. */
		
		/* The last parameter to select() is a time-out of how
			long select() should block. If you want to wait forever
			until something happens on a socket, you'll probably
			want to pass NULL. */
		
		readsocks = select(server->highsocket+1,
				   &server->socks,
				   (fd_set *) 0, 
				   (fd_set *) 0,
				   &timeout);
		
		/* select() returns the number of sockets that had
			things going on with them -- i.e. they're readable. */
			
		/* Once select() returns, the original fd_set has been
			modified so it now reflects the state of why select()
			woke up. i.e. If file descriptor 4 was originally in
			the fd_set, and then it became readable, the fd_set
			contains file descriptor 4 in it. */
		
		if (readsocks < 0) {
			perror("select");
			exit(EXIT_FAILURE);
		}
		
		if (readsocks > 0)
		   // something is ready
		   read_socks(server);

		
	} /* while(1) */

#ifdef WIN32
   WSACleanup();
#endif

	return 0;
	
}

/* 	tsalen=sizeof(client->sa); */
/* 	tsocket=accept(server->socket,(struct sockaddr *)&tsa,&tsalen); */

/* 	if(tsocket==-1) { */

/* #ifdef WIN32 */
/* 	   if(WSAGetLastError()!=WSAEWOULDBLOCK) {  */
/* #else			 */
/* 	   if(errno!=EAGAIN) {  */
/* #endif */
/* 	      fprintf(stderr,"What kind of error is this?\n"); // REMOVE */
/* 	      // client fucked up? warn somebody? (error or log or something?) */
/* 	      return 0; // don't process nothing */
/* 	   }; */
		   
/* 	} else { */
		   
/* 	   client=__ILWS_malloc(sizeof(struct web_client)); */
/* 	   if(client==NULL) { */
/* 	      rt=shutdown(tsocket,SHUT_RDWR); */
/* #ifdef WIN32 */
/* 	      rt=closesocket(tsocket);  */
/* #else */
/* 	      rt=close(tsocket);  */
/* #endif */
/* 	      LWSERR(LE_MEMORY); */
/* 	      return 0; */
/* 	   }; */
		
/* 	   client->salen=tsalen; */
/* 	   client->socket=tsocket; */
/* 	   client->sa=tsa; */
		   
/* #ifdef HAVE_OPENSSL */
/* 	   if((server->flags & WS_USESSL) == WS_USESSL) { */
/* 	      client->ssl = SSL_new(server->ctx); */
/* 	      SSL_set_fd(client->ssl,client->socket); */
/* 	      SSL_accept(client->ssl); */
/* 	      //client->cert = SSL_get_peer_certificate (client->ssl); */
/* 	   } else { */
/* 	      client->ssl=NULL; */
/* 	   }; */
/* #endif */
		   
/* 	   if(!__ILWS_add_client(server->client,client)) { */
/* 	      fprintf(stderr,"No client?\n"); // REMOVE */
/* 	      return 0; */
/* 	   }else { */
/* 	      web_log("%s - - [%s] Connected\n", */
/* 		      inet_ntoa(client->sa.sin_addr), */
/* 		      __ILWS_date(time(NULL),"%d/%b/%Y:%H:%M:%S %z")); //REMOBE			 */
/* 	   }; */
	   
/* 	}; */
		
/* 	// end search for client */
/* 	client=server->client; // init list */
/* 	if(!client->next) { // think of Rocco Carbone (rocco@tecsiel.it) */
/* 	   return 2; // i don't need to process the list (nothing next) returns 2 if there is no client to process */
/* 	}; */
	   
/* 	while(client->next!=NULL) { // Process the client and swap to next; */
/* 	   current_web_client=client->next; */
/* 	   switch(client->next->stat) { */
/* 	      case 1: */
/* 		 __ILWS_read_client(current_web_client);		 */
/* 		 break; */
/* 	      case 2: */
/* 		 __ILWS_process_client(current_web_client,server->gethandler); */
/* 		 break; */
/* 	      case 4: */
/* 		 __ILWS_output_client(current_web_client);	 */
/* 		 break; */
/* 	      case 5:  */
/* 		 __ILWS_delete_next_client(client);  */
/* 		 continue; */
/* 	   }; */
/* 	   client=client->next; */
	   
/* 	}; */
	
/* 	return 1;  // return 1 if something processed */
	   


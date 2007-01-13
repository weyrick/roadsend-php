//mingw #include <sys/select.h> 
#include <windows-streams.h>
#include <sys/time.h> 
#include <sys/types.h> 
#include <unistd.h> 

int fdzero(fd_set *fds) {
   FD_ZERO(fds);
   return 0;
}

int fdset(fd_set *fds, int fd) {
   FD_SET(fd, fds);
   return 0;
}

int fd_isset(fd_set *fds, int fd) {
   return FD_ISSET(fd, fds);
}


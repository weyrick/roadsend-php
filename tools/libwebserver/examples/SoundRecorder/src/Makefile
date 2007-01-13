CC=gcc
INCLUDE=-I../include -I../../../include
BIN=../bin
CFLAGS= -O2 -fomit-frame-pointer -Wall -g
DEFINES=-DDEBUG
LIBS=../../../bin/libwebserver.a
LIBDIR=
BINFILE=SoundRecorder

OBJS= main.o soundbuffers.o soundcard.o soundmixer.o



all: $(OBJS)
	$(CC) $(OBJS) $(LIBS) $(LIBDIR) -o ../$(BINFILE)



.c.o:
	$(CC) -c $< $(CFLAGS) $(DEFINES) $(INCLUDE)




clean:
	@echo "Cleaning...";	
	rm -f *.o
	rm -f $(BINFILE)

	
	
		 
		 

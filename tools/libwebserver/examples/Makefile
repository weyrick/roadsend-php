CC=gcc
INCLUDE=-I../include 
CFLAGS=
DEFINES=-DHAVE_CONFIG_H
LIBS=
LIBDIR=
 
all:
	@echo -e "\n\tBuilding examples\n"
	$(CC)  demo.c ../bin/libwebserver.a $(LIBDIR) $(LIBS) $(CFLAGS) $(DEFINES) $(INCLUDE) -o demo       
	$(CC)  packetmounter.c ../bin/libwebserver.a $(LIBDIR) $(LIBS) $(CFLAGS) $(DEFINES) $(INCLUDE) -o packetmounter       
	$(CC)  cgi.c ../bin/libwebserver.a $(LIBDIR) $(LIBS) $(CFLAGS) $(DEFINES) $(INCLUDE) -o cgi       
	cd SoundRecorder; make



clean:
	@rm -f *.log
	@rm -f demo 
	@rm -f packetmounter 
	@rm -f cgi 
	cd SoundRecorder; make clean

distclean: clean
	@rm -f Makefile

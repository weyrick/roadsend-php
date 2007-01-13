CC=gcc
INCLUDE=-I../include 
DEFINES=-DHAVE_CONFIG_H
LIBS= -lm ../bin/libwebserver.a
LIBDIR=
CFLAGS= $(DEFINES) $(INCLUDE) 
LDFLAGS=$(LIBDIR) $(LIBS) 
HEADERS=examples.h functions.h info.h security.h

all: help

help: help.o ../bin/libwebserver.a
	@echo -e "\n\tBuilding Help\n"
	$(CC) -o help $< $(LDFLAGS)

	@cp help ../bin
	@cp help.cfg ../bin
	@cp mime.types ../bin

help.o: $(HEADERS)



$(HEADERS): %.h: ../help.html/%.html
	cat $< | ../tools/data2header $(patsubst %.h,%,$@) > $@

clean:
	@rm -f *.log
	@rm -f help
	@rm -f help.o

distclean: clean
	@rm -f Makefile

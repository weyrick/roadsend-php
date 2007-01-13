PCC_ROOT = ../../
include $(PCC_ROOT)/bigloo-rules.mk

APACHECTL	= /usr/sbin/apachectl

BIGLOO_VERSION  = `bigloo -eval '(begin (print *bigloo-version*) (exit 0))'`     
CINC		= -I $(APACHE_INC) -copt "-I $(APACHE_INC)"

BCOMMONFLAGS	= -L $(PCC_ROOT)libs -copt -I/usr/local/include 

MOD_OBJS	= apache.o apache_request.o apache_multipart_buffer.o apache_cookie.o

all: mod_pcc.so

mod_pcc.so: mod_pcc_$(SU).so
	cp mod_pcc_$(SU).so mod_pcc.so

clean:
	-rm -f *.a *.o *.so $(CLEFTOVERS)

# these commandlines come from the libapreq build process 
# (except for -mms-bitfields, which is my doing --tim)
apache_request.o: apache_request.c
	gcc $(APACHE_CFLAGS) -DPACKAGE_NAME=\"\" -DPACKAGE_TARNAME=\"\" -DPACKAGE_VERSION=\"\" -DPACKAGE_STRING=\"\" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE=\"libapreq\" -DVERSION=\"1.2\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_DLFCN_H=1 -I. -I$(APACHE_INC) -g -O2 -c apache_request.c

apache_multipart_buffer.o: apache_multipart_buffer.c
	gcc $(APACHE_CFLAGS) -DPACKAGE_NAME=\"\" -DPACKAGE_TARNAME=\"\" -DPACKAGE_VERSION=\"\" -DPACKAGE_STRING=\"\" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE=\"libapreq\" -DVERSION=\"1.2\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_DLFCN_H=1 -I. -I$(APACHE_INC) -g -O2 -c apache_multipart_buffer.c

apache_cookie.o: apache_cookie.c
	gcc $(APACHE_CFLAGS) -DPACKAGE_NAME=\"\" -DPACKAGE_TARNAME=\"\" -DPACKAGE_VERSION=\"\" -DPACKAGE_STRING=\"\" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE=\"libapreq\" -DVERSION=\"1.2\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_DLFCN_H=1 -I. -I$(APACHE_INC) -g -O2 -c apache_cookie.c

apache.o: apache.scm $(PCC_ROOT)runtime/php-runtime.sch
	bigloo -c apache.scm $(APACHE_BFLAGS) $(CINC) -L $(PCC_ROOT)libs -I ../ \
               -I $(PCC_ROOT)runtime \
               -copt -DBIGLOO_MAIN=phpoo_initialize\
               -copt -DBIGLOO_EXIT='BUNSPEC,'

mod_pcc_s.so: mod_pcc.c $(MOD_OBJS)
	$(LINK_APACHE_MODULE)

mod_pcc_u.so: mod_pcc.c $(MOD_OBJS)
	$(LINK_APACHE_MODULE_UNSAFE)

full-install: mod_pcc.so 
	apachectl stop
	sleep 2	
	apxs -i -a -n "pcc" mod_pcc.so 
	apachectl start	

install: mod_pcc.so
	cp mod_pcc.so `$(APXS) -q LIBEXECDIR`/mod_pcc.so

install-unsafe: mod_pcc_u.so
	cp mod_pcc_u.so `$(APXS) -q LIBEXECDIR`/mod_pcc.so


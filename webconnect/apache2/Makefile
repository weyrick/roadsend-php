PCC_ROOT = ../../
include $(PCC_ROOT)/bigloo-rules.mk

APACHECTL	= /usr/sbin/apachectl

BIGLOO_VERSION  = `bigloo -eval '(begin (print *bigloo-version*) (exit 0))'`     
CINC2		= -I $(APACHE2_INC) -copt "-I $(APACHE2_INC)" -copt "-I $(APR_INC)"
LIBTOOL_INC	= -I $(APACHE2_INC) -I $(APR_INC)

BCOMMONFLAGS	= -L $(PCC_ROOT)libs -copt -I/usr/local/include 

MOD2_OBJS	= apache2.lo apache_request.lo apache_multipart_buffer.lo apache_cookie.lo

# cgen binary
CGEN		= $(shell which cgen)

all: mod_pcc2.so 

mod_pcc2.so: mod_pcc2_$(SU).so
	cp mod_pcc2_$(SU).so mod_pcc2.so

clean:
	-rm -f *.a *.o *.so $(CLEFTOVERS)
	-rm -r .libs/
	-rm *.la *.lo *.slo

# note this uses libtool
apache2.lo: apache2.scm $(PCC_ROOT)/runtime/php-runtime.sch
	bigloo -c apache2.scm $(APACHE2_BFLAGS) $(CINC2) -L $(PCC_ROOT)libs -I $(PCC_ROOT) \
               -I $(PCC_ROOT)runtime \
		-cc "libtool --mode=compile gcc"\
               -copt -DBIGLOO_MAIN=phpoo_initialize\
               -copt -DBIGLOO_EXIT='BUNSPEC,' 
ifeq ($(PCC_OS),PCC_MINGW)
        # bigloo has a problem calling libtool in windows
	$(WINDOWS_LIBTOOL_HELP)
endif

apache_request.lo: apache_request.c
	libtool --mode=compile gcc $(LIBTOOL_INC) -c apache_request.c

apache_cookie.lo: apache_request.c
	libtool --mode=compile gcc $(LIBTOOL_INC) -c apache_cookie.c

apache_multipart_buffer.lo: apache_request.c
	libtool --mode=compile gcc $(LIBTOOL_INC) -c apache_multipart_buffer.c

mod_pcc2_s.so: mod_pcc2.c $(MOD2_OBJS)
ifeq ($(PCC_OS),PCC_MINGW)
	$(COMPILE_APACHE2_MODULE)
endif
	$(LINK_APACHE2_MODULE)
ifneq ($(PCC_OS),PCC_MINGW)
	cp .libs/mod_pcc2.so mod_pcc2_$(SU).so
endif

mod_pcc2_u.so: mod_pcc2.c $(MOD2_OBJS)
ifeq ($(PCC_OS),PCC_MINGW)
	$(COMPILE_APACHE2_MODULE)
	cp .libs/mod_pcc2.so mod_pcc2_$(SU).so
endif
	$(LINK_APACHE2_MODULE_UNSAFE)
ifneq ($(PCC_OS),PCC_MINGW)
	cp .libs/mod_pcc2.so mod_pcc2_$(SU).so
endif

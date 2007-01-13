#! /bin/bash -x

case $1 in

install)
	cp libprofiler_s.so profiler.heap profiler.init /usr/local/lib/bigloo/2.6c/
	cp libprofiler_u.a /usr/local/lib/bigloo/2.6c/
	ln -sf /usr/local/lib/bigloo/2.6c/libprofiler_s.so  /usr/local/lib/
	ln -sf /usr/local/lib/bigloo/2.6c/libprofiler_u.a  /usr/local/lib/
	ldconfig
	;;
*)
	bigloo -mkaddheap -mkaddlib make-lib.scm -addheap profiler.heap
	bigloo -mkaddheap -mkaddlib -c profiler.scm 
	ld -G -o libprofiler_s.so profiler.o 
	ar ruv libprofiler_u.a profiler.o 
esac



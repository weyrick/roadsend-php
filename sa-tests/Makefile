
all: check

check:
	TEST_PHP_EXECUTABLE="../compiler/pcc" ../compiler/pcc -f run-tests.php

clean: 
	-rm `find ./ -name "*.o" -or -name "*.a" -or -name "*.sc[hm]" -or -name "*.so" -or -iname "*.dll" -or -iname "*.heap"`
	-rm `find ./ -name "*.exp" -or -name "*.out" -or -name "*.rtexp" -or -iname "*.rtout"`
	-rm `find ./tests/ -iname "*.php"`
        # executables
	-rm `find ./ -perm +0111 -and -type f`

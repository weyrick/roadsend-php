
all: check

check: php
	PCC_CONF="./pcc-test.conf" TEST_PHP_EXECUTABLE="./php" ../compiler/pcc -f run-tests.php

check_with_zend: php
	PCC_CONF="./pcc-test.conf" TEST_PHP_EXECUTABLE="./php" php -f run-tests.php

php:
	ln -s ../compiler/pcc ./php

clean: 
	-rm `find ./ -name "*.o" -or -name "*.a" -or -name "*.sc[hm]" -or -name "*.so" -or -iname "*.dll" -or -iname "*.heap"`
	-rm `find ./ -name "*.exp" -or -name "*.out" -or -name "*.rtexp" -or -iname "*.rtout" -or -name "*.diff" -or -name "*.log"`
	-rm `find ./tests/ -iname "*.php"`
	-rm ./php


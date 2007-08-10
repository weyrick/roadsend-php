--TEST--
fastcgi build
--PCCARGS--
--fastcgi myfcgi
--FILE--
<?php 

echo "fastcgi" 

?>
--POSTCOMPILE--
ls ./myfcgi.fcgi
--EXPECT--
./myfcgi.fcgi

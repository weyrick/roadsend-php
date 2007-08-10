--TEST--
fastcgi static build
--PCCARGS--
--fastcgi myfcgi-s --static
--FILE--
<?php 

echo "fastcgi" 

?>
--POSTCOMPILE--
ls ./myfcgi-s.fcgi
--EXPECT--
./myfcgi-s.fcgi

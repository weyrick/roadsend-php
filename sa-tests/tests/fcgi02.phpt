--TEST--
fastcgi static build
--SKIPIF--
<? 

$libs = `ls ../libs/`;
if (!strstr($libs, 'fastcgi'))
    echo "skip no fastcgi lib found";

?>
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

--TEST--
fastcgi build
--SKIPIF--
<? 

$libs = `ls ../libs/`;
if (!strstr($libs, 'fastcgi'))
    echo "skip no fastcgi lib found";

?>
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

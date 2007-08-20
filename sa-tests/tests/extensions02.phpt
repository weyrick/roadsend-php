--TEST--
pcre extension test
--SKIPIF--
<? 

$libs = `ls ../libs/`;
if (!strstr($libs, 'pcre'))
    echo "skip extension library not found";

?>
--POST--
--GET--
--PCCARGS--
-u php-pcre
--FILE--
<?php echo preg_replace ( '/Hello/', 'Goodby', 'Hello World'); ?>
--EXPECT--
--RTEXPECT--
Goodby World

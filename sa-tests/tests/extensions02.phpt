--TEST--
pcre extension test
--POST--
--GET--
--PCCARGS--
-u php-pcre
--FILE--
<?php echo preg_replace ( '/Hello/', 'Goodby', 'Hello World'); ?>
--EXPECT--
--RTEXPECT--
Goodby World

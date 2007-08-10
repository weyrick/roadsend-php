--TEST--
std extension test
--POST--
--GET--
--PCCARGS--
-u php-std
--FILE--
<?php echo  gettype("foo"); ?>
--EXPECT--
--RTEXPECT--
string

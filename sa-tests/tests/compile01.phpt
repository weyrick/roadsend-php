--TEST--
compile safe "Hello World" test
--POST--
--GET--
--PCCARGS--
--FILE--
<?php echo "Hello World"?>
--EXPECT--
--RTEXPECT--
Hello World

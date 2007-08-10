--TEST--
static "Hello World" test
--POST--
--GET--
--PCCARGS--
--static
--FILE--
<?php echo "Hello World"?>
--EXPECT--
--RTEXPECT--
Hello World

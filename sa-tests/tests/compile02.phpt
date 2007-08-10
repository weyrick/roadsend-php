--TEST--
optimized "Hello World" test
--POST--
--GET--
--PCCARGS--
-O
--FILE--
<?php echo "Hello World"?>
--EXPECT--
--RTEXPECT--
Hello World

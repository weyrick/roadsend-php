--TEST--
Interpreted "Hello World" test
--POST--
--GET--
--PCCARGS--
-f
--FILE--
<?php echo "Hello World"?>
--EXPECT--
Hello World

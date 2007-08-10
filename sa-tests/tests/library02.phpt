--TEST--
library optimized build test
--POST--
--GET--
--PCCARGS--
-l library-two -O --force-rebuild
--FILE--
<?php 

function library02 () {
    return "hello world";
}

?>
--EXPECT--
--RTEXPECT--

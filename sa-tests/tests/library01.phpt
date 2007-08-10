--TEST--
library build test
--POST--
--GET--
--PCCARGS--
-l library-one --force-rebuild
--FILE--
<?php

function library01($foo) {
   return $foo;
}

?>
--EXPECT--
--RTEXPECT--

--TEST--
library optimized verify (interpreted)
--POST--
--GET--
--PCCARGS--
-u library-two -f
--FILE--
<?php

if (re_lib_include_exists('tests/library02.php'))
  echo "found\n";

require_once('tests/library02.php');

echo library02()."\n";

?>
--EXPECT--
found
hello world
--RTEXPECT--

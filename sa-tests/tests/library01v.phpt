--TEST--
library verify (interpreted)
--POST--
--GET--
--PCCARGS--
-u library-one -f
--FILE--
<?php

if (re_lib_include_exists('tests/library01.php'))
  echo "found\n";

require_once('tests/library01.php');

echo library01("test")."\n";
?>
--EXPECT--
found
test
--RTEXPECT--

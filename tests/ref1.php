<?php

$foo = 5;
$zot = 7;
$bar =& $foo;
$bar = 8;
$bar =& $zot;
$bar = 9;
echo "$foo, $zot, $bar\n";


?>
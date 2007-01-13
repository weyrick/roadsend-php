<?php

$foo = 5;
$wibb = array($foo, &$foo);
$foo = 6;
echo "$wibb[0], $wibb[1]\n";

$wibb[0] = 9;

$wibb[1] = 10;

echo "$foo, $wibb[0], $wibb[1]\n";

?>
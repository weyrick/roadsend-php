<?php

if (isset($a)) {
	echo "This thing isn't working.\n";
}

$a = "foo";

if (isset($a)) {
	echo "This thing _does_ work!\n";
}

if (isset($a, $b)) {
	echo "Multiple cows at night.\n";
}

$b = 4;
$c = 3;
$d = 9;

if (isset($a, $b, $c, $d)) {
	echo "My hero!\n";
}

?>

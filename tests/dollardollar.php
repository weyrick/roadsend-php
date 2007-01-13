<?php

$bar = 7;
$foo = "bar";

echo "bar is $bar\n";
echo "bar is $$foo\n";
echo "bar is ${$foo}\n";
echo "bar is " . $$foo . "\n"; 

$zot = "foo";

echo "bar is still " . $$$zot . "\n";

$$$zot = "ping";

echo "bar is now $bar (want ping)\n";

$foo = "bar\n";
echo "bar is not " . $$foo . "\n"; 

?>

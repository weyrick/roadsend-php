<?php

$foo = opendir("./");
echo $foo . "\n";
var_dump($foo);
echo "\n\nas an array key:\n";
$bar[$foo] = true;
var_dump($bar);
echo "\n" . get_resource_type($foo) . "\n";

echo "and reading: " . $bar[$foo] . "\n"; 


?>
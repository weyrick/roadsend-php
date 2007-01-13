this inserts the 12 at key 1001, should be at key 2:

check if looking up a big integer key bumps the maximum integer key

<?php

$foo = array("foo", "bar");

print $foo[1000];

$foo[] = 12;

print_r($foo);
?>

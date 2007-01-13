<?php
$foo = "bar";
$bar = 12;
unset($$foo);
echo $bar."\n";
?>


<?php

class foo {
  var $aprop = 12;
}

$bar = new foo();
var_dump($bar);
$zot = 52;

$bar->aprop =& $zot;

$zot = 42;

print "the answer is: " . $bar->aprop . "\n";


?>
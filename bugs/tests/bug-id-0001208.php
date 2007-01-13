<?php

$a1 = array("default");
$a2 = array("default", "secondary");
$a3 = array_merge($a1, $a2);
print "merged: ";
print_r($a3);

$a4 = array_unique($a3);
print "uniqued: ";
print_r($a4);


?>
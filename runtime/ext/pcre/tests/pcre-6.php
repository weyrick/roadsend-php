<?php


print_r(preg_grep("/goo/", array('bake','sale')));

$array = array(1,12,13.2,9.75,4);

// return all array elements
// containing floating point numbers
print_r(preg_grep ("/^(\d+)?\.\d+$/", $array));

?>
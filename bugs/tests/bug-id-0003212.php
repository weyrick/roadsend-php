<?php

class foo {
  var $roles;
}

$one = new foo();
$two = new foo();
$one->roles = array(1, 2, 3);
$two->roles = array(1, 2);

if ($one == $two) {
  echo "same\n";
} else {
  echo "not same\n";
}

?>

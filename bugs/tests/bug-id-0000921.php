<?php

class hi {
  var $string;

  function hi(&$str) {
    $this->string = $str;
    echo $this->string;
  }

}

//Zend php screws up if you pass an unnamed variable by reference
//$n = new hi('blah');
$a = 'blah';
$n = new hi($a);


?>

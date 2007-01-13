0000735 need support for returning a value from a function by reference

<?php

class someClass {
  var $zot = 6;

  function someClass() {
    $this->zot = 2;
  }

  function &test() {
    $a =& new someClass();
    return $a;
  }

}



$b = someClass::test();

echo $b->zot;


?>


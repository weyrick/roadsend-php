0000733 parse error on class property named $parent

<?php

class aclass {
  var $parent = 12;

  function aclass() {
    echo $this->parent . "\n";
  }
}

$zot = new aclass();

?>
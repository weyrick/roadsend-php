<?php

class aclass {
  var $blah = 'ho';
  function unsetit() {
    var_dump($this->blah);
    unset($this->blah);
    var_dump($this->blah);
  }
}

$a = new aclass();
$a->unsetit();

?>
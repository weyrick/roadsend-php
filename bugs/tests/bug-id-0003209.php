<?php

class Foo {
  var $prop;
  var $otherprop;

  function Foo () {
    $this->prop =& $this->otherprop;
    $this->prop = "foo";
  }
}

$foo = new Foo();               
var_dump($foo);
?>

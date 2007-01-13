I dunno if this changed or what, but we just complain about "Cannot use a scalar value as an array", and php bashes it to an array. Test:

<?php

class Foo {
  var $prop = false;

  function Foo () {
    $this->prop['key'] = "value";
  }
}

$foo = new Foo();
var_dump($foo);


$bar = false;
$bar['key'] = 'value';
var_dump($bar);

?>

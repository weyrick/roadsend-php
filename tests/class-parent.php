<?php

class foo {

  var $zot = 12;

  function foo() {
    //    print "foo->zot: $this->zot\n";
    print "This is foo in foo.  Static method invocations can't count on properties, so no zot.\n";
  }

  function anothermethod($a, $b=32) {
    print "foo->anothermethod: $a and $b\n";
  }

}


class bar extends foo {

  var $zot = 14;

  function bar() {
    parent::foo();
    foo::foo();
  }

  function onemethod($a, $b=32) {
    parent::anothermethod(1, 2);
    print "bar->onemethod: $a and $b\n";
  }

  function anothermethod($a, $b=32) {
    parent::anothermethod(2, $b);
    print "bar->anothermethod: $a and $b\n";
  }

}


interface baz {
    function bip();
}

new foo();
$b = new bar();
//foo::foo();

$b->onemethod(1);
$b->anothermethod(1);

echo get_class($b)."\n";
echo get_parent_class($b)."\n";
echo get_parent_class('bar')."\n";
echo get_parent_class('stdClass')."\n";

echo "subclass? ".is_subclass_of($b, 'foo')."\n";
echo "subclass? ".is_subclass_of($a, 'foo')."\n";
echo "subclass? ".is_subclass_of($a, 'stdclass')."\n";
// this is > php 5.0.5
echo "subclass? ".is_subclass_of('bar', 'foo')."\n";

echo "class_exists?".class_exists('bar',false)."\n";
echo "class_exists?".class_exists('baz',false)."\n";
echo "interface_exists?".interface_exists('bar',false)."\n";
echo "interface_exists?".interface_exists('baz',false)."\n";

?>
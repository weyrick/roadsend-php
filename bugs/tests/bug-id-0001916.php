<?php
 
class foo {
  var $member = 'foo';
  function func() {
    if (isset($this)) {
      print "this is set, mem: " . $this->member . "\n";
    } else {
      print "this not set, mem: " . $this->member . "\n";
    }
  }
}
 
class bar extends foo {
  var $member = 'bar';
  function bar() {
    print "calling foo statically:\n";
    foo::func();
    print "calling foo dynamically:\n";
    $foo = new foo();
    $foo->func();
    print "done\n";
  }
}
 
$bar = new bar();
 
?>
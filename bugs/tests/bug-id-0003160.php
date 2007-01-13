this is keeping pweb from working. if the subclass overrides a static method, it can't call the method in its parent class.


<?php

class foo {
  function raiseError() {
    echo "raise error 1\n";
  }
}

class bar extends foo {
  function raiseError() {
    echo "raise error 2\n";
    foo::raiseError();
  }
}

$foo = new bar();
$foo->raiseError();

?>

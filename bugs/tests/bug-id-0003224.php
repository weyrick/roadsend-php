<?php
class foo {
    var $prop = "value";
    function foo() {
        eval('echo $this->prop . "\n";');
    }
}
$foo = new foo();
?>

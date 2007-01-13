parse error on class variable named 'default'

<?php

class myclass {
var $default = 'test';
function blah() {
$this->default = 'meep';
}
}

$c = new myclass();
$c->blah();
echo $c->default;

?>
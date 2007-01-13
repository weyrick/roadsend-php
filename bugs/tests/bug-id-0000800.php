0000800 more string interpolation crazyness

<?php

class testClass {

var $var;

function testClass() {
$this->var['test'] = 'fnord';
echo "can you see the [{$this->var['test']}]?\n";
}

}

$c = new testClass();

?>

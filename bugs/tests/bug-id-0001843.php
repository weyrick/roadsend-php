 print_r doesn't print the fields in objects, it just prints
"Object":

<?php

class foo {
var $zork = "Asdf";
var $bar = "wing";
}

$a = array(new foo(), new foo(), "asdf" => new foo());

print_r($a);

?>
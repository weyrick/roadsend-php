<?php

function foo($arg) {
   var_dump($arg);
}

// test too few args behavior
foo();

// test too many args behavior
foo(1, 2, 3);

?>

<?php

if (!function_exists("zot")) {
  function zot($a, $b) {
    echo "\$a $a, \$b $b\n";
  }
}

if (!function_exists("zot")) {
  function zot($a, $b) {
    echo "woops!";
  }
}

if (!function_exists("print_r")) {
  function print_r($a) {
    echo "woops!";
  }
}

zot("one", 2);
print_r(array(42));

?>
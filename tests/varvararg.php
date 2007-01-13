<?php

//test an argument in a variable variable function
function foo($arg1) {
  $$bazoom = 2;
  print $arg1;
}

//test an argument used as a variable-variable
function bar($arg2) {
  $$arg2 = 2;
  print $$arg2;
}

//test an argument used as a global variable-variable
function zot($arg3) {
  global $$arg3;

  print $$arg3;
}


foo("flop");

bar("zork");

$bing = "printme\n";
zot("bing");

?>

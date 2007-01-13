<?php

define("CONST1", 1);
define("CONST2", 'test');
define("CONST2", CONST2.'ing123');
define("CONST3", CONST2.'ing123');

echo SOME_CONSTANT;
echo CONST1;
echo CONST2;
echo CONST3;

echo "defined1? [".defined('CONST1')."]\n";
echo "defined1a? [".defined(CONST1)."]\n";
echo "defined2? [".defined(SOME_CONSTANT)."]\n";
echo "defined2a? [".defined('SOME_CONSTANT')."]\n";
echo "defined3? [".defined(CONST3)."]\n";
echo "defined3a? [".defined('CONST3')."]\n";
echo "defined4? [".defined(BLAH)."]\n";

echo "test1\n";
if (MY_CONST) {
	echo "here meep\n";
}

echo "test2\n";
if (MY_CONST2 == true) {
	echo "there zang\n";
}

echo "test3\n";
if (MY_CONST2 === true) {
	echo "there zang bazzle\n";
}

echo "test4\n";
if (MY_CONST2 == 1) {
	echo "there zang fizzle\n";
}

echo "test5\n";
if (CONST1) {
	echo "yay!\n";
}

echo "test6\n";
if ("ASDF" == true) {
  print "it was true\n";
}

?>
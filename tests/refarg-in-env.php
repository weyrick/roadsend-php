<?php

$foo = 9;
$bar = 10;
$bar =& $foo;
$bar = 11;

echo "0bar: $bar, foo: $foo\n";

$zot = 12;
$bar =& $zot;
$zot = 13;

echo "1foo: $foo, bar: $bar, zot: $zot\n";

$zot =& $foo;
#is this a zend bug?  $a =& $a seems to copy $a.
#$foo =& $foo;
$bar =& $foo;


#$bar++;

echo "2foo: $foo, bar: $bar, zot: $zot\n";

$bing = "bar";

$broof = "foo";

$barp = "zot";

echo "3foo: ". $$broof . ", bar: " . $$bing . ", zot: " . $$barp . "\n";


function one(&$foo, $bar) {
  $foo = 9;
  $bar = 10;
  $bar =& $foo;
  $bar = 11;
}

one($bar, $foo);
echo "4bar: $bar, foo: $foo\n";


function two($bar, &$zot) {
  $zot = 12;
  $bar =& $zot;
  $zot = 13;
}

two($bar, $zot);
echo "5foo: $foo, bar: $bar, zot: $zot\n";

function three($zot, $foo) {
  $zot =& $foo;
  $foo =& $foo;
  $bar =& $foo;
  $zot =& $bar;
  $bar++;
}

function four(&$zot, &$foo) {

//this screws up zend's implementation.
//  $foo =& $foo;

  $foo++;
}

three($zot, $foo);
echo "6foo: $foo, bar: $bar, zot: $zot\n";

$bar++;
echo "7foo: $foo, bar: $bar, zot: $zot\n";

$zot--;
echo "8foo: $foo, bar: $bar, zot: $zot\n";

$foo-=3;
echo "9foo: $foo, bar: $bar, zot: $zot\n";


four($foo, $zot);
echo "10foo: $foo, bar: $bar, zot: $zot\n";

$foo += 9;

echo "11foo: $foo, bar: $bar, zot: $zot\n";


echo "12foo: ". $$broof . ", bar: " . $$bing . ", zot: " . $$barp . "\n";

?>
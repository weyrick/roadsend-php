0001246 warning on mutation of non reference function parameter

<?php


function modit($var) {
$var = 'i have changed the variable';
}

function modarray($a) {
asort($a);
}

function returncopy($var) {
$var = 'meep';
return $var;
}

function &returnref($var) {
return $var;
}

$a = 'test';
modit($a);
var_dump($a);

$a = array(1,2,3);
modarray($a);
var_dump($a);

$b =& $a;
$a = 'hello';
$c = returncopy($b);
var_dump($c);

$x =& $a;
$a = 'hi ho';
$w = returnref($x);
var_dump($w);

$d = $f = array(5,3,8,2,1);
asort($f);
var_dump($d);
var_dump($f);

$a = array('1' => 'hey there',
'six' => 'snorg',
'blix' => 'bellbottom');

foreach ($a as $k => $v) {
echo "$k => $v\n";
$v = 'changeit';
}

var_dump($a);

class aclass {
var $v = 'initial';
}

$z[] =& new aclass;
$z[] = new aclass;

var_dump($z);

foreach ($z as $c) {
$c->v = 'changed';
}

var_dump($z);

echo "Test return values by reference\n";


function &byref() {
  static $foo;

  $foo++;
  echo "$foo\n";
  return $foo;
}

$bar = byref();
$bar++;
byref();


$bar =& byref();
$bar++;
byref();

echo "Test return values getting copied\n";

function copying() {
  static $foo;

  $foo[] = "asdf";
  var_dump($foo);
  return $foo;
}

$bar = copying();
$bar[] = 22;
copying();


$bar =& copying();
$bar[] = 23;
copying();


?>

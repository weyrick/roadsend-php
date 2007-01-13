0002039: === isn't properly checking types when comparing hashes 

the "identicalp" operator has to check the types of
entries in hashtables and objects too. 

<?php

$a = array(1);
$b = array("1");

if ($a == $b) {
  echo "arrays equal\n";
}

if ($a === $b) {
  echo "arrays identical\n";
}


//the object case

class a {
}

$c = new a();
$c->foo = 1;

$d = new a();
$d->foo = "1";

if ($c == $d) {
  echo "objects equal\n";
}

if ($c === $d) {
  echo "objects identical\n";
}


?>

what about order?

<?php

$a = array(1 => "foo", 2 => "bar");
$b = array(2 => "bar", 1 => "foo");

if ($a == $b) {
  echo "differently ordered arrays are ==\n";
}

if ($a === $b) {
  echo "differently ordered arrays are ===\n";
}

//and objects

class c {
  var $a = 2;
  var $b = 3;
}

$a = new c();
$b = new c();

$a->d = 5;
$a->c = 4;

$b->c = 4;
$b->d = 5;

if ($a == $b) {
  echo "differently ordered objcets are ==\n";
}

if ($a === $b) {
  echo "differently ordered objects are ===\n";
}

?>


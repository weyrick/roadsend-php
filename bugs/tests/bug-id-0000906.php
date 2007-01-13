 disallow overriding scheme functions from php

 right now you can define a php function (con or list for example) and it will override the scheme function

<?php
function car($a) {
  echo $a;
}
function cdr($a) {
  echo $a;
}
function cons($a) {
  echo $a;
}
echo cons('x');
$a[] = 'hi';
foreach ($a as $i) {
  echo $i;
}
?>


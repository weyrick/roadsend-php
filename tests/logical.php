<?php

// !
$a = false;
$b = !$a;
echo !$a;
echo $b;

echo (!$a == $b);

// &&
$a = true;
$b = false;
$c = true;
$d = ($a && ($b && $c));
echo $d;

// ||
$a = true;
$b = false;
$c = true;
$d = ($a || ($b || $c));
echo $d;

// now, the coup de gras
echo ($a && (!$b || ($a && $d)) || $c);

// FIXME need 'and', 'or', 'xor'

?>
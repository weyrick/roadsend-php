0000926: we need more operators

<?php

$a = 10;


echo("*=  ");
$a *= 42;

var_dump($a);

echo("\n/=  ");
$a /= 42;
var_dump($a);

echo("\n.=  ");
$a .= 42;
var_dump($a);

echo("\n%=  ");
$a %= 42;
var_dump($a);

echo("\n&=  ");
$a &= 42;
var_dump($a);

print "\n";
print "152 << 2: ";
print(152 << 2);
print "\n";
print "152 >> 2: ";
print(152 >> 2);


echo("\n|=  ");
$a |= 42;
var_dump($a);

echo("\n^=  ");
$a ^= 42;
var_dump($a);

echo("\n<<=  ");
$a <<= 42;
var_dump($a);

echo("\n>>=  ");
$a >>= 4;
var_dump($a);

?>
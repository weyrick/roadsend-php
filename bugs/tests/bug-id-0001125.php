<?

define('LONG_MAX', is_int(5000000000)? 9223372036854775807 : 0x7FFFFFFF);
define('LONG_MIN', -LONG_MAX - 1);
printf("%d,%d,%d,%d\n",is_int(LONG_MIN ),is_int(LONG_MAX ),
is_int(LONG_MIN-1),is_int(LONG_MAX+1));

$z = 5000000000;
var_dump($z);
$z = 9223372036854775807;
var_dump($z);

echo "this is z: ";
$z = 0x7FFFFFFF;
var_dump($z);

echo "this is -z: ".-$z."\n";

echo "1: ";
$z = (-$z - 1);
var_dump($z);

echo "1a: ";
$z = 0x7FFFFFFF;
$za = -$z;
$zb = ($za - 1);
echo "za is $za, zb is $zb\n"; 
var_dump($zb);

echo "2: ";
$z = ((-$z) + 1);
var_dump($z);

$a = LONG_MIN;
$b = LONG_MAX;
$c = (LONG_MIN-1);
$d = (LONG_MAX+1);

echo "3:";
var_dump($a);
echo "4:";
var_dump($b);
echo "5:";
var_dump($c);
echo "6:";
var_dump($d);

?>
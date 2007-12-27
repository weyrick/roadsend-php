<?

class foo {
}

$a[] = new foo();
$a[] =& new foo();

$b = new foo();
$c =& new foo();
$d = new foo();
$d->a = $b;
$d->b = $c;
$d->a1 =& $b;
$d->a2 =& $c;
$d->a3[] = $a;
$d->a4[] = $b;
$d->a5[] = $c;
$d->a6[] =& $a;
$d->a7[] =& $b;
$d->a8[] =& $c;


var_dump($a);
var_dump($b);
var_dump($c);
var_dump($d);

?>
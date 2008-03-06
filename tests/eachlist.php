<?php



$foo = array ("bob", "fred", "jussi", "jouni", "egon", "marliese");


print_r($foo);

$bar = each ($foo);
print_r($bar);

$bar = each ($foo);
print_r($bar);

$bar = each ($foo);
print_r($bar);


list($zot, $zing) = each ($foo);
echo "zot $zot zing $zing\n";

print_r(array ("a", "wibble" => "b", 1 => "c"));

list ($a, $b, $c) = array ("a", "wibble" => "b", 1 => "c");
echo "a :$a: b :$b: c :$c:\n"; 

list ($a, $b, $c) = array ("foo" => "a", "bar" => "b", "wibble" => "c");
echo "a :$a: b :$b: c :$c:\n"; 

$foo = list ($a, $b, $c) = array (0 => "a", 2 => "b", 3 => "c");
echo "a :$a: b :$b: c :$c:\n"; 

echo "foo $foo\n";
#yes, folks, it _is_ really that bad.

$foo = array("bob", "fred", "jussi", "jouni", "egon", "marliese");

$key = 1;
while ($key !== NULL) {
list($key, $val) = each($foo);
echo "$key => $val\n";
next($foo);
echo "current is:\n";
var_dump(current($foo));
}


?>



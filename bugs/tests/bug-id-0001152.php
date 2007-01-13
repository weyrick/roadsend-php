0001152 string assignment problems
<?php
function error_hdlr($errno, $errstr) {
echo "[$errstr]\n";
}

set_error_handler('error_hdlr');

$i = 4;
$s = "string";

echo "1: ";
$result = "* *-*";
var_dump($result);
echo "2: ";
$result{6} = '*';
var_dump($result);
echo "3: ";
$result{1} = $i;
var_dump($result);
echo "4: ";
$result{3} = $s;
var_dump($result);
echo "5: ";
$result{7} = 0;
var_dump($result);
echo "6: ";
$a = $result{1} = $result{3} = '-';
var_dump($result);
echo "7: ";
$b = $result{3} = $result{5} = $s;
var_dump($result);
echo "8: ";
$c = $result{0} = $result{2} = $result{4} = $i;
var_dump($result);
echo "9: ";
$d = $result{6} = $result{8} = 5;
var_dump($result);
echo "10: ";
$e = $result{1} = $result{6};
var_dump($result);
echo "11: ";
var_dump($a, $b, $c, $d, $e);
echo "12: ";
$result{-1} = 'a';
var_dump($result);
?>

NULLs suck
<?php

$b = 7;
$a = $b = 12;


var_dump($a);
var_dump($b);

$b = "foo";
$a = $b{2} = "p";

var_dump($a);
var_dump($b);

$c = "asdf";
$c{2} = "";
var_dump($c);
?>


this test verifies that the string gets written back into an array
in the case of a one-or-more dimensional array where the last dimension
is actually a string-char.

<?php

//since this test changes the string bar, which will also be used to
//look up the global variable $bar, it succumbs to disappearing
//variable disease when the constants are shared.  -fno-sharing, or
//not using a literal string for the constant catches it.  $bar here
//is to test for it. it's irrelevant to this test, but I happen to
//have discovered it here, so this is where it is.
$bar = 2;

$foo = array("bar");
//now, the 0 is an hash index, but the 3 is a string-char
$foo[0][3] = "b";

var_dump($foo);
echo "and bar:\n";
var_dump($bar);

?>
<?

$a = PHP_INT_MAX;
echo "a is [$a] :: as int [".(int)$a."] as float [".(float)$a."]\n";
echo "$a + 1 = ".($a+1)."\n";
echo "$a++ = ".++$a."\n";
define(PHP_INT_MIN, (- PHP_INT_MAX - 1));
$a = PHP_INT_MIN;
echo "a is [$a] :: as int [".(int)$a."] as float [".(float)$a."]\n";
echo "$a - 1 = ".($a-1)."\n";
echo "$a-- = ".--$a."\n";

?>
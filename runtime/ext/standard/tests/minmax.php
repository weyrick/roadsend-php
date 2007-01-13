<?

echo "max\n";
echo max(-2354, 4325,325 ,23,4) . " " . max("foo", 21) . " " . max(0, 23, 3) . " " . max(5, 5, 5, 4) . max(1.2345, 23.3) . "\n";
echo "max array: ".max(array(8,2,23,9912,5))."\n";
$v = max(array(2, 4, 8), array(2, 5, 1));
echo "max array 2: ".var_dump($v)."\n";
$v = max(array('hi' => 2, 4, 8), array(2, 5, 1), array('yo' => 3, 8, 9, 2));
echo "max array 2a: ".var_dump($v)."\n";
echo "max array 3: ".max('string', array(2, 5, 7), 42)."\n";
echo "max 2: ".max(0, 'hello')."\n";
echo "max 3: ".max('hello', 0)."\n";
echo "max 4: ".max('hello', -1)."\n";

echo "min\n";
echo min(-2354, 4325,325 ,23,4) . " " . min(0, 21) . " " . min(0, 23, 3) . " " . min(5, 5, 5, 4) . min(1.2345, 23.3) . "\n";
echo "min array: ".min(array(8,2,23,9912,5))."\n";
echo "min array 2: ".min(array(2, 4, 8), array(2, 5, 1))."\n";
echo "min array 3: ".min('string', array(2, 5, 7), 42)."\n";
echo "min 2: ".min(0, 'hello')."\n";    // 0
echo "min 3: ".min('hello', 0)."\n";    // hello
echo "min 4: ".min('hello', -1)."\n";    // -1

// in fact, if they both work out to zero, both min and max always
// return their first argument:

echo(max("hello", 0));
echo "\n";
echo(max(0, "hello"));
echo "\n";
echo(min("hello", 0));
echo "\n";
echo(min(0, "hello"));
echo "\n";

echo(max(array(-1, "hello", 0)));
echo "\n";
echo(min(array("hello", 0)));
echo "\n";

?>
<?

// range
$a = range(0, 12);
foreach($a as $number) {
    echo $number;
}
$a = range('a', 'i');
var_dump($a);
foreach($a as $letter) {
    echo $letter;
}
// array('c', 'b', 'a');
$a = range('c', 'a');
foreach($a as $letter) {
    echo $letter;
}

// array_slice
echo "array_splice:\n";
$input = array ("a", "b", "c", "d", "e");
$output = array_slice($input, 2);      // returns "c", "d", and "e"
var_dump($output);
$output = array_slice($input, 2, -1);  // returns "c", "d"
var_dump($output);
$output = array_slice($input, -2, 1);  // returns "d"
var_dump($output);
$output = array_slice($input, 0, 3);   // returns "a", "b", and "c"
var_dump($output);
$output = array_slice($input, 4);
var_dump($output);


// in_array
$os = array ("Mac", "NT", "Irix", "Linux", 55);
if (in_array ("Irix", $os)) {
    print "Got Irix";
}
if (in_array ("mac", $os)) {
    print "Got mac";
}
if (in_array (55, $os, true)) {
    print "strict works";
}
if (in_array ("55", $os, true)) {
    print "strict doesn't work";
}

// array_values
$array = array ("size" => "XL", "color" => "gold");
print_r(array_values ($array));

// current, pos, next, key, prev, end
reset($os);
print current($os);
print key($os);
next($os);
print pos($os);
print key($os);
print prev($os);
print pos($os);
print key($os);
print end($os);
print current($os);
print key($os);
while ($val = prev($os)) {
    echo "prev check: $val\n";
}

// array_reverse
$input  = array('your' => "php", 'my' => 4.0, array("green", "red"));
$result = array_reverse($input);
$result_keyed = array_reverse($input, true);
var_dump($result);
var_dump($result_keyed);

// array_pop
$stack = array("orange", "banana", "apple", "raspberry");
$fruit = array_pop($stack);
print_r($stack);
echo $fruit;

// array_shift
$stack = array("orange", "banana", "apple", "raspberry");
$fruit = array_shift($stack);
print_r($stack);
echo $fruit;

$stack = array('one' => "orange", "banana", 'two' => "apple", "raspberry");
$fruit = array_shift($stack);
print_r($stack);
echo $fruit;

// array_unshift
$queue = array("orange", "banana");
array_unshift($queue, "apple", "raspberry");
var_dump($queue);
$queue = array('one' => "orange", "banana");
array_unshift($queue, "apple", "raspberry");
var_dump($queue);
$queue = array('one' => "orange", "banana");
array_unshift($queue, "apple", array('one' => 'two', '3'), "raspberry");
var_dump($queue);

// array_search
$fruits = array("d" => "lemon", "a" => "orange", 'num' => 5, 'num2' => '5', "b" => "banana", "c" => "apple");
$v = array_search('a', $fruits);
var_dump($v);
$v = array_search('5', $fruits);
var_dump($v);
$v = array_search('5', $fruits, true);
var_dump($v);


?>
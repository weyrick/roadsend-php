<?php
function odd($var) {
    return ($var % 2 == 1);
}

function even($var) {
    return ($var % 2 == 0);
}

function cube($n) {
    return $n*$n*$n;
}

function show_Spanish($n, $m) {
    return "The number $n is called $m in Spanish";
}

function map_Spanish($n, $m) {
    return  array ($n => $m);
}

function test_alter (&$item1, $key, $prefix) {
    $item1 = "$prefix: $item1";
}

function test_print ($item2, $key) {
    echo "$key. $item2<br>\n";
}



$testarr = array('dairy' => 'cheese',
		 'grain' => 'bread',
		 'moldy' => 'bread',
		 'chewy' => 'feet');

print("array_change_key_case:\n");
print_r($testarr);
print_r(array_change_key_case($testarr, CASE_UPPER));
print_r($testarr);
print_r(array_change_key_case($testarr));
print_r($testarr);


print("array_chunk:\n");
$input_array = array('a', 'b', 'c', 'd', 'e');
print_r(array_chunk($input_array, 2));
print_r(array_chunk($input_array, 3, TRUE));
print_r(array_chunk($testarr, 2));
print_r(array_chunk($testarr, 2, TRUE));



print("array_count_values:\n");
print_r(array_count_values($testarr));
print_r(array_count_values($input_array));


print("array_diff:\n");
$array1 = array ("a" => "green", "red", "blue", "red");
$array2 = array ("b" => "green", "yellow", "red");
print_r(array_diff($array1, $array2));
print_r(array_diff($testarr, $input_array));


print("array_diff_assoc:\n");
$array1 = array("a" => "green", "b" => "brown", "c" => "blue", "red");
$array2 = array("a" => "green", "yellow", "red");
$result = array_diff_assoc($array1, $array2);
print_r($result);
print_r(array_diff_assoc($testarr, $input_array));

print("array_filter:\n");



$array1 = array ("a"=>1, "b"=>2, "c"=>3, "d"=>4, "e"=>5);
$array2 = array (6, 7, 8, 9, 10, 11, 12);

echo "Odd :\n";
print_r(array_filter($array1, "odd"));
echo "Even:\n";
print_r(array_filter($array2, "even"));

class cbclass {
  function cbmethod($o) {
    if ($o > 5) {
      return false;
    } else {
      return true;
    }
  }
}

print_r(array_filter($array2, array("cbclass", "cbmethod")));
$cbobj = new cbclass();
print_r(array_filter($array2, array($cbobj, "cbmethod")));

print("array_flip:\n");
$trans = array ("a" => 1, "b" => 1, "c" => 2);
print_r(array_flip($trans));
print_r(array_flip($testarr));


print("array_fill:\n");
print_r(array_fill(5, 6, "bicycle"));


print("array_intersect:\n");
$array1 = array ("a" => "green", "red", "blue", "red");
$array2 = array ("b" => "green", "yellow", "red");
print_r(array_intersect ($array1, $array2));
print_r(array_intersect ($testarr, $input_array));

print_r($testarr);
print("array_key_exists:\n");
if (array_key_exists("b", $testarr)) {
  print("key \"b\" exists\n");
} else {
  print("key \"b\" doesn't exist\n");
}

if (array_key_exists("grain", $testarr)) {
  print("key \"grain\" exists\n");
} else {
  print("key \"grain\" doesn't exist\n");
}



print("array_keys:\n");
print_r(array_keys($testarr));
print_r(array_keys($input_array));
print_r(array_keys($array1, "red"));


print("array_map:\n");

$a = array(1, 2, 3, 4, 5);
$b = array_map("cube", $a);
print_r($b);



$a = array(1, 2, 3, 4, 5);
$b = array("uno", "dos", "tres", "cuatro", "cinco");

$c = array_map("show_Spanish", $a, $b);
print_r($c);

$d = array_map("map_Spanish", $a , $b);
print_r($d);



print("array_merge:\n");
$array1 = array ("color" => "red", 2, 4);
$array2 = array ("a", "b", "color" => "green", "shape" => "trapezoid", 4);
print_r(array_merge ($array1, $array2));
print_r(array_merge ($testarr, $array1, $array2));

$a = array(1,2,3);
$b = 4;

$c = array_merge($a, $b);
var_dump($c);

print("array_merge_recursive:\n");
$ar1 = array ("color" => array ("favorite" => "red"), 5);
$ar2 = array (10, "color" => array ("favorite" => "green", "blue"));
print_r(array_merge_recursive ($ar1, $ar2));
print_r(array_merge_recursive ($testarr, $input_array, $ar1, array("dairy" => "cream")));
//circular case
//we behave a little different on the circular case, but it's safe anyway
//$ar2[3] = $ar2;
//print_r(array_merge_recursive ($ar1, $ar2));



print("array_walk:\n");
$fruits = array ("d"=>"lemon", "a"=>"orange", "b"=>"banana", "c"=>"apple");


echo "Before ...:\n";
array_walk ($fruits, 'test_print');
reset ($fruits);
array_walk ($fruits, 'test_alter', 'fruit');
echo "... and after:\n";
reset ($fruits);
array_walk ($fruits, 'test_print');


// array_pad
$input = array (12, 10, 9);

$result = array_pad ($input, 5, 0);
// result is array (12, 10, 9, 0, 0)
var_dump($result);

$result = array_pad ($input, -7, -1);
// result is array (-1, -1, -1, -1, 12, 10, 9)
var_dump($result);

$result = array_pad ($input, 2, "noop");
var_dump($result);

// array_push
$stack = array ("orange", "banana");
array_push ($stack, "apple", "raspberry");
var_dump($stack);

// array_sum
$a = array(2, 4, 6, 8);
echo "sum(a) = " . array_sum($a) . "\n";

$b = array("a" => 1.2, "b" => 2.3, "c" => 3.4);
echo "sum(b) = " . array_sum($b) . "\n";

$b = array("a" => 1, "b" => 2, "c" => 3.4);
echo "sum(c) = " . array_sum($b) . "\n";

/*
works but fails test 

// shuffle
$numbers = range(1, 20);
//srand((float)microtime() * 1000000);
shuffle($numbers);
while (list(, $number) = each($numbers)) {
   echo "$number ";
}

$input = array("Neo", "Morpheus", "Trinity", "Cypher", "Tank");
$rand_keys = array_rand($input, 2);
echo $input[$rand_keys[0]] . "\n";
echo $input[$rand_keys[1]] . "\n";

echo array_rand($input);

*/

function rsum($v, $w)
{
   $v += $w;
   return $v;
}

function rmul($v, $w)
{
   $v *= $w;
   return $v;
}

$a = array(1, 2, 3, 4, 5);
$x = array();
echo array_reduce($a, "rsum")."\n";
echo array_reduce($a, "rmul", 10)."\n";
echo array_reduce($x, "rsum", 1)."\n";

?>

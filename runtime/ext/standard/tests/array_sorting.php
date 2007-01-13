<?php

// ASORT
print "input:\n";
$input = array("a" => "green", "red", "b" => "green", "blue", "red");
$input2 = array("a" => "green", "red", "b" => "green", "blue", "red");
var_dump($input);
print "asort string:\n";
asort($input2, SORT_STRING);
var_dump($input2);


$input = array(4,"4","3",4,3,"3");
$input2 = array(4,"4","3",4,3,"3");
$input3 = array(4,"4","3",4,3,"3");
$input4 = array(4,"4","3",4,3,"3");
print "input:\n";
var_dump($input);

asort($input2, SORT_STRING);
print "asort string:\n";
var_dump($input2);

asort($input3, SORT_REGULAR);
print "asort regular:\n";
var_dump($input3);
asort($input4, SORT_NUMERIC);
print "asort numeric:\n";
var_dump($input4);

$input = array(2,"3","4",4,"3",4,3,"3",3,"2");
$input2 = array(2,"3","4",4,"3",4,3,"3",3,"2");
$input3 = array(2,"3","4",4,"3",4,3,"3",3,"2");
$input4 = array(2,"3","4",4,"3",4,3,"3",3,"2");
print "input:\n";
var_dump($input);

asort($input2, SORT_STRING);
print "asort string:\n";
var_dump($input2);
asort($input3, SORT_REGULAR);
print "asort regular:\n";
var_dump($input3);
asort($input4, SORT_NUMERIC);
print "asort numeric:\n";
var_dump($input4);

$input = array(7,"3",2,"7",4,3,"2");
$input2 = array(7,"3",2,"7",4,3,"2");
$input3 = array(7,"3",2,"7",4,3,"2");
$input4 = array(7,"3",2,"7",4,3,"2");
print "input:\n";
var_dump($input);

asort($input2, SORT_STRING);
print "asort string:\n";
var_dump($input2);
asort($input3, SORT_REGULAR);
print "asort regular:\n";
var_dump($input3);
asort($input4, SORT_NUMERIC);
print "asort numeric:\n";
var_dump($input4);


// KSORT
print("ksort:\n");
$fruits = array ("d"=>"lemon", "a"=>"orange", "b"=>"banana", "c"=>"apple");
ksort ($fruits);
reset ($fruits);
while (list ($key, $val) = each ($fruits)) {
    echo "$key = $val\n";
}
$fruits = array ("d"=>"lemon", "a"=>"orange", "b"=>"banana", "c"=>"apple");
krsort ($fruits);
reset ($fruits);
while (list ($key, $val) = each ($fruits)) {
    echo "$key = $val\n";
}


// usort, uksort
function cmp($a, $b) {
    if ($a == $b) {
        return 0;
    }
    return ($a < $b) ? -1 : 1;
}

$a = array(3, 2, 5, 6, 1);

usort($a, "cmp");
while (list($key, $value) = each($a)) {
    echo "$key: $value\n";
}

$a2 = array('aba', 'baba', 'caba', 'do');

usort($a2, "cmp");
while (list($key, $value) = each($a2)) {
    echo "$key: $value\n";
}

$b = array(4 => "four", 3 => "three", 20 => "twenty", 10 => "ten");

uksort($b, "cmp");
while (list($key, $value) = each($b)) {
    echo "$key: $value\n";
}

// asort
$fruits = array("d" => "lemon", "a" => "orange", "b" => "banana", "c" => "apple");
asort($fruits);
reset($fruits);
while (list($key, $val) = each($fruits)) {
    echo "$key = $val\n";
}

$fruits = array("d" => "lemon", "a" => "orange", "b" => "banana", "c" => "apple");
arsort($fruits);
reset($fruits);
while (list($key, $val) = each($fruits)) {
    echo "$key = $val\n";
}

// sort, rsort
$fruits = array("d" => "lemon", "a" => "orange", "b" => "banana", "c" => "apple");
sort($fruits);
reset($fruits);
while (list($key, $val) = each($fruits)) {
    echo "$key = $val\n";
}
$fruits = array("d" => "lemon", "a" => "orange", "b" => "banana", "c" => "apple");
rsort($fruits);
reset($fruits);
while (list($key, $val) = each($fruits)) {
    echo "$key = $val\n";
}

$input = array(2,"3","4",4,"3",4,3,"3",3,"2");
$input2 = array(2,"3","4",4,"3",4,3,"3",3,"2");
$input3 = array(2,"3","4",4,"3",4,3,"3",3,"2");
$input4 = array(2,"3","4",4,"3",4,3,"3",3,"2");
print "input:\n";
var_dump($input);

sort($input2, SORT_STRING);
print "sort string:\n";
var_dump($input2);
sort($input3, SORT_REGULAR);
print "sort regular:\n";
var_dump($input3);
sort($input4, SORT_NUMERIC);
print "sort numeric:\n";
var_dump($input4);


$array1 = array("img12.png", "img10.png", "img2.png", "img1.png", "IMG2.png", "img10.PNG");
$array2 = array("img12.png", "img10.png", "img2.png", "img1.png", "IMG2.png", "img10.PNG");
$array3 = array("img12.png", "img10.png", "img2.png", "img1.png", "IMG2.png", "img10.PNG");

sort($array1);
echo "Standard sorting\n";
foreach($array1 as $img) {
    echo "$img\n";
}

natsort($array2);
echo "\nNatural order sorting\n";
foreach($array2 as $img) {
    echo "$img\n";
}

natcasesort($array3);
echo "\nNatural case order sorting\n";
foreach($array3 as $img) {
    echo "$img\n";
}

$array3 = array('one' => "img12.png", 'two' => "img10.png", "img2.png", "img1.png", "IMG2.png", "img10.PNG");
natsort($array3);
echo "\nNatural order sorting\n";
print_r($array3);

$wtfarray = array('One12','oNe6','OnE4','ONE9','onE2');
natcasesort($wtfarray);
echo "\nNatural case order sorting\n";
foreach($wtfarray as $img) {
    echo "$img\n";
}

$b = array(4 => "four", 3 => "three", 20 => "twenty", 10 => "ten", 'blah' => 'zippo', 'blah2' => 'aardvark');

uasort($b, "cmp");
while (list($key, $value) = each($b)) {
    echo "$key: $value\n";
}

// 
$b2 = array('one' => 4,
            'two' => 9,
            'three' => 1,
            'four' => 32,
            'five' => 15);

uasort($b2, "cmp");
while (list($key, $value) = each($b2)) {
    echo "$key: $value\n";
}



?>
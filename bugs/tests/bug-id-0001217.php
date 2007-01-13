<?

class m {
    var $a = 1;
}

class o {
    var $c = 1;
}

$c =& new m();
$d = new o();

echo "grimble: ". ($c == $c) . "\n";
echo "grimble: ". ($d == $d) . "\n";
echo "grumble: ". ($c === $c) . "\n";
echo "grumble: ". ($d === $d) . "\n";


$a = array(1,
           "20",
           100,
           "200",
           array('lo',true, 23, array(1,2), 7=>66),
           true,
           "0f2fj",
           $d,
           array(3),
           "testing",
           NULL,
           array(1,2,3),
           $c,
           1.23,
           "4.31");

$b = array(89,
           "a string",
           "12",
           NULL,
           array(3),
           9321,
           "802",
           $c,
           1.23,
           "00v2nc8",
           array(4,"hi", "blah"=>23, array(1,2)),
           false,
           $d,
           "this is a string",
           "4.31");

foreach ($a as $v1) {
  $i++;
  $j=0;
    foreach ($b as $v2) {
      $j++;
        echo "$i,$j: a is [$v1] and is ".gettype($v1)."\n";
        echo "$i,$j: b is [$v2] and is ".gettype($v2)."\n";
        if (is_string($v1) && is_numeric($v1))
            echo "$i,$j: a is a string and is numeric\n";
        if (is_string($v2) && is_numeric($v2))
            echo "$i,$j: b is a string and is numeric\n";
        echo "$i,$j: a == b: ".($v1 == $v2)."\n";
	var_dump($v1);
	var_dump($v2);
        echo "$i,$j: a === b: ".($v1 === $v2)."\n";
        echo "$i,$j: a < b: ".($v1 < $v2)."\n";
        echo "$i,$j: a > b: ".($v1 > $v2)."\n";
        echo "$i,$j: a <= b: ".($v1 <= $v2)."\n";
        echo "$i,$j: a >= b: ".($v1 >= $v2)."\n";
    }
}

?>
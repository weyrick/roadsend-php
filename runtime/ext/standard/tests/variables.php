<?php

$a = array(NULL, 231, 0, '', 'test', array(1,2,3), true, false);
foreach ($a as $v) {
    echo "empty: [".empty($v)."]\n";
}

print("trying print_r on a recursive array\n");

$testarr = array("foo" => "bar", 1 => 2);
$testarr["baz"] = $testarr;
print_r($testarr);


print("trying var_dump on a recursive array\n");

var_dump($testarr);

$multi = array("key1" => $testarr, "key2" => $testarr);

print("trying print_r on a multiply recursive array\n");

print_r($multi);

print("trying var_dump on a multiply recursive array\n");

var_dump($multi);

class tclass {
    var $a;
    function __toString() {
        return "[class ".__CLASS__."]";
    }
    function tclass() {
        //    $this->a=1;
        $this->a = array('test',array('hi'=>'there'));
    }
}
$obj = new tclass();

// convert to hash
print_r($obj);

$s = "some string";

$a2 = array('string' => 'test',
            'int' => 23,
            'float' => 1.23,
            'null' => NULL,
            'double' => 3.21,
            'array' => array('a'),
            'object' => $obj,
            'object ref' => &$obj,
            'string ref' => &$s,
            'boolean' => false);

var_dump($a2);

$a = array('string' => 'test',
           'int' => 23,
           'float' => 1.23,
           'null' => NULL,
           'double' => 3.21,
           'array' => array('a'),
 //           'object' => $obj,
           'boolean' => false);

$lastkey=NULL;
foreach ($a as $t => $v) {
    echo "$t ===> ".gettype($v)."\n";
    echo is_string($v);
    echo is_int($v);
    echo is_integer($v);
    echo is_float($v);
    echo is_null($v);
    echo is_double($v);
    echo is_array($v);
    echo is_object($v);
    echo is_bool($v);

    // settype
    $e = $v;
    echo "e is now $e ===> ".gettype($e)."\n";
    if (!empty($lastkey)) {
        echo "changing to $lastkey\n";
        settype($e, $lastkey);
        echo "after change, e is now $e ===> ".gettype($e)."\n";
    }
            
    $lastkey=$t;
}


$z = 1;
$x = 'hi';
$y = true;
$v = NULL;
$w = 1.23;
$u = array(1,2,3);

$a = array($z, $x, $y, $v, $w, $u);
$b = array(&$z, &$x, &$y, &$v, &$w, &$u);
var_dump($a);
var_dump($b);

$a = 1;
$b =& $a;
var_dump($b);

class uclass {
    var $a;
    var $b;
    function uclass() {
        global $a;
        $this->b =& $a;
        $this->a = array('test',array('hi'=>'there'));
    }
}
$obja = new uclass();
$objb =& new uclass();
var_dump($obja);
var_dump($objb);

?>
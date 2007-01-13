<?php

function test_ser($val) {

    $sv = serialize($val);
    echo "val is $val, type: ".gettype($val)." serialize is \n$sv\n";
    $usv = unserialize($sv);
    var_dump($usv);

    return $usv;
}

$glob = "glob";
$bax = 'bax';
$moz = 'moz';

$a = array(&$glob, &$glob, &$moz, &$bax, &$glob, &$bax, &$moz, &$glob);
test_ser($a);

$a = array($glob, &$glob, &$moz, &$bax, &$glob, &$bax, $bax, $glob, &$moz);//, &$glob);
test_ser($a);


$globa = 'my global hi there';

class myClass {
    var $p1 = NULL;
    var $p2 = 'hi th";ere';
    var $p3 = array(1,2,3);
    var $p4 = true;
    var $p5 = NULL;
    var $p6 = false;

    function multi() {
        global $globa;
        $this->p5 =& new zot();
        $this->p6 =& $globa;
        $this->p3[] =& $globa;
    }    
    function hello() {
        echo 'hello';
    }

    function __wakeup() {
        echo "yay i woke up!!!\n";
    }
}

class zot {
    var $prop = array(1,2,array("hah"=>'yoles'));
}

$a = array('one'=>'nine','string'=>'two', array(1=>'six', array(4,2,1)),'2');
//$a[] =& $a;
$a[] =& $globa;
$a[] = 'breaker';
$a[] = $a;
$a[] = $globa;
$a['luck'] =& $globa;
$b = test_ser($a);

// test ref assignment from unserialized array
$b['luck'] = 'new val';
var_dump($b);

$sing =& $globa;
$b = test_ser($sing);



$a = array('my global hi there', $globa, &$globa, 'nonref' => $globa, 'ref' => &$globa);
$a[] =& $globa;
test_ser($a);

$c = new myClass();
$c->multi();
$d = test_ser($c);

$d->p6 = 'new val';
var_dump($d);

$a = array('hi', &$a);
test_ser($a);

?>
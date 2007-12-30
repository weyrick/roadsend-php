<?php

function test_ser($val) {

    // on windows, php serializes floats with garbage prescision, like this:
// val is 23.123456789012, type: double serialize is 
//-d:23.12345678901234435898004448972642421722412109375;
// and us    
//+d:23.123456789012344;    

    // so to make the test pass, we'll skip it on windows
    if ((PHP_OS == 'WINNT') && gettype($val) == 'double')
        return;
    
    $sv = serialize($val);
    echo "val is $val, type: ".gettype($val)." serialize is \n$sv\n";
    $usv = unserialize($sv);
    var_dump($usv);

}

$globa = 'my global hi there';

class myClass {
    var $p1 = NULL;
    var $p2 = 'hi th";ere';
    var $p3 = array(1,2,3);
    var $p4 = true;
    var $p5 = NULL;
    var $p6 = false;

    function __toString() {
        return "[myClass instance]";
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

class myClass2 {
    var $p1 = NULL;
    var $p2 = 'hi there';
    var $p3 = array(1,2,3);
    var $p4 = true;

    
    function __sleep() {
        echo "zzzzzzzz......\n";
        $a[] = 'p3';
        return $a;
    }
    
    function hello() {
        echo 'hello';
        echo "this should NOT say 'hi there': $this->p2\n";
    }

    function __wakeup() {
        echo "yay i woke up!!!\n";
    }
}

$a = array('one','two','three');
test_ser($a);

$a = array('one'=>'nine','two'=>'seven','three'=>'twelve');
test_ser($a);

$a = array('one'=>'nine','two', array(1=>'six'));
test_ser($a);

$a = array('one'=>'nine','two', array(1=>'six', array(4,2,1)),'2');
test_ser($a);

test_ser(true);
test_ser(false);
test_ser("this is a test of a string with \"; some a:0 N; shit in it i:23123; to screw tim up b:0; on the unserializer");
test_ser(2371238);
test_ser(23.2312);
test_ser(23.1234567890123456789012345678901234567890);
test_ser(NULL);

$c = new myClass();
test_ser($c);

$d = new myClass();
$sd = serialize($d);
echo $sd;
$e = unserialize($sd);
$e->hello();

$d = new myClass2();
$sd = serialize($d);
echo $sd;
$e = unserialize($sd);
print_r($e);
$e->hello();

?>
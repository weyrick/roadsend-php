<?

class Foo {

    function __construct() {
        echo __CLASS__.' -- '.__METHOD__."\n";
        echo "location is ".basename(__FILE__)." on line ".__LINE__."\n";
    }

    function testm() {
        echo __CLASS__.' -- '.__METHOD__."\n";
        echo "function: ".__FUNCTION__."\n";
    }

    function testm2() {
        echo __CLASS__.' -- '.__METHOD__."\n";
    }

}


class BaR extends Foo {
    
    function __construct() {
        echo __CLASS__.' -- '.__METHOD__."\n";
        echo "function: ".__FUNCTION__."\n";
        echo "location is ".basename(__FILE__)." on line ".__LINE__."\n";
    }

    function testm2() {
        echo __CLASS__.' -- '.__METHOD__."\n";
        echo "location is ".basename(__FILE__)." on line ".__LINE__."\n";
    }
}

function testfunc() {
    echo "function: ".__FUNCTION__."\n";
}

echo __CLASS__.' -- '.__METHOD__.", function: ".__FUNCTION__."\n";

echo "location is ".basename(__FILE__)." on line ".__LINE__."\n";

$f = new foo();
$f->testm();
$f->testm2();

$f = new bar();
$f->testm();
$f->testm2();

testfunc();

?>
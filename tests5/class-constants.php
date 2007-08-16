<?php

class foo {
    static $p1 = array(1, 2, 3);
    static $p2 = "foo";
}

class bar extends foo {
    static $p2 = "bar";
    static $p3 = 2;
}

$o1 = new foo();
print_r($o1);
var_dump($o1);
// class constants cannot be accessed via normal -> syntax
var_dump($o1->p1);
$o2 = new bar();
// class constants are not printed by print_r or var_dump
print_r($o2);
var_dump($o2);

// class constants are inherited
var_dump(foo::$p1);
var_dump(foo::$p2);
var_dump(bar::$p1);
var_dump(bar::$p2);
var_dump(bar::$p3);
?>
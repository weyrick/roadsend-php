<?php

class foo {
    static $p1 = array(1, 2, 3);
    static public $p2 = "foo";
    protected static $p5 = "bar";
    private static $p6 = "baz";
    static $p7 = 0;
    function inc() {
      self::$p7 = 20;
    }
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

$o1->inc();
var_dump(foo::$p7);

class Foo2
{
    public static $my_static = 'foo';

    public function staticValue() {
        return self::$my_static;
    }
}

class Bar2 extends Foo2
{
    public function fooStatic() {
        return parent::$my_static;
    }
}


print Foo2::$my_static . "\n";

$foo = new Foo2();
print $foo->staticValue() . "\n";
print $foo->my_static . "\n";      // Undefined "Property" my_static

// $foo::my_static is not possible

print Bar2::$my_static . "\n";
$bar = new Bar2();
print $bar->fooStatic() . "\n";

?>
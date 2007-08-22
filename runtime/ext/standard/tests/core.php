<?php

putenv("TEST_ENV=testval");

$val = getenv("TEST_ENV");
echo "the environment value is: [$val]\n";

class myClass {

    function someFunction($a, $b) {
        echo "in class with someFunction $a and $b\n";
    }
    
}

function aFunction($a, $b) {
    echo "in aFunction $a and $b\n";
}

call_user_func('aFunction', 'zorp', 'zot');
call_user_func(array('myClass','someFunction'), 'zorp', 'zot');

call_user_func_array('aFunction', array('bleep','bloop'));

$c = new myClass();
call_user_method('someFunction', $c, 'fnick', 'fnack');
call_user_method_array('someFunction', $c, array('wibble', 'wobble'));

// preferred method for calling method functions
call_user_func(array(&$c, 'someFunction'),'here','there');

echo "1:".class_exists('someblahclass'); echo "\n";
echo "2:".class_exists('myClass'); echo "\n";

echo "3:".method_exists('myClass','someFunction'); echo "\n";
echo "4:".method_exists('myClass','aFunction'); echo "\n";
echo "5:".method_exists('noClass','someFunction'); echo "\n";

/////

$cl = get_declared_classes();
// this works, but is different order than php
//var_dump($cl);

set_include_path("./:/home/test");
echo get_include_path()."\n";

define('FOO', 'bar');
define('ZoT', 'baz');

$v = get_defined_constants();
// different from zend
//var_dump($v);

echo "Last modified: " . date ("F d Y H:i:s.", getlastmod());

if (PHP_OS != 'WINNT') {
    echo get_current_user()."\n";
// works, but fails test due to difference with php script
//echo getmypid()."\n";
    echo getmyuid()."\n";
    echo getmygid()."\n";
}


function someFunction()
{
}

$functionVariable = 'someFunction';

var_dump(is_callable($functionVariable, false, $callable_name));  // bool(true)
var_dump(is_callable($functionVariable, true, $callable_name));  // bool(true)

echo $callable_name, "\n";  // someFunction

//
//  Array containing a method
//

class someClass {

  function someMethod()
  {
  }

}

$anObject = new someClass();

$methodVariable = array($anObject, 'someMethod');

var_dump(is_callable($methodVariable, true, $callable_name));  //  bool(true)
var_dump(is_callable($methodVariable, false, $callable_name));  //  bool(true)
echo $callable_name, "\n";  //  someClass:someMethod

// these are intential screwups
var_dump(is_callable(array(), true, $callable_name));  //  bool(true)
var_dump(is_callable(array(1,2), true, $callable_name));  //  bool(true)
var_dump(is_callable(32131, true, $callable_name));  //  bool(true)


?>

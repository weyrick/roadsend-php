<?php

// demonstrate that lowercase constants cannot coexist with
// case-insensitive constants
define("lower", 42, true);
define("lower", 12);


print("Lower is " . lower . "\n");
print("Lower is " . LOWER . "\n");

// demostrate that uppercase constants _can_ coexist with
// case-insensitive constants
define("UPPER", 42, true);
define("UPPER", 12);

print("Upper is " . upper . "\n");
print("Upper is " . UPPER . "\n");

// demonstrate that mixed case behaves like uppercase
// (can coexist)
define("MId", 42, true);
define("MId", 12);

print("Mid is " . MId . "\n");
print("Mid is " . MID . "\n");

// now show that the case-sensitivity bit is not overridden by 
// subsequent definitions
define("sensible", 12);
define("sensible", 42, true);

print("Sensible is " . sensible . "\n");
print("Sensible is " . SENSIBLE . "\n");


define (ACONSTANT, false);
print("ACONSTANT is :");  var_dump(ACONSTANT);

$foo = 'DYNAMIC_CONSTANT';
$bar = 'second-val';
define($foo, $bar);
echo "constant: ".DYNAMIC_CONSTANT."\n";

?>
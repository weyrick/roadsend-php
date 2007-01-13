0001017	need static variables in class methods in interpreter

<?php

class aclass {
  function amethod() {
    static $foo;
    
    return $foo++;
  }	
}

print aclass::amethod() . "\n";
print aclass::amethod() . "\n";
print aclass::amethod() . "\n";

$anobj = new aclass();

print $anobj->amethod() . "\n";
print $anobj->amethod() . "\n";
print $anobj->amethod() . "\n";



?>
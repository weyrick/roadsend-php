An example from the PHP docs demonstrating copy suppression without losing 
the reference stuff.
<?php

class aclass { }
$instance = new aclass();

$assigned  =  $instance;
$reference  =& $instance;

// This is so we can see that $instance wasn't copied above.  In php5
// mode, it would've been.
$instance->var = '$assigned will have this value';

$instance = null; // $instance and $reference become null

print_r($instance);
print_r($reference);
print_r($assigned);

?>
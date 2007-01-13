<?php

$input = "Alien";
print str_pad($input, 10) . "\n";                     
print str_pad($input, 10, "-=", STR_PAD_LEFT) . "\n"; 
print str_pad($input, 10, "_", STR_PAD_BOTH) . "\n";  
print str_pad($input, 10, "-=", STR_PAD_BOTH) . "\n"; 
print str_pad($input, 11, "-=", STR_PAD_BOTH) . "\n"; 
?>

<?php

$a = array( 1 => 'one', 2 => 'two', 3 => 'three' );
unset( $a[2] );
/* will produce an array that would have been defined as
   $a = array( 1=>'one', 3=>'three');
   and NOT
   $a = array( 1 => 'one', 2 => 'three');
*/

print_r($a);

$a=5;$b=array(1);$c="string";
echo "i1: ".isset($a,$b,$c)."\n";
echo "i2: ".isset($a,$b,$c,$d)."\n";
unset($a,$b,$c);
echo "i3: ".isset($a,$b,$c)."\n";

?>
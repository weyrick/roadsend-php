the reference property belongs to values, not hash slots

in this case, both entries in the array are references, because there is only 
one value and it's a reference. pcc does not implement this correctly:



<?php

$foo = array("bar");
$foo[1] =& $foo[0];
var_dump($foo);

?>



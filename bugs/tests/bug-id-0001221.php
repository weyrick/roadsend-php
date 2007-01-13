0001221 badness in the interpreter with multidimensional arrays

$foo[0][0] works, but $a=0; $foo[0][$a] doesn't.

<?php

$foo[0][0] = "asdf";
$a = 0;
//print("foo[0][0] is " . $foo[0][0] . "\n");
print("with a variable it's " . $foo[$a][0] . "\n");

?>


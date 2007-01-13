unset() needs to take variable number of arguments

<?php

$a = 'hi';
$b = 'yo';
$c = 'man!';

echo "$a, $b, $c\n";
unset($a, $b, $c);
echo "$a, $b, $c\n";

?>
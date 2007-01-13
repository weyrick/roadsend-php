When incrementing inside an element of an array, the var ($count in this case) seams to get incremented by the number of elements being addressed.

i.e. $count is 2 at the end here
<?
$count=0;
$foo[++$count][0] = 'bar';
print "$count\n";
$bount=0;
$zot = $foo[++$bount][0];
print "$bount\n";

?>

and $count is 3 at the end here
<?
$count=0;
$foo[++$count][0][1] = 'bar';
print "$count\n";
?>


check the reference case, too:

<?php

$count=0;
$foo[++$count][1][3] =& $count;
print "$count\n";
var_dump($foo);
?>

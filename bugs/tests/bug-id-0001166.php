0001166 nested foreach problem

Additional Information i'm sure this has to do with the internal array
index. not sure how php handles it but it works ok in php, ie it
iterates through all items for each nest level.

<?php


$a = array('1','2','3','4');

foreach ($a as $v) {
  foreach ($a as $k) {
    print "a1 is $v while a2 is $k\n";
  }
}


?>


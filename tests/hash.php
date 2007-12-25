<?php
$n = ($argc == 2) ? $argv[1] : 100;
//print "$n\n";
for ($i = 1; $i <= $n; $i++) {
    $X[dechex($i)] = $i;
}
//print "$n\n";
//print "$i\n";
//print "$X\n";
for ($i = $n; $i > 0; $i--) {
  //  print "wibble $i";
  //  print "$X[$i]\n";
  if ($X[$i]) { /* print "wobble"; */ $c++; }
}

print "$c\n";
var_dump($X);

?>


TEST things that can't be in hashes

<?php

class aclass {}
$anobj = new aclass();
@$ahash[$anobj] = 12;
var_dump($ahash);

@$ahash[$ahash] = 42;
var_dump($ahash);

//NULL becomes the empty string 
$ahash[NULL] = 19;
var_dump($ahash);

?>


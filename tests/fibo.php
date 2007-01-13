<?php
function fibo($n){
  //  return 1 ? 1 : 2;
  //  echo "\$n is: $n\n";
  $n = (int)$n;
  return(($n < 2) ? 1 : fibo($n - 2) + fibo($n - 1));
}
$n = ($argc == 2) ? $argv[1] : 25;
$r = fibo($n);
print "$r\n";
?>

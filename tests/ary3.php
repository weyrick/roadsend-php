<?php

function foo() {
$n = 1000;
for ($i=0; $i<$n; $i++) {
    $X[$i] = $i + 1;
}
for ($k=0; $k<100; $k++) {
    for ($i=$n-1; $i>=0; $i--) {
	$Y[$i] += $X[$i];
    }
}

$last = $n-1;
print "$Y[0] $Y[$last]\n";
}

foo();

?>

<?php

#test calling a function using the string that is its name

function mofun($moarg) {
	echo "called with $moarg.\n";
}

$fun = "mofun";

$fun("does this work?");

#this doesn't work, and isn't meant to
#"mofun"("does this work?");


function fun_with_ref_arg($foo, &$bar) {
	echo "called with $foo, $bar.\n";	
	$bar++;
}

$bar = 3;
$fun = "fun_with_ref_arg";

$fun("trash", $bar);
echo "bar is now $bar\n";

function fun_with_opt_arg($foo, $bar, $baz=2) {
	echo "called with $foo, $bar, $baz.\n";
}


$fun = "fun_with_opt_arg";

$fun("trash", "bork");
$fun("trash", "bork", $bar);



?>
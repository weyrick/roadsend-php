<?php

$input = '';
for($i=0; $i<512; $i++) {
	$input .= chr($i%256);
}


$foo = '\\&quote; \\foo 4: \\\\ 2: \\ 1: ---- \\" \\\'';
var_dump($foo);

$bar = stripslashes($foo);
var_dump($bar);

// mingw diff shows a difference if we display this, but there
// doesn't appear to be one. the rest of the test passes.
//if (PHP_OS != 'WINNT')
//    echo "Normal: $input";
    
ini_set('magic_quotes_sybase', 0);
if($input === stripslashes(addslashes($input))) {
	echo "OK\n";
} else {
	echo "FAILED\n";
}

echo "Sybase: ";
ini_set('magic_quotes_sybase', 1);
if($input === stripslashes(addslashes($input))) {
	echo "OK\n";
} else {
	echo "FAILED\n";
}


?>

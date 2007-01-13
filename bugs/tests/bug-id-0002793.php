<?php

function bar() {
	$a = "foo";
	$b = "foo";
	$c =& $a;
	$d = $a;
	$a{0} = 'b';
	print "$a\n";
	print "$b\n";
	print "$c\n";
	print "$d\n";
}

bar();
?>

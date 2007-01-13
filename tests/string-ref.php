<?php

function foo() {
	return "f";
}

$bar = "ooo";
$bar{0} = foo();

echo $bar{0} . $bar{1} . $bar{2};

?>
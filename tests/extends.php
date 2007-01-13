<?php


class base {
	
	var $base_var = "base";	

	function base () {
		print "$this->base_var boogey woogey\n";
	}	

	function base_method () {
		print "a method in $this->base_var\n";
	}

	function arith_op ($a, $b) {
		print "base adds $a and $b, to get: " . ($a + $b) . "\n";
	}
}

$abase = new base();
$abase->base_method();
$abase->arith_op(1, 2);

class child extends base {

	function arith_op ($a, $b) {
		print "child multiplies $a and $b, to get: " . ($a * $b) . "\n";
	}

	function child_method() {
		print "not a method in $this->base_var\n";
	}

}

$achild = new child();
$achild->base_method();
$achild->child_method();
$achild->arith_op(1, 2);


class grandchild extends child {

	function grandchild($foo) {
		$this->base_var = "grandchild";
		print "you just became a grandfather! $foo.\n";
	}

}

$agrandchild = new grandchild("bar");
$agrandchild->base_method();
$agrandchild->child_method();
$agrandchild->arith_op(1, 2);



?>
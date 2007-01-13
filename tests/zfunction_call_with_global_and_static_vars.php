<?php  error_reporting(0);
	$a = 10;
	function Test()
	{
		static $a=1;
		global $b;
		$c = 1;
		$b = 5;
		echo "one $a $b one";
		$a++;
		$c++;
		echo "two $a $c two";
	}
	Test();	
	echo "buckle $a $b $c my";
	Test();	
	echo "shoe $a $b $c shoe";
	Test()?>

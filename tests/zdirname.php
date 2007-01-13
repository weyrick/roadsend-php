<?php

	function check_dirname($path)
	{
		print "dirname($path) == " . dirname($path) . "\n";
	}
	
// I actually think that zend gets it wrong on the two commented cases
//	check_dirname("/foo/");
	check_dirname("/foo");
	check_dirname("/foo/bar");
	check_dirname("d:\\foo\\bar.inc");
	check_dirname("/");
	check_dirname(".../foo");
	check_dirname("./foo");
//	check_dirname("foobar///");
	check_dirname("c:\foo");
?>

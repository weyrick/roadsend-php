<?php

if (!extension_loaded('gtk')) {
	dl( 'php_gtk.' . PHP_SHLIB_SUFFIX);
}

$drawing_area = &new GtkDrawingArea();
$drawing_area = &new GtkDrawingArea();
var_dump($drawing_area);
//the wrappers have ID numbers in them.  we want to make sure that we
//can correctly find the same wrapper for the same gtk object.
var_dump($drawing_area->style);
var_dump($drawing_area->style);
$drawing_area = &new GtkDrawingArea();
var_dump($drawing_area->style);
//var_dump($drawing_area->style->white);

//todo: test that it works in the gtkobject case too (gtkstyle is not a gtkobject)

?>

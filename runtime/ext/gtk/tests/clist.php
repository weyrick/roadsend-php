test the custom properties of a gtkclist
<?php

if (!extension_loaded('gtk')) {
	dl( 'php_gtk.' . PHP_SHLIB_SUFFIX);
}

$titles = array("auto resize", "not resizeable", "max width 100",
		"min width 50", "hide column", "Title 5", "Title 6",
		"Title 7", "Title 8",  "Title 9",  "Title 10", "Title 11");
$clist = &new GtkCList(12, $titles);

echo "the clist: ";
var_dump($clist);
 


$text = array('This', 'is an', 'inserted', 'row.',
	      'This', 'is an', 'inserted', 'row.',
              'This', 'is an', 'inserted', 'row.');

$row = $clist->prepend($text);
$row = $clist->prepend($text);

var_dump($row);

echo "\n\n-- in gtkwidget: \n";

echo "\nstyle\n";
var_dump($clist->style);

echo "\nwindow\n";
var_dump($clist->window);

echo "\nallocation\n";
var_dump($clist->allocation);

echo "\nstate\n";
var_dump($clist->state);

echo "\nparent\n";
var_dump($clist->parent);



echo "\n\n-- in gtkclist itself: \n";

echo "\nfocus_row\n";
var_dump($clist->focus_row);

echo "\nrows\n";
var_dump($clist->rows);

echo "\nsort_column\n";
var_dump($clist->sort_column);

echo "\nsort_type\n";
var_dump($clist->sort_type);

echo "\nselection\n";
var_dump($clist->selection);

echo "\nselection_mode\n";
var_dump($clist->selection_mode);

echo "\nrow_list\n";
var_dump($clist->row_list);

var_dump($clist->row_list[0]);

//this produces a warning about not being able to assign to a overloaded property "row_list"
//$clist->row_list[2] = 4;

var_dump($clist->row_list);

//this should signal an error
//$foo =& $clist->row_list;

//so should this
//$bar =& $clist->window;

//this works in zend php
$foo = $clist->row_list;
foreach($foo as $a => $b) {
  print "$a $b\n";
}

//but this doesn't
// foreach($clist->row_list as $a => $b) {
//   print "$a $b\n";
// }

print("test at 1,2: " . $clist->get_text(1, 2) . "\n");

?>
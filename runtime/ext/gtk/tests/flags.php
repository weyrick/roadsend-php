make sure that flags are working about the same
<?php

if (!extension_loaded('gtk')) {
	dl( 'php_gtk.' . PHP_SHLIB_SUFFIX);
}

$button =& new GtkButton('foo');
echo "button flags: \n";
var_dump($button->flags());

echo "flag: \n";
var_dump(GTK_CAN_DEFAULT);

$button->set_flags(GTK_CAN_DEFAULT);
echo "new button flags: \n";
var_dump($button->flags());

?>
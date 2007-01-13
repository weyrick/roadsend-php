<?php
if (!extension_loaded('gtk')) {
	dl( 'php_gtk.' . PHP_SHLIB_SUFFIX);
}

function delete_event($widget)
{
	return false;
}

function shutdown($widget)
{
	print("Shutting down...\n");
	gtk::main_quit();
}

function hello($widget)
{
	global $window;
	print "Hello World!\n";
}

$window = &new GtkWindow(GTK_WINDOW_POPUP);
$window->connect('destroy', 'shutdown');
$window->connect('delete-event', 'delete_event');
$window->set_border_width(10);

$button = &new GtkButton('Hello World!');
$button->connect('clicked', 'hello');
$window->add($button);

$window->show_all();

ob_implicit_flush(true);

gtk::main();

?>



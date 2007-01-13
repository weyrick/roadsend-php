Just check if some random enum works
<?php
if (!extension_loaded('php-gtk')) {
	dl( 'php_gtk.' . PHP_SHLIB_SUFFIX);
}

print Gtk::BUTTONS_CLOSE ."\n";
print Gdk::BUTTON1_MASK ."\n";
print Gdk::WINDOW_TOPLEVEL ."\n";

?>
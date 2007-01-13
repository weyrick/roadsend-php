<?php

/***
 *
 * This is a sample PHP-GTK project
 *
 * More information on PHP-GTK can be found here:
 * http://gtk.php.net
 *
 * The entry point into the project is the Main File, which you can set in
 * Project Properties.
 *
 * The project can be Compiled and Run but click the green Play button above.
 * You can also run it in the debugger by clicking the "Run In Debugger" button
 * in the debugger toolbar.
 *
 */


/*
 * Called when the window is being destroyed. Simply quit the main loop.
 */
function destroy($arg)
{
	Gtk::main_quit();
}

/*
 * Called when delete-event happens. Returns false to indicate that the event
 * should proceed.
 */
function delete_event()
{
	return false;
}


/*
 * Called when button is clicked. Print the message and destroy the window.
 */
function hello_world($arg)
{
	global $window;
	print "Hello World!\n";
    // this must be called to exit the program properly
	$window->destroy();
}

/*
 * Create a new top-level window and connect the signals to the appropriate
 * functions. Note that all constructors must be assigned by reference.
 */
$window =& new GtkWindow();
$window->connect('destroy', 'destroy');
$window->connect('delete-event', 'delete_event');
$window->set_border_width(10);

/*
 * Create a button, connect its clicked signal to hello() function and add
 * the button to the window.
 */
$button =& new GtkButton('Hello World!');
$button->connect('clicked', 'hello_world');
$window->add($button);

/*
 * Create a new tooltips object and use it to set a tooltip for the button.
 */
$tt =& new GtkTooltips();
$tt->set_delay(200);
$tt->set_tip($button, 'Prints "Hello World!"', '');
$tt->enable();

/*
 * Show the window and all its child widgets.
 */
$window->show_all();

/* Run the main loop. */
Gtk::main();

?>
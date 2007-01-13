<?php

$obj = new GtkButton();

$obj->set_data("foo", "this is a string");
echo "the data:  " . $obj->get_data("foo") . "\n";


?>
<?php

// Provides: <body text='black'>
echo str_replace("%body%", "black", "<body text='%body%'>");


// Provides: Hll Wrld f PHP
$vowels = array("a", "e", "i", "o", "u", "A", "E", "I", "O", "U");
echo str_replace($vowels, "", "Hello World of PHP");

// Provides: You should eat pizza, beer, and ice cream every day
$phrase  = "You should eat fruits, vegetables, and fiber every day.";

$healthy = array("fruits", "vegetables", "fiber");
$yummy   = array("pizza", "beer", "ice cream");
echo str_replace($healthy, $yummy, $phrase);

$healthy = array("fruits", "vegetables", "fiber");
$yummy   = array("pizza", "beer");
echo str_replace($healthy, $yummy, $phrase);

$healthy = array("fruits", "vegetables", "fiber");
$yummy   = "beer";
echo str_replace($healthy, $yummy, $phrase);

// Use of the count parameter is available as of PHP 5.0.0
//$str = str_replace("ll", "", "good golly miss molly!", $count);
//echo $count; // 2

var_dump(str_replace(array(1), array("a"), "1"));

?>
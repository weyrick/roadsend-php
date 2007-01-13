<?php
$string = "This is a test";
echo ereg_replace (" is", " was", $string) . "\n";
echo ereg_replace ("( )is", "\\1was", $string) . "\n";
echo ereg_replace ("(( )is)", "\\2was", $string) . "\n";



/* This will not work as expected. */
$num = 4;
$string = "This string has four words.";
$string = ereg_replace('four', $num, $string);
echo $string . "\n";   /* Output: 'This string has   words.' */

/* This will work. */
$num = '4';
$string = "This string has four words.";
$string = ereg_replace('four', $num, $string);
echo $string . "\n";   /* Output: 'This string has 4 words.' */


$text = "file:///usr/local/doc/bigloo-2.5c/bigloo-5.10.html#container1673";

$text = ereg_replace("[[:alpha:]]+://[^<>[:space:]]+[[:alnum:]/]",
                     "<a href=\"\\0\">\\0</a>", $text);

echo "\n" .  $text . "\n";

?>


<?php

$string1 = "dolphin-flogger";

echo '<'.substr($string1, 0, 5).">\n";
echo '<'.substr($string1, 4, 9).">\n";
echo '<'.substr($string1, 9, 23).">\n";
echo '<'.substr($string1, 25, 40).">\n";
echo '<'.substr($string1, 0, -4).">\n";
echo '<'.substr($string1, -3, -2).">\n";
echo '<'.substr($string1, -20, 24).">\n";
echo '<'.substr($string1, -5, 4).">\n";
echo '<'.substr($string1, 13, -8).">\n";
echo '<'.substr($string1, 40, 0).">\n";
echo '<'.substr($string1, 4).">\n";


?>
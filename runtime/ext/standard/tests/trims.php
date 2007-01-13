<?php

$trim = " \t\t\nthis is a test of the trim \r\n  ";
echo trim($trim);

$trim2 = "  \t \n -+-this is another test-+- \n";
echo trim($trim2, "-+ \n\t");

echo ltrim($trim);
echo rtrim($trim2, "-+ \n\t");

echo "<".trim('').">";
echo "<".ltrim('').">";
echo "<".chop('blah    ').">";

?>
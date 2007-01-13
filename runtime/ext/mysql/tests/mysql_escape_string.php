<?php

$input = 'Thar\'s cheese in them thar hole' . "\n";

echo "Normal: $input\n";
echo "Eaten: " . mysql_escape_string($input) . "\n";

$link = mysql_connect("localhost", "develUser", "d3v3lpa55")
    or die("Could not connect");

echo "Eaten: " . mysql_real_escape_string($input,$link) . "\n";

mysql_close($link);

?>

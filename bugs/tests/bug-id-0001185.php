0001185 here doc escaping

php escapes \\ to \ within heredocs

<?php
$test = <<< HERE
this is a test
\\\\ \\\\ \\\\\\ \\
\a\\b\c\d\\e\f\g
last line
HERE;

echo $test;

?>

<?php

$handle = fopen("http://www.google.com/", "rb");
$contents = '';
while (!feof($handle)) {
  $contents .= fread($handle, 8192);
}
fclose($handle);

var_dump($contents);

$handle = fopen("https://secure.roadsend.com/_test/test.php?arg=1", "rb");
$contents = '';
if ($handle) {
while (!feof($handle)) {
  $contents .= fread($handle, 8192);
}
fclose($handle);

var_dump($contents);
}
else {
    echo "---- failed to connect ssl through wrapper\n";
}

// Get a file into an array.  In this example we'll go through HTTP to get
// the HTML source of a URL.
$lines = file('http://www.google.com/');

// Loop through our array, show HTML source as HTML source; and line numbers too.
foreach ($lines as $line_num => $line) {
   echo "Line #<b>{$line_num}</b> : " . htmlspecialchars($line) . "<br />\n";
}

?>
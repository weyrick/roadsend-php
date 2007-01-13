<?php


$s = 'laz/y brown cow jumps over the sly fox';

echo preg_match('/la[zZ]\/y/S', $s); 
echo preg_match('-cow-', $s);
echo preg_match('-cow-', $s); // this repeat is to test the cache
echo preg_match('    /JUMPS/i', $s);
echo preg_match('/JUMPS/i', $s);
echo preg_match('/goo/', $s);

preg_match('/sly\s*(.+)$/', $s, $m);
print_r($m);

preg_match('/the\s*(.+)\s(.+)$/', $s, $m, PREG_OFFSET_CAPTURE);
print_r($m);

// FROM DOCS

// get host name from URL
preg_match("/^(http:\/\/)?([^\/]+)/i",
"http://www.php.net/index.html", $matches);
$host = $matches[2];
// get last two segments of host name
preg_match("/[^\.\/]+\.[^\.\/]+$/",$host,$matches);
echo "domain name is: ".$matches[0]."\n";

// delimiters
echo preg_match("!foo!", "somefooyo");
echo preg_match("#foo#", "somefooyo");
echo preg_match("(foo)", "somefooyo");
echo preg_match("<foo>", "somefooyo");
echo preg_match("{foo}", "somefooyo");
echo preg_match("[foo]", "somefooyo");

?>
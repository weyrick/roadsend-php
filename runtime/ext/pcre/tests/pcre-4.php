<?php

print_r(preg_split('/,/', 'this,is,a,list,of,values'));

print_r(preg_split('/vjv/', 'firstvjvsecondvjvthirdvjvfourth'));

print_r(preg_split('/\|/', 'first|second|third|fourth', 2));

print_r(preg_split('/\s+/','one two three four five six seven eight nine ten', 5));


print_r(preg_split('/Y/', 'no splits here man'));

print_r(preg_split('/(\-)/','one-two-three-four-five-six-seven-eight-nine-ten', -1,
		   PREG_SPLIT_DELIM_CAPTURE));


print_r(preg_split('/(\-)/','one-two-three-four-five-six-seven-eight-nine-ten', -1,
		   PREG_SPLIT_DELIM_CAPTURE |
		   PREG_SPLIT_NO_EMPTY));

print_r(preg_split('/(\-)/','one-two-three-four-five-six-seven-eight-nine-ten', -1,
		   PREG_SPLIT_DELIM_CAPTURE |
		   PREG_SPLIT_OFFSET_CAPTURE));


print_r(preg_split('/(\-)/','one-two-three-four-five-six-seven-eight-nine-ten', -1,
		   PREG_SPLIT_DELIM_CAPTURE |
		   PREG_SPLIT_NO_EMPTY |
		   PREG_SPLIT_OFFSET_CAPTURE));


print_r(preg_split('//','one two three four five six seven eight nine ten', -1,
		   PREG_SPLIT_NO_EMPTY |
		   PREG_SPLIT_OFFSET_CAPTURE));

// from docs

// split the phrase by any number of commas or space characters,
// which include " ", \r, \t, \n and \f
$keywords = preg_split("/[\s,]+/", "hypertext language, programming");
print_r($keywords);


$str = 'string';
$chars = preg_split('//', $str, -1, PREG_SPLIT_NO_EMPTY);
print_r($chars);


$str = 'hypertext language programming';
$chars = preg_split('/ /', $str, -1, PREG_SPLIT_OFFSET_CAPTURE);
print_r($chars);


$line = '10.0.0.2 - - [17/Mar/2003:18:03:08 +1100] "GET /images/org_background.gif HTTP/1.0" 200 2321 "http://10.0.0.3/login.php" "Mozilla/5.0 Galeon/1.2.7 (X11; Linux i686; U;) Gecko/20021203"';

$elements = preg_split('/^(\S+) (\S+) (\S+) \[([^\]]+)\] "([^"]+)" (\S+) (\S+) "([^"]+)" "([^"]+)"/', $line,-1,PREG_SPLIT_DELIM_CAPTURE | PREG_SPLIT_NO_EMPTY);

print_r($elements);

$a = preg_split("/\s+/", " ", -1, PREG_SPLIT_NO_EMPTY);
var_dump($a);

?>

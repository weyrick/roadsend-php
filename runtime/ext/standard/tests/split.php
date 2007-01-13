<?php

$passwd_line = "www-data:x:33:33:www-data:/var/www:/bin/sh";

list($user,$pass,$uid,$gid,$extra)= split (":", $passwd_line, 5);

echo "$user,$pass,$uid,$gid,$extra\n";


$date = "04/30/1973";  
list ($month, $day, $year) = split ('[/.-]', $date);
echo "Month: $month; Day: $day; Year: $year<br>\n";



#we both print a warning.
#$str = "foo\nbaz\nbar\n";
#list($foo, $baz, $bar) = split("^", $str);
#echo "foo $foo, baz $baz, bar $bar\n";

?>
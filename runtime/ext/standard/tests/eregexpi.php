<?php

$string = "adsf asdfljasldkfj als alskj Abc asdfl jaskdjf lsdjg ";

if ( eregi ("abc", $string) ) {
	echo "works\n";
} 	



if ( eregi ("^abc", $string) ) {
	echo "broken\n";
}

if ( eregi ("abc$", $string) ) {
	echo "broken\n";
}



$string = "adsf asdfljasldkfj als\n alskj aBc asdfl\n jaskdjf lsdjg abc";

if ( eregi ("abc$", $string) ) {
	echo "works\n";
}



eregi ("([[:alnum:]]+) ([[:alnum:]]+) ([[:alnum:]]+)", $string, $regs); 

print_r ($regs);



//$string = eregi_replace ("^", "<br />", $string); 


print ($string); 


//$string = eregi_replace ("$", "<br />", $string); 


print ($string);



$string = "adsf Asdfljasldkfj als\n alskj abc asdfl\n jaskdjf lsdjg abc";

$string = eregi_replace ("a", "zoot", $string);

print ($string);

print_r ( spliti (" ", $string, 3));


$date = "2003-07-03";

if (eregi ("([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})", $date, $regs)) {
    echo "$regs[3].$regs[2].$regs[1]";
} else {
    echo "Invalid date format: $date";
}



?>
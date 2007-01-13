<?php

$string = "adsf asdfljasldkfj als alskj abc asdfl jaskdjf lsdjg ";


if ( ereg ("abc", $string) ) {
	echo "works\n";
} 	



if ( ereg ("^abc", $string) ) {
	echo "broken\n";
}

if ( ereg ("abc$", $string) ) {
	echo "broken\n";
}



$string = "adsf asdfljasldkfj als\n alskj abc asdfl\n jaskdjf lsdjg abc";

if ( ereg ("abc$", $string) ) {
	echo "works\n";
}





ereg ("([[:alnum:]]+) ([[:alnum:]]+) ([[:alnum:]]+)", $string, $regs); 

print_r ($regs);



//$string = ereg_replace ("^", "<br />", $string); 


print ($string); 


//$string = ereg_replace ("$", "<br />", $string); 


print ($string);



$string = "adsf asdfljasldkfj als\n alskj abc asdfl\n jaskdjf lsdjg abc";

$string = ereg_replace ("a", "zoot", $string);

print ($string);

print_r ( split (" ", $string, 3));




$date = "2003-07-03";

if (ereg ("([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})", $date, $regs)) {
    echo "$regs[3].$regs[2].$regs[1]";
} else {
    echo "Invalid date format: $date";
}


?>


<?php



$num=12;
$location="fragit";

$format = "There are %d monkeys in the %s\n";
printf($format,$num,$location);

$format = "The %s contains %d monkeys\n";
printf($format,$num,$location);


$format = "The %2\$s contains %1\$d monkeys\n";
printf($format,$num,$location);

//error messages don't have to be the same
//$format = "The %2\$s contains %0\$d monkeys\n";
//printf($format,$num,$location);



$format = "The %2\$s contains %1\$d monkeys.
           That's a nice %2\$s full of %1\$d monkeys.\n";
printf($format, $num, $location);

$year=3;
$month=4;
$day=5;

$isodate = sprintf("%04d-%02d-%02d", $year, $month, $day);


$money1 = 68.75;
$money2 = 54.35;
$money = $money1 + $money2;
// echo $money will output "123.1";
$formatted = sprintf("%01.2f", $money);
// echo $formatted will output "123.10"

echo $money . " " . $formatted . "\n";

printf("%'g10.10f\n", 2);

printf("%10.10f\n", 2);

printf("%010.10f\n", 2);

printf("%-'m10.10f\n", 2);

printf("%1$-20s, %1$20s \n", "foo");


// vprintf, vsprintf
vprintf("%d plus %d = %d\n", array(1,1,2));
echo vsprintf("%d plus %d = %d\n", array(1,1,2));

?>

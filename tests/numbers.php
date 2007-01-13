<?php

function test_num($title, $a) {
    print "$title : $a\n";
    var_dump($a);
}

$test = 25;
var_dump($test);

test_num("dec1",(268435456 * 2));
test_num("dec2",(268 * 2));
test_num("dec3",(5843545699 * 2));
test_num("dec4",(95843545699 * 2));
test_num("dec5",(268435456 * 5));

$a = 0799;
$b = 0732;
var_dump($a);
var_dump($b);

test_num("hex1",0xFFFF);
test_num("hex2 ",0xFFFFFFFF);
test_num("hex2e",0xFFFFFFFF0);
test_num("hex2a",0xFFFFFFF);
test_num("hex2b",0xFFFFFF);
test_num("hex2c",0xFFFFFFFFF);
test_num("hex2d",0xFFFFFFFFFF);
test_num("hex3 ",0xFFFFFFFFFFF);
test_num("hex4", 0xFFFFFFFFFFFFFFFFF);

test_num("oct1:",(077777777 * 2));
test_num("oct2:",(077777777777 * 2));

test_num("fl1",(9321392939293.22 * 2));
test_num("fl2:",(9321.2232 * 2.5));
test_num("fl3:", 1.234);
test_num("fl4:", 1.2e3);
test_num("fl5:", 7E-10);
test_num("fl5a:", 0.0000000007);
test_num("fl5b:", 0.000007);
test_num("fl6:", 7.243E+10);
test_num("fl7:", 3E+5);
test_num("fl8:", 3E-5);

$large_number =  2147483647;
echo "p1:";
var_dump($large_number);
// output: int(2147483647)

$large_number =  2147483648;
echo "p2:";
var_dump($large_number);
// output: float(2147483648)

// this goes also for hexadecimal specified integers:
// ** fails due to no float overflow for hexs in the lexer **
//echo "p3:";
//var_dump( 0x80000000 );
// output: float(2147483648)

// this example is two numers that starts as an int (elong) but
// but after the operation need to overflow into a float
$million = 1000000;
$large_number =  50000 * $million;
echo "p4:";
var_dump($large_number);
// output: float(50000000000)
echo "p5:";
$ln = -50000 * $million;
var_dump($ln);
echo "p6:";
var_dump(25/7);         // float(3.5714285714286) 
echo "p7:";
var_dump((int) (25/7)); // int(3)
//var_dump(round(25/7));  // float(4)
echo "p8:";
echo (int) ( (0.1+0.7) * 10 );

echo "\n";

// overflows on arithmetic
test_num('of1:', (1000000*1000000));
test_num('of1a:', (2147483647*2147483647));
test_num('of1b:', (2147483647*2147483660));
test_num('of1c:', (-2147483647*2147483660));
test_num('of2:', (2147483647+2147483650));
test_num('of3:', (2147483647+2147483647));
test_num('of3a:', (-2147483647+-2147483647));
test_num('of4:',  (-200000000-200000000));
test_num('of5:', (1000000/1000));

// elongs
test_num('el1:', (32144 / 231));
test_num('el2:', (32144 + 231));
test_num('el3:', (32144 * 231));
test_num('el4:', (32144 - 231));

$c[] = +5;
$c[] = -12.;
$c[] = 4.;
$c[] = +12.5;

var_dump($c);

?>

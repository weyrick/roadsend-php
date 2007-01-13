PHP follows Perl's convention when dealing with arithmetic operations on character variables and not C's. For example, in Perl 'Z'+1 turns into 'AA', while in C 'Z'+1 turns into '[' ( ord('Z') == 90, ord('[') == 91 ). Note that character variables can be incremented but not decremented.

Additional Information 	
<?

echo ('A'+1)."\n";
echo ('Z'+1)."\n";
echo ('ZZ'+1)."\n";

$char = 'A';
$char++;
echo ($char)."\n";
$char = 'A';
++$char;
echo ($char)."\n";
$char = 'Z';
$char++;
echo ($char)."\n";
$char = 'ZZ';
$char++;
echo ($char)."\n";
$char = 'Z2Z';
$char++;
echo ($char)."\n";
$char = ' Z';
$char++;
echo ($char)."\n";


for ( $i = 'A', $t = 0; $i != 'AAA' && $t != 100; $i++, $t++ ) {
echo "$i\n";
}

?>

some more tests

<?php
$testcases = array("a", "aa", "z", "zz", "jz", 
		   "A", "AA", "Z", "ZZ", "JZ", 
		   "0", "00", "9", "99", "49",
		   "asdFA", "aA", "asdfZ", "Zz", "Ja", 
		   "asdF1", "1a9", "asd11", "8Zz", "J0");

foreach ($testcases as $test) {
  echo "testcase $test\n";
  for($i=0; $i<5; $i++) {
    //    echo $test++ . "\n";
    echo ++$test . "\n";
  }
  echo "--\n";
}
?>


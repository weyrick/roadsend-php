<?

// test the way we handle integer keys in hashes

print "int max: ".PHP_INT_MAX."\n";
print "int min: ".PHP_INT_SIZE."\n";

$key=PHP_INT_MAX;
$a[$key]=$key;
$key++; 
print "overflow key: $key\n";
$b[$key]=$key;
$bigkey = '9999999999999999999999999999999999999';
$bigkeyneg = '-9999999999999999999999999999999999999';
$bignumkey = 9999999999999999999999999999999999999;
$bignumkeyneg = -9999999999999999999999999999999999999;
$leadzero = '00567';
$float = 1.3217467;
var_dump($bignumkey);
$c[$bigkey] = 'foo';
$c[$bignumkey] = 'bar';
$c[$bignumkeyneg] = 'barzap';
$c[$bigkeyneg] = 'bip';
$c[$leadzero] = 'baz';
$c[$float] = 'f';
print_r($a);
print_r($b); 
print_r($c);

?>
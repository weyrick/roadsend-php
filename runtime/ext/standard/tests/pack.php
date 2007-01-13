<?php

print "first: \n";
$binary_data = pack("NvVNvN*", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
var_dump($binary_data);
var_dump(unpack("N", pack("N", 1)));
var_dump(unpack("N*", pack("N*", 1, 2, 3, 4, 5)));
print "second: \n";
$binary_data = pack("NN*VvVN*", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
var_dump($binary_data);
// print "third: \n";
// $binary_data = pack("NNnVvVN*", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
// var_dump($binary_data);
//print "third: \n";
//$binary_data = pack("*NNnVvVN*", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
//var_dump($binary_data);
//var_dump(unpack("nint", $binary_data));

?>
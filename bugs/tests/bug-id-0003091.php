test comparison of resources
<?php


$fp = fopen(__FILE__,'r');

if ($fp == "") {
    echo "unable to open file\n";
}
else {
    echo "opened file\n";
}
echo (int) $fp;
echo "\n";

echo "1: ".($fp == 0)."\n";
echo "2: ".($fp == 1)."\n";
echo "3: ".($fp > 0)."\n";
echo "4: ".($fp < 0)."\n";

fclose($fp);



?>

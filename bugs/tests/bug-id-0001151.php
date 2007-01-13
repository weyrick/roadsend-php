0001151 core error
<?php
$ar = array();
for ($count = 0; $count < 10; $count++) {
$ar[$count] = "$count";
$ar[$count]['idx'] = "$count";
}

for ($count = 0; $count < 10; $count++) {
echo $ar[$count]." -- ".$ar[$count]['idx']."\n";
}
$a = "0123456789";
print $a{0} . "\n";
$a[9] = $a{0};
var_dump($a);
?>

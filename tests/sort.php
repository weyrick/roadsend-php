<?php

$fruits = array ("lemon", "orange", "banana", "apple");
print_r($fruits);
sort ($fruits);
reset ($fruits);
while (list ($key, $val) = each ($fruits)) {
    echo "fruits[".$key."] = ".$val."\n";
}

?>


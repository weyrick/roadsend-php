<?php

$colors = array('red','blue','green','yellow');

foreach ( $colors as $color ) {
    echo "Do you like $color?\n";
}

print $color . "\n";

/* output:
Do you like red?
Do you like blue?
Do you like green?
Do you like yellow?
*/

foreach ($colors as $key => $color) {
    // won't work:
    //$color = strtoupper($color);
    
    //works:
    $colors[$key] = strtoupper($color);
}
print_r($colors);

/* output:
Array
(
    [0] => RED
    [1] => BLUE
    [2] => GREEN
    [3] => YELLOW
)
*/


?>

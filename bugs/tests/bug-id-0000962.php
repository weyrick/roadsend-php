0000962 user defined functions with default values of false can fail
 	apparently for the same reason we can't have a default of #f for defbuiltins, user defined functions can't either:
<?php

function badDefault($a=false) {
    echo "made it, a is $a\n";
}

badDefault('hi');
badDefault();

?>

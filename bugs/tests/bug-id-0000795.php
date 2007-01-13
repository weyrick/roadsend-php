0000795 parse error on default function argument as a negative number

<?php

function functest($a,$b = -1) {
return $b;
}

echo functest('1');


?>

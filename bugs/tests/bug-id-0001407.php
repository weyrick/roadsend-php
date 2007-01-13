<?php

$a =  array(
        'af-utf-8'     => array('af|afrikaans', 'afrikaans-utf-8', 'af'),
        'af-iso-8859-1'=> array('af|afrikaans', 'afrikaans-iso-8859-1', 'af'),
        'bg-win1251'   => array('bg|bulgarian', 'bulgarian-windows-1251', 'bg'));

$b = $a;
$a = array();

while (list($p, $s) = each($b)) {
    var_dump($p);
    var_dump($s);
    $a[$p] = $s;
}

var_dump($a);

?>
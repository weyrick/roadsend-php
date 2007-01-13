<?php

function functest($a,$b,$c) {
return 'this is craptacular';
}

$languages['one']['XTRA_CODE'] = 'functest';

$filename = $languages['one']['XTRA_CODE']('downloadfilename', '', '');
echo $filename;

?>


0002565: fwrite() is not binary safe

it's using stdio's fputs(), so it stops at the first 0 in the string:

<?php

$baz = fopen("/dev/zero", "r");
$foo = fread($baz, 8192);
$bar = fopen("woot", "wb");
fwrite($bar, $foo);
fclose($bar);
echo filesize("woot") . "\n";

?>

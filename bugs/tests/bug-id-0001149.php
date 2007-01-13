<?php

if (!ini_get('register_globals')) {
    $argc = $_SERVER['argc'];
    $argv = $_SERVER['argv'];
}

for ($i=1; $i<$argc; $i++) {
    echo ($i-1).": ".$argv[$i]."\n";
}

?>

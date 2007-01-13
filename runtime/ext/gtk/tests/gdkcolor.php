<?php

if (!extension_loaded('gtk')) {
	dl( 'php_gtk.' . PHP_SHLIB_SUFFIX);
}

$clTransparentTest =& new GdkColor('#FFAA33');
$foo =& new GdkColor(255, 51, 170);

$bar =& new GdkColor('blorp');


?>
check that unserialize doesn't produce a fatal error when encountering bad data
<?php

function maybe_unserialize($original) {
	if ( false !== $gm =  @ unserialize($original) )
		return $gm;
	else
		return $original;
}

var_dump("value " . maybe_unserialize("http://hummer/blog"));

?>

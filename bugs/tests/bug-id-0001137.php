<?php
$input = array("foo", "bar", "baz", "grldsajkopallkjasd");
foreach($input AS $i) {
    echo crc32($i)."\n";
    printf("%d - %u\n", crc32($i), crc32($i));
}
?>
<?php

echo crc32('the quick brown fox jumped over the lazy dog')."\n";

for ($i=0; $i<256; $i++) {
    echo($i.": ".crc32(chr($i))."\n");
}

?>

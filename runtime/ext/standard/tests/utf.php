<?php

echo utf8_encode('test'.chr(205))."\n";
echo utf8_decode('test')."\n";

echo "utf_encode: ".utf8_encode("æ")."\n";

printf("%s -> %s\n", urlencode("æ"), urlencode(utf8_encode("æ")));
printf("%s <- %s\n", urlencode(utf8_decode(urldecode("%C3%A6"))), "%C3%A6");

?>
<?php

echo addcslashes("", "")."\n";
echo addcslashes("", "burp")."\n";
echo addcslashes("kaboemkara!", "")."\n";
echo addcslashes("foobarbaz", 'bar')."\n";
echo addcslashes('foo[ ]', 'A..z')."\n";

echo @addcslashes("zoo['.']", 'z..A')."\n";
//they treat it as the chars 'z', '.', and 'A'.
echo @addcslashes("zoo['.']", 'z..z')."\n";
//... but z..z is a valid range (the '.' char isn't escaped)

echo "octal value of \\145 is " . decoct(ord("\145")) . "\n";
echo "hex value of \\xe5 is " . dechex(ord("\xe5")) . "\n";

echo addcslashes('abcdefghijklmnopqrstuvwxyz', "a\145..\160z")."\n";
echo stripcslashes(addcslashes('abcdefghijklmnopqrstuvwxyz', "a\145..\160z"))."\n";
echo 'octal for \f is: ' .  decoct(ord(stripcslashes('\f'))) . "\n";

echo "[" . stripcslashes('\f') . "]" . "\n";

echo "\n\r" == stripcslashes('\n\r'),"\n";
echo stripcslashes('\065\x64')."\n";

echo stripcslashes('')."\n";


//echo addcslashes("foo\001\002\003bar\nbaz", "\2on")."\n";
//echo addcslashes("foo\001\002\003bar\nbaz", "\002on")."\n";


?>

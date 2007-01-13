<?php

$beer = "mmm, mmm, good";

$keg['a'] = 17;
$keg[3] = 18;


echo "a few $beers\n";
echo "a few ${beer}s\n";
echo "a few {$beer}s\n";

echo "from a large$keg[a]\n";
echo "from a large{$keg['a']}\n";
echo "from a large{$keg[1 + 2]}\n";

echo "foo[asdf]";

echo "from a large${keg['a']}\n";
echo "from a large${keg[a]}\n";
echo "from a large{{$keg['a']}\n";

echo "from a large\{${$keg['a']}\n";

echo "from a large{$keg['a']}}\n";
?>

PHP breaks the strings up into constant strings and non-constant strings in 
their lexer.  The constant strings don't eat the \ in "\{", but the non-
constant strings do.  (The key difference between a constant and non-constant
string is the presense of a non-escaped $).

Test the \{ stuff:
<?php
echo "\{";
echo "\{\n";
echo "\{$\n";
echo "\${\n";
echo "{\n";
echo "\.3";
$foo = "bar";
echo "\n\$foo\n"; 
echo "\n\{$foo}\n"; 
echo "\n\${foo}\n"; 
?>

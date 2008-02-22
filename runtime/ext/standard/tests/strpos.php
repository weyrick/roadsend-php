<?

// strpos
$mystring = 'abc';
$findme   = 'a';
$pos = "1: ".strpos($mystring, $findme);
echo "$pos\n";

// Note our use of ===.  Simply == would not work as expected
// because the position of 'a' was the 0th (first) character.
if ($pos === false) {
    echo "The string '$findme' was not found in the string '$mystring'";
} else {
    echo "The string '$findme' was found in the string '$mystring'";
    echo " and exists at position $pos\n";
}

echo "2: ".strpos('blah-7-meep','-7-');
echo "\n";
echo "3: ".strpos('blah-7-meep','meep',5);
echo "\n";
echo "4: ".strpos('blah-7-MEEP','meep',5);
echo "\n";
echo "5: ".strpos('blah-7-meep','blah',2);
echo "\n";
echo "6: ".strpos('BLAH-7-meep','bLaH');
echo "\n";


// no support in php?
echo "[";
echo "1: ".stripos('blah-7-MEEP','MEEP',5);
echo "\n";
echo "2: ".stripos('bLaH-7-meep','bLaH');
echo "\n";
echo "]";

/*
echo strrpos('bffflah-7-meep','-7-');
echo strrpos('bsdfwlah-7-meep-MEEP-meep','MEEP');
echo strrpos('blah-7-mBlAhblaheep','BlAh');
*/

?>
done
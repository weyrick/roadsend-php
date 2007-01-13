<?

echo curl_version();

echo "\niniting\n";
$ch = curl_init();

echo "\nsetting options:";
echo curl_setopt($ch, CURLOPT_URL, "https://secure.roadsend.com/_test/test.php?var1=test&var2=test");

curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
//curl_setopt($ch, CURLOPT_VERBOSE, 1);

if (PHP_OS == 'WINNT') {
    // we don't have a ca tp verify against on mingw
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 1);
}

echo "\nexecing:";
$foo = curl_exec($ch);
var_dump($foo);


echo "\nclosing:";
echo curl_close($ch);


?>

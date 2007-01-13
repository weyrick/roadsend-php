<?

echo curl_version();

echo "initing\n";
$ch = curl_init();

echo "\nsetting options:";
echo curl_setopt($ch, CURLOPT_URL, "http://www.google.com");
//echo curl_setopt($ch, CURLOPT_VERBOSE, 1);

echo "\nexecing:";
echo curl_exec($ch);

echo "\nsetting RETURNTRANSFER:";
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

echo "\nexecing:";
$foo = curl_exec($ch);
var_dump($foo);

echo "\nexecing:";
$foo = curl_exec($ch);
var_dump($foo);


echo "\nclosing:";
echo curl_close($ch);


?>

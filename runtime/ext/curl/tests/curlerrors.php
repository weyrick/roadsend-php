<?

$ch = curl_init();
echo "\n1 setopt: ";
echo curl_setopt($ch, CURLOPT_URL, "fnord://this is not a url");
echo "\n2 exec: ";
echo curl_exec($ch);
echo "\n3 error: ";
echo curl_error($ch);
echo "\n4 errno: ";
echo curl_errno($ch);


echo curl_setopt($ch, "fake option",0);

echo "\n5 close: ";
echo curl_close($ch);


/*
$ch = curl_init();
echo "\nsetopt: ";
echo curl_setopt($ch, CURLOPT_URL, "bad host");
echo "\nexec: ";
echo curl_exec($ch);
echo "\nerror: ";
echo curl_error($ch);
echo "\nerrno: ";
echo curl_errno($ch);
echo "\nclose: ";
echo curl_close($ch);
*/



?>


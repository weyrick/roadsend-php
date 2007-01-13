<?

function encodePostArr($arr) {
    $str = '';
    foreach ($arr as $k=>$v) {
        $str .= "$k=".urlencode($v)."&";
    }
    return substr($str,0,-1);
}

$ch = curl_init();
curl_setopt ($ch, CURLOPT_POST, 1);
curl_setopt ($ch, CURLOPT_URL, "http://localhost/curl/dumppost.php");
curl_setopt ($ch, CURLOPT_USERAGENT, 'agent');
curl_setopt ($ch, CURLOPT_HEADER, 0);
curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 0);
curl_setopt ($ch, CURLOPT_TIMEOUT, 180);

curl_setopt ($ch, CURLOPT_VERBOSE, 1);
curl_setopt ($ch, CURLOPT_NOPROGRESS, 1);
curl_setopt ($ch, CURLOPT_FAILONERROR, 0);

$fields = array('filename' => 'somefileval',
                'field2'   => 'f2val',
                'field3'   => 'f3val'
                );

curl_setopt ($ch, CURLOPT_POSTFIELDS, encodePostArr($fields));

// EXEC
print curl_exec ($ch);

if (curl_errno($ch)) {
    $error_code = 'MSG_CURL_ERROR';
    die(curl_error($ch));
}

curl_close ($ch);


?>
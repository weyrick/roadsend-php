<?

function curl_upload($src) {
    $fn = basename($src);
    $fp = fopen($src,"r");
    $dest = "ftp://devel:foobar@localhost/$fn";
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_UPLOAD, 1);
    curl_setopt($ch, CURLOPT_URL, $dest);
    curl_setopt($ch, CURLOPT_FTPASCII, 0);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_INFILE, $fp);
    curl_setopt($ch, CURLOPT_INFILESIZE, filesize($src));
    $result = curl_exec($ch);
    fclose ($fp);
    print_r(curl_getinfo($ch));
    $errorMsg = curl_error($ch);
    $errorNumber = curl_errno($ch);
    echo "\nErrMsg: ".$errorMsg."\nErrNo: ".$errorNumber."\n";
    curl_close($ch);
    return $errorNumber;
}

//curl_upload('foo.txt');
curl_upload('foo.bin');

?>
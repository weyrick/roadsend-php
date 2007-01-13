<?php

$fsock = fsockopen('www.roadsend.com', 80, $errno, $errstr, 10);
//stream_set_timeout($fsock, 0);
//stream_set_blocking($fsock, FALSE);
fputs($fsock, "GET /updatecheck/20x.txt HTTP/1.1\r\n");
fputs($fsock, "HOST: www.phpbb.com\r\n");
fputs($fsock, "Connection: close\r\n\r\n");

while (!feof($fsock)) {
    $google .= fread($fsock, 1024);
    //print $google;
    print "loop " . strlen($google) . "\n";
}
print strlen($google);

?>
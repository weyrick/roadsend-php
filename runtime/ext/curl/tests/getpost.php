<?php

$ch = curl_init();

curl_setopt($ch, CURLOPT_URL,"http://www.roadsend.com/_test/test.php");
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS,
            "postvar1=value1&postvar2=value2&postvar3=value3");
            
curl_exec ($ch);
echo curl_error($ch);

curl_setopt($ch, CURLOPT_URL,"http://www.roadsend.com/_test/test.php?type=get&foo=bar");
curl_exec ($ch);

curl_close ($ch); 


//
// A very simple POST example with a custom request keyword 'FOOBAR'
//

$ch = curl_init();

curl_setopt($ch, CURLOPT_URL,"http://www.roadsend.com/_test/test.php");
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS,
            "postvar1=value1&postvar2=value2&postvar3=value3");

// issue a FOOBAR request instead of POST!
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "FOOBAR");

curl_exec ($ch);
curl_close ($ch); 

?>

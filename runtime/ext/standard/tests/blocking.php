This test thanks to groove :)

<?
 echo "without blocking: \n";
 $fp = fsockopen("www.ebay.com", 80);
 fputs($fp, "GET / HTTP/1.0\r\nHost: www.ebay.com\r\n\r\n");
 stream_set_blocking($fp, false);
 $sLine = fgets($fp , 1024);
 echo $sLine;
 echo "and with blocking: \n";
 stream_set_blocking($fp, true);
 $sLine = fgets($fp , 1024);
 echo $sLine;

?>
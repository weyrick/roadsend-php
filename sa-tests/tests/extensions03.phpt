--TEST--
xml extension test
--SKIPIF--
<? 

$libs = `ls ../libs/`;
if (!strstr($libs, 'xml'))
    echo "skip extension library not found";

?>
--POST--
--GET--
--PCCARGS--
-u php-xml
--FILE--
<?php

$data = "<root><section>This is my sample XML code</section></root>";

$parser = xml_parser_create();
echo xml_parse($parser,$data);

?>
--EXPECT--
--RTEXPECT--
1

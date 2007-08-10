--TEST--
microserver static build
--PCCARGS--
--microserver mymicro-s --static
--FILE--
<?php 

echo "micro app" 

?>
--POSTCOMPILE--
./mymicro-s -h
--EXPECT--
   -h,--help This help message
   -d LEVEL  Debug level
   -l LOG    Log all requests to the specfied file
   -p PORT   Server port number

--TEST--
microserver build
--PCCARGS--
--microserver mymicro
--FILE--
<?php 

echo "micro app" 

?>
--POSTCOMPILE--
./mymicro -h
--EXPECT--
   -h,--help This help message
   -d LEVEL  Debug level
   -l LOG    Log all requests to the specfied file
   -p PORT   Server port number

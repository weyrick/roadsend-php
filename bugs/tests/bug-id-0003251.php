<?php
 $foo = 'some val';
 define('DEFFOO', $foo);
 echo '$foo is '.$foo.' and DEFFOO is '.DEFFOO."\n";
 unset($foo);
 echo '$foo is '.$foo.' and DEFFOO is '.DEFFOO."\n";
?>
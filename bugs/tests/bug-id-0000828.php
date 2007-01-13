<?php

$dir = '/etc';

$foo = `ls -l $dir`;

print $foo;

$bar = `echo \`echo "asdf"\``;		
echo $bar;

?>
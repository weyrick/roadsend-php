Bug# 0000697

default function parameters should accept undefined tokens for default values
bad practice, but php allows this:


function myfun($arg=undef, $arg2=undef) {
...
}

where undef isn't defined at all anywhere else. perhaps it turns it into a string?
Additional Information 	

<?php


function myfun($arg=undef, $arg1=alsoundef) {
   echo("$arg, $arg1\n");
}

myfun();


?>
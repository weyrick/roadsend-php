<?php

function foo()
{
   $numargs = func_num_args();
   echo "Number of arguments: $numargs<br />\n";
   if ($numargs >= 2) {
       echo "Second argument is: " . func_get_arg(1) . "<br />\n";
   }
   /*$arg_list = func_get_args();
   for ($i = 0; $i < $numargs; $i++) {
       echo "Argument $i is: " . $arg_list[$i] . "<br />\n";
   }*/
}

function foo_with_args($a, $b)
{
   $numargs = func_num_args();
   echo "correct -- Number of arguments: $numargs<br />\n";
   if ($numargs >= 2) {
       echo "0Second argument is: " . func_get_arg(1) . "<br />\n";
   }
   foo(6,5,4);
   $numargs = func_num_args();
   echo "wrong -- Number of arguments: $numargs<br />\n";
   if ($numargs >= 2) {
       echo "1Second argument is: " . func_get_arg(1) . "<br />\n";
   }
   foo(11,12,13);
   $arg_list = func_get_args();
   for ($i = 0; $i < $numargs; $i++) {
       echo "2Argument $i is: " . $arg_list[$i] . "<br />\n";
   }
}

foo_with_args(1,2);

?>
test variable arity user functions

<?php
function foo()
{
   $numargs = func_num_args();
   echo "Number of arguments: $numargs<br />\n";
   if ($numargs >= 2) {
       echo "Second argument is: " . func_get_arg(1) . "<br />\n";
   }
   $arg_list = func_get_args();
   for ($i = 0; $i < $numargs; $i++) {
       echo "Argument $i is: " . $arg_list[$i] . "<br />\n";
   }
}

foo();
foo(1, 2, 3);

function foo_with_args($a, $b)
{
   $numargs = func_num_args();
   echo "0Number of arguments: $numargs<br />\n";
   if ($numargs >= 2) {
       echo "0Second argument is: " . func_get_arg(1) . "<br />\n";
   }
   $arg_list = func_get_args();
   for ($i = 0; $i < $numargs; $i++) {
       echo "0Argument $i is: " . $arg_list[$i] . "<br />\n";
   }
}

//foo_with_args();
foo_with_args(1, 2, 3);


class aclass {
  function afun() {
    $numargs = func_num_args();
    echo "1Number of arguments: $numargs<br />\n";
    if ($numargs >= 2) {
      echo "1Second argument is: " . func_get_arg(1) . "<br />\n";
    }
    $arg_list = func_get_args();
    for ($i = 0; $i < $numargs; $i++) {
      echo "1Argument $i is: " . $arg_list[$i] . "<br />\n";
    }
  }

  function afun_with_args($a) {
    $numargs = func_num_args();
    echo "2Number of arguments: $numargs<br />\n";
    if ($numargs >= 2) {
      echo "2Second argument is: " . func_get_arg(1) . "<br />\n";
    }
    $arg_list = func_get_args();
    for ($i = 0; $i < $numargs; $i++) {
      echo "2Argument $i is: " . $arg_list[$i] . "<br />\n";
    }
  }
}

aclass::afun(1, 2);
$a = new aclass();
$a->afun(88, 89, 90, 91);


aclass::afun_with_args(1, 2);
$a = new aclass();
$a->afun_with_args(88, 89, 90, 91);

?> 


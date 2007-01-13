<?

/***
 *
 * A sample main file that can be compiled to multiple
 * targets with the Roadsend Compiler
 *
 */ 

echo "starting main.php ...\n";

include ('inc1.php');
include ('inc2.php');

inc1_function('foo', 'bar');
inc2_function('baz', 'bif');


?>
end of program

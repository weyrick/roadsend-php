define() needs to happen like a normal statement, and still work as a
default value.

<?php

echo "hey:".defined('MEME').":yeh\n";
define('MEME',1);
echo "hey:".defined('MEME').":yeh\n";

?>

more

<?php

foo();

function foo($a=ZOT) {
print ("\$a is $a\n");
}

define(ZOT, "wert");

foo();

?>
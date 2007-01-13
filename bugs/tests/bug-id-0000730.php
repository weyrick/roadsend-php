0000730 access to a string index in a class property


<?

class testc { var $tp = "this is a test"; }

$c = new testc();

echo "{$c->tp{3}}\n";

?>

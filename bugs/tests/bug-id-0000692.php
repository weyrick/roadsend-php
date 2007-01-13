constant as default argument for function parameter

the following breaks in the parser:


<?php
define("SF_LAYOUT_UNDEFINED", 100);

function addText($text, $lay=SF_LAYOUT_UNDEFINED) {

  echo ("$text, $lay\n");
}

addText("foo");


?>

this is also a problem for assigning a constant to a class variable in a class definition, ie:

<?php




class foo {
  var $sample = SF_LAYOUT_UNDEFINED;
}


$afoo = new foo();
echo $afoo->sample . "\n";


?>
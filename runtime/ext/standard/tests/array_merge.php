<?php

//array_merge with a string
$foo = array (
  " AceIce"=>
 "AceIce",
  " Basic"=>
 "Basic",
  " Blue"=>
 "Blue",
  " Bluecurve"=>
 "Bluecurve",
  " CVS"=>
 "CVS");
var_dump(array_merge("no theme", $foo));

?>

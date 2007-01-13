<?php
class foo {
  function foo($name) {
    $GLOBALS['List'] =& $this;
    $this->Name = $name;
    $GLOBALS['List']->echoName(); 
  }
  
  function echoName() {
    $GLOBALS['names'][]=$this->Name; 
    echo "Foo";
  } 
}

function &foo2(&$foo)	{
	return $foo; }


$bar1 =& new foo('constructor');

$bar1->Name = 'outside';

$bar1->echoName();

$List->echoName();

$bar1 =& foo2(new foo('constructor'));

$bar1->Name = 'outside';

$bar1->echoName();


$List->echoName();

print ($names==array('constructor','outside','outside','constructor','outside','outside')) ? 'success':'failure'; 

print("\nthe array:\n");

print_r(array('constructor','outside','outside','constructor','outside','outside'));

print("\n\$names:\n");

print_r($names);


?>

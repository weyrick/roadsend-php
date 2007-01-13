0000959 $this is null in constructor

<?php

class bling {

  function bling() {
    echo "bling this is $this\n";
    echo "bling this->zot is " . $this->zot ."\n";
  }

  function wibble() {
    print "bling's wibble\n";
    echo "bling's wibble's this: $this\n";
    echo "bling's wibbles' this->zot is " . $this->zot ."\n";
  }
}

class foo extends bling {
  var $zot = 3;

  function foo() {
    parent::bling();
    echo "this is $this\n";
    echo "this->zot is " . $this->zot ."\n";
    $this->wibble();
    parent::wibble();
  }

  function wibble() {
    print "foo's wibble\n";
    echo "foo's wibble's this: $this\n";
    echo "foos's wibbles' this->zot is " . $this->zot ."\n";
  }
}


$bar = new foo();

//echo "--\n";
//bling::bling();

?>

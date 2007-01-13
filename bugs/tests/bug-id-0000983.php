0000983 parse error, single quotes in double quotes on class var default

<?php

class aclass {
  var $avar = "'test'";
  function aclass() {
    echo "$this->avar\n";
  }
}

$a = new aclass();

?>

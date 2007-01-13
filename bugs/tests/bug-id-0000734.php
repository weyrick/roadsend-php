0000734 parse error on empty conditional block


<?php

class aclass {
  var $SfFilter;

  function afun($autoFilter) {
    if ($autoFilter) {
      // try to guess some filters to add based on it's name
      // EMAIL
      // FIXME - removed for now (weyrick)
      //      if (eregi('email',$this->getName()))
      //	$this->setSfFilter('email');
    }
  }

  function setSfFilter($filter) {
    $this->SfFilter = $filter;
  }

  function getName() {
    return "foo";
  }
}

$aninstance = new aclass();
$aninstance->afun(false);
echo "$aninstance->SfFilter\n";
$aninstance->afun(true);
echo "$aninstance->SfFilter\n";



?>
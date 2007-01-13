<?

class aclass {

  function afunc($meep, $blah='', $fnord) {
    var_dump($meep);
    var_dump($blah);
    var_dump($fnord);
  }

}

$a = new aclass();
$a->afunc('meep','hello');
$a->afunc('meep','hello',true);


?>
0001051:  parse error on parent:: as rval
<?


class aclass {
  function afunc() {
    return 'super!!!!!!!!!';
  }
}

class bclass extends aclass {
  function afunc() {
    //return parent::afunc();
    $a = parent::afunc();
    return $a;
  }
}

$a = new bclass();
echo $a->afunc();


?>
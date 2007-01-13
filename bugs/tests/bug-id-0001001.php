<?

class aclass {
  var $myarray = array();
  function aclass() {
    $this->myarray[] = 'one';
    $this->myarray[] = 'two';
    var_dump($this->myarray);
  }
}

$a =& new aclass();
$b =& new aclass();
$c = new aclass();

?>
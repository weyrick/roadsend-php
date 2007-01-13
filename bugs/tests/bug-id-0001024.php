0001024 unable to assign a reference to class property hash if the key doesn't already exist

<?

class bclass {
  var $str = 'hi there';
}

class aclass {
  var $directive = array();
  function runit($a) {
    $b =& new bclass();
    // uncomment this and it works
    //$this->directive['obj'][$a] = array();
    $this->directive['obj'][$a] =& $b;
  }
}

$a = new aclass();
$a->runit('akey');

echo $a->directive['obj']['akey']->str;

?>

recursive references
<?

class aclass {
  var $hash;

  function &afunc($i) {
    $var =& new bclass($i, $this);
    $this->hash[$i] =& $var;
    return $var;
  }

}

class bclass {
  var $id;
  var $parent;
  function bclass($id, &$parent) {
    $this->id = $id;
    $this->parent =& $parent;
  }
}


$m = new aclass();
$a =& $m->afunc(1);
$b =& $m->afunc(2);
$c =& $m->afunc(3);

$b->id = 10;
$b->parent->hash[] = 'hello';

print_r($m);
print_r($a);
print_r($b);
print_r($c);

echo "\n\n and now, var_dump \n\n";

var_dump($m);
var_dump($a);
var_dump($b);
var_dump($c);

?>
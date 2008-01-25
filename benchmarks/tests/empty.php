<?

class o {
  var $v1;
}

$o = new o();

$a = array('s1' => 'some string',
           's2' => '',
           's3' => '0',
           's3' => '555',
           'b1' => false,
           'b2' => true,
           'i1' => 0,
           'i2' => 555,
           'n1' => NULL,
           'a1' => array(),
           'a2' => array(1,2,3),
           'o1' => $o,
           'o2' => $o->v1,
           );
           

for ($i=0; $i<100000; $i++) {
 foreach ($a as $v) {
    $foo = empty($v);
 }
}

?>


0000731 parse error magically making a number negative

<?
$str=5;
echo -$str . "\n";

echo -($str) . "\n";
echo -($str+1) . "\n";




class foo {
  var $directive = array('vfSeparator' => "asdf");

  function foo() {
    $title = "wibble";
    $cutVal = strlen($this->directive['vfSeparator']);
    $title = substr($title, 0, -$cutVal);
    echo "$cutVal, $title\n";
  }

}


$zot = new foo();

?>



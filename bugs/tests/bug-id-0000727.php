
0000727 


instantiate a class based on a classname from an array

<?

class foo {
  var $directive = array('columnClass' => 'bar');

  function makeOne() {
    //create a new tableDefinition object
    $columnDef =& new $this->directive['columnClass']();
    $columnDef->zot();
  }
}

class bar {
  function zot() {
    echo "they've spotted us\n";
  }
}

$afoo = new foo();
$afoo->makeOne();


?>
 	

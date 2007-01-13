0000792 parse error using class property name 'class'

<?

class t {
  var $class = '';
  function t () {
    $this->class = 'woops';
  }
}


?>

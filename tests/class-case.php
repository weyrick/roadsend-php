<?

class TeSt {
  public $BaZBiP = 'yes';
  function FooBar() {
    echo "-> ".$this->bazbip."\n";
    echo "-> ".$this->BaZBiP."\n";
  }
}

$a = new test;
var_dump($a);
$a->foobar();
$b = get_class_methods($a);
var_dump($b);

?>
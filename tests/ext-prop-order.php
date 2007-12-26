<?

class a {
  static public $sa1 = 50;
  public $a1 = 1;
  public $a2 = 2;
  private $pa1 = 10;
  protected $ppa1 = 20;
  static private $sa2 = 51;
}

class b extends a {
  public $a2 = 199;
  public $b1 = 3;
  private $pb1 = 11;
  static public $sb1 = 52;
  public $b2 = 4;
  protected $ppb1 = 21;
  static private $sb2 = 53;
}

class c extends b {
  protected $ppc1 = 22;
  static public $sc1 = 54;
  private $pc1 = 12;
  public $c1 = 5;
  public $c2 = 6;
  static private $sc2 = 55;
}

$a = new a();
$a->a3 = 7;
print_r($a);

$b = new b();
$b->b3 = 8;
print_r($b);

$c = new c();
$c->c3 = 9;
print_r($c);

?>

<?php

class zot {

  var $bing = 12;
  var $Bing = "this is the capitalized bing";


  function zot() {
    echo "constructor\n";
  }

  var $otherplacement = 9;

  function __toString() {
      return "[this is a zot class]";
  }

  function afun($anarg) {
    //    echo $this->bing;
    echo $this;
    echo "you called zot->afun with $anarg.  bing was {$this->bing}.\n";
    //    $this->bing = $anarg;
  }

}

class argconstructor {

  var $bing = 12;


  function __toString() {
      return "[this is an argconstructor class]";
  }

  function argconstructor($a, $b="foo") {
    echo "constructor $a, $b\n";
  }

  var $otherplacement = 9;

  function afun($anarg) {
    //    echo $this->bing;
    echo $this;
    echo "you called argconstructor->afun with $anarg.  bing was {$this->bing}.\n";
    //    $this->bing = $anarg;
  }

}

function zot() {
  echo "I am the walrus\n";
}

$bing = new zot;

print "lower: $bing->bing, capitalized: $bing->Bing\n";

echo "foo";

$bing->afun(19);
$bing->afun(20);

$bing = new zot();
$bing = new zot;
//$bing = new zot("asdf");

$bing->afun(34);


zot();

$bing = new argconstructor(12);
$bing->afun(12);

$c = 'argconstructor';
$bap = new $c;
$bpa = new $c(12);

class bar {
  var $baz;
  function bar($a) { $this->baz = $a; }
}

class foo {

  var $a ='bar';

  function assign() {
    $zap =& new $this->a('setbaz');
  }

}

$a = new foo();
$a->assign();
print_r($a);

?>

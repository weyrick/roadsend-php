0002040: using == or === on recursive objects and arrays causes a segfault 

the @'s are because in zend php these comparisons cause a fatal error.  we
just want to make sure that pcc doesn't crash -- it should reach the "done".
I don't see why a comparison of recursive data should be a "fatal error".
--tim

<?php

//test recursive hashtables
$a[2] =& $a;

function a() {
  if ($a == $a) {
    return 2;
  }
}

@a(); 

function b() {
  if ($a === $a) {
    return 2;
  }
}

@b();


//test recursive objects
class b {}
$b = new b();
$b->foo =& $b;

function c() {
  if ($b == $b) {
    return 2;
  }
}

@c();

function d() {
  if ($b === $b) {
    return 2;
  }
}

@d();

echo "done\n";

?>
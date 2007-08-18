<?

function bwops($a, $b) {
  $r[] = $a ^ $b;
  $r[] = $a xor $b;
  $r[] = $a & b;
  $r[] = $a and $b;
  $r[] = $a | $b;
  $r[] = $a or $b;
  $r[] = ~$a;
  $r[] = $a << $b;
  $r[] = $a >> $b;
  return $r;
}

$r = bwops(8,16);
var_dump($r);

?>
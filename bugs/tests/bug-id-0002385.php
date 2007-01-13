continue with parens

<?

for ($a=0; $a<5; $a++) {
  echo "a: $a\n";
  for ($b=0;$b<5; $b++) {
    echo "b: $b\n";
    if($b==3) {
      continue(2);
    }
  }
}
?>

and break with parens:

<?
for ($a=0; $a<5; $a++) {
  echo "a: $a\n";
  for ($b=0;$b<5; $b++) {
    echo "b: $b\n";
    if($b==3) {
      break(2);
    }
  }
}
?>


continue with a variable:

<?
$m = 2;
for ($a=0; $a<5; $a++) {
  echo "a: $a\n";
  for ($b=0;$b<5; $b++) {
    echo "b: $b\n";
    if($b==3) {
      continue($m);
    }
  }
}
?>


continue with a function call:

<?
function m() { return 2; }

for ($a=0; $a<5; $a++) {
  echo "a: $a\n";
  for ($b=0;$b<5; $b++) {
    echo "b: $b\n";
    if($b==3) {
      continue m();
    }
  }
}
?>


break with a function call:

<?
function n() { return 2; }

for ($a=0; $a<5; $a++) {
  echo "a: $a\n";
  for ($b=0;$b<5; $b++) {
    echo "b: $b\n";
    if($b==3) {
      break n();
    }
  }
}
?>

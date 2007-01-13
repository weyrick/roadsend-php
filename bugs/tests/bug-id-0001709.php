string-port replacements aren't nesting properly
'
<?php

function test_foreach() {
  print("\ntesting foreach:\n");
  
  $strings = array(0, 1, 2, 3);
  
  foreach ($strings as $val) {
    $op .= "outer $val, ";
    foreach ($strings as $val) {
      if ($val == 3) {
	break;
      }
      $op .= "inner $val, ";
    }
    $op .= "\n";
  }
  print("$op\n");
}

function test_for() {
  print("\ntesting for:\n");
  
  for ($i=0; $i<4; $i++) {
    $op .= "outer $i, ";
    for ($j=0; $j<4; $j++) {
      if ($j == 3) {
	break;
      }
      $op .= "inner $j, ";
    }
    $op .= "\n";
  }
  print("$op\n");
}

function test_while() {
  print("\ntesting while:\n");
  
  $i=0;
  while ($i<4) {
    $op .= "outer $i, ";
    $j=0;
    while ($j<4) {
      if ($j == 3) {
	break;
      }
      $op .= "inner $j, ";
      $j++;
    }
    $op .= "\n";
    $i++;
  }
  print("$op\n");
}

function test_do() {
  print("\ntesting do:\n");

  $i = 0;
  do {
    $op .= "outer $i, ";
    $j = 0;
    do {
      if ($j == 3) {
	break;
      }
      $op .= "inner $j, ";
      $j++;
    } while ($j<4);
    $op .= "\n";
    $i++;
  } while ($i<4);
  print("$op\n");
}


test_foreach();
test_while();
test_for();
test_do();


?>


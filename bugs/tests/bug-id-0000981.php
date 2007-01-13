continue accepts an optional integer argument

<?php

echo "\n****** while loop\n";
$i = 0;
while ($i++ < 5) {
  echo "Outer\n";
  while (1) {
    echo "\tMiddle\n";
    while (1) {
      echo "\tInner\n";
      continue 3;
    }
    echo "This never gets output.\n";
  }
  echo "Neither does this.\n";
}


echo "\n****** for loop\n";
for ($i = 0; $i < 5; $i++) {
  echo "Outer\n";
  for (;;) {
    echo "\tMiddle\n";
    for (;;) {
      echo "\tInner\n";
      continue 3;
    }
    echo "This never gets output.\n";
  }
  echo "Neither does this.\n";
}

echo "\n****** foreach loop\n";
$looper = array(0, 1, 2, 3, 4);

foreach ($looper as $i) {
  echo "Outer\n";
  foreach ($looper as $i) {
    echo "\tMiddle\n";
    foreach ($looper as $i) {
      echo "\tInner\n";
      continue 3;
    }
    echo "This never gets output.\n";
  }
  echo "Neither does this.\n";
}

echo "\n****** do loop\n";
$i = 0;
do {
  echo "Outer\n";
  do {
    echo "\tMiddle\n";
    do {
      echo "\tInner\n";
      continue 3;
    } while (1);
    echo "This never gets output.\n";
  } while (1);
  echo "Neither does this.\n";
} while ($i++ < 4)



?>

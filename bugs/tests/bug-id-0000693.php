0000693 foreach and others with no braces cause parse error

<?php

# 	the following causes a parse error

$arr = array("ASdf", "asdf");

foreach ($arr as $key => $val)
     echo "$key, $val\n";


for($i=0; $i<10; $i++)
     echo "$i\n";


function cnt() {
  static $i = 0;

  $i++;
  return $i;
}

while (cnt() < 10) 
     echo "counted\n";



?>
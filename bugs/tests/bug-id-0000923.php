key or value is optional in list()

<?php

$a = array('1'=>'blah','2'=>'meep','3'=>'mope');

reset($a);
while (list(,$v) = each($a)) {
  echo "$v\n";
}

echo "-- next --\n";

reset($a);
while (list($v,) = each($a)) {
  echo "$v\n";
}

echo "-- next --\n";

reset($a);
while (list(,,$v) = each($a)) {
  echo "$v\n";
}

?>

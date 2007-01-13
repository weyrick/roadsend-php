0000927 unable to foreach() on $GLOBALS

<?php

$thisisaglobal = "foo";

foreach ($GLOBALS as $key => $value)
{
  $i++;
}

echo "it worked.\n";

?>

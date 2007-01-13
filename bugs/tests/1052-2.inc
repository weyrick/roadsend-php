<?php

class aclass {
  function afunc() {
     echo "2 and i'm in ".__FILE__."\n";
  }
}

echo "2 file is ".__FILE__."\n";
include('1052-3.inc');
echo "2 file is ".__FILE__."\n";

?>
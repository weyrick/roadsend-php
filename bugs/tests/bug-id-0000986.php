0000986 parse error globalizing a variable variable from a hash
<?php

$aval = 'hi';

function blah() {
  $a['test'] = 'aval';
  global $$a['test'];
  echo "this should say hi--> ".$$a['test']."\n";
}

blah();

?>

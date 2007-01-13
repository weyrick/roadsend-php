0000982 hash key 'default','var' throws parse error

<?php

$b['Default'] = 'hey';
echo "$b[Default]\n";

class aclass {
  function aclass() {
    $a['Default'] = 'nope';
    echo "$a[Default]";
  }
}

$a = new aclass();

?>


 also with the VAR key:
<?php

$b['VAR'] = 'hey';
echo "$b[VAR]\n";

class bclass {
  function bclass() {
    $a['VAR'] = 'nope';
    echo "{$a['VAR']}";
    echo "$a[VAR]";
  }
}

$a = new bclass();


?>

 <?php

$test['include'] = 'yippie';

echo $test['include'];
// wow php doesn't allow this one
//echo $test[include];
echo "$test[include]";
echo "{$test['include']}";


?>
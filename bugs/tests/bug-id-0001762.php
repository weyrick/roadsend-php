runtime error in compiler on variable method name
<?

class aclass {
  function afunc21() {
    echo "you made it\n";
  }
}

$a = new aclass();
$func = 'afunc21';
$a->$func();

?>
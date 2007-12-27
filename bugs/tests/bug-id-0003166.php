foreach an object like an array
<?

class foo {
    var $a=1;
    var $b=2;
    var $c=3;
}

$f = new foo();

foreach ($f as $k => $v) {
    echo "$k => $v\n";
}

?>
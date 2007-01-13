0001057 allow blank class definitions
<?

class aclass {
var $prop = 'hi';
}

class bclass extends aclass {
}

$a = new bclass();
var_dump($a);


?>

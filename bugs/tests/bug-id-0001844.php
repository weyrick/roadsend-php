segfault on string/array access

<?

$a = "hi";
@$a[] = 5;
var_dump($a);

?>
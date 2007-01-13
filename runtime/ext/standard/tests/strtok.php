<?

$string = "This is\tan example\nstring";
/* Use tab and newline as tokenizing characters as well  */
$tok = strtok($string," \n\t");
while ($tok) {
    echo "Word=$tok<br>";
    $tok = strtok(" \n\t");
}


$first_token  = strtok('/something', '/');
$second_token = strtok('/');
var_dump ($first_token, $second_token);

?>
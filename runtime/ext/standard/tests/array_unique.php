<?

// array_unique
$input = array("a" => "green", "red", "b" => "green", "blue", "red");
$input2 = array("a" => "green", "red", "b" => "green", "blue", "red");
var_dump($input);

asort($input2, SORT_STRING);
var_dump($input2);

$result = array_unique($input);
var_dump($result);

$input = array(4,"4","3",4,3,"3");

$result = array_unique($input);
var_dump($result);

?>
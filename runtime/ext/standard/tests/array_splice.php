<?

echo "splice 1\n";
$input = array("red", "green", "blue", "yellow");
$out = array_splice($input, 2);
// $input is now array("red", "green")
var_dump($input);
var_dump($out);

echo "splice 2\n";
$input = array("red", "green", "blue", "yellow");
$out = array_splice($input, 1, -1);
// $input is now array("red", "yellow")
var_dump($input);
var_dump($out);

echo "splice 3\n";
$input = array("red", "green", "blue", "yellow");
$out = array_splice($input, 1, count($input), "orange");
// $input is now array("red", "orange")
var_dump($input);
var_dump($out);

echo "splice 4\n";
$input = array("red", "green", "blue", "yellow");
$out = array_splice($input, -1, 1, array("black", "maroon"));
// $input is now array("red", "green",
//          "blue", "black", "maroon")
var_dump($input);
var_dump($out);

echo "splice 5\n";
$input = array("red", "green", "blue", "yellow");
$out = array_splice($input, 3, 0, "purple");
// $input is now array("red", "green",
//          "blue", "purple", "yellow");
var_dump($input);
var_dump($out);

echo "splice 6, keys\n";
$input = array('n1' => "red", 'n2' => "green", 'n3' => "blue", 'n4' => "yellow");
$out = array_splice($input, 3, 0, "green");
var_dump($input);
var_dump($out);

?>
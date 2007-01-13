<?

echo "Testing uniqid: ";
$str = "prefix";
$ui1 = uniqid($str);
$ui2 = uniqid($str);
if (strlen($ui1) == strlen($ui2) && strlen($ui1) == 19 && $ui1 != $ui2) {
echo("passed\n");
} else {
echo("failed: <$ui1> <$ui2>\n");
}

?>

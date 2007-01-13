<?

echo "1:".number_format(-2354987)."\n";
echo "2:".number_format("foo")."\n";
echo "3:".number_format(0)."\n";
echo "4:".number_format(98095.1)."\n";
echo "5:".number_format(1.2345)."\n";

echo "6:".number_format(-2354987, 2) . "\n";
echo "7:".number_format("foo", 3) . "\n";
echo "8:".number_format(0, 1) . "\n";
echo "9:".number_format(98095.1, 1) . "\n";
echo "10:".number_format(1.2345, 3) . "\n";

#Zend is ignores the dec_point and thousands_sep: echo number_format(-2354987, 2, "foo", "bar") .  " " . number_format("foo", 2, "foo", "bar") . " " .

echo "11:".number_format(0, 0, "foo", "bar") . "\n";
echo "12:".number_format(98095.1, 2, ",", " ") . "\n";
echo "13:".number_format(1.2345 , 5, ",", " ") . "\n";

echo "14:".number_format("9foo8", 2, ".", ",") . "\n";
echo "15:".number_format("chars10chars.987", 3, ".", ",") . "\n";
echo "16:".number_format(".9chars9", 2) . "\n";
echo "17:".number_format("+93.240", 4) . "\n";

?>
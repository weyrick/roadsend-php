<?

echo "o1: ".((object)$a == NULL)."\n";
echo "o2: ".((object)$a == true)."\n";
echo "o3: ".((object)$a == false)."\n";
echo "o4: ".((object)$a == 1)."\n";
echo "o5: ".((object)$a == (object)$b)."\n";


?>
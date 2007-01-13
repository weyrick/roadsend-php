Pcc pukes if you try to access the elements of a multi-dimensional array 
and mix the {} and the []

<?

$test = array('one'=>array('a'=>'b'),'two'=>array('c'=>'d'));

echo $test{'two'}['c'];
echo "\n";

?>
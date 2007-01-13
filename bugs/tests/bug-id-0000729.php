0000729 access to a class property through variable variable: 

<?
class testc { var $test='5'; }
$c = new testc();
$prop = 'test';
echo $c->{$prop} . "\n";
echo $c->$prop . "\n";
?>


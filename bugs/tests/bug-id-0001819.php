It appears to be undocumented, but you can use {} for 
accessing arrays as well as []. i.e. foo{1}{2}

<?
$test = array('foo' => array('foo2' => 'bar'));
echo $test{'foo'}{'foo2'} . "\n";
?>
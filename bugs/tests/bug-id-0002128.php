<?
$out = exec('echo foobar;echo barfoo');
var_dump($out);
$out = exec('echo foobar');
var_dump($out);
?>

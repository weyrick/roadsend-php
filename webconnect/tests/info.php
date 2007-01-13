<?

echo "hello!!!<br>\n";

phpinfo();

?>
<pre>
<?
echo "SERVER:\n";
var_dump($_SERVER);
echo "GET:\n";
var_dump($_GET);
echo "POST:\n";
var_dump($_POST);
echo "REQUEST:\n";
var_dump($_REQUEST);

?>
</pre>
<form action="<? echo $_SERVER['PHP_SELF']; ?>" method="post">
<input type="text" name="sample">
<input type="submit">
</form>

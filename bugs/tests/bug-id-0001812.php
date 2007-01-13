parser problem with echo

When one of the arguments to echo is 'exit', pcc returns a parser error. example:

<?
echo "foo\n", exit();
?>

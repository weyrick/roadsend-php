<?

$r = odbc_connect('fake', 1, 2);
//var_dump($r);
echo "resource? ".is_resource($r)."\n";
echo "resource error msg:\n";
echo odbc_errormsg($r)."\n";
echo "resource state:\n";
echo odbc_error($r)."\n";

echo "global error msg:\n";
echo odbc_errormsg()."\n";
echo "global state:\n";
echo odbc_error()."\n";

?>


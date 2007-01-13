<?

include('connect.inc');

$r = odbc_connect($dsn, $db_user, $db_pass);
//var_dump($r);
echo "resource? ".is_resource($r)."\n";
if (!$r) {
    echo odbc_errormsg();
    exit(1);
}

echo odbc_close($r);

?>


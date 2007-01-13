<?

include('connect.inc');

$r = odbc_connect($directdsn, $db_user, $db_pass);
//var_dump($r);
echo "resource? ".is_resource($r)."\n";
if (!$r) {
    echo odbc_errormsg();
    exit(1);
}

// test caching
$r2 = odbc_connect($directdsn, $db_user, $db_pass);
//var_dump($r2);
echo "resource? ".is_resource($r2)."\n";

echo odbc_close($r);
echo odbc_close($r);

$r = odbc_connect($directdsn, $db_user, $db_pass, SQL_CUR_USE_ODBC);
echo "resource? ".is_resource($r)."\n";
odbc_close_all();
echo odbc_close($r);


?>
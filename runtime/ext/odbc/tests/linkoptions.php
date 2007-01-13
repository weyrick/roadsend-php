<?

include('connect.inc');

$r = odbc_connect($directdsn, $db_user, $db_pass);
//var_dump($r);
echo "resource? ".is_resource($r)."\n";
if (!$r) {
    echo odbc_errormsg();
    exit(1);
}


// odbc_autocommit
$v = odbc_autocommit($r);
var_dump($v);
$v = odbc_autocommit($r, 1);
var_dump($v);
$v = odbc_autocommit($r);
var_dump($v);
$v = odbc_autocommit($r, 0);
var_dump($v);
$v = odbc_autocommit($r);
var_dump($v);

// odbc_data_source
$v = odbc_data_source($r, SQL_FETCH_FIRST);
var_dump($v);
$v = odbc_data_source($r, SQL_FETCH_NEXT);
var_dump($v);

echo odbc_close($r);

?>
<?

include('connect.inc');

$r = odbc_connect($directdsn, $db_user, $db_pass);
//var_dump($r);
echo "resource? ".is_resource($r)."\n";
if (!$r) {
    echo odbc_errormsg();
    exit(1);
}

$rh = odbc_prepare($r, "SELECT * FROM my_table");
if (!$rh) {
    echo "odbc_prepare failed!\n";
    echo odbc_errormsg();
    echo odbc_close($r);    
    exit(1);
}
//var_dump($rh);
echo "resource? ".is_resource($rh)."\n";

// no params
$rv = odbc_execute($rh);
//var_dump($rv);
echo "resource? ".is_resource($rv)."\n";
if (!$rv) {
    echo "odbc_execute failed!\n";
    echo odbc_errormsg();
    echo odbc_close($r);    
    exit(1);
}

$rows = odbc_num_rows($rh);
echo "num rows: $rows\n";
var_dump($rows);

// fetch
while ($rr = odbc_fetch_array($rh)) {
    var_dump($rr);
}

//////////////////// params

$rh = odbc_prepare($r, "SELECT ATAN(?,?)");
if (!$rh) {
    echo "odbc_prepare failed!\n";
    echo odbc_errormsg();
    echo odbc_close($r);    
    exit(1);
}
//var_dump($rh);
echo "resource? ".is_resource($rh)."\n";

$rv = odbc_execute($rh, array('-2','2'));
//var_dump($rv);
echo "resource? ".is_resource($rv)."\n";
if (!$rv) {
    echo "odbc_execute failed!\n";
    echo odbc_errormsg();
    echo odbc_close($r);    
    exit(1);
}

$rows = odbc_num_rows($rh);
echo "num rows: $rows\n";
var_dump($rows);

// fetch
while ($rr = odbc_fetch_array($rh)) {
    var_dump($rr);
}



echo odbc_close($r);

?>
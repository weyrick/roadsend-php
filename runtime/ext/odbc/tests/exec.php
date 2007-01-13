<?

include('connect.inc');

$r = odbc_connect($directdsn, $db_user, $db_pass);
//var_dump($r);
echo "resource? ".is_resource($r)."\n";
if (!$r) {
    echo odbc_errormsg();
    exit(1);
}

$rh = odbc_exec($r, "SELECT * FROM my_table");
if (!$rh) {
    echo "odbc_exec failed!\n";
    echo odbc_errormsg();
    echo odbc_close($r);    
    exit(1);
}
//var_dump($rh);
echo "resource? ".is_resource($rh)."\n";
$rows = odbc_num_rows($rh);
echo "num rows: $rows\n";
var_dump($rows);

$cols = odbc_num_fields($rh);
echo "num fields: $cols\n";
var_dump($cols);

// fetch
while ($rr = odbc_fetch_array($rh)) {
    var_dump($rr);
}

// fetch a specific row
$rr = odbc_fetch_array($rh, 3);
var_dump($rr);

// bad row
$rr = odbc_fetch_array($rh, 200);
var_dump($rr);

// free the result
echo odbc_free_result($rh);
// for good measure
echo odbc_free_result($rh);


echo odbc_close($r);

?>
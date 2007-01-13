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

// test auto fetch
echo "testing auto odbc_fetch_row\n";
$val = odbc_result($rh, 2);
var_dump($val);

// fetch
echo "testing looped odbc_fetch_row\n";
while (odbc_fetch_row($rh)) {
    $val = odbc_result($rh, 1);
    var_dump($val);
    $val1 = odbc_result($rh, 4);    
    var_dump($val1);
    $val2 = odbc_result($rh, 'field2');
    var_dump($val2);    
    $val3 = odbc_result($rh, 'nothere');    
    var_dump($val3);
}

// fetch with row number
echo "testing odbc_fetch_row with row specified\n";
$rval = odbc_fetch_row($rh, 2);
var_dump($rval);
$val = odbc_result($rh, 1);
var_dump($val);
$val1 = odbc_result($rh, 4);    
var_dump($val1);
$val2 = odbc_result($rh, 'field2');
var_dump($val2);    
$val3 = odbc_result($rh, 'nothere');    
var_dump($val3);

// bad row
$rval = odbc_fetch_row($rh, 200);
var_dump($rval);

echo odbc_close($r);

?>
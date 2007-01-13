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

// fetch_row
echo "testing odbc_fetch_row, next\n";
$rv = odbc_fetch_row($rh);
var_dump($rv);
$val = odbc_result($rh, 1);
var_dump($val);

// fetch_row with row number
echo "testing odbc_fetch_row with row specified\n";
$rval = odbc_fetch_row($rh, 2);
var_dump($rval);
$val = odbc_result($rh, 1);
var_dump($val);

// fetch_array, next
echo "testing odbc_fetch_array, next\n";
$rval = odbc_fetch_array($rh);
var_dump($rval);

// fetch_array with row number
echo "testing odbc_fetch_array with row specified\n";
$rval = odbc_fetch_array($rh, 4);
var_dump($rval);

// fetch_object, next
echo "testing odbc_fetch_object, next\n";
$rval = odbc_fetch_object($rh);
var_dump($rval);

// fetch_object with row number
echo "testing odbc_fetch_object with row specified\n";
$rval = odbc_fetch_object($rh, 4);
var_dump($rval);

// fetch_into, next
$ar = array();
echo "testing odbc_fetch_into, next\n";
$rval = odbc_fetch_into($rh, $ar);
var_dump($rval);
var_dump($ar);

// fetch_into with row number
echo "testing odbc_fetch_into with row specified\n";
$rval = odbc_fetch_into($rh, $ar, 7);
var_dump($rval);
var_dump($ar);

echo odbc_close($r);

?>
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

// odbc_cursor
echo odbc_cursor($rh)."\n";

// fields
echo odbc_field_len($rh, 1)."\n";
echo odbc_field_precision($rh, 2)."\n";
echo odbc_field_scale($rh, 3)."\n";

echo odbc_field_name($rh, 2)."\n";
echo odbc_field_num($rh, 'field2')."\n";

echo odbc_field_type($rh, 3)."\n";


echo odbc_close($r);

?>
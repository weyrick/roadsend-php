<?

include('connect.inc');

$r = odbc_connect($directdsn, $db_user, $db_pass);
//var_dump($r);
echo "resource? ".is_resource($r)."\n";
if (!$r) {
    echo odbc_errormsg();
    exit(1);
}


$rh = odbc_gettypeinfo($r);
echo "resource? ".is_resource($rh)."\n";
//var_dump($rh);
if ($rh == NULL) {
    echo odbc_errormsg();
    exit(1);
}
while ($rr = odbc_fetch_array($rh)) {
    // we use ODBC 3, so we differ in column type # for date columns
    // this is not a bug
    if (($rr['TYPE_NAME'] == 'datetime') ||
        ($rr['TYPE_NAME'] == 'timestamp') ||
        ($rr['TYPE_NAME'] == 'date') ||        
        ($rr['TYPE_NAME'] == 'time'))    
    {
        $rr['DATA_TYPE'] = '(hack)';
        $rr['SQL_DATATYPE'] = '(hack)';        
    }
    var_dump($rr);
}

$rh = odbc_gettypeinfo($r, SQL_VARCHAR);
echo "resource? ".is_resource($rh)."\n";
//var_dump($rh);
if ($rh == NULL) {
    echo odbc_errormsg();
    exit(1);
}
while ($rr = odbc_fetch_array($rh)) {
    var_dump($rr);
}


echo odbc_close($r);


?>
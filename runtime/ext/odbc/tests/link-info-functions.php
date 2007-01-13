<?

include('connect.inc');

$r = odbc_connect($directdsn, $db_user, $db_pass);
//var_dump($r);
echo "resource? ".is_resource($r)."\n";
if (!$r) {
    echo odbc_errormsg();
    exit(1);
}


// columnprivileges
$rh = odbc_columnprivileges($r, '', 'test', 'my_table', '%');
//var_dump($rh);
echo "resource? ".is_resource($rh)."\n";
if ($rh == NULL) {
    echo odbc_errormsg();
    exit(1);
}
while ($rr = odbc_fetch_array($rh)) {
    var_dump($rr);
}

// columns
$rh = odbc_columns($r, '', 'test', 'my_table', '%');
//var_dump($rh);
echo "resource? ".is_resource($rh)."\n";
if ($rh == NULL) {
    echo odbc_errormsg();
    exit(1);
}
while ($rr = odbc_fetch_array($rh)) {
    // we use ODBC 3, so we differ in column type # for date columns
    // this is not a bug
    if ($rr['TYPE_NAME'] == 'datetime') {
        $rr['DATA_TYPE'] = '(hack)';
        $rr['SQL_DATA_TYPE'] = '(hack)';        
    }
    var_dump($rr);
}

// foreignkeys
$rh = odbc_foreignkeys($r, '', '', '', '', '', '');
//var_dump($rh);
echo "resource? ".is_resource($rh)."\n";
if ($rh == NULL) {
    echo odbc_errormsg();
}
else {
while ($rr = odbc_fetch_array($rh)) {
    var_dump($rr);
}
}

// primarykeys
$rh = odbc_primarykeys($r, '', 'test', 'my_table');
//var_dump($rh);
echo "resource? ".is_resource($rh)."\n";
if ($rh == NULL) {
    echo odbc_errormsg();
}
else {
while ($rr = odbc_fetch_array($rh)) {
    var_dump($rr);
}
}


// tables
$rh = odbc_tables($r);
//var_dump($rh);
echo "resource? ".is_resource($rh)."\n";
if ($rh == NULL) {
    echo odbc_errormsg();
}
else {
while ($rr = odbc_fetch_array($rh)) {
    var_dump($rr);
}
}

// tableprivileges
$rh = odbc_tableprivileges($r,'','test','%');
//var_dump($rh);
echo "resource? ".is_resource($rh)."\n";
if ($rh == NULL) {
    echo odbc_errormsg();
}
else {
while ($rr = odbc_fetch_array($rh)) {
    var_dump($rr);
}
}

// statistics
$rh = odbc_statistics($r,'','test','my_table','','');
//var_dump($rh);
echo "resource? ".is_resource($rh)."\n";
if ($rh == NULL) {
    echo odbc_errormsg();
}
else {
while ($rr = odbc_fetch_array($rh)) {
    var_dump($rr);
}
}

// specialcolumns
/*
$rh = odbc_specialcolumns($r,SQL_BEST_ROWID,'','test','my_table',0,0);
var_dump($rh);
if ($rh == NULL) {
    echo odbc_errormsg();
}
else {
while ($rr = odbc_fetch_array($rh)) {
    var_dump($rr);
}
}
*/

echo odbc_close($r);


?>
<?

include('connect.inc');

$r = odbc_connect($directdsn, $db_user, $db_pass);
//var_dump($r);
echo "resource? ".is_resource($r)."\n";
if (!$r) {
    echo odbc_errormsg();
    exit(1);
}


$rh = odbc_exec($r, "CREATE TABLE IF NOT EXISTS innotable ( idx INT UNSIGNED NOT NULL ) TYPE=InnoDB");
if ($rh == NULL) {
    echo odbc_errormsg($r);
    exit(1);
}

$rh = odbc_exec($r, "INSERT INTO innotable SET idx=300");
if ($rh == NULL) {
    echo odbc_errormsg($r);
    exit(1);
}

odbc_autocommit($r, false);


$rh = odbc_exec($r, "INSERT INTO innotable SET idx=500");
if ($rh == NULL) {
    echo odbc_errormsg($r);
    exit(1);
}

odbc_rollback($r);

$rh = odbc_exec($r, "SELECT * FROM innotable");
if ($rh == NULL) {
    echo odbc_errormsg($r);
    exit(1);
}

// fetch
while ($rr = odbc_fetch_array($rh)) {
    var_dump($rr);
}

$rh = odbc_exec($r, "INSERT INTO innotable SET idx=700");
if ($rh == NULL) {
    echo odbc_errormsg($r);
    exit(1);
}

odbc_commit($r);

$rh = odbc_exec($r, "SELECT * FROM innotable");
if ($rh == NULL) {
    echo odbc_errormsg($r);
    exit(1);
}

// fetch
while ($rr = odbc_fetch_array($rh)) {
    var_dump($rr);
}

$rh = odbc_exec($r, "DROP TABLE innotable");
if ($rh == NULL) {
    echo odbc_errormsg($r);
    exit(1);
}


echo odbc_close($r);

?>
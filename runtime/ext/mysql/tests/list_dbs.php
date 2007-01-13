<?php

$dbh = mysql_connect('localhost', 'develUser', 'd3v3lpa55');
$db_list = mysql_list_dbs($dbh);

while ($row = mysql_fetch_object($db_list)) {
    echo $row->Database . "\n";
    if (mysql_select_db($row->Database)) {
        echo "I have access to $row->Database\n";
    }
    $rh = mysql_list_tables($row->Database);
    $e = mysql_error();
    var_dump($e);
    while ($rr = mysql_fetch_array($rh)) {
        var_dump($rr);
    }
}

?>

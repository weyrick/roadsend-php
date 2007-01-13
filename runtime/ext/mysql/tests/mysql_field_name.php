<?php
    $link = mysql_pconnect("localhost", "develUser", "d3v3lpa55")
        or die("Could not connect");

    mysql_select_db("test")
        or exit("Could not select database");

    $res = mysql_query("select * from my_table", $link);

    echo mysql_field_name($res, 0) . "\n";
    echo mysql_field_name($res, 2);

?>

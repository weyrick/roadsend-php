<?php
    $link = mysql_pconnect("localhost", "develUser", "d3v3lpa55")
        or die("Could not connect");

    mysql_select_db("test")
        or exit("Could not select database");

    $query = "SELECT last_name, first_name FROM friends";
    $result = mysql_query($query)
        or die("Query failed");

    // fetch rows in reverse order

    for ($i = mysql_num_rows($result) - 1; $i >=0; $i--) {
        if (!mysql_data_seek($result, $i)) {
            echo "Cannot seek to row $i\n";
            continue;
        }

        if(!($row = mysql_fetch_object($result))) {
            echo "Cannot fetch object $i\n";
            continue;
        }
        echo "$row->last_name $row->first_name<br />\n";
    }

    mysql_free_result($result);
?>


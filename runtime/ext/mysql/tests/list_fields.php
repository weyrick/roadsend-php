<?php

$link = mysql_connect('localhost', 'develUser', 'd3v3lpa55');

$fields = mysql_list_fields("test", "my_table", $link);

$columns = mysql_num_fields($fields);

for ($i = 0; $i < $columns; $i++) {
    echo mysql_field_name($fields, $i) . "\n";;
}

?>

<?php

mysql_connect("localhost", "develUser", "d3v3lpa55")
	or die ("Couldn't connect");

mysql_select_db("test")
	or exit("Couldn't select database");

$result = mysql_query("SELECT * FROM my_table");

$fields = mysql_num_fields($result);
$rows   = mysql_num_rows($result);
$i = 0;
$table = mysql_field_table($result, $i);
echo "Your '".$table."' table has ".$fields." fields and ".$rows." records\n";
echo "The table has the following fields\n";
while ($i < $fields) {
    $type  = mysql_field_type($result, $i);
    $name  = mysql_field_name($result, $i);
    $len   = mysql_field_len($result, $i);
    $flags = mysql_field_flags($result, $i);
    echo "type: ".$type." name: ".$name." len: ".$len." flags: ".$flags."\n";
    $i++;
}
mysql_close();

?>

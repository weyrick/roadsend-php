<?php

$link = mysql_connect("localhost", "develUser", "d3v3lpa55") or die("Could not connect: " . mysql_error());

$result = mysql_unbuffered_query("USE bork");
var_dump($result);

print("is resource: " . is_resource($result) . "\n");
var_dump(mysql_fetch_array($result));

$result = mysql_unbuffered_query("SELECT User FROM mysql.user") or die("Could not query: ". mysql_error());            

print("is resource: " . is_resource($result) . "\n");
echo "\nresult is: ".mysql_result($result,3); 

echo "BOTH\n";
var_dump(mysql_fetch_array($result));
echo "ASSOC\n";
var_dump(mysql_fetch_array($result, MYSQL_ASSOC));
echo "NUM\n";
var_dump(mysql_fetch_array($result, MYSQL_NUM));

$result = mysql_query("SELECT * FROM mysql.user") or die("Could not query: ". mysql_error());
echo "\n1result is: ".mysql_result($result,4,'password');
echo "\n2result is: ".mysql_result($result,4,'user.password');

$result = mysql_query("SELECT * FROM mysql.user") or die("Could not query: ". mysql_error());
echo "\nresult is: ".mysql_result($result,4,1);
var_dump(mysql_fetch_field($result));

$result = mysql_query("SELECT * FROM mysql.user") or die("Could not query: ". mysql_error());
echo "\nresult is: ".mysql_dbname($result,6,0); 

// from phpmyadmin
$dbs          = mysql_list_dbs();
echo "\ndbs:\n";
$num_dbs      = ($dbs) ? mysql_num_rows($dbs) : 0;
var_dump($num_dbs);
$real_num_dbs = 0;
for ($i = 0; $i < $num_dbs; $i++) {
    $db_name_tmp = mysql_dbname($dbs, $i);
    var_dump($db_name_tmp);
    $dblink      = mysql_select_db($db_name_tmp);
    if ($dblink) {
        $dblist[] = $db_name_tmp;
        $real_num_dbs++;
    }
}
mysql_free_result($dbs);
var_dump($dblist);

mysql_select_db("test");
$result = mysql_query("UPDATE my_table SET field1 = 'test one' WHERE id=1");
var_dump($result);


mysql_close($link);


?>

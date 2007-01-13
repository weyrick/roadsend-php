<?php

$link = mysql_connect("localhost", "develUser", "d3v3lpa55")
or die("Could not connect\n");
print ("Connected successfully\n");
//echo mysql_get_client_info();
echo mysql_get_server_info($link);
echo mysql_get_host_info($link);
echo mysql_get_proto_info($link);
    
//print ("link is " . $link);
//var_dump($link);

mysql_close($link);
//should be harmless
mysql_close($link);

?>

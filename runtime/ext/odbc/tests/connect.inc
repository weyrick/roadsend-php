<?

$db_user        = "develUser";
$db_pass        = "d3v3lpa55";
$db_name        = "test";

if (PHP_OS == 'WINNT') {
$db_host        = "192.168.0.50";
$dsn =        "DRIVER={MySQL ODBC 3.51 Driver};" .
              "CommLinks=tcpip(Host=$db_host);" .
              "DatabaseName=$db_name;" .
              "uid=$db_user; pwd=$db_pass";
}
else {
$db_host        = "localhost";
$dsn =        "DRIVER={myodbc};" .
              "CommLinks=tcpip(Host=$db_host);" .
              "DatabaseName=$db_name;" .
              "uid=$db_user; pwd=$db_pass";
}

$directdsn = 'myodbc-test';

?>
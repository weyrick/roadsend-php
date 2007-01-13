<?

require('s_common.inc');

$db = sqlite_open($dbname,0640);
echo "resource? ".is_resource($db)."\n";
$r = sqlite_close($db);
var_dump($r);
$r = sqlite_close($db);
var_dump($r);

$db = sqlite_open('/never-exists/this-will-fail',0666,$errmsg);
echo "resource? ".is_resource($db)."\n";
// error messages are different from 2.x to 3.x
echo substr($errmsg,0,10);

?>


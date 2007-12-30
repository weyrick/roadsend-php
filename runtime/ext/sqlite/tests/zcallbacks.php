<?

require('s_common.inc');

$db = makedb();


$data = array(
        array("one", "uno"),
        array("two", "dos"),
        array("three", "tres"),
        );

sqlite_query("CREATE TABLE strings(a,b)", $db);

function implode_args()
{
        $args = func_get_args();
        $sep = array_shift($args);
        return implode($sep, $args);
}

foreach ($data as $row) {
        sqlite_query("INSERT INTO strings VALUES('" . sqlite_escape_string($row[0]) . "','" . sqlite_escape_string($row[1]) . "')", $db);
}

sqlite_create_function($db, "implode", "implode_args");

$r = sqlite_query("SELECT implode('-', a, b) from strings", $db);
while ($row = sqlite_fetch_array($r, SQLITE_NUM)) {
        var_dump($row);
}


$r = sqlite_close($db);


?>


<?

require('s_common.inc');

$db = makedb();

$rh = sqlite_unbuffered_query($db, 'SELECT * FROM mytable');
echo "result resource? ".is_resource($rh)."\n";
echo "num cols: ".sqlite_num_fields($rh)."\n";
if ($rh) {

    // simple fetch_array  loop
    echo "fetching results\n";
    while ($result = sqlite_fetch_array($rh)) {
        var_dump($result);
    }

}
else {
    echo "bad query: ".sqlite_error_string($db);
}

$r = sqlite_close($db);


?>


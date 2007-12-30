<?

require('s_common.inc');

$db = makedb();

$r = sqlite_fetch_column_types('mytable', $db);
var_dump($r);

$rh = sqlite_query($db, 'SELECT * FROM mytable');
echo "result resource? ".is_resource($rh)."\n";
if ($rh) {

    // num_rows
    echo "num rows: ".sqlite_num_rows($rh)."\n";
    
    // simple fetch_array  loop
    echo "fetching results\n";
    while ($result = sqlite_fetch_array($rh)) {
        var_dump($result);
    }

    // simple fetch_object loop    
    // php5 dumps objects differently
    
/*    echo "fetching results object\n";
    sqlite_rewind($rh);
    while ($result = sqlite_fetch_object($rh)) {
        var_dump($result);
    }*/


    // rewind/next loop
    sqlite_rewind($rh);
    while (sqlite_next($rh)) {
        $result = sqlite_current($rh);
        var_dump($result);
        $b = sqlite_has_more($rh);
        echo "has_more?\n";
        $b = sqlite_valid($rh);
        echo "valid?\n";        
        var_dump($b);
        
//        if (function_exists('sqlite_key'))
//            echo "on row: ".sqlite_key($rh)."\n";                
    }

    // seek
    sqlite_seek($rh, 3);
    $result = sqlite_current($rh);
    var_dump($result);

    // seek
    sqlite_seek($rh, 100);
    $result = sqlite_current($rh);
    var_dump($result);    

    // prev loop
    while (sqlite_prev($rh)) {
        $result = sqlite_current($rh);
        var_dump($result);
        $b = sqlite_has_prev($rh);
        echo "has_prev?\n";        
        var_dump($b);
//         
//        if (function_exists('sqlite_key'))
//            echo "on row: ".sqlite_key($rh)."\n";        
    }    


    // columns
    sqlite_seek($rh, 2);
    for ($i = 0; $i < sqlite_num_fields($rh); $i++) {

        $n = sqlite_field_name($rh, $i);
        
        $c = sqlite_column($rh, $i);
        var_dump($c);

        $c = sqlite_column($rh, $n);
        var_dump($c);        
        
    }


    // fetch_all
    $r = sqlite_fetch_all($rh);
    var_dump($r);

    // fetch single
    sqlite_rewind($rh);
    $r = sqlite_fetch_string($rh);
    var_dump($r);
    
}
else {
    echo "bad query: ".sqlite_error_string($db);
}


// array_query
$val = sqlite_array_query($db, 'SELECT * FROM mytable');
var_dump($val);

// single query
$val = sqlite_single_query($db, 'SELECT * FROM mytable');
var_dump($val);
$val = sqlite_single_query($db, 'SELECT * FROM mytable LIMIT 1', true);
var_dump($val);
$val = sqlite_single_query($db, 'SELECT * FROM mytable LIMIT 1', false);
var_dump($val);

$r = sqlite_close($db);


?>


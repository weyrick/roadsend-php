<?

require('s_common.inc');

$db = makedb();


sqlite_create_function($db, 'md5rev', 'md5_and_reverse', 1);
sqlite_create_aggregate($db, 'max_len', 'max_len_step', 'max_len_finalize');


// generic php callback
$rows = sqlite_array_query($db, "SELECT php('md5', my_string) from mytable");
var_dump($rows);

$rows = sqlite_array_query($db, "SELECT php('max', my_float, 2) from mytable");
var_dump($rows);

// callback error
$rows = sqlite_array_query($db, "SELECT php('unknown', my_string) from mytable");
var_dump($rows);


/// PHP UDF

function md5_and_reverse($string)
{
    echo "in callback, original string is $string\n";
    return strrev(md5($string));
}



$sql  = 'SELECT md5rev(my_string) FROM mytable';
$rows = sqlite_array_query($db, $sql);
var_dump($rows);


/// aggregate

$data = array(
   'one',
   'two',
   'three',
   'four',
   'five',
   'six',
   'seven',
   'eight',
   'nine',
   'ten',
   );

sqlite_query($db, "CREATE TABLE strings(a)");
foreach ($data as $str) {
   $str = sqlite_escape_string($str);
   sqlite_query($db, "INSERT INTO strings VALUES ('$str')");
}

function max_len_step(&$context, $string)
{
    echo "in max_len_step: $string\n";
   if (strlen($string) > $context) {
       $context = strlen($string);
   }
}

function max_len_finalize(&$context)
{
    echo "in finalize, context is: $context\n";
    var_dump($context);
   return $context;
}


var_dump(sqlite_array_query($db, 'SELECT max_len(a) from strings'));


$r = sqlite_close($db);


?>


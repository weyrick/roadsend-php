<?

require('s_common.inc');

$db = makedb();

//////

sqlite_query("CREATE TABLE foo(c1 date, c2 time, c3 varchar(64))", $db);
sqlite_query("INSERT INTO foo VALUES ('2002-01-02', '12:49:00', NULL)", $db);
$r = sqlite_query("SELECT * from foo", $db);
var_dump(sqlite_fetch_array($r, SQLITE_BOTH));
$r = sqlite_query("SELECT * from foo", $db);
var_dump(sqlite_fetch_array($r, SQLITE_NUM));
$r = sqlite_query("SELECT * from foo", $db);
var_dump(sqlite_fetch_array($r, SQLITE_ASSOC));

sqlite_exec("DROP TABLE foo", $db);

/////

$strings = array(
        "hello",
        "hello".chr(1)."o",
        chr(1)."hello there",
        "hello".chr(0)."there",
        ""
);

sqlite_query("CREATE TABLE strings(a)", $db);

foreach ($strings as $str) {
    sqlite_query("INSERT INTO strings VALUES('" . sqlite_escape_string($str) . "')", $db);
}

$i = 0;
$r = sqlite_query("SELECT * from strings", $db);
while ($row = sqlite_fetch_array($r, SQLITE_NUM)) {
        if ($row[0] !== $strings[$i]) {
                echo "FAIL!\n";
                var_dump($row[0]);
                var_dump($strings[$i]);
        } else {
                echo "OK!\n";
        }
        $i++;
}

sqlite_exec("DROP TABLE strings", $db);

/////////////


sqlite_query("CREATE TABLE foo(c1 date, c2 time, c3 varchar(64))", $db);
sqlite_query("INSERT INTO foo VALUES ('2002-01-02', '12:49:00', NULL)", $db);
$r = sqlite_unbuffered_query("SELECT * from foo", $db);
var_dump(sqlite_fetch_array($r, SQLITE_BOTH));
$r = sqlite_unbuffered_query("SELECT * from foo", $db);
var_dump(sqlite_fetch_array($r, SQLITE_NUM));
$r = sqlite_unbuffered_query("SELECT * from foo", $db);
var_dump(sqlite_fetch_array($r, SQLITE_ASSOC));

sqlite_exec("DROP TABLE foo", $db);

/////

$data = array(
        "one",
        "two",
        "three"
        );

sqlite_query("CREATE TABLE strings(a VARCHAR)", $db);

foreach ($data as $str) {
        sqlite_query("INSERT INTO strings VALUES('$str')", $db);
}

$r = sqlite_query("SELECT a from strings", $db);
while ($row = sqlite_fetch_array($r, SQLITE_NUM)) {
        var_dump($row);
}

sqlite_exec("DROP TABLE strings", $db);

/////////


sqlite_query("CREATE TABLE strings(a VARCHAR)", $db);

foreach ($data as $str) {
        sqlite_query("INSERT INTO strings VALUES('$str')", $db);
}

$r = sqlite_unbuffered_query("SELECT a from strings", $db);
while ($row = sqlite_fetch_array($r, SQLITE_NUM)) {
        var_dump($row);
}

sqlite_exec("DROP TABLE strings", $db);

/////////////

sqlite_query("CREATE TABLE strings(a VARCHAR)", $db);

foreach ($data as $str) {
        sqlite_query("INSERT INTO strings VALUES('$str')", $db);
}

$r = sqlite_unbuffered_query("SELECT a from strings", $db);
while (sqlite_valid($r)) {
        var_dump(sqlite_current($r, SQLITE_NUM));
        sqlite_next($r);
}
$r = sqlite_query("SELECT a from strings", $db);
while (sqlite_valid($r)) {
        var_dump(sqlite_current($r, SQLITE_NUM));
        sqlite_next($r);
}
sqlite_rewind($r);
while (sqlite_valid($r)) {
        var_dump(sqlite_current($r, SQLITE_NUM));
        sqlite_next($r);
}

sqlite_exec("DROP TABLE strings", $db);

///////

sqlite_query("CREATE TABLE strings(foo VARCHAR, bar VARCHAR, baz VARCHAR)", $db);

echo "Buffered\n";
$r = sqlite_query("SELECT * from strings", $db);
echo "num fields: ".sqlite_num_fields($r)."\n";
for($i=0; $i<sqlite_num_fields($r); $i++) {
        var_dump(sqlite_field_name($r, $i));
}
echo "Unbuffered\n";
$r = sqlite_unbuffered_query("SELECT * from strings", $db, SQLITE_NUM, $errmsg);
if (!$r) {
    var_dump($errmsg);
}
echo "num fields: ".sqlite_num_fields($r)."\n";
for($i=0; $i<sqlite_num_fields($r); $i++) {
        var_dump(sqlite_field_name($r, $i));
}

sqlite_exec("DROP TABLE strings", $db);

/////

$data = array(
        array (0 => 'one', 1 => 'two'),
        array (0 => 'three', 1 => 'four')
        );

sqlite_query("CREATE TABLE strings(a VARCHAR, b VARCHAR)", $db);

foreach ($data as $str) {
        sqlite_query("INSERT INTO strings VALUES('${str[0]}','${str[1]}')", $db);
}

echo "====BUFFERED====\n";
$r = sqlite_query("SELECT a, b from strings", $db);
while (sqlite_valid($r)) {
        var_dump(sqlite_current($r, SQLITE_NUM));
        var_dump(sqlite_column($r, 0));
        var_dump(sqlite_column($r, 1));
        var_dump(sqlite_column($r, 'a'));
        var_dump(sqlite_column($r, 'b'));
        sqlite_next($r);
}

/// XXX this doesn't match PHP5, but ours looks more correct??

/*
echo "====UNBUFFERED====\n";
$r = sqlite_unbuffered_query("SELECT a, b from strings", $db);
while (sqlite_valid($r)) {
        var_dump(sqlite_current($r, SQLITE_NUM));    
        var_dump(sqlite_column($r, 0));
        var_dump(sqlite_column($r, 'b'));
        var_dump(sqlite_column($r, 1));
        var_dump(sqlite_column($r, 'a'));
        sqlite_next($r);
}
*/

/////

$r = sqlite_close($db);


?>


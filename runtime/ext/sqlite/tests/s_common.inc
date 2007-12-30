<?

if (PHP_OS == 'WINNT') {
	$dbname = "c:\\windows\\temp\\test.sqlite";
}
else {
	$dbname = "/tmp/test.sqlite";
}

// always start fresh
if (file_exists($dbname)) {
    unlink($dbname);
}

//echo "this is sqlite: ".sqlite_libversion()."\n";


function makedb() {

    global $dbname;
    
    echo "making test database: $dbname\n"; 
    $db = sqlite_open($dbname,0640,$errmsg);
    echo "resource? ".is_resource($db)."\n";
    if (!$db) {
        die($errmsg);
    }

    sqlite_busy_timeout($db, 10000);
    
/*    
    echo "dropping old test table...\n";
    $SQL = "DROP TABLE IF EXISTS mytable";

    $res = sqlite_exec($db, $SQL, $errmsg);
    if (!$res) {
        echo "$SQL\n";
        die("drop failed: ".$errmsg."\n");
    }
*/

    echo "making test table...\n";
    $SQL = "CREATE TABLE mytable (
            idxNum    INTEGER PRIMARY KEY,
            my_float  NUMERIC,
            my_string TEXT,
            my_blob   BLOB)";

    $res = sqlite_exec($db, $SQL, $errmsg);    
    if (!$res) {
        echo "$SQL\n";        
        die("create failed: ".$errmsg."\n");
    }


    echo "inserting data...\n";
    $SQL = "INSERT INTO mytable VALUES(1, 1.1, 'some short text', 'some blob data');
            INSERT INTO mytable VALUES(2, 2.22, 'some short textsome short text', 'some blob data');
            INSERT INTO mytable VALUES(3, 3.333, 'some short textsdsjdhjshdj sdjhs djhs d', 'some blob data');
            INSERT INTO mytable VALUES(4, 4.4444, 'some short text ksdjksdj ksjd ksjdksjd ', 'some blob data');
            INSERT INTO mytable VALUES(5, NULL, NULL, NULL);";

    $res = sqlite_exec($db, $SQL, $errmsg);    
    if (!$res) {
        echo "$SQL\n";        
        die("create failed: ".$errmsg."\n");
    }
    else {
        // this fails because sqlite 2 returns a different amount than sqlite 3 for multiple queries
//        echo sqlite_changes($db)." rows were inserted\n";
        echo "last insert: ".sqlite_last_insert_rowid($db)."\n";;
    }
    
    return $db;

    
}

function makedbobj() {

    global $dbname;
    
    echo "making test database obj: $dbname\n"; 
    $db = new SQLiteDatabase($dbname,0640,$errmsg);
    echo "object? ".is_object($db)."\n";
    if (!$db) {
        die($errmsg);
    }

    echo "making test table...\n";
    $SQL = "CREATE TABLE mytable (
            idxNum    INTEGER PRIMARY KEY,
            my_float  NUMERIC,
            my_string TEXT,
            my_blob   BLOB)";

    $res = $db->queryExec($SQL, $errmsg);    
    if (!$res) {
        echo "$SQL\n";        
        die("create failed: ".$errmsg."\n");
    }


    echo "inserting data...\n";
    $SQL = "INSERT INTO mytable VALUES(1, 1.1, 'some short text', 'some blob data');
            INSERT INTO mytable VALUES(2, 2.22, 'some short textsome short text', 'some blob data');
            INSERT INTO mytable VALUES(3, 3.333, 'some short textsdsjdhjshdj sdjhs djhs d', 'some blob data');
            INSERT INTO mytable VALUES(4, 4.4444, 'some short text ksdjksdj ksjd ksjdksjd ', 'some blob data');
            INSERT INTO mytable VALUES(5, NULL, NULL, NULL);";

    $res = $db->queryExec($db, $SQL, $errmsg);    
    if (!$res) {
        echo "$SQL\n";        
        die("create failed: ".$errmsg."\n");
    }
    
    return $db;

    
}


?>
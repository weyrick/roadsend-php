<?

$now =  1066316052;
//$now = time();

$snow = date("l dS of F Y h:i:s A",$now);
echo "now starts out as $now which is $snow\n";

// works
echo strtotime ("now", $now), "\n";
echo strtotime ("10 September 2000", $now), "\n";
echo strtotime ("+1 day", $now), "\n";
echo strtotime ("+1 week", $now), "\n";

// doesn't work

// lex error?
echo strtotime ("+1 week 2 days 4 hours 2 seconds", $now), "\n";
// sets day-ordinal and day-number properly but the code that
// looks at those values to manipulate the date requires
// have-date to be set, which doesn't happen
echo strtotime ("next Thursday", $now), "\n";
echo strtotime ("last Monday", $now), "\n";



////////

$dates = array (
    "1999-10-13",
    "Oct 13  1999",
    "2000-01-19",
    "Jan 19  2000",
    "2001-12-21",
    "Dec 21  2001",
    "2001-12-21 12:16",
    "Dec 21 2001 12:16",
    "Dec 21  12:16",
    "2001-10-22 21:19:58",
    "2001-10-22 21:19:58-02",
    "2001-10-22 21:19:58-0213",
    "2001-10-22 21:19:58+02",
    "2001-10-22 21:19:58+0213"
    );

echo "gmt:\n";
putenv ("TZ=GMT");
foreach ($dates as $date) {
    echo date ("Y-m-d H:i:s\n", strtotime ($date));
}


echo "us/eastern\n";
putenv ("TZ=US/Eastern");

foreach ($dates as $date) {
    echo date ("Y-m-d H:i:s\n", strtotime ($date));
}


?>
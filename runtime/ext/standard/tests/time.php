<?

// time
// this works, it will just always fail since tests are run at different seconds
//echo time()."\n";


echo "timezone 1: ".date_default_timezone_set("America/New_York")."\n";
echo "timezone 2: ".date_default_timezone_get()."\n";
echo "timezone 3: ".date_default_timezone_get()."\n";

// checkdate
echo 'checkdate 1:'.checkdate(0, 0, 0)."\n";
echo 'checkdate 2:'.checkdate(1, 1, 1970)."\n";
echo 'checkdate 3:'.checkdate(2, 12, 1978)."\n";
echo 'checkdate 4:'.checkdate('2', '12', '1978')."\n";
echo 'checkdate 5:'.checkdate(2, 29, 2004)."\n";
echo 'checkdate 6:'.checkdate(2, 29, 2003)."\n";
echo 'checkdate 7:'.@checkdate('hello', 'hi there', 'boing')."\n";
// ?
//echo '8:'.checkdate('6 days', '3 months', '2003 years');
echo 'checkdate 8:'.@checkdate('6 days', '3 months', '2003')."\n";
echo 'checkdate 9:'.@checkdate('6 days', '3 months', 2003)."\n";
echo 'checkdate 10:'.checkdate('6', '3', '2003')."\n";
echo 'checkdate 11:'.checkdate(6, 3, 2003)."\n";

// date
echo "date 1: ".date("l \\t\h\e jS")."\n";
echo "date 2: ".date('l \t\h\e jS\\')."\n";

echo "date 3: ".date('[  a  ]')."\n";
echo "*date 4: ".date ("l dS of F Y h:i A e")."\n";
echo "date 4a: ".date ("l dS of F Y h:i A", 1066316052)."\n";
echo "date 5: ".date("l \\t\h\e jS")."\n";
echo "date 6: ".date("F j, Y, g:i a")."\n";                 // March 10, 2001, 5:16 pm
echo "date 7: ".date("m.d.y")."\n";                         // 03.10.01
echo "date 8: ".date("j, n, Y")."\n";                       // 10, 3, 2001
echo "date 9: ".date("Ymd")."\n";                           // 20010310
echo "date 10: ".date('h-i-, j-m-y, it i w Day z ')."\n";  // 05-16-17, 10-03-01, 1631 1618 6 Fripm01
echo "date 11: ".date('\i\t \i\s \t\h\e jS \d\a\y.')."\n";   // It is the 10th day.
echo "*date 12: ".date("D M j G:i: T Y")."\n";               // Sat Mar 10 15:16:08 MST 2001
echo "*date 13: ".date('H:m: \m \i\s\ \m\o\n\t\h')."\n";     // 17:03:17 m is month
echo "*date 14: ".date("H:i:")."\n";                         // 17:16:17
//echo "*date 15: ".date("U")."\n";
echo "date 16: ".date("Z I O")."\n";
$r = date('r');
$r{23} = 'x';
$r{24} = 'x';
echo "date 17: ".$r."\n";

// gmdatr
echo "gmdate 1: ".gmdate("F j, Y, g:i a")."\n";                 // March 10, 2001, 5:16 pm

// mktime
echo "mktime 1: ".mktime(1,1,1,12,12,1978)."\n";
//echo "*mktime 2: ".mktime(1)."\n";
//echo "*mktime 3: ".mktime(1,1)."\n";
echo "mktime 4: ".mktime(1,1,1)."\n";
echo "mktime 5: ".mktime(1,1,1,12)."\n";
echo "mktime 6: ".mktime(1,1,1,12,12)."\n";
echo "mktime 7: ".mktime(1,1,1,12,12,1978)."\n";

echo "mktime 8: ".date ("M-d-Y", mktime (0,0,0,12,32,1997))."\n";
echo "mktime 9: ".date ("M-d-Y", mktime (0,0,0,13,1,1997))."\n";
echo "mktime 10: ".date ("M-d-Y", mktime (0,0,0,1,1,1998))."\n";

echo "?mktime 11: ".date ("M-d-Y", mktime (0,0,0,1,1,98))."\n";

/* status of daylight saving time unknown */
echo "mktime 12: ".mktime(0, 0, 0, 1, 1, 2002)."\n";
/* status of daylight saving time unknown */
echo "mktime 13: ".mktime(0, 0, 0, 1, 1, 2002, -1)."\n";
/* daylight saving time is not in affect */
echo "mktime 14: ".mktime(0, 0, 0, 1, 1, 2002, 0)."\n";
/* daylight saving time is in affect */
echo "?mktime 15: ".mktime(0, 0, 0, 1, 1, 2002, 1)."\n";

/* status of daylight saving time unknown */
echo "mktime 16: ".mktime(0, 0, 0, 7, 1, 2002)."\n";
/* status of daylight saving time unknown */
echo "mktime 17: ".mktime(0, 0, 0, 7, 1, 2002, -1)."\n";
/* daylight saving time is not in affect */
echo "?mktime 18: ".mktime(0, 0, 0, 7, 1, 2002, 0)."\n";
/* daylight saving time is in affect */
echo "mktime 19: ".mktime(0, 0, 0, 7, 1, 2002, 1)."\n";

// last day of month
echo "mktime 20: ".mktime (0,0,0,3,0,2000)."\n";
echo "mktime 21: ".mktime (0,0,0,4,-31,2000)."\n";

echo "gmmktime 1: ".gmmktime(1,1,1,12,12,1978)."\n";

// getdate
//
$today = getdate(mktime(1,1,1)); 
var_dump($today);
//$today = getdate(); 
//var_dump($today);


// strftime

// Outputs: 12/28/2002 - %V,%G,%Y = 52,2002,2002
print "12/28/2002 - %V,%G,%Y = " . strftime("%V,%G,%Y",mktime(0,0,0,12,28,2002)) . "\n";

// Outputs: 12/30/2002 - %V,%G,%Y = 1,2003,2002
print "12/30/2002 - %V,%G,%Y = " . strftime("%V,%G,%Y",mktime(0,0,0,12,30,2002)) . "\n";

// Outputs: 1/3/2003 - %V,%G,%Y = 1,2003,2003
print "1/3/2003 - %V,%G,%Y = " . strftime("%V,%G,%Y",mktime(0,0,0,1,2,2003)) . "\n";

// Outputs: 1/10/2003 - %V,%G,%Y = 2,2003,2003
print "1/10/2003 - %V,%G,%Y = " . strftime("%V,%G,%Y",mktime(0,0,0,1,10,2003)) . "\n";

print "gmstrftime: 1/10/2003 - %V,%G,%Y = " . gmstrftime("%V,%G,%Y",mktime(0,0,0,1,10,2003)) . "\n";

print strftime("%V,%G,%Y");


// localtime
$lt = localtime(mktime(0,0,0,1,10,2003));
print "localtime: \n";
var_dump($lt);

echo "nate mktime: ".mktime(0,0,0,1,10,2003)."\n";

$lt = localtime(mktime(0,0,0,1,10,2003),1);
print "localtime 2: \n";
var_dump($lt);

// gettimeofday
// works but will fail test
$t = gettimeofday();
echo 'se'.substr($t['sec'],0,-2);
echo 'mw'.$t['minuteswest'];
echo 'dt'.$t['dsttime'];
//echo 'us'.substr($t['usec'],0,-2);

// microtime
// works but will fail test
//echo microtime();
//microtime();

/*
$now = 1059800000;
echo strtotime ("now", $now), "\n";
echo strtotime ("10 September 2000", $now), "\n";
echo strtotime ("+1 day", $now), "\n";
echo strtotime ("+1 week", $now), "\n";
echo strtotime ("+1 week 2 days 4 hours 2 seconds", $now), "\n";
echo strtotime ("next Thursday", $now), "\n";
echo strtotime ("last Monday", $now), "\n";
*/
?>


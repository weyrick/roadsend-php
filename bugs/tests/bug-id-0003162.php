0003162: windows: string-> int conversion broken
<?

$UNIXTIME = '1104534831';

$K = 5;

$from = (int) $UNIXTIME - $K;
$to = (int) $UNIXTIME + $K;

echo "$from - $to\n";

$UNIXTIME = 1104534831;

$from = $UNIXTIME - $K;
$to = $UNIXTIME + $K;

echo "$from - $to\n";

?>

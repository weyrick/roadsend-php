<?php # vim600:syn=php:
$filename = tempnam("/tmp", "phpt");

$fp = fopen($filename, "w+") or die("can't open $filename for append");
echo("ftell 1:  " . ftell($fp)              . "\n");
echo("fwrite 1: " . fwrite($fp, "quxbar")   . "\n");
echo("ftell 2:  " . ftell($fp)              . "\n");
echo("fseek 1:  " . fseek($fp, 3, SEEK_SET) . "\n");
echo("ftell 3:  " . ftell($fp)              . "\n");
var_dump(fread($fp, 1));
echo("ftell 4:  " . ftell($fp)              . "\n");
echo("fseek 2:  " . fseek($fp, 4, SEEK_SET) . "\n");
echo("ftell 5:  " . ftell($fp)              . "\n");
echo("fwrite 2: " . fwrite($fp, '!')        . "\n");
echo("ftell 6:  " . ftell($fp)              . "\n");
echo("fseek 3:  " . fseek($fp, 0, SEEK_SET) . "\n");
echo("ftell 7:  " . ftell($fp)              . "\n");
var_dump(fread($fp, 4095));
echo("ftell 8:  " . ftell($fp)              . "\n");
echo("ftruncate:" . ftruncate($fp, 0)       . "\n");
echo("ftell 9:  " . ftell($fp)              . "\n");
echo("rewind:   " . rewind($fp)             . "\n");
echo("ftell 10: " . ftell($fp)              . "\n");
echo("fwrite 3: " . fwrite($fp, "barfoo")   . "\n");
echo("ftell 11: " . ftell($fp)              . "\n");
echo("fseek 4:  " . fseek($fp, 3, SEEK_SET) . "\n");
echo("ftell 12: " . ftell($fp)              . "\n");
var_dump(fread($fp, 1));
echo("ftell 13: " . ftell($fp)              . "\n");
echo("fwrite 4: " . fwrite($fp, '!')        . "\n");
echo("ftell 14: " . ftell($fp)              . "\n");
echo("fseek 5:  " . fseek($fp, 0, SEEK_SET) . "\n");
echo("ftell 15: " . ftell($fp)              . "\n");
var_dump(fread($fp, 4095));
echo("ftell 16: " . ftell($fp)              . "\n");

fclose($fp);
unlink($filename);
?>


 <?php

$filename = dirname(__FILE__)."/test.csv";
#echo "test filename: $filename\n";

if (file_exists($filename))
   unlink($filename);

$fp = fopen($filename, "w");
fwrite($fp, '"One","\"Two\"","Three\"","Four","\\\\",foo,"\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"\\\\,\\\\"'."\n");
fclose($fp);

$fp = fopen($filename, "r");
while (($line = fgetcsv($fp, 1024)))
   var_dump($line);
fclose($fp);

?>

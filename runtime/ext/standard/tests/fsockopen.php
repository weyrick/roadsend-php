<?php

set_time_limit(0);

function necho ($line_number, $string) {
  echo "$line_number: $string\n";
  return $string;
}

$errno = 0;
$errstr = "";
$fp = fsockopen('www.google.com', 80, &$errno, &$errstr);
necho(10, $errno);
necho(20, $errstr);
necho(40, fwrite($fp, "GET http://www.google.com/index.html\n"));
necho(50, fflush($fp));
necho(60, fread($fp, 2048));

$errno = 0;
$errstr = "";
$fp = fsockopen('smtp.roadsend.com', 25, &$errno, &$errstr);
necho(70,  $errno);
necho(80,  $errstr);
necho(100, fwrite($fp, "HELO bob.com\n"));
necho(110, fflush($fp));
necho(120, fread($fp, 80000));

?>

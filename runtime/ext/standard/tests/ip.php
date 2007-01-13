<?php
function necho ($line_number, $string) {
  echo "$line_number: $string\n";
  return $string;
}

print ip2long("127.0.0.255") - ip2long("127.0.0.1") . "\n";

// ip2long
necho(420, ip2long('127.0.0.1'));
necho(430, ip2long('192.168.20.40'));
necho(440, ip2long('199.0.0.2'));
necho(450, ip2long('255.255.255.255'));
necho(460, ip2long('0.0.0.0'));

// long2ip
necho(470, long2ip(2130706433));  // 127.0.0.1
necho(480, long2ip(-1062726616)); // 192.168.20.40
necho(490, long2ip(-956301310));  // 199.0.0.2
necho(500, long2ip(-1));          // 255.255.255.255
necho(510, long2ip(0));           // 0.0.0.0

?>

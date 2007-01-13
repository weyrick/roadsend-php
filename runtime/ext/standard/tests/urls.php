<?php


$url = urlencode("this/is\a\+t est&o f!@#$% ^&*()url 3nc 0d3 _-=+;:,.><[]{}");
echo "$url\n";

echo urldecode($url)."\n";

$url = rawurlencode("this/is\a\+t est&o f!@#$% ^&*()url 3nc 0d3 _-=+;:,.><[]{}");
echo "$url\n";

echo rawurldecode($url)."\n";


$res = parse_url("http://username:password@hostname/path?arg=value#anchor");
var_dump($res);

$res = parse_url("http://invalid_host..name/");
var_dump($res);


?>
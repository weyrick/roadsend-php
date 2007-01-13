<?php


$pizza  = "piece1 piece2 piece3 piece4 piece5 piece6";
$pieces = explode(" ", $pizza);
var_dump($pieces);

$data = "foo:*:1023:1000::/home/foo:/bin/sh";
$val = explode(':',$data);
var_dump($val);

$data = "foo:-:*:-:1023:-:1000:-::-:/home/foo:-:/bin/sh";
$val = explode(':-:',$data);
var_dump($val);

$data = "foo:-:*:-:1023:-:1000:-::-:/home/foo:-:/bin/sh";
$val = explode(':-:',$data,3);
var_dump($val);

// implode
$v = join('*',$pieces);
var_dump($v);

$v = join($pieces,'*-*');
var_dump($v);



?>

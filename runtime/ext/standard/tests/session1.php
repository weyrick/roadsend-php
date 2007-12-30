<?php
// page1.php

//echo "save path is ".session_save_path()."\n";

session_save_path("/tmp/foo");

echo "new save path is ".session_save_path()."\n";

echo "cache expire is ".session_cache_expire()."\n";

session_cache_expire("260");

echo "new cache expire is ".session_cache_expire()."\n";

echo "cache limiter is ".session_cache_limiter()."\n";

session_cache_limiter("private");

echo "new cache limiter is ".session_cache_limiter()."\n";

echo "module is ".session_module_name()."\n";


$a = session_get_cookie_params();
var_dump($a);

session_set_cookie_params("newname","path","domain",true);

$a = session_get_cookie_params();
var_dump($a);

if (PHP_OS == 'WINNT')
  session_save_path("c:\\windows\\temp");   
else
  session_save_path("/tmp");

echo "the real save path is ".session_save_path()."\n";

session_start();

// will be different so check for valid md5
$s = session_id();
echo "session ID is ".preg_match('/^[a-f0-9]{32}$/',$s)."\n";

// if (SID == $s) {
//     echo "constant looks ok\n";
// }

session_regenerate_id();

$s2 = session_id();
// will be different so check for valid md5
echo "new session ID is ".preg_match('/^[a-f0-9]{32}$/',$s2)."\n";

if ($s1 == $s2) {
    echo "ah crap they were the same!!\n";
}

// if (SID == $s2) {
//     echo "constant looks ok\n";
// }

session_id("newidhere");

echo "new session ID is ".session_id()."\n";

class aclass {
    var $v = 'hi';
}

$_SESSION['myarray'] = array('foo'=>4, 8, array(7,9));
$_SESSION['mystring'] = "some | string";
$_SESSION['mybool'] = true;
$_SESSION['mynull'] = NULL;
$_SESSION['myint'] = 4241;
//$_SESSION['myfloat'] = .100;
$_SESSION['myobj'] = new aclass();
$_SESSION['undef'] = 'erase';
unset($_SESSION['undef']);

print_r($_SESSION);

$vs= session_encode();
echo $vs;

session_unset();

print_r($_SESSION);

echo session_encode();

session_decode($vs);
print_r($_SESSION);

?> 

<?

session_start();

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

//session_write_close();

?>
<?

$e = glob('/etc/*.conf');
var_dump($e);

$e = glob('/etc/*', GLOB_MARK|GLOB_NOSORT);
var_dump($e);

?>
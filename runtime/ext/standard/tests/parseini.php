<?

// XXX this is only on gentoo, could make it smarter
$cfile = '/etc/php/cli-php5/php.ini';
if (file_exists($cfile)) {
    $a = parse_ini_file($cfile);
    var_dump($a);
}
else {
    echo "where is php.ini?\n";
}


?>
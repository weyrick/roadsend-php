<?

echo "-[".md5("blork.nob-flanken-boop")."]-";
// won't work until other versions of crypt are done
//$c = crypt('fnerk-lord');
$c = '';
$d = crypt('lady-reptile', 'X4');
echo $c.' - '.$d."\n";

function p($a) {
for ($i=0; $i < strlen($a); $i++) {
  printf("%x", ord($a[$i]));
}
echo "\n";
}

$a = sha1('foo',true);
p($a);
$a = sha1('abc',true);
p($a);
$a = sha1('this is a foobar',true);
p($a);
if (PHP_OS != 'WINNT') {
    $a = sha1_file('/etc/passwd',true);
    p($a);
 }

?>
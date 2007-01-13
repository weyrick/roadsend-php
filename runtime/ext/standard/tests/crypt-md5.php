<?

echo "-[".md5("blork.nob-flanken-boop")."]-";
// won't work until other versions of crypt are done
//$c = crypt('fnerk-lord');
$c = '';
$d = crypt('lady-reptile', 'X4');
echo $c.' - '.$d."\n";

?>
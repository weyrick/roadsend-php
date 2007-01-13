0000796 parser error on empty braces
<?php

if (1) {
} else if (2) {
}

?>

or

<?php

for ($i=0; $i<10; $i++) { }

?>

which really comes from code like this: 
<?

for ($r=0, $num = count($read); $r < $num &&
substr($read[$r], 0, 8) != '* SEARCH'; $r++) {}

?>

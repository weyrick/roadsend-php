<?php
sizeof("Asdf"); //XXX force php-std to load
function afun() {
    $str .= 'zoot';
    eval('$lastiteration = sizeof(' . $str . ') - 1;');
    echo "lastiteration is $lastiteration\n";
}
afun();

?>
<?php
function test($str) {
    $a = base64_encode($str);
    echo "a $a\n";
    $b = base64_decode($a);
    echo "b $b\n";
    echo "c ".md5($b)."\n";
    $res = md5(base64_decode(base64_encode($str)))."\n";
    return $res;
}

for ($i=0; $i < 256; $i++) {
    echo base64_encode("messafe diges".chr($i))."\n";
}


echo test("");
echo test("a");
echo test("abc");
echo test("message digest");
echo test("abcdefghijklmnopqrstuvwxyz");
echo test("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789");
echo test("12345678901234567890123456789012345678901234567890123456789012345678901234567890");


?>
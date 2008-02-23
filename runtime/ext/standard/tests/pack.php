<?php

function hexdump($a) {
    $s = '';
    for ($i=0; $i<strlen($a); $i++) {
        $s .= sprintf("[%02x] ",ord($a{$i}));
    }
    return $s."\n";
}


function tp($fmt, $val) {
    static $index=0;
    echo "[$index]: orig  : ".sprintf("%d | 0x%02x\n",$val,$val);
    $v = pack($fmt, $val);
    echo "[$index]: pack  : ".hexdump($v);
    $v = unpack($fmt, $v);
    echo "[$index]: unpack: ".sprintf("%d | 0x%02x\n",$v[1],$v[1]);
    echo "-----------------------\n";
    $index++;
}

tp("N", 65534);
tp("N", 0);
tp("N", 2147483650);
tp("N", 4294967296);
tp("N", -2147483648);
tp("N", -30000);

tp("V", 65534);
tp("V", 0);
tp("V", 2147483650);
tp("V", 4294967296);
tp("V", -2147483648);


/*
print_r(unpack("A", pack("A", "hello world")));
print_r(unpack("A*", pack("A*", "hello world")));
echo '"'.pack("A9", "hello").'"';
echo "\n";

print_r(unpack("C", pack("C", -127)));
print_r(unpack("C", pack("C", 127)));
print_r(unpack("C", pack("C", 255)));
print_r(unpack("C", pack("C", -129)));

print_r(unpack("H", pack("H", 0x04)));

print_r(unpack("I", pack("I", 65534)));
print_r(unpack("I", pack("I", 0)));
print_r(unpack("I", pack("I", -1000)));
print_r(unpack("I", pack("I", -64434)));
print_r(unpack("I", pack("I", 4294967296)));
print_r(unpack("I", pack("I", -4294967296)));

print_r(unpack("L", pack("L", 65534)));
print_r(unpack("L", pack("L", 0)));
print_r(unpack("L", pack("L", 2147483650)));
print_r(unpack("L", pack("L", 4294967295)));
print_r(unpack("L", pack("L", -2147483648)));

print_r(unpack("S", pack("S", 65534)));
print_r(unpack("S", pack("S", 65537)));
print_r(unpack("S", pack("S", 0)));
print_r(unpack("S", pack("S", -1000)));
print_r(unpack("S", pack("S", -64434)));
print_r(unpack("S", pack("S", -65535)));

print_r(unpack("a", pack("a", "hello world")));
print_r(unpack("a*", pack("a*", "hello world")));

print_r(unpack("c", pack("c", -127)));
print_r(unpack("c", pack("c", 127)));
print_r(unpack("c", pack("c", 255)));
print_r(unpack("c", pack("c", -129)));

print_r(unpack("h", pack("h", 3000000)));

print_r(unpack("i", pack("i", 65534)));
print_r(unpack("i", pack("i", 0)));
print_r(unpack("i", pack("i", -1000)));
print_r(unpack("i", pack("i", -64434)));
print_r(unpack("i", pack("i", -65535)));
print_r(unpack("i", pack("i", -2147483647)));

print_r(unpack("l", pack("l", 65534)));
print_r(unpack("l", pack("l", 0)));
print_r(unpack("l", pack("l", 2147483650)));
print_r(unpack("l", pack("l", 4294967296)));
print_r(unpack("l", pack("l", -2147483648)));

print_r(unpack("n", pack("n", 65534)));
print_r(unpack("n", pack("n", 65537)));
print_r(unpack("n", pack("n", 0)));
print_r(unpack("n", pack("n", -1000)));
print_r(unpack("n", pack("n", -64434)));
print_r(unpack("n", pack("n", -65535)));

print_r(unpack("s", pack("s", 32767)));
print_r(unpack("s", pack("s", 65535)));
print_r(unpack("s", pack("s", 0)));
print_r(unpack("s", pack("s", -1000)));
print_r(unpack("s", pack("s", -64434)));
print_r(unpack("s", pack("s", -65535)));

print_r(unpack("v", pack("v", 65534)));
print_r(unpack("v", pack("v", 65537)));
print_r(unpack("v", pack("v", 0)));
print_r(unpack("v", pack("v", -1000)));
print_r(unpack("v", pack("v", -64434)));
print_r(unpack("v", pack("v", -65535)));
  */

?>

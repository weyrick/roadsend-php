<?php

function hexdump($a) {
    $s = '';
    for ($i=0; $i<strlen($a); $i++) {
        $s .= sprintf("[%02x] ",ord($a{$i}));
    }
    return $s."\n";
}


function tp($fmt, $val) {
    static $index=1;
    echo "[$index]: orig  : ".sprintf("%d | 0x%02x\n",$val,$val);
    $v = pack($fmt, $val);
    echo "[$index]: pack  : ".hexdump($v);
    $v = unpack($fmt, $v);
    echo "[$index]: unpack: ".sprintf("%d | 0x%02x\n",$v[1],$v[1]);
    echo "-----------------------\n";
    $index++;
}

// 1
tp("N", -1);
tp("N", 65534);
tp("N", 0);
tp("N", 2147483650);
tp("N", 4294967296);
tp("N", -2147483648);
tp("N", -30000);

// 8
tp("V", 65534);
tp("V", 0);
tp("V", 2147483650);
tp("V", 4294967296);
tp("V", -2147483648);

// 13
tp("v", 65534);
tp("v", 65537);
tp("v", 0);
tp("v", -1000);
tp("v", -64434);
tp("v", -65535);

// 19
tp("C", -127);
tp("C", 127);
tp("C", 255);
tp("C", -129);

// 23
tp("c", -127);
tp("c", 127);
tp("c", 255);
tp("c", -129);

// 27
tp("L", 65534);
tp("L", 0);
tp("L", 2147483650);
tp("L", 4294967295);
tp("L", -2147483648);

// 32
tp("l", 65534);
tp("l", 0);
tp("l", 2147483650);
tp("l", 4294967295);
tp("l", -2147483648);

// 37
tp("I", 65534);
tp("I", 0);
tp("I", -1000);
tp("I", -64434);
tp("I", 4294967296);
tp("I", -4294967296);

// 43
tp("i", 65534);
tp("i", 0);
tp("i", -1000);
tp("i", -64434);
tp("i", 4294967296);
tp("i", -4294967296);

// 49
tp("S", 65534);
tp("S", 65537);
tp("S", 0);
tp("S", -1000);
tp("S", -64434);
tp("S", -65535);

// 55
tp("s", 65534);
tp("s", 65537);
tp("s", 0);
tp("s", -1000);
tp("s", -64434);
tp("s", -65535);

// 61

/*
print_r(unpack("A", pack("A", "hello world")));
print_r(unpack("A*", pack("A*", "hello world")));
echo '"'.pack("A9", "hello").'"';
echo "\n";

print_r(unpack("H", pack("H", 0x04)));

print_r(unpack("a", pack("a", "hello world")));
print_r(unpack("a*", pack("a*", "hello world")));

print_r(unpack("h", pack("h", 3000000)));

print_r(unpack("n", pack("n", 65534)));
print_r(unpack("n", pack("n", 65537)));
print_r(unpack("n", pack("n", 0)));
print_r(unpack("n", pack("n", -1000)));
print_r(unpack("n", pack("n", -64434)));
print_r(unpack("n", pack("n", -65535)));

  */

?>

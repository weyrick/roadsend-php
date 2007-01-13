<?php

function dumpbt($bt) {
    foreach ($bt as $v) {
        print "file: ".basename($v['file'])."\n";
        print "line: ".$v['line']."\n";
        print "function: ".$v['function']."\n";
        print "args: ".$v['args']."\n";
    }
}

function c() {
  $a = debug_backtrace();
  dumpbt($a);
}

function b($b,$c) {
  c();
}

function a($b) {
  b('1','2');
  $a = debug_backtrace();
  dumpbt($a);
}


a('test');

?>

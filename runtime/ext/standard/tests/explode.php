<?php
echo "1\n";
var_dump(explode("foo", "barfoobarfoobar"));
echo "2\n";
var_dump(explode("barfoobarfoobar", "foo"));
echo "3\n";
var_dump(explode("foo", "foo"));
echo "4\n";
var_dump(explode("foo", "foo", 0));
echo "5\n";
var_dump(explode("foo", "barFOOBARFOOBAR"));
echo "6\n";
var_dump(explode("foo", "barfoobarfoobar", 1));
echo "7\n";
var_dump(explode("foo", "barfoobarfoobar", 2));
?>


<?php

var_dump(strstr("test string", "test"));
var_dump(strstr("test string", "string"));
var_dump(strstr("test string", "strin"));
var_dump(strstr("test string", "t s"));
var_dump(strstr("test string", "g"));
var_dump(md5(strstr("te".chr(0)."st", chr(0))));
var_dump(strstr("tEst", "test"));
var_dump(strstr("teSt", "test"));
var_dump(@strstr("", ""));
var_dump(@strstr("a", ""));
var_dump(@strstr("", "a"));
var_dump(md5(@strstr("\\\\a\\", "\\a")));

?>
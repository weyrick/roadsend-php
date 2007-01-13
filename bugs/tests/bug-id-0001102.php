<?php
$data = '(#11/19/2002#)';
var_dump(preg_split('/\b/', $data));
var_dump(preg_split('/,/', "one,two,,three,,"));
var_dump(preg_split('/\b/', $data, PREG_SPLIT_OFFSET_CAPTURE));
?>
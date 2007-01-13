<?php


include "smErrors.inc";
include "smObject.inc";

$obj = new sm_Object();
$obj->debugLog("foo");

SM_fatalErrorPage("oops");

?>
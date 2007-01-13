<?php 
include "includetest.inc";
include("includetest.inc");
require "includetest.inc";
require("includetest.inc");

include_once "includetest-once.inc";
require_once "includetest-once.inc";
include_once("includetest-once.inc");
require_once("includetest-once.inc");

$includesuffix = ".inc";

include "includetest" . $includesuffix;
include("includetest" . $includesuffix);
require "includetest" . $includesuffix;
require("includetest" . $includesuffix);

include_once "includetest-once" . $includesuffix;
require_once "includetest-once" . $includesuffix;
include_once("includetest-once" . $includesuffix);
require_once("includetest-once" . $includesuffix);




?>

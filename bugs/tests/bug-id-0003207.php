<?php

function flup() { return "asdfbar"; }

${flup()} = "foo";

echo ${"asdf" . "bar"};

class wibble {
    var $moo = "cow";
}


$wibbler = new wibble();

$mo = "mo";
if (isset($wibbler->{$mo . "o"})) {
    echo $wibbler->{"mo" . "o"};
}

echo "\n";
// also, it seems as though we're not being permissive 
// enough with the foreach key and value lvals.
foreach (array("a" => "b", "c" => "d") as 
         $arr['c'] => $arr['d']) 
{
    echo $arr['c'];
    echo $arr['d'];
}

echo "\n";


foreach (array("a" => "b", "c" => "d") as $wibbler->{$mo . "o"} => $wibbler->{$mo . "b"}) {
    echo $wibbler->{"mo" . "o"};
    echo $wibbler->{"mo" . "b"};
}

echo "\n";


// don't forget foreach with a :
foreach (array("a" => "b", "c" => "d") as 
         $arr['c'] => $arr['d']) :
    echo $arr['c'];
    echo $arr['d'];
endforeach;

echo "\n";


foreach (array("a" => "b", "c" => "d") as $wibbler->{$mo . "o"} => $wibbler->{$mo . "b"}) :
    echo $wibbler->{"mo" . "o"};
    echo $wibbler->{"mo" . "b"};
endforeach;

echo "\n";

?>

<?php

$var_array = array("color" => "blue",
                   "size"  => "medium",
                   "shape" => "sphere");
extract($var_array);

echo "EXTR_OVERWRITE (def): $color, $size, $shape\n";

$var_array = array("color" => "blue",
                   "size"  => "medium",
                   "shape" => "sphere");
extract($var_array, EXTR_PREFIX_ALL, "pref");

//$a = get_defined_vars();
//var_dump($a);

echo "PREFIX_ALL: $pref_color, $pref_size, $pref_shape\n";


$var_array = array("color" => "blue",
                   "size"  => "medium",
                   "blahshape" => "sphere");
extract($var_array, EXTR_PREFIX_SAME, "newpref");

echo "PREFIX_SAME: $newpref_color, $newpref_size, $blahshape\n";


$var_array = array("color" => "blue2",
                   "size"  => "medium2",
                   "22" => "sphere2");
extract($var_array, EXTR_PREFIX_INVALID, "inpref");

echo "PREFIX_INVALID: $color, $size, $inpref_22\n";


$var_array = array("color" => "blue5",
                   "size"  => "medium6",
                   "noshape" => "sphere7");
extract($var_array, EXTR_SKIP);

echo "EXTR_SKIP: $color, $size, $noshape\n";


$var_array = array("color" => "blue22",
                   "size"  => "medium33",
                   "meepshape" => "sphere44");
extract($var_array, EXTR_PREFIX_IF_EXISTS, "ifpref");

echo "EXTR_PREFIX_IF_EXISTS: $ifpref_color, $ifpref_size, $meepshape\n";


$var_array = array("color" => "blue384729",
                   "size"  => "medium438472",
                   "fnord" => "sphere");
extract($var_array, EXTR_IF_EXISTS);


echo "EXTR_IF_EXISTS: $color, $size, $fnord\n";


$var_array = array("color" => "blue",
                   "size"  => "medium",
                   "shape" => "sphere");
extract($var_array, EXTR_REFS);

echo "EXTR_IF_EXISTS: $color, $size, $shape\n";
$var_array['color'] = 'newvalue';
echo "EXTR_IF_EXISTS: $color, $size, $shape\n";

?>

<?php

$simple = "<para>cdata test<note>simple note</note><note> sample  two

end here</note><open test='test'></open></para>";

$p = xml_parser_create();
xml_parse_into_struct($p,$simple,$vals,$index);
xml_parser_free($p);
echo "Index array\n";
print_r($index);
echo "\nVals array\n";
print_r($vals);

$p2 = xml_parser_create();
xml_parser_set_option($p2, XML_OPTION_CASE_FOLDING, 0);
xml_parser_set_option($p2, XML_OPTION_SKIP_WHITE, 0);
xml_parse_into_struct($p2,$simple,$vals,$index);
xml_parser_free($p2);
echo "Index array\n";
print_r($index);
echo "\nVals array\n";
print_r($vals);


?>
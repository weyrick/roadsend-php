<?php


// NOTE this fails when used with PHP4 xml parser (expat)

$file = getenv('PCC_HOME').'/runtime/ext/xml/tests/data.xml';
echo "working with $file\n";
$depth = 0;

function startElement($parser, $name, $attrs) {
    global $depth;
    for ($i = 0; $i < $depth; $i++) {
        print "  ";
    }
    print "$name\n";
    $depth++;
    print_r($attrs);
}

function endElement($parser, $name) {
    global $depth;
    $depth--;
}

$xml_parser = xml_parser_create();

xml_set_element_handler($xml_parser, "startElement", "endElement");
if (!($fp = fopen($file, "r"))) {
    die("could not open XML input");
}

while ($data = fread($fp, 4096)) {
    if (!xml_parse($xml_parser, $data, feof($fp))) {
        die(sprintf("XML error: %s at line %d",
                    xml_error_string(xml_get_error_code($xml_parser)),
                    xml_get_current_line_number($xml_parser)));
    }
    print "on line: ".xml_get_current_line_number($xml_parser)."\n";
    print "on col: ".xml_get_current_column_number($xml_parser)."\n";
    print "on byte: ".xml_get_current_byte_index($xml_parser)."\n";
        
}
xml_parser_free($xml_parser);


?>
<?php


$file = getenv('PCC_HOME').'/runtime/ext/xml/tests/data.xml';
echo "working with $file\n";

class xmlparser {

    function startElement($parser, $name, $attrs) {
        print "start: $name\n";
        print_r($attrs);
    }
    
    function endElement($parser, $name) {
        print "end: $name\n";
    }

}

$pObj =& new xmlparser();

$xml_parser = xml_parser_create();

xml_set_element_handler($xml_parser, "startElement", "endElement");
xml_set_object($xml_parser, $pObj);

if (!($fp = fopen($file, "r"))) {
    die("could not open XML input");
}

while ($data = fread($fp, 4096)) {
    if (!xml_parse($xml_parser, $data, feof($fp))) {
        die(sprintf("XML error: %s at line %d",
                    xml_error_string(xml_get_error_code($xml_parser)),
                    xml_get_current_line_number($xml_parser)));
    }
}
xml_parser_free($xml_parser);


// using array method
$xml_parser2 = xml_parser_create();
xml_set_element_handler($xml_parser2, array($pObj, "startElement"), array($pObj, "endElement"));

if (!($fp = fopen($file, "r"))) {
    die("could not open XML input");
}

while ($data = fread($fp, 4096)) {
    if (!xml_parse($xml_parser2, $data, feof($fp))) {
        die(sprintf("XML error: %s at line %d",
                    xml_error_string(xml_get_error_code($xml_parser2)),
                    xml_get_current_line_number($xml_parser2)));
    }
}
xml_parser_free($xml_parser2);



?>
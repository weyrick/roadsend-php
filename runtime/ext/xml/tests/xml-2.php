<?php

// NOTE this fails when used with php4 xml parser (expat)

$file = getenv('PCC_HOME').'/runtime/ext/xml/tests/data2.xml';
echo "working with $file\n";

function startElement($parser, $name, $attrs) {
    print "start: [$name]\n";
    print_r($attrs);
}

function endElement($parser, $name) {
    print "end: [$name]\n";
}

function cdata($parser, $data) {
    print "cdata: [$data]\n";
}

function default_h($parser, $data) {
    print "default: [$data]\n";
}

function ext_ent($parser, $names, $base, $sysid, $pubid) {
    print "external: [$names] [$sysid] [$pubid]\n"; 
}

function notation($parser, $name, $base, $sysid, $pubid) {
    print "notation: [$names] [$sysid] [$pubid]\n"; 
}

function pi_h($parser, $target, $data) {
    print "pi: [$target] [$data]";
}

function unparsed($parser, $name, $base, $sysid, $pubid, $notation) {
    print "unparsed: [$names] [$sysid] [$pubid] [$notation]\n"; 
}

$xml_parser = xml_parser_create();

xml_set_element_handler($xml_parser, 'startElement', 'endElement');
xml_set_character_data_handler($xml_parser, 'cdata');
xml_set_default_handler($xml_parser, 'default_h');
xml_set_external_entity_ref_handler($xml_parser, 'ext_ent');
xml_set_notation_decl_handler($xml_parser, 'notation');
xml_set_processing_instruction_handler($xml_parser, 'pi_h');
xml_set_unparsed_entity_decl_handler($xml_parser, 'unparsed');

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


?>
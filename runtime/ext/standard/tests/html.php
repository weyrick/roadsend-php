<?

$t = get_html_translation_table(HTML_ENTITIES);
var_dump($t);

$t = get_html_translation_table(HTML_SPECIALCHARS);
var_dump($t);

$t = get_html_translation_table(HTML_SPECIALCHARS, ENT_NOQUOTES);
var_dump($t);

$t = get_html_translation_table(HTML_SPECIALCHARS, ENT_QUOTES);
var_dump($t);


$new = htmlspecialchars("<a href='test'>Test \"test\"</a>\n");
echo $new; 

$new = htmlspecialchars("<a href='test'>Test \"test\"</a>\n", ENT_NOQUOTES);
echo $new; 

$new = htmlspecialchars("<a href='test'>Test \"test\"</a>\n", ENT_QUOTES);
echo $new; 

$str = '';
for ($i=30; $i < 256; $i++) {
    $str .= chr($i)."\n";
}

echo "$str\n";
echo "compat: ".htmlentities($str)."\n";
echo "noquotes: ".htmlentities($str, ENT_NOQUOTES)."\n";
echo "quotes: ".htmlentities($str, ENT_QUOTES)."\n";

echo "compat: ".html_entity_decode(htmlentities($str, ENT_QUOTES))."\n";
echo "noquotes: ".html_entity_decode(htmlentities($str, ENT_QUOTES), ENT_NOQUOTES)."\n";
echo "quotes: ".html_entity_decode(htmlentities($str, ENT_QUOTES), ENT_QUOTES)."\n";

?>
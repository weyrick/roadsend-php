<?php

$s = ob_get_status();
var_dump($s);

ob_start();

echo "This is a large foo";

$worp = ob_get_contents();

$s = ob_get_status();

ob_end_clean();

echo "You tried to say: $worp\n";

unset($s['size']); // we don't calc size like zend
var_dump($s);



ob_start();

ob_start();

$s = ob_get_status(true);

echo "This is a large foo";

ob_end_flush();

echo "wibble";

ob_end_flush();

unset($s[0]['size']); // we don't calc size like zend
unset($s[1]['size']); // we don't calc size like zend
var_dump($s);

ob_start();

print "Hello World";

$out = ob_get_clean();
$out = strtolower($out);

var_dump($out);



?>
<?php

function callback($buffer) {

  // replace all the apples with oranges
  return (ereg_replace("apples", "oranges", $buffer));

}

ob_start("callback");

?>

<html>
<body>
<p>It's like comparing apples to oranges.
</body>
</html>

<?php

ob_end_flush();

?>
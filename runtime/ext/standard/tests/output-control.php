<?php

ob_start();

echo "This is a large foo";

$worp = ob_get_contents();

ob_end_clean();

echo "You tried to say: $worp\n";




ob_start();

ob_start();

echo "This is a large foo";

ob_end_flush();

echo "wibble";

ob_end_flush();

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
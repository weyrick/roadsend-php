<?

$c = NULL;
foreach ($c as $k => $v) {
    echo "shouldn't see this: $k => $v\n";
}

echo "this should run, however\n";

?>
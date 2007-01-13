<?

// string escaping
$str = "foo ' '' \' \\ \" \\\"";
echo sqlite_escape_string($str)."\n";;

$str = "this has a ".chr(0)." char in the middle";
echo sqlite_escape_string($str)."\n";;

// encodeing/decoding binary
$data = array(
        "hello there",
        "this has a ".chr(0)." char in the middle",
        chr(1)." this has an 0x01 at the start",
        "this has ".chr(1)." in the middle",
        ""
        );

foreach ($data as $item) {
    echo "raw: $item\n";
    $coded = sqlite_udf_encode_binary($item);
    echo "coded: $coded\n";
    $decoded = sqlite_udf_decode_binary($coded);
    echo "decoded: $decoded\n";
    if ($item != $decoded) {
        echo "FAIL:\n";
        echo "[$item]\n";
        echo "[$decoded]\n";
    }
}


?>


<?


if (count($_POST)) {
    echo "these fields were posted:<br>\n";
    var_dump($_POST);
}
else {
    echo "nothing was posted\n";
}


?>
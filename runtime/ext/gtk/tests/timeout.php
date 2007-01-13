<?

if (!extension_loaded('gtk')) {
	dl( 'php_gtk.' . PHP_SHLIB_SUFFIX);
}

gtk::timeout_add(1, "callback", "some data");
echo "callback added\n";
gtk::main();

function callback($data) {
  static $i=0;

  if ($i < 1000) {
    $i++;
    echo "callback called\n";
    return TRUE;
  } else {
    echo "callback finished, data was: $data\n";
    gtk::main_quit();
  }

}

?>
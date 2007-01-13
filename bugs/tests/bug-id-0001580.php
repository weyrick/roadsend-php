failure to compile on return in global context
<?

echo "up here\n";

if (0) {
  return;
} else {
  print (include("1580.inc")) . "\n";
  return;
}

echo "hi\n";

?>
down here

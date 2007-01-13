0003230: line numbers incorrect with multiline strings in double quotes
<?

echo __LINE__."\n";

echo "foo\n";

echo __LINE__."\n";

echo 'string line 1
two
three
four
five';

echo "\n".__LINE__."\n";

echo "string line 1
two
three\n\n
four
five\n";

echo __LINE__."\n";

?>
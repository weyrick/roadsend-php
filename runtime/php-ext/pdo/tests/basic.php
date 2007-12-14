<?

echo ((extension_loaded('pdo')) ? "PDO extension is loaded" : "no PDO extension")."\n";
echo ((class_exists('pdo')) ? "PDO class exists" : "no PDO class")."\n";
echo ((class_exists('PDOStatement')) ? "PDOStatement class exists" : "no PDOStatement class")."\n";


?>
done

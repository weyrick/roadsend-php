0001345 parse error on class with method 'string'

<?

class aclass {

	function string($string) {
		echo "your silly string was $string\n";
	}

}

$a = new aclass();
$a->string('a phony phalacy');

?>



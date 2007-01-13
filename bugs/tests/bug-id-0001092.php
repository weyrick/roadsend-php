0001092 able to override builtin function 'error'

Note: This test only produces a warning, and then only when compiled.
<?

function error($msg) {
	echo "error, your keyboard is one firE!!!!!!!\n";
}

error('meep');

?>

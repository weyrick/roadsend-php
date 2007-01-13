<?

/***
 *
 * A sample include file
 *
 */

// top level code is always run when included
echo ":: including inc2.php\n";

function inc2_function($a, $b) {

    echo "calling inc1_function: $a, $b\n";
    return false;
    
}

?>
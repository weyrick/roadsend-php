 0002492: more array/reference blues

this code is used in phpmyadmin to extract variables from GET/POST and make them global. the problem occurs when there is an array in one of them (because the script passed something like "foo[]=12&foo[]=13") and it recurses in the function.

<?php

function PMA_gpc_extract($array, &$target) {
    if (!is_array($array)) {
        return FALSE;
    }
    $is_magic_quotes = get_magic_quotes_gpc();
    foreach ($array AS $key => $value) {
        if (is_array($value)) {
            // there could be a variable coming from a cookie of
            // another application, with the same name as this array
            unset($target[$key]);

            PMA_gpc_extract($value, $target[$key]); //<-- this is the problem
        } else if ($is_magic_quotes) {
            $target[$key] = stripslashes($value);
        } else {
            $target[$key] = $value;
        }
    }
    return TRUE;
}

$_GET['blah'] = array('val1' => 'foo1', 'val2' => 'foo2');
PMA_gpc_extract($_GET, $GLOBALS);

var_dump($GLOBALS['blah']);

?>

The gist of the problem is that the reference lookup of $target[$key] 
actually has to create the entry, i.e. call php-hash-lookup-ref with #t
  for create?. Here is a more specific test:

<?php

function nothing(&$target) {
    //save a reference to $target that will last even after nothing() has
    //returned.  the problem is that, after nothing() has returned, their 
    //var_dump() won't print the entry it created as a reference, because the
    //reference count dropped.  but we don't use reference counting, so we 
    //still print it as a reference.  whether that's a bug or not, it is a 
    //separate issue.  
    $GLOBALS['save'] =& $target;
}

//the function does nothing, but the call creates the hashtable, and an entry in it
nothing($foo['blah']);
print "foo:\n";
var_dump($foo);


function evenless($target) {
}

//this function call doesn't even create the hashtable
evenless($choad['blah']);
print "choad:\n";
var_dump($choad);

//also, using reference assignment will create the hashtable and a key in it
$bar =& $baz['blah'];
var_dump($baz);

//but using a non-reference assignment does nothing.
$bar = $zot['blah'];
var_dump($zot);


?>

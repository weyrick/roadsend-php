<?php

function inverse($x) {
    if (!$x) {
        throw new Exception('Division by zero.');
    }
    else return 1/$x;
}

function inverse2($x) {
    if (!$x) {
        throw new Other2('Division by zero.');
    }
    else return 1/$x;
}

class Other2 extends Exception {
    var $foo = 'excellent';
}

try {
    echo inverse(5) . "\n";
    echo inverse(0) . "\n";
} catch (Exception $e) {
    echo 'Caught exception: ',  $e->getMessage(), "\n";
} catch (Other $e) {
    echo 'Caught other exception';
} catch (Other2 $e) {
    echo "Caught other exception 2";
}

// Continue execution
echo 'Hello World';

try {
    echo inverse2(0) . "\n";
} catch (Other $e) {
    echo 'Caught other exception';
} catch (Other2 $e) {
    echo "Caught other exception 2";
}


// nested, rethrows
try {
        funcfunc();
} catch (Exception $ex) {
        print "caught an exception\n";
}

function funcfunc() {
        try {
                func();
        } catch (Exception $ex) {
                throw $ex;
        }
}
function func() {
        throw new Exception('blah', 101);
}

?>

<?
/**
 * This is a simple Hello World console application example.
 *
 * All files in the project are compiled to a single executable. The
 * entry point into the program is the Main File, which you can set in
 * Project Properties.
 *
 * If you press the green Play button above, the project will be compiled
 * and then run.
 *
 * You can also start the project in the Debugger by pressing the
 * "Run In Debugger" button on the debugger toolbar above.
 *
 * When the program is run in the IDE, output will show up in the Output
 * window below. You can also view the output as HTML in the HTML Tab.
 *
 * If there were any errors during the build, they will be listed in the
 * Build window below. You can get more detailed build output by changing
 * the Debug Level in Tools -> IDE Options in the Main Menu.
 *
 */

// include a project file so we can call a function define elsewhere
// in the project
include('inc.php');

// call function from include file
includeFunc('foo');

// If you run a program in the debugger you can mouse over a variable
// to see it's current value
$a = "Welcome to the Roadsend Compiler!\n\n";

print ":: $a\n";

$b = array('one' => array('two'),
                    3,
                    "four");

var_dump($b);

function my_function($adjective) {

    $s = "have a $adjective day!";
    return $s;

}

/**
 *
 * The IDE includes function parameter help. Uncomment the line
 * below, and continue the my_function call by typing a "(" and pausing
 * for just a moment.
 *
 * The IDE will tell you which parameters are available to that function.
 *
 */
//echo my_function

class myClass {

    var $size = 50;
    var $height = 2;

    function myClass() {

        /**
         * There is also popup help for class methods and variables.
         * Uncomment the line below and continue the call to $this->size
         * by typing a ">" and pausing for just a moment. The IDE will
         * popup the methods and functions available in this class
         *
         */
         //$this-

    }


    function classFunc() {
        echo "Call to classFunc\n";
    }

}

$c = new myClass();
$c->classFunc();

?>
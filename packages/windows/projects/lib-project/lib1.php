<?
/**
 * This is a sample Library project.
 *
 * Library projects compile to libraries of functions, as both a dynamic
 * library (.DLL) and a static library (.A). There is no executable
 * file (.EXE) when a library is compiled.
 *
 * You would create a library project when you want to share functions between
 * multiple projects.
 *
 * For an example of using a library in an application, open the "cl-use-lib"
 * project.
 *
 *
 */

echo "Library was loaded\n";

// include other library project files full of functions
include('lib2.php');
include('lib3.php');

function myLibFunc($a) {

    echo "in myLibFunc: $a\n";

}


?>
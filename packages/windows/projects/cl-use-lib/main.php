<?
/**
 * This is a sample stand alone project that uses a Library that was built
 * from a Library Project (lib-project).
 *
 * IMPORTANT -- For this project to compile correctly, you must load and
 *              build the "lib-project" project first.
 *
 * The following tabs are used in the Project Properties:
 *
 *  Search Paths - The library project directory is listed here so the
 *                 compiler can find the library we wish to use
 *
 *  Libraries    - After the search path is listed, any libraries in those
 *                 paths will be listed here. Selected libraries will be used
 *                 in the project.
 *
 *  Linked Projects - Here we have selected the project file (.lrj) from our
 *                    library project. This will let the IDE know we want
 *                    parameter help and popup function help from this project.
 *                    Because we have it selected, the functions from the
 *                    library we are using show up in the Code tabe on the left.
 *
 */

// include the main library include file so we have access to the
// functions it provides
include('lib1.php');

// call a library function that we loaded from a previously compiled library
myLibFunc('houston, we have lift off');

?>
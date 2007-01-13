<?
/****************************************************************
 * This project demonstrates a CGI application.
 *
 * It is similiar to a stand alone executable, but is meant to be run
 * from a web server through the CGI interface.
 *
 * The difference between a CGI application and a stand alone application
 * is that some processing is done automatically at startup that
 * prepares the application to handle a web request and return information
 * back to the web client.
 *
 * The standard PHP super globals are filled with information the
 * client submitted during the request ($_GET, _$POST, $_COOKIE). There
 * are also many useful variables passed from the web server in
 * the $_SERVER and $_ENV super globals.
 *
 * A "Content-type" header is automatically printed when the program
 * runs. This is required by the web server so that it can send
 * information back to the client in the proper format.
 *
 * Your compiled CGI program should work with any web server that supports
 * the CGI 1.1 interface.
 *
 * Note that unlike a compiled web application, there is only one entry
 * point into your CGI application (the "main file"). You may have multiple
 * files in your project, but it is up to your mainfile to examine the
 * variables passed to the script and execute the desired code.
 *
 * The $_SERVER['PATH_TRANSLATED'] variable may be useful for this.
 *
 */


// sample include file
include('inc.php');

echo "Compiled CGI application<br>\n";

?>
<form action="<? echo $_SERVER['PHP_SELF']; ?>" method="POST">
<input type="text" name="var1" value="submit me">
<input type="submit">
</form>
<?

// check our variable and smile if we're told to
// this function is in our include file
if ($_POST['var1'] == 'smile')
    handleSmile();

echo "<pre>\n";
var_dump($_POST);
var_dump($_GET);
var_dump($_REQUEST);
var_dump($_COOKIE);
echo "</pre>\n";

phpinfo();

?>
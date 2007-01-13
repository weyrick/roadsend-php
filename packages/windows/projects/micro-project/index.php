<?

/***
 *
 * This is the index page on the MicroServer site
 *
 */

// images and other files are served normally, but have to exist on
// disk, they are _not_ compiled into the executable
?>
<center><img src="/images/reSmLogo.png"></center>
<?

echo "This is the default index page<br>\n";

// there is a special function that, when executed, will close the server
echo "<a href='{$_SERVER['PHP_SELF']}?close=1'>Click To Stop Web Server</a><br>\n";
if ($_GET['close'] == '1')
    re_mhttpd_stop();


?>
<a href="info.php">Show information on this query and the Roadsend Compiler</a><br>
<a href="/home/main.php">Sample page</a><br>

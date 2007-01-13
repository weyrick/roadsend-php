<?php

if (PHP_OS == 'WINNT') {
  echo "this breaks normal php\n";
  exit;
}

error_reporting(E_ALL);

function necho ($line_number, $string) {
  echo "$line_number: $string\n";
  return $string;
}

//// constants (commented out ones are not implemented in php-4.3)
//necho(10, STREAM_FILTER_READ);
//necho(20, STREAM_FILTER_WRITE);
//necho(30, STREAM_FILTER_ALL);
//necho(40, PSFS_PASS_ON);
//necho(50, PSFS_FEED_ME);
//necho(60, PSFS_ERR_FATAL);
necho(70, STREAM_USE_PATH);
necho(80, STREAM_REPORT_ERRORS);
//necho(90, STREAM_CLIENT_ASYNC_CONNECT);
//necho(100, STREAM_CLIENT_PERSISTENT);
//necho(110, STREAM_SERVER_BIND);
//necho(120, STREAM_SERVER_LISTEN);
//necho(130, STREAM_NOTIFY_RESOLVE);
necho(140, STREAM_NOTIFY_CONNECT);
necho(150, STREAM_NOTIFY_AUTH_REQUIRED);
necho(160, STREAM_NOTIFY_MIME_TYPE_IS);
necho(170, STREAM_NOTIFY_FILE_SIZE_IS);
necho(180, STREAM_NOTIFY_REDIRECTED);
necho(190, STREAM_NOTIFY_PROGRESS);
//necho(200, STREAM_NOTIFY_COMPLETED);
necho(210, STREAM_NOTIFY_FAILURE);
necho(220, STREAM_NOTIFY_AUTH_RESULT);
necho(230, STREAM_NOTIFY_SEVERITY_INFO);
necho(240, STREAM_NOTIFY_SEVERITY_WARN);
necho(250, STREAM_NOTIFY_SEVERITY_ERR);

// stream_context_get_options, stream_context_set_options
// stream_context_set_params, stream_get_meta_data
$fp = fopen("/tmp/foobar-context-test-file", "w+");
necho(260, "stream_context_get_options:");
var_dump(stream_context_get_options($fp));
necho(270, stream_context_set_option($fp, "the-wrapper", "the-option", "the-value"));
necho(280, "stream_context_get_options:");
var_dump(stream_context_get_options($fp));


/* XXX get these working. They seem to have implemented in Zend _after_ we did the streams
 * stuff. -Nate
 */
//necho(290, stream_context_set_params($fp, array("param1" => "val1", "param2" => "val2")));
//function callback() { echo "callback called\n"; }
//necho(291, stream_context_set_params($fp, array("notification" => "callback")));
//necho(300, "stream_get_meta_data:");
//var_dump(stream_get_meta_data($fp));

necho(310, "stream_context_get_options:");
var_dump(stream_context_get_options($fp));
necho(320, fclose($fp));


// 




// http input
$handle = fopen("http://www.roadsend.com/license/rpl1.txt",'r');

//it looks like writing it with feof() exposes a bug in Zend.  not 100%
//sure.  but it looks like you have to read from the handle one extra 
//time in zend before feof signals an eof.  maybe because the file ends
//with a newline?  dunno.
//while (!feof ($handle)) {

while ($buffer = fgets($handle)) {
    echo "--<$buffer>--";
}
fclose ($handle);

?>
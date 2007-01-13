<?

/**
 * This is a sample MicroServer project.
 *
 * It resembles a normal PHP web application, in that all files in the
 * project are meant to be called from a web browser. For example, this
 * project contains the files:
 *
 *  /index.php
 *  /info.php
 *  /home/main.php
 *
 * And will be accessed in a web browser as (for example):
 * http://localhost/index.php
 * and
 * http://localhost/home/main.php
 *
 * But a MicroServer project will not be run through Apache or another
 * web server. It will be compiled to a stand alone .EXE file with
 * a built in web server. When the .EXE file is run, a server is started
 * on a configurable port, at which point a web browser can be opened
 * to the correct URL on the localhost, and the application can be accessed
 * locally.
 *
 * This allows you to compile your web applications for offline use, and no
 * webserver needs to be installed on the target system.
 *
 * You can set the default port that the server runs on in the
 * MicroServer Application tabe of the Project Properties.
 *
 * You can start the compiled .EXE with the following parameters:
 *  microapp.exe [-d n] [-p n] [-l file.log]
 *
 *    -d N         Set debug level to N
 *    -p N         Start server on port N
 *    -l file.log  Log all requests to file.log
 *
 *
 */


 /**
  * This file is a special file that is run once when the application
  * loads. It may be used to run startup functions neccessary for your
  * application.
  *
  * Here we just launch a browser
  *
  */

// This text runs on start and shows up in the command window
echo "Sample MicroServer App Started at: http://localhost:".RE_MHTTPD_PORT."/\n";

// launch a browser using the windows ShellExecute function
win_shellexecute("open", 'http://localhost:'.RE_MHTTPD_PORT.'/', '', '', SW_RESTORE);

?>
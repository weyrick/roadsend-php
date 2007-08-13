<?php
/*
   +----------------------------------------------------------------------+
   | PHP Version 4                                                        |
   +----------------------------------------------------------------------+
   | Copyright (c) 1997-2002 The PHP Group                                |
   +----------------------------------------------------------------------+
   | This source file is subject to version 2.02 of the PHP license,      |
   | that is bundled with this package in the file LICENSE, and is        |
   | available at through the world-wide-web at                           |
   | http://www.php.net/license/2_02.txt.                                 |
   | If you did not receive a copy of the PHP license and are unable to   |
   | obtain it through the world-wide-web, please send a note to          |
   | license@php.net so we can mail you a copy immediately.               |
   +----------------------------------------------------------------------+
   | Authors: Ilia Alshanetsky <iliaa@php.net>                            |
   |          Preston L. Bannister <pbannister@php.net>                   |
   |          Marcus Boerger <helly@php.net>                              |
   |          Derick Rethans <derick@php.net>                             |
   |          Sander Roobol <sander@php.net>                              |
   | (based on version by: Stig Bakken <ssb@fast.no>)                     |
   | (based on the PHP 3 test framework by Rasmus Lerdorf)                |
   +----------------------------------------------------------------------+
 */

/*
	Require exact specification of PHP executable to test (no guessing!).
	Die if any internal errors encountered in test script.
	Regularized output for simpler post-processing of output.
	Optionally output error lines indicating the failing test source and log
	for direct jump with MSVC or Emacs.
*/

/*
 * TODO:
 * - do not test PEAR components if base class and/or component class cannot be instanciated
 */


// change into the PHP source directory.

if (getenv('TEST_PHP_SRCDIR')) {
	@chdir(getenv('TEST_PHP_SRCDIR'));
}

$cwd = getcwd();

// delete as much output buffers as possible
while(@ob_end_clean());
if (ob_get_level()) echo "Not all buffers were deleted.\n";

error_reporting(E_ALL);
ini_set('magic_quotes_runtime',0); // this would break tests by modifying EXPECT sections

// Get the executable to tesd from the env variable
if (getenv('TEST_PHP_EXECUTABLE')) {
	$php = getenv('TEST_PHP_EXECUTABLE');
}

// If we weren't told what pcc binary to use,
// try to figure out a php executable
if (empty($php) || !file_exists($php)) {
    //echo "environment variable TEST_PHP_EXECUTABLE not set. Trying to find pcc.\n";
   $php = trim(`which pcc`);
}

// Last ditch effort, try the default location
if (empty($php) || !file_exists($php)) {
   echo "No pcc in your path. Trying default location.\n";
   $os = PHP_OS;
   if (substr(strtoupper($os),0,3) != 'LIN')
       $php = 'c:/roadsend/local/bin/pcc.exe';
   else
       $php = '/usr/bin/pcc';
}

if (empty($php) || !file_exists($php)) {

    if ($argc > 1)
        $php = $argv[1];

}

// If we're here and we don't have a php executable, time to leave
if (empty($php) || !file_exists($php)) {
	error("Can't find pcc. Please set the environment variable TEST_PHP_EXECUTABLE with the location.");
}

if (getenv('TEST_PHP_LOG_FORMAT')) {
	$log_format = strtoupper(getenv('TEST_PHP_LOG_FORMAT'));
} else {
	$log_format = 'LEOD';
}
/*
if (function_exists('is_executable') && !@is_executable($php)) {
	error("invalid PHP executable specified by TEST_PHP_EXECUTABLE  = " . $php);
}
*/
// Check whether a detailed log is wanted.
if (getenv('TEST_PHP_DETAILED')) {
	define('DETAILED', getenv('TEST_PHP_DETAILED'));
} else {
	define('DETAILED', 0);
}

if (getenv('ZEND_COMPAT') == 1) {
    echo "running in ZEND_COMPAT mode: all EXPECT sections moved to RTEXPECT\n";
}

// Check whether user test dirs are requested.
if (getenv('TEST_PHP_USER')) {
	$user_tests = explode (',', getenv('TEST_PHP_USER'));
} else {
	$user_tests = array();
}

// List of files to delete after the tests are done.
$toDelete = array();

// Get info from php
$info_file = realpath(dirname(__FILE__)) . '/run-test-info.php';
@unlink($info_file);
$php_info = '<?php echo "
PHP_SAPI    : " . PHP_SAPI . "
PHP_VERSION : " . phpversion() . "
ZEND_VERSION: " . zend_version() . "
PHP_OS      : " . PHP_OS . " - " . php_uname() ."
PCC_VERSION : " . PCC_VERSION;
?>';

// synedit highlight problem -- DELETE ME :) <?
save_text($info_file, $php_info);
$ini_overwrites = array(
		'mbstring.script_encoding=pass',
		'output_handler=',
		'zlib.output_compression=Off',
		'open_basedir=',
		'safe_mode=0',
		'disable_functions=',
		'output_buffering=Off',
		'error_reporting=2047',
		'display_errors=1',
		'log_errors=0',
		'html_errors=0',
		'track_errors=1',
		'report_memleaks=1',
		'docref_root=/phpmanual/',
		'docref_ext=.html',
		'error_prepend_string=',
		'error_append_string=',
		'auto_prepend_file=',
		'auto_append_file=',
		'magic_quotes_runtime=0',
		'session.auto_start=0'
	);
$info_params = array();
settings2array($ini_overwrites,$info_params);
settings2params($info_params);
$php_info = `$php -f $info_file`;
@unlink($info_file);
define('TESTED_PHP_VERSION', `$php --version`);


// Set up some test file varables
$testFileVars = array ('%CWD%' => $cwd
                       );


// Write test context information.
echo "
=====================================================================
CWD         : $cwd
PHP         : $php $php_info
Extra dirs  : ";
foreach ($user_tests as $test_dir) {
	echo "{$test_dir}\n              ";
}
echo "
=====================================================================
";

// Determine the tests to be run.

$test_files = array();
$test_results = array();
$GLOBALS['__PHP_FAILED_TESTS__'] = array();

// If parameters given assume they represent selected tests to run.
if (isset($argc) && $argc > 1) {
	for ($i=1; $i<$argc; $i++) {
		$testfile = realpath($argv[$i]);
		if (is_dir($testfile)) {
			find_files($testfile);
		} else if (preg_match("/\.phpt$/", $testfile)) {
			$test_files[] = $testfile;
		}
	}
	$test_files = array_unique($test_files);

	// Run selected tests.
	if (count($test_files)) {
		usort($test_files, "test_sort");
		echo "Running selected tests.\n";
		foreach($test_files AS $name) {
			$test_results[$name] = run_test($php,$name);
		}
		if (getenv('REPORT_EXIT_STATUS') == 1 and ereg('FAILED( |$)', implode(' ', $test_results))) {
			exit(1);
		}
		exit(0);
	}
}

// Compile a list of all test files (*.phpt).
$test_files = array();
$exts_to_test = get_loaded_extensions();
$exts_tested = count($exts_to_test);
$exts_skipped = 0;
$ignored_by_ext = 0;
sort($exts_to_test);
$test_dirs = array('tests', 'ext');

if (empty($user_tests)) {
  foreach ($test_dirs as $dir) {
	  find_files("{$cwd}/{$dir}", ($dir == 'ext'));
  }
}
else {
  foreach ($user_tests as $dir) {
	find_files($dir, ($dir == 'ext'));
  }
}

function find_files($dir,$is_ext_dir=FALSE,$ignore=FALSE)
{
	global $test_files, $exts_to_test, $ignored_by_ext, $exts_skipped, $exts_tested;

	$o = opendir($dir) or error("cannot open directory: $dir");
	while (($name = readdir($o)) !== FALSE) {
		if (is_dir("{$dir}/{$name}") && !in_array($name, array('.', '..', 'CVS'))) {
			$skip_ext = ($is_ext_dir && !in_array($name, $exts_to_test));
			if ($skip_ext) {
				$exts_skipped++;
			}
			find_files("{$dir}/{$name}", FALSE, $ignore || $skip_ext);
		}

		// Cleanup any left-over tmp files from last run.
		if (substr($name, -4) == '.tmp') {
			@unlink("$dir/$name");
			continue;
		}

		// Otherwise we're only interested in *.phpt files.
		if (substr($name, -5) == '.phpt') {
			if ($ignore) {
				$ignored_by_ext++;
			} else {
				$testfile = realpath("{$dir}/{$name}");
				$test_files[] = $testfile;
			}
		}
	}
	closedir($o);
}

function test_sort($a, $b) {
	global $cwd;

	$ta = strpos($a, "{$cwd}/tests")===0 ? 1 + (strpos($a, "{$cwd}/tests/run-test")===0 ? 1 : 0) : 0;
	$tb = strpos($b, "{$cwd}/tests")===0 ? 1 + (strpos($b, "{$cwd}/tests/run-test")===0 ? 1 : 0) : 0;
	if ($ta == $tb) {
		return strcmp($a, $b);
	} else {
		return $tb - $ta;
	}
}

$test_files = array_unique($test_files);
usort($test_files, "test_sort");

$start_time = time();

echo "TIME START " . date('Y-m-d H:i:s', $start_time) . "
=====================================================================
";

foreach ($test_files as $name) {
	$test_results[$name] = run_test($php,$name);
}

$end_time = time();

// Summarize results

if (0 == count($test_results)) {
	echo "No tests were run.\n";
	return;
}

$n_total = count($test_results);
$n_total += $ignored_by_ext;

$sum_results = array('PASSED'=>0, 'WARNED'=>0, 'SKIPPED'=>0, 'FAILED'=>0);
foreach ($test_results as $v) {
	$sum_results[$v]++;
}
$sum_results['SKIPPED'] += $ignored_by_ext;
$percent_results = array();
while (list($v,$n) = each($sum_results)) {
	$percent_results[$v] = (100.0 * $n) / $n_total;
}

// do some cleanup.
foreach ($toDelete as $fileToDelete) {
    @unlink("$cwd/{$fileToDelete}");
}

echo "
=====================================================================
TIME END " . date('Y-m-d H:i:s', $end_time);

$summary = "
=====================================================================
TEST RESULT SUMMARY
---------------------------------------------------------------------
Exts skipped    : " . sprintf("%4d",$exts_skipped) . "
Exts tested     : " . sprintf("%4d",$exts_tested) . "
---------------------------------------------------------------------
Number of tests : " . sprintf("%4d",$n_total) . "
Tests skipped   : " . sprintf("%4d (%2.1f%%)",$sum_results['SKIPPED'],$percent_results['SKIPPED']) . "
Tests warned    : " . sprintf("%4d (%2.1f%%)",$sum_results['WARNED'],$percent_results['WARNED']) . "
Tests failed    : " . sprintf("%4d (%2.1f%%)",$sum_results['FAILED'],$percent_results['FAILED']) . "
Tests passed    : " . sprintf("%4d (%2.1f%%)",$sum_results['PASSED'],$percent_results['PASSED']) . "
---------------------------------------------------------------------
Time taken      : " . sprintf("%4d seconds", $end_time - $start_time) . "
=====================================================================
";
echo $summary;

$failed_test_summary = '';
if (count($GLOBALS['__PHP_FAILED_TESTS__'])) {
	$failed_test_summary .= "
=====================================================================
FAILED TEST SUMMARY
---------------------------------------------------------------------
";
	foreach ($GLOBALS['__PHP_FAILED_TESTS__'] as $failed_test_data) {
		$failed_test_summary .=  $failed_test_data['test_name'] . $failed_test_data['info'] . "\n";
	}
	$failed_test_summary .=  "=====================================================================\n";
}

if ($failed_test_summary && !getenv('NO_PHPTEST_SUMMARY')) {
	echo $failed_test_summary;
}

if (getenv('REPORT_EXIT_STATUS') == 1 and $sum_results['FAILED']) {
	exit(1);
}
 
//
//  Write the given text to a temporary file, and return the filename.
//

function save_text($filename,$text)
{
	$fp = @fopen($filename,'w') or error("Cannot open file '" . $filename . "' (save_text)");
	fwrite($fp,$text);
	fclose($fp);
	if (1 < DETAILED) echo "
FILE $filename {{{
$text
}}} 
";
}

//
//  Write an error in a format recognizable to Emacs or MSVC.
//

function error_report($testname,$logname,$tested) 
{
	$testname = realpath($testname);
	$logname  = realpath($logname);
	switch (strtoupper(getenv('TEST_PHP_ERROR_STYLE'))) {
	case 'MSVC':
		echo $testname . "(1) : $tested\n";
		echo $logname . "(1) :  $tested\n";
		break;
	case 'EMACS':
		echo $testname . ":1: $tested\n";
		echo $logname . ":1:  $tested\n";
		break;
	}
}

//
//  Run an individual test case.
//

function run_test($php,$file)
{
	global $log_format, $info_params, $ini_overwrites, $toDelete;

	if (DETAILED) echo "
=================
TEST $file
";

	// Load the sections of the test file.
	$section_text = array(
		'TEST'     => '(unnamed test)',
		'SKIPIF'   => '',
		'GET'      => '',
		'ARGS'     => '',
		'PCCARGS'  => '',
		'RTEXPECT' => ''
	);

	$fp = @fopen($file, "r") or error("Cannot open test file: $file");

	$section = '';
	while (!feof($fp)) {
		$line = fgets($fp);

		// Match the beginning of a section.
		if (ereg('^--([A-Z]+)--',$line,$r)) {
			$section = $r[1];
			$section_text[$section] = '';
			continue;
		}
		
		// Add to the section text.
		$section_text[$section] .= $line;
	}
	fclose($fp);

    // if we're running zend type tests, substitute EXPECT for RTEXPECT
    if (getenv('ZEND_COMPAT') == 1) {
        $section_text['RTEXPECT'] = $section_text['EXPECT'];
        $section_text['EXPECT'] = '';
    }

	/* For GET/POST tests, check if cgi sapi is avaliable and if it is, use it. */
	if ((!empty($section_text['GET']) || !empty($section_text['POST']))) {
		if (file_exists("./sapi/cgi/php")) {
			$old_php = $php;
			$php = realpath("./sapi/cgi/php") . ' -C ';
		}
	}

	$shortname = str_replace($GLOBALS['cwd'].'/', '', $file);
	$tested = trim($section_text['TEST'])." [$shortname]";

	$tmp = realpath(dirname($file));
	$tmp_skipif = $tmp . uniqid('/phpt.');
	$tmp_file   = ereg_replace('\.phpt$','.php',$file);
	$tmp_post   = $tmp . uniqid('/phpt.');

	@unlink($tmp_skipif);
	@unlink($tmp_file);
	@unlink($tmp_post);

	// unlink old test results	
	@unlink(ereg_replace('\.phpt$','.exp',$file));
	@unlink(ereg_replace('\.phpt$','.out',$file));
	@unlink(ereg_replace('\.phpt$','.rtout',$file));
	@unlink(ereg_replace('\.phpt$','.rtexp',$file));

	// Reset environment from any previous test.
	putenv("REDIRECT_STATUS=");
	putenv("QUERY_STRING=");
	putenv("PATH_TRANSLATED=");
	putenv("SCRIPT_FILENAME=");
	putenv("REQUEST_METHOD=");
	putenv("CONTENT_TYPE=");
	putenv("CONTENT_LENGTH=");

	// Check if test should be skipped.
	$info = '';
	$warn = false;
	if (array_key_exists('SKIPIF', $section_text)) {
		if (trim($section_text['SKIPIF'])) {
			save_text($tmp_skipif, $section_text['SKIPIF']);
			$extra = substr(PHP_OS, 0, 3) !== "WIN" ?
				"unset REQUEST_METHOD;": "";
				
			$output = `$extra $php $info_params -f $tmp_skipif`;
			@unlink($tmp_skipif);
			if (eregi("^skip", trim($output))) {
				echo "SKIP $tested";
				$reason = (eregi("^skip[[:space:]]*(.+)\$", trim($output))) ? eregi_replace("^skip[[:space:]]*(.+)\$", "\\1", trim($output)) : FALSE;
				if ($reason) {
					echo " (reason: $reason)\n";
				} else {
					echo "\n";
				}
				if (isset($old_php)) {
					$php = $old_php;
				}
				return 'SKIPPED';
			}
			if (eregi("^info", trim($output))) {
				$reason = (ereg("^info[[:space:]]*(.+)\$", trim($output))) ? ereg_replace("^info[[:space:]]*(.+)\$", "\\1", trim($output)) : FALSE;
				if ($reason) {
					$info = " (info: $reason)";
				}
			}
			if (eregi("^warn", trim($output))) {
				$reason = (ereg("^warn[[:space:]]*(.+)\$", trim($output))) ? ereg_replace("^warn[[:space:]]*(.+)\$", "\\1", trim($output)) : FALSE;
				if ($reason) {
					$warn = true; /* only if there is a reason */
					$info = " (warn: $reason)";
				}
			}
		}
	}

	// Default ini settings
	$ini_settings = array();
	// additional ini overwrites
	//$ini_overwrites[] = 'setting=value';
	settings2array($ini_overwrites, $ini_settings);

	// Any special ini settings 
	// these may overwrite the test defaults...
	if (array_key_exists('INI', $section_text)) {
		settings2array(preg_split( "/[\n\r]+/", $section_text['INI']), $ini_settings);
	}
	settings2params($ini_settings);

	// We've satisfied the preconditions - run the test!
	save_text($tmp_file,$section_text['FILE']);
	if (array_key_exists('GET', $section_text)) {
		$query_string = trim($section_text['GET']);
	} else {
		$query_string = '';
	}

	putenv("REDIRECT_STATUS=1");
	putenv("QUERY_STRING=$query_string");
	putenv("PATH_TRANSLATED=$tmp_file");
	putenv("SCRIPT_FILENAME=$tmp_file");

	$args = $section_text['ARGS'] ? ' -- '.$section_text['ARGS'] : '';

	$pccargs = parseTestFileVars(trim($section_text['PCCARGS']));

	if (array_key_exists('POST', $section_text) && !empty($section_text['POST'])) {

		$post = trim($section_text['POST']);
		save_text($tmp_post,$post);
		$content_length = strlen($post);

		putenv("REQUEST_METHOD=POST");
		putenv("CONTENT_TYPE=application/x-www-form-urlencoded");
		putenv("CONTENT_LENGTH=$content_length");

		//$cmd = "$php$ini_settings $pccargs \"$tmp_file\" 2>&1 < $tmp_post";
		$cmd = "$php $pccargs \"$tmp_file\" 2>&1 < $tmp_post";

	} else {

		putenv("REQUEST_METHOD=GET");
		putenv("CONTENT_TYPE=");
		putenv("CONTENT_LENGTH=");

		//$cmd = "$php$ini_settings $pccargs \"$tmp_file\" $args 2>&1";
		$cmd = "$php -d 0 $pccargs \"$tmp_file\" $args 2>&1";
	}

	if (DETAILED) echo "
CONTENT_LENGTH  = " . getenv("CONTENT_LENGTH") . "
CONTENT_TYPE    = " . getenv("CONTENT_TYPE") . "
PATH_TRANSLATED = " . getenv("PATH_TRANSLATED") . "
QUERY_STRING    = " . getenv("QUERY_STRING") . "
REDIRECT_STATUS = " . getenv("REDIRECT_STATUS") . "
REQUEST_METHOD  = " . getenv("REQUEST_METHOD") . "
SCRIPT_FILENAME = " . getenv("SCRIPT_FILENAME") . "
COMMAND $cmd
";

    // if there is a PRECOMPILE, run the commands
    if (array_key_exists('PRECOMPILE', $section_text)) {
        $preCompile = trim($section_text['PRECOMPILE']);
        if (!empty($preCompile)) {
            if (DETAILED)
                echo "PRECOMPILE: [$preCompile]\n";
            system($preCompile);
        }
    }

    // compile command
	$out = `$cmd`;

    // if there is a POSTCOMPILE, run the commands
    if (array_key_exists('POSTCOMPILE', $section_text)) {
        $postCompile = trim($section_text['POSTCOMPILE']);
        if (!empty($postCompile)) {
            if (DETAILED)
                echo "POSTCOMPILE: [$postCompile]\n";
            $out .= `$postCompile`;
        }
    }

    // If there is a RunTimeEXPECTED set, run the
    // created executable and capture the output
    global $cwd;
    $rtexpect = trim($section_text['RTEXPECT']);
    if ((0 == strcmp(trim($out),trim($section_text['EXPECT']))) && !empty($rtexpect)) {

       $rtcmd = ereg_replace('\.phpt$','', $file);
       $rtexpect = parseTestFileVars($rtexpect);

        // if there is a PRERUN, run the commands
        if (array_key_exists('PRERUN', $section_text)) {
            $preRun = trim($section_text['PRERUN']);
            if (!empty($preRun)) {
                if (DETAILED)
                    echo "PRERUN: [$preRun]\n";
                system($preRun);
            }
        }

       // run command
       $rtout = `$rtcmd 2>&1`;
    }
    
    @unlink(ereg_replace('\.phpt$','.o', $file));
    //@unlink(ereg_replace('\.phpt$','', $file));
    if (strpos($pccargs,'-l') !== FALSE) {
//       $type = '_s';
//       if (strpos($pccargs,'-O') !== FALSE || strpos($pccargs,'--static') !== FALSE) {
           $type = '_u';
//       }
       @unlink(ereg_replace('\.phpt$',$type . '.o', $file));
    }
	@unlink($tmp_post);

	// Does the output match what is expected?
	$output = trim($out);
	$output = preg_replace('/\r\n/',"\n",$output);

	/* when using CGI, strip the headers from the output */
	if (isset($old_php) && ($pos = strpos($output, "\n\n")) !== FALSE) {
		$output = substr($output, ($pos + 2));
	}

	if (isset($section_text['EXPECTF']) || isset($section_text['EXPECTREGEX'])) {
		if (isset($section_text['EXPECTF'])) {
			$wanted = trim($section_text['EXPECTF']);
		} else {
			$wanted = trim($section_text['EXPECTREGEX']);
		}
		$wanted_re = preg_replace('/\r\n/',"\n",$wanted);
		if (isset($section_text['EXPECTF'])) {
			$wanted_re = preg_quote($wanted_re, '/');
			// Stick to basics
			$wanted_re = str_replace("%s", ".+?", $wanted_re); //not greedy
			$wanted_re = str_replace("%i", "[+\-]?[0-9]+", $wanted_re);
			$wanted_re = str_replace("%d", "[0-9]+", $wanted_re);
			$wanted_re = str_replace("%x", "[0-9a-fA-F]+", $wanted_re);
			$wanted_re = str_replace("%f", "[+\-]?\.?[0-9]+\.?[0-9]*(E-?[0-9]+)?", $wanted_re);
			$wanted_re = str_replace("%c", ".", $wanted_re);
			// %f allows two points "-.0.0" but that is the best *simple* expression
		}
/* DEBUG YOUR REGEX HERE
		var_dump($wanted_re);
		print(str_repeat('=', 80) . "\n");
		var_dump($output);
*/
		if (preg_match("/^$wanted_re\$/s", $output)) {
			@unlink($tmp_file);
			echo "PASS $tested$info\n";
			if (isset($old_php)) {
				$php = $old_php;
			}
			return 'PASSED';
		}

	} else {
		$wanted = trim($section_text['EXPECT']);
        $wanted = parseTestFileVars($wanted);
		$wanted = preg_replace('/\r\n/',"\n",$wanted);

	// compare and leave on success
		$ok = (0 == strcmp($output,$wanted));
		if (!empty($rtexpect)) {
            $ok = (0 == strcmp($rtout,$rtexpect));
        }
		if ($ok) {
			@unlink($tmp_file);
//             // If we were compiling a library, and the test
//             // passed, put the library files in a list to clean
//             // them up after all the tests are done
//             if (strpos($pccargs,'-l') !== FALSE) {
//                 $type = '_s';
//                 if (strpos($pccargs,'-O') !== FALSE || strpos($pccargs,'--static') !== FALSE) {
//                     $type = '_u';
//                 }
//                 $base = preg_replace( "/(.*?-l\s*)(.*?)(\s+.*|$)/", "\$2",$pccargs);
                
//                 $toDelete[] = "lib{$base}{$type}.a";
//                 $toDelete[] = "lib{$base}{$type}.so";
//                 $toDelete[] = "{$base}.heap";
//                 $toDelete[] = "{$base}.sch";
//             }
			echo "PASS $tested$info\n";
			if (isset($old_php)) {
				$php = $old_php;
			}
			return 'PASSED';
		}
	}

	// Test failed so we need to report details.
	if ($warn) {
		echo "WARN $tested$info\n";
	} else {
		echo "FAIL $tested$info\n";
	}

	$GLOBALS['__PHP_FAILED_TESTS__'][] = array(
						'name' => $file,
						'test_name' => $tested,
						'info'   => $info
						);

	// write .exp
	if (strpos($log_format,'E') !== FALSE) {
		$logname = ereg_replace('\.phpt$','.exp',$file);
		$log = fopen($logname,'w') or error("Cannot create test log - $logname");
		fwrite($log,$wanted);
		fclose($log);
		if (!empty($rtexpect)) {
		    $logname = ereg_replace('\.phpt$','.rtexp',$file);
		    $log = fopen($logname,'w') or error("Cannot create test log - $logname");
	    	fwrite($log,$rtexpect);
    		fclose($log);
		}
	}

	// write .out
	if (strpos($log_format,'O') !== FALSE) {
		$logname = ereg_replace('\.phpt$','.out',$file);
		$log = fopen($logname,'w') or error("Cannot create test log - $logname");
		fwrite($log,$output);
		fclose($log);
        if (!empty($rtout)) {
  	        $logname = ereg_replace('\.phpt$','.rtout',$file);
  	        $log = fopen($logname,'w') or error("Cannot create test log - $logname");
  	        fwrite($log,$rtout);
  	        fclose($log);
        }

	}

	if (isset($old_php)) {
		$php = $old_php;
	}

	return $warn ? 'WARNED' : 'FAILED';
}

function error($message)
{
	echo "ERROR: {$message}\n";
	exit(1);
}

function settings2array($settings, &$ini_settings)
{
	foreach($settings as $setting) {
		if (strpos($setting, '=')!==false) {
			$setting = explode("=", $setting, 2);
			$name = trim(strtolower($setting[0]));
			$value = trim($setting[1]);
			$ini_settings[$name] = $value;
		}
	}
}

function settings2params(&$ini_settings)
{
	if (count($ini_settings)) {
		$settings = '';
		foreach($ini_settings as $name => $value) {
			$value = addslashes($value);
			$settings .= " -d \"$name=$value\"";
		}
		$ini_settings = $settings;
	} else {
		$ini_settings = '';
	}
}

/**
 * Function to replace defined keys with
 * specified values.
 *
 * @param $string
 * @return string
 **/
function parseTestFileVars($string) {
    global $testFileVars;
    foreach ($testFileVars as $key => $val) {
        $string = preg_replace("/$key/", $val, $string);
    }
    return $string;
}
?>

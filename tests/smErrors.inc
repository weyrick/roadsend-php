<?php

/**
 *  Roadsend SiteManager
 *******************************************************************
 *  Copyright (c) 2001,2002 Roadsend, Inc.(http://www.roadsend.com)
 *******************************************************************
 *
 * This source file is subject to version 1.0 of the Roadsend Public
 * License, that is bundled with this package in the file 
 * LICENSE, and is available through the world wide web at 
 * http://www.roadsend.com/license/rpl1.txt
 *
 *******************************************************************
 * Author(s): Shannon Weyrick (weyrick@roadsend.com)
 *
 * @package roadsend_siteManager
 */
/** 
 *  override the PHP error handler
 */
set_error_handler("SM_errorHandler");

/**
 * submit a message to the debug log. it will only show up when viewing
 * debug output
 *
 * @param string $msg message to log
 * @param SM_errorHandler $obj the caller object. specify to display which object called
 *                                 the debug function
 * @param int $verbosity verbosity of this message, for filtering out unwanted debug messages later
 */
function SM_debugLog($msg, $obj=NULL, $verbosity=0) {

    global $SM_debugOutput;

    if (is_object($obj))
        $msg = get_class($obj).":: ".$msg;
    else
        $msg = "$msg";

    $SM_debugOutput[] = array('msg'=>$msg,'verbosity'=>$verbosity);

}

/** 
 *  a fatal error has occured. last ditch effort to output an error message.
 *
 *  @param string $msg error message to display 
 *  @param object $obj the caller object. specify to display which object called the error routine
 *  
 */
function SM_fatalErrorPage($msg='', $obj=NULL) {
    
    global $SM_outputBuffer;

    SM_debugLog("<font color=\"red\">$msg</font>",$obj);

    $SM_outputBuffer = ob_get_contents();
    ob_end_clean();

    echo SM_makeErrorPage();
    exit;
    
}

/**
 * create the HTML for the error page
 * doesn't echo anything, it returns it's output
 * @return string complete HTML page output
 */
function SM_makeErrorPage() {

    global $SM_siteName, $SM_siteID, $PHP_SELF, $SM_debugOutput, $SM_outputBuffer, $SM_noticeLog, $SM_siteManager, $SM_debugLevel;
    
    if ($SM_siteName == '')
        $SM_siteName = 'UNKNOWN SITENAME';
    
    if ($SM_siteID == '')
        $SM_siteID = 'UNKNOWN SITEID';
    
    $output = "<html><body bgcolor=ffffff><br /><b><font color=\"red\">\n";
    $output .= "$SM_siteName ($SM_siteID) :: $PHP_SELF<br /></font><hr />\n";

    if (!empty($SM_noticeLog)) {

        if (isset($SM_siteManager) && ($SM_siteManager->siteConfig->getVar('debug','showNotices'))) {        

            $output .= "<b>NOTICE LOG:</b><br />\n";
            foreach ($SM_noticeLog as $line) {
                $output .= "$line<br />\n";
            }

        }
    }

    if (is_array($SM_debugOutput)) {
        foreach ($SM_debugOutput as $log) {
            if ($log['verbosity'] > $SM_debugLevel)
                continue;
            ($log['verbosity'] > 0) ? $v = '['.$log['verbosity'].']' : $v = '';
            $output .= "$v {$log['msg']}<br />\n";
        }
    }

    if (trim($SM_outputBuffer) != '') {
        $output .= "Output Buffer:<br /><pre>".$SM_outputBuffer."</pre>\n";
    }

    //$output .= "<hr /><b>Roadsend SiteManager v".SM_VERSION." (<a href=\"http://www.roadsend.com/siteManager\">http://www.roadsend.com/siteManager</a>) (PHP v".PHP_VERSION.'/'.PHP_OS.')';
    $output .= "</b><br /></body></html>";

    return $output;

}

/**
 * this debug function will dump all variables that were
 * passed to the script, including GET, POST and cookies
 * will traverse arrays
 */
function SM_dumpVars() {
    
    while (list($key, $val) = each ($_REQUEST)) {
        if (!is_array($val))
            echo "$key => $val<br />";
        else {
            echo "$key (array):<br />";
            foreach($val as $k => $v) {
                echo " ..... $k -> $v<br />";
            }
        }
    }

}   


/**
*  override PHP's main error handler function
*  this should NOT be called directly
*/
 
function SM_errorHandler($errno, $errstr, $errfile, $errline) {

    global $SM_noticeLog;

    switch ($errno) {
    case E_PARSE:
    case E_USER_ERROR:
    case E_COMPILE_ERROR:
    case E_CORE_ERROR:
    case E_ERROR:
        $msg = "<b>FATAL</b> [$errno] $errstr<br />\n";
        $msg .= "  Fatal error in line $errline of file ".$errfile;
        $msg .= ", SiteManager ".SM_VERSION.", PHP ".PHP_VERSION." (".PHP_OS.")<br />\n";
        SM_fatalErrorPage($msg);
        break;
    case E_USER_WARNING:
    case E_COMPILE_WARNING:
    case E_CORE_WARNING:
    case E_WARNING:
        $msg = "<b>SiteManager PHP WARNING:</b> $errstr on line $errline in $errfile<br />\n";
        SM_debugLog($msg);
        break;
    case E_NOTICE:
    case E_USER_NOTICE:
        $SM_noticeLog[] = '<b>SiteManager PHP NOTICE:</b> '.$errstr." on line $errline in $errfile\n";
        break;
    default:
        SM_fatalErrorPage("Unkown error type: [$errno] $errstr on line $errline in $errfile<br />\n");
        break;
    }

}


?>

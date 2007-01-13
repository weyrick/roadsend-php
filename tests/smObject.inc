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
 */


/**
 * base siteManager object. used to give siteManager objects common
 * configuration, database, and session functionality
 * @author Shannon Weyrick <weyrick@roadsend.com>
 * @package roadsend_siteManager
 */
class SM_object {
    
    /**
    * a list of class logged items 
    * @var array
    */
    var $classLog = array();

    /** 
    * configuration directive hash 
    * @var array
    */
    var $directive = array();

    /** 
    * current session handler 
    * @var SM_session
    */
    var $sessionH = NULL;

    /** 
    * current default database handler 
    * @var PEAR::DB
    */
    var $dbH = NULL;

    /** 
    * current hash of database handlers 
    * @var array
    */
    var $dbHL = NULL;

    /** 
    * current inVar manager 
    * @var SM_inVarManager
    */
    var $inVarH = NULL;

    /** 
    * reference to the current Global siteConfig 
    * @var SM_siteConfig
    */
    var $siteConfig = NULL;

    /** 
    * current site error handler 
    * @var SM_errorHandler
    */
    var $errorHandler = NULL;

    /** 
    * language independent text hash 
    * @var array
    */
    var $liText = array();

    /** 
    * whether to override or append directives in loadConfig 
    * @var bool
    */
    var $owD = true;

    /** 
    * our SMOBJECT config reader 
    * @var SM_configReader_SMOBJECT
    */
    var $cObjectReader = NULL;

    /** 
    * our SMLANGUAGE config reader 
    * @var SM_configReader_SMLANGUAGE
    */
    var $cLanguageReader = NULL;

    /**
     * SiteManager Object Configure. This should be called once upon the creation
     * of a class extending SM_object. It will configure the object within the
     * current SiteManager site.
     */
    function _smoConfigure() {

        global $SM_siteManager;

        // setup variables to reference SM_siteManager object
        $this->dbH          =& $SM_siteManager->dbH;
        $this->dbHL         =& $SM_siteManager->dbHL;
        $this->sessionH     =& $SM_siteManager->sessionH;
        $this->siteConfig   =& $SM_siteManager->siteConfig;
        $this->inVarH       =& $SM_siteManager->inVarH;
        $this->errorHandler =& $SM_siteManager->errorHandler;

    }

    /**
     * PHP magic function run when this object is serialized
     */
    function __sleep() {

        // don't store SiteManager handlers
        unset($this->dbH);
        unset($this->dbLH);
        unset($this->sessionH);
        unset($this->siteconfig);
        unset($this->inVarH);
        unset($this->errorHandler);

    }

    /**
     * PHP magic function run when this object is unserialized
     */
    function __wakeup() {

        // reinit handlers
        $this->_smoConfigure();

    }

    /**
     * call fatalErrorPage from current error handler
     * @param string $msg message to display
     */
    function fatalErrorPage($msg='unknown fatal error') {
        if (isset($this->errorHandler)) {
            $this->errorHandler->fatalErrorPage($msg, $this);
        }
        else {
            SM_fatalErrorPage($msg, $this);
        }
    }

    /**
     * call debugLog from current error handler
     * @param string $msg message to display
     * @param string $verbosity level of verbosity this message is assigned to (higher=more verbose)
     */
    function debugLog($msg, $verbosity=0) {
      //        if (isset($this->errorHandler)) {
	  //            $this->errorHandler->debugLog($msg, $this, $verbosity);
      //        }
      //        else {
            SM_debugLog($msg, $this, $verbosity);
	    //        }
        // add to class log
        $this->classLog[] = $msg;
    }

    /**
     * call dbErrorCheck from error handler
     * @param result handle $rh result handle to check
     */
    function dbErrorCheck($rh, $fatal=true) {
        if (isset($this->errorHandler)) {
            return $this->errorHandler->dbErrorCheck($rh, $this, $fatal);
        }
        else {
	  return TRUE; //SM_dbErrorCheck($rh, $this, $fatal);
        }
    }

     /**
      * this function configures the object. it accepts an associative array of 
      * configuration directive in key/value pair format
      * @param array $cDir a key/value pair list of directive for this object
      */
    function configure($cDir) {
        if (is_array($cDir)) {
            foreach ($cDir as $k=>$v)
                $this->directive[$k] = $v;
        }
    }

     /**
      * Add a single key/value directive for configuration
      * @param string $key the key to use
      * @param array $val the value to assign it
      * @param bool $overWrite when set to false, if the key is already present, 
      *                           the new value will be an array of the old values(s)
      *                           and the new one (instead of overwriting). defaults
      *                           to true.
      */
    function addDirective($key, $val='', $overWrite=true) {
        if ((!$overWrite)&&(isset($this->directive[$key]))) {
            if (is_array($this->directive[$key])) {
                $this->directive[$key][] = $val;
            }
            else {
                $this->directive[$key] = array($this->directive[$key], $val);
            }
        }
        else {        
            // new value
            $this->directive[$key] = $val;
        }
    }   


    /**
     * retrieve the current value of a directive
     * @param string $key key to lookup
     * @return mixed value of the directive, or NULL if not set
     */
    function getDirective($key) {
        if (isset($this->directive[$key])) {
            return $this->directive[$key];
        }
        else {
            return NULL;
        }
    }

    /**
     * dump values of directive variable
     */
    function dumpDirectives() {

        global $_dOp;

        $_dOp = '';
        $_dOp = get_class($this)." :: directive list<br /><br />\n";
        $_dOp .= "<ul>";
        array_walk($this->directive, '_ddPrint');
        $_dOp .= "</ul><br />";

        return $_dOp;

    }

    /**
     * dump object information. should be overriden by subclass for
     * anything more than just displaying the class log
     */
    function dumpInfo() {

        // should be overridden
        if (is_array($this->classLog)) {
            return $this->getClassLog();
        }
        else {
            return get_class($this).':: no information';
        }

    }


    /** 
     * retrieve the class log as a block of formatted text
     *
     */
    function getClassLog() {
        if (isset($this->classLog))        
            return "CLASS LOG:<br />".join('<br />',$this->classLog).'<br /><br />';
    }

    
    /**
     * retrieve some language independent text by ID
     * @param string $id the id to use to retrieve the text
     * @param string $locale the locale to use. defaults to directive['defaultLocale'] or GCS defaultLocale
     */
    function getText($id, $locale='') {

        global $SM_clientLocale;

        // try to decide which locale to use
        if ($locale == '') {        

            if (($this->siteConfig->getVar('localization','useClientLocale'))&& 
                (isset($SM_clientLocale))) {
                // use locale specified by browser. might be array
                $locale = $SM_clientLocale;

            }
            elseif (!empty($this->directive['defaultLocale']))
                $locale = $this->directive['defaultLocale'];
            else {               
                $locale = $GLOBALS['SM_defaultLocale'];
            }
        }

        // if after all that, we still don't have a locale, default to us, english
        if (($locale == '')||( (is_array($locale))&&(sizeof($locale) == 0)  )) {
            $locale = 'en_US';
        }

        // loop through $locale if it's an array, return first value found
        if (is_array($locale)) {
            $lSearch = '';
            foreach ($locale as $l) {
                // force proper format
                if (strlen($l) > 2) {
                    if ($l{2} == '-') {
                        $l{2} = '_';
                    }
                    list($lang, $country) = split('_',$l,2);
                    $l = strtolower($lang).'_'.strtoupper($country);
                }
                $lSearch .= $l.',';
                if (isset($this->liText[$l][$id]))
                    return $this->liText[$l][$id];
            }
            // no text found for this locale..
            return "(translation unavailable for your language: $lSearch)";
        }
        else {
            // force proper format
            if (strlen($locale) > 2) {
                if ($locale{2} == '-') {
                    $locale{2} = '_';
                }
                list($lang, $country) = split('_',$locale,2);
                $locale = strtolower($lang).'_'.strtoupper($country);
            }
            if (isset($this->liText[$locale][$id])) {
                return $this->liText[$locale][$id];
            }
            else {
                return "(translation unavailable for your language: $locale)";
            }
        }

    }

    /**
    * load the SMOBJECT section of an XSM XML file
    * This currently loads and sets directives for this object
    * @param string $configFile the xml file to load
    * @param bool $fatalFNF if true, execution will stop if the file is not found
    * @param bool $overWrite if true, values loaded will overwrite current directives
    *                          loaded from the XML file. if false, it will keep values and
    *                          make an array where keys are non-unique
    */
        
    function loadConfig($configFile,$fatalFNF = true, $overWrite = true){

        global $SM_siteManager;

        // overwrite directive
        $this->owD = $overWrite;

        // find and load config file
        if (($configFile = $SM_siteManager->findSMfile($configFile, 'config', 'xsm', $fatalFNF)) == '')
            return;

        // check cache?
        $willCache = false;
        if ($this->siteConfig->getGlobalVar('cache','cacheSMObject')) {

            $willCache = true;
            if ($this->loadSerial($configFile, 'SMOBJECT', $this->directive))
                return;

        }

        // fall through: get config
//         // if we dont have a reader yet, make it
//         if ($this->cObjectReader == NULL) {
//             $this->cObjectReader =& SM_loadConfigReader('SMOBJECT', $this);
//         }
        
//         // read in config, setting my properties at the same time
//         // overwrite directives?
//         $this->cObjectReader->addDirective('owD',$this->owD);
//         $this->cObjectReader->readConfigXML($configFile);

//         // should we cache the file?
//         if ($willCache) {
//             $this->saveSerial($configFile, 'SMOBJECT', $this->directive);
//         }

    }


    /**
     * load an SMLANGUAGE XML language file
     * @param string $lFile the file to read in     
     * @param bool $fatalFNF if true, execution will stop if the file is not found
     */
    function loadLanguage($langFile, $fatalFNF = true) {
    
        global $SM_siteManager;

        // find and load config file
        if (($langFile = $SM_siteManager->findSMfile($langFile, 'locale', 'xsm', $fatalFNF)) == '')
            return false;

        // check cache?
        $willCache = false;
        if ($this->siteConfig->getGlobalVar('cache','cacheSMLanguage')) {

            $willCache = true;
            if ($this->loadSerial($langFile, 'SMLANGUAGE', $this->liText))
                return true;

        }

        // fall through: get config
//         // if we dont have a reader yet, make it
//         if ($this->cLanguageReader == NULL) {
//             $this->cLanguageReader =& SM_loadConfigReader('SMLANGUAGE', $this);
//         }
        
//         // read in config, setting my properties at the same time
//         $this->cLanguageReader->readConfigXML($langFile);

//         // should we cache the file?
//         if ($willCache) {
//             $this->saveSerial($langFile, 'SMLANGUAGE', $this->liText);
//         }
    
        return true;

    }


    /**
     * cache an object currently in serialized PHP data format
     * @param string $file the file to write to
     * @param string $prefix a string to prefix the cache file name with
     * @param mixed $data the object to cache
     * @return bool true on successful cache, false otherwise
     */
    function saveSerial($file, $prefix, &$data) {

        global $SM_siteID;

        // must specify file. will strip directory later
        if ($file == '') {        
            $this->debugLog("saveSerial - file to cache was blank");
            return false;        
        }

        // use cache system?
        if (!$this->siteConfig->getGlobalVar('cache','useCache')) {        
            return false;
        }

        // create file name
        $cacheDir = $this->siteConfig->getGlobalVar('dirs','cache');        
        $goodFN = preg_replace('/\W/','_',$file);        
        $file = $cacheDir.$SM_siteID.'-'.$prefix.'-'.$goodFN.'.inc';

        // only save if the file doesn't exist
        if (file_exists($file))
            return false;

        $fp = fopen($file,'w');
        if (!$fp) {
            $this->debugLog("saveSerial: couldn't open cache file for output [$file] - check permissions");
            return false;
        }

        // serialize
        $ct = serialize($data);

        fwrite($fp, $ct);
        fclose($fp);

        // nobody should read it but webserver
        chmod($file,0600);

        if ($GLOBALS['SM_develState'])        
            $this->debugLog("saveSerial: created cache file $file");

        return true;

    }

    /**
     * read in a serialized object, assign value to $data
     * @param string $file the file to read in and unseralize     
     * @param string $prefix a string to prefix the cache file name with
     * @param mixed $data store results of unserialized data in this variable
     */
    
     function loadSerial($file, $prefix, &$data) {

        global $SM_siteID;

        // use cache system?
        if (!$this->siteConfig->getGlobalVar('cache','useCache')) {        
            return;
        }

        // make file name
        $cacheDir = $this->siteConfig->getGlobalVar('dirs','cache');
        $goodFN = preg_replace('/\W/','_',$file);        
        $file = $cacheDir.$SM_siteID.'-'.$prefix.'-'.$goodFN.'.inc';

        if (!file_exists($file)) {        
            $this->debugLog("loadSerial: file not found [$file]");
            return false;
        }
        $fp = fopen($file,'r');
        $ct = fread($fp, filesize($file));
        fclose($fp);

        $data = unserialize($ct);

        if ($GLOBALS['SM_develState'])        
            $this->debugLog("loadSerial: loaded cached file $file");

        return true;

    }

}

?>

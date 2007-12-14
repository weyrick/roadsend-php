<?php

/**
 *
 * This file has been modified to implement a PDO layer for Roadsend PHP
 * It is used and released under the terms of the GPL license as specified
 * below.
 *
 */

/**
 * This file contains the main classes used to emulate PDO functionality.
 * 
 * Provides limited PDO and PDOStatement class implementations for PHP 4 (and 
 * 5.x platforms without the PECL PDO extensions installed or without the 
 * required drivers configured). The classes are named with a trailing
 * underscore to allow them to work even if native PDO extensions are installed
 * but the drivers you need may not be available or configured properly.
 * 
 * The OpenExpedio PDO emulation was originally inspired by {@link 
 * http://www.phpclasses.org/browse/package/2572.html PDO for PHP 4} by Andrew 
 * Giammarchi.
 * 
 * @author Jason Coward <xpdo@opengeek.com>
 * @copyright Copyright (C) 2006-2007, Jason Coward
 * @license http://opensource.org/licenses/gpl-license.php GNU Public License
 * @see PHP_MANUAL#pdo
 * @package xpdo.pdo
 */

/**
 * A PHP emulation of the PHP Data Objects (PDO) extension compatible with PHP 4.
 * 
 * The PHP Data Objects (PDO) extension defines a lightweight, consistent
 * interface for accessing databases in PHP. Each database driver that
 * implements the PDO interface can expose database-specific features as regular
 * extension functions. Note that you cannot perform any database functions
 * using the PDO extension by itself; you must use a database-specific PDO
 * driver to access a database server.  See the {@link PHP_MANUAL#pdo official 
 * PDO documentation} for more detailed information on PDO and how it
 * is used.
 * 
 * This limited PDO implementation is provided by OpenExpedio (xPDO) to allow
 * compatibility with PHP 4.3+, or any later version where native PDO or a
 * required native PDO driver is not available.
 * 
 * @package xpdo.pdo
 * @todo Implement additional driver support; currently only supports MySQL,
 * PostgreSQL, and SQLite
 */
class PDO {
    var $_driver;
    var $_dbtype= null;

    /**
     * Returns a list of available database drivers.
     * 
     * @static
     * @return array All drivers available to any PDO instance.
     * @todo Implement this as a dynamic list of available drivers.
     */
    function getAvailableDrivers() {
        return array (
            'mysql',
//            'pgsql',
            'sqlite'
        );
    }

    /**#@+
     * Creates a PDO instance representing a connection to a database.
     * 
     * @see PHP_MANUAL#pdo-construct
     * @uses PDO_::__construct() For PHP 4 compatibility.
     * @uses xPDO::parseDSN()
     * @param string $dsn The Data Source Name, or DSN, contains the information
     * required to connect to the database.
     * @param string $username The user name for the DSN string. This parameter
     * is optional for some PDO drivers.
     * @param string $password The password for the DSN string. This parameter
     * is optional for some PDO drivers.
     * @param array $driver_options A key=>value array of driver-specific
     * connection options.
     * @return PDO_ A valid PDO instance if successful; error is raised
     * otherwise.
     * 
     * @todo Test sqlite and pgsql drivers.
     * @todo Add charset support for sqlite and pgsql drivers.
     * @todo Implement additional drivers.
     */
    function PDO($dsn, $username= '', $password= '', $driver_options= null) {
        $this->__construct($dsn, $username, $password, $driver_options);
    }
    /** @ignore */
    function __construct($dsn, $username= '', $password= '', $driver_options= null) {
        $con= xPDO :: parseDSN($dsn);
        $driverClass= XPDO_CORE_PATH . 'pdo.' . $con['dbtype'] . '.inc.php';
        include_once (XPDO_CORE_PATH . 'pdo.' . $con['dbtype'] . '.inc.php');
        $this->_dbtype= $con['dbtype'];
        if ($con['dbtype'] === 'mysql') {
            if (isset ($con['port']))
                $con['host'] .= ':' . $con['port'];
            if ($this->_driver= new PDO_mysql($con['host'], $con['dbname'], $username, $password)) {
                if (isset ($con['charset']) && !empty($con['charset'])) {
                    $this->_driver->exec("SET CHARACTER SET " . $con['charset']);
                }
            }
        }
        elseif ($con['dbtype'] === 'sqlite2' || $con['dbtype'] === 'sqlite') {
            $this->_driver= new PDO_sqlite($con['dbname']);
        }
        /*
        elseif ($con['dbtype'] === 'pgsql') {
            $dsn= 'host=' . $con['host'] . ' dbname=' . $con['dbname'] . ' user=' . $username . ' password=' . $password;
            if (isset ($con['port']))
                $dsn .= ' port=' . $con['port'];
            $this->_driver= new PDO_pgsql($dsn);
        }
        */
    }
    /**#@-*/

    /**
    * Parses a DSN and returns an array of the connection details.
    *
    * @param string $string The DSN to parse.
    * @return array An array of connection details from the DSN.
    * @todo Have this method handle all methods of DSN specification as handled
    * by latest native PDO implementation.
    */
    function parseDSN($string) {
        $result= array ();
        $pos= strpos($string, ':');
        $parameters= explode(';', substr($string, ($pos +1)));
        $result['dbtype']= strtolower(substr($string, 0, $pos));
        for ($a= 0, $b= count($parameters); $a < $b; $a++) {
            $tmp= explode('=', $parameters[$a]);
            if (count($tmp) == 2) {
                $result[$tmp[0]]= $tmp[1];
            } else {
                $result['dbname']= $parameters[$a];
            }
        }
        return $result;
    }
    
    /** 
     * @see PHP_MANUAL#pdo-begintransaction
     */
    function beginTransaction() {
        $this->_driver->beginTransaction();
    }

    /** 
     * @see PHP_MANUAL#pdo-commit
     */
    function commit() {
        $this->_driver->commit();
    }

    /** 
     * @see PHP_MANUAL#pdo-exec
     */
    function exec($query) {
        return $this->_driver->exec($query);
    }

    /** 
     * @see PHP_MANUAL#pdo-errorcode
     */
    function errorCode() {
        return $this->_driver->errorCode();
    }

    /** 
     * @see PHP_MANUAL#pdo-errorinfo
     */
    function errorInfo() {
        return $this->_driver->errorInfo();
    }

    /** 
     * @see PHP_MANUAL#pdo-getattribute
     */
    function getAttribute($attribute) {
        return $this->_driver->getAttribute($attribute);
    }

    /** 
     * @see PHP_MANUAL#pdo-lastinsertid
     */
    function lastInsertId() {
        return $this->_driver->lastInsertId();
    }

    /** 
     * @see PHP_MANUAL#pdo-prepare
     */
    function prepare($statement, $driver_options= array ()) {
        return $this->_driver->prepare($statement, $driver_options= array ());
    }

    /** 
     * @see PHP_MANUAL#pdo-query
     */
    function query($query) {
        return $this->_driver->query($query);
    }

    /** 
     * @see PHP_MANUAL#pdo-quote
     */
    function quote($string, $parameter_type= PDO_PARAM_STR) {
        return $this->_driver->quote($string, $parameter_type);
    }

    /** 
     * @see PHP_MANUAL#pdo-rollback
     */
    function rollBack() {
        $this->_driver->rollBack();
    }

    /** 
     * @see PHP_MANUAL#pdo-setattribute
     */
    function setAttribute($attribute, $value) {
        return $this->_driver->setAttribute($attribute, $value);
    }
}

/**
 * Represents a PDO prepared statement.
 * 
 * @author Jason Coward <xpdo@opengeek.com>
 * @copyright Copyright (C) 2006-2007, Jason Coward
 * @license http://opensource.org/licenses/gpl-license.php GNU Public License
 * @package xpdo.pdo
 */
class PDOStatement {
    /**
     * @var string The SQL query string for the statement to use.
     */
    var $queryString= '';

    var $_connection;
    var $_dbinfo;
    var $_persistent= false;
    var $_result= null;
    var $_fetchmode= PDO_FETCH_BOTH;
    var $_errorCode= '';
    var $_errorInfo= array (
        PDO_ERR_NONE
    );
    var $_boundParams= array ();
    
    /**#@+
     * A PDOStatement is created by calling PDO::prepare() and similar methods.
     * 
     * @access private
     * @param string $queryString A SQL query string.
     * @param resource &$connection A valid database connection resource handle.
     * @param array $dbinfo Meta information about the connection and driver.
     * @return PDOStatement_
     */
    function PDOStatement($queryString, & $connection, & $dbinfo) {
        $this->__construct($queryString, $connection, $dbinfo);
    }
    /** @ignore */
    function __construct($queryString, & $connection, & $dbinfo) {
        $this->queryString= $queryString;
        $this->_connection= & $connection;
        $this->_dbinfo= & $dbinfo;
    }
    /**#@-*/

    function bindParam($param, & $variable, $data_type= PDO_PARAM_STR, $length= 0, $driver_options= null) {
        $this->_boundParams[$param]['value']= $variable;
        $this->_boundParams[$param]['type']= $data_type;
        $this->_boundParams[$param]['length']= intval($length);
    }

    function bindValue($param, $value, $data_type= PDO_PARAM_STR) {
        $this->_boundParams[$param]['value']= $value;
        $this->_boundParams[$param]['type']= $data_type;
        $this->_boundParams[$param]['length']= 0;
    }

    function errorCode() {
        return $this->_errorCode;
    }

    function errorInfo() {
        return $this->_errorInfo;
    }

    function execute($input_parameters= null) {
        $array= & $this->_boundParams;
        if (is_array($input_parameters) && !empty ($input_parameters)) {
            $array= $input_parameters;
        }
        $queryString= $this->queryString;
        if (count($array) > 0) {
            reset($array);
            while (list ($k, $param)= each($array)) {
                $v= $param['value'];
                $type= $param['type'];
                if (!$v) {
                    switch ($type) {
                    	case PDO_PARAM_INT:
                    		$v= '0';
                    		break;
                    	case PDO_PARAM_BOOL:
                    		$v= '0';
                    		break;
                    	default:
                    		break;
                    }
                }
                if (!is_int($k) || substr($k, 0, 1) === ':') {
                    if (!isset ($tempf)) {
                        $tempf= $tempr= array ();
                    }
                    $pattern= '/' . $k . '\b/';
                    array_push($tempf, $pattern);
                    $v= $this->quote($v, $type);
                    array_push($tempr, $v);
                } else {
                    $parse= create_function('$d,$v,$t', 'return $d->quote($v, $t);');
                    $queryString= preg_replace("/(\?)/e", '$parse($this,$array[$k][\'value\'],$type);', $queryString, 1);
                }
            }
            if (isset ($tempf)) {
                $queryString= preg_replace($tempf, $tempr, $queryString);
            }
        }
        if (is_null($this->_result= $this->_uquery($queryString))) {
            $keyvars= false;
        } else {
            $keyvars= true;
        }
        return $keyvars;
    }

    function setFetchMode($mode) {
        $result= false;
        if ($mode= intval($mode)) {
            switch ($mode) {
                case PDO_FETCH_NUM :
                case PDO_FETCH_ASSOC :
                case PDO_FETCH_OBJ :
                case PDO_FETCH_BOTH :
                default:
                    $result= true;
                    $this->_fetchmode= $mode;
                    break;
            }
        }
        return $result;
    }

    function closeCursor() {
        do {
           while ($this->fetch()) {}
           if (!$this->nextRowset())
               break;
        } while (true);
    }

    function bindColumn($column, & $param, $type= null, $max_length= null, $driver_option= null) { return false; }

    function columnCount() { return false; }

    function getAttribute($attribute) { return false; }

    function getColumnMeta($column) { return false; }

    function fetch($mode= PDO_FETCH_BOTH, $cursor= null, $offset= null) { return false; }

    function fetchAll($mode= PDO_FETCH_BOTH, $column_index= 0) { return false; }

    function fetchColumn($column_number= 0) { return false; }

    function fetchObject($class_name= '', $ctor_args= null) { return false; }
    
    function nextRowset() { return false; }

    function quote($string, $parameter_type= PDO_PARAM_STR) { return false; }
    
    function rowCount() { return false; }

    function setAttribute($attribute, $value) { return false; }
    
    function debugDumpParams() { return false; }

    function _setErrors($er) { return false; }

    function _uquery(& $query) { return false; }
}

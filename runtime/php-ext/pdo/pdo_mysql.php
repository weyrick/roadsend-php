<?php

/**
 *
 * This file has been modified to implement a PDO layer for Roadsend PHP
 * It is used and released under the terms of the GPL license as specified
 * below.
 *
 */


/**
 * MySQL PDO emulation.
 * 
 * Contains the classes required to support MySQL PDO when native PDO is not
 * available to the platform.
 * 
 * The OpenExpedio PDO emulation was originally inspired by {@link 
 * http://www.phpclasses.org/browse/package/2572.html PDO for PHP 4} by Andrew 
 * Giammarchi.
 * 
 * @author Jason Coward <xpdo@opengeek.com>
 * @copyright Copyright (C) 2006-2007, Jason Coward
 * @license http://opensource.org/licenses/gpl-license.php GNU Public License
 * @package xpdo.pdo
 */

/**
 * A MySQL PDO implementation using the PHP mysql extension.
 * 
 * @package xpdo.pdo
 */
pcc_builtin class PDO_mysql {
    
    protected $connection;
    protected $dbinfo;
    protected $persistent= false;
    protected $autocommit = '0';
    protected $errorCode= PDO::ERR_NONE;
    protected $errorInfo= array (
        PDO::ERR_NONE
    );

    /**
     * Implements PDO driver emulation for MySQL.
     *
     * @access private
     * @param string $host
     * @param string &$db
     * @param string &$user
     * @param string &$pass
     * @return PDO_mysql
     */
    public function __construct($host, $db, $user, $pass) {
        if (!$this->connection= @ mysql_connect($host, $user, $pass, true)) {
            $this->setErrors('DBCON');
        } else {
            if (!@ mysql_select_db($db, $this->connection)) {
                $this->setErrors('DBER');
                $this->connection= null;
            } else {
                $this->dbinfo= array (
                    $host,
                    $user,
                    $pass,
                    $db
                );
            }
        }
    }

    public function errorCode() {
        return $this->errorCode;
    }

    public function errorInfo() {
        return $this->errorInfo;
    }

    public function exec($query) {
        $result= 0;
        if (!is_null($this->uquery($query)))
            $result= mysql_affected_rows($this->connection);
        if (is_null($result))
            $result= false;
        return $result;
    }

    public function lastInsertId() {
        return mysql_insert_id($this->connection);
    }

    public function prepare($statement, $driver_options= array ()) {
        return new PDOStatement_mysql($statement, $this->connection, $this->dbinfo);
    }

    public function query($statement) {
        $args= func_get_args();
        $result= false;
        if ($stmt= new PDOStatement_mysql($statement, $this->connection, $this->dbinfo)) {
            if (count($args) > 1) {
                $stmt->setFetchMode($args[1]);
            }
            $stmt->execute();
            $result= $stmt;
        }
        return $result;
    }

    public function quote($string, $parameter_type= PDO::PARAM_STR) {
        $string= mysql_real_escape_string($string, $this->connection);
        switch ($parameter_type) {
        	case PDO::PARAM_NULL:
                break;
        	case PDO::PARAM_INT:
        		break;
        	default:
                $string= "'" . $string . "'";
        }
        return $string;
    }

    public function getAttribute($attribute) {
        $result= false;
        switch ($attribute) {
            case PDO::ATTR_SERVER_INFO :
                $result= mysql_get_host_info($this->connection);
                break;
            case PDO::ATTR_SERVER_VERSION :
                $result= mysql_get_server_info($this->connection);
                break;
            case PDO::ATTR_CLIENT_VERSION :
                $result= mysql_get_client_info();
                break;
            case PDO::ATTR_PERSISTENT :
                $result= $this->persistent;
                break;
            case PDO::ATTR_DRIVER_NAME :
                $result= 'mysql';
                break;
            case PDO::ATTR_AUTOCOMMIT:
                $result = (bool)$this->autocommit;
                break;
        }
        return $result;
    }

    public function setAttribute($attribute, $value) {
        $result= false;
        if ($attribute === PDO::ATTR_PERSISTENT && $value != $this->persistent) {
            $result= true;
            $this->persistent= (boolean) $value;
            mysql_close($this->connection);
            if ($this->persistent === true) {
                $this->connection= mysql_pconnect($this->dbinfo[0], $this->dbinfo[1], $this->dbinfo[2]);
            }
            else {
                $this->connection= mysql_connect($this->dbinfo[0], $this->dbinfo[1], $this->dbinfo[2]);
            }
            mysql_select_db($this->dbinfo[3], $this->connection);
        }
        if ($attribute === PDO::ATTR_AUTOCOMMIT) {
            $this->autocommit = ($value ? '1' : '0');
            $this->exec("SET AUTOCOMMIT=".$this->autocommit);
        }
        return $result;
    }

    public function beginTransaction() {
        return $this->exec('BEGIN');
    }

    public function commit() {
        return $this->exec('COMMIT');
    }

    public function rollBack() {
        return $this->exec('ROLLBACK');
    }

    protected function setErrors($er) {
        if (!is_resource($this->connection)) {
            $errno= mysql_errno();
            $errst= mysql_error();
        } else {
            $errno= mysql_errno($this->connection);
            $errst= mysql_error($this->connection);
        }
        $this->errorCode = $er;
        $this->errorInfo= array (
            $this->errorCode,
            $errno,
            $errst
        );
    }

    protected function uquery($query) {
        if (!$query= @ mysql_query($query, $this->connection)) {
            $this->setErrors('SQLER');
            $query= null;
        }
        return $query;
    }
}

/**
 * A MySQL PDOStatement class compatible with PHP 4.
 * 
 * @package xpdo.pdo
 */
pcc_builtin class PDOStatement_mysql extends PDOStatement {
    
    public function __construct($queryString, $connection, $dbinfo) {
        parent::__construct($queryString, $connection, $dbinfo);
    }

    public function columnCount() {
        $result= 0;
        if (!is_null($this->result))
            $result= mysql_num_fields($this->result);
        return $result;
    }

    public function fetch($mode= PDO::FETCH_BOTH, $cursor= null, $offset= null) {
        if (func_num_args() == 0)
            $mode=$this->fetchmode;
        $result= false;
        if (!is_null($this->result)) {
            switch ($mode) {
                case PDO::FETCH_NUM :
                    $result= @ mysql_fetch_row($this->result);
                    break;
                case PDO::FETCH_ASSOC :
                    $result= @ mysql_fetch_assoc($this->result);
                    break;
                case PDO::FETCH_OBJ :
                    $result= @ mysql_fetch_object($this->result);
                    break;
                case PDO::FETCH_BOTH :
                default :
                    $result= @ mysql_fetch_array($this->result);
                    break;
            }
        }
        if (!$result)
            $this->result= null;
        return $result;
    }

    public function fetchAll($mode= PDO::FETCH_BOTH, $column_index= 0) {
        if (func_num_args() == 0)
            $mode= $this->fetchmode;
        $result= array ();
        if (!is_null($this->result)) {
            switch ($mode) {
                case PDO::FETCH_NUM :
                    while ($r= @ mysql_fetch_row($this->result))
                        array_push($result, $r);
                    break;
                case PDO::FETCH_ASSOC :
                    while ($r= @ mysql_fetch_assoc($this->result))
                        array_push($result, $r);
                    break;
                case PDO::FETCH_OBJ :
                    while ($r= @ mysql_fetch_object($this->result))
                        array_push($result, $r);
                    break;
                case PDO::FETCH_COLUMN :
                    while ($r= @ mysql_fetch_row($this->result))
                        array_push($result, $r[$column_index]);
                    break;
                case PDO::FETCH_BOTH :
                default :
                    while ($r= @ mysql_fetch_array($this->result))
                        array_push($result, $r);
                    break;
            }
        }
        $this->result= null;
        return $result;
    }

    public function fetchColumn($column_number= 0) {
        $result= false;
        if (!is_null($this->result)) {
            $result= @ mysql_fetch_row($this->result);
            if ($result)
                $result= $result[$column_number];
            else
                $this->result= false;
        }
        return $result;
    }

    public function getAttribute($attribute) {
        $result= false;
        switch ($attribute) {
            case PDO::ATTR_SERVER_INFO :
                $result= mysql_get_host_info($this->connection);
                break;
            case PDO::ATTR_SERVER_VERSION :
                $result= mysql_get_server_info($this->connection);
                break;
            case PDO::ATTR_CLIENT_VERSION :
                $result= mysql_get_client_info();
                break;
            case PDO::ATTR_PERSISTENT :
                $result= $this->persistent;
                break;
            case PDO::ATTR_DRIVER_NAME :
                $result= '';
                break;
        }
        return $result;
    }

    public function quote($string, $parameter_type= PDO::PARAM_STR) {
        $string= mysql_real_escape_string($string, $this->connection);
        switch ($parameter_type) {
            case PDO::PARAM_NULL:
                break;
            case PDO::PARAM_INT:
                break;
            default:
                $string= "'" . $string . "'";
        }
        return $string;
    }

    public function rowCount() {
        return mysql_affected_rows($this->connection);
    }

    public function setAttribute($attribute, $value) {
        $result= false;
        if ($attribute === PDO::ATTR_PERSISTENT && $value != $this->persistent) {
            $result= true;
            $this->persistent= (boolean) $value;
            mysql_close($this->connection);
            if ($this->persistent === true) {
                $this->connection= mysql_pconnect($this->dbinfo[0], $this->dbinfo[1], $this->dbinfo[2]);
            }
            else {
                $this->connection= mysql_connect($this->dbinfo[0], $this->dbinfo[1], $this->dbinfo[2]);
            }
            mysql_select_db($this->dbinfo[3], $this->connection);
        }
        return $result;
    }

    protected function uquery($query) {
        if (!@ $query= mysql_query($query, $this->connection)) {
            $this->setErrors('SQLER');
            $query= null;
        }
        return $query;
    }

    protected function setErrors($er) {
        if (!is_resource($this->connection)) {
            $errno= mysql_errno();
            $errst= mysql_error();
        } else {
            $errno= mysql_errno($this->connection);
            $errst= mysql_error($this->connection);
        }
        $this->errorCode= $er;
        $this->errorInfo= array (
            $this->errorCode,
            $errno,
            $errst
        );
        $this->result= null;
    }
}

?>
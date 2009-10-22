<?php

function __autoload($class){
    if ($class != "FOO")
        throw new Exception( "wrong class name!" );
    class FOO{
        static public function success(){
            echo "success";
        }
    }
}

FOO::success();

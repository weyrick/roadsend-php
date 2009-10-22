<?php

function __autoload($class){
    if ($class != "FOO")
        throw new Exception( "wrong class name!" );
    class FOO{
        public function success(){
            echo "success";
        }
    }
}

$c = new FOO();
$c->success();

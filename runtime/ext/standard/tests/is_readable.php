<?php

echo "cwd: " . getcwd();

echo "this should be readable: " . 
        (is_readable($PHP_SELF) ? "and it is." : "but it's not!");

echo "\n";
echo "this should not be readable: " . 
        (is_readable($PHP_SELF . "bork") ? "but it is!" : "and it's not.");

echo "\n";
?>
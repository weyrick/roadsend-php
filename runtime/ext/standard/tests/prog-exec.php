<?php


echo "system 1: ".system('ls /etc/');
echo "system 2: ".system('ls /etc/', $ret);
echo "return: $ret\n";
echo "system 3: ".system('ls /this-does-not-exist/', $ret);
echo "return: $ret\n";

echo "passthru 1: ".passthru('ls /etc/', $ret);
echo "return: $ret\n";

echo "exec ---> ".exec('ls /etc/')."<-----\n";
echo exec('ls /etc/', $output);
var_dump($output);
$output = array('testing123');
echo exec('ls /etc/', $output);
var_dump($output);
echo exec('ls /etc/', $output, $ret);
var_dump($output);
echo "return: $ret\n";

unset($output);
echo exec('fnord', $output, $ret);
var_dump($output);
echo "exec return: $ret\n";

echo system('fnord', $r);
var_dump($r);

echo escapeshellarg("%\"''/\\b'la''h\''")."\n";

$cmd = '$this" {}\'!@#$%^&*(){}[]<>/\n\n\t;;`\\ffabcdefghijklmnopqrstuvwxyz';
echo escapeshellcmd($cmd)."\n";


?>

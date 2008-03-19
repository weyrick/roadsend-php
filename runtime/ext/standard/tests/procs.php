<?php
$descriptorspec = array(
   0 => array("pipe", "r"),  // stdin is a pipe that the child will read from
   1 => array("pipe", "w"),  // stdout is a pipe that the child will write to
   //   2 => array("file", "/tmp/error-output.txt", "a") // stderr is a file to write to
);

$cwd = '/tmp';
$env = array('some_option' => 'aeiou');

$process = proc_open('sh', $descriptorspec, $pipes);//, $cwd, $env);
//var_dump($process);
if (is_resource($process)) {

    //    var_dump(proc_get_status($process));

    // $pipes now looks like this:
    // 0 => writeable handle connected to child stdin
    // 1 => readable handle connected to child stdout
    // Any error output will be appended to /tmp/error-output.txt
    echo "fwrite: ".fwrite($pipes[0], "ls\n")."\n";
    echo "fclose: ".fclose($pipes[0])."\n";

    //echo stream_get_contents($pipes[1]);
    while(!feof($pipes[1])) {
        $line = fgets($pipes[1]);
        echo $line;
    }
    fclose($pipes[1]);

    // It is important that you close any pipes before calling
    // proc_close in order to avoid a deadlock
    $return_value = proc_close($process);

    echo "command returned $return_value\n";
}
?> 

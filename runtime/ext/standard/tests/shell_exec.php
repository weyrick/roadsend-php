<?php

if (substr(PHP_OS, 0, 3) == 'WIN') {
    print shell_exec("dir c:\\");
    echo `dir "c:\\program files\\"`."\n";
}
else {
    $SysVer = `ver`;
    print $SysVer;
        
    print shell_exec("echo wibble wibble wibble");
    print shell_exec("ls /");
}

?>

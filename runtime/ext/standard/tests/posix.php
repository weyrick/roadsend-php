<?php
// tests for the posix extension

$pid = posix_getpid();
if ($pid > 0)
   echo "posix_getpid succeeded\n";
else
   echo "posix_getpid failed\n";

$ppid = posix_getppid();
if ($ppid > 0)
   echo "posix_getppid succeeded\n";
else
   echo "posix_getppid failed\n";

$uid = posix_getuid();
echo "uid=$uid\n";

$euid = posix_geteuid();
echo "euid=$euid\n";

$gid = posix_getgid();
echo "gid=$gid\n";

$egid = posix_getegid();
echo "egid=$egid\n";

posix_setuid(1004);
$uid = posix_getuid();
echo "uid=$uid\n";

posix_seteuid(1004);
$euid = posix_geteuid();
echo "euid=$euid\n";

posix_setgid(1004);
$gid = posix_getgid();
echo "gid=$gid\n";

posix_setegid(1004);
$egid = posix_getegid();
echo "egid=$egid\n";

$groups = posix_getgroups();
echo "groups=\n";
print_r($groups);

$login = posix_getlogin();
echo "login=$login\n";

$pgrp = posix_getpgrp();
echo "pgrp=$pgrp\n";

$setsid = posix_setsid();
if ($setsid > 0)
   echo "posix_setsid succeeded\n";
else
   echo "posix_setsid failed\n";

$getpgid = posix_getpgid($pid);
if ($getpgid > 0)
   echo "posix_getpgid succeeded\n";
else
   echo "posix_getpgid failed\n";

$getsid = posix_getsid($pid);
if ($getsid > 0)
   echo "posix_getsid succeeded\n";
else
   echo "posix_getsid failed\n";

$setpgid = posix_setpgid($pid, $getpgid);
if ($setpgid > 0)
   echo "posix_setpgid succeeded\n";
else
   echo "posix_setpgid failed\n";

$uname = posix_uname();
echo "uname=\n";
print_r($uname);

$times = posix_times();
foreach ($times as $k => $v)
   if ($v < 0)
      echo "times[$k] is negative\n";
   else
      echo "times[$k] is greater than or equal to 0\n";

$ctermid = posix_ctermid();
echo "ctermid=$ctermid\n";

$ttyname = posix_ttyname(1);
echo "ttyname for fd 1 = $ttyname\n";

$isatty = posix_isatty(1);
echo "isatty for fd 1 = $isatty\n";

$cwd = posix_getcwd();
if (file_exists($cwd))
   echo "posix_getcwd succeeded\n";
else
   echo "posix_getcwd failed\n";

// make sure the file we use for testing ain't there already
$testfile = "/tmp/phpoo_test_fifo204982";
if (file_exists($testfile))
   unlink($testfile);

$mkfifo = posix_mkfifo($testfile, 0);
echo "mkfifo=$mkfifo\n";

// clean up test file without assuming we actually succeeded in creating it
if (file_exists($testfile))
   unlink($testfile);	

$getgrnam = posix_getgrnam("floppy");
echo "getgrnam for floppy =\n";
var_dump($getgrnam);

$getgrgid = posix_getgrgid(25); // 25 is group floppy
echo "getgrgid for group 25 =\n";
var_dump($getgrgid);

$getpwnam = posix_getpwnam("ftp");
echo "getpwnam for user ftp =\n";
var_dump($getpwnam);

$getpwuid = posix_getpwuid(106); // 106 is user ftp
echo "getpwuid for userid 106 =\n";
var_dump($getpwuid);

$getrlimit = posix_getrlimit();
echo "getrlimit=\n";
foreach ($getrlimit as $k => $v)
   if (! ($k === "soft stack"))
      echo "fstat[$k] = $v\n";
   else
      if ($v < 0)
         echo "fstat[$k] is negative\n";
      else
         echo "fstat[$k] is greater than or equal to 0\n";

// test errno stuff
$retval = posix_kill(-1, -1);
$errno = posix_get_last_error();
$errstr = posix_strerror($errno);
echo "posix_kill(-1, -1) returned $retval\n";
echo "posix_get_last_error($retval) returned $errno\n";
echo "posix_strerror($errno) returned $errstr\n";

?>

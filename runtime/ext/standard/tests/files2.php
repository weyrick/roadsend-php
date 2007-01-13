<?php
error_reporting(E_ALL);

function necho ($line_number, $string) {
  echo "$line_number: $string\n";
  return $string;
}

function first_digit($number) {
  return substr($number, 0, 1);
}

if (PHP_OS == 'WINNT') {
    $testfile = "testfile";
} 
else {
    $testfile = "./this-is-a-file-for-testing-the-compiler";
} 

// basename
$path = "/home/httpd/html/index.php";
necho(10, basename($path));          // should print "index.php"
necho(20, basename($path, ".php"));  // should print "index"
necho(30, basename($path, "x.php")); // should print "inde"
necho(40, basename($path, ".PHP"));  // should print "index.php"

// chmod, chgrp, touch, file_exists, unlink, filegroup
necho(50, touch($testfile));
necho(60, file_exists($testfile));
clearstatcache();
necho(90, fileperms($testfile));
necho(100, filegroup($testfile));
if (PHP_OS != 'WINNT') {
  clearstatcache();
  necho(70, fileperms($testfile));
  necho(80, chmod($testfile, 0422));
  clearstatcache();
  necho(110, chgrp($testfile, "cdrom"));
  clearstatcache();
  necho(120, filegroup($testfile));
  necho(130, fileowner($testfile));
  necho(140, chown($testfile, "nobody"));
  clearstatcache();
  necho(150, fileowner($testfile));
}
necho(160, unlink($testfile));
necho(170, file_exists($testfile));

// fileatime, filectime, filegroup, fileinode, filemtime, fileowner
// fileperms filesize, filetype
clearstatcache();
necho(180, first_digit(fileatime("/usr/include/stdio.h")));
necho(190, first_digit(filectime("/usr/include/stdio.h")));
necho(200, filegroup("/usr/include/stdio.h"));
necho(210, fileinode("/usr/include/stdio.h"));
necho(220, first_digit(filemtime("/usr/include/stdio.h")));
necho(230, fileowner("/usr/include/stdio.h"));
necho(240, fileperms("/usr/include/stdio.h"));
necho(250, filesize("/usr/include/stdio.h"));
necho(260, filetype("/usr/include/stdio.h"));

// file
if (PHP_OS != 'WINNT') {
necho(270, 'file("/etc/passed"):');
print_r(file("/etc/passwd"));
}
else {
necho(270, 'file("c:/windows/system.ini"):');
print_r(file("c:/windows/system.ini"));
}
echo "\n";

// dirname
if (PHP_OS != 'WINNT') {
necho(280, dirname("/etc/passwd"));
necho(290, dirname("/usr/local/lib/foo/local/lib/bar/foo.h"));
}
else {
necho(280, dirname("c:/"));
necho(281, dirname("/etc/passwd"));
necho(290, dirname("c:\\"));
necho(291, dirname("c:\\foobar\\"));
necho(292, dirname("c:/foobar/"));
necho(293, dirname("/mnt/c/foo"));
}

// disk_free_space, diskfreespace
if (PHP_OS != 'WINNT') {
necho(300, first_digit(disk_free_space("/etc")));
necho(310, first_digit(diskfreespace("/etc")));

// disk_total_space
necho(320, first_digit(disk_total_space("/tmp")));
}

// fgetcsv
$row = 1;
$handle = fopen("/etc/passwd","r");
while ($data = fgetcsv ($handle, 1000, ":")) {
    $num = count($data);
    necho(330, "$num fields in line $row:");
    $row++;
    for ($c=0; $c < $num; $c++) {
        necho(340, $data[$c]);
    }
}
fclose($handle);

// fgets
$handle = fopen("/etc/passwd", "r");
echo "350: ";
while ($handle && !feof ($handle)) {
 fgets($handle, 4096);
}
fclose($handle);

// fnmatch (disabled because my test version of php doesn't have it --tpd 4/5/2005)
//$color = "foogrey";
//necho(360, fnmatch("*gr[ae]y", "foogrey"));
//necho(361, fnmatch("*[rw][er][ai][dt]*able", "readable"));
//necho(362, fnmatch("*[rw][er][ai][dt]*able", "writable"));
//necho(363, fnmatch("*[rw][er][ai][dt]*able", "writeable"));

// is_dir
necho(370, is_dir("/proc"));
necho(380, is_dir("./this_file_should_probably_not_exist"));
necho(390, is_dir("/etc/group"));

// is_executable (disabled because my test version of php doesn't have it --tpd 4/7/2005)
//necho(400, is_executable("/etc/group"));
//necho(410, is_executable("/bin/ls"));

// is_file
necho(420, is_file("/proc"));
necho(430, is_file("./this_file_should_probably_not_exist"));
necho(440, is_file("/etc/group"));

// touch, is_writeable, is_writable, is_readable, unlink
necho(450, touch($testfile));
necho(460, is_writeable($testfile));
necho(470, is_writable($testfile));
necho(480, is_readable($testfile));
necho(490, is_readable("/etc/passwd"));
necho(500, is_writeable("/etc/passwd"));
necho(510, is_writable("/etc/passwd"));
necho(520, unlink($testfile));

// link, tempnam, file_exists, unlink
necho(530, touch($testfile));
$link_name = tempnam("/tmp", "cowboy1");
necho(540, file_exists($link_name));
necho(550, unlink($link_name));
clearstatcache();

if (PHP_OS != 'WINNT') {
necho(560, link($testfile, $link_name));
necho(570, is_link($link_name));
}

necho(580, unlink($link_name));

// popen, pclose, fread
$handle = popen("/bin/ls /etc", "r");
necho(590, fread($handle, 2096)	);
necho(600, pclose($handle));

$handle = popen('/path/to/spooge 2>&1', 'r');
necho(610, fread($handle, 2096));
// this fails because the process was unable to be opened properly in the first place,
// but we return different error number, so I don't print it
pclose($handle);

// readfile
necho(620, 'readfile("/etc/motd"):');
readfile("/etc/motd");
echo "\n";
necho(630, 'readfile("./this_file_should_probably_not_exist"):');
readfile("./this_file_should_probably_not_exist");

// realpath, symlink, unlink
if (PHP_OS != 'WINNT') {
necho(640, realpath("/etc/alternatives/telnet"));
necho(645, realpath("/etc/passwd")); 
necho(650, symlink("/proc", "./proc"));
necho(660, realpath("/etc/../proc/.././proc"));
} 
else {
necho(640, realpath("c:\\Windows\\SyStEm.ini"));
necho(645, realpath("C:\\windOws\none")); 
necho(650, realpath("c:\\wiNdows\\undeploy.exe"));
necho(655, realpath("c:\\wIndoWs\\Help\\..\\system.INI"));
}
necho(670, unlink("./proc"));

// touch, file_exists, rename, copy, unlink
$newname = $testfile . "with-a-new-name";
necho(680, touch($testfile));
necho(690, file_exists($testfile));
necho(700, rename($testfile, $newname));
clearstatcache();
necho(710, file_exists($testfile));
necho(720, file_exists($newname));
necho(730, copy($newname, $testfile));
necho(740, file_exists($testfile));
necho(750, file_exists($newname));
necho(760, unlink($testfile));
necho(770, unlink($newname));
necho(780, file_exists($testfile));
necho(790, file_exists($newname));

// mkdir, fileperms, is_dir, rmdir
$tmpdir = "./a-temporary-directory-to-test-the-compiler";
necho(800, mkdir($tmpdir));
clearstatcache();
necho(810, fileperms($tmpdir));
necho(820, is_dir($tmpdir));
necho(830, rmdir($tmpdir));
clearstatcache(); 
// Zend caches this and says that the directory is still there unless
// we clear the stat cache!!
necho(840, is_dir($tmpdir));

// fstat
$handle = fopen("/usr/include/stdio.h", "r");
$fstat =  necho(850, fstat($handle));
foreach ($fstat as $k => $v)	
  if (($k != 8) && (! ($k === "atime")))	
    necho(860, "fstat[$k] = $v, type is: " . gettype($v));
  else
    necho(860, "(first digit of) fstat[$k] = " . first_digit($v) .", type is: " . gettype($v));
necho(870, fclose($handle));

// stat
$stat =  stat("/usr/include/stdio.h");
foreach ($stat as $k => $v)	
  if (($k != 8) && (! ($k === "atime")))	
    necho(880, "stat[$k] = $v, type is: " . gettype($v));
  else
    necho(880, "(first digit of) stat[$k] = " . first_digit($v) .", type is: " . gettype($v));

// touch, symlink, is_link, unlink, tempnam
necho(890, touch($testfile));
$symlink_name = tempnam("/tmp", "cowboy2");
necho(900, file_exists($symlink_name));
necho(910, unlink($symlink_name));
clearstatcache();
if (PHP_OS != 'WINNT') {
necho(920, symlink($testfile, $symlink_name));
necho(930, file_exists($symlink_name));
necho(940, is_link($symlink_name));
necho(950, unlink($symlink_name));
}

// tempnam
$tmpfname = tempnam("/tmp", "cowboy3");
$handle = fopen($tmpfname, "w");
necho(960, fwrite($handle, "writing to tempfile"));
necho(970, fclose($handle));
necho(980, unlink($tmpfname));

// umask
necho(990,  umask());
necho(1000, umask(0755));
necho(1010, umask("foo"));
necho(1020, umask());

// touch, unlink
necho(1030, touch($testfile));
necho(1040, file_exists($testfile));
necho(1050, unlink($testfile));
necho(1060, file_exists($testfile));

if (PHP_OS == 'WINNT') {

echo "1: ".is_dir("c:\\windows")."\n";
echo "1a: ".is_dir("c:\\windows\\")."\n";
echo "1b: ".is_dir("c:/windows/")."\n";
echo "1c: ".is_dir("c:/windows")."\n";
echo "2: ".file_exists("./files2.php")."\n";
echo "3: ".file_exists("./foobar.php")."\n";
echo "4: ".is_file("./foobar2")."\n";
echo "5: ".is_file("./foobar")."\n";
echo "5a: ".is_readable("./foobar")."\n";
echo "6: ".touch("./foobar3")."\n";
echo "7: ".unlink("./foobar3")."\n";

}

?>
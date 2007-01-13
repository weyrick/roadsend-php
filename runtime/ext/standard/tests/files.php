<?php

error_reporting(0);

function first_digit($number) {
  return substr($number, 0, 1);
}

$testfile = 'file-test.txt';

$string = "this is some text

blah.. lazy blue fox jumps over satirical dog
lorum crapsum dipsum jumpsum

#!@$231hcjhco
blah";

$fp = fopen($testfile, "wb");
echo "trunc fwrite: ".fwrite($fp, $string, strlen($string)-3)."\n";
echo "trunc fputs: ".fputs($fp, $string, strlen($string)-3)."\n";
echo fclose($fp);
echo "[".fclose($fp)."]";
$test = fclose($fp);
echo "<$test>\n";

echo "file_exists: ".file_exists("file-test.txt")."\n";

echo "filesize: ".filesize($testfile)."\n";

echo "fgets: ";
$handle = fopen ($testfile, 'r');
while (!feof ($handle)) {
    $buffer = fgets($handle, 7);
    echo "<$buffer>";
}
fclose ($handle);

echo "fgets2: ";
$handle = fopen ($testfile, 'r');
while (!feof ($handle)) {
    $buffer = fgets($handle);
    echo "--<$buffer>--";
}
fclose ($handle);

echo "fgetc1: ";
$handle = fopen ($testfile, 'r');
while (!feof ($handle)) {
    $buffer = fgetc($handle);
    echo "<$buffer>";
}
fclose ($handle);

echo "fgetc2: ";
$handle = fopen ($testfile, 'r');
while (!feof ($handle)) {
    $buffer = fgetc($handle);
    echo "--<$buffer>--";
}
fclose ($handle);

echo "fread + len: ";
$handle = fopen ($testfile, 'r');
while ($data = fread($handle, 5)) {
    print "got [$data]\n";
}
fclose($handle);

// get contents of a file into a string
echo "fread: ";
$handle = fopen ($testfile, "r");
$contents = fread ($handle, filesize ($testfile));
fclose ($handle);

echo "(".$contents.")\n";

// append to file
$fp = fopen($testfile, 'a');
echo "append fputs: ".fputs($fp, "appended-text-blahblah")."\n";
fclose($fp);

// get file contents
$newc = file_get_contents($testfile);
echo "new contents: ($newc)\n";

// remove file
unlink($testfile);


// basename
$f = '/var/www/test/man/mack/the/knife/myfile.txt';
echo basename($f)."\n";

// is_*
echo "{";
echo is_dir('/tmp/');
echo is_dir('/doesntexist/');
echo "}\n";

// file*time
echo "{";
echo first_digit(filemtime('/etc/passwd'));
echo "}\n";

$a = getcwd();
chdir("/usr/include");
$here = getcwd();
echo "in: $here\n";
chdir("/tmp");
echo "now in ".getcwd()."\n";
chdir($here);
echo "back in in: ".getcwd()."\n";
chdir($a);

$a = pathinfo("/home/php/some/directory/filename.ext");
var_dump($a);

if (file_exists("/etc/")) {
    // directory class, unix
    $d = dir("/etc/");
    //echo "Handle: " . $d->handle . "<br />\n";
    echo "Path: " . $d->path . "<br />\n";
    while (false !== ($entry = $d->read())) {
        echo $entry."<br />\n";
    }
    $d->close();
} else {
    // directory class, windows
    $d = dir("c:/msys/1.0/etc/");
    //echo "Handle: " . $d->handle . "<br />\n";
    echo "Path: " . $d->path . "<br />\n";
    while (false !== ($entry = $d->read())) {
   echo $entry."<br />\n";
    }
    $d->close();
}


?>

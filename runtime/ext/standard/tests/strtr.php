<?

echo strtr(1,2,3)."\n";
echo strtr('hello','ello','3770')."\n";
echo strtr('hello','ello','377')."\n";
echo strtr('hello','ell','37770')."\n";

$trans = array("hello" => "bye", "hi" => "greetings");
echo strtr("hi all, I said hello", $trans)."\n";

$trans = array("hello" => "hi", "hi" => "hello");
echo strtr("hi all, I said hello", $trans)."\n";

$trans = array("hello" => "bye", "hi" => "greetings");
$trans1 = array("hello" => "hi", "hi" => "hello");

// test performance at the same time
for ($i=0; $i<10000; $i++) {
 strtr(1,2,3)."\n";
 strtr('hello','ello','3770')."\n";
 strtr('hello','ello','377')."\n";
 strtr('hello','ell','37770')."\n";


 strtr("hi all, I said hello", $trans)."\n";


 strtr("hi all, I said hello", $trans1)."\n";
}


?>
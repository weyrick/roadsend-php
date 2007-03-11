<?php

$string1 = "dolphin-flogger";

echo strlen($string1)."\n";

$mix = "xAnDu-LaMbAsTIc\n";
echo strtoupper($mix);
echo strtolower($mix);

$caps = "this is a test of the caps function\n";
echo ucwords($caps);
echo ucfirst($caps);

echo chr(40);
echo ord('c');

echo strrev("Hello World!");

echo str_repeat("-=-", 20);

$var1 = "Hello";
$var2 = "hello";
if (strcasecmp($var1, $var2) == 0) {
    echo "$var1 is equal to $var2 in a case-insensitive string comparison";
}
echo strcasecmp("Z", "AAA");
echo strcasecmp("Z", "A"); 

echo strncasecmp("thiS BE a TeST", "THis be a TEST", 5);

/*
// works but fails test
echo "uniqid 1: ".uniqid('testing123')."\n";
echo "uniqid 2: ".uniqid()."\n";
*/

echo strnatcmp("img1.png","img10.png");
echo strnatcmp("img10.png","img1.png");
echo strnatcmp("img202.png","img20.png");
echo strnatcasecmp("iMG1.png","img10.png");
echo strnatcasecmp("imG10.png","IMg1.png");
echo strnatcasecmp("ImG202.png","Img20.png");


echo "\nbase64_encode: [".base64_encode('this is an encoding string. zot!')."]\n";
echo "\nbase64_encode: [".base64_encode('this is an encoding string. zot! and a little bit more this time')."]\n";
echo "\nbase64_encode: [".base64_encode('this is an encoding string. zot! cha cha now yall!!')."]\n";

echo "\nbase64_decode: [".base64_decode(base64_encode('this is an encoding string. zot!'))."]\n";
echo "\nbase64_decode: [".base64_decode(base64_encode('this is an encoding string. zot! and a little bit more this time'))."]\n";
echo "\nbase64_decode: [".base64_decode(base64_encode('this is an encoding string. zot! cha cha now yall!!'))."]\n";

echo quoted_printable_decode("hi=20this=20is=20a=20test")."\n";

echo quotemeta('hey.\\\\\\\'!@#$%()[]{}/.,<>;:"\|')."\n";

echo str_rot13('01234567890abcdefghijklmnopqrstuvwxyz,./;[]\-=');

print substr_count("This is a test", "is")."\n";
print substr_count("cgcgcgcgcgcgcgcgcgcgcgc", "cgc")."\n";
print substr_count("is IS iS Is", "is")."\n";

echo "1: ". strspn("42 is the answer, what is the question ...", "1234567890") ."\n";

echo "2: ". strcmp("tEsT","tEsT") ."\n";
echo "3: ". strcmp("tEsT","test") ."\n";
echo "4: ". strcmp("blah","tEsT") ."\n";
echo "5: ". strncmp("meepMopeBlah","me",2) ."\n";

echo "6: ". strcoll("tEsT","test") ."\n";
echo "7: ". strcoll("blah","tEsT") ."\n";

// wtf does this do?
echo strcspn("dzg", 'abcdefg')."\n";

// get last directory in $PATH
echo substr(strrchr(getenv('PATH'), ":"), 1)."\n";

// get everything after last newline
echo "strrchr stuff\n";
$text = "Line 1\nLine 2\nLine 3";
echo substr(strrchr($text, 10), 1 )."\n";


echo strrpos('test.php','.');
echo strrpos('test.php.test','.');
// php5
//echo strripos('test.php.test','p');
//echo strripos('test.php.test','P');

$a = parse_url("http://username:password@hostname/path?arg=value#anchor");
var_dump($a);

$a = parse_url("http://username@hostname/path#anchor");
var_dump($a);

$a = parse_url("http://hostname/path?arg=value");
var_dump($a);

$a = parse_url("http://hostname/path");
var_dump($a);

$str = 'abcdefghijklmnopqrstuvwxyz';
// passes but different results
//echo str_shuffle($str)."\n";


$var = 'ABCDEFGH:/MNRPQR/';
echo "Original: $var<hr />\n";

/* These two examples replace all of $var with 'bob'. */
echo substr_replace($var, 'bob', 0) . "<br />\n";
echo substr_replace($var, 'bob', 0, strlen($var)) . "<br />\n";

/* Insert 'bob' right at the beginning of $var. */
echo substr_replace($var, 'bob', 0, 0) . "<br />\n";

/* These next two replace 'MNRPQR' in $var with 'bob'. */
echo substr_replace($var, 'bob', 10, -1) . "<br />\n";
echo substr_replace($var, 'bob', -7, -1) . "<br />\n";

/* Delete 'MNRPQR' from $var. */
echo substr_replace($var, '', 10, -1) . "<br />\n";

// test the failed replacement case:
var_dump(substr_replace('bork', '', 10, -1));

$data = "Two Ts and one F.";

$result = count_chars($data, 0);
var_dump($result);

$result = count_chars($data, 1);
var_dump($result);

$result = count_chars($data, 2);
var_dump($result);

$result = count_chars($data, 3);
var_dump($result);

$result = count_chars($data, 4);
var_dump($result);


?>

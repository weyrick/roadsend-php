<?php

function exercise_trims($string, $chars)
{
  echo trim($string); echo ltrim($string); echo rtrim($string); echo chop($string); echo "\n\n";
  echo trim($string, $chars); echo ltrim($string, $chars); echo rtrim($string, $chars); echo chop($string, $chars); echo "\n\n";
  echo trim($string, ''); echo ltrim($string, ''); echo rtrim($string, ''); echo chop($string, ''); echo "\n\n";

  echo "\n\n";

    echo $string.$strings; echo $string.$strings; echo $string.$strings; echo $string.$strings; echo "\n\n";
  echo $string.trim($chars).$strings; echo $string.ltrim($chars).$strings; echo $string.rtrim($chars).$strings; echo $string.chop($chars).$strings; echo "\n\n";
  echo $string.trim('').$strings; echo $string.ltrim('').$strings; echo $string.rtrim('').$strings; echo $string.chop('').$strings; echo "\n\n";

  echo "\n\n";
}

$strings=array(
	       " \t\t\nthis is a test of the trim \r\n  ",
	       "  \t \n -+-this is another test-+- \n",
	       'werijfsojc',
	       ' \\0\\t\\nABC \\0\\t\\n',
	       "cb.AAAb.c",
	       "c.fdefSAAAAAS.cdeff",
	       "hijklabyz.AAAAAA.hijkl",
	       "hij..klabyz.AAAAAA.hijkl",
	       "hijklmnabyz.AAAAAA.hijklmn",
	       "hijklmnabyz.AAAAAA.hijk..lmn",
	       " \\0\\t\\nABC \\0\\t\\n",
	       "\n\0 \\0\\t\\nABC \\0\\t\\n",
	       "ABC\\x50\\xC1\\x60\\x90",
	       "\\x51..\\xC0",
	       );

$charses=array(
	       'abc',
	       'b..e',
	       'asvs \0e..s..d..r..e..a....;elkj',
	       "-+ \n\t",
	       "ccc..a",
	       "ccc..f",
	       "h..j..l",
	       "h..jj..l",
	       "h..j..l..n",
	       "\\x51..\\xC1",
	       "\\x50..\\xC1",
	       "\\x51..\\xC0",
	       "\\x51..\\xC1",
	       );

foreach ($strings as $i => $string) {
  foreach ($charses as $j => $chars) {
    exercise_trims($string, $chars); } }

echo "\n\n"; exercise_trims("ABC\\x50\\xC1\\x60\\x90", 'asvs \0e..s..d..r..e..a....;elkj'); echo "\n\n";

echo "\n\n"; exercise_trims("\\xC1", 'asvs \0e..s..d..r..e..a....;elkj'); echo "\n\n";

echo "\n\n"; exercise_trims("\\xC1", '....;'); echo "\n\n";

echo "\n\n"; exercise_trims("\\xC1", '....;'); echo "\n\n";

echo "\n\n"; echo rtrim("\\xC1", '....;'); echo "\n\n";
echo "\n\n"; echo rtrim("\\xC1", '.;'); echo "\n\n";
echo "\n\n"; echo rtrim("\xC1", '....;'); echo "\n\n";

?>

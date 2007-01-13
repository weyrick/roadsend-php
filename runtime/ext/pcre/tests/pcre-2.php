<?php


$s = 'laz/y brown cow jumps! over c0w the sly fox coww brown';

$num = preg_match_all("!(c[0o]w{1,2})\s(\w+)!", $s, $m);

echo preg_match_all('//', $s, $m);

echo "from $s there are $num matches:\n";
print_r($m);

print "set order\n";
$num = preg_match_all("!(c[0o]w{1,2})\s(\w+)!", $s, $m, PREG_SET_ORDER);
print "$num:\n";
print_r($m);

echo "pattern order + offset capture\n";
$num = preg_match_all("!(c[0o]w{1,2})\s(\w+)!", $s, $m, PREG_PATTERN_ORDER | PREG_OFFSET_CAPTURE);
print "$num:\n";
print_r($m);

echo "set order + offset capture\n";
$num = preg_match_all("!(c[0o]w{1,2})\s(\w+)!", $s, $m, PREG_SET_ORDER | PREG_OFFSET_CAPTURE);
print "$num:\n";
print_r($m);

echo "pattern order + offset capture (again)\n";
preg_match_all("/cow/", "cow cow cow monkey cow", $m, PREG_PATTERN_ORDER | PREG_OFFSET_CAPTURE);
print_r($m);

// from docs
$html = "<b>bold text</b><a href=howdy.html>click me</a>";

preg_match_all ("/(<([\w]+)[^>]*>)(.*)(<\/\\2>)/", $html, $matches);

for ($i=0; $i< count($matches[0]); $i++) {
  echo "matched: ".$matches[0][$i]."\n";
  echo "part 1: ".$matches[1][$i]."\n";
  echo "part 2: ".$matches[3][$i]."\n";
  echo "part 3: ".$matches[4][$i]."\n\n";
}

preg_match_all ("/\(?  (\d{3})?  \)?  (?(1)  [\-\s] ) \d{3}-\d{4}/x",
                "Call 555-1212 or 1-800-555-1212", $phones);

print_r($phones);

//preg_match_all("/\{FILE\s*\{([A-Za-z0-9\._]+?)\}\s*\}/m", '', $m);
preg_match_all("/(dd)/", '', $m);
print_r($m);

preg_match("/(dd)(ss)/", '', $m);
print_r($m);

?>
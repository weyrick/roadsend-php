<?php


echo  M_PI	. "\n";
echo  M_E	. "\n";
echo  M_LOG2E	. "\n";
echo  M_LOG10E	. "\n";
echo  M_LN2	. "\n";
echo  M_LN10	. "\n";
echo  M_PI_2	. "\n";
echo  M_PI_4	. "\n";
echo  M_1_PI	. "\n";
echo  M_2_PI	. "\n";

//later versions?
//echo  M_SQRTPI	. "\n";
//echo  M_SQRT3	. "\n";
//echo  M_LNPI	. "\n";
//echo  M_EULER	. "\n";


echo  M_2_SQRTPI . "\n";
echo  M_SQRT2	. "\n";
echo  M_SQRT1_2	. "\n";

echo "abs\n";
echo abs(-2354) . " " . abs("foo") . " " . abs(0) . " " . abs(5) . abs(1.2345) . "\n";

echo "acos\n";
echo acos(-2354) . " " . acos("foo") . " " . acos(0) . " " . acos(5) . acos(1.2345) . "\n";

if (PHP_OS != 'WINNT') {
echo "acosh\n";
echo acosh(-2354) . " " . acosh("foo") . " " . acosh(0) . " " . acosh(5) . acosh(1.2345) . "\n";
}

echo "asin\n";
echo asin(-2354) . " " . asin("foo") . " " . asin(0) . " " . asin(5) . asin(1.2345) . "\n";

if (PHP_OS != 'WINNT') {
echo "asinh\n";
echo asinh(-2354) . " " . asinh("foo") . " " . asinh(0) . " " . asinh(5) . asinh(1.2345) . "\n";
}

echo "atan\n";
echo atan(-2354) . " " . atan("foo") . " " . atan(0) . " " . atan(5) . atan(1.2345) . "\n";

if (PHP_OS != 'WINNT') {
echo "atanh\n";
echo atanh(-2354) . " " . atanh("foo") . " " . atanh(0) . " " . atanh(5) . atanh(1.2345) . "\n";
}

echo "atan2\n";
echo atan2(-2354, 3) . " " . atan2("foo", 12) . " " . atan2(0, 3) . " " . atan2(5, 2.3) . atan2(1.2345, 3.22) . "\n";

echo "base_convert\n";
echo base_convert("-2354", 10, 2) . " " . base_convert("foo", 10, 10) . " " . base_convert(300, 4, 20) . " " .  
base_convert(5, 6, 7) . " " . base_convert(5, 4, 7) . " " . base_convert(1.2345, 8, 2) . "\n";

echo "bindec\n";
echo bindec("-2354") . " " . bindec("foo") . " " . bindec(0) . " " . bindec(5) . bindec("1.2345") . "\n";

echo "ceil\n";
echo ceil(-2354) . " " . ceil("foo") . " " . ceil(0) . " " . ceil(5) . ceil(1.2345) . "\n";

echo "cos\n";
echo cos(-2354) . " " . cos("foo") . " " . cos(0) . " " . cos(5) . cos(1.2345) . "\n";

echo "cosh\n";
echo cosh(-2354) . " " . cosh("foo") . " " . cosh(0) . " " . cosh(5) . cosh(1.2345) . "\n";

echo "decbin\n";
echo decbin(2354) . " " . decbin("foo") . " " . decbin(0) . " " . decbin("5") . decbin(1.2345) . "\n";

echo "dechex\n";
echo dechex("2354") . " " . dechex("foo") . " " . dechex(0) . " " . dechex(5) . dechex(1.2345) . "\n";

echo "decoct\n";
echo decoct(2354) . " " . decoct("foo") . " " . decoct(0) . " " . decoct(5) . decoct(1.2345) . "\n";

echo "deg2rad\n";
echo deg2rad(-2354) . " " . deg2rad("foo") . " " . deg2rad(0) . " " . deg2rad(5) . deg2rad(1.2345) . "\n";

echo "exp\n";
echo exp(-2354) . " " . exp("foo") . " " . exp(0) . " " . exp(5) . exp(1.2345) . "\n";

if (PHP_OS != 'WINNT') {
echo "expm1\n";
echo expm1(-2354) . " " . expm1("foo") . " " . expm1(0) . " " . expm1(5) . expm1(1.2345) . "\n";
}

echo "floor\n";
echo floor(-2354) . " " . floor("foo") . " " . floor(0) . " " . floor(5) . floor(1.2345) . "\n";

// in windows, php has this at 32767 for no good reason
if (PHP_OS != 'WINNT') {

echo getrandmax()."\n";
if (100000 < getrandmax()) {
  echo "getrandmax: Well, that's a start.\n";
}
else {
    echo "woops, getrandmax: ".getrandmax()."\n";
}

} 

echo "hexdec\n";
echo hexdec("-2354") . " " . hexdec("foo") . " " . hexdec(0) . " " . hexdec(5) . hexdec("1.2345") . "\n";

if (PHP_OS != 'WINNT') {
echo "hypot\n";
echo hypot(-2354, 34) . " " . hypot("foo", 2) . " " . hypot(0, 0) . " " . hypot(5, 12) . hypot(1.2345, 2.3234) . "\n";
}

echo "log\n";
echo log(-2354) . " " . log("foo") . " " . log(0) . " " . log(5) . log(1.2345) . "\n";

echo "log10\n";
echo log10(-2354) . " " . log10("foo") . " " . log10(0) . " " . log10(5) . log10(1.2345) . "\n";

if (PHP_OS != 'WINNT') {
echo "log1p\n";
echo log1p(-2354) . " " . log1p("foo") . " " . log1p(0) . " " . log1p(5) . log1p(1.2345) . "\n";
}

echo "octdec\n";
echo octdec("-2354") . " " . octdec("foo") . " " . octdec(0) . " " . octdec(5) . octdec("1.2345") . "\n";

echo "pi\n";
echo pi() . "\n";

echo "pow\n";
echo pow(-2354, 4) . " " . pow("foo", 2) . " " . pow(0, 0) . " " . pow(5, 12) . pow(1.2345, 2.3234) . "\n";

echo "rad2deg\n";
echo rad2deg(-2354) . " " . rad2deg("foo") . " " . rad2deg(0) . " " . rad2deg(5) . rad2deg(1.2345) . "\n";

echo "rand\n";
for ($i=0; $i<1000; $i++) {
  $zot[rand(0, 2)] = "foo!\n";
}

sort($zot);
print_r($zot);

echo "round\n";
echo round(-2354) . " " . round("foo") . " " . round(0) . " " . round(5) . round(1.2345) . "\n";

echo "sin\n";
echo sin(-2354) . " " . sin("foo") . " " . sin(0) . " " . sin(5) . sin(1.2345) . "\n";

echo "sinh\n";
echo sinh(-2354) . " " . sinh("foo") . " " . sinh(0) . " " . sinh(5) . sinh(1.2345) . "\n";

echo "sqrt\n";
echo sqrt(-2354) . " " . sqrt("foo") . " " . sqrt(0) . " " . sqrt(5) . sqrt(1.2345) . "\n";

echo "srand\n";
srand(12);
echo "(no output)\n";

echo "tan\n";
echo tan(-2354) . " " . tan("foo") . " " . tan(0) . " " . tan(5) . tan(1.2345) . "\n";

echo "tanh\n";
echo tanh(-2354) . " " . tanh("foo") . " " . tanh(0) . " " . tanh(5) . tanh(1.2345) . "\n";

echo "is_finite\n";
if (is_finite(1)) {
  echo "works.";
}
if (is_finite(log(0))) {
  echo " broken";
}
if (is_finite(sqrt(-1))) {
  echo " brokener";
}
echo "\n";

echo "is_infinite\n";
if (is_infinite(1)) {
  echo "broken.";
}
if (is_infinite(log(0))) {
  echo " works";
}
if (is_infinite(sqrt(-1))) {
  echo " brokener";
}
echo "\n";

echo "is_nan\n";
if (is_nan(1)) {
  echo "broken.";
}
if (is_nan(log(0))) {
  echo " brokener";
}
if (is_nan(sqrt(-1))) {
  echo " works";
}
echo "\n";

// mt_srand -- Seed the better random number generator
mt_srand(101);

// mt_rand -- Generate a better random value
//for ($i=0; $i<1000; $i++) {
  echo "[".mt_rand(0, 10)."]\n";
//}

// mt_getrandmax -- Show largest possible random value
echo mt_getrandmax();

?>

;XXX not implemented yet:
;
; lcg_value -- Combined linear congruential generator




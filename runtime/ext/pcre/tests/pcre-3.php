<?php


echo preg_replace('/sandwhich/','burger',"Would you like fries with your sandwhich, and if so, which sandwhich?\n");

$subj = "9 - x - 22 - dd9dd\n";
echo "orig: $subj";
echo "new: ".preg_replace('!\d\d!','num', $subj);

// backrefs
echo preg_replace('/(foo)\s(bar)\s\s(baz)/', '$3 $2 $1', 'foo bar  baz');
echo "\n1\n";
echo preg_replace('/(foo)\s(bar)\s\s(baz)/', '\\3 \\2 \\1', 'foo bar  baz');
echo "\n2\n";
echo preg_replace('/(foo)\s(bar)\s\s(baz)/', '$3$2$1', 'foo bar  baz');
echo "\n3\n";
echo preg_replace('/(foo)\s(bar)\s\s(baz)/', "\$3 \$2 \$1", 'foo bar  baz');
echo "\n4\n";
echo preg_replace('/(foo)\s(bar)\s\s(baz)/', "\\3\${2} \${1} \\\\3 \\\\12 hi", 'foo bar  baz');
echo "\n5\n";

// limit
echo preg_replace('/boop/', 'teet', "boop boop boop teet teet boop\n", 3);

// subject is array
print_r(preg_replace('/boop/', 'test', array('test boop test', 'boop boop boop')));

// pattern array, shorter replacement array
print preg_replace(array('/meep/','/moop/'), array('blorp'), 'baz baz meep moop');

// pattern array, single replacement
print preg_replace(array('/foo/','/bar/'), 'zip', 'bar foo bar foo <-- all zips!');

// from docs

$string = "April 15, 2003";
$pattern = "/(\w+) (\d+), (\d+)/i";
$replacement = "\${1}1,\$3";
print preg_replace($pattern, $replacement, $string);

$string = "The quick brown fox jumped over the lazy dog.";

$patterns[0] = "/quick/";
$patterns[1] = "/brown/";
$patterns[2] = "/fox/";

$replacements[2] = "bear";
$replacements[1] = "black";
$replacements[0] = "slow";

print preg_replace($patterns, $replacements, $string);
/*
ksort($patterns);
ksort($replacements);

print preg_replace($patterns, $replacements, $string);
*/

$patterns = array ("/(19|20)(\d{2})-(\d{1,2})-(\d{1,2})/",
                   "/^\s*{(\w+)}\s*=/");
$replace = array ("\\3/\\4/\\1\\2", "$\\1 =");
print preg_replace ($patterns, $replace, "{startDate} = 1999-5-27");


// eval
$html_body = '<html><title>this is a title, using eval</title>';
echo preg_replace ("/(<\/?)(\w+)([^>]*>)/e", 
                   "'\\1'.strtoupper('\\2').'\\3'", 
                   $html_body);


$docText = <<<EOD
<a href="introduction.html">1. Introduction</a></span></dt><dd><dl><dt><span class="section">
<a href="introduction.html#id2524679">What Is PHP?</a></span></dt><dt><span class="section">
<a href="ch01s02.html">What Is The Roadsend PHP Compiler?</a></span></dt><dd><dl><dt>
<span class="section"><a href="ch01s02.html#id2539836">What can The Roadsend PHP Compiler do?</a></span></dt>

</dl></dd><dt><span class="section"><a href="ch01s03.html">How It Works</a></span></dt><dt><span class="section"><a href="ch01s04.html">The Future of The Roadsend PHP Compiler</a></span></dt><dt><span class="section"><a href="ch01s05.html">Terms Used In This Manual</a></span></dt></dl></dd><dt><span class="chapter"><a href="installation.html">2. Installation and Configuration</a></span></dt><dd><dl><dt><span class="section"><a href="installation.html#id2525662">Installation and Development Environment</a></span></dt><dd><dl><dt><span class="section"><a href="installation.html#id2534091">Requirements</a></span></dt><dt><span class="section"><a href="installation.html#id2560409">Installing The Roadsend PHP Compiler</a></span></dt><dt><span class="section"><a href="installation.html#id2523087">Installing Apache Module</a></span></dt><dt><span class="section"><a href="installation.html#id2523156">Installing A License File</a></span></dt></dl></dd><dt><span class="section"><a href="config-file.html">Configuration</a></span></dt><dt><span class="section"><a href="ch02s03.html">Uninstalling</a></span></dt></dl></dd><dt><span class="chapter"><a href="use.html">3. Use</a></span></dt><dd><dl><dt><span class="section"><a href="use.html#id2520221">Overview
  </a></span></dt><dt><span class="section"><a href="ch03s02.html">Interpreting vs. Compiling</a></span></dt><dd><dl><dt><span class="section"><a href="ch03s02.html#id2511896">Mixed Interpreting/Compiling</a></span></dt></dl></dd><dt><span class="section"><a href="ch03s03.html">Compiling Stand Alone Applications</a></span></dt><dd><dl><dt><span class="section"><a href="ch03s03.html#id2522092">Multiple Source Files</a></span></dt><dt><span class="section"><a href="ch03s03.html#compile-with-libs">Compiling With a Library</a></span></dt><dt><span class="section"><a href="ch03s03.html#extensions">Precompiled Extensions</a></span></dt></dl></dd><dt><span class="section"><a href="ch03s04.html">Compiling Libraries</a></span></dt><dd><dl><dt><span class="section"><a href="ch03s04.html#installing-libs">Installing Libraries</a></span></dt><dt><span class="section"><a href="ch03s04.html#lib-cline">Library Command Line Options</a></span></dt></dl></dd><dt><span class="section"><a href="webapps.html">Web Applications</a></span></dt><dd><dl><dt><span class="section"><a href="webapps.html#id2510099">Compiled Web Applications</a></span></dt><dt><span class="section"><a href="webapps.html#id2510243">Interpreted Web Applications</a></span></dt></dl></dd><dt><span class="section"><a href="ch03s06.html">Differences From Zend PHP</a></span></dt><dd><dl><dt><span class="section"><a href="ch03s06.html#handling-includes">Handling Include Files</a></span></dt><dt><span class="section"><a href="ch03s06.html#id2523421">Semantic Differences</a></span></dt><dt><span class="section"><a href="ch03s06.html#id2523466">Available Extensions</a></span></dt></dl></dd><dt><span class="section"><a href="ch03s07.html">Writing Portable PHP Code</a></span></dt><dt><span class="section"><a href="ch03s08.html">Optimization</a></span></dt><dd><dl><dt><span class="section"><a href="ch03s08.html#id2523574">Shared vs Static</a></span></dt></dl></dd></dl></dd><dt><span class="chapter"><a href="reference.html">4. Reference</a></span></dt><dd><dl><dt><span class="section"><a href="reference.html#id2561585">Command Line Options</a></span></dt><dt><span class="section"><a href="ch04s02.html">
    Environment Variables
  </a></span></dt><dt><span class="section"><a href="ch04s03.html">Known Issues</a></span></dt></dl></dd><dt><span class="chapter"><a href="faq.html">5. Frequently Asked Questions</a></span></dt></dl></div><div class="list-of-figures"><p><b>List of Figures</b></p><dl><dt>3.1. <a href="ch03s02.html#id2511877">Interpreting vs. Compiling</a></dt><dt>3.2. <a href="ch03s02.html#id2511909">Interpreting Include Files at Runtime</a></dt><dt>3.3. <a href="ch03s02.html#id2511939">Running Compiled Code From An Interpreted Web page</a></dt><dt>3.4. <a href="ch03s03.html#id2522115">Multiple Source Files</a></dt><dt>3.5. <a href="ch03s04.html#id2546704">Using Compiled Libraries</a></dt></dl></div><div class="list-of-tables"><p><b>List of Tables</b></p><dl><dt>2.1. <a href="installation.html#id2516418">Supported Platforms</a></dt><dt>2.2. <a href="installation.html#id2560425">Packages</a></dt><dt>2.3. <a href="installation.html#id2445512">Selecting which packages to install</a></dt><dt>2.4. <a href="installation.html#id2445577">Self Installer Packages</a></dt><dt>2.5. <a href="installation.html#id2445643">Debian Packages</a></dt><dt>2.6. <a href="installation.html#id2523031">RPM Packages</a></dt><dt>2.7. <a href="config-file.html#id2544986">Configuration Directives</a></dt><dt>2.8. <a href="ch02s03.html#id2514426">Uninstallation Scripts</a></dt><dt>4.1. <a href="ch04s02.html#id2516676">Environment Variables</a></dt></dl></div><div class="list-of-examples"><p><b>List of Examples</b></p><dl><dt>3.1. <a href="ch03s03.html#id2522058">Single Source File (first.php)</a></dt><dt>3.2. <a href="ch03s03.html#id2522137">Multiple Source Files</a></dt><dt>3.3. <a href="ch03s06.html#id2523436">Declaring a Pass-By-Reference Parameter</a></dt></dl></div></div><div class="navfooter"><hr /><table width="100%" summary="Navigation footer"><tr><td width="40%" align="left">\x{FFFF}</td><td width="20%" align="center">\x{FFFF}</td><td width="40%" align="right">\x{FFFF}<a accesskey="n" href="introduction.html">Next</a></td></tr><tr><td width="40%" align="left" valign="top">\x{FFFF}</td><td width="20%" align="center">\x{FFFF}</td><td width="40%" align="right" valign="top">\x{FFFF}Chapter\x{FFFF}1.\x{FFFF}Introduction</td></tr></table></div></body></html>
EOD;


//var_dump($docText);

$SELF = 'somefile.php';
$sVars = 'sID=12345';
$docText = preg_replace('/HREF="([^http].+)"/miU',"HREF=\"$SELF?$sVars&doc=\\1\"",$docText);
var_dump($docText);


$text = '---123445567890---';
$newtext = preg_replace('/([45])/','\\1-',$text);
echo "\n$newtext\n";

?>

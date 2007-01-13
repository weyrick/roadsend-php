<?


$html = '

<h1
><a
NAME="function.strip-tags"
></a
>strip_tags</h1
><div
CLASS="refnamediv"
><a
NAME="AEN101923"
></a
><p
>    (PHP 3&#62;= 3.0.8, PHP 4 )</p
>strip_tags&nbsp;--&nbsp;Strip HTML and PHP tags from a string</div
><div
CLASS="refsect1"
><a
NAME="AEN101926"
></a
><h2
>Description</h2
>string <b
CLASS="methodname"
>strip_tags</b
> ( string str [, string allowable_tags])<br
></br
><p
>&#13;     This function tries to return a string with all HTML and PHP tags
     stripped from a given <tt
CLASS="parameter"
><i
>str</i
></tt
>.  It errors on
     the side of caution in case of incomplete or bogus tags.  It uses
     the same tag stripping state machine as the
     <a
HREF="function.fgetss.php"
><b
CLASS="function"
>fgetss()</b
></a
> function.
    </p
><p
>&#13;     You can use the optional second parameter to specify tags which
     should not be stripped.
     <div
CLASS="note"
><blockquote
CLASS="note"
><p
><b
>Note: </b
>

       <tt
CLASS="parameter"
><i
>allowable_tags</i
></tt
> was added in PHP 3.0.13
       and PHP 4.0b3.
      </p
></blockquote
></div
>
    </p
><p
>&#13;     <table
WIDTH="100%"
BORDER="0"
CELLPADDING="0"
CELLSPACING="0"
CLASS="EXAMPLE"
><tr
><td
><div
CLASS="example"
><a
NAME="AEN101945"
></a
><p
><b
>Example 1. <b
CLASS="function"
>strip_tags()</b
> example</b
></p
><table
BORDER="0"
BGCOLOR="#E0E0E0"
CELLPADDING="5"
><tr
><td
><pre
CLASS="php"
>&#60;?php
$string = strip_tags($string, \'&#60;a&#62;&#60;b&#62;&#60;i&#62;&#60;u&#62;\');
?&#62;</pre
></td
></tr
></table
></div
></td
></tr
></table
>

    </p
><div
CLASS="warning"
><p
></p
><table
CLASS="warning"
BORDER="1"
WIDTH="100%"
><tr
><td
ALIGN="CENTER"
><b
>Warning</b
></td
></tr
><tr
><td
ALIGN="LEFT"
><p
>&#13;      This function does not modify any attributes on the tags that you allow
      using <tt
CLASS="parameter"
><i
>allowable_tags</i
></tt
>, including the
      <tt
CLASS="literal"
>style</tt
> and <tt
CLASS="literal"
>onmouseover</tt
> attributes
      that a mischievous user may abuse when posting text that will be shown
      to other users.
     </p
></td
></tr
></table
></div
></div
><br /><br />

';


echo strip_tags('NEAT <img src="test"> STUFF');
echo "\n";

echo strip_tags('NEAT <img > src="test"> STUFF');
echo "\n";

echo strip_tags('NEAT <img < src="test"> STUFF');
echo "\n";

echo strip_tags('NEAT < img < src="test"> STUFF');
echo "\n";

echo strip_tags('<b
>STUFF</b
>');
echo "\n";

echo strip_tags('<td>NEAT < here <img < src="test"> STUFF</td>');
echo "\n";

echo strip_tags('NEAT <? cool < blah ?> STUFF');
echo "\n";

echo strip_tags('NEAT <? cool > blah ?> STUFF');
echo "\n";

echo strip_tags('NEAT <!-- cool < blah --> STUFF');
echo "\n";


echo strip_tags('NEAT <!-- cool > blah --> STUFF');
echo "\n";

echo strip_tags('NEAT <? echo \"\\\"\"?> STUFF');
echo "\n";

echo strip_tags('NEAT <? echo \'\\\'\'?> STUFF');
echo "\n";
echo strip_tags('TESTS ?!!?!?!!!?!!');
echo "\n";

echo strip_tags($html);
echo strip_tags($html,'<b>');


?>
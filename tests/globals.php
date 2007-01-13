<?php

$foo = "this is variable 'foo'";

$bar = 12;

echo "foo: $foo\n";
echo "bar: $bar\n";

funofoneglobal();

echo "foo: $foo\n";
echo "bar: $bar\n";

funoftwoglobals();

echo "foo: $foo\n";
echo "bar: $bar\n";


function funofoneglobal()
{
  global $foo;

  echo "in funofoneglobal, foo is $foo\n";
}

function funoftwoglobals()
{
  global $foo, $bar;

  echo "in funoftwoglobals, foo is $foo\n";
  echo "in funoftwoglobals, bar is $bar\n";

  $foo = 8;
  $bar = $foo + $bar; 

  echo "in funoftwoglobals, foo becomes $foo\n";
  echo "in funoftwoglobals, bar becomes $bar\n";
}

?>
<?php

class foo {
  var $include = "include";
  var $include_once = "include_once";
  var $require = "require";
  var $require_once = "require_once";
  var $continue = "continue";
  var $define = "define";
  var $parent = "parent";
  var $exit = "exit";
  var $false = "false";
  var $true = "true";
  var $echo = "echo";
  var $print = "print";
  var $if = "if";
  var $else = "else";
  var $elseif = "elseif";
  var $while = "while";
  var $do = "do";
  var $or = "or";
  var $xor = "xor";
  var $and = "and";
  var $endwhile = "endwhile";
  var $endif = "endif";
  var $for = "for";
  var $foreach = "foreach";
  var $as = "as";
  var $unset = "unset";
  var $function = "function";
  var $var = "var";
  var $class = "class";
  var $extends = "extends";
  var $array = "array";
  var $list = "list";
  var $new = "new";
  var $return = "return";
  var $global = "global";
  var $static = "static";
  var $switch = "switch";
  var $endswitch = "endswitch";
  var $default = "default";
  var $break = "break";
  var $case = "case";
  var $null = "null";
  var $bool = "bool";
  var $boolean = "boolean";
  var $int = "int";
  var $integer = "integer";
  var $float = "float";
  var $real = "real";
  var $double = "double";
  var $string = "string";
  var $object = "object";

  // php disallows:  function include() { echo "called include\n"; }
  // php disallows:  function include_once() { echo "called include_once\n"; }
  // php disallows:  function require() { echo "called require\n"; }
  // php disallows:  function require_once() { echo "called require_once\n"; }
  // php disallows:  function continue() { echo "called continue\n"; }
  function define() { echo "called define\n"; }
  function parent() { echo "called parent\n"; }
  // php disallows:  function exit() { echo "called exit\n"; }
  function false() { echo "called false\n"; }
  function true() { echo "called true\n"; }
  // php disallows:  function echo() { echo "called echo\n"; }
  // php disallows:  function print() { echo "called print\n"; }
  // php disallows:  function if() { echo "called if\n"; }
  // php disallows:  function else() { echo "called else\n"; }
  // php disallows:  function elseif() { echo "called elseif\n"; }
  // php disallows:  function while() { echo "called while\n"; }
  // php disallows:  function do() { echo "called do\n"; }
  // php disallows:  function or() { echo "called or\n"; }
  // php disallows:  function xor() { echo "called xor\n"; }
  // php disallows:  function and() { echo "called and\n"; }
  // php disallows:  function endwhile() { echo "called endwhile\n"; }
  // php disallows:  function endif() { echo "called endif\n"; }
  // php disallows:  function for() { echo "called for\n"; }
  // php disallows:  function foreach() { echo "called foreach\n"; }
  // php disallows:  function as() { echo "called as\n"; }
  // php disallows:  function unset() { echo "called unset\n"; }
  // php disallows:  function function() { echo "called function\n"; }
  // php disallows:  function var() { echo "called var\n"; }
  // php disallows:  function class() { echo "called class\n"; }
  // php disallows:  function extends() { echo "called extends\n"; }
  // php disallows:  function array() { echo "called array\n"; }
  // php disallows:  function list() { echo "called list\n"; }
  // php disallows:  function new() { echo "called new\n"; }
  // php disallows:  function return() { echo "called return\n"; }
  // php disallows:  function break() { echo "called break\n"; }
  // php disallows:  function global() { echo "called global\n"; }
  // php disallows:  function static() { echo "called static\n"; }
  // php disallows:  function switch() { echo "called switch\n"; }
  // php disallows:  function endswitch() { echo "called endswitch\n"; }
  // php disallows:  function default() { echo "called default\n"; }
  // php disallows:  function break() { echo "called break\n"; }
  // php disallows:  function case() { echo "called case\n"; }
  function null() { echo "called null\n"; }
  function bool() { echo "called bool\n"; }
  function boolean() { echo "called boolean\n"; }
  function int() { echo "called int\n"; }
  function integer() { echo "called integer\n"; }
  function float() { echo "called float\n"; }
  function real() { echo "called real\n"; }
  function double() { echo "called double\n"; }
  function string() { echo "called string\n"; }
  function object() { echo "called object\n"; }
}

$afoo = new foo();

echo "property 'include': " . $afoo->include . "\n";
echo "property 'include_once': " . $afoo->include_once . "\n";
echo "property 'require': " . $afoo->require . "\n";
echo "property 'require_once': " . $afoo->require_once . "\n";
echo "property 'continue': " . $afoo->continue . "\n";
echo "property 'define': " . $afoo->define . "\n";
echo "property 'parent': " . $afoo->parent . "\n";
echo "property 'exit': " . $afoo->exit . "\n";
echo "property 'false': " . $afoo->false . "\n";
echo "property 'true': " . $afoo->true . "\n";
echo "property 'echo': " . $afoo->echo . "\n";
echo "property 'print': " . $afoo->print . "\n";
echo "property 'if': " . $afoo->if . "\n";
echo "property 'else': " . $afoo->else . "\n";
echo "property 'elseif': " . $afoo->elseif . "\n";
echo "property 'while': " . $afoo->while . "\n";
echo "property 'do': " . $afoo->do . "\n";
echo "property 'or': " . $afoo->or . "\n";
echo "property 'xor': " . $afoo->xor . "\n";
echo "property 'and': " . $afoo->and . "\n";
echo "property 'endwhile': " . $afoo->endwhile . "\n";
echo "property 'endif': " . $afoo->endif . "\n";
echo "property 'for': " . $afoo->for . "\n";
echo "property 'foreach': " . $afoo->foreach . "\n";
echo "property 'as': " . $afoo->as . "\n";
echo "property 'unset': " . $afoo->unset . "\n";
echo "property 'function': " . $afoo->function . "\n";
echo "property 'var': " . $afoo->var . "\n";
echo "property 'class': " . $afoo->class . "\n";
echo "property 'extends': " . $afoo->extends . "\n";
echo "property 'array': " . $afoo->array . "\n";
echo "property 'list': " . $afoo->list . "\n";
echo "property 'new': " . $afoo->new . "\n";
echo "property 'return': " . $afoo->return . "\n";
echo "property 'break': " . $afoo->break . "\n";
echo "property 'global': " . $afoo->global . "\n";
echo "property 'static': " . $afoo->static . "\n";
echo "property 'switch': " . $afoo->switch . "\n";
echo "property 'endswitch': " . $afoo->endswitch . "\n";
echo "property 'default': " . $afoo->default . "\n";
echo "property 'break': " . $afoo->break . "\n";
echo "property 'case': " . $afoo->case . "\n";
echo "property 'null': " . $afoo->null . "\n";
echo "property 'bool': " . $afoo->bool . "\n";
echo "property 'boolean': " . $afoo->boolean . "\n";
echo "property 'int': " . $afoo->int . "\n";
echo "property 'integer': " . $afoo->integer . "\n";
echo "property 'float': " . $afoo->float . "\n";
echo "property 'real': " . $afoo->real . "\n";
echo "property 'double': " . $afoo->double . "\n";
echo "property 'string': " . $afoo->string . "\n";
echo "property 'object': " . $afoo->object . "\n";



// php disallows:  $afoo->include();
// php disallows:  $afoo->include_once();
// php disallows:  $afoo->require();
// php disallows:  $afoo->require_once();
// php disallows:  $afoo->continue();
$afoo->define();
$afoo->parent();
// php disallows:  $afoo->exit();
$afoo->false();
$afoo->true();
// php disallows:  $afoo->echo();
// php disallows:  $afoo->print();
// php disallows:  $afoo->if();
// php disallows:  $afoo->else();
// php disallows:  $afoo->elseif();
// php disallows:  $afoo->while();
// php disallows:  $afoo->do();
// php disallows:  $afoo->or();
// php disallows:  $afoo->xor();
// php disallows:  $afoo->and();
// php disallows:  $afoo->endwhile();
// php disallows:  $afoo->endif();
// php disallows:  $afoo->for();
// php disallows:  $afoo->foreach();
// php disallows:  $afoo->as();
// php disallows:  $afoo->unset();
// php disallows:  $afoo->function();
// php disallows:  $afoo->var();
// php disallows:  $afoo->class();
// php disallows:  $afoo->extends();
// php disallows:  $afoo->array();
// php disallows:  $afoo->list();
// php disallows:  $afoo->new();
// php disallows:  $afoo->return();
// php disallows:  $afoo->break();
// php disallows:  $afoo->global();
// php disallows:  $afoo->static();
// php disallows:  $afoo->switch();
// php disallows:  $afoo->endswitch();
// php disallows:  $afoo->default();
// php disallows:  $afoo->break();
// php disallows:  $afoo->case();
$afoo->null();
$afoo->bool();
$afoo->boolean();
$afoo->int();
$afoo->integer();
$afoo->float();
$afoo->real();
$afoo->double();
$afoo->string();
$afoo->object();

?>

The {$ ... } construct now allows general expressions in some cases.  
${ ... } in some too, but not as many (??)
<?php
class foo { function method() { return "value"; } }
$foo = new foo();
print "property is : {$foo->method(print 'asdf')}\n";

$bar = array(1, 2, 3);
print "property is : {$bar[print 'another print']}\n";
print "property is : ${bar[print 'another print']}\n";
//$bar[print 'another print'];

var_dump(print('asdfasdfasdf'));
?>
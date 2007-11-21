<?

class MyClass
{
}
class NotMyClass
{
}
$a = new MyClass;

var_dump($a instanceof MyClass);
var_dump($a instanceof NotMyClass);

class ParentClass
{
}
class MyClass2 extends ParentClass
{
}
$a = new MyClass2;

var_dump($a instanceof MyClass2);
var_dump($a instanceof ParentClass);


interface MyInterface
{
}
class MyClass3 implements MyInterface
{
}
$a = new MyClass3;

var_dump($a instanceof MyClass3);
var_dump($a instanceof MyInterface);

interface MyInterface2
{
}
class MyClass4 implements MyInterface2
{
}
$a = new MyClass4;
$b = new MyClass4;
$c = 'MyClass4';
$d = 'NotMyClass';
var_dump($a instanceof $b); // $b is an object of class MyClass4
var_dump($a instanceof $c); // $c is a string 'MyClass4'
var_dump($a instanceof $d); // $d is a string 'NotMyClass'

?>
bigloo type error from pcc

Description 	pcc gives the following warning:

Type error -- `struct' expected, `nil' provided

when trying to compile the following snipet of code:

<?
function foo() {
$bar[1];
}
?>
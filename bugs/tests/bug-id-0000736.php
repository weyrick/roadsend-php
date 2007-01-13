0000736

this is the core of the issue:
<?
echo "{$columnConfig[$name]['postfix']}";


?>

 parse error on ridiculous string assignment 

 yes, this was pulled from actual code...

<?

$name = 'hi';
$columnConfig[$name]['postFix'] = 'test';

// Check to see if we need to add a postfix
if(!empty($columnConfig[$name]['postfix'])) {
  $postfix="{$columnConfig[$name]['postfix']}";
} else {
  $postfix="nope";
}

echo $postfix;

?>



i believe this is the same parse problem, here is another example

<?


class blah {
var $style;

function style() {
$text = 'my text';
$sName = 'mystyle';
$this->style[$sName] = 'meep';
$text = "<span class=\"{$this->style[$sName]}\">$text</span>\n";
return $text;
}
}

$b = new blah();
echo $b->style();


?>

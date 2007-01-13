Alternative syntax for control structures

<?
if ($foo == "no"):
$bar = $foo;
elseif ($foo = "yes"):
//dont do anything
endif;
?>

-- or --

<?
if ($foo == "no"):
//dont do anything
elseif ($foo = "yes"):
$bar = $foo;
endif;
?>
 
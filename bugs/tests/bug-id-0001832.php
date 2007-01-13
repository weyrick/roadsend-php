wierd problem with unset

When unset is called as the only instruction in a foreach loop 
and curly brackets aren't used, and this foreach loop is the only 
argument inside an if/else block where curly brackets aren't used, 
pcc complains about the else.

example:


<?
if(true)
     foreach(array() as $bar)
          unset($bar);
else
     unset($bar);
?>


it doesn't seam to be a problem under any other combination of curly brackets or functions.
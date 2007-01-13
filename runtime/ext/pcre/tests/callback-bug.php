<?
   $text = "April fools day is 04/01/2002\n";
   function foo($matches) {
         $i = $GLOBALS['botMosImageCount']++;
         return @$GLOBALS['botMosImageArray'][$i];
   }
   echo preg_replace_callback("/foo/", "foo",$text);
?>

Summary  	 continue

 problem inside a switch statement

Description 	

 when you try to continue out of a nested switch statment, pcc complains but php lets you do it.

<?
for($a=1; $a<10; $a++) {
   switch ($a) {
   case 1: echo "$a\n"; break;
   case 2: echo "$a\n"; break;
   case 3: echo "$a\n"; break;
   case 4: continue 2;
   case 5: echo "$a\n"; break;
   default:
   }
}
?>

foo

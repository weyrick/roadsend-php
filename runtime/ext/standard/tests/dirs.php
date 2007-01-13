<?php
// Note that !== did not exist until 4.0.0-RC2

if (PHP_OS == 'WINNT')
  $dir = 'c:\\windows';
else
  $dir = '/etc';

if ($handle = opendir($dir)) {
   echo "Directory handle: $handle\n";
   echo "Files:\n";

   /* This is the correct way to loop over the directory. */
   while (false !== ($file = readdir($handle))) {
       echo "$file\n";
   }

   /* This is the WRONG way to loop over the directory. */
   while ($file = readdir($handle)) {
       echo "$file\n";
   }

   closedir($handle);
}

if (PHP_OS == 'WINNT') {

echo '1:'.dirname('c:')."\n";
echo '2:'.dirname('c:\\')."\n";
echo '3:'.dirname('z:\\')."\n";
echo '4:'.dirname('z:\\foobar\\')."\n";
echo '5:'.dirname('//somepath/foo')."\n";

}

?>

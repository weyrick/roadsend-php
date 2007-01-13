<?php

if ($dir = opendir("/etc")) {
  while (($file = readdir($dir)) !== false) {
    echo "$file\n";
  }  
  closedir($dir);
}

?>

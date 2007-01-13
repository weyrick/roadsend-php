<?php  
system("sh -c 'exit 101'", $r); echo "system: $r\n"; 
exec("sh -c 'exit 99'", $out, $r); echo "exec: $r\n"; 
passthru("sh -c 'exit 76'", $r); echo "passthru: $r\n"; 
?>

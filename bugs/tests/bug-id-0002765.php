php-hash's doubly linked list is being walked past the sentinel

Looks like this will do it:

<?php

$hash = array(1, 2);

print(array_pop($hash));
print(array_pop($hash));
print(array_pop($hash));
print("\n");
?>

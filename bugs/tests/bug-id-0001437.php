0001437 php-hashes don't behave quite the same as php's hashes after deleting entries
<?php

$foo = array("foo", "bar", "baz");
unset($foo[0]);
print_r($foo);

?>

This is due to the way elements are deleted from the ordered-rep vector. It's probably better to maintain two pointers in each entry in the hashtable -- prev and next -- like a doubly linked list, than to dick around with the vector. That would fix this.
<?php

if ($expression) { 
    ?>
    <strong>This is true.</strong>
    <?php 
} else { 
    ?>
    <strong>This is \false.</strong>
    <?php 
}

$expression = 1;

if ($expression) { 
    ?>
    <strong>This is 'true'.</strong>
    <?php 
} else { 
    ?>
    <strong>This is false.</strong>
    <?php 
}
?>

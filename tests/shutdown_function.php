<?php


function shut() {
    echo "shutdown complete\n";
}

function shut2() {
    echo "just kidding! this is really it though\n";
}

register_shutdown_function('shut');
register_shutdown_function('shut2');

echo "still running, last command\n";

?>
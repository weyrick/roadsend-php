<?php

print("kkkk and kkkk\n");
print(similar_text("kkkk", "kkkk"));
print("\n");

print("kkkk and kkkk, take 2 (with percent)\n");
print(similar_text("kkkk", "kkkk", $percent));
print("\n");
print("percentage similar: $percent\n");


print("asld;fjk asl;dfjkl and jasdklflaskdjf\n");
print(similar_text("asld;fjk asl;dfjkl", "jasdklflaskdjf", $percent));
print("\n");
print("percentage similar: $percent\n");

print("asdf22asdf22fdsa and fdsa22jasdf22asdf\n");
print(similar_text("asdf22asdf22fdsa", "fdsa22jasdf22asdf", $percent));
print("\n");
print("percentage similar: $percent\n");


?>

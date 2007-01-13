If the last semicolon before the '?>' is skipped, there is a comment on the same 
line as the last line of code and the end tag is also on the line, pcc pukes.

<? echo "goodbye, cruel world\n" //some comment ?>

foo

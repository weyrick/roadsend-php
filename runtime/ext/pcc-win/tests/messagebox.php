<?

$ret = win_messagebox('this is text yaya','roadsend caption',MB_YESNOCANCEL);
echo "ret was $ret\n";
switch ($ret) {
    case IDYES:
        win_messagebox("you said yes",'yay!!');
        break;
    case IDNO:
        win_messagebox("you said no :(", "dang");
        break;
    case IDCANCEL:
        win_messagebox("or, not", "doh");
        break;
}

?>
<?

/*

win_shellexecute($operation, $file, $params, $workdir, $showcmd)

win_get_registry_key($key, $subkey, $entry)

win_set_registry_key($key, $subkey, $entry, $value)

win_messagebox($text, $caption, $type)

win_getlasterror()

*/

$ret = win_messagebox('Welcome to the Roadsend Compiler', PCC_VERSION_TAG, MB_YESNOCANCEL|MB_ICONASTERISK);
switch ($ret) {
    case IDYES:
        win_messagebox("You answered Yes",'Go');
        break;
    case IDNO:
        win_messagebox("You answered No", 'Stop');
        break;
    case IDCANCEL:
        win_messagebox("You answered Cancel", "Cancel");
        break;
}

$install_dir = win_get_registry_key(HKEY_LOCAL_MACHINE,
                                    "SOFTWARE\\Roadsend\\Compiler\\".
                                    PCC_VERSION_MAJOR.'.'.
                                    PCC_VERSION_MINOR,
                                    "root");

win_messagebox("The Roadsend install dir is [" .$install_dir."]\n",'Version');

echo "last error: ".win_getlasterror();

?>
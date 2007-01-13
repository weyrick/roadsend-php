<?

echo PHP_OS."\n";

$wallpaper = win_get_registry_key(HKEY_CURRENT_USER, "Control Panel\\Desktop", "Wallpaper");
echo "The current wallpaper file is [" .$wallpaper. "]\n";

$install_dir = win_get_registry_key(HKEY_LOCAL_MACHINE,
                                    "SOFTWARE\\Roadsend\\Compiler\\".
                                    PCC_VERSION_MAJOR.'.'.
                                    PCC_VERSION_MINOR,
                                    "root");

echo "The Roadsend install dir is [" .$install_dir."]\n";

win_set_registry_key(HKEY_LOCAL_MACHINE,
                     "SOFTWARE\\Roadsend\\Compiler\\".
                     PCC_VERSION_MAJOR.'.'.
                     PCC_VERSION_MINOR,
                     "stringtest",
                     "mystringval");

echo win_get_registry_key(HKEY_LOCAL_MACHINE,
                                    "SOFTWARE\\Roadsend\\Compiler\\".
                                    PCC_VERSION_MAJOR.'.'.
                                    PCC_VERSION_MINOR,
                                    "stringtest");

win_set_registry_key(HKEY_LOCAL_MACHINE,
                     "SOFTWARE\\Roadsend\\Compiler\\".
                     PCC_VERSION_MAJOR.'.'.
                     PCC_VERSION_MINOR,
                     "inttest",
                     25);

echo win_get_registry_key(HKEY_LOCAL_MACHINE,
                                    "SOFTWARE\\Roadsend\\Compiler\\".
                                    PCC_VERSION_MAJOR.'.'.
                                    PCC_VERSION_MINOR,
                                    "inttest");

?>
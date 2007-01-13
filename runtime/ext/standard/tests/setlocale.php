<?php
/* locale auf Holland setzen */
setlocale (LC_ALL, 'nl_NL');

/* Ausgabe: vrijdag 22 december 1978 */
echo strftime ("%A %e %B %Y", mktime (0, 0, 0, 12, 22, 1978));
echo "\n";
echo gmstrftime ("%A %e %B %Y", mktime (0, 0, 0, 12, 22, 1978));
echo "\n";

/* versuche verschiedene mögliche locale Namen für Deutsch ab PHP 4.3.0 */
$loc_de = setlocale (LC_ALL, 'de_DE@euro', 'de_DE', 'de', 'ge');
echo "Preferred locale for german on this system is '$loc_de'\n";


/* try again, using an array */
$loc_de = setlocale (LC_ALL, array('de_DE@euro', 'de_DE', 'de', 'ge'));
echo "Preferred locale for german on this system is '$loc_de'\n";

?> 

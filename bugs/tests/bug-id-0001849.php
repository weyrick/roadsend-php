<?

//include('constant_inc.php');

function lang_load( $p_lang ) {
    global $g_lang_strings, $g_lang_current;
		
//     if ( $g_lang_current == $p_lang ) {
// 	return;
//     }
		
    // define current language here so that when custom_strings_inc is
    // included it knows the current language
    $g_lang_current = $p_lang;

    //$t_lang_dir = dirname ( dirname ( __FILE__ ) ) . DIRECTORY_SEPARATOR . 'lang' . DIRECTORY_SEPARATOR;
    $t_lang_dir = './';
    require_once( $t_lang_dir . 'strings_'.$p_lang.'.inc' );		
		
    $t_vars = get_defined_vars();
    //    print(sizeof($t_vars) . "\n");
    //    print_r(array_keys($t_vars));
    foreach ( array_keys( $t_vars ) as $t_var ) {
	$t_lang_var = ereg_replace( '^s_', '', $t_var );
	if ( $t_lang_var != $t_var || 'MANTIS_ERROR' == $t_var ) {
	    $g_lang_strings[$t_lang_var] = $$t_var;
	}
    }

}

lang_load('english');

print_r($g_lang_strings);
//print_r(array_keys(get_defined_vars()));
?>

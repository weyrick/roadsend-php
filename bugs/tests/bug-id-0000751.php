<?

function aphp_uname() {
  return 'Linux simple 2.4.18 #1 Sat Mar 1 15:55:45 EST 2003 i686';
}

function parseSignature($uname = null)
{
  static $sysmap = array('HP-UX' => 'hpux',
			 'IRIX64' => 'irix',
			 // Darwin?
			 );
  static $cpumap = array('i586' => 'i386',
			 'i686' => 'i386',
			 );
  if ($uname === null) {
    $uname = aphp_uname();
  }
  $parts = split('[[:space:]]+', trim($uname));
  echo $parts;
}
  
?>

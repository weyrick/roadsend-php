<?php

function open($save_path, $session_name)
{
  global $sess_save_path, $sess_session_name;
  echo "open: $save_path, $session_name\n";      
  $sess_save_path = $save_path;
  $sess_session_name = $session_name;
  return(true);
}

function close()
{
    echo "close\n";
  return(true);
}

function read($id)
{
  global $sess_save_path, $sess_session_name;
  echo "read: \n";
  $sess_file = "$sess_save_path/sess_$id";
  if ($fp = @fopen($sess_file, "r")) {
   $sess_data = fread($fp, filesize($sess_file));
   return($sess_data);
  } else {
   return(""); // Must return "" here.
  }

}

function write($id, $sess_data)
{
  global $sess_save_path, $sess_session_name;
  echo "write: $sess_data\n";
  $sess_file = "$sess_save_path/sess_$id";
  if ($fp = @fopen($sess_file, "w")) {
   return(fwrite($fp, $sess_data));
  } else {
   return(false);
  }

}

function destroy($id)
{
  global $sess_save_path, $sess_session_name;
  echo "destroy\n";
  $sess_file = "$sess_save_path/sess_$id";
  return(@unlink($sess_file));
}

/*********************************************
 * WARNING - You will need to implement some *
 * sort of garbage collection routine here.  *
 *********************************************/
function gc($maxlifetime)
{
    echo "gc\n";
  return true;
}

session_set_save_handler("open", "close", "read", "write", "destroy", "gc");

session_start();

// proceed to use sessions normally

$_SESSION['bork'] = 'zot';



?>
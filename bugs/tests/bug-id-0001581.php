 up here
<?

class aclass {

   var $exit=1;

   function hi() {
     if ($this->exit) {
       exit;
     } else
       print "sucked";
   }

}

$a = new aclass();
$a->hi();

?>
down here

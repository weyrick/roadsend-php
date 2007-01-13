<HTML>
  <HEAD>
    <TITLE>"This is a 
      <?php echo "success" . "ful" ."ly" ?> 
      deployed web page.
    </TITLE>
  </HEAD>
  <BODY>
    Two plus two is 
    <?php 
      $foo = array(0 => "zero", 
                   1 => "one",
                   2 => "two",
                   3 => "three",
                   4 => "four",
                   5 => "five");
      echo $foo[2 + 2];
    ?>.<BR>    
    It's clearly not
    <?php
      foreach ($foo as $num => $name) {
        if (!($num == 2 + 2 || $num == count($foo) - 1))
          echo "$name, ";
      }
      echo "or $foo[$num].";
    ?><BR>
  </BODY>
</HTML>
 
    


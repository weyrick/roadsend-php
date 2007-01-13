<?php

// base class with member properties and methods
class Vegetable {

  var $edible, $color="brown";

    function Vegetable( $edible, $color="green" ) {
        $this->edible = $edible;
        $this->color = $color;
    }

    function staticable($anarg) {
      print "You passed this very special staticable function: $anarg\n";
    }

    function is_edible() {
        return $this->edible;
    }

    function what_color() {
        return $this->color;
    }
    
} // end of class Vegetable


// extends the base class
class Spinach extends Vegetable {

    var $cooked = false;

    function Spinach() {
        $this->Vegetable( true, "green" );
    }

    function cook_it() {
        $this->cooked = true;
    }

    function is_cooked() {
        return $this->cooked;
    }
    
} // end of class Spinach

?>

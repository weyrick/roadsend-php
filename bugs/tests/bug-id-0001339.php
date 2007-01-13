<?

class aclass {
    
    var $avar;
    var $bvar;
    
    function afunc() {
        
        $a = array(1,2,3,4,5);
        foreach ($a as $this->avar)
            echo "working with $this->avar\n";

        foreach ($a as $k => $this->avar)
            echo "working with $k and $this->avar\n";

        foreach ($a as $this->avar => $v)
            echo "working with $v and $this->avar\n";

        foreach ($a as $this->avar => $this->bvar)
            echo "working with $this->bvar and $this->avar\n";

        var_dump($this->avar);
        
    }
    
}

$a = new aclass();
$a->afunc();


?>
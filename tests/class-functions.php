<?

class foo {

}

class bar extends foo {


}

// is_subsclass: first param can be string
echo "subclass? ".is_subclass_of('bar','foo'),"\n";

?>
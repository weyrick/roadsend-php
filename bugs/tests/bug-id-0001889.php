this is similar to what sitemanager does.  it should help us ferret out 
copying problems.

<?

class tag {
  var $txt;
  function tag($t) {
    $this->txt = $t;
  }
}

class tpt {
  var $tags;
  function tpt() {
    $this->tags[] =& new tag('inited');
  }
  function addmore() {
    $this->tags[] =& new tag('more here');
  }
}

class root {
  var $tlist = array();

  function newtpt($key) {

    if (isset($this->tlist[$key])) {
      echo "found cache for $key\n";
      return $this->tlist[$key];
    }

    echo "no cache for $key\n";
    $newTemplate =& new tpt();

    // cache it
    $this->tlist[$key] =& $newTemplate;

    // return new template
    return $newTemplate;

  }
}


$r =& new root();

$t =& $r->newtpt('thiskey');
var_dump($t);
$t->addmore();
var_dump($t);

$t2 =& $r->newtpt('thiskey');
var_dump($t2);
$t2->addmore();
var_dump($t2);



?>

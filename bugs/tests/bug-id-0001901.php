methods can modify their $this, so it must have any pending copies 
forced on it for the method call.  This tests for that, in an 
admittedly baroque way. the line         

  $this->smTagList[$areaName]->addItem($output);

is where the copy should be forced


<?

// defines
define('SM_TAG_IDENTIFIER','SM'); // if you want something other than <SM> tags, change this
define('SM_TAG_PREGEXP','/<\s*'.SM_TAG_IDENTIFIER.'\s(.+)\s*>/Ui');
define('SM_TAG_ATTR_PREGEXP','/(\w+)\s*=\s*[\"\'](.+)[\"\']/SUi');
define('SM_AREAID_KEY','_SMarea-');
define('SM_TAG_CLASS','SM_smTag_');

class SM_layoutTemplate { //extends SM_object {
        
    var $smTagList = array();

    var $htmlTemplate = '';

    var $htmlParsedOutput = '';

    var $htmlOutput = '';
        
    var $tagPriorityList = array();

    var $parsed = false;
    
    
    function setTemplateData($templateData, $parse=true) {
        $this->htmlTemplate = split("\n",$templateData);
	return $this->_php_parseTemplate();
    }


    function _php_parseTemplate() {

        if (sizeof($this->htmlTemplate) == 0) {
            $this->debugLog("template data was blank, ignoring");
            return false;
        }


        $this->htmlParsedOutput   = '';

	//tagclassname: SM_smTag_AREA
	$tagClass =& new SM_smTag_AREA();
	$tagClass->setParent($this);
	$tagClass->setTagData('<sm type="area" name="areaOne">', array("TYPE" => "area", "NAME" => "areaOne"));
	$this->smTagList["areaOne"] = $tagClass;
	$this->tagPriorityList[$tagClass->thinkPriority][] = "areaOne";

        $this->parsed = true;

        return true;

    }

             
    function addText($output, $areaName) {
      //      $foo =& $this->smTagList[$areaName];
        $this->smTagList[$areaName]->addItem($output);
    }





}



class SM_siteManagerRoot { //extends SM_object {
    
    var $templateCache = array();

    function loadTemplate($fName, $fatalFNF=true) {

	$tptData = '<b>Sample Template</b><br>
<sm type="area" name="areaOne">
<br>
Template Test Complete
';
        
        // in cache?
        if (isset($this->templateCache[$fName])) {
	    echo "CACHED:\n";
            return $this->templateCache[$fName];
        }        

	echo "NOT CACHED\n";
        // create the template
        $newTemplate =& new SM_layoutTemplate();
	$newTemplate->setTemplateData($tptData);

        // cache it
        $this->templateCache[$fName] =& $newTemplate;

        // return new template
        return $newTemplate;
    
    }

}

class SM_smTag { //extends SM_object {

    var $tagLine = '';

    var $attributes = array();

    var $tagOutput = '';

    var $thinkPriority = 0;

    var $parentTemplate = NULL;

    function setParent(&$template) {

        $this->parentTemplate =& $template;

    }

    function setTagData($tagLine, $attrs) {

        // configure 
        $this->tagLine = $tagLine;
        $this->attributes = $attrs;
        

    }

    function say($output) {
        $this->tagOutput .= $output;
    }


    
}


class SM_smTag_AREA extends SM_smTag {

    var $areaName = '';

    var $itemList = array();

    function addItem(&$data) {
        $this->itemList[] =& $data;
    }


}


function SM_loadTag($tag) {
    return true;
}

$root =& new SM_siteManagerRoot();
$tpt =& $root->loadTemplate('sample.tpt');
var_dump($tpt);
$tpt->addText('this is from first call','areaOne');


$tpt =& $root->loadTemplate('sample.tpt');
var_dump($tpt);
$tpt->addText('this is from second call','areaOne');


// $tpt =& $root->loadTemplate('sample.tpt');
// var_dump($tpt);
// $tpt->addText('this is from third call','areaOne');
// echo $tpt->run();

?>

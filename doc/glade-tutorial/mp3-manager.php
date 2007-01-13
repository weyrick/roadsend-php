<?php


class SongList {
    var $view;
    var $model = array();

    function SongList(&$clist) {
        $this->view =& $clist;
        $this->load();
    }

    function addSong($title, $artist,  $filename) {
        $this->model[] = array('title' => $title,
                               'artist' => $artist,
                               'filename' => $filename);
        $this->redisplay();
    }

    function redisplay() {
        $this->view->clear();
        $i=0;
        $clTransparentTest =& new GdkColor(0, 0, 0);
        gdk::gdk_color_parse('#FFAA33', $clTransparentTest);

        foreach($this->model as $song) {
            $this->view->append(array($song['artist'], $song['title']));
            $this->view->set_foreground($i++, $clTransparentTest);
        }
    }

    function deleteSelected() {
        if (isset($this->view->selection[0])) {
            $newModel = array();
            foreach ($this->model as $index => $song) {
                if ($index != $this->view->selection[0]) {
                    $newModel[] = $song;
                }
            }
            $this->model = $newModel;
            $this->redisplay();
        }
    }

    function save() {
        $fp = fopen("mp3-manager-songs.dat", "w");
        if (!$fp) {
            alert('Error saving songs!');
        } else {
            fwrite($fp, serialize($this->model));
            fclose($fp);
        }
    }

    function load() {
        if (file_exists("mp3-manager-songs.dat")) {
            $this->model = unserialize(file_get_contents("mp3-manager-songs.dat"));
        }
        $this->redisplay();
    }
}

class FileDialog {
    var $fs;
    var $field;

    function FileDialog(&$filenameField) {
        $this->field =& $filenameField;
    }

    function show() {
        $fs =& new GtkFileSelection('Select MP3 File');
        $fs->set_modal(true);
        $fs->ok_button->connect_object('clicked', array($this, 'ok'));
        $fs->ok_button->connect_object('clicked', array($fs, 'destroy'));
        $fs->cancel_button->connect_object('clicked', array($fs, 'destroy'));
        $fs->show();
        $this->fs =& $fs;
    }

    function ok() {
        $this->field->set_text($this->fs->get_filename());
    }
}


if (!extension_loaded('gtk')) {
    dl( 'php_gtk.' . PHP_SHLIB_SUFFIX);
}

$gladexml =& new GladeXML('mp3-manager.glade');
$window =& $gladexml->get_widget('window');

$newSong =& $gladexml->get_widget('newSong');
$newSong->connect('clicked', 'handleNewSong');

$songList =& new SongList($gladexml->get_widget('songList'));

$deleteSong =& $gladexml->get_widget('deleteSong');
$deleteSong->connect_object('clicked', array($songList, 'deleteSelected'));

$quitButton =& $gladexml->get_widget('quit');
$quitButton->connect_object('clicked', array($window, 'destroy'));

$window->connect_object('destroy', array('gtk', 'main_quit'));
$window->connect_object('destroy', array($songList, 'save'));
$window->connect_object('delete-event', array('gtk', 'false'));
Gtk::main();


function handleNewSong($widget) {
    $gladexml =& new GladeXML('song-details.glade');

    $window =& $gladexml->get_widget('details');
    $cancelButton =& $gladexml->get_widget('cancel');
    $cancelButton->connect_object('clicked', array(&$window, 'destroy'));
    
    $title =& $gladexml->get_widget('title');
    $artist =& $gladexml->get_widget('artist');
    $filename =& $gladexml->get_widget('filename');
    
    $fileSelect =& new FileDialog($filename);
    $browseButton =& $gladexml->get_widget('browse');
    $browseButton->connect_object('clicked', array($fileSelect, 'show'));
        

    $okButton =& $gladexml->get_widget('ok');
    $okButton->connect('clicked', 'addSong', array('title' => &$title,
                                                   'artist' => &$artist,
                                                   'filename' => &$filename),
                       &$window);
}


function addSong($widget, &$form, &$window) {
    global $songList;

    $title = $form['title']->get_text();
    $artist = $form['artist']->get_text();
    $filename = $form['filename']->get_text();

    if (empty($filename)) {
        alert('Please enter a filename.');
    } else {
        $songList->addSong($title, $artist, $filename);
        $window->destroy();
    }
}


function alert($message) {
    $dialog =& new GtkDialog();
    $dialog->set_modal(true);
    $dialog->set_border_width(10);
    $label =& new GtkLabel($message);
    $okButton =& new GtkButton("Okay");
    $okButton->connect_object('clicked', array($dialog, 'destroy'));
    $dialog->action_area->add($okButton);
    $dialog->vbox->add($label);
    $dialog->show_all();
}

?>

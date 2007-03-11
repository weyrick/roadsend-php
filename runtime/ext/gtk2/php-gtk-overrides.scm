;; ***** BEGIN LICENSE BLOCK *****
;; Roadsend PHP Compiler Runtime Libraries
;; Copyright (C) 2007 Roadsend, Inc.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public License
;; as published by the Free Software Foundation; either version 2.1
;; of the License, or (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Lesser General Public License for more details.
;; 
;; You should have received a copy of the GNU Lesser General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
;; ***** END LICENSE BLOCK *****
(module php-gtk-overrides
   (load (php-macros "../../../php-macros.scm"))
   (load (php-gtk-macros "php-gtk-macros.sch"))
   (library profiler)
   (import
    (gtk-binding "cigloo/gtk.scm")
    (gtk-signals "cigloo/signals.scm")
    (php-gtk-common-lib "php-gtk-common.scm")
    (gtk-enums-lib "gtk-enums.scm")
    (gdk-enums-lib "gdk-enums.scm")
;    (php-gdk-lib "php-gdk.scm")
;    (php-gtk-lib "php-gtk.scm")
    (php-gtk-signals "php-gtk-signals.scm"))
   (export
    (init-php-gtk-overrides)
    (ctree-callback ctree::GtkCTree* node::GtkCTreeNode* callback::procedure))
   (extern
    (export ctree-callback "ctree_callback")))

(define (init-php-gtk-overrides)
   1)

(def-static-method Gtk (true)
   TRUE)

(def-static-method Gtk (false)
   FALSE)

(defmethod GtkSelectionData (set type format data)
   (let* ((this::GtkSelectionData* (gtk-object $this))
	  (type::GdkAtom (php-gdk-atom-get (maybe-unbox type)))
	  (format::int (mkfixnum format))
	  (data::string (mkstr data))
	  (len::int (string-length data)))
      (gtk_selection_data_set this type format (pragma::guchar-array-256 "$1" data) len)
      NULL))


(defmethod GtkObject (get_data key)
   (let ((data::gpointer (gtk_object_get_data (gtk-object $this)
					      (mkstr key))))
      (if (foreign-null? data)
	  NULL
	  (copy-php-data (pragma::obj "$1" data)))))


(defmethod GtkObject (set_data key data)
   (let ((data::gpointer (pragma::gpointer "$1" (maybe-unbox data))))
      (pragma "extern obj_t phpgtk_destroy_notify(obj_t)")
      (reference data)
      (gtk_object_set_data_full (gtk-object $this)
				(mkstr key)
				data
				(pragma::GtkDestroyNotify
				 "(GtkDestroyNotify)phpgtk_destroy_notify"))
      NULL))

(defmethod GtkBox (query_child_packing child)
   (let ((this (GTK_BOX (gtk-object $this)))
	 (child (GTK_WIDGET (gtk-object child)))
	 (expand::bool 0)
	 (fill::bool 0)
	 (padding::guint 0)
	 (pack_type::int 0))
      (pragma "gtk_box_query_child_packing($1, $2, &$3, &$4, &$5, (GtkPackType*)&$6)"
	      this child expand fill padding pack_type)
      (list->php-hash (list (convert-to-boolean expand)
			    (convert-to-boolean fill)
			    (convert-to-integer padding)
			    (convert-to-integer pack_type)))))


(defmethod GtkCalendar (get_data)
   (let ((year::int 0)
	 (month::int 0)
	 (day::int 0))
      (gtk_calendar_get_date (GTK_CALENDAR (gtk-object $this))
			     (pragma::guint* "&$1" year)
			     (pragma::guint* "&$1" month)
			     (pragma::guint* "&$1" day))
      (list->php-hash (list year month day))))

(defmethod GtkCList (get_text row column)
   (let ((text::string ""))
      (if (zero? (gtk_clist_get_text (GTK_CLIST (gtk-object $this))
				     (mkfixnum row)
				     (mkfixnum column)
				     (pragma::string* "&$1" text)))
	  (begin
	     (php-warning "cannot get text value.")
	     NULL)
	  text)))

(defmethod GtkCList (get_pixmap row column)
   (let ((pixmap::GdkPixmap* (pragma::GdkPixmap* "NULL"))
	 (mask::GdkBitmap* (pragma::GdkBitmap* "NULL")))
      (if (zero? (gtk_clist_get_pixmap (GTK_CLIST (gtk-object $this))
				       (mkfixnum row)
				       (mkfixnum column)
				       (pragma::GdkPixmap** "&$1" pixmap)
				       (pragma::GdkBitmap** "&$1" mask)))
	  (php-warning "cannot get pixmap value")
	  (list->php-hash
	   (list (gtk-wrapper-new 'gdkpixmap pixmap)
		 (gtk-wrapper-new 'gdkbitmap mask))))))


(defmethod GtkCList (set_row_data row data)
   (reference data)
   (pragma "extern obj_t phpgtk_destroy_notify(obj_t data)")
   (gtk_clist_set_row_data_full (GTK_CLIST (gtk-object $this))
				row
				(pragma::gpointer "$1" data)
				(pragma::GtkDestroyNotify "phpgtk_destroy_notify"))
   NULL)

(defmethod GtkCList (get_row_data row)
   ;;; I don't know why the copy call is necessary, but it's in php-gtk
   (let ((data (pragma::obj "gtk_clist_get_row_data($1, $2)"
			    (GTK_CLIST (gtk-object $this))
			    (mkfixnum row))))
      (if (pragma::bool "$1" data)
	  (copy-php-data data)
	  NULL)))

(defmethod GtkCList (find_row_from_data data)
   (convert-to-number
    (gtk_clist_find_row_from_data (GTK_CLIST (gtk-object $this))
				  (pragma::gpointer "$1" data))))

(defmethod GtkCList (get_pixtext row column)
   (let ((pixmap::GdkPixmap* (pragma::GdkPixmap* "NULL"))
	 (mask::GdkBitmap* (pragma::GdkBitmap* "NULL"))
	 (text::string "")
	 (spacing::int 0))
      (if (zero? (gtk_clist_get_pixtext (GTK_CLIST (gtk-object $this))
					(mkfixnum row)
					(mkfixnum column)
					(pragma::string* "&$1" text)
					(pragma::guint8* "&$1" spacing)
					(pragma::GdkPixmap** "&$1" pixmap)
					(pragma::GdkBitmap** "&$1" mask)))
	  (php-warning "cannot get pixtext value")
	  (list->php-hash
	   (list (convert-to-number spacing)
		 text
		 (gtk-wrapper-new 'gdkpixmap pixmap)
		 (gtk-wrapper-new 'gdkbitmap mask))))))


(defmethod GtkCList (get_text row column)
   (let ((this::GtkCList* (GTK_CLIST (gtk-object $this)))
	 (row::int (mkfixnum row))
	 (column::int (mkfixnum column))
	 (text::string ""))
      (if (zero? (pragma::int "gtk_clist_get_text($1, $2, $3, &$4)"
			       this row column text))
	  (php-warning "cannot get text value: gtk_clist_get_text returned 0")
	  text)))

(defmethod GtkCList (get_selection_info x y)
   (let ((row::int 0)
	 (column::int 0))
      (if (zero?
	   (gtk_clist_get_selection_info (GTK_CLIST (gtk-object $this))
					 x
					 y
					 (pragma::gint* "&$1" row)
					 (pragma::gint* "&$1" column)))
	  FALSE
	  (list->php-hash (list (convert-to-number row)
				(convert-to-number column))))))


(defmethod GtkColorSelection (set_color red green blue #!optional (opacity 1.0))
   (let ((red::double (onum->float (convert-to-number red)))
	 (green::double (onum->float (convert-to-number green)))
	 (blue::double (onum->float (convert-to-number blue)))
	 (opacity::double (onum->float (convert-to-number opacity)))
	 (this::GtkColorSelection* (GTK_COLOR_SELECTION (gtk-object $this))))
   (pragma "{ gdouble value[4] = {$2, $3, $4, $5};
 gtk_color_selection_set_color($1, value); }"
	   this red green blue opacity)
   NULL))



(defmethod gtkcolorselection (get_color)
   (let ((red::double (pragma::double "0.0"))
	 (green::double (pragma::double "0.0"))
	 (blue::double (pragma::double "0.0"))
	 (opacity::double (pragma::double "0.0"))
	 (this::GtkColorSelection* (GTK_COLOR_SELECTION (gtk-object $this))))
      (pragma "{ gdouble value[4];
 gtk_color_selection_get_color($1, value);
 $2 = value[0]; $3 = value[1]; $4 = value[2]; $5 = value[3];}"
	      this red green blue opacity)
      (if (pragma::bool "$1->use_opacity" this)
	  (list->php-hash (map convert-to-number (list red green blue opacity)))
	  (list->php-hash (map convert-to-number (list red green blue))))))


(defmethod GtkCombo (set_popdown_strings strings)
   (let ((strings (maybe-unbox strings)))
      (if (not (php-hash? strings))
	  (php-warning "strings should be an array")
	  (let ((lst
		 (let loop ((lst::GList* (pragma::GList* "NULL"))
			    (strings (php-hash->list strings)))
		       (if (pair? strings)
			   (let ((s::string (convert-to-utf8 (car strings))))
			      (loop (pragma::GList* "g_list_append($1, $2)" lst s)
				    (cdr strings)))
			   lst))))
	     (let ((glst::GList* lst)
		   (this::GtkCombo* (GTK_COMBO (gtk-object $this))))
		(pragma "gtk_combo_set_popdown_strings(GTK_COMBO($1), $2)" this glst)
		(pragma "g_list_free($1)" glst)
		NULL))))
   NULL)


(defmethod GtkContainer (children)
   (list->php-hash
    (map (lambda (o)
	    (gtk-object-wrapper-new #f o))
	 (glist->list (gtk_container_children (GTK_CONTAINER (gtk-object $this)))
		       'bs-_GtkObject*))))

(define (ctree-callback ctree::GtkCTree* node::GtkCTreeNode* callback::procedure)
   (callback (gtk-object-wrapper-new 'GtkCTree* ctree)
	     (php-gtk-ctree-node-new node)))
      

(defmethod GtkCtree (post_recursive node callback #!rest extra)
   (let ((node (gtk-object/safe 'GtkCTreeNode node return))
	 (this (GTK_CTREE (gtk-object/safe 'GtkCTree $this return)))
	 (callback (maybe-unbox callback))
	 (extra (map maybe-unbox extra)))
      (gtk_ctree_post_recursive this node
				(pragma::GtkCTreeFunc "ctree_callback")
				(pragma::void* "$1" (phpgtk-callback-closure callback extra #t)))
      NULL))


(defmethod GtkCTree (node_set_row_data node data)
   (let ((this::GtkCTree* (GTK_CTREE (gtk-object $this)))
	 (node::GtkCTreeNode* (gtk-object/safe 'GtkCTreeNode node return)))
      ;; this function chucks the data in a hashtable on the bigloo side
      ;; so it won't get GC'd and then come back from the dead
      (gtk-ctree-node-set-row-data this node data)))

(defmethod GtkCTree (node_get_row_data node)
   (let ((this::GtkCTree* (GTK_CTREE (gtk-object $this)))
	 (node::GtkCTreeNode* (gtk-object/safe 'GtkCTreeNode node return)))
      (gtk-ctree-node-get-row-data this node)))

(defmethod GtkCTree (node_get_text node column)
    (let (($this::GtkCTree*
            (if (php-null? (maybe-unbox $this))
              (pragma::GtkCTree* "NULL")
              (GTK_CTREE
                (gtk-object/safe 'GtkCTree $this return))))
          (node::GtkCTreeNode*
            (if (php-null? (maybe-unbox node))
              (pragma::GtkCTreeNode* "NULL")
              (gtk-object/safe 'GtkCTreeNode node return)))
          (column::int (mkfixnum column))
	  (text::string* (pragma::string* "NULL")))
       (when (zero? (gtk_ctree_node_get_text $this node column (pragma::string* "&$1" text)))
	  (php-warning "cannot get text value")
	  (return NULL))
       (if (pragma::bool "($1 != NULL)" text)
	   (convert-to-codepage text)
	   NULL)))

(defmethod GtkEditable (insert_text text pos)
   (let* ((text::string (mkstr text))
	  (len::int (string-length text))
	  (pos::int (mkfixnum pos)))
      (gtk_editable_insert_text (GTK_EDITABLE (gtk-object $this))
				text
				len
				(pragma::gint* "&$1" pos))
      (convert-to-number pos)))

(defmethod GtkLabel (get)
   (let ((this (GTK_LABEL (gtk-object $this)))
	 (text::string ""))
      (gtk_label_get this (pragma::gchar** "&$1" text))
      text))

(defmethod GtkList (append_items items)
   (let ((items (maybe-unbox items)))
      (if (not (php-hash? items))
	  (php-warning "items should be an array")
	  (let ((lst
		 (let loop ((lst::GList* (pragma::GList* "NULL"))
			    (items (php-hash->list items))
                            (i 0))
		       (if (pair? items)
                           (if (php-object-is-a (car items) 'GtkListItem)
                               (loop (pragma::GList* "g_list_append($1, $2)" lst
                                                     (GTK_LIST_ITEM (gtk-object (car items))))
                                     (cdr items)
                                     (+ i 1))
                               (begin
                                  (php-warning "list item " i " must be a GtkListItem")
                                  (pragma "g_list_free($1)" lst)
                                  (return NULL)))
			   lst))))
             (let ((glst:Glist* lst)
                   (this::GtkList* (GTK_LIST (gtk-object/safe 'GtkList $this return))))
                (gtk_list_append_items this lst)
                ;; XXX really don't need to free the glist?
                NULL))))
   NULL)

(define (get-hash-arg name value)
   (let ((value (maybe-unbox value)))
      (if (php-hash? value)
	  value
	  (begin
	     (php-warning "Argument " name " should be an array.")
	     (make-php-hash)))))

(defmethod GtkWidget (drag_dest_set flags targets actions)
   (let ((flags (gtk-flag-value 'GTK_TYPE_DEST_DEFAULTS flags))
	 (actions (gtk-flag-value 'GTK_TYPE_GDK_DRAG_ACTION actions))
	 (targets (get-hash-arg 'targets targets)))
      (let ((c-targets (pragma::GtkTargetEntry* "g_new(GtkTargetEntry, $1)"
						(php-hash-size targets))))
	 (let ((i 0))
	    (php-hash-for-each targets
	       (lambda (k v)
		  (let ((target-values (if (php-hash? v)
					   (php-hash->list v)
					   '())))
;		     (map display-circle `("one iteration, key is " ,k " value is " ,v "\n"))
		     (unless (= 3 (length target-values))
			(php-warning "unable to parse target " i)
			(return FALSE))
		     (let ((target::string (mkstr (car target-values)))
			   (flags::int (mkfixnum (cadr target-values)))
			   (info::int (mkfixnum (caddr target-values)))
			   (c-targets::GtkTargetEntry* c-targets)
			   (i::int i))
;			(print "target " target " flags " flags " info " info)
			(pragma "$1[$2].target = $3" c-targets i target)
			(pragma "$1[$2].flags = $3" c-targets i flags)
			(pragma "$1[$2].info = $3" c-targets i info))
		     ;; XXX note that we set the outer i
		     (set! i (+ i 1)))))
;	    (print "setting drag dest " (GTK_WIDGET (gtk-object $this)) ", " flags ", " c-targets ", " actions)
	    (gtk_drag_dest_set (GTK_WIDGET (gtk-object $this)) flags c-targets i actions)
	    (let ((c-targets::GtkTargetEntry* c-targets))
	       (pragma "g_free($1)" c-targets)
	       TRUE) ))))

		     
		     


(defmethod GtkWidget (drag_source_set sbmask targets actions)
   (let ((sbmask (gtk-flag-value 'GTK_TYPE_GDK_MODIFIER_TYPE sbmask))
	 (actions (gtk-flag-value 'GTK_TYPE_GDK_DRAG_ACTION actions))
	 (targets (get-hash-arg 'targets targets)))
      (let ((c-targets (pragma::GtkTargetEntry* "g_new(GtkTargetEntry, $1)"
						(php-hash-size targets))))
	 (let ((i 0))
	    (php-hash-for-each targets
	       (lambda (k v)
;		  (map display-circle `("one (source) iteration, key is " ,k " value is " ,v "\n"))
				     
		  (let ((target-values (if (php-hash? v)
					   (php-hash->list v)
					   '())))
		     (unless (= 3 (length target-values))
			(php-warning "unable to parse target " i "  in the list of targets")
			(return FALSE))
		     (let ((target::string (mkstr (car target-values)))
			   (flags::int (mkfixnum (cadr target-values)))
			   (info::int (mkfixnum (caddr target-values)))
			   (c-targets::GtkTargetEntry* c-targets)
			   (i::int i))
;			(print "source target " target " flags " flags " info " info)
			(pragma "$1[$2].target = $3" c-targets i target)
			(pragma "$1[$2].flags = $3" c-targets i flags)
			(pragma "$1[$2].info = $3" c-targets i info))
		     ;; XXX note that we set the outer i
		     (set! i (+ i 1)))))
;	    (print "setting drag source " (GTK_WIDGET (gtk-object $this)) ", " sbmask ", " c-targets ", " actions)
	    (gtk_drag_source_set (GTK_WIDGET (gtk-object $this)) sbmask c-targets i actions)

	    (let ((c-targets::GtkTargetEntry* c-targets))
	       (pragma "g_free($1)" c-targets)
	       TRUE)))))





;; this would be handled adequately by the generated method, except
;; for the windows codepage stuff.
(defmethod GtkCTree (insert_node parent sibling text spacing pixmap_closed mask_closed pixmap_opened mask_opened is_leaf expanded)
   (let (($this::GtkCTree*
	  (if (php-null? (maybe-unbox $this))
              (pragma::GtkCTree* "NULL")
              (GTK_CTREE
	       (gtk-object/safe 'GtkCTree $this return))))
	 (parent::GtkCTreeNode*
	  (if (php-null? (maybe-unbox parent))
              (pragma::GtkCTreeNode* "NULL")
              (gtk-object/safe 'GtkCTreeNode parent return)))
	 (sibling::GtkCTreeNode*
	  (if (php-null? (maybe-unbox sibling))
              (pragma::GtkCTreeNode* "NULL")
              (gtk-object/safe 'GtkCTreeNode sibling return)))
	 ;; this is the codepage stuff he's on about :)
	 (text::string* ;(php-hash->string* text))
	  (string-list->string* (map convert-to-utf8 (php-hash->list (maybe-unbox text)))))
	 (spacing::int (mkfixnum spacing))
	 (pixmap_closed::GdkPixmap*
	  (if (php-null? (maybe-unbox pixmap_closed))
              (pragma::GdkPixmap* "NULL")
              (gtk-object/safe 'GdkPixmap pixmap_closed return)))
	 (mask_closed::GdkBitmap*
	  (if (php-null? (maybe-unbox mask_closed))
              (pragma::GdkBitmap* "NULL")
              (gtk-object/safe 'GdkBitmap mask_closed return)))
	 (pixmap_opened::GdkPixmap*
	  (if (php-null? (maybe-unbox pixmap_opened))
              (pragma::GdkPixmap* "NULL")
              (gtk-object/safe 'GdkPixmap pixmap_opened return)))
	 (mask_opened::GdkBitmap*
	  (if (php-null? (maybe-unbox mask_opened))
              (pragma::GdkBitmap* "NULL")
              (gtk-object/safe 'GdkBitmap mask_opened return)))
	 (is_leaf::bool (convert-to-boolean is_leaf))
	 (expanded::bool (convert-to-boolean expanded)))
      (gtk-wrapper-new
       'GtkCTreeNode
       (pragma::GtkCTreeNode*
	"gtk_ctree_insert_node($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)"
	$this
	parent
	sibling
	text
	spacing
	pixmap_closed
	mask_closed
	pixmap_opened
	mask_opened
	is_leaf
	expanded))))
;; pretty sure this one is handled adequately by the generated method.
;; The only thing we're missing is the nice error message when the
;; hash size != the number of columns.



(defmethod GtkCList (append text)
   (set! text (maybe-unbox text))
   (let (($this::GtkCList*
	  (if (php-null? (maybe-unbox $this))
              (pragma::GtkCList* "NULL")
              (GTK_CLIST
	       (gtk-object/safe 'GtkCList $this return)))))
      (unless (= (php-hash-size text) (GtkCList*-columns $this))
	 (php-warning "the array of strings (" (php-hash-size text)
		      ") does not match the number of colums (" (GtkCList*-columns $this) ")")
	 (return NULL))
      (let ((strings::string*
	     (string-list->string* (map convert-to-utf8 (php-hash->list text)))))
	 (convert-to-integer (pragma::int
			      "gtk_clist_append($1, $2)"
			      $this
			      strings)))))

;; same as above except it calls prepend
(defmethod GtkCList (prepend text)
   (set! text (maybe-unbox text))
   (let (($this::GtkCList*
	  (if (php-null? (maybe-unbox $this))
              (pragma::GtkCList* "NULL")
              (GTK_CLIST
	       (gtk-object/safe 'GtkCList $this return)))))
      (unless (= (php-hash-size text) (GtkCList*-columns $this))
	 (php-warning "the array of strings (" (php-hash-size text)
		      ") does not match the number of colums (" (GtkCList*-columns $this) ")")
	 (return NULL))
      (let ((strings::string*
	     (string-list->string* (map convert-to-utf8 (php-hash->list text)))))
	 (convert-to-integer (pragma::int
			      "gtk_clist_prepend($1, $2)"
			      $this
			      strings)))))
      
      
;; again, the same afaict
(defmethod GtkCList (insert row text)
   (set! text (maybe-unbox text))
   (let (($this::GtkCList*
	  (if (php-null? (maybe-unbox $this))
              (pragma::GtkCList* "NULL")
              (GTK_CLIST
	       (gtk-object/safe 'GtkCList $this return)))))
      (unless (= (php-hash-size text) (GtkCList*-columns $this))
	 (php-warning "the array of strings (" (php-hash-size text)
		      ") does not match the number of colums (" (GtkCList*-columns $this) ")")
	 (return NULL))
      (let ((strings::string*
	     (string-list->string* (map convert-to-utf8 (php-hash->list text)))))
	 (convert-to-integer (pragma::int
			      "gtk_clist_insert($1, $2, $3)"
			      $this
			      (mkfixnum row)
			      strings)))))


(defmethod GtkCList (get_text row column)
   (set! row (mkfixnum row))
   (set! column (mkfixnum column))
   (let (($this::GtkCList*
	  (if (php-null? (maybe-unbox $this))
              (pragma::GtkCList* "NULL")
              (GTK_CLIST
	       (gtk-object/safe 'GtkCList $this return)))))
      (let ((text::string (pragma::string "NULL")))
	 (when (zero? (gtk_clist_get_text $this row column (pragma::gchar** "&$1" text)))
	    (php-warning "cannot get text value")
	    (return NULL))
	 (if (pragma::bool "($1 != NULL)" text)
	     (convert-to-codepage text)
	     NULL))))
	 



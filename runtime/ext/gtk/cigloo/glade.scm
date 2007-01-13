;; generated with
;; cigloo -int-enum -macro -type GtkFrame -type GtkWidget -type GtkAccelGroup -type GtkFrameClass -type guint /usr/include/libglade-1.0/glade/glade.h  > glade.scm
(module glade-binding
   (import (gtk-binding "cigloo/gtk.scm"))
   (extern
    (include "glade/glade.h")
    
    ;; beginning of /usr/include/libglade-1.0/glade/glade.h
    (macro glade_init::void () "glade_init")
    (macro glade_gnome_init::void () "glade_gnome_init")
    (macro glade_bonobo_init::void () "glade_bonobo_init")
    (macro glade_gnome_db_init::void () "glade_gnome_db_init")
    (macro glade_load_module::void (string) "glade_load_module")
;    (type void->void "void ($(void))")
    (type string->void "void ($(char *))")
    ;; end of /usr/include/libglade-1.0/glade/glade.h
    
    
    
    ;; this bit was generated using:
    ;; cigloo -type gint -type GList -type GtkObject -type gchar -type GtkSignalFunc   -type gboolean -type gpointer -type GtkData -type GtkDataClass -type GtkType   -int-enum -macro -type GtkFrame -type GtkWidget -type GtkAccelGroup -type GtkFrameClass -type guint /usr/include/libglade-1.0/glade/glade-xml.h  > glade-xml.scm
    
    ;; beginning of /usr/include/libglade-1.0/glade/glade-xml.h
    (macro GLADE_XML::s-_GladeXML* (obj::cobj) "GLADE_XML")
;    (macro GLADE_XML_CLASS::int (int) "GLADE_XML_CLASS")
    (macro GLADE_IS_XML::int (int) "GLADE_IS_XML")
    (macro glade_xml_get_type::GtkType () "glade_xml_get_type")
    (macro glade_xml_new::GladeXML* (string string) "glade_xml_new")
    (macro glade_xml_new_with_domain::GladeXML* (string string string) "glade_xml_new_with_domain")
    (macro glade_xml_new_from_memory::GladeXML* (string int string string) "glade_xml_new_from_memory")
    (macro glade_xml_construct::gboolean (GladeXML* string string string) "glade_xml_construct")
    (macro glade_xml_signal_connect::void (GladeXML* string GtkSignalFunc) "glade_xml_signal_connect")
    (macro glade_xml_signal_connect_data::void (GladeXML* string GtkSignalFunc gpointer) "glade_xml_signal_connect_data")
    (macro glade_xml_signal_autoconnect::void (GladeXML*) "glade_xml_signal_autoconnect")
    (macro glade_xml_signal_connect_full::void (GladeXML* gchar* GladeXMLConnectFunc gpointer) "glade_xml_signal_connect_full")
    (macro glade_xml_signal_autoconnect_full::void (GladeXML* GladeXMLConnectFunc gpointer) "glade_xml_signal_autoconnect_full")
    (macro glade_xml_get_widget::GtkWidget* (GladeXML* string) "glade_xml_get_widget")
    (macro glade_xml_get_widget_prefix::GList* (GladeXML* string) "glade_xml_get_widget_prefix")
    (macro glade_xml_get_widget_by_long_name::GtkWidget* (GladeXML* string) "glade_xml_get_widget_by_long_name")
    (macro glade_xml_relative_file::gchar* (GladeXML* gchar*) "glade_xml_relative_file")
    (macro glade_get_widget_name::string (GtkWidget*) "glade_get_widget_name")
    (macro glade_get_widget_long_name::string (GtkWidget*) "glade_get_widget_long_name")
    (macro glade_get_widget_tree::GladeXML* (GtkWidget*) "glade_get_widget_tree")
    (macro glade_set_custom_handler::void (GladeXMLCustomWidgetHandler gpointer) "glade_set_custom_handler")
    (type s-_GladeXML (struct (parent::GtkData "parent") (filename::string "filename") (txtdomain::string "txtdomain") (priv::GladeXMLPrivate* "priv")) "struct _GladeXML")
    (type GladeXML s-_GladeXML "GladeXML")
    (type s-_GladeXMLClass (struct (parent_class::GtkDataClass "parent_class")) "struct _GladeXMLClass")
    (type GladeXMLClass s-_GladeXMLClass "GladeXMLClass")
    (type s-_GladeXMLPrivate (struct) "struct _GladeXMLPrivate")
    (type GladeXMLPrivate s-_GladeXMLPrivate "GladeXMLPrivate")
;    (type gchar* (pointer gchar) "gchar *")
;    (type GtkObject* (pointer GtkObject) "GtkObject *")
    (type gchar*,GtkObject*,gchar*,gchar*,GtkObject*,gboolean,gpointer->void "void ($(gchar *,GtkObject *,gchar *,gchar *,GtkObject *,gboolean,gpointer))")
    (type *gchar*,GtkObject*,gchar*,gchar*,GtkObject*,gboolean,gpointer->void (function void (gchar* GtkObject* gchar* gchar* GtkObject* gboolean gpointer)) "void ((*$)(gchar *,GtkObject *,gchar *,gchar *,GtkObject *,gboolean,gpointer))")
    (type GladeXMLConnectFunc *gchar*,GtkObject*,gchar*,gchar*,GtkObject*,gboolean,gpointer->void "GladeXMLConnectFunc")
;    (type GtkWidget* (pointer GtkWidget) "GtkWidget *")
    (type GladeXML*,gchar*,gchar*,gchar*,gchar*,gint,gint,gpointer->GtkWidget* "GtkWidget *($(GladeXML *,gchar *,gchar *,gchar *,gchar *,gint,gint,gpointer))")
    (type *GladeXML*,gchar*,gchar*,gchar*,gchar*,gint,gint,gpointer->GtkWidget* (function GtkWidget* (GladeXML* gchar* gchar* gchar* gchar* gint gint gpointer)) "GtkWidget *((*$)(GladeXML *,gchar *,gchar *,gchar *,gchar *,gint,gint,gpointer))")
    (type GladeXMLCustomWidgetHandler *GladeXML*,gchar*,gchar*,gchar*,gchar*,gint,gint,gpointer->GtkWidget* "GladeXMLCustomWidgetHandler")
;    (type void->GtkType "GtkType ($(void))")
    (type string,string->GladeXML* "GladeXML *($(char *,char *))")
    (type string,string,string->GladeXML* "GladeXML *($(char *,char *,char *))")
    (type string,int,string,string->GladeXML* "GladeXML *($(char *,int,char *,char *))")
    (type GladeXML*,string,string,string->gboolean "gboolean ($(GladeXML *,char *,char *,char *))")
    (type GladeXML*,string,GtkSignalFunc->void "void ($(GladeXML *,char *,GtkSignalFunc))")
    (type GladeXML*,string,GtkSignalFunc,gpointer->void "void ($(GladeXML *,char *,GtkSignalFunc,gpointer))")
    (type GladeXML*->void "void ($(GladeXML *))")
    (type GladeXML*,gchar*,GladeXMLConnectFunc,gpointer->void "void ($(GladeXML *,gchar *,GladeXMLConnectFunc,gpointer))")
    (type GladeXML*,GladeXMLConnectFunc,gpointer->void "void ($(GladeXML *,GladeXMLConnectFunc,gpointer))")
    (type GladeXML*,string->GtkWidget* "GtkWidget *($(GladeXML *,char *))")
;    (type GList* (pointer GList) "GList *")
    (type GladeXML*,string->GList* "GList *($(GladeXML *,char *))")
    (type GladeXML*,gchar*->gchar* "gchar *($(GladeXML *,gchar *))")
    (type GtkWidget*->string "char *($(GtkWidget *))")
    (type GtkWidget*->GladeXML* "GladeXML *($(GtkWidget *))")
    (type GladeXMLCustomWidgetHandler,gpointer->void "void ($(GladeXMLCustomWidgetHandler,gpointer))")
    ;; end of /usr/include/libglade-1.0/glade/glade-xml.h
    
    ))


;; I think this has to get called before gtk_init, or weird shit
;; happens (the gtk type system gets shat on).
(begin (glade_init) 0)

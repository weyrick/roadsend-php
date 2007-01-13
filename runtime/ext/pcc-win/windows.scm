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

(module pcc-win
   (include "../phpoo-extension.sch")
;   (library common)
   (library profiler)
;   (import (win-c-bindings "c-bindings.scm"))
   (extern
     (include "pcc-win.h")
     (type hkey (opaque) "HKEY")
     (get-registry-string::obj (key::hkey subkey::string entry-name::string)
			       "get_registry_string")
     (set-registry-key::obj (key::hkey
			     subkey::string
			     entry-name::string
			     num-val::int
			     str-val::string
			     isstring::int)
			       "set_registry_key")
     (macro winapi-shellexecute::int (hwnd::int
				      operation::string
				      file::string
				      params::string
				      workdir::string
				      showcmd::int
				      )
	    "ShellExecute")
     (macro winapi-messagebox::int (hwnd::int
				    text::string
				    caption::string
				    type::int)
	    "MessageBox")
     )
   (export
    (init-pcc-win-lib)
    (win_getlasterror)
    (win_messagebox text caption type)
    (win_get_registry_key key subkey entry)
    (win_set_registry_key key subkey entry value)
    (win_shellexecute operation file params workdir showcmd)))


; magical init routine
(define (init-pcc-win-lib)
   1)

; register the extension
(register-extension "pcc-win" "1.0.0"
                    "pcc-win" '()
                    required-extensions: '("compiler"))


; shellexecute
(defconstant SW_HIDE            (pragma::int "SW_HIDE"))
(defconstant SW_SHOWMAXIMIZED   (pragma::int "SW_SHOWMAXIMIZED"))
(defconstant SW_MAXIMIZE        (pragma::int "SW_MAXIMIZE"))
(defconstant SW_MINIMIZE        (pragma::int "SW_MINIMIZE"))
(defconstant SW_RESTORE         (pragma::int "SW_RESTORE"))
(defconstant SW_SHOW            (pragma::int "SW_SHOW"))
(defconstant SW_SHOWDEFAULT     (pragma::int "SW_SHOWDEFAULT"))
(defconstant SW_SHOWMINIMIZED   (pragma::int "SW_SHOWMINIMIZED"))
(defconstant SW_SHOWMINNOACTIVE (pragma::int "SW_SHOWMINNOACTIVE"))
(defconstant SW_SHOWNA          (pragma::int "SW_SHOWNA"))
(defconstant SW_SHOWNOACTIVATE  (pragma::int "SW_SHOWNOACTIVATE"))
(defconstant SW_SHOWNORMAL      (pragma::int "SW_SHOWNORMAL"))

; registry
(defconstant HKEY_CURRENT_USER   0)
(defconstant HKEY_LOCAL_MACHINE  1)
(defconstant HKEY_CLASSES_ROOT   2)
(defconstant HKEY_USERS          3)
(defconstant HKEY_CURRENT_CONFIG 4)
(defconstant HKEY_DYN_DATA       5)

; messagebox buttons
(defconstant MB_OK               (pragma::int "MB_OK"))
(defconstant MB_ABORTRETRYIGNORE (pragma::int "MB_ABORTRETRYIGNORE"))
(defconstant MB_OKCANCEL         (pragma::int "MB_OKCANCEL"))
(defconstant MB_RETRYCANCEL      (pragma::int "MB_RETRYCANCEL"))
(defconstant MB_YESNO            (pragma::int "MB_YESNO"))
(defconstant MB_YESNOCANCEL      (pragma::int "MB_YESNOCANCEL"))
; messagebox button defaults
(defconstant MB_DEFBUTTON1       (pragma::int "MB_DEFBUTTON1"))
(defconstant MB_DEFBUTTON2       (pragma::int "MB_DEFBUTTON2"))
(defconstant MB_DEFBUTTON3       (pragma::int "MB_DEFBUTTON3"))
(defconstant MB_DEFBUTTON4       (pragma::int "MB_DEFBUTTON4"))
; messagebox modality
(defconstant MB_APPLMODAL        (pragma::int "MB_APPLMODAL"))
(defconstant MB_SYSTEMMODAL      (pragma::int "MB_SYSTEMMODAL"))
(defconstant MB_TASKMODAL        (pragma::int "MB_TASKMODAL"))
; messagebox icons
(defconstant MB_ICONASTERISK     (pragma::int "MB_ICONASTERISK"))
(defconstant MB_ICONWARNING      (pragma::int "MB_ICONWARNING"))
(defconstant MB_ICONEXCLAMATION  (pragma::int "MB_ICONEXCLAMATION"))
(defconstant MB_ICONINFORMATION  (pragma::int "MB_ICONINFORMATION"))
(defconstant MB_ICONQUESTION     (pragma::int "MB_ICONQUESTION"))
(defconstant MB_ICONSTOP         (pragma::int "MB_ICONSTOP"))
(defconstant MB_ICONERROR        (pragma::int "MB_ICONERROR"))
(defconstant MB_ICONHAND         (pragma::int "MB_ICONHAND"))
; messagebox results
(defconstant IDCANCEL (pragma::int "IDCANCEL"))
(defconstant IDIGNORE (pragma::int "IDIGNORE"))
(defconstant IDABORT  (pragma::int "IDABORT"))
(defconstant IDNO     (pragma::int "IDNO"))
(defconstant IDOK     (pragma::int "IDOK"))
(defconstant IDYES    (pragma::int "IDYES"))
(defconstant IDRETRY  (pragma::int "IDRETRY"))

;
; RegOpenKey
;
(defbuiltin (win_get_registry_key key subkey (entry ""))
"Retrieve @var{entry} from the system registry entry pointed to by @var{key}, @var{subkey}

@subheading Parameters

@table @var

@item key [constant]
One of the predefined HKEY_* constants.

@item subkey [string]
A string specifying the path of the key.

@item entry [string]
The specific entry to retrieve. If it is not specified, the default entry is used.

@end table

@subheading Return Value [mixed]
The specified key, or @code{false} if not found.

@subheading Example
@example
$wallpaper = win_get_registry_key(HKEY_CURRENT_USER, \"Control Panel\\\\Desktop\", \"Wallpaper\");
@end example
"
   (let ((h-key #f))
      (cond ((eqv? key HKEY_CURRENT_USER) (set! h-key (pragma::hkey "HKEY_CURRENT_USER")))
	    ((eqv? key HKEY_LOCAL_MACHINE) (set! h-key (pragma::hkey "HKEY_LOCAL_MACHINE")))
	    ((eqv? key HKEY_CLASSES_ROOT) (set! h-key (pragma::hkey "HKEY_CLASSES_ROOT")))
	    ((eqv? key HKEY_USERS) (set! h-key (pragma::hkey "HKEY_USERS")))
	    ((eqv? key HKEY_CURRENT_CONFIG) (set! h-key (pragma::hkey "HKEY_CURRENT_CONFIG")))
	    ((eqv? key HKEY_DYN_DATA) (set! h-key (pragma::hkey "HKEY_DYN_DATA"))))
      (if h-key
	  (get-registry-string h-key (mkstr subkey) (mkstr entry))
	  #f)))

;
; RegCreateKey
;
(defbuiltin (win_set_registry_key key subkey (entry "") (value ""))
"Set @var{entry} in system key @var{key}, @var{subkey} in the system registry.

@subheading Parameters

@table @var

@item key [constant]
One of the predefined HKEY_* constants

@item subkey [string]
A string specifying the path of the key

@item entry [string]
The specific entry to write to. If it is not specified, the default entry is used

@item value [string]
The new value for the specified registry key. @strong{If it is not passed, the specified key will be removed.} 
@end table

@subheading Return Value [bool]
@code{true} on success or @code{false} on failure

@subheading Example
@example
win_set_registry_key(HKEY_LOCAL_MACHINE,
                     \"SOFTWARE\\Super Software Company\\ActiveProduct\\\".
                     \"1.0\"
                     \"my-integer\",
                     25);
@end example
"
   (let ((s-key (pregexp-replace* "/" (mkstr subkey) "\\\\"))
	 (ent (pregexp-replace* "/" (mkstr entry) "\\\\"))
	 (isstr? (if (php-number? value) 0 1))
	 (s-val (if (php-number? value) "" (mkstr value)))
	 (n-val (if (php-number? value) (mkfixnum value) 0))
	 (h-key #f))
      (cond ((eqv? key HKEY_CURRENT_USER) (set! h-key (pragma::hkey "HKEY_CURRENT_USER")))
	    ((eqv? key HKEY_LOCAL_MACHINE) (set! h-key (pragma::hkey "HKEY_LOCAL_MACHINE")))
	    ((eqv? key HKEY_CLASSES_ROOT) (set! h-key (pragma::hkey "HKEY_CLASSES_ROOT")))
	    ((eqv? key HKEY_USERS) (set! h-key (pragma::hkey "HKEY_USERS")))
	    ((eqv? key HKEY_CURRENT_CONFIG) (set! h-key (pragma::hkey "HKEY_CURRENT_CONFIG")))
	    ((eqv? key HKEY_DYN_DATA) (set! h-key (pragma::hkey "HKEY_DYN_DATA"))))
      (if h-key
	  (set-registry-key h-key
			    s-key
			    ent
			    n-val
			    s-val
			    isstr?)
	  #f)))
   
;
; ShellExecute
; 
(defbuiltin (win_shellexecute operation file (params 'unpassed) (workdir 'unpassed) (showcmd 'unpassed))
"Perform an operation on the specified file, such as opening a web browser to a URL or opening Notepad
on a text file.

@subheading Parameters

@table @var

@item operation [string]
The action to be performed. It may be any of the following strings:

@table @var
@item 'edit'
    Launches an editor and opens the document for editing.
@item 'explore'
    Explores the folder specified by file.
@item 'find'
    Initiates a search starting from the specified directory.
@item 'open'
    Opens the file specified by @var{file}. The file can be an executable file, a document file, or a folder.
@item 'print'
    Prints the document file specified by @var{file}. If @var{file} is not a document file, the function will fail.
@end table


@item file [string]
The file on which to execute the verb.

@item params [string]
If @var{file} is an executable file, @var{params} will be passed as parameters when the file is executed.

@item workdir [string]
The default working directory.

@item showcmd [constant]
Flags that specify how the application is displayed when it is opened. These should be one or more of the
SW_* constants binary OR'd together.

@end table

@subheading Return Value [int]
A value greater than 32 if successful, or an error value that is less than or equal to 32 otherwise.

@subheading Example
@example
// launch a web browser
$ret = win_shellexecute('open','http://www.google.com', '', '', SW_SHOWMAXIMIZED);
echo \"return: $ret\\n\";
@end example

For more information, see the @uref{http://msdn.microsoft.com/library/default.asp?url=/library/en-us/shellcc/platform/shell/reference/functions/shellexecute.asp, Microsoft API}.
"
   (let ((op (mkstr operation))
	 (target (mkstr file))
	 (args (if (eqv? params 'unpassed) "" (mkstr params)))
	 (wdir (if (eqv? workdir 'unpassed) "" (mkstr workdir)))
	 (scmd (if (eqv? showcmd 'unpassed) 0 (mkfixnum showcmd))))      
      (let ((retval (winapi-shellexecute 0 operation file args wdir scmd)))
	 (mkfixnum retval))))

;
; MessageBox
;
(defbuiltin (win_messagebox text caption (type 'unpassed))
"
Display a popup message box to the user.

@subheading Parameters

@table @var

@item text [string]
The text to show in the popup window.

@item caption [string]
The caption of the popup window.

@item type [int]
Flags that affect the type of message box shown. This argument should be created
from the MB_ constants, binary OR'd together.

@end table

@subheading Return Value [int]
The return value will depend on the @var{type} flags passed to the message box.
The value will match one of the ID_* constants, depending on which button
the user clicked on to close the message box.

@subheading Example
@example
$ret = win_messagebox('This is the test of the messagebox','Box Caption',MB_YESNOCANCEL|MB_ICONINFORMATION);
echo \"ret was $ret\n\";
switch ($ret) @{
    case IDYES:
        win_messagebox('You pressed Yes','Good');
        break;
    case IDNO:
        win_messagebox('You pressed No', 'Bad');
        break;
    case IDCANCEL:
        win_messagebox('You pressed Cancel', 'Indifferent');
        break;
@}
@end example
"
   (let ((t (mkstr text))
	 (c (mkstr caption))
	 (type (if (eqv? type 'unpassed) (mkfixnum MB_OK) (mkfixnum type))))
      (let ((retval (winapi-messagebox 0 text caption type)))
	 (mkfixnum retval))))

;
; GetLastError
;
(defbuiltin (win_getlasterror)
"
Return a string from the operating system containing a description of the last error that occured.

@subheading Return Value [string]
String containing the error message.

@subheading Example
@example
$msg = win_getlasterror();
echo \"Windows said: $msg\";
@end example"
   (let ((buf::string (make-string 1024)))
      (pragma::void 
        "FormatMessage(
            FORMAT_MESSAGE_FROM_SYSTEM |
            FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL,
            GetLastError(),
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
            $1, 1024, NULL)"
	buf)
      buf))

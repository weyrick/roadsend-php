<?php
	# Mantis - a php based bugtracking system
	# Copyright (C) 2000 - 2002  Kenzaburo Ito - kenito@300baud.org
	# Copyright (C) 2002 - 2003  Mantis Team   - mantisbt-dev@lists.sourceforge.net
	# This program is distributed under the terms and conditions of the GPL
	# See the README and LICENSE files for details

	# English: Kenzaburo Ito, kenito@300baud.org
	###########################################################################
	# English strings for Mantis
	# -------------------------------------------------
	# $Revision: 1.1 $
	# $Author: tim $
	# $Date: 2004/05/12 18:24:19 $
	#
	# $Id: strings_english.inc,v 1.1 2004/05/12 18:24:19 tim Exp $
	###########################################################################
?>
<?php
# Charset
$s_charset = 'iso-8859-1';

# Group commands menuitems
$s_actiongroup_menu_move = 'Move';
$s_actiongroup_menu_assign = 'Assign';
$s_actiongroup_menu_close = 'Close';
$s_actiongroup_menu_delete = 'Delete';
$s_actiongroup_menu_resolve = 'Resolve';
$s_actiongroup_menu_update_priority = 'Update Priority';
$s_actiongroup_menu_update_status = 'Update Status';

# new strings:
$s_all_projects = 'All Projects';
$s_move_bugs = 'Move Bugs';
$s_operation_successful = 'Operation successful.';
$s_date_order = 'Date Order';
$s_print_all_bug_page_link = 'Print Reports';
$s_csv_export = 'CSV Export';
$s_login_anonymously = 'Login Anonymously';
$s_jump_to_bugnotes = 'Jump to Bugnotes';
$s_public_project_msg = 'This project is PUBLIC.  All users have access.';
$s_private_project_msg = 'This project is PRIVATE.  Only administrators and manually added users have access.';
$s_access_level_project = 'Project Access Level';
$s_view_submitted_bug_link = 'View Submitted Bug';
$s_assigned_projects = 'Assigned Projects';
$s_unassigned_projects = 'Unassigned Projects';
$s_print = 'Print';
$s_jump = 'Jump';
$s_copy_users = 'Copy Users';
$s_copy_categories_from = 'Copy Categories From';
$s_copy_categories_to = 'Copy Categories To';
$s_bug_history = 'Bug History';


# print_all_bug_page.php : display selected bugs
$s_hide_button = 'Display selected only';

# print_all_bug_options.php : printing preferences
$s_printing_preferences_title = 'Choose fields to print';
$s_printing_options_link = 'Printing Options';

# word and excel export
$s_bugnote_title = 'Bugnote handler' ;
$s_bugnote_date = 'Date of bugnote';
$s_bugnote_description = 'Bugnote description';

$s_error_no_proceed = 'Please use the "Back" button in your web browser to return to the previous page.  There you can correct whatever problems were identified in this error or select another action.  You can also click an option from the menu bar to go directly to a new section.';

# ERROR strings
$MANTIS_ERROR[ERROR_GENERIC] = 'An error occurred during this action.  You may wish to report this error to your local administrator.';
$MANTIS_ERROR[ERROR_SQL] = 'SQL error detected.  Please report this to ';
$MANTIS_ERROR[ERROR_REPORT] = 'There was an error in your report.';
$MANTIS_ERROR[ERROR_NO_FILE_SPECIFIED] = 'No file specified';
$MANTIS_ERROR[ERROR_FILE_DISALLOWED] = 'The file type is disallowed';
$MANTIS_ERROR[ERROR_NO_DIRECTORY] = 'The directory does not exist. Please check the project settings.';
$MANTIS_ERROR[ERROR_DUPLICATE_FILE] = 'This is a duplicate file.  Please delete the file first.';
$MANTIS_ERROR[ERROR_DUPLICATE_PROJECT] = 'A project with that name already exists.';
$MANTIS_ERROR[ERROR_EMPTY_FIELD] = 'A necessary field was empty.  Please recheck your inputs.';
$MANTIS_ERROR[ERROR_PROTECTED_ACCOUNT] = 'This account is protected.  You are not allowed to access this until the account protection is lifted.';
$MANTIS_ERROR[ERROR_ACCESS_DENIED] = 'Access Denied.';
$MANTIS_ERROR[ERROR_UPLOAD_FAILURE] = 'File upload failed.  PHP file uploads may be disabled.  Please ask your admin to run the admin_check script to debug this problem.';
$MANTIS_ERROR[ERROR_FILE_TOO_BIG] = 'File upload failed.  This is likely because the filesize was larger than is currently allowed by this PHP installation.';
$MANTIS_ERROR[ERROR_GPC_VAR_NOT_FOUND] = 'A required parameter to this page was not found.';
$MANTIS_ERROR[ERROR_USER_NAME_NOT_UNIQUE] = 'That username is already being used.  Please go back and select another one.';
$MANTIS_ERROR[ERROR_CONFIG_OPT_NOT_FOUND] = 'Configuration option \'%s\' not found.';
$MANTIS_ERROR[ERROR_LANG_STRING_NOT_FOUND] = 'String not found.';
$MANTIS_ERROR[ERROR_BUGNOTE_NOT_FOUND] = 'Bugnote not found.';

$s_login_error = 'ERROR: your account may be disabled or the username/password you entered is incorrect.';
$s_login_cookies_disabled = 'ERROR: Your browser either doesn\'t know how to handle cookies, or refuses to handle them.';


?>

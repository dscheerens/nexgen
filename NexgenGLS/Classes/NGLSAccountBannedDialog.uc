/***************************************************************************************************
 *
 *  NGLS. Nexgen Global Login System by Zeropoint.
 *
 *  $CLASS        NGLSAccountBannedDialog
 *  $VERSION      1.00 (6-9-2008 18:12)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog that will be displayed if the account has been banned.
 *
 **************************************************************************************************/
class NGLSAccountBannedDialog extends NGLSLoginDialog;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	wrapLength=78
	caption="Failed to login: your account has been banned/suspended."
	message="The Nexgen Global Login System has refused your login request because your account appears to be banned or suspended. Contact the server administrator for more details about your account status."
}
/***************************************************************************************************
 *
 *  NGLS. Nexgen Global Login System by Zeropoint.
 *
 *  $CLASS        NGLSInvalidLoginInfoDialog
 *  $VERSION      1.00 (6-9-2008 18:22)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog that will be displayed if the account has been banned.
 *
 **************************************************************************************************/
class NGLSInvalidLoginInfoDialog extends NGLSLoginDialog;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	wrapLength=78
	caption="Failed to login: invalid user name or password."
	message="The Nexgen Global Login System has refused your login request because you have entered an invalid username or password."
}
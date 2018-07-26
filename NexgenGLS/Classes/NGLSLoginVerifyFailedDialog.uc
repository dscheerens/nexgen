/***************************************************************************************************
 *
 *  NGLS. Nexgen Global Login System by Zeropoint.
 *
 *  $CLASS        NGLSLoginVerifyFailedDialog
 *  $VERSION      1.00 (24-8-2008 19:22)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if an timeout occurred in the login procedure.
 *
 **************************************************************************************************/
class NGLSLoginVerifyFailedDialog extends NGLSLoginTimeoutDialog;

var UMenuLabelControl reasonLabel;                // Ban reason label component.
var localized string reasonText;                  // Reason why verification failed label text.
var localized string noReasonText;                // Text to display if no reason is given.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the dialog. Calling this function will setup the static dialog contents.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function created() {
	local float cy;
	
	super(NexgenPopupDialog).created();
	
	// Add components.
	cy = borderSize;
	
	addText(caption, cy, F_Bold, TA_Center);
	addNewLine(cy);
	addText(message, cy, F_Normal, TA_Left);
	addNewLine(cy);
	reasonLabel = addPropertyLabel(cy, reasonText, 48.0);
	
	reconnectButton = addButton(reconnectText, 64.0);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the contents for this dialog.
 *  $PARAM        reason  Reason why the player was banned.
 *  $PARAM        str2  Not used.
 *  $PARAM        str3  Not used.
 *  $PARAM        str4  Not used.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent(optional string reason, optional string str2, optional string str3, optional string str4) {
	if (reason == "") {
		reasonLabel.setText(noReasonText);
	} else {
		reasonLabel.setText(reason);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	wrapLength=79
	caption="Failed to login: unable to verify username and password."
	message="The server was unable to verify your username and password. Because of the strict server settings you are not allowed to play on this server if your username and password can't be verified. If you continue to experience this problem contact the administrator of this server."
	reasonText="Error:"
	noReasonText="Unknown"
}

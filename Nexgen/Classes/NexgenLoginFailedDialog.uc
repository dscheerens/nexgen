/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenLoginFailedDialog
 *  $VERSION      1.00 (4-12-2008 12:32)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if the client failed to send it's login information.
 *
 **************************************************************************************************/
class NexgenLoginFailedDialog extends NexgenPopupDialog;

var UWindowSmallButton reconnectButton;           // Reconnect button component.
var UMenuLabelControl diagnosticCodeLabel;        // Ban reason label component.

var localized string caption;                     // Caption to display on the dialog.
var localized string message;                     // Dialog help / info / description message.
var localized string diagnosticCodeText;          // Diagnostic code label text.
var localized string reconnectText;               // Text to display on the reconnect button.

const reconnectCommand = "Reconnect";             // Console command for reconnecting.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the dialog. Calling this function will setup the static dialog contents.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function created() {
	local float cy;
	
	super.created();
	
	// Add components.
	cy = borderSize;
	
	addText(caption, cy, F_Bold, TA_Center);
	addNewLine(cy);
	addText(message, cy, F_Normal, TA_Left);
	addNewLine(cy);
	diagnosticCodeLabel = addPropertyLabel(cy, diagnosticCodeText, 96.0);
	
	reconnectButton = addButton(reconnectText, 64.0);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the contents for this dialog.
 *  $PARAM        diagnosticCode  The diagnostics code.
 *  $PARAM        str2  Not used.
 *  $PARAM        str3  Not used.
 *  $PARAM        str4  Not used.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent(optional string diagnosticCode, optional string str2, optional string str3, optional string str4) {
	diagnosticCodeLabel.setText(diagnosticCode);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the dialog of an event (caused by user interaction with the interface).
 *                Checks if the reconnect or spectator buttons have been clicked and deals with it
 *                accordingly.
 *  $PARAM        control    The control object where the event was triggered.
 *  $PARAM        eventType  Identifier for the type of event that has occurred.
 *  $REQUIRE      control != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notify(UWindowDialogControl control, byte eventType){
	super.notify(control, eventType);
	
	// Reconnect button.
	if (control == reconnectButton && eventType == DE_Click) {
		getplayerowner().consoleCommand(reconnectCommand);
		close();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	wrapLength=79
	caption="Failed to login: login timeout."
	message="The server has disconnected your client because no login information was received. Your client sends this information automatically to the server unless a problem occurs. If you continue to experience this problem please report the diagnostics code to the administrator of this server."
	diagnosticCodeText="Diagnostics code:"
	reconnectText="Reconnect"
}
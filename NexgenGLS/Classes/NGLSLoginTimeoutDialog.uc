/***************************************************************************************************
 *
 *  NGLS. Nexgen Global Login System by Zeropoint.
 *
 *  $CLASS        NGLSLoginTimeoutDialog
 *  $VERSION      1.00 (13-10-2007 17:54)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if an timeout occurred in the login procedure.
 *
 **************************************************************************************************/
class NGLSLoginTimeoutDialog extends NexgenPopupDialog;

var UWindowSmallButton reconnectButton;           // Reconnect button component.

var localized string caption;                     // Caption to display on the dialog.
var localized string message;                     // Dialog help / info / description message.
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
	
	reconnectButton = addButton(reconnectText, 64.0);
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
function notify(UWindowDialogControl control, byte eventType) {
	super.notify(control, eventType);
	
	// Reconnect button.
	if (control == reconnectButton && eventType == DE_Click) {
		// Reconnect.
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
	caption="Failed to login: timeout."
	message="You have been disconnected from the server because your client failed to send it's login information to the server within time. You can reconnect immediately to the server by pressing the reconnect button. If you continue to experience this problem contact the administrator of this server."
	reconnectText="Reconnect"
}

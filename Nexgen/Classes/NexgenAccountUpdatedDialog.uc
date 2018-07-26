/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenAccountUpdatedDialog
 *  $VERSION      1.00 (21-10-2007 15:22)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if the account of the player was updated.
 *
 **************************************************************************************************/
class NexgenAccountUpdatedDialog extends NexgenPopupDialog;

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
	caption="Your account has been updated."
	message="The server has disconnected your client because your account was updated. For security reasons and in order to apply the changes to your account, you had to be disconnected from the server. You can reconnect immediately.\\n \\nSorry for the inconvenience."
	reconnectText="Reconnect"
	autoCloseControlPanel=true
}
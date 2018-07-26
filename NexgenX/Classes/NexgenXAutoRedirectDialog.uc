/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXAutoRedirectDialog
 *  $VERSION      1.00 (7-12-2008 16:25)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if the server is full. 
 *
 **************************************************************************************************/
class NexgenXAutoRedirectDialog extends NexgenPopupDialog;

var bool bCancelClicked;                          // Whether the user has already clicked cancel.

var UWindowSmallButton cancelButton;              // Reconnect button component.
var UMenuLabelControl serverLabel;                // Indicates the server to which the player is
                                                  // being redirected.

var localized string caption;                     // Caption to display on the dialog.
var localized string message;                     // Dialog help / info / description message.
var localized string serverText;                  // Title text for the server label.
var localized string cancelText;                  // Text to display on the reconnect button.
var localized string reconnectText;               // Text to display on the reconnect button.

const openCommand = "Open";                       // Console command for opening an URL.
const cancelCommand = "Cancel";                   // Console command to cancel connecting.
const reconnectCommand = "Reconnect";             // Console command for reconnecting.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the dialog. Calling this function will setup the static dialog contents.
 *  $ENSURE       reconnectButton != none && spectatorButton != none
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
	serverLabel = addPropertyLabel(cy, serverText, 96.0);;
	
	cancelButton = addButton(cancelText, 64.0);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the contents for this dialog.
 *  $PARAM        serverName  Name of the server where the player is being redirected to.
 *  $PARAM        serverUrl   Url of the server.
 *  $PARAM        str3        Not used.
 *  $PARAM        str4        Not used.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent(optional string serverName, optional string serverUrl, optional string str3, optional string str4) {
	getplayerowner().consoleCommand(openCommand @ serverUrl);
	serverLabel.setText(serverName @ "(" $ serverUrl $ ")");
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
	
	if (control != none && control.isA('UWindowSmallButton') && eventType == DE_Click) {
		switch (control) {
			// Cancel button.
			case cancelButton:
				if (bCancelClicked) {
					getplayerowner().consoleCommand(reconnectCommand);
					close();
				} else {
					getplayerowner().consoleCommand(cancelCommand);
					cancelButton.setText(reconnectText);
					bCancelClicked = true;
				}
				break;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	caption="Failed to login: server is full."
	message="The server you have tried to enter has no more player slots available. You are automatically being redirected to an alternate server. If you do not wish to be redirected you can cancel the automatic redirection by clicking the cancel button."
	serverText="Connecting to:"
	cancelText="Cancel"
	reconnectText="Reconnect"
}
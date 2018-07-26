/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPTagRejectDialog
 *  $VERSION      1.00 (22-6-2008 11:50)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if the player uses a protected tag in his or her name. 
 *
 **************************************************************************************************/
class NXPTagRejectDialog extends NexgenPopupDialog;

var UWindowSmallButton reconnectButton;           // Reconnect button component.
var UMenuLabelControl tagLabel;                   // Tag label component.
var UWindowEditControl nameInput;                 // Player name input field component.

var localized string caption;                     // Caption to display on the dialog.
var localized string message;                     // Dialog help / info / description message.
var localized string tagMessage;                  // Message describing the rejected tag.
var localized string nameText;                    // Label to display before the name field.
var localized string reconnectText;               // Text to display on the reconnect button.

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
	tagLabel = addLabel(cy);
	nameInput = addEditControl(cy, nameText, 64.0);
	
	reconnectButton = addButton(reconnectText, 64.0);
	
	// Set component properties.
	nameInput.setMaxLength(24);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the contents for this dialog.
 *  $PARAM        tag   The tag that is protected.
 *  $PARAM        str2  Not used.
 *  $PARAM        str3  Not used.
 *  $PARAM        str4  Not used.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent(optional string tag, optional string str2, optional string str3, optional string str4) {
	tagLabel.setText(class'NexgenUtil'.static.format(tagMessage, tag));
	nameInput.setValue(getPlayerOwner().playerReplicationInfo.playerName);
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
	local string newName;
	
	super.notify(control, eventType);
	
	// Reconnect button.
	if (control == reconnectButton && eventType == DE_Click) {
		newName = class'NexgenUtil'.static.trim(nameInput.getValue());
		// Check name.
		if (newName == "") {
			nameInput.setValue(getPlayerOwner().playerReplicationInfo.playerName);
		} else {
			// Update player name.
	        getPlayerOwner().changeName(newName);
	        getPlayerOwner().updateURL("Name", newName, true);
			
			// Reconnect.
			getplayerowner().consoleCommand(reconnectCommand);
			close();
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	caption="Failed to login: you tried to use a protected tag."
	message="This server has (clan) tag protection enabled, which means you can't use certain tags unless you have an account on the server. Please change your name and reconnect."
	tagMessage="The protected tag you tried to use is: %1"
	nameText="Name:"	
	reconnectText="Reconnect"
}